local BP_BattleModeNpc_C = UnLua.Class()
function BP_BattleModeNpc_C:ShowOrHideWidget(IsShow)
  local TargetWidget = self.TipWidget:GetUserWidgetObject()
  if TargetWidget then
    TargetWidget:SetIsInteract(IsShow)
    TargetWidget:ChangeStatusWidget(self.BattleModeShowType)
  end
  if IsShow and self.BattleModeShowType == UE.ERGBattleModeShowType.Pending then
    self:ShowBlurPlane()
  else
    self.Plane:SetHiddenInGame(true)
  end
end
function BP_BattleModeNpc_C:ShowBlurPlane()
end
function BP_BattleModeNpc_C:EventOnBattleModeShowType(ShowType)
  self.Overridden.EventOnBattleModeShowType(self, ShowType)
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  local TargetWidget = self.TipWidget:GetUserWidgetObject()
  if TargetWidget then
    TargetWidget:ChangeStatusWidget(ShowType)
  end
  if ShowType == UE.ERGBattleModeShowType.Finished then
    self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "Award")
    if self.MarkId == nil or -1 == self.MarkId then
      UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        function()
          self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "Award")
        end
      }, 0.5, false)
    end
  end
  if ShowType == UE.ERGBattleModeShowType.DoneReward and -1 ~= self.MarkId then
    UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
    self.MarkId = -1
  end
  if ShowType == UE.ERGBattleModeShowType.Pending then
    self:ShowBlurPlane()
  elseif not self.Plane.HiddenInGame then
    self.Plane:SetHiddenInGame(true)
  end
end
function BP_BattleModeNpc_C:ShowInteractTip()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local BattleModeInteractCompClass = UE.UClass.Load(LogicVote.BattleModeInteractCompPath)
  if not BattleModeInteractCompClass then
    return
  end
  local BattleModeInteractComp = self:GetComponentByClass(BattleModeInteractCompClass)
  local bResult, InteractTipRow = DTSubsystem:GetInteractTipRowByID(self:GetInteractTipId(), nil)
  if bResult then
    HUD:UpdateInteractWidget(InteractTipRow, self, true)
    if BattleModeInteractComp.InteractConfig.Behavior == UE.ERGInteractBehavior.Duration then
      HUD:UpdateInteractStatues(true, BattleModeInteractComp)
    end
  else
    HUD:UpdateInteractWidget(nil, self, false)
  end
end
function BP_BattleModeNpc_C:GetInteractTipId()
  local TipId = 0
  if self.BattleModeShowType == UE.ERGBattleModeShowType.Pending then
    TipId = 1013
  elseif self.BattleModeShowType == UE.ERGBattleModeShowType.Finished then
    TipId = 1009
  end
  return TipId
end
function BP_BattleModeNpc_C:ReceiveEndPlay()
  if -1 ~= self.MarkId then
    UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
  end
end
return BP_BattleModeNpc_C
