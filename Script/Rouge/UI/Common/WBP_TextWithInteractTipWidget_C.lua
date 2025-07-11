local WBP_TextWithInteractTipWidget_C = UnLua.Class()
function WBP_TextWithInteractTipWidget_C:Construct()
  self.LeisureCustomKeyNameList:Add(self.CustomKeyNameTemplate)
  self.LeisureTextBlockWidgetList:Add(self.TextTemplate)
  self:SetTextStyle(self.TextTemplate)
end
function WBP_TextWithInteractTipWidget_C:InitStyle(InTextColorAndOpacity, InFont, InJustification, InMinDesiredWidth, InShadowColor, InShadowOffset, InStrikeBrush, InTransformPolicy)
  self.TextColorAndOpacity = InTextColorAndOpacity
  self.Font = InFont
  self.Justification = InJustification
  self.MinDesiredWidth = InMinDesiredWidth
  self.ShadowColor = InShadowColor
  self.ShadowOffset = InShadowOffset
  self.StrikeBrush = InStrikeBrush
  self.TransformPolicy = InTransformPolicy
end
function WBP_TextWithInteractTipWidget_C:RefreshInfo(SourceString, CustomKeyNameList)
  self.SourceString = SourceString
  self.CustomKeyNameList = CustomKeyNameList
  self.CustomKeyIndex = 1
  local AllItem = self.MainList:GetAllChildren()
  for key, SingleItem in pairs(AllItem) do
    if UE.UGameplayStatics.GetObjectClass(SingleItem) == UE.UGameplayStatics.GetObjectClass(self.CustomKeyNameTemplate) then
      self.LeisureCustomKeyNameList:Add(SingleItem)
    else
      self.LeisureTextBlockWidgetList:Add(SingleItem)
    end
    SingleItem:RemoveFromParent()
  end
  self:RefreshListWidgets(self.SourceString)
end
function WBP_TextWithInteractTipWidget_C:RefreshListWidgets(SourceString)
  local Result, LeftS, RightS = UE.UKismetStringLibrary.Split(SourceString, "{0}", nil, nil, UE.ESearchCase.IgnoreCase, UE.ESearchDir.FromStart)
  if not (Result and self.CustomKeyNameList) or not self.CustomKeyNameList:IsValidIndex(1) then
    local TargetTextWidget = self:GetTextWidget()
    TargetTextWidget:SetText(SourceString)
  else
    local TargetTextWidget = self:GetTextWidget()
    TargetTextWidget:SetText(LeftS)
    if self.CustomKeyNameList:IsValidIndex(self.CustomKeyIndex) then
      local TargetCustomKeyName = self.CustomKeyNameList:Get(self.CustomKeyIndex)
      local TargetCustomKeyNameWidget = self:GetCustomKeyNameWidget()
      TargetCustomKeyNameWidget:SetCustomKeyConfig(TargetCustomKeyName, nil)
      self.CustomKeyIndex = self.CustomKeyIndex + 1
    else
      print("RefreshListWidgets CustomKeyNameList Invalid Index", self.CustomKeyIndex)
    end
    if not UE.UKismetStringLibrary.IsEmpty(RightS) then
      self:RefreshListWidgets(RightS)
    end
  end
end
function WBP_TextWithInteractTipWidget_C:GetTextWidget()
  local TargetTextWidget
  if self.LeisureTextBlockWidgetList:IsValidIndex(1) then
    TargetTextWidget = self.LeisureTextBlockWidgetList:Get(1)
    self.LeisureTextBlockWidgetList:RemoveItem(TargetTextWidget)
  else
    TargetTextWidget = self:ConstructTextBlockWidget()
  end
  self:SetTextStyle(TargetTextWidget)
  local Slot = self.MainList:AddChild(TargetTextWidget)
  Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
  Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Center)
  return TargetTextWidget
end
function WBP_TextWithInteractTipWidget_C:SetTextStyle(InTextBlock)
  InTextBlock:SetColorAndOpacity(self.TextColorAndOpacity)
  InTextBlock:SetFont(self.Font)
  InTextBlock:SetJustification(self.Justification)
  InTextBlock:SetMinDesiredWidth(self.MinDesiredWidth)
  InTextBlock:SetShadowColorAndOpacity(self.ShadowColor)
  InTextBlock:SetShadowOffset(self.ShadowOffset)
  InTextBlock:SetStrikeBrush(self.StrikeBrush)
  InTextBlock:SetTextTransformPolicy(self.TransformPolicy)
end
function WBP_TextWithInteractTipWidget_C:GetCustomKeyNameWidget()
  local TargetCustomKeyNameWidget
  if self.LeisureCustomKeyNameList:IsValidIndex(self.LeisureCustomKeyNameList:LastIndex()) then
    TargetCustomKeyNameWidget = self.LeisureCustomKeyNameList:Get(self.LeisureCustomKeyNameList:LastIndex())
    self.LeisureCustomKeyNameList:RemoveItem(TargetCustomKeyNameWidget)
  else
    TargetCustomKeyNameWidget = UE.UWidgetBlueprintLibrary.Create(self, self.CustomKeyNameTemplate:StaticClass())
  end
  local Slot = self.MainList:AddChild(TargetCustomKeyNameWidget)
  Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
  Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Center)
  return TargetCustomKeyNameWidget
end
return WBP_TextWithInteractTipWidget_C
