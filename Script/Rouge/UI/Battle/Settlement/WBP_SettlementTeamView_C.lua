local SettlementConfig = require("GameConfig.Settlement.SettlementConfig")
local WBP_SettlementTeamView_C = UnLua.Class()
local FinisCountDown = 9

function WBP_SettlementTeamView_C:Construct()
  self.DamageItemClass = UE.UClass.Load("/Game/Rouge/UI/Battle/WBP_SingleDamageItem.WBP_SingleDamageItem_C")
end

function WBP_SettlementTeamView_C:InitSettlementTeamView(ParentView)
  print("WBP_SettlementTeamView_C:InitSettlementTeamView")
  UpdateVisibility(self, true)
  self.ParentView = ParentView
  self:UpdateView()
  self.delayTimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      if self and self.ParentView then
        self.ParentView:ShowOrHideRoleLight(true)
      end
    end
  }, SettlementConfig.ShowRoleLightTime, false)
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
  end
  if LogicSettlement.ClearanceStatus == SettlementStatus.Finish then
    self.StateCtrl_Result:ChangeStatus(ESettleStatus.Succ)
  else
    self.StateCtrl_Result:ChangeStatus(ESettleStatus.Failed)
  end
end

function WBP_SettlementTeamView_C:PlaySeq(SoftObjPath)
  local LevelSequenceAsset = UE.URGBlueprintLibrary.TryLoadSoftPath(SoftObjPath)
  if not LevelSequenceAsset then
    return
  end
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  self.SequencePlayer, self.SequenceActor = UE.ULevelSequencePlayer.CreateLevelSequencePlayer(self, LevelSequenceAsset, setting, nil)
  if self.SequencePlayer == nil or self.SequenceActor == nil then
    print("[WBP_SettlementInComeView_C::Play] Player or SequenceActor is Empty!")
    return
  end
  self.SequencePlayer:Play()
end

