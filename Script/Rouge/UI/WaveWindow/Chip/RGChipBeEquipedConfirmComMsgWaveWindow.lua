local RGChipBeEquipedConfirmComMsgWaveWindow = UnLua.Class()
function RGChipBeEquipedConfirmComMsgWaveWindow:SetWaveWindowParam(WaveWindowParamParam)
  self.Overridden.SetWaveWindowParam(self, WaveWindowParamParam)
  local chipViewModel = UIModelMgr:Get("ChipViewModel")
  local chipBagItemData = chipViewModel:GetChipBagDataByUUIDRef(WaveWindowParamParam.StringParam0)
  self.WBP_ChipStrengthPanelItem:InitChipStrengthPanelItem(chipBagItemData, self)
end
function RGChipBeEquipedConfirmComMsgWaveWindow:ShowChipAttrListTip(bShow, ChipBagsItemData)
  if bShow then
    UpdateVisibility(self.RGAutoLoadPanelCompareChipAttrListTips, true)
    self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:InitChipAttrListTip(ChipBagsItemData, not ChipBagsItemData.bSelect, EChipAttrListTipSComparetate.NoOperator, EChipViewState.Normal)
  elseif UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget) then
    self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:Hide()
  end
end
return RGChipBeEquipedConfirmComMsgWaveWindow
