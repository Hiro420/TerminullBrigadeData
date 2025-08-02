local rapidjson = require("rapidjson")
local RedDotData = require("Modules.RedDot.RedDotData")
Logic_Mall = Logic_Mall or {
  ExteriorInfo = {},
  RechargeInfo = nil,
  PropsInfo = {},
  BundleInfo = {}
}
local ViewTemplateId = {
  BundleTemplate = 1,
  ExterirorTemplate = 2,
  PropsTemplate = 3
}
local EnumSalesStatus = {
  Error = 0,
  OnSale = 1,
  AlreadyOwned = 2,
  SoldOut = 3,
  NotOnSale = 4,
  OffShelf = 5,
  LimitedTimeOnSale = 6
}
_G.EnumSalesStatus = _G.EnumSalesStatus or EnumSalesStatus

function Logic_Mall.JumpToMall(GoodId, Callback)
  local GoodInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[GoodId]
  if nil == GoodInfo then
    print("Not Find GoodInfo In TBMall.GoodId Is:", GoodId)
    return
  end
  if 1 == GoodInfo.Shelfs[1] then
    local BundleViewContentModel = UIModelMgr:Get("BundleViewContentModel")
    if BundleViewContentModel then
      local GainResourcesID = GoodInfo.GainResourcesID
      if 2 == GoodInfo.ShelfsShowType then
        UIMgr:Show(ViewID.UI_Mall_PurchaseConfirm, true, GoodId, 1)
        return
      end
      BundleViewContentModel:ShowBundleContent(GainResourcesID, GoodId)
    end
  end
end

