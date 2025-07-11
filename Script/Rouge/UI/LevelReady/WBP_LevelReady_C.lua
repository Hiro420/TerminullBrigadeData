local WBP_LevelReady_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")
function WBP_LevelReady_C:Construct()
  self.AgreeKeyName = "PKeyEvent"
  self.RefuseKeyName = "OKeyEvent"
  self.TargetLevelName = ""
  self.CurrentNum = 0
  self.MaxNum = 0
  self.ListContainer = ListContainer.New(self.SingleReadyTemplate:StaticClass())
  local AllChildren = self.HorizontalBox_Ready:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    table.insert(self.ListContainer.AllWidgets, SingleItem)
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.ButtonWithSound_Ok.OnClicked:Add(self, WBP_LevelReady_C.OnAgreeEnterLevel)
  self.ButtonWithSound_Refuse.OnClicked:Add(self, WBP_LevelReady_C.OnRefuseEnterLevel)
  self.PercentTime = 1
  self.CurPercentTime = 0
end
function WBP_LevelReady_C:Destruct()
  if IsListeningForInputAction(self, self.AgreeKeyName) then
    StopListeningForInputAction(self, self.AgreeKeyName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.RefuseKeyName) then
    StopListeningForInputAction(self, self.RefuseKeyName, UE.EInputEvent.IE_Pressed)
  end
  self.ButtonWithSound_Ok.OnClicked:Remove(self, WBP_LevelReady_C.OnAgreeEnterLevel)
  self.ButtonWithSound_Refuse.OnClicked:Remove(self, WBP_LevelReady_C.OnRefuseEnterLevel)
  EventSystem.RemoveListener(EventDef.NPCAward.NPCAwardNumInteractFinish, WBP_LevelReady_C.OnFinishInteract, self)
  self:ClearTimerHandle()
  self.ListContainer:ClearAllWidgets()
  self.ListContainer = nil
end
function WBP_LevelReady_C:FocusInput()
end
function WBP_LevelReady_C:UnfocusInput()
end
function WBP_LevelReady_C:Show()
  if self.IsShow then
    return
  end
  self.IsShow = true
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.LocalUserId = DataMgr.GetUserId()
  ListenForInputAction(self.AgreeKeyName, UE.EInputEvent.IE_Pressed, true, {
    self,
    WBP_LevelReady_C.OnAgreeEnterLevel
  })
  ListenForInputAction(self.RefuseKeyName, UE.EInputEvent.IE_Pressed, true, {
    self,
    WBP_LevelReady_C.OnRefuseEnterLevel
  })
  self:OnFinishInteract()
  EventSystem.AddListener(self, EventDef.NPCAward.NPCAwardNumInteractFinish, WBP_LevelReady_C.OnFinishInteract)
  self.PercentTimeInterval = 0.02
  self.PercentTime = 30
  local VoteConfig = UE.URGGameplayLibrary.GetVoteConfig(self, LogicVote.CurVoteType)
  self.PercentTime = VoteConfig.CountDownTime
  self.CurPercentTime = VoteConfig.CountDownTime - (GetCurrentTimestamp(true) - LogicVote.VoteStartTime)
  self.bAgree = false
  self.bRefuse = false
  self:RefreshOperatePanelVis()
  self.HorizontalBox_Buttons:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:UpdateLevelName()
  self:InitReadyBox()
  self:UpdateRefusePanelVis()
  self:PlayAnimation(self.Ani_in)
end
function WBP_LevelReady_C:UpdateLevelName()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  self.TargetRequestEnterText = self.RequestEnterText
  local TargetLevelName = self.DefaultLevelName
  if LogicVote.CurVoteType == UE.EVoteType.Portal or LogicVote.CurVoteType == UE.EVoteType.BonusLevel then
    local Result, RowInfo = DTSubsystem:GetWorldLevelPoolTableRow(LogicVote.CurVoteModeId, nil)
    if Result then
      TargetLevelName = RowInfo.LevelName
    end
  elseif LogicVote.CurVoteType == UE.EVoteType.BattleMode then
    local Result, RowInfo = DTSubsystem:GetBattleModeRowInfoById(LogicVote.CurVoteModeId, nil)
    if Result then
      TargetLevelName = RowInfo.Name
    end
  elseif LogicVote.CurVoteType == UE.EVoteType.TowerClimb then
    TargetLevelName = self.ClimbLevelText
    self.TargetRequestEnterText = self.RequestClimbEnterText
  elseif LogicVote.CurVoteType == UE.EVoteType.Survivor20 then
    TargetLevelName = self.SurvivorLevelText
    self.TargetRequestEnterText = self.SurvivorEnterText
  end
  self.TargetLevelName = TargetLevelName
  self:SpliceTitle()
