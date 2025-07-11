local WBP_AwardItem_C = UnLua.Class()
function WBP_AwardItem_C:Show(ResourceId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local TableName = ""
  if RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
    TableName = TableNames.TBCharacterSkin
  elseif RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
    TableName = TableNames.TBWeapon
  elseif RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
    TableName = TableNames.TBWeaponSkin
  end
  local BResult, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableName, ResourceId)
  if BResult then
    SetImageBrushByPath(self.Img_Icon, ResourceRowInfo.HeirloomIconPath, self.IconSize)
  end
  self.Txt_Name:SetText(RowInfo.Name)
end
function WBP_AwardItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_AwardItem_C
