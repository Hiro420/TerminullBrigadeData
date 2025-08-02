local rapidjson = require("rapidjson")
local DrawCardViewModel = CreateDefaultViewModel()
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local DrawCardHandler = require("Protocol.DrawCard.DrawCardHandler")
local DrawCardData = require("Modules.DrawCard.DrawCardData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local DrawCardViewType = {
  DrawCardMain = 1,
  DrawCardOnce = 2,
  DrawCardMulti = 3,
  DrawCardPoolDetail = 4
}
local DrawCardPoolList = {}
DrawCardViewModel.propertyBindings = {
  CurCardPoolName = "\233\187\152\232\174\164\229\141\161\230\177\160\229\144\141",
  CurCardPoolOpenCount = 0,
  CurGuarantList = {},
  CurCardPoolEndTime = "2025-06-01 00:00:00",
  CurCardPoolBgPath = ""
}

function DrawCardViewModel:OnInit()
  self.Super:OnInit()
end

function DrawCardViewModel:OnShutdown()
  self.Super:OnShutdown()
end

function DrawCardViewModel:InitInfoByCardPoolId(CardPoolId)
  self.CardPoolId = CardPoolId
  local PoolInfo = self:GetPoolInfoByPoolId(CardPoolId)
  self.CurCardPoolName = PoolInfo.Name
  self.CurCardPoolOpenCount = self:GetCardPoolOpenCountById(CardPoolId)
  self.CurGuarantList = self:GetCardPoolGuarantListById(CardPoolId)
  self.CurCardPoolEndTime = PoolInfo.EndTime
  self.CurCardPoolBgPath = PoolInfo.BgPath
end

function DrawCardViewModel:ShowDrawCard()
  RGUIMgr:OpenUI(UIConfig.WBP_DrawCardView_C.UIName)
  local DardCardView = RGUIMgr:GetUI(UIConfig.WBP_DrawCardView_C.UIName)
  DardCardView:InitInfo(1)
end

function DrawCardViewModel:HideSelf()
  UIMgr:Hide(ViewID.UI_DrawCard, true)
  self.DrawWidget = nil
end

function DrawCardViewModel:GetHeroTableRow(ResourceId)
  local HeroTb = LuaTableMgr.GetLuaTableByName(TableNames.TBHero)
  if not HeroTb then
    return nil
  end
  return HeroTb[ResourceId]
end

function DrawCardViewModel:GetHeroArtResTableRow(IdParam)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicSettlement.GetHeroArtResTableRow not DTSubsystem")
    return nil
  end
  local Result, DTHeroArtRow = DTSubsystem:GetHeroArtResDataById(tonumber(IdParam), nil)
  if Result then
    return DTHeroArtRow
  end
  print("\233\133\141\231\189\174\229\188\130\229\184\184\239\188\140\232\175\165\231\173\137\231\186\167\229\156\168\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168", IdParam)
  return nil
end

function DrawCardViewModel:DrawCard(DrawTimes, PondId)
  if not self.DrawWidget then
    self.DrawWidget = RGUIMgr:GetUI(UIConfig.WBP_DrawCardView_C.UIName)
  end
  HttpCommunication.Request("mallservice/dogacha", {pondId = PondId, times = DrawTimes}, {
    self.DrawWidget,
    self.DrawWidget.DrawCardResult
  }, {
    self.DrawWidget,
    self.DrawWidget.DrawFailed
  })
end

function DrawCardViewModel:DrawCardResult(JsonResponse)
  local Response = rapidjson.decode(JsonResponse.Content)
  if not Response then
    return
  end
  if not self.DrawWidget then
    self.DrawWidget = RGUIMgr:GetUI(UIConfig.WBP_DrawCardView_C.UIName)
  end
  if 1 == #Response.Resources then
    self.DrawWidget:DrawResultOnce(Response.Resources[1])
  elseif #Response.Resources > 1 then
    self.DrawWidget:DrawResultMulti(Response.Resources)
  end
end

function DrawCardViewModel:DrawFailed()
end

function DrawCardViewModel:GetCost(Times, PondId)
  local GachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  for i, v in ipairs(GachaPondTable[PondId].ExpendResource) do
    return v.key, v.value * Times, self:CheckCost(Times, PondId)
  end
  return 0, 0, false
end

function DrawCardViewModel:GetCostIcon(CostResId)
  local GeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  return GeneralTable[CostResId].Icon
end

