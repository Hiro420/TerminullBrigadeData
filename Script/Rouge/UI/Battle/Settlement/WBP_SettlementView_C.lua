local ESettlementViewStatus = {
  FirstView = 1,
  RewardView = 2,
  TeamView = 3
}
local WBP_SettlementView_C = UnLua.Class()
local SkipInteract = 0.4
local SkipInteractTimerRate = 0.02
local FinisCountDown = 9
local SpaceActionName = "Space"
local EscActionName = "PauseGame"
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local Settlementconfig = require("GameConfig.Settlement.SettlementConfig")
local SaveGrowthSnapHandler = require("Protocol.SaveGrowthSnap.SaveGrowthSnapHandler")
function WBP_SettlementView_C:Construct()
  self.Overridden.Construct(self)
  self.MediaPlayer:SetLooping(false)
  self.MediaPlayer:Rewind()
  self.MediaPlayer:Pause()
  self:FinishSequence()
  self:SetRenderOpacity(0)
  if not IsListeningForInputAction(self, SpaceActionName) then
    ListenForInputAction(SpaceActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.SpaceKeyDown
    })
  end
  if not IsListeningForInputAction(self, EscActionName) then
    ListenForInputAction(EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.EscPressed
    })
    ListenForInputAction(EscActionName, UE.EInputEvent.IE_Released, true, {
      self,
      self.EscReleased
    })
  end
  self.Btn_LongPressJump.OnPressed:Add(self, self.EscPressed)
  self.Btn_LongPressJump.OnReleased:Add(self, self.EscReleased)
  EventSystem.AddListenerNew(EventDef.Settlement.ShowSettleTxt, self, self.ShowSettleTxt)
  EventSystem.AddListenerNew(EventDef.Settlement.HideSettleTxt, self, self.HideSettleTxt)
  UpdateVisibility(self.WBP_SettleInComeView, false)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.ShowInit
  }, 0.5, false)
  self.StepFadeInAniPlayed = {}
  self.StepFadeOutAniPlayed = {}
  self.AsyncLoadingEnd = false
  self.SkinId = -1
end
function WBP_SettlementView_C:FocusInput()
  self.Overridden.FocusInput(self)
end
function WBP_SettlementView_C:CanShowSequence()
  return self.AsyncLoadingEnd
end
function WBP_SettlementView_C:SpaceKeyDown()
  if self.CurSettleViewStep == ESettleViewStatus.ResultView then
    return
  end
  if self.CurSettleViewStep == ESettleViewStatus.MvpView and not self:CanShowSequence() then
    return
  end
  self:NextStep()
end
function WBP_SettlementView_C:EscPressed()
  if self.CurSettleViewStep == ESettleViewStatus.ResultView then
    return
  end
  if self.CurSettleViewStep == ESettleViewStatus.MvpView and self:CanShowSequence() or self.CurSettleViewStep == ESettleViewStatus.TeamView then
    self:EscReleased()
    self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.RefreshProgress
    }, SkipInteractTimerRate, true)
    self.StartTime = 0
    self:UpdateProgress(-1)
  end
end
function WBP_SettlementView_C:EscReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  self:UpdateProgress(-1)
  self.StartTime = 0
end
function WBP_SettlementView_C:RefreshProgress()
  if self.StartTime >= SkipInteract then
    if self.CurSettleViewStep == ESettleViewStatus.MvpView and self:CanShowSequence() or self.CurSettleViewStep == ESettleViewStatus.TeamView then
      self:ShowIncomeView()
      self:ExitTeamView()
      self:EscReleased()
    end
  else
    self.StartTime = self.StartTime + SkipInteractTimerRate
    self:UpdateProgress(self.StartTime / SkipInteract)
  end
end
function WBP_SettlementView_C:UpdateProgress(Percent)
  local Mat = self.URGImageCircle:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue("percent", Percent)
  end
end
function WBP_SettlementView_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
end
function WBP_SettlementView_C:OnOpenTalentClick()
  UpdateVisibility(self.WBP_SettlementTalentView, true)
  self.WBP_SettlementTalentView:InitSettlementTalentView()
end
function WBP_SettlementView_C:OpenSaveGrowthSnap()
  self.WBP_SaveGrowthSnap:ShowSnap()
  EventSystem.Invoke(EventDef.BeginnerGuide.OnClickOpenSnap)
