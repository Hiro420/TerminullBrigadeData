local TopupHandler = {}
local rapidjson = require("rapidjson")
local TopupData = require("Modules.Topup.TopupData")
local LoginData = require("Modules.Login.LoginData")
local RechargeData = require("Modules.Recharge.RechargeData")
local JumpToTopupPanelHideViewList = {
  {
    ViewId = ViewID.UI_Mall_Bundle_Content,
    bHideOther = true
  },
  {
    ViewId = ViewID.UI_Apearance,
    SpecialFunctionName = "ListenForEscInputAction"
  },
  {
    ViewId = ViewID.UI_DrawCard,
    bHideOther = true
  },
  {
    ViewId = ViewID.UI_BattlePassMainView,
    bHideOther = true
  },
  {
    ViewId = ViewID.UI_MainModeSelection,
    bHideOther = true
  },
  {
    ViewId = ViewID.UI_DevelopMain,
    bHideOther = true
  }
}
local MaxPayTimeOutTime = 60
local CheckShowINTLUnderAgeTip = function()
  if IsPlayerAdult() then
    return false
  end
  local RegionId = GetRegionId()
  if RegionId == RegionCode.Japan then
    local LobbySaveGame = LogicLobby.GetLobbySaveGame()
    local LastSetPayAgeTime = LobbySaveGame:GetLastSetPayAgeTime(DataMgr.GetUserId())
    if GetCurrentTimestamp(true) - LastSetPayAgeTime < 259200 then
      print("TopupHandler:CheckShowINTLUnderAgeTip LastSetPayAgeTime is less than 30 days")
      return false
    end
    UIMgr:Show(ViewID.UI_ComplianceWaveWindow)
    return true
  end
  return false
end

function TopupHandler:RequestBuyMisdasProduct(ProductId, Quantity)
  if not ProductId or not Quantity then
    return
  end
  local RealProductId = TopupData:GetProductIdByResourceId(ProductId)
  if 0 ~= RealProductId then
    print("TopupHandler:RequestBuyMisdasProduct RealProductId = ", tostring(RealProductId), ProductId)
    ProductId = RealProductId
  end
  local Result, PaymentRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, ProductId)
  if not Result then
    return
  end
  local RegionId = GetRegionId()
  if RegionId == RegionCode.Japan and not IsPlayerAdult() then
    local MonthRechargeTimestamp = RechargeData.GetMonthRechargeTimestamp()
    local CurRechargeTimestamp = RechargeData.GetCurRechargeTimestamp()
    if nil == MonthRechargeTimestamp or IsNewMonth(MonthRechargeTimestamp, CurRechargeTimestamp) then
      local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if not WaveWindowManager then
        return
      end
      WaveWindowManager:ShowWaveWindow(500001)
      RechargeData.SetMonthRechargeTimestamp(CurRechargeTimestamp)
    end
  end
  if not TopupData:IsExecuteINTLPayLogic() then
    local OnlinePurchaseSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlinePurchaseSystem:StaticClass())
    if not OnlinePurchaseSystem then
      print("TopupHandler:RequestBuyMisdasProduct OnlinePurchaseSystem is nil")
      return
    end
    local OnlinePurchaseItem = UE.FOnlinePurchaseItem()
    OnlinePurchaseItem.Id = PaymentRowInfo.MidasGoodsID
    OnlinePurchaseItem.Quantity = Quantity
    local Items = {OnlinePurchaseItem}
    local Result = OnlinePurchaseSystem:AsyncPurchaseProducts(Items, RapidJsonEncode({
      roleID = DataMgr.GetUserId()
    }), LoginData:GetLobbyServerId())
    return Result
  else
    local IsInPay = UE.URGPlatformFunctionLibrary.GetIsInPay()
    if IsInPay and TopupData.LastPayTime and GetCurrentTimestamp(true) - TopupData.LastPayTime < MaxPayTimeOutTime then
      print("TopupHandler:RequestBuyMisdasProduct IsInPay")
      return
    end
    TopupData.CurBuyProductId = ProductId
    TopupData.CurBuyQuantity = Quantity
    if CheckShowINTLUnderAgeTip() then
      print("TopupHandler:RequestBuyMisdasProduct Need ShowINTLUnderAgeTip")
      return
    end
    local IsSteamCNChannel = UE.URGBlueprintLibrary.IsSteamCNChannel()
    local CurrencyType = PaymentRowInfo.CurrencyType
    local Region = PaymentRowInfo.Region
    local DefaultRegion = IsSteamCNChannel and "CN" or "US"
    local DefaultCurrencyType = IsSteamCNChannel and "CNY" or "USD"
    local SDKProductInfo = TopupData:GetSDKProductInfo(PaymentRowInfo.MidasGoodsID)
    if SDKProductInfo then
      local Result, ValidCountryRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRechargeValidCountry, SDKProductInfo.region_code)
      if Result then
        Region = SDKProductInfo.region_code
        CurrencyType = SDKProductInfo.currency_code
      else
        Region = DefaultRegion
        CurrencyType = DefaultCurrencyType
      end
    else
      Region = DefaultRegion
      CurrencyType = DefaultCurrencyType
    end
    local Language = ""
    if "CN" == Region then
      if UE.URGBlueprintLibrary.IsOfficialPackage() then
        Language = "zh"
      else
        Language = "zh-CN"
      end
    else
      Language = "en"
    end
    local Param = {
      language = Language,
      products = {
        {
          productID = PaymentRowInfo.MidasGoodsID,
          quantity = Quantity
        }
      },
      transaction = {
        currencyType = CurrencyType,
        payChannel = TopupData:GetPayChannel(),
        region = Region
      }
    }
    if not IsSteamCNChannel then
      local RegistrationRegion = GetRegionId()
      local Result, ISORowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBISOCountryCode, tonumber(RegistrationRegion))
      local TargetRegion = Result and ISORowInfo.Alpha_2 or RegistrationRegion
      local PublicIP = UE.UHttpService.GetPublicIPAddr(GameInstance)
      Param.userInfo = {
        age = TopupData:GetTopupAge(),
        ip = PublicIP,
        registrationRegion = TargetRegion
      }
    end
    UE.URGPlatformFunctionLibrary.SetIsInPay(true)
    TopupData.LastPayTime = GetCurrentTimestamp(true)
    local Path = IsSteamCNChannel and "pay/china/createorder" or "pay/oversea/createorder"
    HttpCommunication.Request(Path, Param, {
      GameInstance,
      function(Target, JsonResponse)
        print("CreateOrder Success!", JsonResponse.Content)
        local JsonTable = rapidjson.decode(JsonResponse.Content)
        UE.URGPlatformFunctionLibrary.CTIPay(JsonTable.payInfo)
      end
    }, {
      GameInstance,
      function()
        UE.URGPlatformFunctionLibrary.SetIsInPay(false)
      end
    })
    return true
  end
