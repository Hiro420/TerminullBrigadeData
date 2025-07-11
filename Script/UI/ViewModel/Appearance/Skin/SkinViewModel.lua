local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local SkinData = require("Modules.Appearance.Skin.SkinData")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local SkinViewModel = CreateDefaultViewModel()
SkinViewModel.propertyBindings = {}
local HeroSkinListSort = function(A, B)
  local viewModelTemp = UIModelMgr:Get("SkinViewModel")
  local bUnlockA = false
  if A.HeirloomId > 0 and viewModelTemp then
    local heirloomIdA, levelA = HeirloomData:GetHeirloomBySkinId(A.HeroSkinTb.SkinID)
    local maxUnlockLvA = viewModelTemp:GetMaxUnLockHeirloomLevel(heirloomIdA)
    bUnlockA = maxUnlockLvA > 0
  else
    bUnlockA = A.bUnlocked
  end
  local bUnlockB = false
  if B.HeirloomId > 0 and viewModelTemp then
    local heirloomIdB, levelB = HeirloomData:GetHeirloomBySkinId(B.HeroSkinTb.SkinID)
    local maxUnlockLvB = viewModelTemp:GetMaxUnLockHeirloomLevel(heirloomIdB)
    bUnlockB = maxUnlockLvB > 0
  else
    bUnlockB = B.bUnlocked
  end
  if bUnlockA ~= bUnlockB then
    return bUnlockA
  end
  if A.HeroSkinTb.SkinRarity ~= B.HeroSkinTb.SkinRarity then
    return A.HeroSkinTb.SkinRarity > B.HeroSkinTb.SkinRarity
  end
  if A.HeroSkinTb.Sort ~= B.HeroSkinTb.Sort then
    return A.HeroSkinTb.Sort > B.HeroSkinTb.Sort
  end
  return A.HeroSkinTb.SkinID > B.HeroSkinTb.SkinID
end
local WeaponSkinListSort = function(A, B)
  if A.bUnlocked and not B.bUnlocked then
    return true
  end
  if not A.bUnlocked and B.bUnlocked then
    return false
  end
  if A.WeaponSkinTb.SkinRarity ~= B.WeaponSkinTb.SkinRarity then
    return A.WeaponSkinTb.SkinRarity > B.WeaponSkinTb.SkinRarity
  end
  if A.WeaponSkinTb.Sort ~= B.WeaponSkinTb.Sort then
    return A.WeaponSkinTb.Sort > B.WeaponSkinTb.Sort
  end
  return A.WeaponSkinTb.SkinID > B.WeaponSkinTb.SkinID
end
local CheckWeaponSkinCanEquip = function(self, SkinResId)
  local skinData
  local bEquiped = false
  for k, v in pairs(SkinData.WeaponSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.WeaponSkinTb.SkinID then
        skinData = vSkinData
        bEquiped = v.EquipedSkinId == vSkinData.WeaponSkinTb.SkinID
        break
      end
    end
  end
  if not skinData or not skinData.bUnlocked then
    return false
  end
  if bEquiped then
    return false
  end
  return true
end
function SkinViewModel:OnInit()
  self.Super:OnInit()
  EventSystem.AddListenerNew(EventDef.Skin.OnEquipHeroSkin, self, self.OnEquipHeroSkin)
  EventSystem.AddListenerNew(EventDef.Skin.OnEquipWeaponSkin, self, self.OnEquipWeaponSkin)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.OnGetHeroSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.OnGetWeaponSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnSetSkinEffectState, self, self.OnGetHeroSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnEffectStateChange, self, self.OnEffectStateChange)
  EventSystem.AddListenerNew(EventDef.Lobby.WeaponListChanged, self, self.OnWeaponInfoChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnWeaponInfoChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.OnUpdateMyHeroInfo)
  EventSystem.AddListenerNew(EventDef.Heirloom.OnHeirloomInfoChanged, self, self.OnHeirloomInfoChanged)
  self:InitHeroSkinList()
  self.ShowSeq = true