end
function WBP_SettlementView_C:ShowSettlementPlayerInfoView(PlayerId)
  UpdateVisibility(self.CanvasPanelSkipToEnd, false)
  self.WBP_SettlementPlayerInfoView:InitSettlemntPlayerInfo(PlayerId)
end
function WBP_SettlementView_C:NextStep()
  if not self.CurSettleViewStep then
    return
  end
  if SettlementViewStepInfo[self.CurSettleViewStep] then
    local exitFuncName = SettlementViewStepInfo[self.CurSettleViewStep].ExitFuncName
    if exitFuncName and self[exitFuncName] then
      self[exitFuncName](self)
    end
  end
  self.StepTimer = 0
  self.CurSettleViewStep = self.CurSettleViewStep + 1
  if SettlementViewStepInfo[self.CurSettleViewStep] then
    self[SettlementViewStepInfo[self.CurSettleViewStep].FuncName](self)
    local aniName = SettlementViewStepInfo[self.CurSettleViewStep].AniName
    local aniTargetName = SettlementViewStepInfo[self.CurSettleViewStep].AniTargetName
    local target = self
    if aniTargetName and self[aniTargetName] then
      target = self[aniTargetName]
    end
    if aniName and "" ~= aniName and target[aniName] then
      target:PlayAnimation(target[aniName])
    end
  end
end
function WBP_SettlementView_C:ShowInit()
  self.CurSettleViewStep = 0
  self:NextStep()
end
function WBP_SettlementView_C:ShowMvp()
  local middleRole = LogicSettlement.GetMiddleRole()
  local leftRole = LogicSettlement.GetLeftRole()
  local rightRole = LogicSettlement.GetRightRole()
  middleRole:SetHiddenInGame(true)
  leftRole:SetHiddenInGame(true)
  rightRole:SetHiddenInGame(true)
  self.bAlreadyPlaySeq = false
  if LogicSettlement.ClearanceStatus == SettlementStatus.Finish then
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_1.La_MetaverseCenter_Finish_1'", true)
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_2.La_MetaverseCenter_Finish_2'", false)
    self.StateCtrl_Result:ChangeStatus(ESettleStatus.Succ)
  else
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_1.La_MetaverseCenter_Finish_1'", false)
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_2.La_MetaverseCenter_Finish_2'", true)
    self.StateCtrl_Result:ChangeStatus(ESettleStatus.Failed)
  end
  local camera = LogicSettlement.GetSettleCamera()
  if UE.RGUtil.IsUObjectValid(camera) then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      PC:SetViewTargetwithBlend(camera)
    end
  end
  self:SetRenderOpacity(1)
  UpdateVisibility(self, true)
  print("WBP_SettlementView_C:ShowMvp")
  if not LogicSettlement:CheckIsTeamClearance() then
    self:NextStep()
    return
  end
  local mvpPlayer = LogicSettlement:CalMvp()
  local playerList = LogicSettlement:GetOrInitPlayerList()
  local skinId = -1
  print("WBP_SettlementView_C:ShowMvp1", mvpPlayer.PlayerId)
  for i, v in ipairs(playerList) do
    if mvpPlayer.PlayerId == v.roleid then
      skinId = v.hero.skin
      break
    end
  end
  print("WBP_SettlementView_C:ShowMvp2", skinId)
  local bNeedPlayMovie = false
  if skinId > 0 then
    local result, row = GetRowData(DT.DT_HeirloomSkin, tostring(skinId))
    if result then
      local heirloogMediaData
      if result and row.HeirloomMediaDataAry:IsValidIndex(1) then
        heirloogMediaData = row.HeirloomMediaDataAry:Get(1)
      end
      local playerInfo = LogicSettlement:GetPlayerInfoByPlayerId(mvpPlayer.PlayerId)
      if playerInfo then
        print("WBP_SettlementView_C:ShowMvp3", playerInfo.name, playerInfo.hero.id)
        self.RGTextName:SetText(playerInfo.name)
        local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
        local RowInfo = CharacterTable[playerInfo.hero.id]
        if RowInfo then
          self.RGTextHeroName:SetText(RowInfo.Name)
        end
        self:PlayAnimation(self.Ani_in)
      end
      local viewModel = UIModelMgr:Get("SkinViewModel")
      if viewModel and viewModel.ShowSeq then
        self:PlayMovieSequence(skinId, heirloogMediaData)
        return
      end
      if heirloogMediaData then
        local MovieSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
        if MovieSubSys then
          local mediaSrc = MovieSubSys:GetMediaSource(heirloogMediaData.MediaId)
          if mediaSrc then
            if self.AkEventName ~= nil or self.AkEventName ~= "" then
              UE.UAudioManager.StopWwiseEventByName(self.AkEventName)
            end
            self.AkEventName = MovieSubSys:GetAkEventName(heirloogMediaData.MediaId)
            UE.UAudioManager.PlaySound2DByName(self.AkEventName, "SettlementView:ShowMvp")
            self.MediaPlayer.OnMediaReachedEnd:Add(self, self.MediaPlayerFinish)
            self.MediaPlayer:OpenSource(mediaSrc)
            self.MediaPlayer:SetLooping(false)
            self.MediaPlayer:Rewind()
            self.MediaPlayer:Play()
            local durationTimeSpan = self.MediaPlayer:GetDuration()
            local duration = UE.URGBlueprintLibrary.GetTimeSpanTicks(durationTimeSpan)
            self.SkipWidget:Init(duration, self.SpaceKeyDown, self)
            UpdateVisibility(self.CanvasPanelMvp, true)
            bNeedPlayMovie = true
            self.CurSettleViewStep = ESettleViewStatus.MvpView
            self.AsyncLoadingEnd = true
            UpdateVisibility(self.CanvasPanelSkipToEnd, true)
          end
        end
      end
    end
  end
  if not bNeedPlayMovie then
    self:NextStep()
  end
