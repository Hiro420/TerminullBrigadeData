local TopupData = require("Modules.Topup.TopupData")
local EBattlePassActivateState = {
  Normal = 0,
  Premium = 1,
  Ultra = 2
}
_G.EBattlePassActivateState = _G.EBattlePassActivateState or EBattlePassActivateState
local AwardState = {
  Lock = 0,
  UnLock = 1,
  ReceiveNormal = 2,
  ReceivePremiun = 3
}
_G.AwardState = _G.AwardState or AwardState
local BattlePassData = {
  OldBattlePasData = {},
  CurBattlePassID = 1
}
function BattlePassData:UpdateInfo(BattlePassInfo, BattlePassID)
  if nil == BattlePassData[BattlePassID] then
    BattlePassData[BattlePassID] = BattlePassInfo
  else
    if BattlePassData[BattlePassID].exp ~= BattlePassInfo.exp then
      BattlePassData[BattlePassID].IsUpgrade = true
      BattlePassData.OldBattlePasData[BattlePassID] = DeepCopy(BattlePassData[BattlePassID])
    end
    BattlePassData[BattlePassID].exp = BattlePassInfo.exp
    BattlePassData[BattlePassID].battlePassData = BattlePassInfo.battlePassData
    BattlePassData[BattlePassID].battlePassActivateState = BattlePassInfo.battlePassActivateState
    BattlePassData[BattlePassID].level = BattlePassInfo.level
  end
  BattlePassData.CurBattlePassID = BattlePassID
end
function BattlePassData:MergeAwardList(AwardList)
  local newAwardList = {}
  for i, v in ipairs(AwardList) do
    if newAwardList[v.AwardID] then
      newAwardList[v.AwardID] = newAwardList[v.AwardID] + v.Num
    else
      newAwardList[v.AwardID] = v.Num
    end
  end
  return newAwardList
end
function BattlePassData:GetBattlePassPriceById(BattlePassID, BattlePassState)
  if nil == BattlePassData[BattlePassID] then
    print("\233\128\154\232\161\140\232\175\129id\233\148\153\232\175\175\239\188\129 id\228\184\186", BattlePassID)
    return "", ""
  end
  local BattlePassInfo = self:GetBattlePassRowInfoById(BattlePassID)
  if nil == BattlePassInfo then
    print("TBBattlePass\228\184\173\230\156\170\229\143\145\231\142\176id:", BattlePassID)
    return "", ""
  end
  local CurProductId = self:GetBattlePassProductIdById(BattlePassID, BattlePassState)
  local OriginalProductId = ""
  if BattlePassState == EBattlePassActivateState.Premium then
    OriginalProductId = BattlePassInfo.PremiumUnlockResourceID
  elseif BattlePassState == EBattlePassActivateState.Ultra then
    OriginalProductId = BattlePassInfo.UltraUnlockResourceID
  end
  local CurMallProductId = TopupData:GetProductIdByResourceId(CurProductId)
  local CurPrice = TopupData:GetProductDisplayPrice(CurMallProductId)
  local OriginalMallProductId = TopupData:GetProductIdByResourceId(OriginalProductId)
  local OriginalPrice = TopupData:GetProductDisplayPrice(OriginalMallProductId)
  return CurPrice, OriginalPrice
end
function BattlePassData:GetBattlePassProductIdById(BattlePassID, BattlePassState)
  if nil == BattlePassData[BattlePassID] then
    print("\233\128\154\232\161\140\232\175\129id\233\148\153\232\175\175\239\188\129 id\228\184\186", BattlePassID)
    return "", ""
  end
  local CurBattlePassState = BattlePassData[BattlePassID].battlePassActivateState
  local BattlePassInfo = self:GetBattlePassRowInfoById(BattlePassID)
  if nil == BattlePassInfo then
    print("TBBattlePass\228\184\173\230\156\170\229\143\145\231\142\176id:", BattlePassID)
    return "", ""
  end
  if BattlePassState == EBattlePassActivateState.Premium then
    return BattlePassInfo.PremiumUnlockResourceID
  elseif BattlePassState == EBattlePassActivateState.Ultra then
    if CurBattlePassState == EBattlePassActivateState.Premium then
      return BattlePassInfo.PremiumToUltraResourceID
    else
      return BattlePassInfo.UltraUnlockResourceID
    end
  end
end
function BattlePassData:GetBattlePassRowInfoById(BattlePassID)
  local TBBattlePass = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePass)
  if TBBattlePass then
    for i, v in ipairs(TBBattlePass) do
      if v.BattlePassID == BattlePassID then
        return v
      end
    end
  end
  return nil
end
function BattlePassData:GetBattlePassMaxLevel(BattlePassID)
  local BPAwardList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
  local count = 0
  for i, v in ipairs(BPAwardList) do
    if v.BattlePassID == BattlePassID then
      count = count + 1
    end
  end
  return count
end
return BattlePassData
