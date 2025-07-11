local WBP_DamageNumber_C = UnLua.Class()
local DamageNumberConfig = require("GameConfig.DamageNumber.DamageNumberConfig")
function WBP_DamageNumber_C:Initialize(Initializer)
  self.TablePos = 0
  self.StartViewportPosOffset = UE.FVector2D()
end
local DamageTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(1.0, 0.957326, 0.0, 1.0),
  Purple = UE.FLinearColor(0.333033, 0.087961, 1.0, 1.0),
  Gold = UE.FLinearColor(1.0, 0.632107, 0.0, 1.0),
  Red = UE.FLinearColor(1.0, 0.0, 0.0, 1.0)
}
function WBP_DamageNumber_C:Construct()
  self.DefaultNormalSize = 14
  self.DefaultElementFontSize = 14
  if self.NormalFont then
    self.DefaultNormalSize = self.NormalFont.Size
  end
  if self.ElementEffectFont then
    self.DefaultElementFontSize = self.ElementEffectFont.Size
  end
  self.DefaultLuckyShotIconSize = UE.FVector2D()
  self.DefaultLuckyShotIconSize.X = self.Img_LuckyShot.Brush.ImageSize.X
  self.DefaultLuckyShotIconSize.Y = self.Img_LuckyShot.Brush.ImageSize.Y
end
function WBP_DamageNumber_C:Show(TargetActor, Params, HitReactionTag, HealthChangedValue)
  self.HitActor = TargetActor
  self.Params = Params
  self.HitReactionTag = HitReactionTag
  self.HealthChangedValue = HealthChangedValue
  self.CurOffsetTime = 0
  self.TargetDamageConfig = self:GetDamageConfig()
  self.StartViewportPosOffset = UE.FVector2D(0.0, 0.0)
  self.HitLocation = self:GetHitLocation()
  self.Retainer:SetRenderTranslation(UE.FVector2D(0.0, 0.0))
  self:StartShowAnim()
  self:InitInfo()
  self:SetVisibility(UE.ESlateVisibility.Visible)
end
function WBP_DamageNumber_C:GetDamageConfig()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  local DamageNumberStyleTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(LogicGameSetting.GetDamageNumberStyleTagName())
  local StyleValue = RGGameUserSettings:GetGameSettingByTag(DamageNumberStyleTag)
  local Result, RowInfo = false
  local ConfigRowName = ""
  if self.HitReactionTag then
  elseif self.HealthChangedValue then
    ConfigRowName = "HealthChanged"
  elseif UE.URGDamageStatics.IsDot(self.Params) then
    ConfigRowName = "Dot"
  elseif UE.URGDamageStatics.IsWeakHit(self.Params) then
    if 0 == StyleValue then
      ConfigRowName = "WeakHitFixed"
    else
      ConfigRowName = "WeakHit"
    end
  else
    local HitPartIndex = UE.URGDamageStatics.GetPartIndex(self.Params)
    if HitPartIndex > 0 then
      ConfigRowName = "PartHit"
    end
  end
  if UE.UKismetStringLibrary.IsEmpty(ConfigRowName) then
    if 0 == StyleValue then
      ConfigRowName = "NormalFixed"
    else
      ConfigRowName = "Normal"
    end
  end
  Result, RowInfo = GetRowData(DT.DT_NumberStyleConfig, ConfigRowName)
  if not Result then
    print("WBP_DamageNumber_C:GetDamageConfig not found DT_NumberStyleConfig RowInfo, RowName:", ConfigRowName)
    Result, RowInfo = GetRowData(DT.DT_NumberStyleConfig, self.DefaultConfigRowName)
  end
  return RowInfo.Config
end
function WBP_DamageNumber_C:GetRandomStartTranslation()
  local DamageConfig = self:GetDamageConfig()
  local Length = UE.UKismetMathLibrary.RandomFloatInRange(DamageConfig.InnerCircleRadius, DamageConfig.OutCircleRadius)
  local XFactor = self.OffsetAngle < 0 and -1.0 or 1.0
  local YFactor = UE.UKismetMathLibrary.InRange_FloatFloat(self.OffsetAngle, -90.0, 90.0, true, true) and -1.0 or 1.0
  local Translation = UE.FVector2D()
  Translation.X = UE.UKismetMathLibrary.Abs(UE.UKismetMathLibrary.DegSin(self.OffsetAngle) * Length) * XFactor
  Translation.Y = UE.UKismetMathLibrary.Abs(UE.UKismetMathLibrary.DegCos(self.OffsetAngle) * Length) * YFactor
  return Translation