end
function SkinViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.Skin.OnEquipHeroSkin, self, self.OnEquipHeroSkin)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnEquipWeaponSkin, self, self.OnEquipWeaponSkin)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.OnGetHeroSkinList)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.OnGetWeaponSkinList)
  EventSystem.RemoveListenerNew(EventDef.Lobby.WeaponListChanged, self, self.OnWeaponInfoChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnWeaponInfoChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.OnUpdateMyHeroInfo)
  EventSystem.RemoveListenerNew(EventDef.Heirloom.OnHeirloomInfoChanged, self, self.OnHeirloomInfoChanged)
  self.Super:OnShutdown()
end
function SkinViewModel:InitHeroSkinList()
  SkinData.ClearData()
  local characterSkinList = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  for k, v in pairs(characterSkinList) do
    if not SkinData.HeroSkinMap[v.CharacterID] then
      SkinData.HeroSkinMap[v.CharacterID] = {
        EquipedSkinId = -1,
        SkinDataList = {}
      }
    end
    local heirloomId, level = HeirloomData:GetHeirloomBySkinId(v.SkinID)
    local HeroSkinData = {
      HeroSkinTb = v,
      bUnlocked = false,
      HeirloomId = heirloomId,
      HeirloomLevel = level
    }
    table.insert(SkinData.HeroSkinMap[v.CharacterID].SkinDataList, HeroSkinData)
  end
  local weaponSkinList = LuaTableMgr.GetLuaTableByName(TableNames.TBWeaponSkin)
  for k, v in pairs(weaponSkinList) do
    if not SkinData.WeaponSkinMap[v.WeaponID] then
      SkinData.WeaponSkinMap[v.WeaponID] = {
        EquipedSkinId = -1,
        SkinDataList = {}
      }
    end
    local heirloomId, level = HeirloomData:GetHeirloomBySkinId(v.SkinID)
    local WeaponSkinData = {
      WeaponSkinTb = v,
      bUnlocked = false,
      HeirloomId = heirloomId,
      HeirloomLevel = level
    }
    table.insert(SkinData.WeaponSkinMap[v.WeaponID].SkinDataList, WeaponSkinData)
  end
end
function SkinViewModel:UpdateCurSelectSkinToggle(ToggleIndex)
  if self.CurSelectSkinToggle == ToggleIndex then
    return
  end
  self.CurSelectSkinToggle = ToggleIndex
  if self.CurSelectSkinToggle == ESkinToggleStatus.HeroSkin then
    self.CurSelectHeroSkinResId = -1
    self:UpdateRoleSkinList()
  elseif self.CurSelectSkinToggle == ESkinToggleStatus.WeaponSkin then
    self.CurSelectWeaponSkinResId = -1
    self:UpdateWeaponSkinList()
  end
  self:UpdateDetailsView()
end
function SkinViewModel:UpdateRoleSkinList(bNotUpdateList)
  local curHeroId = self.CurHeroId
  if not SkinData.HeroSkinMap[curHeroId] then
    return
  end
  local showHeroSkinData = {
    EquipedSkinId = SkinData.HeroSkinMap[curHeroId].EquipedSkinId,
    SkinDataList = {}
  }
  for i, v in ipairs(SkinData.HeroSkinMap[curHeroId].SkinDataList) do
    table.insert(showHeroSkinData.SkinDataList, v)
  end
  table.sort(showHeroSkinData.SkinDataList, HeroSkinListSort)
  local view = self:GetFirstView()
  if view then
    if self.CurSelectSkinToggle == ESkinToggleStatus.HeroSkin then
      if not bNotUpdateList then
        view:OnHeroSkinListUpdate(showHeroSkinData, self.CurSelectHeroSkinResId)
      end
      view:UpdateEquipButton()
    end
    view:OnUpdateHeroSkinToggleProgress(showHeroSkinData)
  end
