local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local RecruitDropListItem = UnLua.Class()
local ItemStateEnum = {
  Normal = 0,
  Select = 1,
  Lock = 2,
  FriendLock = 3
}
local TitleStateEnum = {Close = 0, Open = 1}

function RecruitDropListItem:Construct()
  self.BtnMain.OnClicked:Add(self, self.BtnMain_OnClicked)
  self.BtnMain.OnHovered:Add(self, self.BtnMain_OnHovered)
  self.BtnMain.OnUnhovered:Add(self, self.BtnMain_OnUnhovered)
end

function RecruitDropListItem:Destruct()
  self.BtnMain.OnClicked:Remove(self, self.BtnMain_OnClicked)
  self.BtnMain.OnHovered:Remove(self, self.BtnMain_OnHovered)
  self.BtnMain.OnUnhovered:Remove(self, self.BtnMain_OnUnhovered)
end

function RecruitDropListItem:InitItem(Option, Index, InfoID, Parent)
  self.Option = Option
  self.Index = Index
  self.InfoID = InfoID
  self.Parent = Parent
  self.TXT_Info:SetText(Option)
  UpdateVisibility(self, true)
end

function RecruitDropListItem:SetIsNormal()
  self:SetState(ItemStateEnum.Normal)
end

function RecruitDropListItem:SetIsItem(IsItem)
  self.IsItem = IsItem
  self:SetState(self.IsItem and ItemStateEnum.Normal or TitleStateEnum.Close)
  UpdateVisibility(self.Panel_BG, not IsItem)
  UpdateVisibility(self.Overlay_Title, not IsItem)
end

function RecruitDropListItem:SetIsSelect()
  self:SetState(ItemStateEnum.Select)
end

function RecruitDropListItem:SetIsLock()
  self:SetState(ItemStateEnum.Lock)
end

function RecruitDropListItem:SetIsFriendLock()
  self:SetState(ItemStateEnum.FriendLock)
end

function RecruitDropListItem:SetState(ItemState)
  self.State = ItemState
  self:RefreshState(ItemState)
end

function RecruitDropListItem:SetIsOpen(IsOpen)
  if not self.IsItem then
    self:SetState(IsOpen and TitleStateEnum.Open or TitleStateEnum.Close)
  end
end

function RecruitDropListItem:RefreshState(ItemState)
  if self.IsItem then
    UpdateVisibility(self.Overlay_Select, ItemState == ItemStateEnum.Select)
    UpdateVisibility(self.Overlay_Lock, ItemState == ItemStateEnum.Lock)
    UpdateVisibility(self.Overlay_FriendLock, ItemState == ItemStateEnum.FriendLock)
  else
    self.Overlay_Title:SetRenderTransformAngle(ItemState == TitleStateEnum.Open and 180 or 0)
    UpdateVisibility(self.Overlay_TitleSelect, ItemState == TitleStateEnum.Open)
  end
end

function RecruitDropListItem:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function RecruitDropListItem:BtnMain_OnClicked()
  if self.IsItem then
    if self.State ~= ItemStateEnum.Lock and self.State ~= ItemStateEnum.FriendLock then
      self.Parent:OnUnLockItemClicked(self.Option, self.Index, self.InfoID)
    else
      self.Parent:OnLockItemClicked()
    end
  else
    self.OnClicked:Broadcast(self.Option, self.Index, self.InfoID)
  end
end

function RecruitDropListItem:BtnMain_OnHovered()
  if self.IsItem then
    UpdateVisibility(self.Overlay_Hover, true)
  end
end

function RecruitDropListItem:BtnMain_OnUnhovered()
  if self.IsItem then
    UpdateVisibility(self.Overlay_Hover, false)
  end
end

return RecruitDropListItem
