local WBP_SettlementBattleLagacyModify_C = UnLua.Class()
function WBP_SettlementBattleLagacyModify_C:Construct()
end
function WBP_SettlementBattleLagacyModify_C:InitSettlementBattleLagacyModify(CurBattleLagacyData, ParentView)
  self.ParentView = ParentView
  self.CurBattleLagacyData = CurBattleLagacyData
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  local result, row = GetRowData(DT.DT_GenericModify, CurBattleLagacyData.BattleLagacyId)
  if result and logicCommandDataSubsystem then
    local resultGroup, rowGroup = GetRowData(DT.DT_GenericModifyGroup, row.GroupId)
    if resultGroup then
      self.RGTextGodName:SetText(rowGroup.Name)
    end
    local inscriptionData = GetLuaInscription(row.Inscription)
    if inscriptionData then
      local name = GetInscriptionName(row.Inscription)
      self.RGRichTextBlockName:SetText(name)
    end
    local resultRarity, rowRarity = GetRowData(DT.DT_ItemRarity, tostring(row.Rarity))
    if resultRarity then
      self.RGRichTextBlockName:SetDefaultColorAndOpacity(rowRarity.GenericModifyDisplayNameColor)
    end
  end
end
function WBP_SettlementBattleLagacyModify_C:OnMouseEnter()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowGenericModifyBagTips(true, self.CurBattleLagacyData.BattleLagacyId)
  end
end
function WBP_SettlementBattleLagacyModify_C:OnMouseLeave()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowGenericModifyBagTips(false, self.CurBattleLagacyData.BattleLagacyId)
  end
end
function WBP_SettlementBattleLagacyModify_C:Destruct()
end
return WBP_SettlementBattleLagacyModify_C
