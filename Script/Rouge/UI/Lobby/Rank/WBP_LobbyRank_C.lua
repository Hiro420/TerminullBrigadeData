local rapidjson = require("rapidjson")
local RankData = require("Modules.Rank.RankData")
local WBP_LobbyRank_C = UnLua.Class()

function WBP_LobbyRank_C:Construct()
  self.Button_Test.OnClicked:Add(self, WBP_LobbyRank_C.OnClicked_Test)
  self.Button_Debug.OnClicked:Add(self, WBP_LobbyRank_C.OnClicked_Debug)
  self.Button_Left.OnClicked:Add(self, WBP_LobbyRank_C.OnClicked_Left)
  self.Button_Right.OnClicked:Add(self, WBP_LobbyRank_C.OnClicked_Right)
  self.CurrentPageNumber = 1
  self.ModeIndex = 1
  self:OnLobbyDebugUI()
  self:BindOnLobbyDebugUI(true)
  EventSystem.AddListener(self, EventDef.LobbyRankPanel.OnModeChange, WBP_LobbyRank_C.OnModeChange)
end

function WBP_LobbyRank_C:Destruct()
  self.Button_Test.OnClicked:Remove(self, WBP_LobbyRank_C.OnClicked_Test)
  self.Button_Debug.OnClicked:Remove(self, WBP_LobbyRank_C.OnClicked_Debug)
  self.Button_Left.OnClicked:Remove(self, WBP_LobbyRank_C.OnClicked_Left)
  self.Button_Right.OnClicked:Remove(self, WBP_LobbyRank_C.OnClicked_Right)
  self.widgetTable = nil
  self:BindOnLobbyDebugUI(false)
  EventSystem.RemoveListener(EventDef.LobbyRankPanel.OnModeChange, WBP_LobbyRank_C.OnModeChange, self)
  self.WBP_PlayerRankInfo.ButtonClicked:Remove(self, self.OnButtonClicked)
end

function WBP_LobbyRank_C:UpdateRankPagesInfo(RankList)
  self.ScrollBox_RankList:ClearChildren()
  if table.count(RankList) <= 0 then
    self.CurrentPageNumber = 1
    self.TextBlock_CurrentPage:SetText(tostring(0))
    self.TextBlock_MaxPage:SetText(tostring(0))
    return
  end
  local Number = #RankList
  local settings = UE.URGLobbySettings.GetSettings()
  self.NumberOfPage = settings.RankMaxNumber / settings.RankMaxPageNumber
  self.FinalPageNumber = math.ceil(Number / self.NumberOfPage)
  self.TextBlock_MaxPage:SetText(tostring(self.FinalPageNumber))
  self.RankInfoTable = {}
  local temptable = {}
  for i, SingleInfo in pairs(RankList) do
    table.insert(temptable, SingleInfo)
    if 0 == i % self.NumberOfPage then
      table.insert(self.RankInfoTable, temptable)
      temptable = {}
    end
  end
  table.insert(self.RankInfoTable, temptable)
  self:UpdateRankList(self.CurrentPageNumber)
  self:SetLocalPlayerRankInfo()
end

function WBP_LobbyRank_C:UpdateRankList(PageNumber)
  if PageNumber > self.FinalPageNumber or PageNumber < 1 then
    return
  end
  self.CurrentPageNumber = PageNumber
  self.TextBlock_CurrentPage:SetText(tostring(PageNumber))
  self.ScrollBox_RankList:ClearChildren()
  local widgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Rank/WBP_SingleRankInfo.WBP_SingleRankInfo_C")
  local widget
  self.widgetTable = {}
  local length = #self.RankInfoTable
  if PageNumber <= length then
    for i, SingleInfo in ipairs(self.RankInfoTable[PageNumber]) do
      widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
      if widget then
        widget:InitRankInfo(math.ceil((PageNumber - 1) * self.NumberOfPage + i), SingleInfo, i)
        widget.ButtonClicked:Add(self, self.OnButtonClicked)
        self.ScrollBox_RankList:AddChild(widget)
        table.insert(self.widgetTable, widget)
      end
    end
  end
end

