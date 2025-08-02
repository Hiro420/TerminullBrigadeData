local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local BattlePassHandle = require("Protocol.BattlePass.BattlePassHandler")
local BattlePassSmallItem = Class(ViewBase)
local AwardState = {
  Lock = 0,
  UnLock = 1,
  ReceiveNormal = 2,
  ReceivePremiun = 3
}

function BattlePassSmallItem:Construct()
  self.WBP_Item.OnClicked:Add(self, self.BtnOnClick)
  EventSystem.AddListenerNew(EventDef.BattlePass.GetBattlePassData, self, self.BindOnUpdateBattlePass)
end

function BattlePassSmallItem:Destruct()
  self.WBP_Item.OnClicked:Remove(self, self.BtnOnClick)
end

function BattlePassSmallItem:BtnOnClick()
  self.ParentView:OnItemClicked(self.ItemID, self.Level, self.Index)
  self.WBP_Item:SetSel(true)
end

function BattlePassSmallItem:OnListItemObjectSet(ListItemObj)
  self:InitItem(ListItemObj.ItemID, ListItemObj.Num, ListItemObj.ParentView, ListItemObj.Level, ListItemObj.IsPremium)
end

function BattlePassSmallItem:InitItem(ItemID, Num, ParentView, Level, IsPremium, Index)
  self.ParentView = ParentView
  self.ItemID = ItemID
  self.Level = Level
  self.Index = Index
  self.WBP_Item:InitItem(ItemID, Num)
  self.IsPremium = IsPremium
  local typeText = self.IsPremium and "Premium" or "Normal"
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(Level) .. "_" .. tostring(self.ItemID) .. "_" .. typeText)
end

function BattlePassSmallItem:SetLock(IsLock)
  self.WBP_Item:SetLock(IsLock)
end

function BattlePassSmallItem:SetReceive(CanReveice, IsReceived)
  if CanReveice then
    self.WBP_Item:UpdateReceivedPanelVis(IsReceived)
    UpdateVisibility(self.Available_for_receive, not IsReceived)
  else
    UpdateVisibility(self.Available_for_receive, false)
    self.WBP_Item:UpdateReceivedPanelVis(false)
  end
end

function BattlePassSmallItem:SetState(State, IsNormal)
  self:SetLock(false)
  if State == AwardState.Lock then
    self:SetLock(true)
    self.WBP_Item:UpdateReceivedPanelVis(false)
    UpdateVisibility(self.Available_for_receive, false)
    return
  end
  if IsNormal then
    if self.IsPremium then
      self:SetLock(true)
      UpdateVisibility(self.Available_for_receive, false)
      return
    else
      self.WBP_Item:UpdateReceivedPanelVis(State > AwardState.UnLock)
      UpdateVisibility(self.Available_for_receive, State <= AwardState.UnLock)
      if State <= AwardState.UnLock then
        self:PlayAnimation(self.Ani_change, self.Ani_change:GetEndTime())
      end
    end
  else
    if self.IsPremium then
      self.WBP_Item:UpdateReceivedPanelVis(State == AwardState.ReceivePremiun)
      UpdateVisibility(self.Available_for_receive, State ~= AwardState.ReceivePremiun)
      if State ~= AwardState.ReceivePremiun then
        self:PlayAnimation(self.Ani_change, self.Ani_change:GetEndTime())
      end
    else
      self.WBP_Item:UpdateReceivedPanelVis(State > AwardState.UnLock)
      UpdateVisibility(self.Available_for_receive, State <= AwardState.UnLock)
      if State <= AwardState.UnLock then
        self:PlayAnimation(self.Ani_change, self.Ani_change:GetEndTime())
      end
    end
    self:SetLock(false)
  end
end

return BattlePassSmallItem
