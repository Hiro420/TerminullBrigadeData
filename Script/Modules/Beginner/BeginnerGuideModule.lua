local BeginnerGuideModule = LuaClass()
local rapidjson = require("rapidjson")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local PandoraData = require("Modules.Pandora.PandoraData")
local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local DisableGuideViews = {
  ViewID.UI_ReportView,
  ViewID.UI_PandoraRootPanel,
  ViewID.UI_Common_GetProps
}

function BeginnerGuideModule:Ctor()
end

function BeginnerGuideModule:OnInit()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("BeginnerGuideModule:OnInit...........")
  BeginnerGuideData:ResetData()
  EventSystem.AddListenerNew(EventDef.BeginnerGuide.OnGetFinishedGuideList, self, self.BindOnGetFinishedGuideList)
  EventSystem.AddListenerNew(EventDef.BeginnerGuide.OnBeginnerMissionFinished, self, self.BindOnBeginnerMissionFinished)
  EventSystem.AddListenerNew(EventDef.BeginnerGuide.OnLobbyShow, self, self.BindOnLobbyShow)
  EventSystem.AddListenerNew(EventDef.Login.DataResetWhenLogin, self, self.BindOnDataResetWhenLogin)
  EventSystem.AddListenerNew(EventDef.ViewAction.ViewProrityQueueEmpty, self, self.BindOnViewProrityQueueEmpty)
  EventSystem.AddListenerNew(EventDef.Pandora.pandoraOnCloseRootPanel, self, self.BindPandoraOnCloseRootPanel)
  for k, v in pairs(BeginnerGuideData.GuideList) do
    if v.triggerevent ~= "" then
      if 1 == v.eventtype then
        EventSystem.AddListenerNew(v.triggerevent, self, function()
          self:InitByGuideId(v.id)
        end)
      end
      if 2 == v.eventtype then
        ListenObjectMessage(nil, v.triggerevent, self, function(Instigator)
          local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
          if Character ~= Instigator then
            print("ywtao,Character ~= Instigator, \228\184\141\230\152\175\229\143\145\231\187\153\232\135\170\229\183\177\231\154\132\228\186\139\228\187\182")
            return
          end
          self:InitByGuideId(v.id)
        end)
      elseif 3 == v.eventtype then
        ListenObjectMessage(nil, v.triggerevent, self, function()
          self:InitByGuideId(v.id)
        end)
      end
    end
  end
  self.bCanRequestMyHeroInfo = false
  self.bCanRequestTeamGameFloorData = false
end

function BeginnerGuideModule:OnShutdown()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("BeginnerGuideModule:OnShutdown...........")
  EventSystem.RemoveListenerNew(EventDef.BeginnerGuide.OnGetFinishedGuideList, self, self.BindOnGetFinishedGuideList)
  EventSystem.RemoveListenerNew(EventDef.BeginnerGuide.OnBeginnerMissionFinished, self, self.BindOnBeginnerMissionFinished)
  EventSystem.RemoveListenerNew(EventDef.BeginnerGuide.OnLobbyShow, self, self.BindOnLobbyShow)
  EventSystem.RemoveListenerNew(EventDef.Login.DataResetWhenLogin, self, self.BindOnDataResetWhenLogin)
  EventSystem.RemoveListenerNew(EventDef.ViewAction.ViewProrityQueueEmpty, self, self.BindOnViewProrityQueueEmpty)
  EventSystem.RemoveListenerNew(EventDef.Pandora.pandoraOnCloseRootPanel, self, self.BindPandoraOnCloseRootPanel)
  for k, v in pairs(BeginnerGuideData.GuideList) do
    if v.triggerevent ~= "" and (2 == v.eventtype or 3 == v.eventtype) then
      UnListenObjectMessage(v.triggerevent, self)
    end
  end
end