function WBP_LobbyRank_C:RequestSetScoreAndData()
  local RoleList = {}
  local SingleRole = {
    roleId = DataMgr.GetUserId(),
    gameHard = tonumber(self.EditableText_Difficulty:GetText()),
    gamePassDuration = tonumber(self.EditableText_GamePassDuration:GetText()),
    gamePassTime = os.time(date)
  }
  table.insert(RoleList, SingleRole)
  local roleInfosString = RapidJsonEncode(RoleList)
  print(roleInfosString)
  local Param = {
    boardName = "season:cyber",
    roleInfos = roleInfosString
  }
  HttpCommunication.Request("dbg/rank/setscoreanddata", Param, {
    self,
    self.OnSetScoreAndDataSuccess
  }, {
    self,
    self.OnSetScoreAndDataFail
  })
end

function WBP_LobbyRank_C:RequestRankList(BoardName, Start, Stop)
  local boardName = "?boardName=" .. BoardName
  local start = "&&start=" .. Start
  local stop = "&&stop=" .. Stop
  local path = "rank/pullranklist" .. boardName .. start .. stop
  HttpCommunication.RequestByGet(path, {
    self,
    self.OnRequestRankListSuccess
  }, {
    self,
    self.OnRequestRankListFail
  })
  print("WBP_LobbyRank_C", path)
end

function WBP_LobbyRank_C:RequestTeamInfo(uniqueID)
  if nil == uniqueID then
    return
  end
  if nil == self.CacheTeamInfo then
    self.CacheTeamInfo = {}
  end
  if nil ~= self.CacheTeamInfo[uniqueID] then
    self:OnRequestTeamInfoSuccess(self.CacheTeamInfo[uniqueID])
    return
  end
  self.RequestUniqueID = uniqueID
  local boardName = "?boardName=" .. self.CurMode
  local uniqueIDs = "&&uniqueIDs=" .. uniqueID
  HttpCommunication.RequestByGet("rank/pulldata" .. boardName .. uniqueIDs, {
    self,
    self.OnRequestTeamInfoSuccess
  }, {
    self,
    self.OnRequestTeamInfoFail
  })
end

function WBP_LobbyRank_C:RequestRankListBySettings(BoardName)
  local settings = UE.URGLobbySettings.GetSettings()
  local RankMaxNumber = tostring(settings.RankMaxNumber - 1)
  self:RequestRankList(BoardName, "0", RankMaxNumber)
end

function WBP_LobbyRank_C:BindOnLobbyDebugUI(Bind)
  local setting = UE.URGLobbySettings.GetSettings()
  if setting then
    if Bind then
      setting.LobbyDebugUIDelegate:Add(self, WBP_LobbyRank_C.OnLobbyDebugUI)
    else
      setting.LobbyDebugUIDelegate:Remove(self, WBP_LobbyRank_C.OnLobbyDebugUI)
    end
  end
end

function WBP_LobbyRank_C:OnRequestRankListSuccess(JsonResponse)
  print("OnRequestRankListSuccess", JsonResponse.Content)
  self.RankListInfo = rapidjson.decode(JsonResponse.Content)
  self:FilterMode()
  self:UpdateRankPagesInfo(self.ModeOneRankList)
  self.WBP_RankModeItemBox:UpdateRankModeItemBox()
end

function WBP_LobbyRank_C:OnRequestRankListFail(JsonResponse)
  print("OnRequestRankListFail", JsonResponse.ErrorMessage)
end

function WBP_LobbyRank_C:OnRequestTeamInfoSuccess(JsonResponse)
  local Response
  if type(JsonResponse) == "string" then
    print("OnRequestTeamInfoSuccess", JsonResponse)
    Response = rapidjson.decode(JsonResponse)
  else
    Response = rapidjson.decode(JsonResponse.Content)
    print("OnRequestTeamInfoSuccess", JsonResponse.Content)
  end
  for key, value in pairs(rapidjson.decode(Response.datas[1]).List) do
    if value.mvp then
      self.WBP_RankMVP_Info:Init("123", value.totalDamage, value.heroId)
      return
    end
  end
  if self.RequestUniqueID then
    self.CacheTeamInfo[self.RequestUniqueID] = JsonResponse.Content
  end
end

function WBP_LobbyRank_C:OnRequestTeamInfoFail(JsonResponse)
  print("OnRequestTeamInfoFail", JsonResponse.ErrorMessage)
