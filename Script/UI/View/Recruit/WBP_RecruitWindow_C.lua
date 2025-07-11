local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local WBP_RecruitWindow_C = UnLua.Class()
local NotAutoJoin = NSLOCTEXT("WBP_RecruitWindow_C", "NotAutoJoin", "\231\173\155\233\128\137")
local AutoJoin = NSLOCTEXT("WBP_RecruitWindow_C", "AutoJoin", "\228\184\141\231\173\155\233\128\137")
local StartRecruit = NSLOCTEXT("WBP_RecruitWindow_C", "StartRecruit", "\229\143\145\232\181\183\230\139\155\229\139\159")
local TeamSelection = NSLOCTEXT("WBP_RecruitWindow_C", "TeamSelection", "\233\152\159\228\188\141\231\173\155\233\128\137")
local Mode = NSLOCTEXT("RecruitDropDownList", "Mode", "\230\168\161\229\188\143")
local World = NSLOCTEXT("RecruitDropDownList", "World", "\228\184\150\231\149\140")
local Difficulty = NSLOCTEXT("RecruitDropDownList", "Difficulty", "\233\154\190\229\186\166")
function WBP_RecruitWindow_C:Construct()
  self.SelectModeID = 0
  self.SelectWorldID = 0
  self.SelectDifficultyID = 0
  self.InputMaxLength = 50
  self.AutoJoin = false
  self.WBP_ModeList.OnItemClicked:Add(self, WBP_RecruitWindow_C.ModeList_OnItemClicked)
  self.WBP_ModeList.OnListOpen:Add(self, WBP_RecruitWindow_C.ModeList_OnListOpen)
  self.WBP_WorldList.OnItemClicked:Add(self, WBP_RecruitWindow_C.WorldList_OnItemClicked)
  self.WBP_WorldList.OnListOpen:Add(self, WBP_RecruitWindow_C.WorldList_OnListOpen)
  self.WBP_DifficultyList.OnItemClicked:Add(self, WBP_RecruitWindow_C.DifficultyList_OnItemClicked)
  self.WBP_DifficultyList.OnListOpen:Add(self, WBP_RecruitWindow_C.DifficultyList_OnListOpen)
  self.WBP_ApprovalList.OnItemClicked:Add(self, WBP_RecruitWindow_C.ApprovalList_OnItemClicked)
  self.WBP_ApprovalList.OnListOpen:Add(self, WBP_RecruitWindow_C.ApprovalList_OnListOpen)
  self.RGEditableTextCoutomInfo.OnTextChanged:Add(self, self.EditableTextChange)
  self.ButtonTipConfirm.OnClicked:Add(self, self.BindOnTipConfirmClicked)
  self.Btn_Close.OnClicked:Add(self, self.BindOnClose)
  self.Btn_CloseList.OnClicked:Add(self, self.BindOnClsoeList)
  EventSystem.AddListener(self, EventDef.Recruit.StartRecruit, self.BindOnStartRecruit)
  EventSystem.AddListener(self, EventDef.Lobby.GetRolesGameFloorData, self.BindOnGetRolesGameFloorData)
  self:InitModelCombo()
  self:InitApprovalList()
  self:EditableTextChange("")
  self.Old_OpenList = nil
  self.Cur_OpenList = nil
  self.RoleInfos = LogicTeam.RolesGameFloorInfo
  self.WBP_ModeList:ClickItemByInfoID(LogicTeam.GetModeId())
  self.WBP_WorldList:ClickItemByInfoID(LogicTeam.GetWorldId())
  self.WBP_DifficultyList:ClickItemByInfoID(LogicTeam:GetFloor())
  self.WBP_ApprovalList:ClickItemByInfoID(0)
