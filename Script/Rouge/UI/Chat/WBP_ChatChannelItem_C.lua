local WBP_ChatChannelItem_C = UnLua.Class()
local CompositeRowName = 255
function WBP_ChatChannelItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_ChatChannelItem_C:Init(ChannelId)
  local rowName = ChannelId
  if ChannelId == UE.EChatChannel.Composite then
    rowName = CompositeRowName
  end
  local ChannelRow = LogicChat:GetChannelRow(rowName)
  local Name = ""
  if ChannelRow then
    Name = ChannelRow.ChannelName
    SetImageBrushBySoftObject(self.URGImageIconSelect, ChannelRow.ChannelIconSoft)
    SetImageBrushBySoftObject(self.URGImageIconUnSelect, ChannelRow.ChannelIconSoft)
    self.URGImageBgSelect:SetColorAndOpacity(ChannelRow.ChannelColor.SpecifiedColor)
    self.URGImageBgUnSelect:SetColorAndOpacity(ChannelRow.ChannelColor.SpecifiedColor)
    self.URGImageBgUnSelectShadow:SetColorAndOpacity(ChannelRow.ChannelShadowColor.SpecifiedColor)
    self.URGImageBgSelectShadow:SetColorAndOpacity(ChannelRow.ChannelShadowColor.SpecifiedColor)
    self.URGImageIconSelect:SetColorAndOpacity(ChannelRow.ChannelIconColor.SpecifiedColor)
  end
  UpdateVisibility(self.CanvasPanelNameTips, false)
  self.RGTextName:SetText(Name)
end
function WBP_ChatChannelItem_C:Destruct()
  self.Overridden.Destruct(self)
end
function WBP_ChatChannelItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.CanvasPanelNameTips, true)
end
function WBP_ChatChannelItem_C:OnMouseLeave(MouseEvent)
  UpdateVisibility(self.CanvasPanelNameTips, false)
end
return WBP_ChatChannelItem_C
