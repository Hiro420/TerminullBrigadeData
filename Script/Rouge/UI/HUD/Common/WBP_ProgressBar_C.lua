local WBP_ProgressBar_C = UnLua.Class()

function WBP_ProgressBar_C:Construct()
  self.bIsStopMoveVirtualBar = true
  local BottomIcon = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.BottomBrush)
  self.Img_Bottom:SetBrushResourceObject(BottomIcon)
  local FillIcon = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.FillBrush)
  self.Img_Fill:SetBrushResourceObject(FillIcon)
  local VirtualIcon = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.VirtualBrush)
  self.VirtualBar:SetBrushResourceObject(VirtualIcon)
  self:UpdateBarStyle(self.FillColor)
  self.ReduceFXWidget:UpdateFXImgColor(self.FXImgColor)
  self.Img_VirtualWhite:SetColorAndOpacity(self.VirtualWhiteColor)
  UpdateVisibility(self.Img_VirtualWhite, false)
  UpdateVisibility(self.Img_Bottom, self.IsShowBottom)
  self:BindOrUnBindAttributeValueChangeDelegate(true)
  self:SetBarInfo()
  if 0 == self:GetMaxAttributeValue() then
    self.VirtualBar:SetClippingValue(0)
  else
    self.VirtualBar:SetClippingValue(self:GetAttributeValue() / self:GetMaxAttributeValue())
  end
  self.AttributeModifyCacheList = {}
  local AttributeValue = self:GetAttributeValue()
  local MaxAttributeValue = self:GetMaxAttributeValue()
  if 0 == MaxAttributeValue then
    self.Img_VirtualWhite:SetClippingValue(0)
  else
    self.Img_VirtualWhite:SetClippingValue(AttributeValue / MaxAttributeValue)
  end
end

function WBP_ProgressBar_C:BindOrUnBindAttributeValueChangeDelegate(IsBind)
  if not self.OwningActor then
    return
  end
  local CoreComp = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  if IsBind then
    CoreComp:BindAttributeChanged(self.Attribute, {
      self,
      self.BindOnAttributeChange
    })
    CoreComp:BindAttributeChanged(self.MaxAttribute, {
      self,
      self.BindOnMaxAttributeChange
    })
    CoreComp:BindAttributeChanged(self.ChargingAttribute, {
      self,
      self.BindOnChargingAttributeChange
    })
    CoreComp:BindAttributeChanged(self.MaxChargingAttribute, {
      self,
      self.BindOnMaxChargingAttributeChange
    })
    self.IsBound = true
  else
    CoreComp:UnBindAttributeChanged(self.Attribute, {
      self,
      self.BindOnAttributeChange
    })
    CoreComp:UnBindAttributeChanged(self.MaxAttribute, {
      self,
      self.BindOnMaxAttributeChange
    })
    CoreComp:UnBindAttributeChanged(self.ChargingAttribute, {
      self,
      self.BindOnChargingAttributeChange
    })
    CoreComp:UnBindAttributeChanged(self.MaxChargingAttribute, {
      self,
      self.BindOnMaxChargingAttributeChange
    })
    self.IsBound = false
  end
end

function WBP_ProgressBar_C:InitInfo(OwningActor)
  self.OwningActor = OwningActor
  self:BindOrUnBindAttributeValueChangeDelegate(true)
  self.OldValue = self:GetAttributeValue()
  self:SetBarInfo()
  self.ReduceFXWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.VirtualBar:SetClippingValue(self:GetAttributeValue() / self:GetMaxAttributeValue())
  self:UpdateChargingBarVisibility()
end

function WBP_ProgressBar_C:InitASCInfo(OwningActor)
  self.OwningActor = OwningActor
  self:BindOrUnBindAttributeValueChangeDelegate(true)
  self:UpdateBarInfo(self:GetAttributeValue(), self:GetAttributeValue())
end

function WBP_ProgressBar_C:BindOnAttributeChange(NewValue, OldValue)
  self:UpdateBarInfo(NewValue, OldValue)
end

function WBP_ProgressBar_C:BindOnMaxAttributeChange(NewValue, OldValue)
  self:UpdateBarInfo(NewValue, OldValue)
end

function WBP_ProgressBar_C:BindOnChargingAttributeChange(NewValue, OldValue)
  self:UpdateChargingBarVisibility()
  self:UpdateChargingBarInfo(NewValue, OldValue)
end

function WBP_ProgressBar_C:BindOnMaxChargingAttributeChange(NewValue, OldValue)
  self:UpdateChargingBarVisibility()
end

