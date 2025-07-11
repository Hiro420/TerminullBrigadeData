local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local BattlePassData = require("Modules.BattlePass.BattlePassData")
local BattlePasshandler = {}
function BattlePasshandler:SendBattlePassData(BattlePassID)
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.PASS, false) then
    return
  end
  local url = "playergrowth/battlepass/data?battlePassID=" .. BattlePassID
  HttpCommunication.RequestByGet(url, {
    GameInstance,
    function(Target, JsonResponse)
      print("SendBattlePassData Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      BattlePassData:UpdateInfo(JsonTable, BattlePassID)
      EventSystem.Invoke(EventDef.BattlePass.GetBattlePassData, JsonTable, BattlePassID)
    end
  }, {
    GameInstance,
    function()
      print("SendBattlePassData fail!")
    end
  })
end
function BattlePasshandler:SendUnLockUltra(BattlePassID, UnLockType, SuccFun)
  if BattlePassData[BattlePassID] and UnLockType <= BattlePassData[BattlePassID].battlePassActivateState then
    return
  end
  local url = "dbg/playergrowth/battlepass/unlockultra"
  HttpCommunication.Request(url, {battlePassID = BattlePassID, unlockType = UnLockType}, {
    GameInstance,
    function(Target, JsonResponse)
      EventSystem.Invoke(EventDef.BattlePass.UnlockUltra, BattlePassID, UnLockType)
      if SuccFun then
        SuccFun(BattlePassID, UnLockType)
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function BattlePasshandler:SendReceiveAllReward(BattlePassID)
  local OnConfirmClick = function(optionalGiftInfos)
    if optionalGiftInfos then
      if self.OptionalGiftInfos == nil then
        self.OptionalGiftInfos = {}
      end
      for index, GiftInfo in ipairs(optionalGiftInfos) do
        table.insert(self.OptionalGiftInfos, GiftInfo)
      end
    end
    if self.OptionalGiftInfos ~= nil and 0 == #self.OptionalGiftInfos then
      self.OptionalGiftInfos = nil
    end
    local url = "playergrowth/battlepass/receiveallreward"
    HttpCommunication.Request(url, {
      battlePassID = BattlePassID,
      optionalGiftInfos = self.OptionalGiftInfos
    }, {
      GameInstance,
      function(Target, JsonResponse)
        local JsonTable = rapidjson.decode(JsonResponse.Content)
        EventSystem.Invoke(EventDef.BattlePass.ReceiveAllReward, BattlePassID, JsonTable)
      end
    }, {
      GameInstance,
      function()
      end
    })
  end
  local function ShowOptionalGiftQueueWindow(optionalGiftInfos)
    if optionalGiftInfos then
      if self.OptionalGiftInfos == nil then
        self.OptionalGiftInfos = {}
      end
      for index, GiftInfo in ipairs(optionalGiftInfos) do
        table.insert(self.OptionalGiftInfos, GiftInfo)
      end
    end
    for key, value in pairs(self.OptionalGiftIdTable) do
      local Table = {}
      Table[key] = value
      if table.count(self.OptionalGiftIdTable) > 1 then
        ShowOptionalGiftWindow(Table, nil, _G.EOptionalGiftType.BPass, ShowOptionalGiftQueueWindow)
      else
        ShowOptionalGiftWindow(Table, nil, _G.EOptionalGiftType.BPass, OnConfirmClick)
      end
      self.OptionalGiftIdTable[key] = nil
      break
    end
  end
  local AwardTable = self:GetAvailableRewards(BattlePassID)
  self.OptionalGiftIdTable = {}
  for ItemId, Num in pairs(AwardTable) do
    if self:IsOptional(ItemId) then
      self.OptionalGiftIdTable[ItemId] = Num
    end
  end
  if table.count(self.OptionalGiftIdTable) > 0 then
    ShowOptionalGiftQueueWindow()
  else
    OnConfirmClick()
  end
end
function BattlePasshandler:SendReceiveAward(BattlePassID, Level)
  if Level > tonumber(BattlePassData[BattlePassID].level) then
    return
  end
  local OnConfirmClick = function(optionalGiftInfos)
    if optionalGiftInfos then
      if self.OptionalGiftInfos == nil then
        self.OptionalGiftInfos = {}
      end
      for index, GiftInfo in ipairs(optionalGiftInfos) do
        table.insert(self.OptionalGiftInfos, GiftInfo)
      end
    end
    if self.OptionalGiftInfos ~= nil and 0 == #self.OptionalGiftInfos then
      self.OptionalGiftInfos = nil
    end
    local url = "playergrowth/battlepass/receivereward"
    HttpCommunication.Request(url, {
      battlePassID = BattlePassID,
      level = Level,
      optionalGiftInfos = self.OptionalGiftInfos
    }, {
      GameInstance,
      function(Target, JsonResponse)
        local JsonTable = rapidjson.decode(JsonResponse.Content)
        EventSystem.Invoke(EventDef.BattlePass.ReceiveReward, Level, JsonTable)
        self.OptionalGiftInfos = {}
      end
    }, {
      GameInstance,
      function()
      end
    })
  end
  local function ShowOptionalGiftQueueWindow(optionalGiftInfos)
    if optionalGiftInfos then
      if self.OptionalGiftInfos == nil then
        self.OptionalGiftInfos = {}
      end
      for index, GiftInfo in ipairs(optionalGiftInfos) do
        table.insert(self.OptionalGiftInfos, GiftInfo)
      end
    end
    for key, value in pairs(self.OptionalGiftIdTable) do
      local Table = {}
      Table[key] = value
      if table.count(self.OptionalGiftIdTable) > 1 then
        ShowOptionalGiftWindow(Table, nil, _G.EOptionalGiftType.BPass, ShowOptionalGiftQueueWindow)
      else
        ShowOptionalGiftWindow(Table, nil, _G.EOptionalGiftType.BPass, OnConfirmClick)
      end
      self.OptionalGiftIdTable[key] = nil
      break
    end
  end
  local AwardTable = self:GetAvailableRewards(BattlePassID, Level)
  self.OptionalGiftIdTable = {}
  for ItemId, Num in pairs(AwardTable) do
    if self:IsOptional(ItemId) then
      self.OptionalGiftIdTable[ItemId] = Num
    end
  end
  if table.count(self.OptionalGiftIdTable) > 0 then
    ShowOptionalGiftQueueWindow()
  else
    OnConfirmClick()
  end
end
function BattlePasshandler:IsOptional(ItemId)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TBGeneral[ItemId] then
    return TBGeneral[ItemId].Type == TableEnums.ENUMResourceType.OptionalGift
  end
  return false
end
function BattlePasshandler:ReceiveOptionalAward()
end
function BattlePasshandler:GetAvailableRewards(BattlePassID, Level)
  local BPAwardList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
  local RewardTable = {}
  for i, v in ipairs(BPAwardList) do
    local RewardState = BattlePassData[BattlePassID].battlePassData[tostring(v.BattlePassLevel)]
    if nil == RewardState or RewardState == AwardState.Lock or RewardState >= AwardState.ReceivePremiun then
      break
    end
    if nil ~= Level then
      if v.BattlePassID == BattlePassID and Level == v.BattlePassLevel then
        RewardTable[Level] = v
        break
      end
    elseif v.BattlePassID == BattlePassID then
      RewardTable[v.BattlePassLevel] = v
    end
  end
  local AvailableRewards = {}
  local bNormalReward = BattlePassData[BattlePassID].battlePassActivateState == EBattlePassActivateState.Normal
  for Level, RowInfo in pairs(RewardTable) do
    local RewardState = BattlePassData[BattlePassID].battlePassData[tostring(Level)]
    if bNormalReward then
      if RewardState == AwardState.UnLock then
        for index, NormalReward in ipairs(RowInfo.NormalReward) do
          self:AddRewardsInTable(AvailableRewards, NormalReward.key, NormalReward.value)
        end
      end
    elseif RewardState == AwardState.UnLock then
      for index, NormalReward in ipairs(RowInfo.NormalReward) do
        self:AddRewardsInTable(AvailableRewards, NormalReward.key, NormalReward.value)
      end
      for index, PremiumReward in ipairs(RowInfo.PremiumReward) do
        self:AddRewardsInTable(AvailableRewards, PremiumReward.key, PremiumReward.value)
      end
    elseif RewardState == AwardState.ReceiveNormal then
      for index, PremiumReward in ipairs(RowInfo.PremiumReward) do
        self:AddRewardsInTable(AvailableRewards, PremiumReward.key, PremiumReward.value)
      end
    end
  end
  return AvailableRewards
end
function BattlePasshandler:AddRewardsInTable(Table, ItemId, Num)
  if Table[ItemId] then
    Table[ItemId] = Table[ItemId] + Num
  else
    Table[ItemId] = Num
  end
end
return BattlePasshandler
