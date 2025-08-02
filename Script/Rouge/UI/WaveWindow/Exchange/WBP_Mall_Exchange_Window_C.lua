local rapidJson = require("rapidjson")
local WBP_Mall_Exchange_Window_C = UnLua.Class()

function WBP_Mall_Exchange_Window_C:InitExchangeWindow(TargetResourceId, ExchangeNum)
  self.TargetResourceId = TargetResourceId
  self.ExchangeNum = ExchangeNum
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceExchange, self.TargetResourceId)
  if Result then
    self.ExchangeResourceId = RowInfo.ExchangedResourceID
    self.ExchangeRatio = RowInfo.ExchangeRatio
  end
  self.MaxExchangeNum = math.floor(ExchangeNum / (self.ExchangeRatio.key / self.ExchangeRatio.value))
  local Result, ExchangeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.ExchangeResourceId)
  if not Result then
    return
  end
  local Result, TargetRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.TargetResourceId)
  if not Result then
    return
  end
  self.RGTextBlockTitle:SetText(UE.FTextFormat(self.TitleText, TargetRowInfo.Name))
  self.Txt_Info:SetText(UE.FTextFormat(self.DescText, ExchangeRowInfo.Name, TargetRowInfo.Name))
  self.WBP_SliderInput:InitSliderInput(self.ExchangeNum, 1, self.MaxExchangeNum, function(CurValue)
    self.ExchangeNum = CurValue
    self.WBP_Item:UpdateNum(math.floor(CurValue * self.ExchangeRatio.key))
    self.WBP_Item_1:UpdateNum(math.floor(CurValue * self.ExchangeRatio.value))
    local ExchangeResourceNum = LogicOutsidePackback.GetResourceNumById(self.ExchangeResourceId)
    local ExchangeResourceNeedNum = self.ExchangeNum * self.ExchangeRatio.key
    if ExchangeResourceNum < ExchangeResourceNeedNum then
      self.WBP_Item.Text_X:SetColorAndOpacity(self.ErrorColor)
      self.WBP_Item.Text_Num:SetColorAndOpacity(self.ErrorColor)
    else
      self.WBP_Item.Text_X:SetColorAndOpacity(self.DefColor)
      self.WBP_Item.Text_Num:SetColorAndOpacity(self.DefColor)
    end
  end)
  self.WBP_Item:InitItem(self.ExchangeResourceId, self.ExchangeNum * self.ExchangeRatio.key, nil, true)
  self.WBP_Item_1:InitItem(self.TargetResourceId, self.ExchangeNum * self.ExchangeRatio.value, nil, true)
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
end

function WBP_Mall_Exchange_Window_C:BindOnCancelButtonClicked()
  CloseWaveWindow(self)
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(false)
end

function WBP_Mall_Exchange_Window_C:BindOnConfirmButtonClicked()
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
      HttpCommunication.Request("resource/pullwallet", {
        currencyIds = {
          self.ExchangeResourceId
        }
      }, {
        GameInstance,
        function(Target, JsonResponse)
          print("BP_LobbyController_C:BindOnPurchaseProductsResponseDelegate", JsonResponse.Content)
          local JsonTable = rapidJson.decode(JsonResponse.Content)
          local CurrencyList = {}
          for i, SingleCurrencyInfo in ipairs(JsonTable.currencyList) do
            local CurrencyListTable = {
              currencyId = SingleCurrencyInfo.currencyId,
              number = SingleCurrencyInfo.number,
              expireAt = SingleCurrencyInfo.expireAt
            }
            table.insert(CurrencyList, CurrencyListTable)
          end
          DataMgr.SetOutsideCurrencyList(CurrencyList)
          EventSystem.Invoke(EventDef.Lobby.UpdateResourceInfo)
        end
      })
    end
  })
end

function WBP_Mall_Exchange_Window_C:K2_OnConfirmClick()
  local ExchangeResourceNum = LogicOutsidePackback.GetResourceNumById(self.ExchangeResourceId)
  local ExchangeResourceNeedNum = self.ExchangeNum * self.ExchangeRatio.key
  if ExchangeResourceNum < ExchangeResourceNeedNum then
    self.bClose = false
    local Result, ExchangeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.ExchangeResourceId)
    if Result and ExchangeRowInfo.Type == TableEnums.ENUMResourceType.PaymentCurrency then
      self:BindOnCancelButtonClicked()
      ShowWaveWindowWithDelegate(-11, {}, {
        GameInstance,
        function()
          local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_TopupCurrencyPanel")
          UIMgr:Hide(ViewID.UI_Mall_Bundle_Content, true)
          local luaInst = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
          if UE.RGUtil.IsUObjectValid(luaInst) then
            luaInst:ListenForEscInputAction()
          end
          UIMgr:Hide(ViewID.UI_DrawCard, true)
          LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
        end
      })
    else
      ShowWaveWindow(-12)
    end
  else
    self.bClose = true
    self:BindOnConfirmButtonClicked()
  end
end

return WBP_Mall_Exchange_Window_C
