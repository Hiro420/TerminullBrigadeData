local RankData = require("UI.View.Rank.RankData")
local RankViewList = UnLua.Class()
function RankViewList:Construct()
  self.Button_Left.OnClicked:Add(self, RankViewList.OnButton_Left)
  self.Button_Right.OnClicked:Add(self, RankViewList.OnButton_Right)
  self.Btn_MVPDown.OnClicked:Add(self, RankViewList.OnBtnMVPDown)
  self.Btn_MVPUp.OnClicked:Add(self, RankViewList.OnBtnMVPUp)
  self.ScrollBox_RankList.BP_OnItemClicked:Add(self, RankViewList.BP_OnItemClicked)
  self.CurrentPageNumber = 0
  self.ShowTeamTable = {}
  EventSystem.AddListener(self, EventDef.Rank.OnRequestServerElementDataSuccess, RankViewList.OnRequestServerElementDataSuccess)
  self.TextBlock_CurrentPage.OnTextCommitted:Add(self, self.OnTextCommitted)
end
function RankViewList:OnBtnMVPDown()
  if self.MVPIndex == nil then
    self.MVPIndex = 1
  end
  self.MVPIndex = self.MVPIndex - 1
  if self.MVPIndex < 1 then
    self.MVPIndex = table.count(self.ShowTeamTable)
  end
  self.WBP_RankMVP_Info:SetMVPInfo(self.ShowTeamTable[self.MVPIndex])
end
function RankViewList:OnBtnMVPUp()
  if self.MVPIndex == nil then
    self.MVPIndex = 1
  end
  self.MVPIndex = self.MVPIndex + 1
  if self.MVPIndex > table.count(self.ShowTeamTable) then
    self.MVPIndex = 1
  end
  self.WBP_RankMVP_Info:SetMVPInfo(self.ShowTeamTable[self.MVPIndex])
end
function RankViewList:OnRequestServerElementDataSuccess(Data)
  self.ShowTeamTable = {}
  local MVPId = ""
  for index, value in ipairs(Data) do
    if value.mvp then
      table.insert(self.ShowTeamTable, 1, value.roleId)
      self.MVPIndex = 1
    else
      table.insert(self.ShowTeamTable, value.roleId)
    end
  end
  UpdateVisibility(self.Btn_MVPDown, 1 ~= table.count(Data), true)
  UpdateVisibility(self.Btn_MVPUp, 1 ~= table.count(Data), true)
  if 1 == table.count(Data) then
    for index, value in ipairs(Data) do
      if value.roleId == self.SelItem.RankInfo.uniqueID then
        self.WBP_RankMVP_Info:SetMVPInfo(Data[1].roleId)
      end
    end
    return
  end
  self.WBP_RankMVP_Info:SetMVPInfo(self.ShowTeamTable[self.MVPIndex])
end
function RankViewList:OnButton_Left()
  if self.CurrentPageNumber <= 1 then
    return
  end
  self:SetCurPage(self.CurrentPageNumber - 1)
end
function RankViewList:OnButton_Right()
  if self.CurrentPageNumber >= self.ShowPageNumm then
    return
  end
  self:SetCurPage(self.CurrentPageNumber + 1)
end
function RankViewList:OnTextCommitted(Text, CommitMethod)
  if CommitMethod == UE.ETextCommit.OnUserMovedFocus or CommitMethod == UE.ETextCommit.OnCleared then
    self.TextBlock_CurrentPage:SetText(tostring(self.CurrentPageNumber))
    return
  end
  local Index = tonumber(Text)
  if Index > self.ShowPageNumm then
    self.TextBlock_CurrentPage:SetText(tostring(self.CurrentPageNumber))
    return
  end
  if Index <= 0 then
    self.TextBlock_CurrentPage:SetText(tostring(self.CurrentPageNumber))
    return
  end
  self:SetCurPage(Index)
end
function RankViewList:BP_OnItemClicked(ItemObj)
  if nil == ItemObj then
    return
  end
  self.SelItem = ItemObj
  local SeasonId, GameMode, GameWorld, HeroId, UniqueID = ItemObj.SeasonId, ItemObj.GameMode, ItemObj.WorldMode, ItemObj.HeroId, ItemObj.RankInfo.uniqueID
  if not self.ParentClass.TeamMode then
    BoardType = ERankType.Solo
    HeroId = tonumber(self.ParentClass.ComboBoxHero:GetSelectedOption())
  else
    HeroId = nil
  end
  RankData.RequestServerElementData(SeasonId, GameMode, GameWorld, HeroId, UniqueID)
end
function RankViewList:SetShowType(bTeam, WorldMode, GameMode, HeroId, SeasonId)
  self.bTeam = bTeam
  self.WorldMode = WorldMode
  self.GameMode = GameMode
  self.HeroId = HeroId
  self.SeasonId = SeasonId
  UpdateVisibility(self.Pnl_Team, bTeam)
  UpdateVisibility(self.Pnl_Single, not bTeam)