end
function WBP_RecruitWindow_C:Destruct()
  self.WBP_ModeList.OnItemClicked:Remove(self, self.ModeList_OnItemClicked)
  self.WBP_ModeList.OnListOpen:Remove(self, self.ModeList_OnListOpen)
  self.WBP_WorldList.OnItemClicked:Remove(self, self.WorldList_OnItemClicked)
  self.WBP_WorldList.OnListOpen:Remove(self, self.WorldList_OnListOpen)
  self.WBP_DifficultyList.OnItemClicked:Remove(self, self.DifficultyList_OnItemClicked)
  self.WBP_DifficultyList.OnListOpen:Remove(self, self.DifficultyList_OnListOpen)
  self.WBP_ApprovalList.OnItemClicked:Remove(self, self.ApprovalList_OnItemClicked)
  self.ButtonTipConfirm.OnClicked:Remove(self, self.BindOnTipConfirmClicked)
  self.Btn_Close.OnClicked:Remove(self, self.BindOnClose)
  EventSystem.RemoveListener(EventDef.Recruit.StartRecruit, self.BindOnStartRecruit)
end
function WBP_RecruitWindow_C:ShowWindow(IsRecruitWindow, Parent)
  self.IsRecruitWindow = IsRecruitWindow
  self.Parent = Parent
  UpdateVisibility(self, true)
  UpdateVisibility(self.Pnl_EditableText, IsRecruitWindow)
  self.RGTextBlockTitle:SetText(IsRecruitWindow and StartRecruit or TeamSelection)
end
function WBP_RecruitWindow_C:InitModelCombo()
  self.ModelOption = {}
  local ModeInfos = {}
  for ModeID, ModeInfo in pairs(LuaTableMgr.GetLuaTableByName(TableNames.TBGameMode)) do
    if ModeInfo.Name ~= "" and ModeInfo.CanRecrtuit then
      table.insert(ModeInfos, {
        Option = ModeInfo.Name,
        InfoID = ModeID
      })
    end
  end
  self.WBP_ModeList:InitList(ModeInfos)
  self:SetWorldList(self.WBP_ModeList.InfoID)
end
function WBP_RecruitWindow_C:SetWorldList(SelectModeID)
  if not SelectModeID then
    return
  end
  local WorldInfos = {}
  local selectModeWorlds = {}
  for ID, WorldInfo in pairs(LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)) do
    if WorldInfo.gameMode == SelectModeID and not selectModeWorlds[WorldInfo.gameWorldID] then
      selectModeWorlds[WorldInfo.gameWorldID] = true
    end
  end
  for WorldId, v in pairs(selectModeWorlds) do
    local result, row = GetRowData(DT.DT_GameMode, WorldId)
    if result and row.bUnLock and row.bCanSelected then
      table.insert(WorldInfos, {
        Option = row.Name,
        InfoID = row.id
      })
    end
  end
  self.WBP_WorldList:InitList(WorldInfos)
  self:SetDifficultyList()
end
function WBP_RecruitWindow_C:SetDifficultyList()
  local DifficultyInfos = {}
  local result, row = GetRowData(DT.DT_GameMode, self.WBP_WorldList.InfoID)
  if result then
    for i, info in ipairs(row.ModeLevels:ToTable()) do
      table.insert(DifficultyInfos, {
        Option = info.LevelName,
        InfoID = i
      })
    end
  end
  self.WBP_DifficultyList:InitList(DifficultyInfos)
end
function WBP_RecruitWindow_C:InitApprovalList()
  local ApprovaInfos = {}
  table.insert(ApprovaInfos, {Option = NotAutoJoin, InfoID = 1})
  table.insert(ApprovaInfos, {Option = AutoJoin, InfoID = 0})
  self.WBP_ApprovalList:InitList(ApprovaInfos)
end
function WBP_RecruitWindow_C:ModeList_OnItemClicked(InfoID)
  if -1 == InfoID then
    ShowWaveWindow(1195, {
      Mode()
    })
    return
  end
  self:SetWorldList(InfoID)
  self:CloseAllList()
end
function WBP_RecruitWindow_C:ModeList_OnListOpen(IsOpen)
  if IsOpen then
    self:SetBtnClosrListVisible(true)
    self:SetCurrntList(self.WBP_ModeList)
  else
    self:SetBtnClosrListVisible(false)
  end
  self:SetModeItemLock()
