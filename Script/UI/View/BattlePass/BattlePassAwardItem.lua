local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local battlepassdata = require("Modules.BattlePass.BattlePassData")
local BattlePassAwardItem = Class(ViewBase)
local AwardState = {
  Lock = 0,
  UnLock = 1,
  ReceiveNormal = 2,
  ReceivePremiun = 3
}
local BattlePassState = {
  Normal = 0,
  Premiun = 1,
  Ultra = 2
}
function BattlePassAwardItem:BindClickHandler()
end
function BattlePassAwardItem:UnBindClickHandler()
end
function BattlePassAwardItem:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function BattlePassAwardItem:OnDestroy()
end
function BattlePassAwardItem:Construct()
  EventSystem.AddListenerNew(EventDef.BattlePass.OnUpgrade, self, self.BindOnUpgrade)
end
function BattlePassAwardItem:Destruct()
  EventSystem.RemoveListener(EventDef.BattlePass.OnUpgrade, self.BindOnUpgrade, self)
end
function BattlePassAwardItem:OnPreHide()
end
function BattlePassAwardItem:OnListItemObjectSet(ListItemObj)
  local Level = ListItemObj.Level
  local ParentView = ListItemObj.ParentView
  local NormalAward = ParentView.AwardListInfo[Level].NormalAward
  local PremiumAward = ParentView.AwardListInfo[Level].PremiumAward
  local State = ListItemObj.State
  local IsNormal = ListItemObj.IsNormal
  self:InitItem(NormalAward, PremiumAward, Level, ParentView, State, IsNormal)
end
function BattlePassAwardItem:InitItem(NormalAward, PremiumAward, Level, ParentView, State, IsNormal)
  self.ParentView = ParentView
  self.Level = Level
  self.NormalAward = NormalAward
  self.PremiumAward = PremiumAward
  self.Items = {}
  self.IsNormal = IsNormal
  local normalItems = {}
  local premiumItems = {}
  local ChildIndex = 1
  for i, v in ipairs(NormalAward) do
    local normalItem = GetOrCreateItem(self.VBox_Normal, i, self.WBP_BattlePassSmallItem:GetClass())
    normalItem:InitItem(v.key, v.value, ParentView, Level, false, ChildIndex)
    normalItem:SetState(State, IsNormal)
    if self.ParentView.SelectGroup.SelectLevel == Level and self.ParentView.SelectGroup.SelectIndex == ChildIndex then
      normalItem.WBP_Item:SetSel(true)
    else
      normalItem.WBP_Item:SetSel(false)
    end
    ChildIndex = ChildIndex + 1
    table.insert(normalItems, normalItem)
  end
  self.Items.NormalItems = normalItems
  HideOtherItem(self.VBox_Normal, #NormalAward + 1)
  for i, v in ipairs(PremiumAward) do
    local PremiumItem = GetOrCreateItem(self.VBox_Premium, i, self.WBP_BattlePassSmallItem_2:GetClass())
    PremiumItem:InitItem(v.key, v.value, ParentView, Level, true, ChildIndex)
    PremiumItem:SetState(State, IsNormal)
    if self.ParentView.SelectGroup.SelectLevel == Level and self.ParentView.SelectGroup.SelectIndex == ChildIndex then
      PremiumItem.WBP_Item:SetSel(true)
    else
      PremiumItem.WBP_Item:SetSel(false)
    end
    ChildIndex = ChildIndex + 1
    table.insert(premiumItems, PremiumItem)
  end
  self.Items.PremiumItems = premiumItems
  HideOtherItem(self.VBox_Premium, #PremiumAward + 1)
  self.TXT_Level:SetText(Level)
  if tonumber(Level) > tonumber(ParentView.BattlePassInfo.level) then
    self.RGStateController_Lock:ChangeStatus("Lock")
  elseif ParentView.BattlePassInfo.battlePassActivateState == BattlePassState.Normal then
    self.RGStateController_Lock:ChangeStatus("Lock")
  else
    local LevelState = ParentView.BattlePassInfo.battlePassData[tostring(Level)]
    self.RGStateController_Lock:ChangeStatus(LevelState == AwardState.ReceivePremiun and "Lock" or "UnLock")
  end
end
function BattlePassAwardItem:SetReceive()
  for i, item in pairs(self.Items.NormalItems) do
    item:SetReceive(true, true)
  end
  if not self.IsNormal then
    for i, item in pairs(self.Items.PremiumItems) do
      item:SetReceive(true, true)
    end
  end
  self.RGStateController_Lock:ChangeStatus("Lock")
end
function BattlePassAwardItem:BindOnUpgrade()
  if not self.ParentView then
    return
  end
  local OldLevel = tonumber(battlepassdata.OldBattlePasData[self.ParentView.BattlePassID].level)
  local CurLevel = tonumber(battlepassdata[self.ParentView.BattlePassID].level)
  if OldLevel < self.Level and CurLevel >= self.Level then
    for i, item in pairs(self.Items.NormalItems) do
      item:SetLock(false)
      UpdateVisibility(item.Available_for_receive, true)
      item:PlayAnimation(item.Ani_change)
    end
    if battlepassdata[self.ParentView.BattlePassID].battlePassActivateState > BattlePassState.Normal then
      for i, item in pairs(self.Items.PremiumItems) do
        UpdateVisibility(item.Available_for_receive, true)
        item:SetLock(false)
        item:PlayAnimation(item.Ani_change)
      end
    end
  end
end
return BattlePassAwardItem
