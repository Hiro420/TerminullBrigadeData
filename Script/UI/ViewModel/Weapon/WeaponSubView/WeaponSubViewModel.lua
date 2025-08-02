local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local LoginHandler = require("Protocol.LoginHandler")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local WeaponSubView = require("UI.View.Weapon.WeaponSubView.WeaponSubView")
local WeaponSubViewModel = CreateDefaultViewModel()
local GetWeaponPriorityById = function(WeaponId)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, tonumber(WeaponId))
  if result then
    return rowinfo.Priority
  end
  return 0
end
local WeaponSkinItemListSort = function(A, B)
  if A.bUnlocked and not B.bUnlocked then
    return true
  end
  if not A.bUnlocked and B.bUnlocked then
    return false
  end
  if A.WeaponSkinTb.SkinRarity ~= B.WeaponSkinTb.SkinRarity then
    return A.WeaponSkinTb.SkinRarity > B.WeaponSkinTb.SkinRarity
  end
  return A.WeaponSkinTb.SkinID > B.WeaponSkinTb.SkinID
end
local WeaponListSort = function(A, B)
  local aUnlock = A.WeaponData ~= nil
  local bUnlock = B.WeaponData ~= nil
  if aUnlock ~= bUnlock then
    return aUnlock
  end
  local aWeaponResId = tonumber(A.resourceId)
  local bWeaponResId = tonumber(B.resourceId)
  if aWeaponResId ~= bWeaponResId then
    return GetWeaponPriorityById(aWeaponResId) < GetWeaponPriorityById(bWeaponResId)
  end
  local aWeaponUUId = tonumber(A.uuid)
  local bWeaponUUId = tonumber(B.uuid)
  return aWeaponUUId > bWeaponUUId
end
local CheckWeaponSkinUnlock = function(self, WeaponSkinResId, WeaponSkinList)
  for j, k in pairs(WeaponSkinList) do
    for i, v in ipairs(k.SkinDataList) do
      if v.WeaponSkinTb.SkinID == WeaponSkinResId then
        return v.bUnlocked
      end
    end
  end
  return false
end
WeaponSubViewModel.propertyBindings = {
  WeaponList = {},
  EquipedWeapon = {}
}

function WeaponSubViewModel:OnInit()
  self.Super:OnInit()
  EventSystem.AddListenerNew(EventDef.Skin.OnWeaponSkinUpdate, self, self.OnWeaponListChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnEquippedWeaponInfoChanged)
  EventSystem.AddListenerNew(EventDef.Skin.OnWeaponSkinUpdate, self, self.OnWeaponSkinUpdate)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.OnGetWeaponSkinList)
end

function WeaponSubViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.Skin.OnWeaponSkinUpdate, self, self.OnWeaponListChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnEquippedWeaponInfoChanged)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnWeaponSkinUpdate, self, self.OnWeaponSkinUpdate)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.OnGetWeaponSkinList)
  self.Super:OnShutdown()
end

function WeaponSubViewModel:OnWeaponSkinUpdate()
  self:UpdateWeaponSkinList(self.CurSelectWeaponSkinResId)
end

function WeaponSubViewModel:SelectCurEquipedSkin(weaponResId)
  if weaponResId > 0 and SkinData.WeaponSkinMap[weaponResId] then
    local equipedSkinId = SkinData.WeaponSkinMap[weaponResId].EquipedSkinId
    if -1 == equipedSkinId then
      local tbWeapon = LuaTableMgr.GetLuaTableByName(TableNames.TBWeapon)
      if tbWeapon and tbWeapon[weaponResId] then
        equipedSkinId = tbWeapon[weaponResId].SkinID
      end
    end
    self:UpdateCurSelectWeaponSkin(equipedSkinId)
  else
    self:UpdateCurSelectWeaponSkin(-1)
  end
end

