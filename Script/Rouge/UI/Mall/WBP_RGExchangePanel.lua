local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local rapidJson = require("rapidjson")
local WBP_RGExchangePanel = Class(ViewBase)
function WBP_RGExchangePanel:BindClickHandler()
  self.WBP_CommonButton_Confirm.OnMainButtonClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.WBP_CommonButton_Cancel.OnMainButtonClicked:Add(self, self.BindOnCancelButtonClicked)
end
function WBP_RGExchangePanel:UnBindClickHandler()
  self.WBP_CommonButton_Confirm.OnMainButtonClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.WBP_CommonButton_Cancel.OnMainButtonClicked:Remove(self, self.BindOnCancelButtonClicked)
end
function WBP_RGExchangePanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_RGExchangePanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_RGExchangePanel:OnShow(TargetResourceId, ExchangeResourceId, ExchangeNum, ExchangeRatio, MaxExchangeNum)
  self.RealNeedExchangeResourceId = nil
  self:RefreshExchangeInfo(TargetResourceId, ExchangeResourceId, ExchangeNum, ExchangeRatio, MaxExchangeNum)
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
end
function WBP_RGExchangePanel:RefreshExchangeInfo(TargetResourceId, ExchangeResourceId, ExchangeNum, ExchangeRatio, MaxExchangeNum)
  self.TargetResourceId = TargetResourceId
  self.ExchangeResourceId = ExchangeResourceId
  self.ExchangeNum = ExchangeNum or 1
  self.ExchangeRatio = ExchangeRatio
  self.MaxExchangeNum = MaxExchangeNum
  self.CanConfirm = true
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceExchange, self.TargetResourceId)
  if Result then
    if not self.ExchangeResourceId then
      self.ExchangeResourceId = RowInfo.ExchangedResourceID
    end
    if not self.ExchangeRatio then
      self.ExchangeRatio = RowInfo.ExchangeRatio
    end
  end
  if not self.MaxExchangeNum then
    self.MaxExchangeNum = math.floor(LogicOutsidePackback.GetResourceNumById(self.ExchangeResourceId) / (self.ExchangeRatio.key / self.ExchangeRatio.value))
  end
  local Result, ExchangeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.ExchangeResourceId)
  if not Result then
    return
  end
  local Result, TargetRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.TargetResourceId)
  if not Result then
    return
  end
  self.Txt_Title:SetText(UE.FTextFormat(self.TitleText, TargetRowInfo.Name))
  self.Txt_Desc:SetText(UE.FTextFormat(self.DescText, ExchangeRowInfo.Name, TargetRowInfo.Name))
  self.WBP_SliderInput:InitSliderInput(self.ExchangeNum, 1, self.MaxExchangeNum, function(CurValue)
    self.ExchangeNum = CurValue
    self.WBP_Item:UpdateNum(math.floor(CurValue * self.ExchangeRatio.key))
    self.WBP_Item_1:UpdateNum(math.floor(CurValue * self.ExchangeRatio.value))
    local CurNum = LogicOutsidePackback.GetResourceNumById(self.ExchangeResourceId)
  end)
  self.WBP_Item:InitItem(self.ExchangeResourceId, self.ExchangeNum * self.ExchangeRatio.key, nil, true)
  self.WBP_Item_1:InitItem(self.TargetResourceId, self.ExchangeNum * self.ExchangeRatio.value, nil, true)
end
function WBP_RGExchangePanel:SetRealNeedExchangeResourceId(InResourceId)
  self.RealNeedExchangeResourceId = InResourceId
end
function WBP_RGExchangePanel:BindOnConfirmButtonClicked(...)
  if not self.CanConfirm then
    print("WBP_RGExchangePanel:BindOnConfirmButtonClicked \229\183\178\231\130\185\229\135\187\232\191\135\231\161\174\232\174\164")
    return
  end
  self.CanConfirm = false
  local JsonParam = {
    exchangeResourceList = {
      {
        consumeResourceAmount = self.ExchangeNum * self.ExchangeRatio.key,
        resourceID = self.ExchangeResourceId,
        targetResourceID = self.TargetResourceId
      }
    }
  }
  HttpCommunication.Request("resource/exchange", JsonParam, {
    self,
    function()
      print("WBP_RGExchangePanel:BindOnConfirmButtonClicked Exchange Success!")
      local ResourceInfo = LogicOutsidePackback.GetResourceInfoById(self.ExchangeResourceId)
      HttpCommunication.Request("resource/pullwallet", {
        currencyIds = {
          self.ExchangeResourceId
        }
      }, {
        GameInstance,
        function(Target, JsonResponse)
          print("WBP_RGExchangePanel:BindOnConfirmButtonClicked", JsonResponse.Content)
          local JsonTable = rapidJson.decode(JsonResponse.Content)
          local CurrencyList = {}
          for i, SingleCurrencyInfo in ipairs(JsonTable.currencyList) do
            CurrencyList[SingleCurrencyInfo.currencyId] = SingleCurrencyInfo.number
          end
          DataMgr.SetOutsideCurrencyList(CurrencyList)
          EventSystem.Invoke(EventDef.Lobby.UpdateResourceInfo)
          if self.RealNeedExchangeResourceId and self.RealNeedExchangeResourceId ~= self.TargetResourceId then
            self:RefreshExchangeInfo(self.RealNeedExchangeResourceId)
          else
            UIMgr:Hide(ViewID.UI_ExchangePanel)
          end
        end
      })
    end
  })
end
function WBP_RGExchangePanel:BindOnCancelButtonClicked(...)
  UIMgr:Hide(ViewID.UI_ExchangePanel)
end
function WBP_RGExchangePanel:OnHide()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self.RealNeedExchangeResourceId = nil
end
return WBP_RGExchangePanel