function BeginnerGuideModule:InitByGuideId(GuideId)
  if self:CheckDisableGuideView() then
    print("ywtao, \229\189\147\229\137\141\230\156\137\231\166\129\230\173\162\229\188\149\229\175\188\231\154\132\231\149\140\233\157\162\230\152\190\231\164\186\239\188\140\228\184\141\232\167\166\229\143\145\229\188\149\229\175\188")
    return
  end
  print("ywtao, InitByGuideId " .. GuideId)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("ywtao, \230\150\176\230\137\139\229\133\179\228\184\141\232\167\166\229\143\145\229\177\128\229\164\150/\229\177\128\229\134\133\231\142\169\230\179\149\229\188\149\229\175\188")
    return
  end
  if BeginnerGuideData.NowGuideId ~= nil then
    print("ywtao, \229\183\178\230\156\137\229\188\149\229\175\188\232\191\155\232\161\140\228\184\173, \229\136\164\230\150\173\232\131\189\228\184\141\232\131\189\230\138\162\229\141\160...", BeginnerGuideData.NowGuideId)
    local NowGuide = BeginnerGuideData:GetNowGuide()
    if nil == NowGuide or nil == NowGuide.guidelist then
      UnLua.LogError("BeginnerGuideModule:InitByGuideId, NowGuide == nil or NowGuide['guidelist'] == nil")
      return
    end
    if BeginnerGuideData.NowGuideStepId ~= NowGuide.guidelist[1] then
      print("ywtao, \229\189\147\229\137\141\229\188\149\229\175\188\229\183\178\228\184\141\229\156\168\231\172\172\228\184\128\230\173\165\239\188\140\230\151\160\230\179\149\230\138\162\229\141\160")
      return
    else
      print("ywtao, \229\189\147\229\137\141\229\188\149\229\175\188\229\156\168\231\172\172\228\184\128\230\173\165\239\188\140\229\143\175\228\187\165\230\138\162\229\141\160")
      if BeginnerGuideData.GuideList[GuideId].priority > NowGuide.priority then
        print("ywtao, GuideId" .. GuideId .. " \228\188\152\229\133\136\231\186\167\233\171\152\228\186\142 NowGuideId" .. BeginnerGuideData.NowGuideId .. ", \229\143\175\228\187\165\230\138\162\229\141\160, \229\176\157\232\175\149\229\136\157\229\167\139\229\140\150GuideId" .. GuideId)
      else
        print("ywtao, GuideId" .. GuideId .. " \228\188\152\229\133\136\231\186\167\228\184\141\233\171\152\228\186\142 NowGuideId" .. BeginnerGuideData.NowGuideId .. ", \230\151\160\230\179\149\230\138\162\229\141\160")
        return
      end
    end
  end
  if nil == BeginnerGuideData.GuideList[GuideId] then
    print("ywtao,GuideId is nil")
    return
  end
  if BeginnerGuideData:CheckGuideIsFinished(GuideId) then
    print("ywtao,GuideId" .. GuideId .. " is finished")
    return
  end
  for _, PreGuideId in pairs(BeginnerGuideData.GuideList[GuideId].preguidelist) do
    if not BeginnerGuideData:CheckGuideIsFinished(PreGuideId) then
      print("ywtao,Guide " .. PreGuideId .. " is not finished, so Guide " .. GuideId .. " can not start")
      return
    end
  end
  self:ForceInitByGuideId(GuideId)
end

function BeginnerGuideModule:ForceInitByGuideId(GuideId)
  BeginnerGuideData.NowGuideId = GuideId
  local NowGuide = BeginnerGuideData:GetNowGuide()
  if NowGuide.guidelist[1] == nil then
    print("ywtao,Guide" .. GuideId .. " is empty")
    return
  end
  if 1 == NowGuide.eventtype then
    BeginnerGuideData.NowGuideStepId = NowGuide.guidelist[1]
    local ViewModel = UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel")
    ViewModel:ShowNowGuide()
  elseif 2 == NowGuide.eventtype or 3 == NowGuide.eventtype then
    self:ShowInsideTip(NowGuide.guidelist, GuideId)
  end
end

function BeginnerGuideModule:BindOnGetFinishedGuideList(JsonTable)
  local NowGuide = BeginnerGuideData:GetNowGuide()
  if nil ~= NowGuide and BeginnerGuideData:CheckGuideIsFinished(NowGuide.id) then
    UIMgr:Hide(ViewID.UI_BeginnerGuidanceSystemTips)
    EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
    UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel"):ClearNowGuideInfo()
  end
