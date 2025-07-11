local rapidjson = require("rapidjson")
local WBP_GameOver_Fail_C = UnLua.Class()
function WBP_GameOver_Fail_C:Construct()
  self.Button_GameOver.OnClicked:Add(self, WBP_GameOver_Fail_C.BindOnGameOverButtonClicked)
  self.RemainingTime = 10
  self.Txt_RemaingTime:SetText("\230\136\145\228\186\134\232\167\163" .. tostring(self.RemainingTime))
  self.RemainTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_GameOver_Fail_C.RefreshRemainingTime
  }, 1.0, true)
end
function WBP_GameOver_Fail_C:RefreshRemainingTime()
  if self.RemainingTime <= 0 then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimer)
    end
    self:BindOnGameOverButtonClicked()
  else
    self.RemainingTime = self.RemainingTime - 1
    self.Txt_RemaingTime:SetText("\230\136\145\228\186\134\232\167\163" .. tostring(self.RemainingTime))
  end
end
function WBP_GameOver_Fail_C:BindOnGameOverButtonClicked()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager)
  if UIManager then
    UIManager:K2_CloseUI(UE.UGameplayStatics.GetObjectClass(self))
  end
  LogicLobby.OpenLobbyLevel()
end
function WBP_GameOver_Fail_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimer)
  end
end
return WBP_GameOver_Fail_C