end

function WBP_LobbyRank_C:OnSetScoreAndDataSuccess(JsonResponse)
  print("OnSetScoreAndDataSuccess", JsonResponse.Content)
  self:RequestRankListBySettings(EnumRankMode.season.cyber)
end

function WBP_LobbyRank_C:OnSetScoreAndDataFail(JsonResponse)
  print("OnSetScoreAndDataFail", JsonResponse.ErrorMessage)
end

function WBP_LobbyRank_C:OnClicked_Test()
  if self.Overlay_Debug:IsVisible() then
    self.Overlay_Debug:SetVisibility(UE.ESlateVisibility.Hidden)
  else
    self.Overlay_Debug:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_LobbyRank_C:OnClicked_Debug()
  self.Overlay_Debug:SetVisibility(UE.ESlateVisibility.Hidden)
  self:RequestSetScoreAndData()
end

function WBP_LobbyRank_C:OnClicked_Left()
  self:UpdateRankList(self.CurrentPageNumber - 1)
end

function WBP_LobbyRank_C:OnClicked_Right()
  self:UpdateRankList(self.CurrentPageNumber + 1)
end

function WBP_LobbyRank_C:OnButtonClicked(nickname, level, uniqueID)
  self.WBP_PlayerRankInfo:SetClickedBack(false)
  for key, value in ipairs(self.widgetTable) do
    value:SetClickedBack(false)
  end
  if self.CurMode == nil then
    self.CurMode = EnumRankMode.season.cyber
  end
  self:RequestTeamInfo(uniqueID)
  self.TextBlock_PlayerName:SetText(nickname)
  self.TextBlock_Level:SetText(level)
end

function WBP_LobbyRank_C:OnLobbyDebugUI()
  local setting = UE.URGLobbySettings.GetSettings()
  if setting then
    if setting.bShowDebugButton then
      self.Button_Test:SetVisibility(UE.ESlateVisibility.Visible)
    else
      self.Button_Test:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end

function WBP_LobbyRank_C:OnModeChange(Index)
  self.CurrentPageNumber = 1
  self.ModeIndex = Index
  if 1 == Index then
    self:RequestRankListBySettings(EnumRankMode.season.cyber)
    self.CurMode = EnumRankMode.season.cyber
  end
  if 2 == Index then
    self:RequestRankListBySettings(EnumRankMode.season.fairyTale)
    self.CurMode = EnumRankMode.season.fairyTale
  end
  if 3 == Index then
    self:RequestRankListBySettings(EnumRankMode.season.wasteland)
    self.CurMode = EnumRankMode.season.wasteland
  end
  if 4 == Index then
    self:RequestRankListBySettings(EnumRankMode.season.star)
    self.CurMode = EnumRankMode.season.star
  end
end

function WBP_LobbyRank_C:SetLocalPlayerRankInfo()
  local PlayerRankInfo = {}
  PlayerRankInfo.roleId = DataMgr.GetUserId()
  PlayerRankInfo.score = self.RankListInfo.score
  PlayerRankInfo.data = self.RankListInfo.data
  self.WBP_PlayerRankInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  local count = 0
  local rankList
  if 1 == self.ModeIndex then
    rankList = self.ModeOneRankList
  else
    rankList = self.ModeTwoRankList
  end
  for key, value in pairs(rankList) do
    count = count + 1
    if PlayerRankInfo.roleId == value.roleId then
      self.WBP_PlayerRankInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.WBP_PlayerRankInfo:InitRankInfo(count, PlayerRankInfo, 0)
      self.WBP_PlayerRankInfo.ButtonClicked:Add(self, self.OnButtonClicked)
      return
    end
  end
end

function WBP_LobbyRank_C:FilterMode()
  self.ModeOneRankList = {}
  self.ModeTwoRankList = {}
  for key, value in pairs(self.RankListInfo.ranklist) do
    local scoreNumber = tonumber(value.score)
    local gameHardNumber = scoreNumber >> 44
    if 99 == gameHardNumber then
      table.insert(self.ModeTwoRankList, value)
    else
      table.insert(self.ModeOneRankList, value)
    end
  end
end

return WBP_LobbyRank_C
