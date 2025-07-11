local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RedDotData = require("Modules.RedDot.RedDotData")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local WBP_PlayerHeadIcon_C = UnLua.Class()
function WBP_PlayerHeadIcon_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.OnClicked_BtnMain)
  self.Btn_Main.OnHovered:Add(self, self.OnHovered_BtnMain)
  self.Btn_Main.OnUnhovered:Add(self, self.OnUnhovered_BtnMain)
end
function WBP_PlayerHeadIcon_C:Destruct()
end
function WBP_PlayerHeadIcon_C:InitInfo(Portrait, Level, Parent, RoleId)
  self.Txt_Level:SetText(Level)
  self.Parent = Parent
  self.RoleId = RoleId
  local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(Portrait)
  if PortraitRowInfo then
    self.ComPortraitItem:InitComPortraitItem(PortraitRowInfo.portraitIconPath, PortraitRowInfo.EffectPath)
  end
end
function WBP_PlayerHeadIcon_C:SetIsShow(IsShow)
  self.IsShow = IsShow
  UpdateVisibility(self.CanvasPanel_Empty, not IsShow)
  UpdateVisibility(self.ComPortraitItem, IsShow)
  UpdateVisibility(self.CanvasPanel_Level, IsShow)
end
function WBP_PlayerHeadIcon_C:SetIsCaptain(IsCaptain)
  UpdateVisibility(self.Overlay_Captain, IsCaptain)
end
function WBP_PlayerHeadIcon_C:OnClicked_BtnMain()
  local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
  local SourceFrom = ContactPersonData:IsFriend(self.RoleId) and EOperateButtonPanelSourceFromType.RecentList or EOperateButtonPanelSourceFromType.Search
  if self.Parent then
    self.Parent:OnClicked_HeadIcon(MousePosition, SourceFrom, self.RoleId)
  end
end
function WBP_PlayerHeadIcon_C:OnHovered_BtnMain()
  if not self.IsShow then
    return
  end
  if self.Parent then
    self.Parent:OnHovered_HeadIcon(true, nil, self, self.RoleId)
  end
end
function WBP_PlayerHeadIcon_C:OnUnhovered_BtnMain()
  if not self.IsShow then
    return
  end
  if self.Parent then
    self.Parent:OnHovered_HeadIcon(false)
  end
end
function WBP_PlayerHeadIcon_C:CheckIsSelf()
  return self.RoleId == DataMgr.GetUserId()
end
return WBP_PlayerHeadIcon_C
