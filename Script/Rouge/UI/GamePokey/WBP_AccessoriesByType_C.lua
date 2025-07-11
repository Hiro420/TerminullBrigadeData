local WBP_AccessoriesByType_C = UnLua.Class()
function WBP_AccessoriesByType_C:CreateSingleAccessory(Array)
  self.VerticalBox_Accessories:ClearChildren()
  local widget
  for key, value in iterator(Array) do
    widget = UE.UWidgetBlueprintLibrary.Create(self, self.wbp_SingleAccessoryClass, self:GetOwningPlayer())
    if widget then
      local paddings = UE.FMargin()
      paddings.Top = 5
      widget:SetPadding(paddings)
      widget:InitInfo(self.GamePokey, value)
      self.VerticalBox_Accessories:AddChild(widget)
      self.GamePokey.Accessories:Add(widget)
    end
  end
end
function WBP_AccessoriesByType_C:InitInfo(GamePokey, AccessoryType, AccessoryTypeName, Array, ShowBack)
  if GamePokey then
    self.GamePokey = GamePokey
    self.AccessoryType = AccessoryType
    self.wbp_SingleAccessoryClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_SingleAccessory.WBP_SingleAccessory_C")
    self.TextBlock_Type:SetText(AccessoryTypeName)
    self:CreateSingleAccessory(Array)
    if ShowBack then
      self.Image_Type:SetVisibility(UE.ESlateVisibility.Visible)
    else
      self.Image_Type:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end
function WBP_AccessoriesByType_C:RefreshState()
  local widget
  for key, value in iterator(self.VerticalBox_Accessories:GetAllChildren()) do
    widget = value:Cast(self.wbp_SingleAccessoryClass)
    if widget then
      widget:RefreshState()
    end
  end
end
function WBP_AccessoriesByType_C:CheckItemExist()
  local widget
  for key, value in iterator(self.VerticalBox_Accessories:GetAllChildren()) do
    widget = value:Cast(self.wbp_SingleAccessoryClass)
    if widget then
      widget:CheckItemExist()
    end
  end
  if not (self.VerticalBox_Accessories:GetAllChildren():Length() > 0) then
    self:RemoveFromParent()
    return self.AccessoryType, true
  end
  return self.AccessoryType, false
end
function WBP_AccessoriesByType_C:OnButtonClicked(Accessory)
  if self.GamePokey then
    self.GamePokey:OnAccessoryClicked(Accessory)
  end
end
return WBP_AccessoriesByType_C
