local WBP_SettlementBattleInfoItem_C = UnLua.Class()

function WBP_SettlementBattleInfoItem_C:Construct()
end

function WBP_SettlementBattleInfoItem_C:Destruct()
end

function WBP_SettlementBattleInfoItem_C:InitBattleRoleInfoData(BattleInfo)
  self.RGTextName:SetText(BattleInfo.Name)
  self.RGTextNum:SetText(math.ceil(BattleInfo.Value))
end

function WBP_SettlementBattleInfoItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SettlementBattleInfoItem_C
