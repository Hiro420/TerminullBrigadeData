local TopupData = {
  AllProductShelfInfo = {},
  AllMidasProductIdList = {},
  AllProductsCurrencyInfo = {},
  AllSDKProductInfo = {},
  AllMidasIdToProductIdList = {},
  Age = 20,
  LastPayTime = 0
}

function TopupData:DealWithTable(...)
  TopupData.AllProductShelfInfo = {}
  TopupData.AllMidasProductIdList = {}
  TopupData.AllMidasIdToProductIdList = {}
  local TopupTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPaymentMall)
  local CurRegion = UE.URGPlatformFunctionLibrary.IsLIPassEnabled() and TableEnums.ENUNRegion.INTL or TableEnums.ENUNRegion.CN
  for Id, Info in pairs(TopupTable) do
    if Info.IsShow and CurRegion == Info.Region then
      for i, SingleShelfId in ipairs(Info.Shelfs) do
        if not TopupData.AllProductShelfInfo[SingleShelfId] then
          TopupData.AllProductShelfInfo[SingleShelfId] = {}
        end
        table.insert(TopupData.AllProductShelfInfo[SingleShelfId], Id)
      end
      table.insert(TopupData.AllMidasProductIdList, Info.MidasGoodsID)
      TopupData.AllMidasIdToProductIdList[Info.MidasGoodsID] = Id
    end
  end
end

function TopupData:GetProductIdListByShelfId(ShelfId)
  return TopupData.AllProductShelfInfo[ShelfId] or {}
end

function TopupData:SetSDKProductInfo(ProductInfo)
  TopupData.AllSDKProductInfo[ProductInfo.unified_product_id] = ProductInfo
end

function TopupData:GetSDKProductInfo(ProductId)
  return TopupData.AllSDKProductInfo[ProductId]
end

function TopupData:GetProductIdByResourceId(InResourceId)
  return TopupData.AllMidasIdToProductIdList[tostring(InResourceId)] or 0
end

function TopupData:GetProductDisplayPrice(ProductId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, ProductId)
  if not Result then
    return "0"
  end
  local SDKProductInfo = TopupData.AllSDKProductInfo[RowInfo.MidasGoodsID]
  if SDKProductInfo then
    local Result, ValidCountryRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRechargeValidCountry, SDKProductInfo.region_code)
    if Result then
      return SDKProductInfo.display_price
    end
  end
  local Unit = "CNY"
  if RowInfo.CurrencyType == TableEnums.ENUMCurrencyType.USD then
    Unit = "USD"
  end
  return string.format("%s %.2f", Unit, RowInfo.Price)
end

function TopupData:GetPayChannel(...)
  return UE.URGBlueprintLibrary.IsOfficialPackage() and "os_midaspay" or "os_steam"
end

function TopupData:GetAllMidasProductIdList(...)
  return TopupData.AllMidasProductIdList
end

function TopupData:IsExecuteINTLPayLogic()
  local IsSteamCNChannel = UE.URGBlueprintLibrary.IsSteamCNChannel()
  return UE.URGPlatformFunctionLibrary.IsLIPassEnabled() or IsSteamCNChannel
end

function TopupData:InitTopupAge()
  local LobbySaveGame = LogicLobby.GetLobbySaveGame()
  local CurPayAge = LobbySaveGame:GetCurPayAge(DataMgr.GetUserId())
  if 0 ~= CurPayAge then
    TopupData:SetTopupAge(CurPayAge)
  elseif IsPlayerAdult() then
    TopupData:SetTopupAge(20)
  else
    TopupData:SetTopupAge(13)
  end
end

function TopupData:SetTopupAge(InAge, IsNeedSave, IsExecuteINTLPayLogic)
  TopupData.Age = InAge
  if IsNeedSave then
    local LobbySaveGame = LogicLobby.GetLobbySaveGame()
    LobbySaveGame:SetCurPayAge(DataMgr.GetUserId(), InAge)
  end
  if IsExecuteINTLPayLogic then
    local TopupHandler = require("Protocol.Topup.TopupHandler")
    TopupHandler:RequestBuyMisdasProduct(TopupData.CurBuyProductId, TopupData.CurBuyQuantity)
  end
end

function TopupData:GetTopupAge()
  return TopupData.Age
end

return TopupData
