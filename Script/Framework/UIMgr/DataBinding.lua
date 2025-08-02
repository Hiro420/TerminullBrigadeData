local ESlateVisibility = UE.ESlateVisibility
local EUMGSequencePlayMode = UE.EUMGSequencePlayMode
local UWidgetLayoutLibrary = UE.UWidgetLayoutLibrary
local URGBlueprintLibrary = UE.URGBlueprintLibrary
local UnLua = _G.UnLua
local DataBinding = {}

function DataBinding.ConvertInverseBool(source, param)
  if false == source then
    return true
  end
  return false
end

function DataBinding.UpdateText(target, convertedValue, sourceValue)
  if nil ~= target then
    target:SetText(convertedValue)
  else
    UnLua.LogWarn("DataBinding.UpdateText - target is nil , UpdateText value is : ", convertedValue)
  end
end

function DataBinding.UpdateTextColor(target, convertedValue, sourceValue)
  target:SetColorAndOpacity(convertedValue)
end

function DataBinding.UpdateImageColorByStr(target, convertedValue, sourceValue)
  URGBlueprintLibrary.SetImageColor(target, convertedValue)
end

function DataBinding.UpdateLineHeightPercentage(target, convertedValue, sourceValue)
  if nil ~= target and nil ~= target.SetLineHeightPercentage then
    target:SetLineHeightPercentage(convertedValue)
  end
end

function DataBinding.UpdateOpacity(target, convertedValue, sourceValue)
  target:SetRenderOpacity(convertedValue)
end

function DataBinding.UpdateCheckStatus(target, convertedValue, sourceValue)
  target:SetCheckedState(convertedValue)
end

function DataBinding.UpdateEnable(target, convertedValue, sourceValue)
  target:SetIsEnabled(convertedValue)
end

function DataBinding.UpdateIsChecked(target, convertedValue, sourceValue)
  target:SetIsChecked(convertedValue)
end

function DataBinding.UpdateVisiblity(target, convertedValue, sourceValue)
  if nil == target then
    UnLua.LogWarn("target is nil , UpdateVisiblity ")
    return
  end
  if true == convertedValue then
    target:SetVisibility(ESlateVisibility.Visible)
  else
    target:SetVisibility(ESlateVisibility.Hidden)
  end
end

function DataBinding.UpdateSelfNotHitVisiblity(target, convertedValue, sourceValue)
  if true == convertedValue then
    target:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    target:SetVisibility(ESlateVisibility.Hidden)
  end
end

function DataBinding.UpdateNotHitVisiblity(target, convertedValue, sourceValue)
  if true == convertedValue then
    target:SetVisibility(ESlateVisibility.HitTestInvisible)
  else
    target:SetVisibility(ESlateVisibility.Hidden)
  end
end

function DataBinding.UpdateCollapsedOrSelfNotHit(target, convertedValue, sourceValue)
  if true == convertedValue then
    target:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    target:SetVisibility(ESlateVisibility.Collapsed)
  end
end

function DataBinding.UpdateCollapsedVisiblity(target, convertedValue, sourceValue)
  if true == convertedValue then
    target:SetVisibility(ESlateVisibility.Visible)
  else
    target:SetVisibility(ESlateVisibility.Collapsed)
  end
end

function DataBinding.UpdateCollapsedOrNotHit(target, convertedValue, sourceValue)
  if true == convertedValue then
    target:SetVisibility(ESlateVisibility.HitTestInvisible)
  else
    target:SetVisibility(ESlateVisibility.Collapsed)
  end
end

function DataBinding.UpdateEnumVisibility(target, convertedValue, sourceValue)
  URGBlueprintLibrary.SetUIVisibility(target, convertedValue)
end

function DataBinding.UpdateImageSync(target, convertedValue, sourceValue)
  if sourceValue and string.len(convertedValue) > 0 then
    URGBlueprintLibrary.SetImageBrushFromAssetPathSync(target, convertedValue, false)
  end
