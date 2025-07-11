local WBP_ProgressSystem_C = UnLua.Class()
function WBP_ProgressSystem_C:LuaTick(InDeltaTime)
  if self.bFinish or self.bPause then
  else
    self.StateTime = self.StateTime + InDeltaTime
  end
end
function WBP_ProgressSystem_C:Init(id)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.FinishTimerHandle)
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.PauseTimerHandle)
    self.ProgressSystemConfig = DTSubsystem:GetProgressSystemConfig(id)
    local MatInst = self.URGImageProgress:GetDynamicMaterial()
    if MatInst then
      MatInst:SetVectorParameterValue("Color1", self.ProgressSystemConfig.Normal.Color)
    end
    SetImageBrushByPath(self.Ico, self.ProgressSystemConfig.Ico.AssetPathName)
    self.bPause = false
    self.bFinish = false
    self:SetPercent(0)
    self.RGTextTips:SetText(self.ProgressSystemConfig.Normal.Des)
    if self.StateTime == nil or self.StateTime < 0 then
      self.StateTime = 0
    end
  end
end
function WBP_ProgressSystem_C:SetPercent(NewPercent)
  self.Percent = NewPercent
  local MatInst = self.URGImageProgress:GetDynamicMaterial()
  if MatInst then
    MatInst:SetScalarParameterValue("ProgressPercent", self.Percent)
  end
  if self.Percent >= 1 then
    self:DoFinish()
  end
end
function WBP_ProgressSystem_C:DoPause()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if nil == UIManager then
    return
  end
  if nil == self.ProgressSystemConfig then
    return
  end
  self.PauseTime = 0
  self.bPause = true
  local MatInst = self.URGImageProgress:GetDynamicMaterial()
  if MatInst then
    MatInst:SetVectorParameterValue("Color1", self.ProgressSystemConfig.Puase.Color)
  end
  self.RGTextTips:SetText(self.ProgressSystemConfig.Puase.Des)
  self.OldPercent = self.Percent
  self.PauseTimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_ProgressSystem_C.TimerPause
  }, 0.02, true)
end
function WBP_ProgressSystem_C:DoFinish()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if nil == UIManager then
    return
  end
  if nil == self.ProgressSystemConfig then
    return
  end
  self.FinishTime = 0
  local MatInst = self.URGImageProgress:GetDynamicMaterial()
  if MatInst then
    MatInst:SetVectorParameterValue("Color1", self.ProgressSystemConfig.Finish.Color)
  end
  self.RGTextTips:SetText(self.ProgressSystemConfig.Finish.Des)
  self.bFinish = true
  self.FinishTimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_ProgressSystem_C.TimerFinish
  }, 0.02, true)
end
function WBP_ProgressSystem_C:TimerFinish()
  self.FinishTime = self.FinishTime + 0.02
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if nil == UIManager or self.bFinish == false then
    return
  end
  if self.FinishTime >= self.ProgressSystemConfig.Finish.StatuDuration then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.FinishTimerHandle)
    self.bFinish = false
    UIManager:K2_CloseUIByName("WBP_ProgressSystem_C")
  end
end
function WBP_ProgressSystem_C:TimerPause()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if nil == UIManager or self.Pause == false then
    self.StateTime = self.StateTime - self.PauseTime
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.PauseTimerHandle)
  end
  self.PauseTime = self.PauseTime + 0.02
  if not self.ProgressSystemConfig.bPuase then
    if self.PauseTime >= self.ProgressSystemConfig.Puase.StatuDuration then
      self.bPause = false
      self.StateTime = self.StateTime - self.PauseTime
      UIManager:K2_CloseUIByName("WBP_ProgressSystem_C")
      UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.PauseTimerHandle)
    end
    return
  end
  if self.PauseTime >= self.ProgressSystemConfig.Puase.StatuDuration then
    self.bPause = false
    self.StateTime = self.StateTime - self.PauseTime
    UIManager:K2_CloseUIByName("WBP_ProgressSystem_C")
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.PauseTimerHandle)
  end
end
return WBP_ProgressSystem_C