end
function SkinViewModel:UpdateWeaponSkinList()
  local curHeroId = self.CurHeroId
  local curCanEquipedWeapon = LogicOutsideWeapon.GetAllCanEquipWeaponList(curHeroId)
  if not curCanEquipedWeapon then
    return
  end
  local showWeaponSkinDataMap = {}
  local showWeaponIdList = {}
  for i, weaponResId in ipairs(curCanEquipedWeapon) do
    if SkinData.WeaponSkinMap[weaponResId] then
      table.insert(showWeaponIdList, weaponResId)
      if not showWeaponSkinDataMap[weaponResId] then
        local showWeaponSkinData = {
          EquipedSkinId = SkinData.WeaponSkinMap[weaponResId].EquipedSkinId,
          SkinDataList = {}
        }
        showWeaponSkinDataMap[weaponResId] = showWeaponSkinData
      end
      SkinData.WeaponSkinMap[weaponResId].EquipedSkinId = SkinData.WeaponSkinMap[weaponResId].EquipedSkinId
      for iSkinData, vSkinData in ipairs(SkinData.WeaponSkinMap[weaponResId].SkinDataList) do
        table.insert(showWeaponSkinDataMap[weaponResId].SkinDataList, vSkinData)
      end
      table.sort(showWeaponSkinDataMap[weaponResId].SkinDataList, WeaponSkinListSort)
    end
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
  table.sort(showWeaponIdList, WeaponSort)
  local view = self:GetFirstView()
  if view then
    if self.CurSelectSkinToggle == ESkinToggleStatus.WeaponSkin then
      view:OnWeaponSkinListUpdate(showWeaponSkinDataMap, showWeaponIdList, self.CurSelectWeaponSkinResId)
      view:UpdateWeaponEquipButton()
    end
    view:OnUpdateWeaponSkinToggleProgress(showWeaponSkinDataMap)
  end
end
function SkinViewModel:UpdateCurHeroId(CurHeroId)
  if self.CurHeroId == CurHeroId then
    return
  end
  self.CurHeroId = CurHeroId
  self:UpdateRoleSkinList()
  self:UpdateWeaponSkinList()
end
function SkinViewModel:UpdateCurSelectHeroSkin(SelectSkinResId, bUpdateMovie, bNotUpdateList)
  if self.CurSelectHeroSkinResId == SelectSkinResId then
    return
  end
  self.OldCurSelectHeroSkinResId = self.CurSelectHeroSkinResId
  self.CurSelectHeroSkinResId = SelectSkinResId
  self:UpdateRoleSkinList(bNotUpdateList)
  self:UpdateDetailsView(self:GetFirstView() and bUpdateMovie)
  if self:GetFirstView() and bUpdateMovie then
    self:GetFirstView():UpdateMovie(true)
  end
end
function SkinViewModel:UpdateCurSelectWeaponSkin(SelectSkinResId)
  if self.CurSelectWeaponSkinResId == SelectSkinResId then
    return
  end
  self.CurSelectWeaponSkinResId = SelectSkinResId
  self:UpdateWeaponSkinList()
  self:UpdateDetailsView()
end
function SkinViewModel:UpdateDetailsView(bUpdateMovie)
  local skinId
  if self.CurSelectSkinToggle == ESkinToggleStatus.HeroSkin then
    local CurSelectSkin = self.CurSelectHeroSkinResId
    local heroSkinData = self:GetHeroSkinDataBySkinResId(CurSelectSkin)
    if heroSkinData then
      skinId = tostring(heroSkinData.HeroSkinTb.SkinID)
    end
    local view = self:GetFirstView()
    if view then
      view:UpdateHeroSkinDetailsView(heroSkinData, bUpdateMovie)
    end
  elseif self.CurSelectSkinToggle == ESkinToggleStatus.WeaponSkin then
    local weaponSkinData = self:GetWeaponSkinDataBySkinResId(self.CurSelectWeaponSkinResId)
    if weaponSkinData then
      skinId = tostring(weaponSkinData.WeaponSkinTb.SkinID)
    end
    local view = self:GetFirstView()
    if view and weaponSkinData then
      view:UpdateWeaponSkinDetailsView(weaponSkinData)
    end
  end
end
function SkinViewModel:EquipWeaponSkin(SelectSkinResId)
  if CheckWeaponSkinCanEquip(self, SelectSkinResId) then
    local weaponSkinData = self:GetWeaponSkinDataBySkinResId(self.CurSelectWeaponSkinResId)
    local weaponResId = -1
    if weaponSkinData then
      weaponResId = weaponSkinData.WeaponSkinTb.WeaponID
    end
    local weaponInfo
    if weaponResId > 0 then
      weaponInfo = LogicOutsideWeapon.GetWeaponInfoByWeaponResId(weaponResId)
    end
    if weaponInfo then
      self:SendEquipWeaponSkinReq(SelectSkinResId, weaponInfo.uuid)
    end
  end
