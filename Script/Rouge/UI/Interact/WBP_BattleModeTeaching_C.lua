local WBP_BattleModeTeaching_C = UnLua.Class()
function WBP_BattleModeTeaching_C:Construct()
  function self.EscFunctionalBtn.MainButtonClicked()
    self:BindOnEscKeyPressed()
  end
end
function WBP_BattleModeTeaching_C:InitInfo(Owner)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = DTSubsystem:GetBattleModeRowInfoById(Owner.BattleModeId, nil)
  if not Result then
    return
  end
  self.Txt_Desc:SetText(RowInfo.Desc)
end
function WBP_BattleModeTeaching_C:FocusInput()
  self.Overridden.FocusInput(self)
  local Pawn = self:GetOwningPlayerPawn()
  if Pawn then
    local InteractComp = Pawn:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
    if InteractComp then
      InteractComp:SetAllInputIgnored(true)
    end
  end
end
function WBP_BattleModeTeaching_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  local Pawn = self:GetOwningPlayerPawn()
  if Pawn then
    local InteractComp = Pawn:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
    if InteractComp then
      InteractComp:SetAllInputIgnored(false)
    end
  end
end
function WBP_BattleModeTeaching_C:OnDisplay()
  if not IsListeningForInputAction(self, self.EscKeyName) then
    ListenForInputAction(self.EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_BattleModeTeaching_C.BindOnEscKeyPressed
    })
  end
end
function WBP_BattleModeTeaching_C:BindOnEscKeyPressed()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:HideUI(UE.UGameplayStatics.GetObjectClass(self))
end
function WBP_BattleModeTeaching_C:OnUnDisplay()
  if IsListeningForInputAction(self, self.EscKeyName) then
    StopListeningForInputAction(self, self.EscKeyName, UE.EInputEvent.IE_Pressed)
  end
end
function WBP_BattleModeTeaching_C:Destruct()
  if IsListeningForInputAction(self, self.EscKeyName) then
    StopListeningForInputAction(self, self.EscKeyName, UE.EInputEvent.IE_Pressed)
  end
end
return WBP_BattleModeTeaching_C
