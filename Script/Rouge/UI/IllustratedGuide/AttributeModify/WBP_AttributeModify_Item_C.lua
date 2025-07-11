local WBP_AttributeModify_Item_C = UnLua.Class()
function WBP_AttributeModify_Item_C:OnListItemObjectSet(ListItemObj)
  self.Data = ListItemObj.Data
  local Result = false
  local RowInfo = UE.FRGAttributeModifyTableRow
  Result, RowInfo = GetRowData(DT.DT_AttributeModify, self.Data.Id)
  if Result then
    self.Txt_Name:Settext(RowInfo.Name)
    local IconSize = {X = 122, Y = 122}
    SetImageBrushBySoftObject(self.Img_Icon, RowInfo.SpriteIcon, IconSize)
    self.Inscription = RowInfo.Inscription
  end
  self:SetQuality(RowInfo.Rarity)
  self:HaveYouObtained()
  self:SearchKeyword()
end
function WBP_AttributeModify_Item_C:HaveYouObtained()
  UpdateVisibility(self.Lock, not Logic_IllustratedGuide.UnLockAttributeModify[self.Data.Id])
end
function WBP_AttributeModify_Item_C:SearchKeyword()
  local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not RGLogicCommandDataSubsystem then
    return
  end
  local InscriptionDesc = GetLuaInscriptionDesc(self.Inscription, 1)
  print(":LJS", string.find(InscriptionDesc, Logic_IllustratedGuide.SearchKeyword))
  if string.find(InscriptionDesc, Logic_IllustratedGuide.SearchKeyword) then
    self.Overlay_1:SetRenderOpacity(1)
  else
    self.Overlay_1:SetRenderOpacity(0.5)
  end
end
function WBP_AttributeModify_Item_C:SetQuality(Rarity)
  if not self.Data then
    return
  end
  UpdateVisibility(self.Img_Quality_Normal, false)
  UpdateVisibility(self.Img_Quality_Excellent, false)
  UpdateVisibility(self.Img_Quality_Rare, false)
  UpdateVisibility(self.Img_Quality_Epic, false)
  UpdateVisibility(self.Img_Quality_Legend, false)
  if Rarity == UE.ERGItemRarity.EIR_Normal then
    UpdateVisibility(self.Img_Quality_Normal, true)
  elseif Rarity == UE.ERGItemRarity.EIR_Excellent then
    UpdateVisibility(self.Img_Quality_Excellent, true)
  elseif Rarity == UE.ERGItemRarity.EIR_Rare then
    UpdateVisibility(self.Img_Quality_Rare, true)
  elseif Rarity == UE.ERGItemRarity.EIR_Epic then
    UpdateVisibility(self.Img_Quality_Epic, true)
  elseif Rarity == UE.ERGItemRarity.EIR_Legend then
    UpdateVisibility(self.Img_Quality_Legend, true)
  end
end
function WBP_AttributeModify_Item_C:BP_OnItemSelectionChanged(IsSelected)
  UpdateVisibility(self.Img_Select, IsSelected)
end
function WBP_AttributeModify_Item_C:BP_OnEntryReleased()
  UpdateVisibility(self.Img_Select, false)
end
function WBP_AttributeModify_Item_C:SetSelect(bSelect)
end
function WBP_AttributeModify_Item_C:SetCover(bCover)
end
function WBP_AttributeModify_Item_C:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Img_Hovered, true)
end
function WBP_AttributeModify_Item_C:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Img_Hovered, false)
end
return WBP_AttributeModify_Item_C
