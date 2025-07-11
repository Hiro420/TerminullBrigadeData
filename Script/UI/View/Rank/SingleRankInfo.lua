local RankData = require("UI.View.Rank.RankData")
local SingleRankInfo = UnLua.Class()
function SingleRankInfo:OnListItemObjectSet(ListItemObj)
  if nil == ListItemObj then
    return
  end
  self.WBP_SingleRankInfo_Team.RGStateController:ChangeStatus("TopNormal")
  self.WBP_SingleRankInfo_Single.RGStateController:ChangeStatus("TopNormal")
  self.ListItemObj = ListItemObj
  if ListItemObj.bTeam then
    self.Switcher:SetActiveWidgetIndex(1)
    self.WBP_SingleRankInfo_Team:InitSingleRankInfo(ListItemObj, false)
    UpdateVisibility(self.WBP_SingleRankInfo_Team.Pnl_Self, false)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    self.WBP_SingleRankInfo_Single:InitSingleRankInfo(ListItemObj, false)
    UpdateVisibility(self.WBP_SingleRankInfo_Single.Pnl_Self, false)
  end
end
function SingleRankInfo:BP_OnItemSelectionChanged(bIsSelected)
  self.Switcher:GetActiveWidget().bIsSelected = bIsSelected
  self.Switcher:GetActiveWidget():BP_OnItemSelectionChanged(bIsSelected)
  if not bIsSelected then
    if self.ListItemObj.RankNumber > 3 then
      self.Switcher:GetActiveWidget().RGStateController:ChangeStatus("NotTopNormal")
    else
      self.Switcher:GetActiveWidget().RGStateController:ChangeStatus("TopNormal")
    end
  elseif self.ListItemObj.RankNumber > 3 then
    self.Switcher:GetActiveWidget().RGStateController:ChangeStatus("NotTopSelect")
  else
    self.Switcher:GetActiveWidget().RGStateController:ChangeStatus("TopSelect")
  end
end
function SingleRankInfo:SetSelfInfo(ListItemObj)
  if nil == ListItemObj then
    self.Switcher:SetActiveWidgetIndex(0)
    self.WBP_SingleRankInfo_Single.Switcher:SetActiveWidgetIndex(0)
    return
  end
  print("SingleRankInfo,SetSelfInfo", ListItemObj.WorldMode, ListItemObj.GameMode, ListItemObj.HeroId, ListItemObj.RankNumber)
  local RankChange = 0
  local RankNumStatus = "Not"
  if nil ~= ListItemObj.HeroId and not ListItemObj.bTeam then
    RankChange = RankData.DetectingRankingChanges(ListItemObj.WorldMode, ListItemObj.GameMode, ListItemObj.HeroId, ListItemObj.RankNumber)
    if RankChange < 0 then
      RankNumStatus = "Down"
    elseif RankChange > 0 then
      RankNumStatus = "Up"
    end
  end
  if ListItemObj.bTeam then
    self.Switcher:SetActiveWidgetIndex(1)
    self.WBP_SingleRankInfo_Team:InitSingleRankInfo(ListItemObj, true, RankChange)
    self.WBP_SingleRankInfo_Team.RGStateController:ChangeStatus("NotTopNormal")
    self.WBP_SingleRankInfo_Team.RGStateController_RankNumChange:ChangeStatus(RankNumStatus)
    UpdateVisibility(self.WBP_SingleRankInfo_Team.Pnl_Self, true)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    self.WBP_SingleRankInfo_Single:InitSingleRankInfo(ListItemObj, true, RankChange)
    self.WBP_SingleRankInfo_Single.RGStateController:ChangeStatus("NotTopNormal")
    self.WBP_SingleRankInfo_Single.RGStateController_RankNumChange:ChangeStatus(RankNumStatus)
    UpdateVisibility(self.WBP_SingleRankInfo_Single.Pnl_Self, true)
  end
end
return SingleRankInfo