function WeaponSubViewModel:UpdateCurSelectWeaponSkin(SelectSkinResId)
  if self.CurSelectWeaponSkinResId == SelectSkinResId then
    return
  end
  self.CurSelectWeaponSkinResId = SelectSkinResId
  self.SelectSkinCanEquip = SkinData.CheckWeaponSkinCanEquip(SelectSkinResId)
  self.SelectSkinIsUnlock = SkinData.GetWeaponSkinDataBySkinResId(SelectSkinResId).bUnlocked
  self:UpdateWeaponSkinList(SelectSkinResId)
end

function WeaponSubViewModel:SendEquipWeaponSkinReq(SelectSkinResId)
  if SkinData.CheckWeaponSkinCanEquip(SelectSkinResId) then
    local weaponSkinData = SkinData.GetWeaponSkinDataBySkinResId(self.CurSelectWeaponSkinResId)
    local weaponResId = -1
    if weaponSkinData then
      weaponResId = weaponSkinData.WeaponSkinTb.WeaponID
    end
    local weaponInfo
    if weaponResId > 0 then
      weaponInfo = LogicOutsideWeapon.GetWeaponInfoByWeaponResId(weaponResId)
    end
    if weaponInfo then
      SkinHandler.SendEquipWeaponSkinReq(SelectSkinResId, weaponInfo.uuid)
    end
  end
end

function WeaponSubViewModel:SelectWeapon(WeaponInfo)
  if not WeaponInfo then
    return
  end
  self.SelectWeaponId = WeaponInfo.resourceId
  self:OnWeaponListChanged()
  self:RefreshWeaponDetailsTip()
  self:RefreshWeaponDetails()
end

function WeaponSubViewModel:RequestEquipWeapon(WeaponInfo, bShowGlitchMatEffect)
  local CurSelectWeaponSlotId = 0
  local AllCanEquipWeaponList = LogicOutsideWeapon.GetAllCanEquipWeaponList(self.CurHeroId)
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  local TargetWeaponInfo = EquippedWeaponList[CurSelectWeaponSlotId + 1]
  if WeaponInfo.WeaponData and table.Contain(AllCanEquipWeaponList, tonumber(WeaponInfo.resourceId)) then
    if TargetWeaponInfo.uuid == WeaponInfo.uuid then
      print("\228\184\142\229\189\147\229\137\141\230\173\166\229\153\168\233\128\137\230\139\169\228\184\128\230\160\183")
      if self.SelectWeaponId ~= WeaponInfo.uuid then
        self.SelectWeaponId = WeaponInfo.WeaponData.uuid
        self:OnWeaponListChanged()
        self:RefreshWeaponDetailsTip()
      end
    else
      self.SelectWeaponId = WeaponInfo.WeaponData.uuid
      self.SelectWeaponResId = WeaponInfo.resourceId
      self:OnWeaponListChanged()
      self:RefreshWeaponDetailsTip()
    end
  elseif WeaponInfo.resourceId ~= self.SelectWeaponId then
    self.SelectWeaponId = WeaponInfo.resourceId
    self:OnWeaponListChanged(bShowGlitchMatEffect)
    self:RefreshWeaponDetailsTip()
    self:RefreshWeaponDetails()
  end
end

function WeaponSubViewModel:SendRequestEquipWeapon()
  LogicOutsideWeapon.RequestEquipWeapon(self.CurHeroId, self.SelectWeaponId, 0, self.SelectWeaponResId)
end

function WeaponSubViewModel:OnGetWeaponSkinList()
  self:UpdateWeaponSkinList(self.CurSelectWeaponSkinResId)
end