end
function WBP_DamageNumber_C:GetTranslationByAngle(Length)
  local XFactor = self.OffsetAngle < 0 and -1.0 or 1.0
  local YFactor = UE.UKismetMathLibrary.InRange_FloatFloat(self.OffsetAngle, -90.0, 90.0, true, true) and -1.0 or 1.0
  local Translation = UE.FVector2D()
  Translation.X = UE.UKismetMathLibrary.Abs(UE.UKismetMathLibrary.DegSin(self.OffsetAngle) * Length) * XFactor
  Translation.Y = UE.UKismetMathLibrary.Abs(UE.UKismetMathLibrary.DegCos(self.OffsetAngle) * Length) * YFactor
  return Translation
end
function WBP_DamageNumber_C:GetRandomAngle()
  local RandomFactor = UE.UKismetMathLibrary.RandomFloat()
  local DamageConfig = self:GetDamageConfig()
  local MinAngle, MaxAngle = 0, 0
  if UE.UKismetMathLibrary.InRange_FloatFloat(RandomFactor, 0.0, DamageConfig.LeftWeight, true, true) then
    MinAngle = DamageConfig.DownLeft
    MaxAngle = DamageConfig.UpLeft
  elseif UE.UKismetMathLibrary.InRange_FloatFloat(RandomFactor, DamageConfig.LeftWeight, DamageConfig.LeftWeight + DamageConfig.RightWeight, false, true) then
    MinAngle = DamageConfig.UpRight
    MaxAngle = DamageConfig.DownRight
  else
    local MinValue = DamageConfig.LeftWeight + DamageConfig.RightWeight
    if UE.UKismetMathLibrary.InRange_FloatFloat(RandomFactor, MinValue, MinValue + DamageConfig.UpWeight, false, true) then
      MinAngle = DamageConfig.UpLeft
      MaxAngle = DamageConfig.UpRight
    else
      MinAngle = DamageConfig.DownRight - 360
      MaxAngle = DamageConfig.DownLeft
      local TargetAngle = UE.UKismetMathLibrary.RandomFloatInRange(MinAngle, MaxAngle)
      if TargetAngle < -180.0 then
        return TargetAngle + 360.0
      else
        return TargetAngle
      end
    end
  end
  local TargetAngle = UE.UKismetMathLibrary.RandomFloatInRange(MinAngle, MaxAngle)
  return TargetAngle
end
function WBP_DamageNumber_C:Hide()
  self.HitActor = nil
  self.Params = nil
  self.HitReactionTag = nil
  self.HealthChangedValue = nil
  self.CurOffsetTime = 0
  if table.Contain(LogicDamageNumber.LatestWidgets, self) then
    self:ShowOrHideLatestMark(false)
    table.RemoveItem(LogicDamageNumber.LatestWidgets, self)
  end
  self.TargetDamageConfig = nil
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Retainer:SetRenderTranslation(UE.FVector2D(0.0, 0.0))
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TranslationTimer) then
    UE.UKismetSystemLibrary.K2_PauseTimerHandle(self, self.TranslationTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CloseTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CloseTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.FadeOutTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.FadeOutTimer)
  end
  local Quality = BattleUIScalability:GetDamageNumberScalability()
  if Quality == UIQuality.HIGH then
    self:StopAllAnimations()
  end
end
function WBP_DamageNumber_C:InitInfo()
  self:SetDamageText()
  local Quality = BattleUIScalability:GetDamageNumberScalability()
  if Quality > UIQuality.LOW then
    self:UpdateLuckyShotImageVis()
    self:UpdateTextColorAndSize()
  end
  self:UpdateTextOffsetAngle()
  self:UpdateTextAlignment()
  self:UpdatePosInViewport()
  self:UpdateTranslation()
  local OffsetCurve = self:GetDamageOffsetCurve()
  local MinTime, MaxTime = OffsetCurve:GetTimeRange()
  self.CloseTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_DamageNumber_C.CloseWidget
  }, (MaxTime - MinTime) / 100, false)
  self.FadeOutTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:StartFadeOutAnim()
    end
  }, self:GetFadeOutTime(), false)
