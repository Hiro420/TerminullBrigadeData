local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local RecruitMainViewModel = CreateDefaultViewModel()
RecruitMainViewModel.propertyBindings = {}

function RecruitMainViewModel:OnInit()
  self.Super:OnInit()
  EventSystem.AddListenerNew(EventDef.Recruit.GetRecruitTeamList, self, self.GetRecruitTeamList)
end

function RecruitMainViewModel:OnShutdown()
  self.Super:OnShutdown()
end

function RecruitMainViewModel:SendApplyRecruitTeam(Branch, TeamID, Version)
  RecruitHandler:SendApplyRecruitTeam(Branch, TeamID, Version)
end

function RecruitMainViewModel:SendGetRecruitApplyList(TeamID)
  RecruitHandler:SendGetRecruitApplyList(TeamID)
end

function RecruitMainViewModel:SendGetRecruitTeamList(AutoJoin, Floor, GameMode, WorldID)
  RecruitHandler:SendGetRecruitTeamList(AutoJoin, Floor, GameMode, WorldID)
end

function RecruitMainViewModel:SendStartRecruit(AutoJoin, Content, TeamID)
  RecruitHandler:SendStartRecruit(AutoJoin, Content, TeamID)
end

function RecruitMainViewModel:SendStopRecruit(TeamID)
  RecruitHandler:SendStopRecruit(TeamID)
end

function RecruitMainViewModel:SendAgreeRecruitApply(RoleID, TeamID)
  RecruitHandler:SendAgreeRecruitApply(RoleID, TeamID)
end

function RecruitMainViewModel:SendRolesGameFloorData(RoleIDs)
  LogicTeam.SendRolesGameFloorData(RoleIDs)
end

function RecruitMainViewModel:GetRecruitTeamList(TeamList)
  local view = self:GetFirstView()
  if view then
    local userIdList = {}
    for i, v in ipairs(TeamList.teamList) do
      for index, PlayerID in ipairs(v.players) do
        table.insert(userIdList, tonumber(PlayerID))
      end
    end
    DataMgr.GetOrQueryPlayerInfo(userIdList, false, function(playerInfoList)
      local playerInfoMap = {}
      for i, v in ipairs(playerInfoList) do
        playerInfoMap[v.playerInfo.roleid] = v.playerInfo
      end
      for Team, TeamInfo in ipairs(TeamList.teamList) do
        TeamInfo.playerinfos = {}
        for i, PlayerID in ipairs(TeamInfo.players) do
          table.insert(TeamInfo.playerinfos, playerInfoMap[PlayerID])
        end
      end
      self:GetFirstView():UpdateRecruitList(TeamList.teamList)
    end)
  end
end

function RecruitMainViewModel:InitRecruitTeamList()
  self.FilterFloor = LogicTeam.GetFloor()
  self.FilterGameMode = LogicTeam.GetModeId()
  self.FilterWorld = LogicTeam.GetWorldId()
  self.FilterAutoJoin = false
  self:RefreshItemList()
end

function RecruitMainViewModel:RefreshItemList()
  self:SendGetRecruitTeamList(self.FilterAutoJoin, self.FilterFloor, self.FilterGameMode, self.FilterWorld)
  self:GetFirstView():UpdateFilterInfo(self.FilterGameMode, self.FilterWorld, self.FilterFloor)
end

return RecruitMainViewModel
