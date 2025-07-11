local WBP_SettlementBattleLagacyInscription_C = UnLua.Class()
function WBP_SettlementBattleLagacyInscription_C:Construct()
end
function WBP_SettlementBattleLagacyInscription_C:InitSettlementBattleLagacyInscription(CurBattleLagacyData)
  local inscriptionId = tonumber(CurBattleLagacyData.BattleLagacyId)
  if inscriptionId > 0 then
    local inscriptionData = GetLuaInscription(inscriptionId)
    if inscriptionData then
      local name = GetInscriptionName(inscriptionId)
      local desc = GetLuaInscriptionDesc(inscriptionId)
      self.RGTextName:SetText(name)
      self.RGTextDesc:SetText(desc)
    end
  end
end
function WBP_SettlementBattleLagacyInscription_C:Destruct()
end
return WBP_SettlementBattleLagacyInscription_C