function DrawCardViewModel:GetPriceInfo(PoolId)
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  local PoolInfo = self:GetPoolInfoByPoolId(PoolId)
  local CostResId, CostNum = PoolInfo.ExpendResource[1].key, PoolInfo.ExpendResource[1].value
  local ResCurrencyId, ResOldPrice, ResCurPrice = 300001, 9999, 9999
  if TBMall[PoolInfo.GoodsId] then
    local GoodsInfo = TBMall[PoolInfo.GoodsId]
    ResCurrencyId = GoodsInfo.ConsumeResources[1].x
    ResOldPrice = GoodsInfo.ConsumeResources[1].y
    ResCurPrice = GoodsInfo.ConsumeResources[1].z
  end
  return CostResId, CostNum, ResCurrencyId, ResOldPrice, ResCurPrice
end

function DrawCardViewModel:GetPoolInfoByPoolId(PoolId)
  local GachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  local PoolId, PoolInfo = pairs(GachaPondTable[PoolId])
  return PoolInfo
end

function DrawCardViewModel:GetPoolInfo()
  local GachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  return GachaPondTable
end

function DrawCardViewModel:CheckCost(Times, PondId)
  local NeedCostNumTb = {}
  local GachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  if GachaPondTable and GachaPondTable[PondId] then
    for i, v in ipairs(GachaPondTable[PondId].ExpendResource) do
      local ResNum = DataMgr.GetPackbackNumById(v.key)
      local NeedNum = v.value
      if not NeedCostNumTb[v.key] then
        NeedCostNumTb[v.key] = 0
      end
      if NeedCostNumTb[v.key] then
        NeedNum = NeedNum + NeedCostNumTb[v.key]
        NeedCostNumTb[v.key] = NeedNum
      end
      NeedNum = NeedNum * Times
      if ResNum < NeedNum then
        return false
      end
    end
  end
  return true
end

function DrawCardViewModel:Clear()
  self:HideSelf()
end

function DrawCardViewModel:CheckResIsUnLock(ResourceId)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local TotalCharacterSkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  local TotalWeaponSkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBWeaponSkin)
  local SkinData = require("Modules.Appearance.Skin.SkinData")
  if 10 == TotalResourceTable[ResourceId].Type then
    return SkinData.FindHeroSkin(ResourceId)
  elseif 9 == TotalResourceTable[ResourceId].Type then
    return SkinData.FindWeaponSkin(ResourceId)
  elseif 14 == TotalResourceTable[ResourceId].Type then
    local TotalResFamilyTreasure = LuaTableMgr.GetLuaTableByName(TableNames.TBResFamilyTreasure)
    local HeirloomId
    HeirloomId = TotalResFamilyTreasure[ResourceId].FamilyTreasureID
    if nil ~= HeirloomId then
      local MaxUnLockHeirloomLevel = HeirloomData:GetMaxUnLockHeirloomLevel(HeirloomId)
      return MaxUnLockHeirloomLevel > 0
    end
  elseif 16 == TotalResourceTable[ResourceId].Type then
    return CommunicationData.CheckCommIsUnlock(ResourceId)
  elseif 19 == TotalResourceTable[ResourceId].Type then
    local PlayerInfoViewModel = UIModelMgr:Get("PlayerInfoViewModel")
    return PlayerInfoViewModel:GetHeadIconState(PlayerInfoViewModel:GetPortraitIdByResourceId(ResourceId)) ~= EPlayerInfoEquipedState.Lock
  elseif 20 == TotalResourceTable[ResourceId].Type then
    local PlayerInfoViewModel = UIModelMgr:Get("PlayerInfoViewModel")
    return PlayerInfoViewModel:GetBannerState(PlayerInfoViewModel:GetBannerIdByResourceId(ResourceId)) ~= EPlayerInfoEquipedState.Lock
  end
end

function DrawCardViewModel:SetCardPoolOpenCount(CardPoolId, OpenCount)
  DrawCardData:SetCardPoolOpenCount(CardPoolId, OpenCount)
end

function DrawCardViewModel:GetCardPoolOpenCountById(CardPoolId)
  return DrawCardData:GetCardPoolOpenCountById(CardPoolId)
end

function DrawCardViewModel:SetCardPoolGuarantList(CardPoolId, GuarantList)
  DrawCardData:SetCardPoolGuarantList(CardPoolId, GuarantList)
end

function DrawCardViewModel:GetCardPoolGuarantListById(CardPoolId)
  return DrawCardData:GetCardPoolGuarantListById(CardPoolId)
end

function DrawCardViewModel:GetGoodsIdByCardPoolId(CardPoolId)
  local GachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  return GachaPondTable[CardPoolId].GoodsId
end

function DrawCardViewModel:SortResourceList(ResourceList)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  table.sort(ResourceList, function(A, B)
    if not TotalResourceTable[A.resourceId] or not TotalResourceTable[B.resourceId] then
      return not TotalResourceTable[A.resourceId]
    end
    local ARare = TotalResourceTable[A.resourceId].Rare
    local BRare = TotalResourceTable[B.resourceId].Rare
    return ARare > BRare
  end)
end

return DrawCardViewModel