end

function DataBinding.UpdateImageAsync(target, convertedValue, sourceValue)
  if sourceValue and string.len(convertedValue) > 0 then
    URGBlueprintLibrary.SetImageBrushFromAssetPath(target, convertedValue, false)
  end
end

function DataBinding.UpdateImageBrush(target, convertedValue, sourceValue)
  if nil ~= target and nil ~= sourceValue and "" ~= sourceValue then
    local bAsync, bMatchSize = table.unpack(convertedValue)
    if true == bAsync then
      URGBlueprintLibrary.SetImageBrushFromAssetPath(target, sourceValue, bMatchSize)
    else
      URGBlueprintLibrary.SetImageBrushFromAssetPathSync(target, sourceValue, bMatchSize)
    end
  end
end

function DataBinding.UpdateImageTexture(target, convertedValue, sourceValue)
  if convertedValue and type(convertedValue) == "userdata" then
    target:SetBrushFromTexture(convertedValue, true)
  end
end

function DataBinding.UpdateImageAutoSizeSync(target, convertedValue, sourceValue)
  URGBlueprintLibrary.SetImageBrushFromAssetPathSync(target, convertedValue, true)
end

function DataBinding.UpdateImageAutoSizeAsync(target, convertedValue, sourceValue)
  URGBlueprintLibrary.SetImageBrushFromAssetPath(target, convertedValue, true)
end

function DataBinding.UpdateBrushTintColor(target, convertedValue, sourceValue)
  target:SetBrushTintColor(convertedValue)
end

function DataBinding.UpdateImageColor(target, convertedValue, sourceValue)
  if nil ~= target then
    target:SetColorAndOpacity(convertedValue)
  end
end

function DataBinding.UpdateImageMaterial(target, convertedValue, sourceValue)
  if not convertedValue or "" == convertedValue then
    return
  end
  URGBlueprintLibrary.SetImageBrushFromAssetPath(target, convertedValue, false)
end

function DataBinding.UpdateProgressBarImage(target, convertedValue, sourceValue)
  if string.len(convertedValue) > 0 then
    URGBlueprintLibrary.SetBrushFromAssetPath(target.WidgetStyle.FillImage, convertedValue)
  end
end

function DataBinding.UpdateProgressBarBackgroundImage(target, convertedValue, sourceValue)
  if string.len(convertedValue) > 0 then
    URGBlueprintLibrary.SetBrushFromAssetPath(target.WidgetStyle.BackgroundImage, convertedValue)
  end
end

function DataBinding.UpdateButtonAllStateImageAsync(target, convertedValue, sourceValue)
  if string.len(convertedValue) > 0 then
    URGBlueprintLibrary.SetBrushFromAssetPath(target.WidgetStyle.Normal, convertedValue)
    URGBlueprintLibrary.SetBrushFromAssetPath(target.WidgetStyle.Hovered, convertedValue)
    URGBlueprintLibrary.SetBrushFromAssetPath(target.WidgetStyle.Pressed, convertedValue)
  end
end

function DataBinding.UpdateButtonClickMethod(target, convertedValue, sourceValue)
  if nil ~= target then
    target:SetClickMethod(convertedValue)
  end
end

function DataBinding.UpdateButtonTouchMethod(target, convertedValue, sourceValue)
  if nil ~= target then
    target:SetTouchMethod(convertedValue)
  end
end

function DataBinding.UpdateButtonPressMethod(target, convertedValue, sourceValue)
  if nil ~= target then
    target:SetPressMethod(convertedValue)
  end
end

function DataBinding.UpdateWidth(target, convertedValue, sourceValue)
  local slotCanvas = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  local size = slotCanvas:GetSize()
  size.X = convertedValue
  slotCanvas:SetSize(size)
end

