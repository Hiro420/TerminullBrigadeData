local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local FaultScore = UnLua.Class()

function FaultScore:Construct()
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnDebuffChange, self.OnDebuffChange)
  self.Mat = self.URGImage_94:GetDynamicMaterial()
end

function FaultScore:OnDebuffChange(bServerNotify)
  if ClimbTowerData:GetFaultScore() >= ClimbTowerData:GetTargetFaultScore() then
    self.RGStateController_Score:ChangeStatus("Meet", true)
    self.Progress:SetFillColorAndOpacity(self.MeetColor)
  else
    self.RGStateController_Score:ChangeStatus("UnMeet", true)
    self.Progress:SetFillColorAndOpacity(self.UnMeetColor)
  end
  self.Txt_Score:SetText(ClimbTowerData:GetFaultScore())
  self.Txt_TargetScore:SetText("/" .. ClimbTowerData:GetTargetFaultScore())
  if self.Score ~= nil and ClimbTowerData:GetFaultScore() > self.Score and not bServerNotify then
    if ClimbTowerData:GetFaultScore() >= ClimbTowerData:GetTargetFaultScore() then
      self:PlayAnimation(self.Ani_full)
    else
      self:PlayAnimation(self.Ani_add)
    end
    UpdateVisibility(self.niagara_blue, ClimbTowerData:GetFaultScore() < ClimbTowerData:GetTargetFaultScore())
    UpdateVisibility(self.niagara_yellow, ClimbTowerData:GetFaultScore() >= ClimbTowerData:GetTargetFaultScore())
  end
  self.Score = ClimbTowerData:GetFaultScore()
  if bServerNotify then
    self.DeltaScore = ClimbTowerData:GetFaultScore()
  end
end

function FaultScore:LuaTick(InDeltaTime)
  if ClimbTowerData:GetFaultScore() == nil then
    return
  end
  if nil == self.DeltaScore then
    self.DeltaScore = ClimbTowerData:GetFaultScore()
    self.Progress:SetPercent(self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    if self.Mat then
      self.Mat:SetScalarParameterValue("CirclePrecent", self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    end
    return
  end
  if self.DeltaScore < ClimbTowerData:GetFaultScore() then
    self.DeltaScore = UE.UKismetMathLibrary.FInterpTo_Constant(self.DeltaScore, ClimbTowerData:GetFaultScore(), InDeltaTime, self.InterpSpeed)
    self.Progress:SetPercent(self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    if self.Mat then
      self.Mat:SetScalarParameterValue("CirclePrecent", self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    end
  elseif self.DeltaScore > ClimbTowerData:GetFaultScore() then
    self.DeltaScore = ClimbTowerData:GetFaultScore()
    self.Progress:SetPercent(self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    if self.Mat then
      self.Mat:SetScalarParameterValue("CirclePrecent", self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    end
  else
    self.Progress:SetPercent(self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    if self.Mat then
      self.Mat:SetScalarParameterValue("CirclePrecent", self.DeltaScore / ClimbTowerData:GetTargetFaultScore())
    end
  end
end

return FaultScore