end
function WBP_LevelReady_C:SpliceTitle()
  local FinalText = string.format("%s<LevelReadyLevelName>%s</>(%d/%d)%s", self.TargetRequestEnterText, self.TargetLevelName, self.CurrentNum, self.MaxNum, self.FinalAwardText)
  self.Txt_Title:SetText(FinalText)
end
function WBP_LevelReady_C:InitReadyBox()
  local gameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem:StaticClass())
  if gameLevelSystem and gameLevelSystem:IsValid() then
    self:CreateAllReadyWidget()
    self.HorizontalBox_DelayTime:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_LevelReady_C:Hide()
  self.IsShow = false
  self.ReadyStateIdList = {}
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if IsListeningForInputAction(self, self.AgreeKeyName) then
    StopListeningForInputAction(self, self.AgreeKeyName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.RefuseKeyName) then
    StopListeningForInputAction(self, self.RefuseKeyName, UE.EInputEvent.IE_Pressed)
  end
  EventSystem.RemoveListener(EventDef.NPCAward.NPCAwardNumInteractFinish, WBP_LevelReady_C.OnFinishInteract, self)
  self:ClearTimerHandle()
end
function WBP_LevelReady_C:LuaTick(DeletaTime)
  self.CurPercentTime = math.max(self.CurPercentTime - DeletaTime, 0)
  self.Txt_AgreeTimeCount:SetText(tostring(math.floor(self.CurPercentTime)))
  self.ProgressBar_Time:SetPercent(self.CurPercentTime / self.PercentTime)
end
function WBP_LevelReady_C:CreateAllReadyWidget()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return
  end
  self.ListContainer:ClearAllUseWidgets()
  local TeamSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubSystem then
    return
  end
  local AllPlayerInfos = TeamSubSystem.TeamInfo.AllPlayerInfos:ToTable()
  self.MaxNum = table.count(AllPlayerInfos)
  self:SpliceTitle()
  self.ReadyStateIdList = {}
  for i, SinglePlayerInfo in ipairs(AllPlayerInfos) do
    local Item = self.ListContainer:GetOrCreateItem()
    if not self.HorizontalBox_Ready:HasChild(Item) then
      local slot = self.HorizontalBox_Ready:AddChild(Item)
      slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
      slot:SetVerticalAlignment(UE.EVerticalAlignment.HAlign_Center)
    end
    self.ListContainer:ShowItem(Item, SinglePlayerInfo, i)
    self.ReadyStateIdList[SinglePlayerInfo.roleid] = false
  end
end
function WBP_LevelReady_C:OnPortalStateChange(PortalState, UserID)
  if not self.ReadyStateIdList then
    self.ReadyStateIdList = {}
  end
  self.ReadyStateIdList[UserID] = true
  if PortalState ~= UE.EVoteState.Refuse and UserID == self.LocalUserId then
    self.HorizontalBox_Buttons:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.HorizontalBox_DelayTime:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.bAgree = true
    self:RefreshOperatePanelVis()
  end
  local AllChildren = self.ListContainer:GetAllUseWidgetsList()
  for i, SingleItem in pairs(AllChildren) do
    if self.ReadyStateIdList[SingleItem:GetUserId()] then
      SingleItem:OnPortalStateChange(PortalState)
    end
  end
  local currentNumber = 0
  for i, IsReady in pairs(self.ReadyStateIdList) do
    if IsReady then
      currentNumber = currentNumber + 1
    end
  end
  self.CurrentNum = currentNumber
  self:SpliceTitle()
end
function WBP_LevelReady_C:UpdateRefusePanelVis()
  if LogicVote.CanRefuse() then
    self.RefuseButtonPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.RefuseButtonPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_LevelReady_C:RefreshOperatePanelVis()
  if self.bAgree or self.bRefuse then
    self.OperateButtonPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.OperateButtonPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_LevelReady_C:ClearTimerHandle()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.LogOutTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.LogOutTimer)
    self.LogOutTimer = nil
  end
end
function WBP_LevelReady_C:OnAgreeEnterLevel()
  if not self.bAgree and not self.bRefuse then
    UE.URGGameplayLibrary.VoteConfirm(self, self.LocalUserId)
    self.bAgree = true
    self:RefreshOperatePanelVis()
  end
end
function WBP_LevelReady_C:OnRefuseEnterLevel()
  if LogicVote.CanRefuse() and not self.bAgree and not self.bRefuse then
    UE.URGGameplayLibrary.VoteRefuse(self, self.LocalUserId)
    self.bRefuse = true
    self:RefreshOperatePanelVis()
  end
end
function WBP_LevelReady_C:OnFinishInteract()
  if LogicHUD:GetActiveAwardNpcNum() > 0 then
    self.FinalAwardText = self.AwardText
  else
    self.FinalAwardText = ""
  end
  self:SpliceTitle()
end
return WBP_LevelReady_C
