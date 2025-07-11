local RoleSkinItem = UnLua.Class()
local RedDotData = require("Modules.RedDot.RedDotData")
function RoleSkinItem:Construct()
  self.WBP_Item.OnClicked:Add(self, self.OnSelectClick)
end
function RoleSkinItem:Destruct()
  self.WBP_Item.OnClicked:Remove(self, self.OnSelectClick)
end
function RoleSkinItem:OnListItemObjectSet(ListItemObj)
  UpdateVisibility(self.URGImageHover, false)
  UpdateVisibility(self.URGImageHover_1, false)
  self.DataObj = ListItemObj
  local DataObjTemp = ListItemObj
  if not DataObjTemp then
    return
  end
  local heroSkinTb = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  if not heroSkinTb or not heroSkinTb[DataObjTemp.TbId] then
    return
  end
  self.WBP_Item:InitItem(DataObjTemp.TbId)
  print("RoleSkinItem:OnListItemObjectSet", DataObjTemp.expireAt)
  self.WBP_Item:SetTargetExpirationTime(DataObjTemp.expireAt)
  local heroSkinTbData = heroSkinTb[DataObjTemp.TbId]
  if DataObjTemp.bUnlocked then
    if DataObjTemp.HeirloomId > 0 then
      self.WBP_RedDotView:ChangeRedDotIdByTag(heroSkinTbData.CharacterID .. "_" .. DataObjTemp.HeirloomId)
      if DataObjTemp.bEquiped or DataObjTemp.bIsSelected then
        local redDotId = string.format("Skin_RoleSkin_Item_%d_%d", heroSkinTbData.CharacterID, DataObjTemp.HeirloomId)
        RedDotData:SetRedDotNum(redDotId, 0)
      end
    else
      self.WBP_RedDotView:ChangeRedDotIdByTag(heroSkinTbData.CharacterID .. "_" .. heroSkinTbData.SkinID)
      if DataObjTemp.bEquiped or DataObjTemp.bIsSelected then
        local redDotId = string.format("Skin_RoleSkin_Item_%d_%d", heroSkinTbData.CharacterID, heroSkinTb[self.DataObj.TbId].SkinID)
        RedDotData:SetRedDotNum(redDotId, 0)
      end
    end
  else
    self.WBP_RedDotView:ChangeRedDotIdByTag(-1)
  end
  UpdateVisibility(self.CanvasPanelLock, not DataObjTemp.bUnlocked)
  UpdateVisibility(self.CanvasPanelLockAlpha, not DataObjTemp.bUnlocked)
  self.bUnlocked = DataObjTemp.bUnlocked
  if DataObjTemp.bUnlocked then
    self.CanvasPanelRoot:SetRenderOpacity(1)
  else
    self.CanvasPanelRoot:SetRenderOpacity(self.LockOpacity)
  end
  self.WBP_Item:SetLock(not DataObjTemp.bUnlocked)
  UpdateVisibility(self.URGImageEquiped, DataObjTemp.bEquiped)
  UpdateVisibility(self.Image_jiao, DataObjTemp.bEquiped)
  UpdateVisibility(self.Img_AttachSKin, #heroSkinTbData.AttachList > 0)
  local SkinViewModel = UIModelMgr:Get("SkinViewModel")
  local heirloomInfoList = SkinViewModel:GetHeirloomInfoListByHeirloomId(DataObjTemp.HeirloomId)
  local maxLv = SkinViewModel:GetHeirloomMaxLevel(DataObjTemp.HeirloomId)
  local index = 1
  for i = 1, maxLv do
    if heirloomInfoList[i] then
      local skinId, bHaveSkin = SkinViewModel:GetHeroSkinByHeirloomLevel(DataObjTemp.HeirloomId, i)
      if bHaveSkin then
        local item = GetOrCreateItem(self.HorizontalBoxHeirloomLv, index, self.WBP_SkinItemHeirloomLvItem:GetClass())
        local bIsUnLock = SkinViewModel:IsUnLockHeirloom(DataObjTemp.HeirloomId, i)
        UpdateVisibility(item.CanvasPanelLock, not bIsUnLock)
        UpdateVisibility(item.CanvasPanelUnLock, bIsUnLock)
        index = index + 1
      end
    end
  end
  HideOtherItem(self.HorizontalBoxHeirloomLv, index)
  self.WBP_Item:SetSel(self.DataObj.bIsSelected)
end
function RoleSkinItem:BP_OnEntryReleased()
  self.WBP_RedDotView:ChangeRedDotId("")
  self.DataObj = nil
  self.WBP_Item:SetSel(false)
end
function RoleSkinItem:OnMouseEnter()
end
function RoleSkinItem:OnMouseLeave()
end
function RoleSkinItem:OnSelectClick()
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  local heroSkinTb = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  if not heroSkinTb or not heroSkinTb[self.DataObj.TbId] then
    return
  end
  local heroSkinTbData = heroSkinTb[self.DataObj.TbId]
  if #heroSkinTbData.AttachList > 0 then
    for i, v in ipairs(heroSkinTbData.AttachList) do
      if self.DataObj.ParentView.viewModel.CurSelectHeroSkinResId == v then
        return
      end
    end
  end
  if self.DataObj.bUnlocked then
    local redDotId = string.format("Skin_RoleSkin_Item_%d", -1)
    if self.DataObj.HeirloomId > 0 then
      redDotId = string.format("Skin_RoleSkin_Item_%d_%d", heroSkinTbData.CharacterID, self.DataObj.HeirloomId)
    else
      redDotId = string.format("Skin_RoleSkin_Item_%d_%d", heroSkinTbData.CharacterID, heroSkinTb[self.DataObj.TbId].SkinID)
    end
    RedDotData:SetRedDotNum(redDotId, 0)
  end
  if self.bUnlocked and 3 == heroSkinTb[self.DataObj.TbId].SkinRarity then
    self.DataObj.ParentView:PlaySkinVoice(heroSkinTb[self.DataObj.TbId].SkinID)
  end
  self.DataObj.ParentView:SelectItem(heroSkinTb[self.DataObj.TbId].SkinID)
  self.DataObj.bIsSelected = true
  self.WBP_Item:SetSel(true)
end
return RoleSkinItem