function WeaponSubViewModel:OnWeaponListChanged(SkinId, WeaponId, bShowGlitchMatEffect)
  local AllCanEquipWeaponList = LogicOutsideWeapon.GetAllCanEquipWeaponDataList(self.CurHeroId)
  local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if not AllCanEquipWeaponList then
    return
  end
  self.WeaponList = AllCanEquipWeaponList
  table.sort(self.WeaponList, WeaponListSort)
  local equipedIdx = -1
  local selectIdx = -1
  local selectWeaponIdx = -1
  for i = #self.WeaponList, 1, -1 do
    if EquipedWeaponList and EquipedWeaponList[1] and self.WeaponList[i].WeaponData and self.WeaponList[i].uuid == EquipedWeaponList[1].uuid then
      equipedIdx = i
      break
    end
  end
  for i = #self.WeaponList, 1, -1 do
    if self.WeaponList[i].WeaponData and self.WeaponList[i].uuid == self.SelectWeaponId then
      selectWeaponIdx = i
      break
    end
  end
  if -1 == selectWeaponIdx then
    for i = #self.WeaponList, 1, -1 do
      if tonumber(self.WeaponList[i].resourceId) == self.SelectWeaponId then
        selectWeaponIdx = i
        break
      end
    end
  end
  if not WeaponId then
    for i = #self.WeaponList, 1, -1 do
      if self.WeaponList[i].WeaponData and self.WeaponList[i].uuid == self.SelectWeaponId then
        selectIdx = i
        break
      end
    end
  else
    for i = #self.WeaponList, 1, -1 do
      if self.WeaponList[i].uuid == WeaponId then
        selectIdx = i
        break
      end
    end
  end
  if -1 == selectIdx then
    for i = #self.WeaponList, 1, -1 do
      if tonumber(self.WeaponList[i].resourceId) == self.SelectWeaponId then
        selectIdx = i
        break
      end
    end
  end
  if -1 == selectIdx and self.WeaponList[equipedIdx] then
    selectIdx = equipedIdx
    self.SelectWeaponId = self.WeaponList[selectIdx].uuid
  end
  if self:GetFirstView() then
    self:GetFirstView():OnWeaponListUpdate(self.WeaponList, equipedIdx, selectIdx, selectWeaponIdx)
  end
  if EquipedWeaponList and EquipedWeaponList[1] then
    self.EquipedWeapon = EquipedWeaponList[1]
    self:UpdateWeaponSkinList(self.CurSelectWeaponSkinResId)
  end
end

function WeaponSubViewModel:UpdateWeaponSkinList(CurSelectWeaponSkinResId)
  local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if not EquipedWeaponList then
    return
  end
  if not EquipedWeaponList[1] then
    return
  end
  local weaponSkinInfo
  local allWeaponSkinInfos = self:GetAllWeaponSkinInfosByHeroId()
  local allWeaponSkinIds = self:GetAllWeaponSkinIdsByHeroId()
  local resourceId = -1
  local curSelectWeaponData = self:GetCurSelectWeaponData()
  if -1 ~= curSelectWeaponData.uuid then
    weaponSkinInfo = SkinData.WeaponSkinMap[tonumber(curSelectWeaponData.resourceId)]
    resourceId = curSelectWeaponData.resourceId
  else
    local EquipedWeaponInfo = EquipedWeaponList[1]
    resourceId = EquipedWeaponInfo.resourceId
    local weaponResId = tonumber(EquipedWeaponInfo.resourceId)
    weaponSkinInfo = SkinData.WeaponSkinMap[weaponResId]
  end
  if weaponSkinInfo then
    local selectSkinResId = CurSelectWeaponSkinResId or weaponSkinInfo.EquipedSkinId
    if self:GetFirstView() then
      local weaponSkinInfoTemp = DeepCopy(allWeaponSkinInfos)
      local weaponSkinIdsTemp = DeepCopy(allWeaponSkinIds)
      for i, v in pairs(weaponSkinIdsTemp) do
        table.sort(SkinData.WeaponSkinMap[v].SkinDataList, WeaponSkinItemListSort)
      end
      self.SelectSkinCanEquip = SkinData.CheckWeaponSkinCanEquip(selectSkinResId)
      self.SelectSkinIsUnlock = SkinData.GetWeaponSkinDataBySkinResId(selectSkinResId).bUnlocked
      self:GetFirstView():OnWeaponSkinListUpdate(SkinData.WeaponSkinMap, weaponSkinIdsTemp, resourceId, selectSkinResId)
      self:GetFirstView():UpdateDetailsView(CheckWeaponSkinUnlock(self, selectSkinResId, weaponSkinInfoTemp))
    end
  end
