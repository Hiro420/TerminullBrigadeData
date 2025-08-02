local WBP_TalentPanel_C = UnLua.Class()

function WBP_TalentPanel_C:Construct()
end

function WBP_TalentPanel_C:OnShow()
  self:BindOnCommonTalentButtonClicked()
  LogicLobby.ChangeLobbyMainModelVis(false)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
    UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
      self,
      function()
        if UE.RGUtil.IsUObjectValid(self) then
          self:BindOnInputMethodChanged(CommonInputSubsystem:GetCurrentInputType())
        end
      end
    })
  end
end

function WBP_TalentPanel_C:OnHide()
  self:HideTalentPanel()
  LogicLobby.ChangeLobbyMainModelVis(true)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
end

function WBP_TalentPanel_C:BindOnInputMethodChanged(InputType)
  EventSystem.Invoke(EventDef.LobbyPanel.SpecialFuncPanelVisCahange, InputType ~= UE.ECommonInputType.Gamepad)
end

function WBP_TalentPanel_C:BindOnCommonTalentButtonClicked()
  self.CommonTalent:Show()
  LogicTalent.RequestGetCommonTalentsToServer()
end

function WBP_TalentPanel_C:CanDirectSwitch(NextTabWidget)
  return self.CommonTalent:CanDirectSwitch(NextTabWidget)
end

function WBP_TalentPanel_C:HideTalentPanel()
  self.CommonTalent:Hide()
end

function WBP_TalentPanel_C:Destruct()
end

return WBP_TalentPanel_C
