local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local RecruitApplyItem = UnLua.Class()

function RecruitApplyItem:Construct()
  self.Btn_Reject.OnClicked:Add(self, self.BtnReject_Onclicked)
  self.Btn_Agree.OnClicked:Add(self, self.BtnAgree_Onclicked)
end

function RecruitApplyItem:Destruct()
  self.Btn_Reject.OnClicked:Remove(self, self.BtnReject_Onclicked)
  self.Btn_Agree.OnClicked:Remove(self, self.BtnAgree_Onclicked)
end

function RecruitApplyItem:InitApplyItemInfo(PlayerInfo)
  UpdateVisibility(self, true)
  self.PlayerInfo = PlayerInfo
  self.RoleID = PlayerInfo.roleid
  self.WBP_PlayerHeadIcon:InitInfo(PlayerInfo.portrait, PlayerInfo.level, self, self.RoleID)
  self.WBP_PlayerHeadIcon:SetIsShow(true)
  self.Txt_Name:SetText(PlayerInfo.nickname)
  if self.PlatformIconPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo RecruitApplyItem PlayerInfo.roleid: %s", tostring(PlayerInfo.roleid)))
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo RecruitApplyItem PlayerInfo.channelUID: %s", tostring(PlayerInfo.channelUID)))
    self.PlatformIconPanel:UpdateChannelInfo(PlayerInfo.roleid, false, PlayerInfo.channelUID)
  end
end

function RecruitApplyItem:Hide()
  UpdateVisibility(self, false)
end

function RecruitApplyItem:BtnAgree_Onclicked()
  RecruitHandler:SendAgreeRecruitApply(self.RoleID, DataMgr.GetTeamInfo().teamid, self)
end

function RecruitApplyItem:BtnReject_Onclicked()
  RecruitHandler:SendRefuseRecruitApply(self.RoleID, DataMgr.GetTeamInfo().teamid, self)
end

function RecruitApplyItem:RemoveSelf()
  UpdateVisibility(self, false)
  self.Parent:RemoveApplyItem(self.RoleID)
end

function RecruitApplyItem:OnHovered_HeadIcon(bIsShow, PlayerInfo, TargetItem)
  if bIsShow then
    self.Parent.WBP_SocialPlayerInfoTips:InitSocailPlayerInfoTips(self.PlayerInfo)
    local GeometryItem = TargetItem:GetCachedGeometry()
    local GeometryCanvasPanelTips = self.Parent:GetCachedGeometry()
    local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelTips, GeometryItem)
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Parent.WBP_SocialPlayerInfoTips)
    slotCanvas:SetPosition(Pos)
  else
    self.Parent.WBP_SocialPlayerInfoTips:Hide()
  end
end

function RecruitApplyItem:OnClicked_HeadIcon(MousePosition, SourceFrom)
  UIMgr:Show(ViewID.UI_ContactPersonOperateButtonPanel, nil, MousePosition, self.PlayerInfo, SourceFrom)
end

return RecruitApplyItem