end

function WeaponSubViewModel:GetCurEquipedWeaponResId()
  local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if EquipedWeaponList and EquipedWeaponList[1] then
    return tonumber(EquipedWeaponList[1].resourceId)
  end
  return -1
end

function WeaponSubViewModel:GetCurEquipedHeroSkinId()
  return SkinData.GetEquipedSkinIdByHeroId(self.CurHeroId)
end

function WeaponSubViewModel:OnEquippedWeaponInfoChanged(HeroId)
  if self.CurHeroId ~= HeroId then
    return
  end
  self:RefreshWeaponDetailsTip(true)
  EventSystem.Invoke(EventDef.Lobby.WeaponListChanged)
end

function WeaponSubViewModel:UpdateCurHeroId(CurHeroId)
  self.CurHeroId = CurHeroId
end

function WeaponSubViewModel:SetCloseCallback(CloseCallback)
  if self:GetFirstView() then
    self:GetFirstView():SetCloseCallback(CloseCallback)
  end
end

function WeaponSubViewModel:SwitchWeaponInfo(bReset, weaponResId, playAni)
  if self:GetFirstView() then
    self:GetFirstView():ShowWeaponInfo(bReset, weaponResId, playAni)
  end
end

function WeaponSubViewModel:GetCurWeaponId()
  local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if EquipedWeaponList and EquipedWeaponList[1] then
    return EquipedWeaponList[1].uuid
  end
  return nil
end

function WeaponSubViewModel:RefreshWeaponDetailsTip(bMaintainVisble)
  local curSelectWeaponData = self:GetCurSelectWeaponData()
  if curSelectWeaponData then
    local WeaponInfo = {}
    WeaponInfo.resourceId = curSelectWeaponData.resourceId
    self.EquipWeaonInfo = WeaponInfo
    print("WeaponSubViewModel:RefreshWeaponDetailsTip", WeaponInfo.resourceId)
    local view = self:GetFirstView()
    if view then
      view:OnWeaponDetailsTipUpdate(self.EquipWeaonInfo, bMaintainVisble)
    end
  end
end

function WeaponSubViewModel:CheckSkinUnLock()
  local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if not EquipedWeaponList then
    return false
  end
  if not EquipedWeaponList[1] then
    return false
  end
  local weaponSkinInfo
  local weaponResId = -1
  local curSelectWeaponData = self:GetCurSelectWeaponData()
  if curSelectWeaponData then
    weaponSkinInfo = SkinData.WeaponSkinMap[tonumber(curSelectWeaponData.resourceId)]
    weaponResId = curSelectWeaponData.resourceId
  else
    local EquipedWeaponInfo = EquipedWeaponList[1]
    weaponResId = tonumber(EquipedWeaponInfo.resourceId)
    weaponSkinInfo = SkinData.WeaponSkinMap[weaponResId]
  end
  if weaponSkinInfo then
    return CheckWeaponSkinUnlock(self, self.CurSelectWeaponSkinResId, self:GetAllWeaponSkinInfosByHeroId())
  end
  return false
end

function WeaponSubViewModel:CheckEquipedSeason(WeaponInfo)
  if not WeaponInfo then
    return false
  end
  for i, v in ipairs(WeaponInfo.stones) do
    local ResStoneTb = LuaTableMgr.GetLuaTableByName(TableNames.TBResStoneRes)
    if ResStoneTb and ResStoneTb[v] and 2 == ResStoneTb[v].ResStoneType then
      return true
    end
  end
  return false
end