end
function WBP_SettlementView_C:ExitMvp()
  self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
  self.MediaPlayer:Pause()
  self:FinishSequence()
  UpdateVisibility(self.CanvasPanelMvp, false)
end
function WBP_SettlementView_C:ExitTeamView()
  UpdateVisibility(self.WBP_SettlementTeamView, false)
end
function WBP_SettlementView_C:MediaPlayerFinish()
  print("WBP_SettlementView_C:MediaPlayerFinish")
  if self.AkEventName ~= nil or self.AkEventName ~= "" then
    UE.UAudioManager.StopWwiseEventByName(self.AkEventName)
    self.AkEventName = ""
  end
  self:NextStep()
end
function WBP_SettlementView_C:ShowResultView()
  self.CurSettleViewStep = ESettleViewStatus.ResultView
  self.SkipWidget:Reset()
  UpdateVisibility(self.CanvasPanelText, true)
  UpdateVisibility(self.SkipWidget, false)
  UpdateVisibility(self.CanvasPanelSkipToEnd, false)
  print("WBP_SettlementView_C:ShowResultView")
  self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
  self.MediaPlayer:Pause()
  self:FinishSequence()
  self:PlayAnimation(self.Ani_settlement)
  if LogicSettlement:CheckIsTeamClearance() then
    self:PlaySeq(self.SeqShakeSoftObjPath)
  end
  SaveGrowthSnapHandler.RequestGetGrowthSnapShot()
end
function WBP_SettlementView_C:ExitResultView()
  UpdateVisibility(self.CanvasPanelText, false)
end
function WBP_SettlementView_C:ShowTeamView()
  print("WBP_SettlementView_C:ShowTeamView", LogicSettlement:CheckIsTeamClearance())
  self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
  self.MediaPlayer:Pause()
  self:FinishSequence()
  if LogicSettlement:CheckIsTeamClearance() then
    UpdateVisibility(self.CanvasPanelSkipToEnd, true)
    self.CurSettleViewStep = ESettleViewStatus.TeamView
    self.SkipWidget:Init(FinisCountDown, self.OnTeamViewFinish, self)
    UpdateVisibility(self.SkipWidget, true)
    UpdateVisibility(self.CanvasPanelMvp, false)
    UpdateVisibility(self.WBP_SettleInComeView, false)
    self.WBP_SettlementTeamView:InitSettlementTeamView(self)
    self.bHadShowTeamView = true
  else
    self:NextStep()
  end