end
function RankViewList:SetCurPage(Index)
  self.CurrentPageNumber = Index
  self.TextBlock_CurrentPage:SetText(tostring(Index))
  local Start, End = (Index - 1) * self.NumberOfPage + 1, Index * self.NumberOfPage
  local DataObjList = UE.TArray(UE.UObject)
  self.ScrollBox_RankList:RecyleAllData()
  self.ScrollBox_RankList:BP_SetSelectedItem(nil)
  local RoleIds = {}
  for index = Start, End do
    if self.RankListInfo.ranklist[index] and self.RankListInfo.ranklist[index].uniqueID ~= "" then
      for index, value in ipairs(Split(self.RankListInfo.ranklist[index].uniqueID, "_")) do
        table.insert(RoleIds, value)
      end
    end
  end
  local OnGetRoleSuccess = function(PlayerCacheInfoList)
    local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
    for index = Start, End do
      if self.RankListInfo.ranklist[index] then
        local ItemObj = self.ScrollBox_RankList:GetOrCreateDataObj()
        ItemObj.RankNumber = index
        ItemObj.RankInfo = self.RankListInfo.ranklist[index]
        ItemObj.bTeam = self.bTeam
        ItemObj.WorldMode = self.WorldMode
        ItemObj.GameMode = self.GameMode
        ItemObj.HeroId = self.HeroId
        ItemObj.PlayerInfoList = PlayerInfoList
        ItemObj.SeasonId = self.SeasonId
        DataObjList:Add(ItemObj)
      end
    end
    UpdateVisibility(self.CanvasPanel_NoData, DataObjList:Num() <= 0)
    UpdateVisibility(self.WBP_RankMVP_Info, DataObjList:Num() > 0)
    UpdateVisibility(self.Btn_MVPDown, 0 ~= DataObjList:Num())
    UpdateVisibility(self.Btn_MVPUp, 0 ~= DataObjList:Num())
    if LogicRole.GetRoleMainActor() then
      LogicRole.GetRoleMainActor():SetActorHiddenInGame(0 == DataObjList:Num())
    end
    if DataObjList:Num() > 0 then
      self.ScrollBox_RankList:SetRGListItems(DataObjList)
      if nil ~= DataObjList[1] then
        self:BP_OnItemClicked(DataObjList[1])
        self.ScrollBox_RankList:SetSelectedIndex(0)
      end
    end
    local Item
    for i, v in ipairs(self.RankStepItemTable) do
      v.RGStateControllerSelect:ChangeStatus("UnSelect")
    end
    if 1 == self.CurrentPageNumber then
      Item = self.RankStepItemTable[1]
    elseif self.CurrentPageNumber == self.ShowPageNumm then
      Item = self.RankStepItemTable[3]
    else
      Item = self.RankStepItemTable[2]
    end
    if Item then
      Item.RGStateControllerSelect:ChangeStatus("Select")
    end
  end
  DataMgr.GetOrQueryPlayerInfo(RoleIds, false, OnGetRoleSuccess, nil, 300)
end
function RankViewList:UpdateRankPagesInfo()
  self.NumberOfPage = self.MaxShowNum / self.MaxPage
  self.ShowPageNumm = math.ceil(#self.RankListInfo.ranklist / self.NumberOfPage)
  self.TextBlock_MaxPage:SetText(self.ShowPageNumm)
  local FinishNum = 3
  if self.ShowPageNumm < 3 then
    FinishNum = self.ShowPageNumm
  end
  self.RankStepItemTable = {}
  for i = 1, FinishNum do
    local item = GetOrCreateItem(self.HorizontalBoxStep, i, self.WBP_RankStepItem:GetClass())
    self.RankStepItemTable[i] = item
  end
  HideOtherItem(self.HorizontalBoxStep, table.count(self.RankStepItemTable) + 1, true)
end
function RankViewList:UpdateRankList(RankListInfo)
  if self:IsFirstShowList() and 0 == DataMgr.GetPlayerInvisible(2) then
    ShowWaveWindowWithDelegate(self.RankInvisibleWaveId, {}, function()
      DataMgr.SetPlayerInvisible(2, 1)
    end)
  end
  self.WBP_PlayerRankInfo:SetSelfInfo(nil)
  self.RankListInfo = RankListInfo
  self:UpdateRankPagesInfo()
  self:SetCurPage(1)
  UpdateVisibility(self.NoData, 0 == table.count(self.RankListInfo.ranklist))
  local OnGetRoleSuccess = function(PlayerCacheInfoList)
    local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
    for index, value in ipairs(self.RankListInfo.ranklist) do
      if string.match(value.uniqueID, DataMgr.GetUserId()) then
        local ItemObj = UE.NewObject(UE.UClass.Load("/Game/Rouge/UI/Rank/BP_SingleRankInfo.BP_SingleRankInfo_C"), self, nil)
        ItemObj.RankNumber = index
        ItemObj.RankInfo = self.RankListInfo.ranklist[index]
        ItemObj.bTeam = self.bTeam
        ItemObj.WorldMode = self.WorldMode
        ItemObj.GameMode = self.GameMode
        ItemObj.HeroId = self.HeroId
        ItemObj.PlayerInfoList = PlayerInfoList
        ItemObj.SeasonId = self.SeasonId
        self.WBP_PlayerRankInfo:SetSelfInfo(ItemObj)
        return
      end
    end
  end
  for index, value in ipairs(self.RankListInfo.ranklist) do
    if string.match(value.uniqueID, DataMgr.GetUserId()) then
      local Players = Split(self.RankListInfo.ranklist[index].uniqueID, "_")
      DataMgr.GetOrQueryPlayerInfo(Players, false, OnGetRoleSuccess, nil, 300)
      return
    end
  end
end
function RankViewList:IsFirstShowList()
  local FilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/Rank/" .. DataMgr.GetUserId() .. "Rank.txt"
  local OutString = ""
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(FilePath, nil)
  if Result then
    return false
  end
  local OutStr = "1"
  UE.URGBlueprintLibrary.SaveStringToFile(FilePath, OutStr)
  return true
end
return RankViewList
