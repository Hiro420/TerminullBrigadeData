local WBP_AccessorySlotBox_C = UnLua.Class()
function WBP_AccessorySlotBox_C:Construct()
  self:UpdateAngle()
end
function WBP_AccessorySlotBox_C:UpdateAngle()
  local find, shouldRotate = self:CheckAngle(self.AccessoryType)
  if find then
    if shouldRotate then
      self:SetRenderTransformAngle(180)
      self.WBP_AccessorySlotItem:UpdateAngle()
    end
  else
    print("not find data from DT_AccessoryType ---- WBP_AccessorySlotBox_C")
  end
end
function WBP_AccessorySlotBox_C:UpdateAccessorySlotItem(HasAccessory, AccessoryId, AccessoryRarity)
  self:UpdateLine(HasAccessory)
  self.WBP_AccessorySlotItem:UpdateAccessorySlotItem(HasAccessory, AccessoryId, AccessoryRarity, self.AccessoryType, self)
end
function WBP_AccessorySlotBox_C:UpdateLine(Show)
  if Show then
    self.Image_Line:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_LineEnd:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Line:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_LineEnd:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
return WBP_AccessorySlotBox_C