end

function BeginnerGuideModule:BindOnDataResetWhenLogin()
  if UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel") then
    UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel"):ClearNowGuideInfo()
  end
end

function BeginnerGuideModule:FinishGuide(GuideId, bIsSkip)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnBeginnerGuideFinished, GuideId)
  local GuideInfo = BeginnerGuideData.GuideList[GuideId]
  if GuideInfo and not GuideInfo.IsNotRequestToLobbyServer then
    if BeginnerGuideData:CheckGuideIsFinished(GuideId) then
      print("ywtao,GuideId" .. GuideId .. " is already finished")
      return
    end
    BeginnerGuideHandler.RequestFinishGuideToServer(GuideId)
    table.insert(BeginnerGuideData.FinishedGuideList, {guideID = GuideId, finishedTimes = 1})
  end
  BeginnerGuideData.NowGuideId = nil
  if bIsSkip then
    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
      GameInstance,
      function()
        if UIMgr:IsShow(ViewID.UI_LobbyMain) then
          EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow, true)
        end
      end
    })
  end
end

function BeginnerGuideModule:UpdateFinishedGuideList()
  BeginnerGuideHandler.RequestGetFinishedGuideListFromServer()
end

function BeginnerGuideModule:ShowInsideTip(TipIdList, _NowGuideId)
  local BeginnerGuidanceMainPanel = RGUIMgr:GetUI(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName)
  if not BeginnerGuidanceMainPanel or not RGUIMgr:IsShown(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName)
  end
  BeginnerGuidanceMainPanel = RGUIMgr:GetUI(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName)
  if BeginnerGuidanceMainPanel then
    BeginnerGuidanceMainPanel:RefreshInfoByTipIdList(TipIdList, _NowGuideId)
  end
end

function BeginnerGuideModule:BindOnBeginnerMissionFinished(MissionId)
  if nil ~= MissionId and MissionId == BeginnerGuideData.NowGuideId then
    print("ywtao,NowGuideId" .. BeginnerGuideData.NowGuideId .. " is over")
    UnListenObjectMessage(BeginnerGuideData:GetNowGuide().triggerevent, self)
    self:FinishGuide(BeginnerGuideData.NowGuideId)
  end
end

function BeginnerGuideModule:BindOnLobbyShow(bIsNotDelay)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.OnLobbyShowTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.OnLobbyShowTimer)
  end
  EventSystem.Invoke(EventDef.RootView.ShowOrHideMouseInputBlocking, true)
  if bIsNotDelay then
    BeginnerGuideModule:BindOnLobbyShowDelayFun()
  else
    self.OnLobbyShowTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        BeginnerGuideModule:BindOnLobbyShowDelayFun()
      end
    }, 0.5, false)
  end
end

function BeginnerGuideModule:TryHideMouseInputBlocking()
  if self.bCanRequestTeamGameFloorData or self.bCanRequestMyHeroInfo then
    print("ywtao,BeginnerGuideModule:TryHideMouseInputBlocking: bCanRequestTeamGameFloorData or bCanRequestMyHeroInfo is true")
    return
  end
  EventSystem.Invoke(EventDef.RootView.ShowOrHideMouseInputBlocking, false)
end

