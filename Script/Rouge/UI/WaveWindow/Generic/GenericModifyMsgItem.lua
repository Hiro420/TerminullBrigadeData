local GenericModifyMsgItem = UnLua.Class()
function GenericModifyMsgItem:InitGenericModifyMsgItem(ModifyData, ParentView, bLeft)
  self.ParentView = ParentView
  self.ModifyData = ModifyData
  self.bLeft = bLeft
  local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyData.ModifyId))
  if result then
    self.WBP_GenericModifyItem:InitGenericModifyItem(ModifyData.ModifyId, false)
    self.RGTextLevel:SetText(ModifyData.Level)
    UpdateVisibility(self.CanvasPanelLv, ModifyData.Level > 1)
    local OutSaveData = GetLuaInscription(row.Inscription)
    if OutSaveData then
      local name = GetInscriptionName(row.Inscription)
      self.RGTextName:SetText(name)
      local ItemRarityResult, ItemRarityData = GetRowData(DT.DT_ItemRarity, tostring(row.Rarity))
      if ItemRarityResult then
        self.RGTextName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
      end
    end
  end
end
function GenericModifyMsgItem:InitSpecificModifyMsgItem(InscriptionID, ParentView, bLeft)
  self.ParentView = ParentView
  self.InscriptionID = InscriptionID
  self.bLeft = bLeft
  self.WBP_GenericModifyItem:InitSpecificModifyItem(InscriptionID, false)
  UpdateVisibility(self.CanvasPanelLv, false)
  self.RGTextName:SetText(GetInscriptionName(InscriptionID))
  local ItemRarityResult, ItemRarityData = GetRowData(DT.DT_ItemRarity, UE.ERGItemRarity.EIR_Legend)
  if ItemRarityResult then
    self.RGTextName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
  end
end
function GenericModifyMsgItem:OnMouseEnter()
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  if self.ModifyData then
    self.ParentView:ShowModifyTips(true, self.ModifyData, self.bLeft)
  elseif self.InscriptionID then
    self.ParentView:ShowSpecificTips(true, self.InscriptionID, self.bLeft)
  end
end
function GenericModifyMsgItem:OnMouseLeave()
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  if self.ModifyData then
    self.ParentView:ShowModifyTips(false, nil, self.bLeft)
  elseif self.InscriptionID then
    self.ParentView:ShowSpecificTips(false, nil, self.bLeft)
  end
end
return GenericModifyMsgItem
