require("UnLua")
require("Rouge.UI.UIBase.UIConfig")
UILayerGroup = UnLua.Class()
function UILayerGroup:Ctor(...)
  self.UIInstAry = {}
  self.UILayerId = EUILayer.None
  self.LayerFrameOrderOffset = 1
  self.ContainFullScreenWindow = false
end
function UILayerGroup:GetHighestUIInst()
  return self.UIInstAry[#self.UIInstAry]
end
function UILayerGroup:GetHighestNeedFocusUIInst()
  for i = #self.UIInstAry, 1, -1 do
    if self.UIInstAry[i] and self.UIInstAry[i]:GetIsFocusInput() and self.UIInstAry[i]:IsShown() then
      return self.UIInstAry[i]
    end
  end
  return nil
end
function UILayerGroup:SetGroupActive(UpperLayerContainsFullScreenWindow)
  if self.UIInstAry == nil then
    return
  end
  local Count = #self.UIInstAry
  local FindFullScreenWindow = false
  if UpperLayerContainsFullScreenWindow then
    for i = Count, 1, -1 do
      local UIInst = self.UIInstAry[i]
      if UIInst:IsShown() then
        UIInst:UnfocusInput()
        UIInst:OnHideByLayer()
      end
      if UIInst:IsFullScreen() then
        FindFullScreenWindow = true
      end
    end
  else
    for i = Count, 1, -1 do
      local UIInst = self.UIInstAry[i]
      if UIInst.ViewStatus ~= UE.EViewStatus.Hide then
        if UIInst:IsFullScreen() and false == FindFullScreenWindow then
          if UIInst:IsHideByLayer() then
            UIInst:OnDisplayByLayer()
          end
          FindFullScreenWindow = true
        elseif false == FindFullScreenWindow then
          if UIInst:IsHideByLayer() then
            UIInst:OnDisplayByLayer()
          end
        elseif UIInst:IsShown() == true then
          UIInst:UnfocusInput()
          UIInst:OnHideByLayer()
        end
      end
    end
  end
  self.ContainFullScreenWindow = FindFullScreenWindow
end
function UILayerGroup:SetLayerId(LayerIdParam)
  self.UILayerId = LayerIdParam
end
function UILayerGroup:AddToGroup(UIInstParam)
  if not UIInstParam then
    print("UILayerGroup:AddToGroup UIInstParam Is Null", UIInstParam)
    return
  end
  local HighestOrder = self.LayerFrameOrderOffset
  local HighestUIInst = self:GetHighestUIInst()
  if HighestUIInst then
    HighestOrder = HighestUIInst:GetZOrder() + self.LayerFrameOrderOffset
  end
  local CanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(UIInstParam)
  if CanvasSlot then
    CanvasSlot:SetZOrder(HighestOrder)
  end
  UIInstParam:SetZOrder(HighestOrder)
  if not table.Contain(self.UIInstAry, UIInstParam) then
    table.insert(self.UIInstAry, UIInstParam)
  end
end
function UILayerGroup:RemoveFromGroup(UIInstParam)
  if not UIInstParam then
    print("UILayerGroup:RemoveFromGroup UIInstParam Is Null", UIInstParam)
    return
  end
  local Index = table.IndexOf(self.UIInstAry, UIInstParam)
  if Index then
    table.remove(self.UIInstAry, Index)
    UIInstParam:RemoveFromViewport()
  end
end
function UILayerGroup:Clear()
  for Index, Value in ipairs(self.UIInstAry) do
    Value:RemoveFromViewport()
  end
  self.UIInstAry = {}
end
function UILayerGroup:GetContainFullScreenWindow()
  return self.ContainFullScreenWindow
end
function UILayerGroup:GetHighestFullScreenWnd()
  if not self.ContainFullScreenWindow then
    return nil
  end
  for i = #self.UIInstAry, 1, -1 do
    local UIInst = self.UIInstAry[i]
    if UIInst and UIInst:IsFullScreen() and UIInst:IsShown() then
      return UIInst
    end
  end
  return nil
end
