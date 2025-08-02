local WBP_RGBeginnerGuidanceSwitch = UnLua.Class()

function WBP_RGBeginnerGuidanceSwitch:Construct()
  self.Btn_Beginner.OnClicked:Add(self, self.BindOnBeginnerButtonClicked)
  self.Btn_Expert.OnClicked:Add(self, self.BindOnExpertButtonClicked)
  self.Btn_Confirm.OnClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Confirm.OnHovered:Add(self, self.BindOnConfirmButtonHovered)
  self.Btn_Confirm.OnUnhovered:Add(self, self.BindOnConfirmButtonUnhovered)
end

function WBP_RGBeginnerGuidanceSwitch:OnDisplay(...)
  self:SetIsExecute(true)
  UpdateVisibility(self.ScaleBox_Confirm_Hover, false)
  self:SetFocus()
  self:PlayAnimationForward(self.Ani_In)
end

function WBP_RGBeginnerGuidanceSwitch:SetIsExecute(InIsExecute)
  self.IsExecute = InIsExecute
  self:RefreshSelectedStatus()
end

function WBP_RGBeginnerGuidanceSwitch:BindOnBeginnerButtonClicked(...)
  self:SetIsExecute(true)
end

function WBP_RGBeginnerGuidanceSwitch:BindOnExpertButtonClicked(...)
  self:SetIsExecute(false)
end

function WBP_RGBeginnerGuidanceSwitch:BindOnConfirmButtonHovered(...)
  UpdateVisibility(self.ScaleBox_Confirm_Hover, true)
end

function WBP_RGBeginnerGuidanceSwitch:BindOnConfirmButtonUnhovered(...)
  UpdateVisibility(self.ScaleBox_Confirm_Hover, false)
end

function WBP_RGBeginnerGuidanceSwitch:BindOnConfirmButtonClicked(...)
  if self:IsAnimationPlaying(self.Ani_In) then
    self:StopAnimation(self.Ani_In)
  end
  self:PlayAnimationForward(self.Ani_Out)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
  TutorialLevelSubSystem:SetIsExecuteBeginGuideLogic(self.IsExecute)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local MiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if MiscComp then
    MiscComp:ServerSetIsExecuteBeginGuideLogic(self.IsExecute)
  else
    print("WBP_RGBeginnerGuidanceSwitch:BindOnConfirmButtonClicked not MiscComp")
  end
end

function WBP_RGBeginnerGuidanceSwitch:RefreshSelectedStatus(...)
  UpdateVisibility(self.ScaleBox_Beginner_Selected, self.IsExecute)
  UpdateVisibility(self.ScaleBox_Expert_Selected, not self.IsExecute)
end

function WBP_RGBeginnerGuidanceSwitch:OnUnDisplay(...)
end

function WBP_RGBeginnerGuidanceSwitch:OnAnimationFinished(InAnimation)
  if InAnimation == self.Ani_Out then
    RGUIMgr:HideUI(UIConfig.WBP_RGBeginnerGuidanceSwitch_C.UIName)
  end
end

function WBP_RGBeginnerGuidanceSwitch:Destruct(...)
end

return WBP_RGBeginnerGuidanceSwitch