function DataBinding.UpdateAnchors(target, convertedValue, sourceValue)
  local canvasSlot = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if canvasSlot then
    local anchors = canvasSlot:GetAnchors()
    anchors.Minimum = convertedValue.Minimum
    anchors.Maximum = convertedValue.Maximum
    canvasSlot:SetAnchors(anchors)
  end
end

function DataBinding.UpdateSize(target, convertedValue, sourceValue)
  local slotCanvas = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if slotCanvas then
    slotCanvas:SetSize(convertedValue)
  end
end

function DataBinding.UpdatePosition(target, convertedValue, sourceValue)
  local canvasSlot = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if canvasSlot then
    URGBlueprintLibrary.SetUICanvasPosition(canvasSlot, convertedValue)
  end
end

function DataBinding.UpdateCanvasPanelSlotPositionX(target, convertedValue, sourceValue)
  local canvasPanelSlot = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if nil ~= canvasPanelSlot then
    local position = canvasPanelSlot:GetPosition()
    position.X = convertedValue
    URGBlueprintLibrary.SetUICanvasPosition(canvasPanelSlot, position)
  end
end

function DataBinding.UpdateAlignment(target, convertedValue, sourceValue)
  local canvasSlot = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if canvasSlot then
    canvasSlot:SetAlignment(convertedValue)
  end
end

function DataBinding.UpdateAutoSize(target, convertedValue, sourceValue)
  local canvasSlot = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if canvasSlot then
    canvasSlot:SetAutoSize(convertedValue)
  end
end

function DataBinding.UpdateOffsets(target, convertedValue, sourceValue)
  local canvasSlot = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if canvasSlot then
    local left = convertedValue.Left or 0
    local top = convertedValue.Top or 0
    local right = convertedValue.Right or 0
    local bottom = convertedValue.Bottom or 0
    local offsets = canvasSlot:GetOffsets()
    offsets.Left = left
    offsets.Top = top
    offsets.Right = right
    offsets.Bottom = bottom
    canvasSlot:SetOffsets(offsets)
  end
end

function DataBinding.UpdateHorizontalBoxSlotPadding(target, convertedValue, sourceValue)
  local horizontalBoxSlot = UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(target)
  if nil ~= horizontalBoxSlot then
    local left = convertedValue.Left or 0
    local top = convertedValue.Top or 0
    local right = convertedValue.Right or 0
    local bottom = convertedValue.Bottom or 0
    local padding = horizontalBoxSlot.Padding
    padding.Left = left
    padding.Top = top
    padding.Right = right
    padding.Bottom = bottom
    horizontalBoxSlot:SetPadding(padding)
  end
end

function DataBinding.UpdateHorizontalBoxSlotSize(target, convertedValue, sourceValue)
  local horizontalBoxSlot = UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(target)
  if nil ~= horizontalBoxSlot then
    local size = horizontalBoxSlot.Size
    size.Value = convertedValue
    horizontalBoxSlot:SetSize(size)
  end
end

function DataBinding.UpdateWidgetSwitcherActiveIndex(target, convertedValue, sourceValue)
  target:SetActiveWidgetIndex(convertedValue)
end

function DataBinding.UpdateProgressBarPercent(target, convertedValue, sourceValue)
  target:SetPercent(convertedValue)
end

function DataBinding.UpdateProgressBarColor(target, convertedValue, sourceValue)
  if target then
    target:SetFillColorAndOpacity(convertedValue)
  end
end

function DataBinding.UpdateSliderValue(target, convertedValue, sourceValue)
  target:SetValue(convertedValue)
end

function DataBinding.UpdateWidgetRotation(target, convertedValue, sourceValue)
end

function DataBinding.UpdateInvalidateCache(target, convertedValue, sourceValue)
  if target and convertedValue then
    target:InvalidateCache()
  end
end

function DataBinding.UpdateTranslation(target, convertedValue, source)
  if target then
    target:SetRenderTranslation(convertedValue)
  end
end

function DataBinding.UpdateScale(target, convertedValue, sourceValue)
  if target then
    target:SetRenderScale(convertedValue)
  end
