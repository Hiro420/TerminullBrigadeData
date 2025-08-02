local WBP_ScrollLegandTips_C = UnLua.Class()

function WBP_ScrollLegandTips_C:InitScrollLegandItem(AttributeModifyId, Duration)
  local ResultModify, ModifyRow = GetRowData(DT.DT_AttributeModify, AttributeModifyId)
  if ResultModify then
    self.RGTextName:SetText(ModifyRow.Name)
    local inscriptionId = ModifyRow.Inscription
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if RGLogicCommandDataSubsystem and inscriptionId > 0 then
      local InscriptionDesc = GetLuaInscriptionDesc(inscriptionId, 1)
      self.RGTextDesc:SetText(InscriptionDesc)
    end
    SetImageBrushBySoftObject(self.URGImageIcon, ModifyRow.SpriteIcon)
  end
  self:PlayAnimation(self.Ani_in)
  local StartTime = Duration - self.Ani_out:GetEndTime()
  if StartTime < 0 then
    StartTime = 0
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.FadeOut
    }, StartTime, false)
  end
end

function WBP_ScrollLegandTips_C:FadeOut()
  self:StopAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_out)
end

function WBP_ScrollLegandTips_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_ScrollLegandTips_C:Destruct()
  self.Overridden.Destruct(self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
end

return WBP_ScrollLegandTips_C
