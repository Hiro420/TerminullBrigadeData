local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local RecruitDropDownList = UnLua.Class()
function RecruitDropDownList:Construct()
  self.InfoID = 0
  self:SetIsOpen(false)
  self.DropDownListTitle.OnClicked:Add(self, self.OnBtnItemTitleClicked)
end
function RecruitDropDownList:Destruct()
  self.DropDownListTitle.OnClicked:Remove(self, self.OnBtnItemTitleClicked)
end
function RecruitDropDownList:OnBtnItemTitleClicked()
  self:SetIsOpen(not self.IsOpen)
end
function RecruitDropDownList:InitList(Infos)
  if Infos and #Infos > 0 then
    self.DropDownListTitle:InitItem(Infos[1].Option, 0, Infos[1].InfoID, self)
    self.DropDownListTitle:SetIsItem(false)
    self.InfoID = Infos[1].InfoID
    self.Items = {}
    for i, v in ipairs(Infos) do
      local dropDownListItem = GetOrCreateItem(self.ScrollBox_Item, i, self.RecruitDropListItem:GetClass())
      dropDownListItem:InitItem(v.Option, i, v.InfoID, self)
      dropDownListItem:SetIsItem(true)
      table.insert(self.Items, dropDownListItem)
    end
    HideOtherItem(self.ScrollBox_Item, #Infos + 1)
  end
end
function RecruitDropDownList:ClickItemByInfoID(InfoID)
  local IsClicked = true
  for i, v in ipairs(self.Items) do
    if v.InfoID == InfoID then
      v:BtnMain_OnClicked()
      return
    end
  end
  if IsClicked and self.Items[1].State < 2 then
    self.Items[1]:BtnMain_OnClicked()
  end
end
function RecruitDropDownList:OnUnLockItemClicked(Option, Index, InfoID)
  self.InfoID = InfoID
  self.DropDownListTitle:InitItem(Option, 0, InfoID)
  self:SetIsOpen(false)
  self.OnItemClicked:Broadcast(InfoID)
end
function RecruitDropDownList:OnLockItemClicked()
  self.OnItemClicked:Broadcast(-1)
end
function RecruitDropDownList:SetIsOpen(IsOpen)
  self.IsOpen = IsOpen
  self.DropDownListTitle:SetIsOpen(IsOpen)
  UpdateVisibility(self.Overlay_ItemList, IsOpen)
  if IsOpen then
    for i, v in ipairs(self.Items) do
      if self.InfoID == v.InfoID then
        v:SetIsSelect()
      else
        v:SetIsNormal()
      end
    end
  end
  self.OnListOpen:Broadcast(IsOpen)
end
function RecruitDropDownList:GetInfoID()
  return self.InfoID
end
return RecruitDropDownList