end
function WBP_RecruitWindow_C:WorldList_OnItemClicked(InfoID)
  if -1 == InfoID then
    ShowWaveWindow(1195, {
      World()
    })
    return
  end
  self:SetDifficultyList()
  self:SetDifficultyItemLock()
  for i, v in ipairs(self.WBP_DifficultyList.Items) do
    if v.State < 2 then
      v:BtnMain_OnClicked()
      break
    end
  end
  self:CloseAllList()
end
function WBP_RecruitWindow_C:WorldList_OnListOpen(IsOpen)
  if not IsOpen then
    self:SetBtnClosrListVisible(false)
    return
  end
  self:SetCurrntList(self.WBP_WorldList)
  self:SetBtnClosrListVisible(true)
  self:SetWorldItemLock()
end
function WBP_RecruitWindow_C:DifficultyList_OnItemClicked(InfoID)
  if -1 == InfoID then
    ShowWaveWindow(1195, {
      Difficulty()
    })
    return
  end
  self:CloseAllList()
end
function WBP_RecruitWindow_C:DifficultyList_OnListOpen(IsOpen)
  if not IsOpen then
    self:SetBtnClosrListVisible(false)
    return
  end
  self:SetCurrntList(self.WBP_DifficultyList)
  self:SetBtnClosrListVisible(true)
  self:SetDifficultyItemLock()
end
function WBP_RecruitWindow_C:ApprovalList_OnItemClicked(InfoID)
  self:CloseAllList()
end
function WBP_RecruitWindow_C:ApprovalList_OnListOpen(IsOpen)
  if IsOpen then
    self:SetBtnClosrListVisible(true)
    self:SetCurrntList(self.WBP_ApprovalList)
  else
    self:SetBtnClosrListVisible(false)
  end
end
function WBP_RecruitWindow_C:EditableTextChange(text)
  local textLength = UE.URGBlueprintLibrary.GetNickNameLength(text)
  self.ShowText = text
  self.TXT_Editable:SetText(textLength .. "/" .. self.InputMaxLength)
end
function WBP_RecruitWindow_C:BindOnTipConfirmClicked()
  if UE.URGBlueprintLibrary.GetNickNameLength(self.ShowText) > self.InputMaxLength then
    ShowWaveWindow(305000)
    return
  end
  UpdateVisibility(self, false)
  self.Parent.IsOpenWindow = false
  local ModeID, Content, WorldID, Floor, AutoJoin = self:GetWindowParams()
  if self.IsRecruitWindow then
    if not DataMgr.IsInTeam() then
      LogicTeam.RequestCreateTeamToServer({
        self,
        function()
          RecruitHandler:SendStartRecruit(AutoJoin, Content, Floor, ModeID, DataMgr.MyTeamInfo.teamid, WorldID)
        end
      })
    else
      RecruitHandler:SendStartRecruit(AutoJoin, Content, Floor, ModeID, DataMgr.MyTeamInfo.teamid, WorldID)
    end
  else
    self.Parent.viewModel.FilterGameMode = ModeID
    self.Parent.viewModel.FilterWorld = WorldID
    self.Parent.viewModel.FilterFloor = Floor
    self.Parent.viewModel.FilterAutoJoin = AutoJoin
    self.Parent.viewModel:RefreshItemList()
  end
end
function WBP_RecruitWindow_C:BindOnUpdateMyTeamInfo()
  local ModeID, Content, WorldID, Floor, AutoJoin = self:GetWindowParams()
  RecruitHandler:SendStartRecruit(AutoJoin, Content, Floor, ModeID, DataMgr.MyTeamInfo.teamid, WorldID)