end
function SkinViewModel:SendEquipHeroSkinReq(HeroId, skinId)
  SkinHandler.SendEquipHeroSkinReq(HeroId, skinId)
end
function SkinViewModel:SendGetHeroSkinList()
  SkinHandler.SendGetHeroSkinList()
end
function SkinViewModel:SendEquipWeaponSkinReq(SkinId, WeaponId)
  SkinHandler.SendEquipWeaponSkinReq(SkinId, WeaponId)
end
function SkinViewModel:SendGetWeaponSkinList()
  SkinHandler.SendGetWeaponSkinList()
end
function SkinViewModel:SendSetSkinEffectState(EffectState, SkinID)
  SkinHandler.SendSetHeroSkinEffectState(EffectState, SkinID)
end
function SkinViewModel:OnEffectStateChange(EffectState, SkinId)
  local view = self:GetFirstView()
  if view then
    view:SetEffectState(EffectState, SkinId)
  end
end
function SkinViewModel:OnGetHeroSkinList(HeroSkinList)
  if not HeroSkinList then
    UnLua.LogError("SkinViewModel:OnGetHeroSkinList - data is nil.")
  end
  self:UpdateRoleSkinList()
  self:UpdateDetailsView()
end
function SkinViewModel:OnGetWeaponSkinList(WeaponSkinList)
  if not WeaponSkinList then
    UnLua.LogError("SkinViewModel:OnGetWeaponSkinList - data is nil.")
  end
  self:UpdateWeaponSkinList()
  self:UpdateDetailsView()
end
function SkinViewModel:OnEquipHeroSkin(data, HeroId, skinId)
  if not data then
    UnLua.LogError("SkinViewModel:OnEquipHeroSkin - data is nil.")
    return
  end
  DataMgr.UpdateHeroInfoSkin(HeroId, skinId)
  EventSystem.Invoke(EventDef.Lobby.UpdateMyHeroInfo)
end
function SkinViewModel:OnEquipWeaponSkin(data, SkinId, WeaponId)
  if not data then
    UnLua.LogError("SkinViewModel:OnEquipWeaponSkin - data is nil.")
  end
  DataMgr.UpdateWeaponListBySkinId(SkinId, WeaponId)
  EventSystem.Invoke(EventDef.Lobby.WeaponListChanged, SkinId, WeaponId)
end
function SkinViewModel:OnWeaponInfoChanged(SkinId, WeaponId)
  for i, v in ipairs(DataMgr.AllWeaponList) do
    if SkinData.WeaponSkinMap[tonumber(v.resourceId)] then
      SkinData.WeaponSkinMap[tonumber(v.resourceId)].EquipedSkinId = v.skin
    end
  end
  self:UpdateWeaponSkinList()
  EventSystem.Invoke(EventDef.Skin.OnWeaponSkinUpdate, SkinId, WeaponId)
end
function SkinViewModel:OnUpdateMyHeroInfo()
  for i, v in ipairs(DataMgr.GetMyHeroInfo().heros) do
    if SkinData.HeroSkinMap[v.id] then
      SkinData.HeroSkinMap[v.id].EquipedSkinId = v.skinId
    end
  end
  self:UpdateRoleSkinList()
  self:UpdateDetailsView()
  EventSystem.Invoke(EventDef.Skin.OnHeroSkinUpdate)
end
function SkinViewModel:OnHeirloomInfoChanged()
  self:UpdateRoleSkinList()
  self:UpdateDetailsView()
end
function SkinViewModel:GetWeaponResIdBySkinId(SkinId)
  return SkinData.GetWeaponResIdBySkinId(SkinId)
end
function SkinViewModel:GetHeirloomCurPreviewSkin(HeirloomId, EquipedSkinId)
  for i, v in pairs(HeirloomData.AllHeirloomInfo[HeirloomId]) do
    local skinId = self:GetHeroSkinByHeirloomLevel(HeirloomId, i)
    if skinId == EquipedSkinId then
      return v, i
    end
  end
  local unLockLv = self:GetMaxUnLockHeirloomLevel(HeirloomId)
  if 0 == unLockLv then
    local maxLv = HeirloomData:GetHeirloomMaxLevel(HeirloomId)
    return HeirloomData:GetHeirloomInfoByLevel(HeirloomId, maxLv), maxLv
  else
    return HeirloomData:GetHeirloomInfoByLevel(HeirloomId, unLockLv), unLockLv
  end
