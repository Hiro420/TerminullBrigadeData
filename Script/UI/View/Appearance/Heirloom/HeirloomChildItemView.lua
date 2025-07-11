local HeirloomChildItemView = UnLua.Class()
function HeirloomChildItemView:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function HeirloomChildItemView:Show(ResourceId)
  self.ResourceId = ResourceId
  local GeneralResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local RowInfo = GeneralResourceTable[self.ResourceId]
  if not RowInfo then
    print("HeirloomChildItemView:Show not found Resource Row Info, ", self.ResourceId)
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RefreshSelectedStatus(nil)
  local TableName = ""
  if RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
    TableName = TableNames.TBCharacterSkin
  elseif RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
    TableName = TableNames.TBWeapon
  elseif RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
    TableName = TableNames.TBWeaponSkin
  end
  if UE.UKismetStringLibrary.IsEmpty(TableName) then
    printError("HeirloomChildItemView:Show ItemType is invalid! ResourceId:", self.ResourceId)
    return
  end
  local BResult, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableName, self.ResourceId)
  if BResult then
    SetImageBrushByPath(self.Img_Icon, ResourceRowInfo.HeirloomIconPath, self.IconSize)
  end
  local Result, ItemRarityRowInfo = GetRowData(DT.DT_ItemRarity, RowInfo.Rare)
  if Result then
    self.Img_BottomLine:SetColorAndOpacity(ItemRarityRowInfo.DisplayNameColor.SpecifiedColor)
  end
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.BindOnHeirloomSelectedItemChanged)
end
function HeirloomChildItemView:BindOnMainButtonClicked()
  if self.CurSelectedResourceId ~= self.ResourceId then
    EventSystem.Invoke(EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.ResourceId)
  end
end
function HeirloomChildItemView:BindOnMainButtonHovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationForward(self.Ani_hover_in)
end
function HeirloomChildItemView:BindOnMainButtonUnhovered()
  self:PlayAnimationForward(self.Ani_hover_out)
end
function HeirloomChildItemView:OnAnimationFinished(Animation)
  if Animation == self.Ani_hover_out then
    self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function HeirloomChildItemView:RefreshSelectedStatus(ResourceId)
  self.CurSelectedResourceId = ResourceId
  if ResourceId == self.ResourceId then
    self:SetRenderScale(self.SelectedScale)
    self.Img_Bottom:SetRenderOpacity(self.SelectedBottomOpacity)
    UpdateVisibility(self.SelectPanel, true)
  else
    self:SetRenderScale(self.UnSelectedScale)
    self.Img_Bottom:SetRenderOpacity(self.UnSelectedBottomOpacity)
    UpdateVisibility(self.SelectPanel, false)
  end
end
function HeirloomChildItemView:Hide()
  self.ResourceId = -1
  self.CurSelectedResourceId = -1
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return HeirloomChildItemView