end
function WBP_RecruitWindow_C:BindOnStartRecruit(RecruitInfo)
  local ModeID = RecruitInfo.gameMode
  local WorldID = RecruitInfo.worldID
  local Floor = RecruitInfo.floor
  local recruitingPanel = UIMgr:Show(ViewID.UI_RecruitingTipPanel)
  recruitingPanel:SetGameInfo(ModeID, WorldID, Floor)
end
function WBP_RecruitWindow_C:BindOnGetRolesGameFloorData(RoleInfos)
  self.RoleInfos = RoleInfos
  self.WBP_ModeList:ClickItemByInfoID(LogicTeam.GetModeId())
  self.WBP_WorldList:ClickItemByInfoID(LogicTeam.GetWorldId())
  self.WBP_DifficultyList:ClickItemByInfoID(LogicTeam:GetFloor())
end
function WBP_RecruitWindow_C:BindOnClose()
  UpdateVisibility(self, false)
end
function WBP_RecruitWindow_C:BindOnClsoeList()
  if self.CurrentList then
    self.CurrentList:SetIsOpen(false)
  end
end
function WBP_RecruitWindow_C:GetWindowParams()
  local ModeID = self.WBP_ModeList:GetInfoID()
  local WorldID = self.WBP_WorldList:GetInfoID()
  local Floor = self.WBP_DifficultyList:GetInfoID()
  local Content = self.RGEditableTextCoutomInfo:GetText()
  local AutoJoin = true
  if 1 == self.WBP_ApprovalList:GetInfoID() then
    AutoJoin = false
  end
  return ModeID, Content, WorldID, Floor, AutoJoin
end
function WBP_RecruitWindow_C:CloseAllList()
  self.WBP_ModeList:SetIsOpen(false)
  self.WBP_WorldList:SetIsOpen(false)
  self.WBP_DifficultyList:SetIsOpen(false)
  self.WBP_ApprovalList:SetIsOpen(false)
end
function WBP_RecruitWindow_C:SetCurrntList(CurrentList)
  self.CurrentList = CurrentList
  self:SetListOpenState(CurrentList)
end
function WBP_RecruitWindow_C:SetBtnClosrListVisible(IsShow)
  UpdateVisibility(self.Btn_CloseList, IsShow, true)
end
function WBP_RecruitWindow_C:SetModeItemLock()
  for i, item in ipairs(self.WBP_ModeList.Items) do
    for roleid, roleinfo in pairs(self.RoleInfos) do
      if not roleinfo[tostring(item.InfoID)] then
        if roleid == DataMgr.UserId then
          item:SetIsLock()
        elseif DataMgr.IsInTeam() then
          item:SetIsFriendLock()
        end
      end
    end
  end
end
function WBP_RecruitWindow_C:SetWorldItemLock()
  for i, item in ipairs(self.WBP_WorldList.Items) do
    for role_id, role_info in pairs(self.RoleInfos) do
      local modeID = tostring(self.WBP_ModeList.InfoID)
      if role_info[modeID][tostring(item.InfoID)] == nil then
        if role_id == DataMgr.UserId then
          item:SetIsLock()
        elseif DataMgr.IsInTeam() then
          item:SetIsFriendLock()
        end
      end
    end
  end
end
function WBP_RecruitWindow_C:SetDifficultyItemLock()
  for i, item in ipairs(self.WBP_DifficultyList.Items) do
    for role_id, role_info in pairs(self.RoleInfos) do
      local modeID = tostring(self.WBP_ModeList.InfoID)
      local worldID = tostring(self.WBP_WorldList.InfoID)
      if nil == role_info[modeID][worldID] or role_info[modeID][worldID] < item.InfoID then
        if role_id == DataMgr.UserId then
          item:SetIsLock()
        elseif DataMgr.IsInTeam() then
          item:SetIsFriendLock()
        end
      end
    end
  end
end
function WBP_RecruitWindow_C:SetListOpenState(OpenList)
  if self.Old_OpenList and self.Old_OpenList ~= OpenList then
    self.Old_OpenList:SetIsOpen(false)
  end
  self.Old_OpenList = OpenList
end
return WBP_RecruitWindow_C