end

function DataBinding.UpdateAngle(target, convertedValue, sourceValue)
  if nil ~= target then
    target:SetRenderAngle(convertedValue)
  end
end

function DataBinding.UpdateAlpha(target, convertedValue, sourceValue)
  if target then
    local color = target.ColorAndOpacity
    color.A = convertedValue
    target:SetColorAndOpacity(color)
  end
end

function DataBinding.UpdateZOrder(target, convertedValue, sourceValue)
  if target then
    local canvasSlot = UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
    if canvasSlot then
      canvasSlot:SetZOrder(convertedValue)
    end
  end
end

function DataBinding.UpdateSubViewModel(target, convertedValue, sourceValue)
  if target then
    target:ResetViewModel(convertedValue)
  end
end

DataBinding.PolicyBoolToVisiblity = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateVisiblity,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToVisiblityInverse = {
  Converter = DataBinding.ConvertInverseBool,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateVisiblity,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToSelfNotHitVisiblity = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateSelfNotHitVisiblity,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToSelfNotHitVisiblityInverse = {
  Converter = DataBinding.ConvertInverseBool,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateSelfNotHitVisiblity,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToNotHitVisiblity = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateNotHitVisiblity,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToNotHitVisiblityInverse = {
  Converter = DataBinding.ConvertInverseBool,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateNotHitVisiblity,
  OnTargetChanged = nil
}
DataBinding.CollapsedOrNotHit = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCollapsedOrNotHit,
  OnTargetChanged = nil
}
DataBinding.CollapsedOrNotHitInverse = {
  Converter = DataBinding.ConvertInverseBool,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCollapsedOrNotHit,
  OnTargetChanged = nil
}
DataBinding.CollapsedOrSelfNotHit = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCollapsedOrSelfNotHit,
  OnTargetChanged = nil
}
DataBinding.CollapsedOrSelfNotHitInverse = {
  Converter = DataBinding.ConvertInverseBool,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCollapsedOrSelfNotHit,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToCollapsedVisiblity = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCollapsedVisiblity,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToCollapsedVisiblityInverse = {
  Converter = DataBinding.ConvertInverseBool,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCollapsedVisiblity,
  OnTargetChanged = nil
}
DataBinding.PolicyEnumToVisibility = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateEnumVisibility,
  OnTargetChanged = nil
}

function DataBinding.BoolToText()
  return DataBinding.PolicyBoolToText
end

function DataBinding.BoolToVisiblity(inverse, Collapsed)
  if true == inverse then
    if true == Collapsed then
      return DataBinding.PolicyBoolToCollapsedVisiblityInverse
    else
      return DataBinding.PolicyBoolToVisiblityInverse
    end
  elseif true == Collapsed then
    return DataBinding.PolicyBoolToCollapsedVisiblity
  else
    return DataBinding.PolicyBoolToVisiblity
  end
  return DataBinding.PolicyBoolToVisiblity
end

function DataBinding.BoolToNotHitVisiblity(inverse, collapsed)
  if true == inverse then
    if collapsed then
      return DataBinding.CollapsedOrNotHitInverse
    else
      return DataBinding.PolicyBoolToNotHitVisiblityInverse
    end
  elseif collapsed then
    return DataBinding.CollapsedOrNotHit
  else
    return DataBinding.PolicyBoolToNotHitVisiblity
  end
end

function DataBinding.BoolToSelfNotHiVisiblity(inverse, collapsed)
  if true == inverse then
    if collapsed then
      return DataBinding.CollapsedOrSelfNotHitInverse
    else
      return DataBinding.PolicyBoolToSelfNotHitVisiblityInverse
    end
  elseif collapsed then
    return DataBinding.CollapsedOrSelfNotHit
  else
    return DataBinding.PolicyBoolToSelfNotHitVisiblity
  end
end

function DataBinding:EnumToVisibility()
  return DataBinding.PolicyEnumToVisibility
