local ListContainer = require("Rouge.UI.Common.ListContainer")
local WBP_PickupList_C = UnLua.Class()
function WBP_PickupList_C:Construct()
  self.PickupListTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_PickupList_C.RefreshPickupList
  }, 0.1, true)
end
function WBP_PickupList_C:RefreshPickupList()
end
function WBP_PickupList_C:FocusInput()
  self.Overridden.FocusInput(self)
  if not IsListeningForInputAction(self, self.ActionName) then
    ListenForInputAction(self.ActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_PickupList_C.ListenForEscInputAction
    })
  end
end
function WBP_PickupList_C:ListenForEscInputAction()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:Switch(LogicPickup.PickupListWidgetClass, true)
  LogicPickup.SetIsIgnoreInput(false)
end
function WBP_PickupList_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  StopListeningForInputAction(self, self.ActionName, UE.EInputEvent.IE_Pressed)
end
function WBP_PickupList_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PickupListTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PickupListTimer)
  end
  self.DetailItemPanel:ClearChildren()
end
return WBP_PickupList_C