function Logic_Mall.PushRechargeInfo(bForce)
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(1) then
    return
  end
  if Logic_Mall.RechargeInfo and not bForce then
    EventSystem.Invoke(EventDef.Mall.OnGetRechargeInfo, Logic_Mall.RechargeInfo)
    return
  end
  HttpCommunication.RequestByGet("mallservice/getmallinfo?shelfID=4", {
    GameInstance,
    function(self, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      Logic_Mall.RechargeInfo = JsonTable.shelfs[1].goodsInfos
      EventSystem.Invoke(EventDef.Mall.OnGetRechargeInfo, JsonTable.shelfs[1].goodsInfos)
    end
  }, {
    GameInstance,
    function(self, JsonResponse)
    end
  })
end

function Logic_Mall.GetRechargeInfo()
  if Logic_Mall.RechargeInfo ~= nil then
    return Logic_Mall.RechargeInfo
  end
  return nil
end

function Logic_Mall.PushExteriorInfo(bForce, ShelfIndex)
  if (Logic_Mall.ExteriorInfo[ShelfIndex] == nil or bForce) and nil ~= ShelfIndex then
    Logic_Mall.PushSingleExteriorInfo(bForce, ShelfIndex)
    return
  end
  if nil ~= ShelfIndex then
    EventSystem.Invoke(EventDef.Mall.OnGetExteriorInfo, Logic_Mall.ExteriorInfo)
    return
  end
  if nil == ShelfIndex then
    if bForce then
      local tbMallShelf = LuaTableMgr.GetLuaTableByName(TableNames.TBMallShelf)
      for i, v in pairs(tbMallShelf) do
        if v.TemplateId == ViewTemplateId.ExterirorTemplate then
          Logic_Mall.PushSingleExteriorInfo(bForce, i)
        end
      end
    else
      local tbMallShelf = LuaTableMgr.GetLuaTableByName(TableNames.TBMallShelf)
      for i, v in pairs(tbMallShelf) do
        if v.TemplateId == ViewTemplateId.ExterirorTemplate and Logic_Mall.ExteriorInfo[i] == nil then
          Logic_Mall.PushSingleExteriorInfo(bForce, i)
        end
      end
      EventSystem.Invoke(EventDef.Mall.OnGetExteriorInfo, Logic_Mall.ExteriorInfo)
    end
  end
end

function Logic_Mall.PushSingleExteriorInfo(bForce, ShelfIndex)
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(1) then
    return
  end
  HttpCommunication.RequestByGet("mallservice/getmallinfo?shelfID=" .. ShelfIndex, {
    GameInstance,
    function(self, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if JsonTable.shelfs[1].goodsInfos ~= nil then
        Logic_Mall.ExteriorInfo[ShelfIndex] = JsonTable.shelfs[1].goodsInfos
        local row = LogicLobby.ShelfIndexToLabelTagNameList[ShelfIndex]
        if row then
          for index, value in ipairs(Logic_Mall.ExteriorInfo[ShelfIndex]) do
            local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
            if nil == TBMall[value.GoodsID] then
              return
            end
            local bNew = TBMall[value.GoodsID].IsNew
            local ResourcesID = TBMall[value.GoodsID].GainResourcesID
            local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
            local Type = TBGeneral[ResourcesID].Type
            for index, TabId in ipairs(TBMall[value.GoodsID].TapList) do
              local IsNewCreateParent = RedDotData:CreateRedDotState("All_RoleSkin_" .. ShelfIndex .. "_" .. TabId, "All_RoleSkin")
              local RedDotStateParent = {}
              RedDotStateParent.ParentIdList = {row}
              RedDotData:UpdateRedDotState("All_RoleSkin_" .. ShelfIndex .. "_" .. TabId, RedDotStateParent)
            end
            local IsNewCreate = RedDotData:CreateRedDotState("All_RoleSkin_Item_" .. value.GoodsID, "All_RoleSkin_Item")
            local RedDotState = {}
            if IsNewCreate and bNew then
              RedDotState.Num = 1
            end
            RedDotState.ParentIdList = {}
            for index, TabId in ipairs(TBMall[value.GoodsID].TapList) do
              RedDotState.ParentIdList[index] = "All_RoleSkin_" .. ShelfIndex .. "_" .. TabId
            end
            RedDotData:UpdateRedDotState("All_RoleSkin_Item_" .. value.GoodsID, RedDotState)
          end
        end
        EventSystem.Invoke(EventDef.Mall.OnGetExteriorInfo, Logic_Mall.ExteriorInfo)
      end
    end
  }, {
    GameInstance,
    function(self, JsonResponse)
    end
  })
end

function Logic_Mall.GetExteriorInfo()
  if Logic_Mall.ExteriorInfo ~= nil then
    return Logic_Mall.ExteriorInfo
  end
  return nil
end

function Logic_Mall.PushBundleInfo(bForce, ShelfIndex)
  if (Logic_Mall.BundleInfo[ShelfIndex] == nil or bForce) and nil ~= ShelfIndex then
    Logic_Mall.PushSingleBundleInfo(bForce, ShelfIndex)
    return
  end
  if nil ~= ShelfIndex then
    EventSystem.Invoke(EventDef.Mall.OnGetBundleInfo, Logic_Mall.BundleInfo)
    return
  end
  if nil == ShelfIndex then
    if bForce then
      local tbMallShelf = LuaTableMgr.GetLuaTableByName(TableNames.TBMallShelf)
      for i, v in pairs(tbMallShelf) do
        if v.TemplateId == ViewTemplateId.BundleTemplate then
          Logic_Mall.PushSingleBundleInfo(bForce, i)
        end
      end
    else
      local tbMallShelf = LuaTableMgr.GetLuaTableByName(TableNames.TBMallShelf)
      for i, v in pairs(tbMallShelf) do
        if v.TemplateId == ViewTemplateId.BundleTemplate and Logic_Mall.BundleInfo[i] == nil then
          Logic_Mall.PushSingleBundleInfo(bForce, i)
        end
      end
      EventSystem.Invoke(EventDef.Mall.OnGetBundleInfo, Logic_Mall.BundleInfo)
    end
  end
end

function Logic_Mall.PushSingleBundleInfo(bForce, ShelfIndex)
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(1) then
    return
  end
  HttpCommunication.RequestByGet("mallservice/getmallinfo?shelfID=" .. ShelfIndex, {
    GameInstance,
    function(self, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      Logic_Mall.BundleInfo[ShelfIndex] = JsonTable.shelfs[1].goodsInfos
      local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
      local row = LogicLobby.ShelfIndexToLabelTagNameList[ShelfIndex]
      if row then
        for index, value in ipairs(Logic_Mall.BundleInfo[ShelfIndex]) do
          local bNew = TBMall[value.GoodsID].IsNew
          local IsNewCreate = RedDotData:CreateRedDotState("Bundle_SingleItem_" .. value.GoodsID, "Bundle_SingleItem")
          local RedDotState = {}
          if IsNewCreate and bNew then
            RedDotState.Num = 1
          end
          RedDotState.ParentIdList = {row}
          RedDotData:UpdateRedDotState("Bundle_SingleItem_" .. value.GoodsID, RedDotState)
        end
      end
      EventSystem.Invoke(EventDef.Mall.OnGetBundleInfo, Logic_Mall.BundleInfo)
    end
  }, {
    GameInstance,
    function(self, JsonResponse)
    end
  })
end

function Logic_Mall.GetBundleInfo()
  if Logic_Mall.BundleInfo ~= nil then
    return Logic_Mall.BundleInfo
  end
  return nil
end

function Logic_Mall.PushPropsInfo(bForce, ShelfIndex)
  if (Logic_Mall.PropsInfo[ShelfIndex] == nil or bForce) and nil ~= ShelfIndex then
    Logic_Mall.PushSinglePropsInfo(bForce, ShelfIndex)
    return
  end
  if nil ~= ShelfIndex then
    EventSystem.Invoke(EventDef.Mall.OnGetPropsInfo, Logic_Mall.PropsInfo)
    return
  end
  if nil == ShelfIndex then
    if bForce then
      local tbMallShelf = LuaTableMgr.GetLuaTableByName(TableNames.TBMallShelf)
      for i, v in pairs(tbMallShelf) do
        if v.TemplateId == ViewTemplateId.PropsTemplate then
          Logic_Mall.PushSinglePropsInfo(bForce, i)
        end
      end
    else
      local tbMallShelf = LuaTableMgr.GetLuaTableByName(TableNames.TBMallShelf)
      for i, v in pairs(tbMallShelf) do
        if v.TemplateId == ViewTemplateId.PropsTemplate and Logic_Mall.PropsInfo[i] == nil then
          Logic_Mall.PushSinglePropsInfo(bForce, i)
        end
      end
      EventSystem.Invoke(EventDef.Mall.OnGetPropsInfo, Logic_Mall.PropsInfo)
    end
  end
end

function Logic_Mall.PushSinglePropsInfo(bForce, ShelfIndex)
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(1) then
    return
  end
  HttpCommunication.RequestByGet("mallservice/getmallinfo?shelfID=" .. ShelfIndex, {
    GameInstance,
    function(self, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      Logic_Mall.PropsInfo[ShelfIndex] = JsonTable.shelfs[1].goodsInfos
      local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
      local row = LogicLobby.ShelfIndexToLabelTagNameList[ShelfIndex]
      if row then
        for index, value in ipairs(Logic_Mall.PropsInfo[ShelfIndex]) do
          local bNew = TBMall[value.GoodsID].IsNew
          local IsNewCreate = RedDotData:CreateRedDotState("Props_" .. value.GoodsID, "Props")
          local RedDotState = {}
          if IsNewCreate and Logic_Mall.OnShowTime(value.showStartTime, value.showEndTime) and bNew then
            RedDotState.Num = 1
          end
          RedDotState.ParentIdList = {row}
          RedDotData:UpdateRedDotState("Props_" .. value.GoodsID, RedDotState)
          if not Logic_Mall.OnShowTime(value.showStartTime, value.showEndTime) then
            RedDotData:DeleteRedDotState("Props_" .. value.GoodsID)
          end
        end
      end
      EventSystem.Invoke(EventDef.Mall.OnGetPropsInfo, Logic_Mall.PropsInfo)
    end
  }, {
    GameInstance,
    function(self, JsonResponse)
    end
  })
end

function Logic_Mall.GetPropsInfo()
  if Logic_Mall.PropsInfo ~= nil then
    return Logic_Mall.PropsInfo
  end
  return nil
end

function Logic_Mall.IsSoldOut(GoodsId)
  local GoodInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[GoodsId]
  if nil == GoodInfo then
    print("Not Find GoodInfo In TBMall.GoodId Is:", GoodsId)
    return
  end
end

function Logic_Mall.RecordData(SelectNum, GoodsId, shelfID)
  if nil == shelfID then
    return
  end
  local TargetTable
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMallShelf, shelfID)
  if result then
    if row.TemplateId == ViewTemplateId.BundleTemplate then
      TargetTable = Logic_Mall.BundleInfo[shelfID]
    elseif row.TemplateId == ViewTemplateId.ExterirorTemplate then
      TargetTable = Logic_Mall.ExteriorInfo[shelfID]
    elseif row.TemplateId == ViewTemplateId.PropsTemplate then
      TargetTable = Logic_Mall.PropsInfo[shelfID]
    end
  end
  if 4 == shelfID then
    TargetTable = Logic_Mall.RechargeInfo
  end
  if nil == TargetTable then
    return
  end
  for index, value in ipairs(TargetTable) do
    if value.GoodsID == GoodsId then
      value.Amount = value.Amount + SelectNum
      local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
      if TBMall[value.GoodsID] then
        local GoodsInfo = TBMall[value.GoodsID]
        value.buyLimitForAlreadyOwned = GoodsInfo.AleardyOwnedLimit >= value.Amount
      end
    end
  end
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMallShelf, shelfID)
  if result then
    if row.TemplateId == ViewTemplateId.BundleTemplate then
      Logic_Mall.BundleInfo[shelfID] = TargetTable
    elseif row.TemplateId == ViewTemplateId.ExterirorTemplate then
      Logic_Mall.ExteriorInfo[shelfID] = TargetTable
    elseif row.TemplateId == ViewTemplateId.PropsTemplate then
      Logic_Mall.PropsInfo[shelfID] = TargetTable
    end
  end
  if 4 == shelfID then
    Logic_Mall.RechargeInfo = TargetTable
  end
end

function Logic_Mall.OnShowTime(ShowStartTime, ShowEndTime)
  local CurTimeTemp = os.time()
  print(tonumber(ShowStartTime), tonumber(CurTimeTemp), tonumber(ShowEndTime))
  return tonumber(ShowStartTime) <= tonumber(CurTimeTemp) and tonumber(CurTimeTemp) <= tonumber(ShowEndTime)
end

function Logic_Mall.GetDetailRowDataByResourceId(ResourcesID)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TBGeneral[ResourcesID] then
    return nil
  end
  local Type = TBGeneral[ResourcesID].Type
  local TableName
  if 9 == Type then
    TableName = TableNames.TBWeaponSkin
  elseif 10 == Type then
    TableName = TableNames.TBCharacterSkin
  elseif 16 == Type then
    TableName = TableNames.TBResHeroCommuniRoulette
  elseif 20 == Type then
    TableName = TableNames.TBBanner
  elseif 19 == Type then
    TableName = TableNames.TBPortrait
  elseif Type == TableEnums.ENUMResourceType.HERO then
    TableName = TableNames.TBHero
  elseif Type == TableEnums.ENUMResourceType.Weapon then
    TableName = TableNames.TBWeapon
  end
  if TableName then
    return LuaTableMgr.GetLuaTableByName(TableName)[ResourcesID]
  end
  return nil
end

function Logic_Mall.GetGoodsSalesStatus(GoodsInfo)
  if nil == GoodsInfo then
    return EnumSalesStatus.Error
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  local TBMallInfo = TBMall[GoodsInfo.GoodsID]
  if not TBMallInfo then
    return EnumSalesStatus.Error
  end
  if GoodsInfo.BuyLimitForAlreadyOwned then
    return EnumSalesStatus.AlreadyOwned
  end
  if GoodsInfo.Amount >= TBMallInfo.BuyLimit and 0 ~= TBMallInfo.BuyLimit then
    return EnumSalesStatus.SoldOut
  end
  local CurTimeTemp = tonumber(os.time())
  if CurTimeTemp < GoodsInfo.StartTime then
    return EnumSalesStatus.NotOnSale
  end
  if CurTimeTemp > GoodsInfo.EndTime then
    return EnumSalesStatus.OffShelf
  end
  if TBMallInfo.IsCountDown and Logic_Mall.OnShowTime(GoodsInfo.StartTime, GoodsInfo.EndTime) then
    return EnumSalesStatus.LimitedTimeOnSale
  end
  return EnumSalesStatus.OnSale
end
