local WBP_RootPanel_C = UnLua.Class()
function WBP_RootPanel_C:Construct()
  EventSystem.AddListenerNew(EventDef.KoreaCompliance.ShowAgePic, self, self.BindOnShowAgePic)
end
function WBP_RootPanel_C:Destruct()
  self.AllWidgets:Clear()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  EventSystem.RemoveListenerNew(EventDef.KoreaCompliance.ShowAgePic, self, self.BindOnShowAgePic)
end
function WBP_RootPanel_C:SetFullPanel(Slot)
  if Slot and Slot:IsValid() then
    local Anchors = UE.FAnchors()
    local Position = UE.FVector2D(0.0, 0.0)
    local Alignment = UE.FVector2D(0.0, 0.0)
    Anchors.Minimum = UE.FVector2D(0, 0)
    Anchors.Maximum = UE.FVector2D(1.0, 1.0)
    Slot:SetAnchors(Anchors)
    Slot:SetPosition(Position)
    Slot:SetAlignment(Alignment)
    Slot:SetAutoSize(true)
  end
end
function WBP_RootPanel_C:BindOnShowAgePic()
  UpdateVisibility(self.KoreaAge, true, false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      UpdateVisibility(self.KoreaAge, false, false)
    end
  }, 3, false)
end
return WBP_RootPanel_C