function BeginnerGuideModule:BindOnLobbyShowDelayFun()
  if not UIMgr:IsShow(ViewID.UI_LobbyMain) then
    print("ywtao,BeginnerGuideModule:BindOnLobbyShow: UI_LobbyMain is not shown")
    self:TryHideMouseInputBlocking()
    return
  end
  if #Logic_MainTask.CacheInviteDialogue > 0 then
    EventSystem.Invoke(EventDef.BeginnerGuide.OnInviteDialogueShow)
  end
  EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShowAndChecked)
  if self:BatchCheckGuideState({
    103,
    104,
    109,
    110,
    111,
    312,
    313
  }, "anynot") then
    DataMgr.GetOrQueryPlayerInfo({
      DataMgr.GetUserId()
    }, true, function(PlayerInfoList)
      for i, SingleInfo in ipairs(PlayerInfoList) do
        if SingleInfo.playerInfo.roleid == DataMgr.GetUserId() then
          DataMgr.SetBasicInfo(SingleInfo.playerInfo)
          break
        end
      end
      if self:BatchCheckGuideState({
        103,
        110,
        111,
        312,
        313
      }, "anynot") then
        local cb = function()
          self.bCanRequestTeamGameFloorData = false
          self:TryHideMouseInputBlocking()
          if not UIMgr:IsShow(ViewID.UI_LobbyMain) then
            print("ywtao,BeginnerGuideModule:BindOnLobbyShow: UI_LobbyMain is not shown")
            return
          end
          if LogicTeam.CurTeamState ~= LogicTeam.TeamState.Matching then
            if DataMgr.IsInTeam() and not LogicTeam.IsCaptain() then
              return
            end
            if DataMgr.GetFloorByGameModeIndex(23) > 1 and not BeginnerGuideData:CheckGuideIsFinished(110) then
              EventSystem.Invoke(EventDef.BeginnerGuide.OnRingedCityUnLockDifficulty2)
            end
            if DataMgr.GetFloorByGameModeIndex(24) > 0 and not BeginnerGuideData:CheckGuideIsFinished(103) then
              EventSystem.Invoke(EventDef.BeginnerGuide.OnBanditUnLock)
            end
            local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
            if DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode) > 0 and not BeginnerGuideData:CheckGuideIsFinished(111) and SystemUnlockModule and SystemUnlockModule:CheckIsSystemUnlock(7) then
              EventSystem.Invoke(EventDef.BeginnerGuide.OnClimbTowerUnLock)
            end
            if DataMgr.GetFloorByGameModeIndex(33, 3002) > 0 and not BeginnerGuideData:CheckGuideIsFinished(312) and SystemUnlockModule and SystemUnlockModule:CheckIsSystemUnlock(8) then
              EventSystem.Invoke(EventDef.BeginnerGuide.OnSurvivalUnLock)
            end
            if DataMgr.GetFloorByGameModeIndex(100, 3001) > 0 and not BeginnerGuideData:CheckGuideIsFinished(313) and SystemUnlockModule and SystemUnlockModule:CheckIsSystemUnlock(9) then
              EventSystem.Invoke(EventDef.BeginnerGuide.OnBossRushUnLock)
            end
          end
        end
        if self.bCanRequestTeamGameFloorData then
          LogicLobby.RequestGetGameFloorDataToServer(cb)
        else
          cb()
        end
      else
        self.bCanRequestTeamGameFloorData = false
        self:TryHideMouseInputBlocking()
      end
      if self:BatchCheckGuideState({
        101,
        104,
        109
      }, "anynot") then
        local callback = function()
          self.bCanRequestMyHeroInfo = false
          self:TryHideMouseInputBlocking()
          if not UIMgr:IsShow(ViewID.UI_LobbyMain) then
            print("ywtao,BeginnerGuideModule:BindOnLobbyShow: UI_LobbyMain is not shown")
            return
          end
          local CurHeroInfo = DataMgr.GetMyHeroInfo()
          local CurHeroId = CurHeroInfo.equipHero
          if not BeginnerGuideData:CheckGuideIsFinished(101) and (false ~= CurHeroInfo.hasSelectHero or not (CurHeroId <= 0)) then
            EventSystem.Invoke(EventDef.BeginnerGuide.OnInitialHeroSelected)
          end
          local CurProfyLevel = ProficiencyData:GetMaxUnlockProfyLevel(CurHeroId)
          print("ywtao\239\188\140BeginnerGuideModule:BindOnLobbyShow:curHeroId " .. CurHeroId .. " CurProfyLevel " .. CurProfyLevel)
          if not BeginnerGuideData:CheckGuideIsFinished(109) and CurProfyLevel >= 2 then
            if not ProficiencyData:IsCurProfyLevelRewardReceived(CurHeroId, 2) then
              EventSystem.Invoke(EventDef.BeginnerGuide.OnProficiencyUnlock)
            else
              self:FinishGuide(109)
            end
          end
          if not BeginnerGuideData:CheckGuideIsFinished(104) and CurProfyLevel >= 3 then
            if not ProficiencyData:IsCurProfyLevelRewardReceived(CurHeroId, 3) then
              EventSystem.Invoke(EventDef.BeginnerGuide.OnOwningSecondWeapon)
            else
              self:FinishGuide(104)
            end
          end
        end
        if self.bCanRequestMyHeroInfo then
          LogicRole.RequestMyHeroInfoToServer(callback)
        else
          callback()
        end
      else
        self.bCanRequestMyHeroInfo = false
        self:TryHideMouseInputBlocking()
      end
    end, function()
    end)
  else
    self.bCanRequestTeamGameFloorData = false
    self.bCanRequestMyHeroInfo = false
    self:TryHideMouseInputBlocking()
  end
  for _, GroupId in pairs(Logic_MainTask.GetActiveGroups()) do
    if 2 == Logic_MainTask.GetGroupActiveTask(GroupId).state then
      EventSystem.Invoke(EventDef.BeginnerGuide.OnMainTaskRewardUnlock)
      break
    end
  end
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and SystemUnlockModule:CheckIsSystemUnlock(3) and not BeginnerGuideData:CheckGuideIsFinished(105) then
    local AllPuzzlePackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
    if #AllPuzzlePackageInfo > 0 then
      EventSystem.Invoke(EventDef.BeginnerGuide.OnOwningPuzzle)
    else
      HttpCommunication.RequestByGet("hero/puzzlepackage", {
        GameInstance,
        function(Target, JsonResponse)
          local JsonTable = rapidjson.decode(JsonResponse.Content)
          if #JsonTable.puzzles > 0 then
            EventSystem.Invoke(EventDef.BeginnerGuide.OnOwningPuzzle)
          end
        end
      })
    end
  end
