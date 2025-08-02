local WBP_SliderInput_C = UnLua.Class()

function WBP_SliderInput_C:OnBindUIInput()
end

function WBP_SliderInput_C:OnUnBindUIInput()
end

function WBP_SliderInput_C:Construct()
end

function WBP_SliderInput_C:InitSliderInput(CurValue, MinValue, MaxValue, ChangeFunc)
  self:BindFunction()
  self.CurValue = CurValue
  self.MaxValue = MaxValue
  self.MinValue = MinValue
  if self.MaxValue < self.MinValue then
    self.MaxValue = self.MinValue
  end
  self.ChangeFunc = ChangeFunc
  self.SliderWidget:SetMinValue(MinValue)
  self.SliderWidget:SetMaxValue(MaxValue)
  self:RefreshButtonState()
  UpdateVisibility(self, MinValue ~= MaxValue)
end

function WBP_SliderInput_C:BindFunction()
  self.Editable.OnTextChanged:Remove(self, self.OnTextChanged)
  self.Editable.OnTextChanged:Add(self, self.OnTextChanged)
  self.SliderWidget.OnValueChanged:Remove(self, self.OnValueChanged)
  self.SliderWidget.OnValueChanged:Add(self, self.OnValueChanged)
  self.Cut.OnClicked:Remove(self, self.CutFunc)
  self.Cut.OnClicked:Add(self, self.CutFunc)
  self.Add.OnClicked:Remove(self, self.AddFunc)
  self.Add.OnClicked:Add(self, self.AddFunc)
  self.Max.OnClicked:Remove(self, self.MaxFunc)
  self.Max.OnClicked:Add(self, self.MaxFunc)
end

function WBP_SliderInput_C:OnTextChanged(Text)
  if tonumber(Text) == nil then
    if nil == self.InputNum then
      self.InputNum = 1
    end
    self.Editable:SetText(self.InputNum)
    return
  end
  local NewText = math.floor(tonumber(Text))
  self.InputNum = tonumber(NewText)
  if self.MinValue <= tonumber(NewText) and tonumber(NewText) <= self.MaxValue and nil ~= self.CurValue and self.CurValue ~= tonumber(NewText) then
    self.CurValue = tonumber(NewText)
    self:RefreshButtonState()
    return
  end
  if self.MinValue > tonumber(NewText) then
    self.CurValue = self.MinValue
    self.Editable.SelectAllTextOnCommit = true
    self:RefreshButtonState()
    return
  end
  if tonumber(NewText) > self.MaxValue then
    self.CurValue = self.MaxValue
    self.Editable.SelectAllTextOnCommit = true
    self:RefreshButtonState()
    return
  end
  if Text ~= tostring(NewText) then
    self:RefreshButtonState()
  end
end

function WBP_SliderInput_C:OnValueChanged(Value)
  self.CurValue = math.floor(Value)
  self:RefreshButtonState()
end

function WBP_SliderInput_C:CutFunc()
  self.CurValue = self.CurValue - 1
  self:RefreshButtonState()
end

function WBP_SliderInput_C:AddFunc()
  self.CurValue = self.CurValue + 1
  self:RefreshButtonState()
end

function WBP_SliderInput_C:MaxFunc()
  self.CurValue = self.MaxValue
  self:RefreshButtonState()
end

function WBP_SliderInput_C:RefreshButtonState()
  if tostring(self.Editable:GetText()) ~= tostring(self.CurValue) then
    self.Editable:SetText(tostring(self.CurValue))
  end
  self.SliderWidget:SetValue(self.CurValue)
  self.Cut:SetIsEnabled(self.CurValue ~= self.MinValue)
  self.Add:SetIsEnabled(self.CurValue ~= self.MaxValue)
  self.Max:SetIsEnabled(self.CurValue ~= self.MaxValue)
  if self.ChangeFunc then
    self.ChangeFunc(self.CurValue)
  end
end

function WBP_SliderInput_C:SetInitAmount(InitAmount)
  if not InitAmount then
    return
  end
  self.CurValue = InitAmount
  self:RefreshButtonState()
end

return WBP_SliderInput_C