end
function WBP_SettlementView_C:PlaySeq(SoftObjPath)
  local LevelSequenceAsset = UE.URGBlueprintLibrary.TryLoadSoftPath(SoftObjPath)
  if not LevelSequenceAsset then
    return
  end
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  self.SequencePlayerBG, self.SequenceActorBG = UE.ULevelSequencePlayer.CreateLevelSequencePlayer(self, LevelSequenceAsset, setting, nil)
  if self.SequencePlayerBG == nil or self.SequenceActorBG == nil then
    print("[WBP_SettlementView_C::Play] Player or SequenceActor is Empty!")
    return
  end
  self.SequencePlayerBG:Play()
end
function WBP_SettlementView_C:PlayMovieSequence(skinId, heirloogMediaData)
  local seq = LogicRole.GetSkinSequence(skinId)
  if not seq then
    self:LevelSequenceFinish()
    return
  end
  self.SkinId = skinId
  if self.SequencePlayer then
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
  end
  self:PlayAnimation(self.FadeStart)
  if self.AsyncLoadSequenceHandleID and self.AsyncLoadSequenceHandleID > 0 then
    UE.URGAssetManager.CancelAsyncLoad(self.AsyncLoadSequenceHandleID)
    self.AsyncLoadSequenceHandleID = nil
  end
  local Path = UE.UKismetSystemLibrary.BreakSoftObjectPath(seq)
  self.SoftObjPath = seq
  self.heirloogMediaData = heirloogMediaData
  self.AsyncLoadSequenceHandleID = UE.URGAssetManager.Lua_AsyncLoadAsset(Path, function(loadPath)
    self.AsyncLoadSequenceHandleID = nil
    self.AsyncLoadingEnd = true
    self:StartShowSequence()
  end, function()
    print("Failid async load asset: ", Path)
    self:LevelSequenceFinish()
  end)
  self.CurSettleViewStep = ESettleViewStatus.MvpView
  self:ShowOrHideLevel(skinId)
  UpdateVisibility(self.Mask, true)
end
function WBP_SettlementView_C:StartShowSequence()
  if not self:CanShowSequence() then
    return
  end
  local seqSubSys = UE.URGSequenceSubsystem.GetInstance(self)
  if not seqSubSys then
    self:LevelSequenceFinish()
    return
  end
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  local seq = LogicRole.GetSkinSequence(self.SkinId)
  self.SequencePlayer = seqSubSys:CreatePlayerFromLevelSequence(self, seq, setting)
  if self.SequencePlayer == nil then
    print("[WBP_SettlementView_C::Play] Player or SequenceActor is Empty!")
    self:LevelSequenceFinish()
    return
  end
  self.SequenceActor = self.SequencePlayer.SequenceActor
  if LogicRole.GetSequenceActor() then
    self.SequencePlayer:SetInstanceData(LogicRole.GetSequenceActor(), UE.FTransform())
  end
  self.SequencePlayer.OnFinished:Add(self, self.LevelSequenceFinish)
  self.SequencePlayer:Play()
  local duration = self.SequencePlayer:GetSequenceLength()
  duration = math.ceil(duration)
  self.SkipWidget:Init(duration, self.SpaceKeyDown, self)
  UpdateVisibility(self.CanvasPanelMvp, true)
  UpdateVisibility(self.URGImageMovie, false)
  UpdateVisibility(self.CanvasPanelSkipToEnd, true)
  if self.heirloogMediaData then
    local MovieSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
    if MovieSubSys then
      local mediaSrc = MovieSubSys:GetMediaSource(self.heirloogMediaData.MediaId)
      if mediaSrc then
        if nil ~= self.AkEventName or self.AkEventName ~= "" then
          UE.UAudioManager.StopWwiseEventByName(self.AkEventName)
        end
        self.AkEventName = MovieSubSys:GetAkEventName(self.heirloogMediaData.MediaId)
        UE.UAudioManager.PlaySound2DByName(self.AkEventName, "SettlementView:ShowMvp")
      end
    end
  end
  self:PlayAnimation(self.FadeOut)
end
function WBP_SettlementView_C:ShowOrHideLevel(SkinId)
  if self.SequenceLevel then
    self.SequenceLevel:SetShouldBeLoaded(false)
    self.SequenceLevel = nil
  end
  self:ShowOrHideCurrentLevel(not SkinId)
  if SkinId then
    local result, row = GetRowData(DT.DT_DisplaySkin, tostring(SkinId))
    if result and UE.UKismetSystemLibrary.IsValidSoftObjectReference(row.LevelSequenceLevelSoftPtr) then
      local transform = LogicRole.GetSequenceActor() and LogicRole.GetSequenceActor():GetTransform() or UE.FTransform()
      self.SequenceLevel = UE.ULevelToolBPLibrary.ExLoadStreamLevelByObj(GameInstance, row.LevelSequenceLevelSoftPtr, transform)
    end
  end