end

function DataBinding.FormatNumToText(matchTable)
  return {
    Converter = DataBinding.ConvertFormatNumToString,
    ConverterParam = matchTable,
    OnSourceChanged = DataBinding.UpdateText,
    OnTargetChanged = nil
  }
end

function DataBinding.StringToImageAutoSize(async)
  if nil == async or true == async then
    return {
      Converter = nil,
      ConverterParam = nil,
      OnSourceChanged = DataBinding.UpdateImageAutoSizeAsync,
      OnTargetChanged = nil
    }
  else
    return {
      Converter = nil,
      ConverterParam = nil,
      OnSourceChanged = DataBinding.UpdateImageAutoSizeSync,
      OnTargetChanged = nil
    }
  end
end

DataBinding.PolicySetTextColor = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateTextColor,
  OnTargetChanged = nil
}
DataBinding.PolicySetImageColorByStr = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImageColorByStr,
  OnTargetChanged = nil
}
DataBinding.PolicySetLineHeightPercentage = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateLineHeightPercentage,
  OnTargetChanged = nil
}
DataBinding.PolicySetRenderOpacity = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateOpacity,
  OnTargetChanged = nil
}
DataBinding.PolicySetEnable = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateEnable,
  OnTargetChanged = nil
}
DataBinding.PolicySetDisable = {
  Converter = DataBinding.ConvertInverseBool,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateEnable,
  OnTargetChanged = nil
}
DataBinding.PolicySetCheckStatus = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCheckStatus,
  OnTargetChanged = nil
}
DataBinding.PolicySetIsChecked = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateIsChecked,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectText = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateText,
  OnTargetChanged = nil
}
DataBinding.PolicyBoolToText = {
  Converter = DataBinding.BoolToTextConverter,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateText,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectImageSync = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImageSync,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectImageAsync = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImageAsync,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectImageTexture = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImageTexture,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectImageColor = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImageColor,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectImageTintColor = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateBrushTintColor,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectImageMaterial = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImageMaterial,
  OnTargetChanged = nil
}
DataBinding.PolicyNumToText = {
  Converter = DataBinding.ConvertNumToString,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateText,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectAnchors = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateAnchors,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectSize = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateSize,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectWidth = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateWidth,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectPosition = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdatePosition,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectCanvasPanelSlotPositionX = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateCanvasPanelSlotPositionX,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectAlignment = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateAlignment,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectAutoSize = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateAutoSize,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectOffsets = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateOffsets,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectHorizontalBoxSlotPadding = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateHorizontalBoxSlotPadding,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectHorizontalBoxSlotSize = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateHorizontalBoxSlotSize,
  OnTargetChanged = nil
}
DataBinding.PolicyNumToImagePercent = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImagePercent,
  OnTargetChanged = nil
}
DataBinding.PolicyNumToWidgetSwitcherActiveIndex = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateWidgetSwitcherActiveIndex,
  OnTargetChanged = nil
}
DataBinding.PolicyNumToProgressBarPercent = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateProgressBarPercent,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectProgressBarColor = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateProgressBarColor,
  OnTargetChanged = nil
}
DataBinding.PolicyNumToSliderValue = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateSliderValue,
  OnTargetChanged = nil
}
DataBinding.PolicyProgressBarImagePath = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateProgressBarImage,
  OnTargetChanged = nil
}
DataBinding.PolicyProgressBarBackgroundImagePath = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateProgressBarBackgroundImage,
  OnTargetChanged = nil
}
DataBinding.PolicySetButtonAllStateImageSync = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateButtonAllStateImageSync,
  OnTargetChanged = nil
}
DataBinding.PolicyUpdateButtonClickMethod = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateButtonClickMethod,
  OnTargetChanged = nil
}
DataBinding.PolicyUpdateButtonTouchMethod = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateButtonTouchMethod,
  OnTargetChanged = nil
}
DataBinding.PolicyUpdateButtonPressMethod = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateButtonPressMethod,
  OnTargetChanged = nil
}
DataBinding.PolicySubViewBinding = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateSubViewModel,
  OnTargetChanged = nil
}
DataBinding.PolicyButtonEffectBinding = {
  Converter = DataBinding.ConvertButtonEffect,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateButtonEffect,
  OnTargetChanged = nil
}
DataBinding.PolicyWidgetRotation = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateWidgetRotation,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectTranslation = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateTranslation,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectScale = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateScale,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectAngle = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateAngle,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectAlpha = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateAlpha,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectZOrder = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateZOrder,
  OnTargetChanged = nil
}
DataBinding.PolicyRadarChartProgress = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateRadarChartProgress,
  OnTargetChanged = nil
}
DataBinding.PolicyDirectImageVertexColor = {
  Converter = nil,
  ConverterParam = nil,
  OnSourceChanged = DataBinding.UpdateImageVertexColor,
  OnTargetChanged = nil
}

