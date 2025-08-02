local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local rapidjson = require("rapidjson")
local BattlePassData = require("Modules.BattlePass.BattlePassData")
local BattlePassBuyExpWaveWindow = Class(ViewBase)
local LevelDesc = NSLOCTEXT("BattlePassBuyExpWaveWindow", "LevelDesc", "\232\180\173\228\185\176\229\144\142\229\141\135\231\186\167\232\135\179{0}\231\186\167\239\188\140\229\143\175\233\162\134\229\143\150\228\187\165\228\184\139\229\165\150\229\138\177")

function BattlePassBuyExpWaveWindow:BindClickHandler()
  self.Btn_Reduce.OnClicked:Add(self, self.Btn_Reduce_OnClicked)
  self.Btn_Add.OnClicked:Add(self, self.Btn_Add_OnClicked)
  self.Btn_Max.OnClicked:Add(self, self.Btn_Max_OnClicked)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.OnEsc)
end

function BattlePassBuyExpWaveWindow:UnBindClickHandler()
  self.Btn_Reduce.OnClicked:Remove(self, self.Btn_Reduce_OnClicked)
  self.Btn_Add.OnClicked:Remove(self, self.Btn_Add_OnClicked)
  self.Btn_Max.OnClicked:Remove(self, self.Btn_Max_OnClicked)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.OnEsc)
end

function BattlePassBuyExpWaveWindow:InitWindow(BattlePassInfo, BattlePassID)
  self.BuyLevel = 1
  self.BattlePassInfo = BattlePassInfo
  self.BattlePassID = BattlePassID
  self.BattlePassActivateState = BattlePassInfo.battlePassActivateState
  self.AwardList = {}
  self.LevelUpExp = 0
  local BPAwardList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
  for i, AwardList in ipairs(BPAwardList) do
    if AwardList.BattlePassID == BattlePassID then
      table.insert(self.AwardList, AwardList)
    end
  end
  self.MaxLevel = #self.AwardList
  self.LevelUpExp = self.AwardList[2].Exp - self.AwardList[1].Exp
  self:InitCurrencyIcon()
  self:UpdateWindowInfo()
end

function BattlePassBuyExpWaveWindow:OnDestroy()
  self:UnBindClickHandler()
end

function BattlePassBuyExpWaveWindow:Construct()
  self:BindClickHandler()
end

function BattlePassBuyExpWaveWindow:Destruct()
  self:UnBindClickHandler()
end

function BattlePassBuyExpWaveWindow:OnPreHide()
  self:UnBindClickHandler()
end

function BattlePassBuyExpWaveWindow:OnHide()
  self:StopAllAnimations()
end

function BattlePassBuyExpWaveWindow:OnEsc()
  self:OnCancelClick()
end

function BattlePassBuyExpWaveWindow:Btn_Reduce_OnClicked()
  if 1 == self.BuyLevel then
    return
  end
  self.BuyLevel = self.BuyLevel - 1
  self:UpdateWindowInfo()
end

function BattlePassBuyExpWaveWindow:Btn_Add_OnClicked()
  if self.BuyLevel + tonumber(self.BattlePassInfo.level) == self.MaxLevel then
    return
  end
  self.BuyLevel = self.BuyLevel + 1
  self:UpdateWindowInfo()
end

function BattlePassBuyExpWaveWindow:Btn_Max_OnClicked()
  self.BuyLevel = self.MaxLevel - tonumber(self.BattlePassInfo.level)
  self:UpdateWindowInfo()
end

function BattlePassBuyExpWaveWindow:UpdateWindowInfo()
  self.Txt_ChooseLevel:SetText(self.BuyLevel)
  self.Txt_Desc:SetText(tonumber(self.BattlePassInfo.level) + self.BuyLevel)
  local curLevel = tonumber(self.BattlePassInfo.level)
  local showAwardList = {}
  for i = curLevel + 1, curLevel + self.BuyLevel do
    for index, AwardInfo in ipairs(self.AwardList[i].NormalReward) do
      table.insert(showAwardList, {
        AwardID = AwardInfo.key,
        Num = AwardInfo.value
      })
    end
    if self.BattlePassActivateState > 0 then
      for index, AwardInfo in ipairs(self.AwardList[i].PremiumReward) do
        table.insert(showAwardList, {
          AwardID = AwardInfo.key,
          Num = AwardInfo.value
        })
      end
    end
  end
  local showList = BattlePassData:MergeAwardList(showAwardList)
  local showAward = {}
  self.ScrollBox_ShowAward:ClearChildren()
  for i, v in pairs(showList) do
    local awardItem = GetOrCreateItem(self.ScrollBox_ShowAward, #showAward + 1, self.WBP_BattlePassSmallItem:GetClass())
    awardItem:InitItem(i, v)
    table.insert(showAward, awardItem)
  end
  self:UpdateCurrencyNum()
end

function BattlePassBuyExpWaveWindow:UpdateCurrencyNum()
  self.Txt_CurrencyNum:SetText(self.ConsumeNum * self.BuyLevel)
  self.IsNotEnoughMoney = self.ConsumeNum * self.BuyLevel > self.CurrencyNum
  self.WBP_Price:SetPrice(self.ConsumeNum * self.BuyLevel, nil, self.ConsumeResourcesID)
  UpdateVisibility(self.Overlay_Enable, self.IsNotEnoughMoney)
end

function BattlePassBuyExpWaveWindow:InitCurrencyIcon()
  local result, expGoodsInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattlePass, self.BattlePassID)
  if result then
    self.battlePassGoodsID = expGoodsInfo.BattlePassGoodsID
  end
  local result, expGoodsInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMall, self.battlePassGoodsID)
  if result then
    self.ConsumeNum = expGoodsInfo.ConsumeNum
    self.CurrencyNum = LogicOutsidePackback.GetResourceNumById(expGoodsInfo.ConsumeResourcesID)
    self.ConsumeResourcesID = expGoodsInfo.ConsumeResourcesID
    self.ShelfsId = expGoodsInfo.Shelfs[1]
    local RowInfo = LogicOutsidePackback.GetResourceInfoById(expGoodsInfo.ConsumeResourcesID)
    if not RowInfo then
      print("Invalid Currency Num")
      return
    end
  end
end

return BattlePassBuyExpWaveWindow