end

function TopupHandler:RequestGetAllProductInfo()
  if not TopupData:IsExecuteINTLPayLogic() then
    return
  end
  local AllMidasProductId = TopupData:GetAllMidasProductIdList()
  local Result = UE.URGPlatformFunctionLibrary.CTIGetProductInfo(AllMidasProductId)
  print("TopupHandler:RequestGetAllProductInfo", Result)
end

function TopupHandler:RequestPaymentCurrencyAfterPay()
  local PaymentCurrencyTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPaymentCurrency)
  local CurrenctIdList = {}
  local CurCurrencyNumList = {}
  if PaymentCurrencyTable then
    for CurrencyId, v in pairs(PaymentCurrencyTable) do
      table.insert(CurrenctIdList, CurrencyId)
      CurCurrencyNumList[CurrencyId] = LogicOutsidePackback.GetResourceNumById(CurrencyId)
    end
  end
  if next(CurrenctIdList) == nil then
    return
  end
  HttpCommunication.Request("resource/pullwallet", {currencyIds = CurrenctIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("TopupHandler:RequestPaymentCurrencyAfterPay", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local CurrencyList = {}
      local ChangedCurrencyList = {}
      for i, SingleCurrencyInfo in ipairs(JsonTable.currencyList) do
        local CurrencyListTable = {
          currencyId = SingleCurrencyInfo.currencyId,
          number = SingleCurrencyInfo.number,
          expireAt = SingleCurrencyInfo.expireAt
        }
        table.insert(CurrencyList, CurrencyListTable)
        local OldCurrencyNum = CurCurrencyNumList[SingleCurrencyInfo.currencyId]
        if OldCurrencyNum and SingleCurrencyInfo.number - OldCurrencyNum > 0 then
          local TempTable = {
            Id = SingleCurrencyInfo.currencyId,
            Num = SingleCurrencyInfo.number - OldCurrencyNum
          }
          table.insert(ChangedCurrencyList, TempTable)
        end
      end
      if LogicLobby.IsInLobbyLevel() and next(ChangedCurrencyList) ~= nil then
        EventSystem.Invoke(EventDef.Lobby.OnGetPropTip, ChangedCurrencyList)
      end
      DataMgr.SetOutsideCurrencyList(CurrencyList)
      EventSystem.Invoke(EventDef.Lobby.UpdateResourceInfo)
    end
  })
end

function TopupHandler:JumpToTopupPanel()
  ShowWaveWindowWithDelegate(-11, {}, {
    GameInstance,
    function()
      for i, ViewInfo in ipairs(JumpToTopupPanelHideViewList) do
        if ViewInfo.SpecialFunctionName then
          local luaInst = UIMgr:GetLuaFromActiveView(ViewInfo.ViewId)
          if UE.RGUtil.IsUObjectValid(luaInst) and luaInst[ViewInfo.SpecialFunctionName] then
            luaInst[ViewInfo.SpecialFunctionName](luaInst)
          end
        else
          local IsHideOther = ViewInfo.bHideOther ~= nil and ViewInfo.bHideOther or false
          UIMgr:Hide(ViewInfo.ViewId, IsHideOther)
        end
      end
      local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_TopupCurrencyPanel")
      LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
    end
  })
end

return TopupHandler