function WBP_ProgressBar_C:OnAttributeModifyCacheAdded(AttributeCacheModifyData)
  if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.Attribute) or UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.MaxAttribute) then
    local TempTable = {
      Data = AttributeCacheModifyData,
      StartTime = GetCurrentUTCTimestamp()
    }
    if not self.AttributeModifyCacheList then
      self.AttributeModifyCacheList = {}
    end
    self.AttributeModifyCacheList[AttributeCacheModifyData.ModifyID] = TempTable
    self.IsUpdateAttributeCache = true
  end
end

function WBP_ProgressBar_C:OnAttributeModifyCacheRemove(AttributeCacheModifyData)
  if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.Attribute) or UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.MaxAttribute) then
    self.AttributeModifyCacheList[AttributeCacheModifyData.ModifyID] = nil
    self.IsUpdateAttributeCache = table.count(self.AttributeModifyCacheList) > 0
    if not self.IsUpdateAttributeCache then
      self.CurrentAttributeValue = self:GetAttributeValue()
      if self.SetAttribtueModifyTextFunction then
        self:SetAttribtueModifyTextFunction(self.CurrentAttributeValue)
      end
      self:SetBarInfo(self.CurrentAttributeValue)
    end
  end
end

function WBP_ProgressBar_C:UpdateAttributeCachedModify(DeltaTime)
  if not self.CurrentAttributeValue then
    self.CurrentAttributeValue = self:GetAttributeValue()
  end
  for ModifyId, AttributeConfigTable in pairs(self.AttributeModifyCacheList) do
    if GetCurrentUTCTimestamp() - AttributeConfigTable.StartTime <= AttributeConfigTable.Data.ConfigData.Duration then
      local TargetModifyValue = DeltaTime / AttributeConfigTable.Data.ConfigData.Interval * AttributeConfigTable.Data.ConfigData.IntervalModifyValue
      self.CurrentAttributeValue = self.CurrentAttributeValue + TargetModifyValue
    end
  end
  self:SetBarInfo(self.CurrentAttributeValue)
end

function WBP_ProgressBar_C:SetBarInfo(TargetAttributeValue)
  local AttributeValue = self:GetAttributeValue()
  if TargetAttributeValue then
    AttributeValue = TargetAttributeValue
  end
  local MaxAttributeValue = self:GetMaxAttributeValue()
  if AttributeValue > 0 and AttributeValue < 1 then
    AttributeValue = 1
  end
  self.Txt_Num:SetText(tostring(math.ceil(AttributeValue)) .. "/" .. tostring(math.ceil(MaxAttributeValue)))
  local Percent = AttributeValue / MaxAttributeValue
  if 0 == MaxAttributeValue then
    self.Img_Fill:SetClippingValue(0)
    self.Img_VirtualWhite:SetClippingValue(0)
    self.CurFillPercent = 0
    if self.OnValueChangeFunc then
      self.OnValueChangeFunc(0)
    end
  else
    self.Img_Fill:SetClippingValue(Percent)
    self.CurFillPercent = Percent
    if self.OnValueChangeFunc then
      self.OnValueChangeFunc(Percent)
    end
  end
end

function WBP_ProgressBar_C:ResetBarValue()
  self.Img_Fill:SetClippingValue(0)
end

function WBP_ProgressBar_C:UpdateBarInfo(NewValue, OldValue)
  self.CurrentAttributeValue = NewValue
  local OldFillPercent = self.CurFillPercent
  self:SetBarInfo()
  local TargetFillPercent = self.CurFillPercent
  if self.bIsStopMoveVirtualBar then
    self.OldValue = OldValue
  end
  if NewValue - OldValue < 0 then
    self:PlayReduceAnim(OldFillPercent, TargetFillPercent)
  end
  if self.IsShowVirtualWhite then
    self:UpdateVirtualWhiteValue(OldValue, NewValue)
  end
end

function WBP_ProgressBar_C:PlayReduceAnim(OldPercent, TargetPercent)
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ReduceFXWidget)
  if not Slot then
    return
  end
  local CachedGeometry = self:GetCachedGeometry()
  local Size = UE.USlateBlueprintLibrary.GetLocalSize(CachedGeometry)
  local Position = Slot:GetPosition()
  Position.X = Size.X * (1 - TargetPercent) * -1
  Slot:SetPosition(Position)
  self.ReduceFXWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.ReduceFXWidget:PlayReduceAnim(self.ReduceAnimName)
end