function WBP_SettlementTeamView_C:UpdateView()
  local Diff = LogicSettlement:GetClearanceDifficulty()
  self.RGTextDiffculty:SetText(Diff)
  local Duration = math.floor(LogicSettlement:GetClearanceDuration())
  local Hour = math.floor(Duration / 3600)
  local Min = math.floor((Duration - Hour * 3600) / 60)
  local Sec = Duration - Hour * 3600 - Min * 60
  local TimeStr = string.format("%02d:%02d:%02d", Hour, Min, Sec)
  self.RGTextTime:SetText(TimeStr)
  local gameMode = LogicSettlement:GetGameMode()
  local result, row = GetRowData(DT.DT_GameMode, tostring(gameMode))
  if result then
    self.RGTextWorld:SetText(row.Name)
  end
  local PlayerTitleList = LogicSettlement:CalcTitle()
  local MvpPlayer = LogicSettlement:CalMvp()
  local SelfPlayerId = LogicSettlement:GetOrInitSelfPlayerId()
  local PlayerInfoList = LogicSettlement:GetOrInitPlayerList()
  local Index = 1
  local playerPos
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    playerPos = self.ParentView.PlayerPosMap:Find(#PlayerInfoList)
  end
  local playerInfo = LogicSettlement:GetPlayerInfoByPlayerId(SelfPlayerId)
  if playerInfo then
    self.SettlementTeamPlayerItemSelf:InitPlayerInfo(SelfPlayerId, playerInfo.name, playerInfo.hero.id, self)
    self.SettlementTeamPlayerItemSelf:InitTitle(PlayerTitleList[SelfPlayerId])
    self.SettlementTeamPlayerItemSelf:InitMvp(MvpPlayer)
    local middleRole = LogicSettlement.GetMiddleRole()
    print("WBP_SettlementTeamView_C:UpdateView UpdateView", playerInfo.hero.skin)
    middleRole:ChangeBodyMesh(playerInfo.hero.id, playerInfo.hero.skin)
    if playerInfo.weapons:IsValidIndex(1) then
      middleRole:ChangeWeaponMeshBySkinId(playerInfo.weapons:GetRef(1).skin)
    end
    middleRole:UpdateAniInstBySkinId(playerInfo.hero.skin, LogicSettlement.ClearanceStatus == SettlementStatus.Finish)
    middleRole:SetHiddenInGame(false)
    middleRole:ShowLightBySettlementResult(LogicSettlement.ClearanceStatus)
    if 1 == #PlayerInfoList then
      if playerPos and playerPos.PlayerPos:IsValidIndex(1) then
        middleRole:K2_SetActorRelativeTransform(playerPos.PlayerPos:GetRef(1), false, nil, false)
      end
    elseif playerPos and playerPos.PlayerPos:IsValidIndex(2) then
      middleRole:K2_SetActorRelativeTransform(playerPos.PlayerPos:GetRef(2), false, nil, false)
    end
  end
  if 1 == #PlayerInfoList then
    UpdateVisibility(self.CanvasPanel_three_ying, false)
    UpdateVisibility(self.CanvasPanel_Two_ying, false)
    UpdateVisibility(self.CanvasPanel_three, false)
    UpdateVisibility(self.CanvasPanel_Two, false)
  elseif LogicSettlement.ClearanceStatus == SettlementStatus.Finish then
    UpdateVisibility(self.CanvasPanel_three_ying, 3 == #PlayerInfoList)
    UpdateVisibility(self.CanvasPanel_Two_ying, 2 == #PlayerInfoList)
    UpdateVisibility(self.CanvasPanel_three, false)
    UpdateVisibility(self.CanvasPanel_Two, false)
  else
    UpdateVisibility(self.CanvasPanel_three, 3 == #PlayerInfoList)
    UpdateVisibility(self.CanvasPanel_Two, 2 == #PlayerInfoList)
    UpdateVisibility(self.CanvasPanel_three_ying, false)
    UpdateVisibility(self.CanvasPanel_Two_ying, false)
  end
  self.SettlementTeamPlayerItemRight:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.SettlementTeamPlayerItemLeft:SetVisibility(UE.ESlateVisibility.Collapsed)
  local leftRole = LogicSettlement.GetLeftRole()
  local rightRole = LogicSettlement.GetRightRole()
  leftRole:SetHiddenInGame(true)
  rightRole:SetHiddenInGame(true)
  for i, v in ipairs(PlayerInfoList) do
    if v and v.roleid ~= SelfPlayerId then
      if 1 == Index then
        print("WBP_SettlementTeamView_C:UpdateView()", v.roleid, v.name, v.hero.id)
        self.SettlementTeamPlayerItemLeft:InitPlayerInfo(v.roleid, v.name, v.hero.id, self)
        self.SettlementTeamPlayerItemLeft:InitTitle(PlayerTitleList[v.roleid])
        self.SettlementTeamPlayerItemLeft:InitMvp(MvpPlayer)
        self.SettlementTeamPlayerItemLeft:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        Index = Index + 1
        leftRole:SetHiddenInGame(false)
        local EffectState = LogicTeam.GetMemberHeroEffectState(v.roleid, v.hero.skin)
        leftRole:ChangeBodyMesh(v.hero.id, v.hero.skin, nil, nil, nil, EffectState)
        leftRole:ShowLightBySettlementResult(LogicSettlement.ClearanceStatus)
        if v.weapons:IsValidIndex(1) then
          leftRole:ChangeWeaponMeshBySkinId(v.weapons:GetRef(1).skin)
        end
        leftRole:UpdateAniInstBySkinId(v.hero.skin, LogicSettlement.ClearanceStatus == SettlementStatus.Finish)
        if playerPos and playerPos.PlayerPos:IsValidIndex(1) then
          leftRole:K2_SetActorRelativeTransform(playerPos.PlayerPos:Get(1), false, nil, false)
        end
      elseif 2 == Index then
        print("WBP_SettlementTeamView_C:UpdateView()11", v.roleid, v.name, v.hero.id)
        self.SettlementTeamPlayerItemRight:InitPlayerInfo(v.roleid, v.name, v.hero.id, self)
        self.SettlementTeamPlayerItemRight:InitTitle(PlayerTitleList[v.roleid])
        self.SettlementTeamPlayerItemRight:InitMvp(MvpPlayer)
        self.SettlementTeamPlayerItemRight:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        Index = Index + 1
        rightRole:SetHiddenInGame(false)
        local EffectState = LogicTeam.GetMemberHeroEffectState(v.roleid, v.hero.skin)
        rightRole:ChangeBodyMesh(v.hero.id, v.hero.skin, nil, nil, nil, EffectState)
        rightRole:ShowLightBySettlementResult(LogicSettlement.ClearanceStatus)
        if v.weapons:IsValidIndex(1) then
          rightRole:ChangeWeaponMeshBySkinId(v.weapons:GetRef(1).skin)
        end
        rightRole:UpdateAniInstBySkinId(v.hero.skin, LogicSettlement.ClearanceStatus == SettlementStatus.Finish)
        if playerPos and playerPos.PlayerPos:IsValidIndex(3) then
          rightRole:K2_SetActorRelativeTransform(playerPos.PlayerPos:Get(3), false, nil, false)
        end
      end
    end
  end
  self.ParentView:ShowOrHideRoleLight(false)
end

function WBP_SettlementTeamView_C:ShowSettlementPlayerInfoView(PlayerId)
  self.ParentView:ShowSettlementPlayerInfoView(PlayerId)
end

function WBP_SettlementTeamView_C:ListenForEscInputAction()
  self.SkipWidget:Reset()
end

function WBP_SettlementTeamView_C:FadeOut()
  self:StopAnimation(self.Ani_in2)
  self:PlayAnimation(self.Ani_out)
end

function WBP_SettlementTeamView_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    if UE.RGUtil.IsUObjectValid(self.SequencePlayer) and not self.SequencePlayer:IsPaused() then
      UE.URGBlueprintLibrary.JumpToEnd(self.SequencePlayer)
    end
    UpdateVisibility(self, false)
  end
end

function WBP_SettlementTeamView_C:UnInit()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TeamTimer)
  end
end

function WBP_SettlementTeamView_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.delayTimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.delayTimerHandle)
  end
end

return WBP_SettlementTeamView_C
