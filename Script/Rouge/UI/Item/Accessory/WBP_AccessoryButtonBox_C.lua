local WBP_AccessoryButtonBox_C = UnLua.Class()
function WBP_AccessoryButtonBox_C:Construct()
  self.Button.OnClicked:Add(self, WBP_AccessoryButtonBox_C.OnClicked_Button)
end
function WBP_AccessoryButtonBox_C:InitializeButton(InWidthOverride, InHeightOverride, InText, AccessoryType)
  self.ButtonText:SetFont(self.Font)
  self.ButtonText:SetText(InText)
  self.SizeBox:SetWidthOverride(InWidthOverride)
  self.SizeBox:SetHeightOverride(InHeightOverride)
  self.AccessoryType = AccessoryType
end
function WBP_AccessoryButtonBox_C:OnClicked_Button()
  self.OnClicked:Broadcast(self)
end
return WBP_AccessoryButtonBox_C