function WBP_ProgressBar_C:UpdateVirtualBarValue(DifferenceValue)
  if DifferenceValue < 0 then
    self.bIsStopMoveVirtualBar = false
    local AttributeValue = self:GetAttributeValue()
    self.Speed = math.abs(self.OldValue - AttributeValue) / 50
    if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
      self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        function()
          self:PlayChangeVirtualBarAnim()
        end
      }, 0.25, false)
    end
  else
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HealthTimer) then
      UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.HealthTimer)
    end
    self.bIsStopMoveVirtualBar = true
    local AttributeValue = self:GetAttributeValue()
    local MaxAttributeValue = self:GetMaxAttributeValue()
    if 0 == MaxAttributeValue then
      self.VirtualBar:SetClippingValue(0)
    else
      self.VirtualBar:SetClippingValue(AttributeValue / MaxAttributeValue)
    end
  end
end

function WBP_ProgressBar_C:UpdateVirtualWhiteValue(OldValue, NewValue)
  local DifferenceValue = NewValue - OldValue
  if DifferenceValue < 0 then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
      self.VirtualWhiteTargetValue = NewValue
      return
    end
    self.VirtualWhiteOldValue = OldValue
    self.VirtualWhiteTargetValue = NewValue
    self.Img_VirtualWhite:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.VirtualWhiteTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:StartPlayVirtualWhiteAnim()
      end
    }, self.VirtualWhiteDuration, false)
  else
    self:EndVirtualWhiteAnim()
  end
end

function WBP_ProgressBar_C:StartPlayVirtualWhiteAnim()
  self.VirtualWhiteAnimTime = 0
  self.IsPlayVirtualWhiteAnim = true
end

function WBP_ProgressBar_C:EndVirtualWhiteAnim()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.VirtualWhiteTimer)
  end
  self.IsPlayVirtualWhiteAnim = false
  self.Img_VirtualWhite:SetVisibility(UE.ESlateVisibility.Collapsed)
  local AttributeValue = self:GetAttributeValue()
  local MaxAttributeValue = self:GetMaxAttributeValue()
  if 0 == MaxAttributeValue then
    self.Img_VirtualWhite:SetClippingValue(0)
  else
    self.Img_VirtualWhite:SetClippingValue(AttributeValue / MaxAttributeValue)
  end
end

function WBP_ProgressBar_C:GetAttributeValue()
  if not self.OwningActor then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(self.OwningActor)
  if not ASC then
    return 0
  end
  local AttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, self.Attribute, nil)
  return AttributeValue
end

function WBP_ProgressBar_C:GetMaxAttributeValue()
  if not self.OwningActor then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(self.OwningActor)
  if not ASC then
    return 0
  end
  local MaxAttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, self.MaxAttribute, nil)
  return MaxAttributeValue
end

function WBP_ProgressBar_C:PlayChangeVirtualBarAnim()
  self.TimerHandle = nil
  self.HealthTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_ProgressBar_C.ChangeVirtualBarAnim
  }, 0.01, true)
  if self.ChangeVirtualBarAnim then
    self:ChangeVirtualBarAnim()
  end
end

function WBP_ProgressBar_C:ChangeVirtualBarAnim()
  if not self.GetAttributeValue then
    return
  end
  local AttributeValue = self:GetAttributeValue()
  local MaxAttributeValue = self:GetMaxAttributeValue()
  local TargetValue = self.OldValue - self.Speed
  if AttributeValue < TargetValue then
    if 0 == MaxAttributeValue then
      self.VirtualBar:SetClippingValue(0)
    else
      self.VirtualBar:SetClippingValue(TargetValue / MaxAttributeValue)
    end
    self.OldValue = TargetValue
    self.bIsStopMoveVirtualBar = false
  else
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HealthTimer) then
      UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.HealthTimer)
    end
    self.bIsStopMoveVirtualBar = true
    if 0 == MaxAttributeValue then
      self.VirtualBar:SetClippingValue(0)
    else
      self.VirtualBar:SetClippingValue(AttributeValue / MaxAttributeValue)
    end
  end
end

function WBP_ProgressBar_C:UpdateBarStyle(Color)
  self.Img_Fill:SetColorAndOpacity(Color)
end

