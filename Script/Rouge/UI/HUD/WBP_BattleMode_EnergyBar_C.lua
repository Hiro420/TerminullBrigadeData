local WBP_BattleMode_EnergyBar_C = UnLua.Class()
function WBP_BattleMode_EnergyBar_C:LuaTick(InDeltaTime)
  self.Count = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(self.AbilitySystemComponent, self.Attribute, true)
  self.MaxCount = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(self.AbilitySystemComponent, self.MaxAttribute, true)
  self:SetProgress()
end
function WBP_BattleMode_EnergyBar_C:Init()
  local Player = self:GetOwningPlayerPawn()
  if Player and Player.AbilitySystemComponent then
    self.AbilitySystemComponent = Player.AbilitySystemComponent
  end
end
function WBP_BattleMode_EnergyBar_C:SetProgress()
  self.Percent = math.floor(self.Count / self.MaxCount * 100)
  self.ProgressBar_46:SetPercent(self.Count / self.MaxCount)
  self.TextProgress:SetText(self.Percent .. "%")
end
return WBP_BattleMode_EnergyBar_C
