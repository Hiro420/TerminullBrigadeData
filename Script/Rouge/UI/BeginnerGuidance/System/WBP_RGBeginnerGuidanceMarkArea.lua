local WBP_RGBeginnerGuidanceMarkArea = UnLua.Class()
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local markCustomZOrder = GetCustomZOrderByLayer(UE.ECustomLayer.ELayer_GuidMarkArea)
local CustomZOrder = GetCustomZOrderByLayer(UE.ECustomLayer.ELayer_Guid)
local InvalidCustomZOrder = GetCustomZOrderByLayer(UE.ECustomLayer.ELayer_None)
function WBP_RGBeginnerGuidanceMarkArea:Construct()
  self:UpdateWidget()
end
function WBP_RGBeginnerGuidanceMarkArea:UpdateWidget()
  if UE.UKismetStringLibrary.IsEmpty(self.Name) then
    return
  end
  if BeginnerGuideData:GetWidget(nil, self.Name) then
    print("ywtao, WBP_RGBeginnerGuidanceMarkArea:UpdateWidget WidgetName is already exist", self.Name)
  end
  BeginnerGuideData:UpdateWidget(self.Name, self)
end
function WBP_RGBeginnerGuidanceMarkArea:UpdateBeginnerGuidArea(NotCanClickSelectArea)
  UpdateVisibility(self.AutoLoad_Frame, true)
  if self.AutoLoad_Frame.CustomZOrder ~= markCustomZOrder then
    self.AutoLoad_Frame:PlayAnimation("Ani_in")
  end
  if self.AutoLoad_Frame.SetCustomZOrder then
    self.AutoLoad_Frame:SetCustomZOrder(markCustomZOrder)
  end
  UpdateVisibility(self.Img_Mask, false)
  self:RaiseTargetWidget(self.RaiseWidget, NotCanClickSelectArea)
  for i, v in pairs(self.RaiseWidgetList) do
    self:RaiseTargetWidget(v, NotCanClickSelectArea)
  end
end
function WBP_RGBeginnerGuidanceMarkArea:ResetGuidArea()
  UpdateVisibility(self.AutoLoad_Frame, false)
  if self.AutoLoad_Frame.SetCustomZOrder then
    self.AutoLoad_Frame:SetCustomZOrder(InvalidCustomZOrder)
  end
  UpdateVisibility(self.Img_Mask, false)
  self:ResetTargetWidget(self.RaiseWidget)
  for i, v in pairs(self.RaiseWidgetList) do
    self:ResetTargetWidget(v)
  end
end
function WBP_RGBeginnerGuidanceMarkArea:RaiseTargetWidget(TargetWidget, NotCanClickSelectArea)
  if TargetWidget and TargetWidget:IsValid() then
    if TargetWidget.SetCustomZOrder then
      if NotCanClickSelectArea then
        UpdateVisibility(self.Img_Mask, true, true)
      else
        UpdateVisibility(self.Img_Mask, false)
      end
      TargetWidget:SetCustomZOrder(CustomZOrder)
    else
      print("WBP_RGBeginnerGuidanceMarkArea:Construct TargetRaiseWidget.SetCustomZOrder is nil", TargetWidget:GetName())
    end
  else
    print("WBP_RGBeginnerGuidanceMarkArea:Construct TargetRaiseWidget is nil")
  end
end
function WBP_RGBeginnerGuidanceMarkArea:ResetTargetWidget(TargetWidget)
  if TargetWidget and TargetWidget:IsValid() then
    if TargetWidget.SetCustomZOrder then
      TargetWidget:SetCustomZOrder(InvalidCustomZOrder)
    else
      print("WBP_RGBeginnerGuidanceMarkArea:Construct TargetWidget.SetCustomZOrder is nil", TargetWidget:GetName())
    end
  else
    print("WBP_RGBeginnerGuidanceMarkArea:Construct TargetWidget is nil")
  end
end
function WBP_RGBeginnerGuidanceMarkArea:UpdateFrameVis(bIsShow)
  UpdateVisibility(self.AutoLoad_Frame, bIsShow)
end
return WBP_RGBeginnerGuidanceMarkArea