end
function WBP_DamageNumber_C:GetFadeOutTime()
  return self.TargetDamageConfig.FadeOutTime
end
function WBP_DamageNumber_C:GetDamageOffsetCurve()
  return self.TargetDamageConfig.OffsetCurve
end
function WBP_DamageNumber_C:UpdateTextOffsetAngle()
  if self.TargetDamageConfig.IsFixedMove then
    self.OffsetAngle = self.TargetDamageConfig.MoveAngle
  else
    self.OffsetAngle = self:GetRandomAngle()
    self.StartViewportPosOffset = self:GetRandomStartTranslation()
  end
end
function WBP_DamageNumber_C:UpdateTextAlignment()
  local Alignment = UE.FVector2D()
  if self.OffsetAngle > -90 and self.OffsetAngle < 0 then
    Alignment = UE.FVector2D(1.0, 1.0)
  end
  if 0 == self.OffsetAngle then
    Alignment = UE.FVector2D(0.5, 1.0)
  end
  if self.OffsetAngle > 0 and self.OffsetAngle < 90 then
    Alignment = UE.FVector2D(0, 1.0)
  end
  if 90 == self.OffsetAngle then
    Alignment = UE.FVector2D(0, 0.5)
  end
  if self.OffsetAngle > 90 and self.OffsetAngle < 180 then
    Alignment = UE.FVector2D(0.0, 0.0)
  end
  if self.OffsetAngle == 180 then
    Alignment = UE.FVector2D(0.5, 0.0)
  end
  if self.OffsetAngle > -180 and self.OffsetAngle < -90 then
    Alignment = UE.FVector2D(1.0, 0.0)
  end
  if -90 == self.OffsetAngle then
    Alignment = UE.FVector2D(1.0, 0.5)
  end
  self:SetAlignmentInViewport(Alignment)
end
function WBP_DamageNumber_C:GetDamageText()
  if self.HitReactionTag then
    local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(self.HitReactionTag)
    local Result, RowInfo = GetRowData(DT.DT_NumberStyleByHitReaction, TagName)
    self.IsUseChineseFont = true
    return RowInfo.DisplayText
  elseif self.HealthChangedValue then
    self.IsUseChineseFont = false
    return "+" .. UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", self.HealthChangedValue)))
  else
    local InvincibleText, IsInvincible = self:GetInvincibleText()
    local DamageValue = UE.URGDamageStatics.GetDamageValue(self.Params)
    if IsInvincible then
      self.IsUseChineseFont = true
      return InvincibleText
    else
      local DamageValueStr = ""
      local LocalizationModule = ModuleManager:Get("LocalizationModule")
      if LocalizationModule and LocalizationModule:CheckIsCN() then
        DamageValueStr = self:TranslateDamageTxtCN(DamageValue)
      else
        DamageValueStr = self:TranslateDamageTxtIntl(DamageValue)
      end
      self.IsUseChineseFont = false
      return DamageValueStr
    end
  end
end
function WBP_DamageNumber_C:TranslateDamageTxtCN(DamageValue)
  for i, v in ipairs(DamageNumberConfig.CN) do
    if v.MaxNumber and DamageValue < v.MaxNumber or not v.MaxNumber then
      local DamageValueTemp = DamageValue / v.DivideNumber
      if 1 == v.DivideNumber then
        DamageValueTemp = math.ceil(DamageValueTemp)
      else
        local FirstDecimalPlace = math.floor(DamageValueTemp * 10) % 10
        if 0 == FirstDecimalPlace then
          DamageValueTemp = math.floor(DamageValueTemp)
        else
          DamageValueTemp = math.floor(DamageValueTemp * 10) / 10
        end
      end
      return tostring(DamageValueTemp) .. v.Unit
    end
  end
  return tostring(math.ceil(DamageValue))