end
function WBP_SettlementView_C:LevelSequenceFinish()
  self:FinishSequence()
  self:NextStep()
end
function WBP_SettlementView_C:FinishSequence()
  if self.AsyncLoadSequenceHandleID and self.AsyncLoadSequenceHandleID > 0 then
    UE.URGAssetManager.CancelAsyncLoad(self.AsyncLoadSequenceHandleID)
    self.AsyncLoadSequenceHandleID = nil
    self:ShowOrHideLevel()
  end
  UpdateVisibility(self.Mask, false)
  if self.SequencePlayer then
    if nil ~= self.AkEventName or self.AkEventName ~= "" then
      UE.UAudioManager.StopWwiseEventByName(self.AkEventName)
      self.AkEventName = ""
    end
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
    self:ShowOrHideLevel()
  end
end
function WBP_SettlementView_C:ShowOrHideCurrentLevel(Visible)
  if not Visible then
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_1.La_MetaverseCenter_Finish_1'", false)
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_2.La_MetaverseCenter_Finish_2'", false)
  elseif LogicSettlement.ClearanceStatus == SettlementStatus.Finish then
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_1.La_MetaverseCenter_Finish_1'", true)
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_2.La_MetaverseCenter_Finish_2'", false)
  else
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_1.La_MetaverseCenter_Finish_1'", false)
    self:SetLevelStreamVis("World'/Game/Rouge/Map/MetaverseCenter/La_MetaverseCenter_Finish_2.La_MetaverseCenter_Finish_2'", true)
  end
end
function WBP_SettlementView_C:SetLevelStreamVis(LevelName, bVisible)
  local softPtr = MakeStringToSoftObjectReference(LevelName)
  local TargetStreamLevel = UE.ULevelToolBPLibrary.ExLoadStreamLevelByObj(GameInstance, softPtr, UE.FTransform())
  if TargetStreamLevel and TargetStreamLevel.bShouldBeVisible ~= bVisible then
    TargetStreamLevel:SetShouldBeVisible(bVisible)
  end
end
function WBP_SettlementView_C:UpdateRoleVisibility()
  local SelfPlayerId = LogicSettlement:GetOrInitSelfPlayerId()
  local playerInfo = LogicSettlement:GetPlayerInfoByPlayerId(SelfPlayerId)
  if playerInfo then
    local middleRole = LogicSettlement.GetMiddleRole()
    if not self.bHadShowTeamView then
      middleRole:ChangeBodyMesh(playerInfo.hero.id)
      middleRole:SetHiddenInGame(false)
      middleRole:UpdateAniInstBySkinId(playerInfo.hero.skin, LogicSettlement.ClearanceStatus == SettlementStatus.Finish)
      print("WBP_SettlementView_C:UpdateRoleVisibility MiddleRole ShowLightBySettlementResult", LogicSettlement.ClearanceStatus)
      middleRole:ShowLightBySettlementResult(LogicSettlement.ClearanceStatus)
      local playerPos
      if UE.RGUtil.IsUObjectValid(self.ParentView) then
        playerPos = self.ParentView.PlayerPosMap:Find(1)
      end
      if playerPos and playerPos.PlayerPos:IsValidIndex(1) then
        middleRole:K2_SetActorRelativeTransform(playerPos.PlayerPos:Get(1), false, nil, false)
      end
    end
    local CharacterRow = LogicRole.GetCharacterTableRow(playerInfo.hero.id)
    if CharacterRow then
      middleRole.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
  end
  if not LogicSettlement:CheckIsTeamClearance() then
    local leftRole = LogicSettlement.GetLeftRole()
    local rightRole = LogicSettlement.GetRightRole()
    leftRole:SetHiddenInGame(true)
    rightRole:SetHiddenInGame(true)
  end