function DataBinding.DirectText()
  return DataBinding.PolicyDirectText
end

function DataBinding.BoolToText(truTxt, flsTxt)
  DataBinding.PolicyBoolToText.ConverterParam = {truTxt, flsTxt}
  return DataBinding.PolicyBoolToText
end

function DataBinding.SetTextColor()
  return DataBinding.PolicySetTextColor
end

function DataBinding.SetImageStrColor()
  return DataBinding.PolicySetImageColorByStr
end

function DataBinding.SetLineHeightPercentage()
  return DataBinding.PolicySetLineHeightPercentage
end

function DataBinding.DirectImagePath(async)
  if nil == async or true == async then
    return DataBinding.PolicyDirectImageAsync
  else
    return DataBinding.PolicyDirectImageSync
  end
end

function DataBinding.DirectImageBrush(bAsync, bMatchSize)
  return {
    Converter = function(source, converterParam)
      return converterParam
    end,
    ConverterParam = {bAsync, bMatchSize},
    OnSourceChanged = DataBinding.UpdateImageBrush,
    OnTargetChanged = nil
  }
end

function DataBinding.DirectImageTexture()
  return DataBinding.PolicyDirectImageTexture
end

function DataBinding.DirectImageTintColor()
  return DataBinding.PolicyDirectImageTintColor
end

function DataBinding.DirectImageColor()
  return DataBinding.PolicyDirectImageColor
end

function DataBinding.NumToText()
  return DataBinding.PolicyNumToText
end

function DataBinding.DirectAnchors()
  return DataBinding.PolicyDirectAnchors
end

function DataBinding.DirectSize()
  return DataBinding.PolicyDirectSize
end

function DataBinding.AbsoluteToLocalSize()
  return DataBinding.PolicyAbsoluteToLocalSize
end

function DataBinding.DirectPosition()
  return DataBinding.PolicyDirectPosition
end

function DataBinding.DirectCanvasPanelSlotPositionX()
  return DataBinding.PolicyDirectCanvasPanelSlotPositionX
end

function DataBinding.DirectAlignment()
  return DataBinding.PolicyDirectAlignment
end

function DataBinding.DirectAutoSize()
  return DataBinding.PolicyDirectAutoSize
end

function DataBinding.DirectOffsets()
  return DataBinding.PolicyDirectOffsets
end

function DataBinding.DirectHorizontalBoxSlotPadding()
  return DataBinding.PolicyDirectHorizontalBoxSlotPadding
end

function DataBinding.DirectHorizontalBoxSlotSize()
  return DataBinding.PolicyDirectHorizontalBoxSlotSize
end

function DataBinding.NumToImagePercent()
  return DataBinding.PolicyNumToImagePercent
end