function WBP_ProgressBar_C:UpdateBarGrid(BarLength)
  self.GridBarList:ClearChildren()
  local SpawnNum = math.ceil(self:GetMaxAttributeValue() / self.SingleGridValue) - 1
  for i = 1, SpawnNum do
    local Item = self:CreateImage()
    local ItemSlot = self.GridBarList:AddChildToCanvas(Item)
    local Anchor = UE.FAnchors()
    Anchor.Minimum = UE.FVector2D(0.0, 0.0)
    Anchor.Maximum = UE.FVector2D(0.0, 1.0)
    ItemSlot:SetAnchors(Anchor)
    ItemSlot:SetPosition(UE.FVector2D(self.SingleGridValue * i / self:GetMaxAttributeValue() * BarLength, 0.0))
    ItemSlot:SetSize(UE.FVector2D(2.0, 0.0))
    Item:SetColorAndOpacity(UE.FLinearColor(0.234551, 0.234551, 0.234551, 1.0))
  end
end

function WBP_ProgressBar_C:Destruct()
  self:BindOrUnBindAttributeValueChangeDelegate(false)
  self.IsBound = false
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HealthTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HealthTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.VirtualWhiteTimer)
  end
  UnListenObjectMessage(GMP.MSG_World_OnAttributeModifyCacheAdded, self)
  UnListenObjectMessage(GMP.MSG_World_OnAttributeModifyCacheRemove, self)
  self.OnValueChangeFunc = nil
end

function WBP_ProgressBar_C:UpdateChargingBarInfo(NewValue, OldValue)
  if self.HasCharging then
    if 1 == self:GetAttributeValue() / self:GetMaxAttributeValue() then
      self.CanTickCharging = false
      self.ProgressBar_Charging:SetPercent(0)
      self.ProgressBar_Charging:SetVisibility(UE.ESlateVisibility.Hidden)
      self.Img_Bottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      local CoreComp = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
      if CoreComp then
        if 0 ~= CoreComp:GetShieldPercent() then
          self.ProgressBar_Charging:SetVisibility(UE.ESlateVisibility.Hidden)
          return
        end
        self.NewChargingPercent = CoreComp:GetChargingPercent()
        self.CanTickCharging = true
        self.ProgressBar_Charging:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        if self.NewChargingPercent - self.ProgressBar_Charging.Percent < -0.5 then
          self:ForceChargingPercent()
        end
        self.Img_Bottom:SetVisibility(UE.ESlateVisibility.Hidden)
      end
    end
  end
end

function WBP_ProgressBar_C:UpdateChargingBarVisibility()
  if 0 == self:GetMaxChargingValue() then
    self.ProgressBar_Charging:SetVisibility(UE.ESlateVisibility.Hidden)
    self.HasCharging = false
  else
    if not self.HasCharging then
      self.ProgressBar_Charging:SetPercent(0)
    end
    if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(self.Attribute, self.ShieldAttribute) then
      self.HasCharging = true
    end
  end
end

function WBP_ProgressBar_C:ForceChargingPercent()
  print("WBP_ProgressBar_C :ForceChargingPercent")
  if self.OwningActor then
    local CoreComp = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
    if CoreComp then
      self.NewChargingPercent = CoreComp:GetChargingPercent()
    end
  end
  self.VirtualBar:SetClippingValue(self:GetAttributeValue() / self:GetMaxAttributeValue())
  self.Img_VirtualWhite:SetClippingValue(0)
  self.ProgressBar_Charging:SetPercent(self.NewChargingPercent)
end

function WBP_ProgressBar_C:UpdateVirtualWhiteAnim(InDeltaTime)
  self.VirtualWhiteAnimTime = self.VirtualWhiteAnimTime + InDeltaTime
  local MinTime, MaxTime = self.VirtualWhiteAnimCurve:GetTimeRange()
  if MaxTime < self.VirtualWhiteAnimTime then
    self:EndVirtualWhiteAnim()
    return
  end
  local PercentValue = self.VirtualWhiteAnimCurve:GetFloatValue(self.VirtualWhiteAnimTime)
  local TargetOldVirtualWhiteValue = self.VirtualWhiteOldValue - PercentValue * (self.VirtualWhiteOldValue - self.VirtualWhiteTargetValue)
  local MaxAttributeValue = self:GetMaxAttributeValue()
  if 0 == MaxAttributeValue then
    self.Img_VirtualWhite:SetClippingValue(0)
  else
    self.Img_VirtualWhite:SetClippingValue(TargetOldVirtualWhiteValue / MaxAttributeValue)
  end
end

function WBP_ProgressBar_C:BindOnValueChange(OnValueChangeFunc)
  self.OnValueChangeFunc = OnValueChangeFunc
  if self.CurFillPercent then
    self.OnValueChangeFunc(self.CurFillPercent)
  end
end

function WBP_ProgressBar_C:UnBindOnValueChange()
  self.OnValueChangeFunc = nil
end

return WBP_ProgressBar_C