end
function WBP_SettlementView_C:ShowIncomeView()
  self.SaveGrowthSnapTimer = 0
  self:FinishSequence()
  LogicSettlement.ResetBattleLagacy()
  self:ShowOrHideRoleLight(true)
  self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
  self.MediaPlayer:Pause()
  print("WBP_SettlementView_C:ShowIncomeView")
  self.CurSettleViewStep = ESettleViewStatus.IncomeView
  UpdateVisibility(self.CanvasPanelSkipToEnd, false)
  self:UpdateRoleVisibility()
  if not self.bAlreadyPlaySeq then
    local PlayerInfoList = LogicSettlement:GetOrInitPlayerList()
    local playerNum = #PlayerInfoList
    local playerPos
    playerPos = self.PlayerPosMap:Find(playerNum)
    local seqSubSys = UE.URGSequenceSubsystem.GetInstance(self)
    if playerPos and seqSubSys then
      self:PlaySeq(playerPos.SeqSoftPath)
    end
  end
  self.SkipWidget:Reset()
  UpdateVisibility(self.SkipWidget, false)
  UpdateVisibility(self.CanvasPanelMvp, false)
  self.WBP_SettleInComeView:ShowInComeView(self)
  self.bAlreadyPlaySeq = true
end
function WBP_SettlementView_C:ShowWeaponInfo(bIsShow, PresetWeaponId, PresetWeaponItem)
  UpdateVisibility(self.WBP_LobbyWeaponDisplayInfo, bIsShow)
  if bIsShow then
    local ToralResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPresetWeaponRes)
    if ToralResourceTable and ToralResourceTable[PresetWeaponId] then
      local BarrelId = ToralResourceTable[PresetWeaponId].BarrelID
      local AccessoryTb = {}
      if ToralResourceTable[PresetWeaponId].ArrSlot then
        for k, v in ipairs(ToralResourceTable[PresetWeaponId].ArrSlot) do
          table.insert(AccessoryTb, v.value)
        end
      end
      self.WBP_LobbyWeaponDisplayInfo:InitInfo(BarrelId, AccessoryTb)
    end
    local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
    if TipsCanvasSlot then
      local GeometryPresetWeaponItem = PresetWeaponItem:GetCachedGeometry()
      local GeometryPresetWeaponRoot = self.CanvasPanelRewardView:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryPresetWeaponRoot, GeometryPresetWeaponItem) + self.TipsOffset
      TipsCanvasSlot:SetPosition(Pos)
    end
  end
end
function WBP_SettlementView_C:OnTeamViewFinish()
  self:ExitTeamView()
  self:ShowIncomeView()
end
function WBP_SettlementView_C:ShowSettleTxt()
  local tagName = ""
  if LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish then
    tagName = "Succ"
  else
    tagName = "Failed"
  end
  local TxtActorList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, tagName, nil)
  for i, actorItem in iterator(TxtActorList) do
    actorItem:SetActorHiddenInGame(false)
  end
end
function WBP_SettlementView_C:HideSettleTxt()
  local tagName = ""
  if LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish then
    tagName = "Succ"
  else
    tagName = "Failed"
  end
  local TxtActorList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, tagName, nil)
  for i, actorItem in iterator(TxtActorList) do
    actorItem:SetActorHiddenInGame(true)
  end
end
function WBP_SettlementView_C:Destruct()
  EventSystem.RemoveListenerNew(EventDef.Settlement.ShowSettleTxt, self, self.ShowSettleTxt)
  EventSystem.RemoveListenerNew(EventDef.Settlement.HideSettleTxt, self, self.HideSettleTxt)
  self:UnfocusInput()
  self:UnbindAllFromAnimationFinished(self.ani_settlementview_success_in)
  self:UnbindAllFromAnimationFinished(self.ani_settlementview_success_out)
  self.BP_ButtonWithSoundTalent.OnClicked:Remove(self, self.OnOpenTalentClick)
  self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
