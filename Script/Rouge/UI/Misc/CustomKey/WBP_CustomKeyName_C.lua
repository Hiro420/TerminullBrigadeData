local WBP_CustomKeyName_C = UnLua.Class()

function WBP_CustomKeyName_C:Construct()
  self:InitInfo()
end

function WBP_CustomKeyName_C:SetCustomKeyConfig(KeyRowName)
  self.KeyRowName = KeyRowName
  self:InitInfo()
end

function WBP_CustomKeyName_C:SetCustomKeyDisplayInfoByRowNameAry(KMKeyRowNameAry, PadKeyRowNameAry)
  local customKeyDisplayInfo = self.CustomKeyDisplayInfo
  customKeyDisplayInfo.KMKeyRowNameList:Clear()
  customKeyDisplayInfo.PadKeyRowNameList:Clear()
  if nil == KMKeyRowNameAry then
    KMKeyRowNameAry = {}
  end
  for i, v in ipairs(KMKeyRowNameAry) do
    customKeyDisplayInfo.KMKeyRowNameList:Add(v)
  end
  if nil == PadKeyRowNameAry then
    PadKeyRowNameAry = {}
  end
  for i, v in ipairs(PadKeyRowNameAry) do
    customKeyDisplayInfo.PadKeyRowNameList:Add(v)
  end
  self:SetCustomKeyDisplayInfo(customKeyDisplayInfo)
end

function WBP_CustomKeyName_C:SetStyleConfig(BottomIcon, IconSize, BottomColorAndOpacity, BottomIconSize, TextColorAndOpacity)
  if BottomIcon then
    self.BottomIcon = BottomIcon
  end
  if IconSize then
    self.IconSize = IconSize
  end
  if BottomColorAndOpacity then
    self.BottomColorAndOpacity = BottomColorAndOpacity
  end
  if BottomIconSize then
    self.BottomIconSize = BottomIconSize
  end
  if TextColorAndOpacity then
    self.TextColorAndOpacity = TextColorAndOpacity
  end
end

function WBP_CustomKeyName_C:SetBottomOpacity(Opacity)
  self.FirstKeyName:SetBottomOpacity(Opacity)
  self.SecondKeyName:SetBottomOpacity(Opacity)
end

function WBP_CustomKeyName_C:SetTextOpacity(Opacity)
  self.FirstKeyName:SetTextOpacity(Opacity)
  self.SecondKeyName:SetTextOpacity(Opacity)
end

function WBP_CustomKeyName_C:SetTextColorAndOpacity(ColorAndOpacity)
  self.FirstKeyName:SetTextColorAndOpacity(ColorAndOpacity)
  self.SecondKeyName:SetTextColorAndOpacity(ColorAndOpacity)
end

function WBP_CustomKeyName_C:SetIconColorAndOpacity(ColorAndOpacity)
  self.FirstKeyName:SetIconColorAndOpacity(ColorAndOpacity)
  self.SecondKeyName:SetIconColorAndOpacity(ColorAndOpacity)
end

function WBP_CustomKeyName_C:Hide()
  UpdateVisibility(self, false)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
  self.IsBind = false
  self.FirstKeyName:Hide()
  self.SecondKeyName:Hide()
end

function WBP_CustomKeyName_C:PlayHoverOrUnhoverAnim(IsHover)
  if IsHover then
    self:PlayAnimationForward(self.Ani_hover_in)
  else
    self:PlayAnimationForward(self.Ani_hover_out)
  end
end

function WBP_CustomKeyName_C:InitInfo()
  UpdateVisibility(self, true)
  self:StopAllAnimations()
  if not self.IsBind then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
    if CommonInputSubsystem then
      CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
    end
    self.IsBind = true
  end
  self:ChangeCustomKeyAppearance()
end

function WBP_CustomKeyName_C:BindOnInputMethodChanged(InputType)
  self:ChangeCustomKeyAppearance()
end

function WBP_CustomKeyName_C:ChangeCustomKeyAppearance()
  local TargetKeyRowNameList = {}
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if not CommonInputSubsystem then
    print("WBP_CustomKeyName_C:ChangeCustomKeyAppearance CommonInputSubsystem is nil")
    return
  end
  local CustomKeyDisplayInfo = self.CustomKeyDisplayInfo
  local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
  if CurrentInputType == UE.ECommonInputType.Gamepad then
    for k, SingleKeyRowName in pairs(CustomKeyDisplayInfo.PadKeyRowNameList) do
      table.insert(TargetKeyRowNameList, SingleKeyRowName)
    end
  else
    for k, SingleKeyRowName in pairs(CustomKeyDisplayInfo.KMKeyRowNameList) do
      table.insert(TargetKeyRowNameList, SingleKeyRowName)
    end
  end
  if nil == TargetKeyRowNameList then
    TargetKeyRowNameList = {}
  end
  if nil == next(TargetKeyRowNameList) then
    table.insert(TargetKeyRowNameList, self.KeyRowName)
  end
  local KeyNameItemList = {
    self.FirstKeyName,
    self.SecondKeyName
  }
  for i, SingleKeyNameItem in ipairs(KeyNameItemList) do
    local KeyRowName = TargetKeyRowNameList[i]
    if KeyRowName then
      SingleKeyNameItem:Show()
      local KeyNameStyle = self.CustomKeyDisplayInfo.KeyNameStyle
      SingleKeyNameItem:SetCustomKeyConfig(KeyRowName, KeyNameStyle)
      if 2 == i then
        UpdateVisibility(self.Txt_FirstSpaceFlag, true)
      end
    else
      SingleKeyNameItem:Hide()
      UpdateVisibility(self.Txt_FirstSpaceFlag, false)
    end
  end
end

function WBP_CustomKeyName_C:Destruct()
  self:Hide()
end

return WBP_CustomKeyName_C
