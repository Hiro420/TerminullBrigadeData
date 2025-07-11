local WBP_PlayerInfo_C = UnLua.Class()
function WBP_PlayerInfo_C:Construct()
  if self.OwningCharacter then
    if self.OwningCharacter.PlayerState then
      self.Txt_Name:SetText(tostring(self.OwningCharacter.PlayerState:GetUserNickName()))
    end
    self:InitWidgetInfo()
  end
  self.ShieldBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.HealthBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ArmorBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnEnterState, self, self.BindOnCharacterEnterState)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnExitState, self, self.BindOnCharacterExitState)
end
function WBP_PlayerInfo_C:Destruct()
  self.Overridden.Destruct(self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnEnterState, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnExitState, self)
  if self.OwningCharacter then
    self.OwningCharacter.OnCharacterDying:Remove(self, WBP_PlayerInfo_C.BindOnCharacterDying)
    self.OwningCharacter.OnCharacterRescue:Remove(self, WBP_PlayerInfo_C.BindOnCharacterRescue)
  end
  local ControlledCharacter = self:GetOwningPlayerPawn()
  if ControlledCharacter then
    ControlledCharacter.OnNotifyCurAimTarget:Remove(self, self.BindOnNotifyCurAimTarget)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.BarHideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.BarHideTimer)
  end
end
function WBP_PlayerInfo_C:InitWidgetInfo()
  self.DyingBox:InitInfo(self.OwningCharacter)
  self.HealthBar:InitInfo(self.OwningCharacter)
  self.ShieldBar:InitInfo(self.OwningCharacter)
  self.ArmorBar:InitInfo(self.OwningCharacter)
  if self.OwningCharacter then
    self.OwningCharacter.OnCharacterDying:Remove(self, WBP_PlayerInfo_C.BindOnCharacterDying)
    self.OwningCharacter.OnCharacterRescue:Remove(self, WBP_PlayerInfo_C.BindOnCharacterRescue)
    self.OwningCharacter.OnCharacterDying:Add(self, WBP_PlayerInfo_C.BindOnCharacterDying)
    self.OwningCharacter.OnCharacterRescue:Add(self, WBP_PlayerInfo_C.BindOnCharacterRescue)
  end
  local ControlledCharacter = self:GetOwningPlayerPawn()
  if ControlledCharacter then
    ControlledCharacter.OnNotifyCurAimTarget:Add(self, self.BindOnNotifyCurAimTarget)
  end
end
function WBP_PlayerInfo_C:BindOnCharacterDying(Character, CountDownTime)
  UpdateVisibility(self, false)
end
function WBP_PlayerInfo_C:BindOnCharacterRescue(Character)
  UpdateVisibility(self, true)
end
function WBP_PlayerInfo_C:BindOnNotifyCurAimTarget(CurTarget)
  self:ChangeBarVisByAim(CurTarget == self.OwningCharacter)
end
function WBP_PlayerInfo_C:BindOnCharacterEnterState(TargetActor, Tag)
  if TargetActor ~= self.OwningCharacter then
    return
  end
  local CharacterSettings = UE.URGCharacterSettings.GetSettings()
  if not CharacterSettings then
    return
  end
  if CharacterSettings.AbnormalStateTags:Contains(Tag) then
    if self.IsShowBar then
      self:PromptlyHideBar()
    end
    print("WBP_PlayerInfo \232\191\155\229\133\165\229\188\130\229\184\184\231\138\182\230\128\129")
    self.IsInUnNormalState = true
  end
end
function WBP_PlayerInfo_C:BindOnCharacterExitState(TargetActor, Tag, bBlocked)
  if TargetActor ~= self.OwningCharacter then
    return
  end
  local CharacterSettings = UE.URGCharacterSettings.GetSettings()
  if not CharacterSettings then
    return
  end
  if CharacterSettings.AbnormalStateTags:Contains(Tag) then
    print("WBP_PlayerInfo \232\132\177\231\166\187\229\188\130\229\184\184\231\138\182\230\128\129")
    self.IsInUnNormalState = false
  end
end
function WBP_PlayerInfo_C:ChangeBarVisByAim(IsShow)
  if self.IsInUnNormalState then
    print("\232\167\146\232\137\178\229\164\132\228\186\142\229\188\130\229\184\184\231\138\182\230\128\129\228\184\173")
    return
  end
  if self.IsShowBar ~= nil and self.IsShowBar == IsShow then
    return
  end
  self.IsShowBar = IsShow
  if self.IsShowBar then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.BarHideTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.BarHideTimer)
    end
    self.HealthBar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.ShieldBar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.ArmorBar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.BarHideTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self.HealthBar:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.ShieldBar:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.ArmorBar:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    }, self.BarDuration, false)
  end
end
function WBP_PlayerInfo_C:PromptlyHideBar()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.BarHideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.BarHideTimer)
  end
  self.HealthBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ShieldBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ArmorBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.IsShowBar = false
end
function WBP_PlayerInfo_C:CalculateBarLengthByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinLength - self.MaxLength) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxLength
end
function WBP_PlayerInfo_C:CalculateHealthHeightByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinBarHeight - self.MaxBarHeight) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxBarHeight
end
function WBP_PlayerInfo_C:CalculateShieldHeightByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinShieldBarHeight - self.MaxShieldBarHeight) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxShieldBarHeight
end
function WBP_PlayerInfo_C:UpdateBarLength(Distance)
  local HealthSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.HealthBar)
  local ShieldSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ShieldBar)
  local ArmorSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ArmorBar)
  local NameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.VerticalBox_Name)
  local Margin = UE.FMargin()
  if self.IsShowBar then
    Margin.Left = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2
    Margin.Top = HealthSlot:GetOffsets().Top
    Margin.Right = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2
    Margin.Bottom = self:CalculateHealthHeightByDistance(Distance)
    HealthSlot:SetOffsets(Margin)
    ArmorSlot:SetOffsets(Margin)
    Margin.Top = ShieldSlot:GetOffsets().Top
    Margin.Bottom = self:CalculateShieldHeightByDistance(Distance)
    ShieldSlot:SetOffsets(Margin)
  end
  Margin.Top = NameSlot:GetOffsets().Top
  Margin.Bottom = NameSlot:GetOffsets().Bottom
  NameSlot:SetOffsets(Margin)
end
function WBP_PlayerInfo_C:LuaTick(InDeltaTime)
  local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
  if CameraManager and self.OwningCharacter then
    local CameraLocation = CameraManager:GetCameraLocation()
    local OwnerLocation = self.OwningCharacter:K2_GetActorLocation()
    local Distance = UE.UKismetMathLibrary.Vector_Distance(CameraLocation, OwnerLocation)
    self:UpdateBarLength(Distance)
  end
end
return WBP_PlayerInfo_C