end
function WBP_DamageNumber_C:TranslateDamageTxtIntl(DamageValue)
  for i, v in ipairs(DamageNumberConfig.INTL) do
    if v.MaxNumber and DamageValue < v.MaxNumber or not v.MaxNumber then
      local DamageValueTemp = DamageValue / v.DivideNumber
      if 1 == v.DivideNumber then
        DamageValueTemp = math.ceil(DamageValueTemp)
      else
        local FirstDecimalPlace = math.floor(DamageValueTemp * 10) % 10
        if 0 == FirstDecimalPlace then
          DamageValueTemp = math.floor(DamageValueTemp)
        else
          DamageValueTemp = math.floor(DamageValueTemp * 10) / 10
        end
      end
      return tostring(DamageValueTemp) .. v.Unit
    end
  end
  return tostring(math.ceil(DamageValue))
end
function WBP_DamageNumber_C:SetDamageText()
  local DamageText = self:GetDamageText()
  self.Txt_Damage:SetText(DamageText)
end
function WBP_DamageNumber_C:UpdateLuckyShotImageVis()
  if self.HitReactionTag or self.HealthChangedValue then
    self.Img_LuckyShot:SetVisibility(UE.ESlateVisibility.Collapsed)
  elseif UE.URGDamageStatics.IsLuckyShot(self.Params) then
    self.Img_LuckyShot:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_LuckyShot:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_DamageNumber_C:GetInvincibleText()
  if UE.URGDamageStatics.IsInvincible(self.Params) then
    return self.InvincibleText, true
  end
  return "", false
end
function WBP_DamageNumber_C:GetDefaultFontSize()
  return self.DefaultNormalSize
end
function WBP_DamageNumber_C:GetTextColor()
  if self.HitReactionTag then
    local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(self.HitReactionTag)
    local Result, RowInfo = GetRowData(DT.DT_NumberStyleByHitReaction, TagName)
    return RowInfo.TextInitColor, RowInfo.TextFinalColor, RowInfo.IconColor
  elseif self.HealthChangedValue then
    return self.TargetDamageConfig.TextColor, self.TargetDamageConfig.TextColor, self.TargetDamageConfig.TextColor
  else
    local AllRowNames = GetAllRowNames(DT.DT_NumberStyleByDamageCategory)
    for index, SingleRowName in ipairs(AllRowNames) do
      if UE.URGDamageStatics.HasCategory(self.Params, SingleRowName) then
        local Result, RowInfo = GetRowData(DT.DT_NumberStyleByDamageCategory, SingleRowName)
        if Result then
          return RowInfo.TextInitColor, RowInfo.TextFinalColor, RowInfo.IconColor
        end
      end
    end
    return self.TargetDamageConfig.TextColor, self.TargetDamageConfig.TextColor, self.TargetDamageConfig.TextColor
  end
end
function WBP_DamageNumber_C:UpdateTextColorAndSize()
  local TextInitColor, TextFinalColor, IconColor = self:GetTextColor()
  self.Txt_Damage:SetGradientColor(TextInitColor, TextFinalColor)
  self.Img_LuckyShot:SetColorAndOpacity(IconColor)
  self.IsBigDamage = LogicDamageNumber.IsBigDamage(self.Params)
  self:UpdateTextFont(false)
end
function WBP_DamageNumber_C:UpdateTextFont(IsLastestDamage)
  local Font = self.NormalFont
  if self.IsUseChineseFont then
    Font = self.ChineseFont
  end
  local FontScale = self.TargetDamageConfig.FontScale
  if not FontScale then
    FontScale = 1.0
    print("TargetDamageConfig.FontScale is nil")
  end
  local FinalFontScale = FontScale
  local FontSize = 0
  if self.HitReactionTag or self.HealthChangedValue then
  else
    if UE.URGDamageStatics.IsLuckyShot(self.Params) then
      FinalFontScale = FinalFontScale + self.LuckyShotFontScale
    elseif IsLastestDamage then
      FinalFontScale = FinalFontScale + self.LatestFontScale
    end
    for DamageCategoryName, Scale in pairs(self.GamblersGodFontScaleConfig) do
      if UE.URGDamageStatics.HasCategory(self.Params, DamageCategoryName) then
        FinalFontScale = FinalFontScale + Scale
        break
      end
    end
    if not UE.URGDamageStatics.IsDot(self.Params) and self.IsBigDamage then
      FinalFontScale = FinalFontScale + self.BigDamageFontScale
    end
    if UE.URGDamageStatics.IsLuckyShot(self.Params) then
      local ImageSize = UE.FVector2D()
      ImageSize.X = self.DefaultLuckyShotIconSize.X * FinalFontScale
      ImageSize.Y = self.DefaultLuckyShotIconSize.Y * FinalFontScale
      self.Img_LuckyShot:SetBrushSize(ImageSize)
    end
  end
  FontSize = math.floor(self:GetDefaultFontSize() * FinalFontScale)
  Font.Size = FontSize
  local CurFont = self.Txt_Damage.Font
  Font.FontMaterial = CurFont.FontMaterial
  self.Txt_Damage:SetFont(Font)