function WeaponSubViewModel:CheckEquipedSeasonExceptSlot(WeaponInfo, SlotMap)
  if not WeaponInfo then
    return false
  end
  for i, v in ipairs(WeaponInfo.stones) do
    local ResStoneTb = LuaTableMgr.GetLuaTableByName(TableNames.TBResStoneRes)
    if ResStoneTb and ResStoneTb[v] and 2 == ResStoneTb[v].ResStoneType and not SlotMap[i] then
      return true
    end
  end
  return false
end

function WeaponSubViewModel:GetCurSelectWeaponData()
  local curHaveWeaponList = LogicOutsideWeapon.GetCurCanEquipWeaponList(self.CurHeroId)
  if not curHaveWeaponList then
    return nil
  end
  if self.SelectWeaponId then
    print("WeaponSubViewModel:GetCurSelectWeaponData111", self.SelectWeaponId)
    for i, v in ipairs(curHaveWeaponList) do
      print("WeaponSubViewModel:GetCurSelectWeaponData222", v.resourceId, v.uuid)
      if v.uuid == self.SelectWeaponId then
        print("WeaponSubViewModel:GetCurSelectWeaponData333", v.resourceId)
        return {
          WeaponData = v,
          resourceId = v.resourceId,
          uuid = v.uuid
        }
      end
    end
    return {
      WeaponData = nil,
      resourceId = self.SelectWeaponId,
      uuid = -1
    }
  else
    local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    if EquipedWeaponList and EquipedWeaponList[1] then
      return {
        WeaponData = EquipedWeaponList[1],
        resourceId = EquipedWeaponList[1].resourceId,
        uuid = EquipedWeaponList[1].uuid
      }
    end
  end
  return nil
end

function WeaponSubViewModel:GetWeaponDataByResId(WeaponResId)
  local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if not EquipedWeaponList then
    return nil
  end
  for i, v in ipairs(EquipedWeaponList) do
    if tonumber(v.resourceId) == WeaponResId then
      return {
        WeaponData = v,
        resourceId = v.resourceId,
        uuid = v.uuid
      }
    end
  end
  return {resourceId = WeaponResId, uuid = -1}
end

function WeaponSubViewModel:GetAllWeaponSkinIdsByHeroId()
  local weaponInfos = self:GetAllWeaponSkinInfosByHeroId()
  local allWeaponIds = {}
  for i, v in pairs(weaponInfos) do
    table.insert(allWeaponIds, i)
  end
  local WeaponSort = function(A, B)
    local EquipedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    if EquipedWeaponList and EquipedWeaponList[1] then
      if tonumber(EquipedWeaponList[1].resourceId) == A then
        return true
      end
      if tonumber(EquipedWeaponList[1].resourceId) == B then
        return false
      end
    end
    return A < B
  end
  table.sort(allWeaponIds, WeaponSort)
  return allWeaponIds
end

function WeaponSubViewModel:GetAllWeaponSkinInfosByHeroId()
  local allWeaponSkinInfos = {}
  local AllCanEquipWeaponList = LogicOutsideWeapon.GetAllCanEquipWeaponList(self.CurHeroId)
  if AllCanEquipWeaponList then
    for i, v in ipairs(LogicOutsideWeapon.GetAllCanEquipWeaponList(self.CurHeroId)) do
      allWeaponSkinInfos[v] = SkinData.WeaponSkinMap[v]
    end
  end
  return allWeaponSkinInfos
end

function WeaponSubViewModel:EmptySelectWeaponId()
  self.SelectWeaponId = nil
end

function WeaponSubViewModel:RefreshWeaponDetails()
  if self:GetFirstView() then
    self:GetFirstView():UpdateDetailsView()
  end
end

function WeaponSubViewModel:GetWeaponSkinDataBySkinResId(CurSelectWeaponSkinResId)
  return SkinData.GetWeaponSkinDataBySkinResId(CurSelectWeaponSkinResId)
end

return WeaponSubViewModel
