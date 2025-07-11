local WeaponSkinListItem = UnLua.Class()
function WeaponSkinListItem:InitWeaponSkinListItem(WeaponSkinListData, WeaponResId, RGToggleGroupWeaponSkin, HeroId, ParentPanel)
  UpdateVisibility(self, true, true)
  self.WeaponResId = WeaponResId
  self.ParentPanel = ParentPanel
  local bResult, itemData = GetRowData(DT.DT_Item, WeaponResId)
  if not bResult then
    return
  end
  if self.WBP_RedDotView then
    self.WBP_RedDotView:ChangeRedDotIdByTag(HeroId .. WeaponResId)
  end
  self.RGTextWeaponName:SetText(itemData.Name)
  local equipedSkinId = WeaponSkinListData.EquipedSkinId
  local showWeaponNum = 0
  local itemindex = 1
  for i, v in ipairs(WeaponSkinListData.SkinDataList) do
    if self:CheckIsShow(v.WeaponSkinTb, v.bUnlocked) then
      local weaponSkinItem = GetOrCreateItem(self.WrapBoxWeaponSkin, itemindex, self.WBP_WeaponSkinItem:GetClass())
      weaponSkinItem:InitWeaponSkinItem(v, equipedSkinId, HeroId, v.WeaponSkinTb.SkinID, ParentPanel)
      RGToggleGroupWeaponSkin:AddToGroup(v.WeaponSkinTb.SkinID, weaponSkinItem)
      showWeaponNum = showWeaponNum + 1
      itemindex = itemindex + 1
    end
  end
  HideOtherItem(self.WrapBoxWeaponSkin, showWeaponNum + 1)
end
function WeaponSkinListItem:CheckIsShow(SkinTb, IsUnlocked)
  if SkinTb.IsUnlockShow and not IsUnlocked then
    return false
  end
  return SkinTb.IsShow
end
function WeaponSkinListItem:Hide()
  UpdateVisibility(self, false)
end
function WeaponSkinListItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.ParentPanel.EnterList = true
end
function WeaponSkinListItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.ParentPanel.EnterList = false
end
return WeaponSkinListItem
