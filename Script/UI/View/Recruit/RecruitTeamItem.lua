local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local RecruitTeamItem = UnLua.Class()
function RecruitTeamItem:Construct()
  self.Btn_Apply.OnClicked:Add(self, self.BtnApply_Onclicked)
end
function RecruitTeamItem:Destruct()
  self.Btn_Apply.OnClicked:Remove(self, self.BtnApply_Onclicked)
end
function RecruitTeamItem:InitTeamItemInfo(TeamData, Parent)
  self:PlayAnimation(self.Ani_in, 0)
  self.TeamData = TeamData
  self.Parent = Parent
  self.PlayerInfoList = {}
  local playerInfoList = {
    self.WBP_SquadPlayerInfoItem_1,
    self.WBP_SquadPlayerInfoItem_2,
    self.WBP_SquadPlayerInfoItem_3
  }
  for i, PlayerItem in ipairs(playerInfoList) do
    if i > #TeamData.playerinfos then
      PlayerItem:SetIsEmpty(true)
    else
      local playerinfo = TeamData.playerinfos[i]
      table.insert(self.PlayerInfoList, playerinfo)
      PlayerItem:InitTeamItemInfo(playerinfo.portrait, playerinfo.nickname, playerinfo.level, playerinfo.roleid, self)
      PlayerItem:SetIsEmpty(false)
    end
  end
  if not TeamData then
    return
  end
  self.Txt_Floor:SetText(TeamData.floor)
  self.TXT_CustomInfo:SetText(TeamData.content)
  local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(TeamData.worldID))
  if Result then
    self.Txt_MapName:SetText(RowInfo.Name)
    SetImageBrushBySoftObject(self.Img_Map, RowInfo.RecruitMapBg)
    local modeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGameMode)
    self.TXT_Mode:SetText(modeTable[TeamData.gameMode].NameLocMeta)
  end
end
function RecruitTeamItem:Hide()
  UpdateVisibility(self, false)
end
function RecruitTeamItem:BtnApply_Onclicked()
  if not LogicTeam:IsCaptain() then
    ShowWaveWindow(15007)
    return false
  end
  local teamData = self.TeamData
  if not teamData then
    ShowWaveWindow(1189)
    return
  end
  RecruitHandler:SendApplyRecruitTeam(teamData.branch, teamData.teamID, teamData.version)
end
function RecruitTeamItem:OnHovered_PlayerHead(IsHovered, RoleId, Target)
  if IsHovered then
    for i, v in ipairs(self.PlayerInfoList) do
      if v.roleid == RoleId then
        self.Parent:ShowPlayerInfoTips(IsHovered, v, Target)
      end
    end
  else
    self.Parent:ShowPlayerInfoTips(IsHovered)
  end
end
function RecruitTeamItem:OnClicked_PlayerHead(MousePosition, SourceFrom, RoleId)
  local PlayerInfo = self:GetPlayerInfoById(RoleId)
  UIMgr:Show(ViewID.UI_ContactPersonOperateButtonPanel, nil, MousePosition, PlayerInfo, SourceFrom)
end
function RecruitTeamItem:GetPlayerInfoById(RoleId)
  for i, v in ipairs(self.PlayerInfoList) do
    if v.roleid == RoleId then
      return v
    end
  end
  return nil
end
return RecruitTeamItem