end
function WBP_SettlementView_C:LuaTick(InDeltaTime)
  if self.CurSettleViewStep and SettlementViewStepInfo[self.CurSettleViewStep] then
    self.StepTimer = self.StepTimer + InDeltaTime
    if SettlementViewStepInfo[self.CurSettleViewStep].FadeOutAniStartTime and not self.StepFadeOutAniPlayed[self.CurSettleViewStep] and self.StepTimer > SettlementViewStepInfo[self.CurSettleViewStep].FadeOutAniStartTime then
      local aniName = SettlementViewStepInfo[self.CurSettleViewStep].FadeOutAniName
      local aniTargetName = SettlementViewStepInfo[self.CurSettleViewStep].AniTargetName
      local target = self
      if aniTargetName and self[aniTargetName] then
        target = self[aniTargetName]
      end
      if aniName and "" ~= aniName and target[aniName] then
        target:PlayAnimation(target[aniName])
        self.StepFadeOutAniPlayed[self.CurSettleViewStep] = true
      end
    end
    local aniName = SettlementViewStepInfo[self.CurSettleViewStep].AniName
    local aniTargetName = SettlementViewStepInfo[self.CurSettleViewStep].AniTargetName
    local target = self
    if aniTargetName and self[aniTargetName] then
      target = self[aniTargetName]
    end
    if aniName and "" ~= aniName and target[aniName] and not self.StepFadeInAniPlayed[self.CurSettleViewStep] then
      if not SettlementViewStepInfo[self.CurSettleViewStep].FadeInAniStartTime then
        SettlementViewStepInfo[self.CurSettleViewStep].FadeInAniStartTime = 0
      end
      if self.StepTimer > SettlementViewStepInfo[self.CurSettleViewStep].FadeInAniStartTime then
        target:PlayAnimation(target[aniName])
        self.StepFadeInAniPlayed[self.CurSettleViewStep] = true
      end
    end
    if self.StepTimer > SettlementViewStepInfo[self.CurSettleViewStep].Duration then
      self:NextStep()
    end
  end
  if LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish and not self.bSaveGrowthSnapexpire and self.CurSettleViewStep == ESettleViewStatus.IncomeView then
    self.SaveGrowthSnapTimer = self.SaveGrowthSnapTimer + InDeltaTime
    if self.SaveGrowthSnapTimer >= self.SaveGrowthSnapCountDown then
      LogicSettlement:CheckAndAutoSaveGrowth()
      self.bSaveGrowthSnapexpire = true
      self.WBP_SaveGrowthSnap:UpdateExpire()
      if BeginnerGuideData.NowGuideId == 310 then
        local ViewModel = UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel")
        ViewModel:FinishNowGuide()
        UIMgr:Hide(ViewID.UI_BeginnerGuidanceSystemTips)
      end
      if LogicSettlement:GetGameModeType() == UE.EGameModeType.TowerClimb then
        UpdateVisibility(self.WBP_SettlementPlayerInfoView.Btn_SaveGrowthSnap, false)
        UpdateVisibility(self.WBP_SettlementPlayerInfoView.WBP_SaveGrowth_AutoSave, false)
        self.WBP_SettleInComeView:RefreshBtnSaveGrowthSnapVis()
      end
    end
  end
end
function WBP_SettlementView_C:ShowOrHideRoleLight(bIsShow)
  local middleRole = LogicSettlement.GetMiddleRole()
  local leftRole = LogicSettlement.GetLeftRole()
  local rightRole = LogicSettlement.GetRightRole()
  if UE.RGUtil.IsUObjectValid(middleRole) then
    local middleRoleChildActorComp = middleRole.ChildActor
    local middleRoleActor = middleRoleChildActorComp.ChildActor
    if middleRoleActor.Scene then
      middleRoleActor.Scene:SetHiddenInGame(not bIsShow)
    elseif middleRoleActor.LobbyLight then
      middleRoleActor.LobbyLight:SetHiddenInGame(not bIsShow)
    end
  end
  if UE.RGUtil.IsUObjectValid(leftRole) then
    local leftRoleChildActorComp = leftRole.ChildActor
    local leftRoleActor = leftRoleChildActorComp.ChildActor
    if leftRoleActor.Scene then
      leftRoleActor.Scene:SetHiddenInGame(not bIsShow)
    elseif leftRoleActor.LobbyLight then
      leftRoleActor.LobbyLight:SetHiddenInGame(not bIsShow)
    end
  end
  if UE.RGUtil.IsUObjectValid(rightRole) then
    local rightRoleChildActorComp = rightRole.ChildActor
    local rightRoleActor = rightRoleChildActorComp.ChildActor
    if rightRoleActor.Scene then
      rightRoleActor.Scene:SetHiddenInGame(not bIsShow)
    elseif rightRoleActor.LobbyLight then
      rightRoleActor.LobbyLight:SetHiddenInGame(not bIsShow)
    end
  end
end
return WBP_SettlementView_C
