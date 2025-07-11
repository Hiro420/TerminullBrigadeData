local WBP_SingleModeFloorDescItem_C = UnLua.Class()
function WBP_SingleModeFloorDescItem_C:Show(InText)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Desc:SetText(InText)
end
function WBP_SingleModeFloorDescItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_SingleModeFloorDescItem_C
