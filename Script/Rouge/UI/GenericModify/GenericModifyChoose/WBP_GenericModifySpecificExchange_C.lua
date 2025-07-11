local WBP_GenericModifySpecificExchange_C = UnLua.Class()
function WBP_GenericModifySpecificExchange_C:InitGenericModifySpecificExchange(ModifyID, ParentView)
  self.ParentView = ParentView
  self.ModifyID = ModifyID
  UpdateVisibility(self, true)
  self.Btn_Hover.OnHovered:Add(self, WBP_GenericModifySpecificExchange_C.OnHovered)
  self.Btn_Hover.OnUnhovered:Add(self, WBP_GenericModifySpecificExchange_C.OnUnhovered)
  self.WBP_GenericModifyItem:InitSpecificModifyItem(ModifyID, false)
  local OutSaveData = GetLuaInscription(ModifyID)
  if OutSaveData then
    local ItemRarityResult, ItemRarityData = GetRowData(DT.DT_ItemRarity, UE.ERGItemRarity.EIR_Legend)
    if ItemRarityResult then
      self.RGTextName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
      self:UpdateHoverColor(ItemRarityData.GenericModifyRareBgColor)
    end
    local name = GetInscriptionName(ModifyID)
    self.RGTextName:SetText(name)
  end
end
function WBP_GenericModifySpecificExchange_C:Hide()
  self.Btn_Hover.OnHovered:Remove(self, WBP_GenericModifySpecificExchange_C.OnHovered)
  self.Btn_Hover.OnUnhovered:Remove(self, WBP_GenericModifySpecificExchange_C.OnUnhovered)
  self.ModifyID = nil
  self.ParentView = nil
  UpdateVisibility(self, false)
end
function WBP_GenericModifySpecificExchange_C:OnHovered()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowSpecificReplaceTips(true, self.ModifyID)
  end
end
function WBP_GenericModifySpecificExchange_C:OnUnhovered()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowSpecificReplaceTips(false, self.ModifyID)
  end
end
function WBP_GenericModifySpecificExchange_C:UpdateHoverColor(Color, Glow1Color)
  local glow1Color = Glow1Color or Color
  self.URGImageChangeBg:SetColorAndOpacity(Color)
  local mat = self.select_glow_1:GetDynamicMaterial()
  if mat then
    mat:SetVectorParameterValue("color", glow1Color)
    mat:SetScalarParameterValue("alpha", glow1Color.A)
  end
end
return WBP_GenericModifySpecificExchange_C