function DataBinding.NumToWidgetSwitcherActiveIndex()
  return DataBinding.PolicyNumToWidgetSwitcherActiveIndex
end

function DataBinding.NumToProgressBarPercent()
  return DataBinding.PolicyNumToProgressBarPercent
end

function DataBinding.DirectProgressBarColor()
  return DataBinding.PolicyDirectProgressBarColor
end

function DataBinding.NumToSliderValue()
  return DataBinding.PolicyNumToSliderValue
end

function DataBinding.ProgressBarImagePath()
  return DataBinding.PolicyProgressBarImagePath
end

function DataBinding.ProgressBarBackgroundImagePath()
  return DataBinding.PolicyProgressBarBackgroundImagePath
end

function DataBinding.DirectButtonClickMethod()
  return DataBinding.PolicyUpdateButtonClickMethod
end

function DataBinding.DirectButtonTouchMethod()
  return DataBinding.PolicyUpdateButtonTouchMethod
end

function DataBinding.DirectButtonPressMethod()
  return DataBinding.PolicyUpdateButtonPressMethod
end

function DataBinding.SubViewBinding()
  return DataBinding.PolicySubViewBinding
end

function DataBinding.SetRenderOpacity()
  return DataBinding.PolicySetRenderOpacity
end

function DataBinding.SetEnable()
  return DataBinding.PolicySetEnable
end

function DataBinding.SetDisable()
  return DataBinding.PolicySetDisable
end

function DataBinding.SetCheckStatus()
  return DataBinding.PolicySetCheckStatus
end

function DataBinding.SetIsChecked()
  return DataBinding.PolicySetIsChecked
end

function DataBinding.NumToWidth(valueMin, valueMax, widthMin, widthMax)
  return {
    Converter = DataBinding.ConvertNumRemap,
    ConverterParam = {
      valueMin,
      valueMax,
      widthMin,
      widthMax
    },
    OnSourceChanged = DataBinding.UpdateWidth,
    OnTargetChanged = nil
  }
end

function DataBinding.DirectWidth()
  return DataBinding.PolicyDirectWidth
end

function DataBinding.SetWidgetRotation()
  return DataBinding.PolicyWidgetRotation
end

function DataBinding.DirectTranslation()
  return DataBinding.PolicyDirectTranslation
end

function DataBinding.DirectScale()
  return DataBinding.PolicyDirectScale
end

function DataBinding.DirectAngle()
  return DataBinding.PolicyDirectAngle
end

function DataBinding.DirectAlpha()
  return DataBinding.PolicyDirectAlpha
end

function DataBinding.DirectZOrder()
  return DataBinding.PolicyDirectZOrder
end

function DataBinding.PlayAnimationHandler(target, convertedValue, sourceValue)
  local animName, loop, mode = table.unpack(convertedValue)
  if nil == target or nil == target[animName] then
    return
  end
  local anim = target[animName]
  if target:IsAnimationPlaying(anim) then
    target:StopAnimation(anim)
  end
  if true == loop then
    loop = 0
  else
    loop = 1
  end
  if sourceValue then
    target:PlayAnimation(anim, 0, loop, mode or EUMGSequencePlayMode.Forward, 1)
  end
end

function DataBinding.ConvertToAnimName(source, param)
  return param
end

function DataBinding.ActivePlayAnimation(animName, loop, mode)
  return {
    Converter = DataBinding.ConvertToAnimName,
    ConverterParam = {
      animName,
      loop,
      mode
    },
    OnSourceChanged = DataBinding.PlayAnimationHandler,
    OnTargetChanged = nil
  }
end

function DataBinding.ConvertSourceToAnimName(source, param)
  return {source, param}
end

function DataBinding.PlayAnimationWithSource(loop)
  return {
    Converter = DataBinding.ConvertSourceToAnimName,
    ConverterParam = loop,
    OnSourceChanged = DataBinding.PlayAnimationHandler,
    OnTargetChanged = nil
  }
end

return DataBinding
