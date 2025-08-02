local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RedDotData = require("Modules.RedDot.RedDotData")
local RecruitPlayerInfoItem = UnLua.Class()

function RecruitPlayerInfoItem:Construct()
end

function RecruitPlayerInfoItem:Destruct()
end

function RecruitPlayerInfoItem:InitTeamItemInfo(Portrait, name, level, roleid, parent)
  self.RoleId = roleid
  self.Parent = parent
  self.Txt_MapName:SetText(name)
  self.WBP_PlayerHeadIcon:InitInfo(Portrait, level, self)
  if self.PlatformIconPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo RecruitPlayerInfoItem roleid: %s", tostring(roleid)))
    self.PlatformIconPanel:UpdateChannelInfo(roleid)
  end
end

function RecruitPlayerInfoItem:SetIsEmpty(IsEmpty)
  self.IsEmpty = IsEmpty
  self.WBP_PlayerHeadIcon:SetIsShow(not IsEmpty)
  if IsEmpty then
    self.Txt_MapName:SetText("-- --")
    UpdateVisibility(self.PlatformIconPanel, false)
  end
end

function RecruitPlayerInfoItem:OnHovered_HeadIcon(IsHover)
  self.Parent:OnHovered_PlayerHead(IsHover, self.RoleId, self)
end

function RecruitPlayerInfoItem:Hide()
  UpdateVisibility(self, false)
end

function RecruitPlayerInfoItem:OnClicked_HeadIcon(MousePosition, SourceFrom)
  self.Parent:OnClicked_PlayerHead(MousePosition, SourceFrom, self.RoleId)
end

return RecruitPlayerInfoItem