end
function SkinViewModel:GetHeirloomInfoListByHeirloomId(HeirloomId)
  return HeirloomData:GetHeirloomInfoListByHeirloomId(HeirloomId)
end
function SkinViewModel:IsUnLockHeirloom(HeirloomId, Level)
  local TargetSkinId, IsCurLevelHasSkin = HeirloomData:GetHeroSkinByHeirloomLevel(HeirloomId, Level)
  local heroSkinData = self:GetHeroSkinDataBySkinResId(TargetSkinId)
  if heroSkinData then
    return heroSkinData.bUnlocked
  end
  return HeirloomData:IsUnLockHeirloom(HeirloomId, Level)
end
function SkinViewModel:GetMaxUnLockHeirloomLevel(HeirloomId)
  local maxLv = HeirloomData:GetHeirloomMaxLevel(HeirloomId)
  local maxUnlockLv = -1
  for i = 1, maxLv do
    local TargetSkinId, IsCurLevelHasSkin = HeirloomData:GetHeroSkinByHeirloomLevel(HeirloomId, i)
    local heroSkinData = self:GetHeroSkinDataBySkinResId(TargetSkinId)
    if heroSkinData and heroSkinData.bUnlocked then
      maxUnlockLv = i
    end
  end
  if maxUnlockLv > 0 then
    return maxUnlockLv
  end
  return HeirloomData:GetMaxUnLockHeirloomLevel(HeirloomId)
end
function SkinViewModel:GetHeirloomMaxLevel(HeirloomId)
  return HeirloomData:GetHeirloomMaxLevel(HeirloomId)
end
function SkinViewModel:GetHeroSkinByHeirloomLevel(HeirloomId, Level)
  return HeirloomData:GetHeroSkinByHeirloomLevel(HeirloomId, Level)
end
function SkinViewModel:GetHeirloomIdBySkinId(SkinId)
  return HeirloomData:GetHeirloomBySkinId(SkinId)
end
function SkinViewModel:GetTbIdBySkinId(SkinId)
  local heroSkinTb = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  if heroSkinTb then
    for i, v in pairs(heroSkinTb) do
      if v.SkinID == SkinId then
        return v.ID
      end
    end
  end
  return -1
end
function SkinViewModel:GetHeroSkinDataBySkinResId(SkinResId)
  for k, v in pairs(SkinData.HeroSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.HeroSkinTb.SkinID then
        return vSkinData
      end
    end
  end
  return nil
end
function SkinViewModel:GetWeaponSkinDataBySkinResId(SkinResId)
  for k, v in pairs(SkinData.WeaponSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.WeaponSkinTb.SkinID then
        return vSkinData
      end
    end
  end
  return nil
end
function SkinViewModel:CheckSkinCost(PackageID, SkinId)
  local OwnPackageNum = DataMgr.GetPackbackNumById(PackageID)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroSkinExchange, SkinId)
  if result then
    local NeedNum = rowinfo.CostResources[1].value
    return OwnPackageNum >= NeedNum
  end
  return false
end
function SkinViewModel:GetHeroIDEquipID(curHeroId)
  return SkinData.HeroSkinMap[curHeroId].EquipedSkinId
end
function SkinViewModel:GetParentIdByResId(SkinID)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, SkinID)
  if Result then
    return RowInfo.ParentSkinId
  end
end
function SkinViewModel:CheckAllChildSkinUnlocked(ResID)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, ResID)
  if Result then
    for i, v in pairs(RowInfo.AttachList) do
      local AttachSkinData = self:GetHeroSkinDataBySkinResId(v)
      if not AttachSkinData.bUnlocked then
        return false
      end
    end
    return true
  end
end
function SkinViewModel:GetSpecialEffectStateByHeroID(HeroID)
  local HeroInfo = DataMgr.GetMyHeroInfo()
  for i, HeroInfo in ipairs(HeroInfo.heros) do
    if HeroInfo.id == HeroID then
      return HeroInfo.specialEffectState
    end
  end
  return {}
end
return SkinViewModel
