local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local RGChangeNickNameWaveWindow = UnLua.Class()
local ECostState = {Enough = "Enough", NotEnough = "NotEnough"}

function RGChangeNickNameWaveWindow:OnBindUIInput()
  self.WBP_InteractTipWidgetBuy:BindInteractAndClickEvent(self, self.OnConfirmClick)
  self.WBP_InteractTipWidgetCancel:BindInteractAndClickEvent(self, self.OnCancelClick)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.OnCancelClick)
end

function RGChangeNickNameWaveWindow:OnUnBindUIInput()
  self.WBP_InteractTipWidgetBuy:UnBindInteractAndClickEvent(self, self.OnConfirmClick)
  self.WBP_InteractTipWidgetCancel:UnBindInteractAndClickEvent(self, self.OnCancelClick)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.OnCancelClick)
end

function RGChangeNickNameWaveWindow:SetWaveWindowParam(WaveWindowParamParam)
  self:PlayAnimation(self.StartAnim)
  self.Overridden.SetWaveWindowParam(self, WaveWindowParamParam)
  local costItemKey = PlayerInfoData.CostItemList[1].key
  local costItemValue = PlayerInfoData.CostItemList[1].value
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if tbGeneral and tbGeneral[costItemKey] then
    SetImageBrushByPath(self.URGImageCostIcon, tbGeneral[costItemKey].Icon)
  end
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(costItemKey)
  local itemValue = 0
  if CurrencyInfo then
    if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
      itemValue = DataMgr.GetOutsideCurrencyNumById(costItemKey)
    else
      itemValue = DataMgr.GetPackbackNumById(costItemKey)
    end
  end
  local str = string.format("%d/%d", itemValue, costItemValue)
  self.RGTextCostValue:SetText(str)
  local playerInfoViewModel = UIModelMgr:Get("PlayerInfoViewModel")
  if CheckCost(playerInfoViewModel:GetCostItemList()) then
    self.RGStateControllerCost:ChangeStatus(ECostState.Enough)
  else
    self.RGStateControllerCost:ChangeStatus(ECostState.NotEnough)
  end
end

function RGChangeNickNameWaveWindow:GetNickName()
  return tostring(self.RGEditableTextNickName:GetText())
end

return RGChangeNickNameWaveWindow
