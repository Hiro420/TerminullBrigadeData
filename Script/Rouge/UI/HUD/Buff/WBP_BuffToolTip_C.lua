local WBP_BuffToolTip_C = UnLua.Class()

function WBP_BuffToolTip_C:InitInfo(Info)
  self.BuffInfo = Info
  if self.BuffInfo.IsElement then
    self.Txt_Name:SetText(self.BuffInfo.BuffData.Name)
    self.Txt_Desc:SetText(self.BuffInfo.BuffData.Description)
  elseif self.BuffInfo.IsInscription then
    local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if not LogicCommandSubsystem then
      return
    end
    local DataAssest = GetLuaInscription(self.BuffInfo.ID)
    if not DataAssest then
      return
    end
    self.Txt_Name:SetText(DataAssest.InscriptionCDData.CDName)
    self.Txt_Desc:SetText(DataAssest.InscriptionCDData.CDDesc)
  else
    self.Txt_Name:SetText(self.BuffInfo.BuffData.BuffName)
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if Character and Character.BuffComponent then
      local Desc = Character.BuffComponent:GetActiveBuffDescription(self.BuffInfo.ID, Character)
      self.Txt_Desc:SetText(Desc)
    end
  end
end

return WBP_BuffToolTip_C