end

function BeginnerGuideModule:BindOnViewProrityQueueEmpty()
  EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
end

function BeginnerGuideModule:BindPandoraOnCloseRootPanel(AppId)
  if PandoraData:IsDisruptiveUI(AppId) then
    EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
  end
end

function BeginnerGuideModule:CheckDisableGuideView()
  local LobbyModule = ModuleManager:Get("LobbyModule")
  if LobbyModule.CurShowViewData ~= nil then
    print("ywtao, \229\189\147\229\137\141\230\156\137\229\188\185\231\170\151\230\152\190\231\164\186\239\188\140\228\184\141\232\167\166\229\143\145\229\188\149\229\175\188" .. UIDef[LobbyModule.CurShowViewData.ViewID].UIBP)
    return true
  end
  for _, ViewId in pairs(DisableGuideViews) do
    if UIMgr:IsShow(ViewId) then
      print("ywtao, \229\189\147\229\137\141\230\156\137\231\166\129\230\173\162\229\188\149\229\175\188\231\154\132\231\149\140\233\157\162\230\152\190\231\164\186: " .. UIDef[ViewId].UIBP)
      return true
    end
  end
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local CommonMsgWindowIsEmpty = WaveWindowManager:CheckWaveWindowIsEmptyByType(UE.EWaveWindowType.CommonMsg)
  if not CommonMsgWindowIsEmpty then
    print("ywtao, \229\189\147\229\137\141\230\156\137\231\166\129\230\173\162\229\188\149\229\175\188\231\154\132\233\128\154\231\148\168\230\182\136\230\129\175\231\170\151\229\143\163\230\152\190\231\164\186")
    return true
  end
  return false
end

function BeginnerGuideModule:BatchCheckGuideState(GuideIdList, CheckType)
  if type(GuideIdList) == "number" then
    GuideIdList = {GuideIdList}
  end
  if "alltrue" == CheckType then
    for _, GuideId in pairs(GuideIdList) do
      if not BeginnerGuideData:CheckGuideIsFinished(GuideId) then
        return false
      end
    end
    return true
  elseif "anynot" == CheckType then
    for _, GuideId in pairs(GuideIdList) do
      if not BeginnerGuideData:CheckGuideIsFinished(GuideId) then
        return true
      end
    end
    return false
  end
  return true
end

return BeginnerGuideModule