end
function WBP_DamageNumber_C:GetHitLocation()
  local Pos = UE.FVector()
  if self.HitReactionTag or self.HealthChangedValue then
    local MeshComp = self.HitActor and self.HitActor:GetComponentByClass(UE.UMeshComponent:StaticClass())
    if MeshComp then
      local SocketLocation = MeshComp:GetSocketLocation(self.NoHitLocationBoneName)
      Pos.X = SocketLocation.X
      Pos.Y = SocketLocation.Y
      Pos.Z = SocketLocation.Z
    end
  elseif UE.UKismetMathLibrary.EqualEqual_VectorVector(UE.URGDamageStatics.GetLocation(self.Params), UE.FVector(0.0, 0.0, 0.0)) then
    local SocketName = ""
    if UE.URGDamageStatics.IsDot(self.Params) and self.TargetDamageConfig.IsFixedLocation then
      SocketName = self.TargetDamageConfig.BoneName
    else
      SocketName = self.NoHitLocationBoneName
    end
    local MeshComp = self.HitActor and self.HitActor:GetComponentByClass(UE.UMeshComponent:StaticClass())
    if MeshComp then
      local SocketLocation = MeshComp:GetSocketLocation(SocketName)
      Pos.X = SocketLocation.X
      Pos.Y = SocketLocation.Y
      Pos.Z = SocketLocation.Z
    end
  elseif self.TargetDamageConfig.IsFixedLocation and self.HitActor then
    local MeshComp = self.HitActor:GetComponentByClass(UE.UMeshComponent:StaticClass())
    if MeshComp then
      local SocketLocation = MeshComp:GetSocketLocation(self.TargetDamageConfig.BoneName)
      Pos.X = SocketLocation.X
      Pos.Y = SocketLocation.Y
      Pos.Z = SocketLocation.Z
    else
      print("WBP_DamageNumber_C not found MeshComp")
      Pos = UE.URGDamageStatics.GetLocation(self.Params)
    end
  else
    Pos = UE.URGDamageStatics.GetLocation(self.Params)
  end
  return Pos
end
function WBP_DamageNumber_C:UpdatePosInViewport()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local bResult, ViewportPos = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PC, self.HitLocation, nil, false)
  local FinalViewportPos = ViewportPos + self.StartViewportPosOffset
  self:SetPositionInViewport(FinalViewportPos, false)
end
function WBP_DamageNumber_C:ShowOrHideLatestMark(IsShow)
  self:UpdateTextFont(IsShow)
end
function WBP_DamageNumber_C:CloseWidget()
  if self.ListContainer then
    self.ListContainer:HideItem(self)
  end
end
function WBP_DamageNumber_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TranslationTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TranslationTimer)
  end
end
function WBP_DamageNumber_C:StartShowAnim()
  local Quality = BattleUIScalability:GetDamageNumberScalability()
  if Quality < UIQuality.HIGH then
    return
  end
  self:StopAllAnimations()
  if self.Params and UE.URGDamageStatics.GetLuckyShotValue(self.Params) > 0 then
    self:PlayAnimationForward(self.CritFadeInAnim)
  else
    self:PlayAnimationForward(self.FadeInAnim)
  end
end
function WBP_DamageNumber_C:StartFadeOutAnim()
  local Quality = BattleUIScalability:GetDamageNumberScalability()
  if Quality < UIQuality.HIGH then
    return
  end
  self:StopAllAnimations()
  if self.Params and UE.URGDamageStatics.GetLuckyShotValue(self.Params) then
    self:PlayAnimationForward(self.CritFadeOutAnim)
  else
    self:PlayAnimationForward(self.FadeOutAnim)
  end
end
return WBP_DamageNumber_C
