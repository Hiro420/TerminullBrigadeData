local ShowType = {
  Normal = 0,
  MaxForSmaller = 1,
  MaxForLarger = 2
}
local WBP_MovieShow_C = UnLua.Class()

function WBP_MovieShow_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  ListenObjectMessage(nil, GMP.MSG_AI_OnAISpawned, self, self.OnAISpawned)
  EventSystem.AddListenerNew(EventDef.BossTips.BossTipsMovie, self, self.BindOnBossTipsMovie)
  self:InitBossInfo()
end

function WBP_MovieShow_C:OnUnDisplay(bIsPlaySound)
  self.Overridden.OnUnDisplay(self, bIsPlaySound)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerDel) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerDel)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HideTimerDel) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HideTimerDel)
  end
  UpdateVisibility(self.CanvasPanelMonsterInfo, false)
  UnListenObjectMessage(GMP.MSG_AI_OnAISpawned, self)
  EventSystem.RemoveListenerNew(EventDef.BossTips.BossTipsMovie, self, self.BindOnBossTipsMovie)
end

function WBP_MovieShow_C:BindOnBossTipsMovie()
end

function WBP_MovieShow_C:OnShowMovie()
  if not self.MoviePlayer then
    print("WBP_MovieShow_C:OnShowMovie MoviePlayer Is Nil")
    return
  end
  local MovieId = self.MoviePlayer.CurrPlayingMovieId
  local IsSequenceCG = self.MoviePlayer:IsPlaySequenceCG()
  local IsSequenceCGPlaying = self.MoviePlayer:IsPlaying()
  if IsSequenceCG and IsSequenceCGPlaying then
    UpdateVisibility(self.CanvasPanelMovie, false)
    UpdateVisibility(self.MoviePanel, false)
    UpdateVisibility(self.MoviePanelSpecial, false)
  else
    local CurrMediaId = self.MoviePlayer.CurrMediaId
    local resultCur, rowCur = GetRowData(DT.DT_MediaSource, CurrMediaId)
    UpdateVisibility(self.CanvasPanelMovie, true)
    UpdateVisibility(self.MoviePanel, false)
    UpdateVisibility(self.MoviePanelSpecial, false)
    if resultCur then
      if rowCur.AdaptationType == ShowType.MaxForSmaller then
        UpdateVisibility(self.CanvasPanelMovie, false)
        UpdateVisibility(self.MoviePanel, true)
        UpdateVisibility(self.MoviePanelSpecial, false)
      elseif rowCur.AdaptationType == ShowType.MaxForLarger then
        UpdateVisibility(self.CanvasPanelMovie, false)
        UpdateVisibility(self.MoviePanel, false)
        UpdateVisibility(self.MoviePanelSpecial, true)
      else
        UpdateVisibility(self.CanvasPanelMovie, true)
        UpdateVisibility(self.MoviePanel, false)
        UpdateVisibility(self.MoviePanelSpecial, false)
      end
    end
  end
  print("WBP_MovieShow_C:OnShowMovie", MovieId)
  local result, row = GetRowData(DT.DT_MoviePlaySetting, tostring(MovieId))
  if result and row.MovieTipsType == UE.EMovieTipsType.EMovieTips then
    UpdateVisibility(self.CanvasPanelMonsterInfo, false)
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerDel) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerDel)
    end
    self.TimerDel = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        print("WBP_MovieShow_C:OnShowMovie Timer Finish")
        self:ShowMonsterInfo()
      end
    }, row.MonsterInfoShowDelay, false)
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HideTimerDel) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HideTimerDel)
    end
    self.HideTimerDel = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        print("WBP_MovieShow_C:OnShowMovie HideTimer Finish")
        self:HideMonsterInfo()
      end
    }, row.MonsterInfoHideDelay, false)
  end
end

function WBP_MovieShow_C:OnAISpawned(AIActor)
  print("WBP_MovieShow_C:OnAISpawned()", UE.RGUtil.IsUObjectValid(AIActor))
  if UE.RGUtil.IsUObjectValid(AIActor) and AIActor:IsBossAI() then
    print("WBP_MovieShow_C:OnAISpawned111()")
    self:InitBossInfo()
  end
end

function WBP_MovieShow_C:InitBossInfo()
  local BossActor = self:GetBossActor()
  print("WBP_MovieShow_C:InitBossInfo", BossActor)
  if BossActor then
    self.BossTypeId = BossActor:GetTypeID()
    print("WBP_MovieShow_C:InitBossInfo BossTypeId", BossActor, self.BossTypeId)
  end
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local Difficulty = 0
  if LevelSubSystem then
    Difficulty = LevelSubSystem:GetDifficulty()
  end
  local R, RowInfo = GetRowData(DT.DT_BossBarConfig, Difficulty)
  if R then
    UpdateVisibility(self.MonsterTag, UE.URGBlueprintLibrary.IsValidSoftObjectPath(RowInfo.Icon) and RowInfo.bShowIconInTips)
    UpdateVisibility(self.boss_icon, RowInfo.bUsingDynamicMaterials)
    UpdateVisibility(self.DifficultyIcon, not RowInfo.bUsingDynamicMaterials)
    SetImageBrushBySoftObjectPath(self.DifficultyIcon, RowInfo.Icon)
    self.TagText:SetText(RowInfo.TagText)
  end
end

function WBP_MovieShow_C:GetBossActor()
  local aiCharacterActorAry = UE.UGameplayStatics.GetAllActorsOfClass(self, UE.AAICharacterBase.StaticClass(), nil)
  for i, v in iterator(aiCharacterActorAry) do
    if UE.RGUtil.IsUObjectValid(v) and v.IsBossAI and v:IsBossAI() then
      return v
    end
  end
  local aiPawnActorAry = UE.UGameplayStatics.GetAllActorsOfClass(self, UE.AAIPawnBase.StaticClass(), nil)
  for i, v in iterator(aiPawnActorAry) do
    if UE.RGUtil.IsUObjectValid(v) and v.IsBossAI and v:IsBossAI() then
      return v
    end
  end
  return nil
end

function WBP_MovieShow_C:ShowMonsterInfo()
  print("WBP_MovieShow_C:ShowMonsterInfo", self.BossTypeId)
  if not self.BossTypeId then
    print("WBP_MovieShow_C:ShowMonsterInfo BossTypeId Is nil")
    return
  end
  local result, row = GetRowData(DT.DT_Monster, tostring(self.BossTypeId))
  print("WBP_MovieShow_C:ShowMonsterInfo11", self.BossTypeId, result, row)
  if result then
    local Name = ""
    if "" ~= tostring(row.NickName) then
      Name = string.format("%s(%s)", row.Desc, row.NickName)
    else
      Name = row.Desc
    end
    self.RGTextMonsterName:SetText(Name)
    self.RGTextMonsterName_1:SetText(Name)
    self.RGTextMonsterTitle:SetText(row.Title)
    self.RGTextMonsterTitle_1:SetText(row.Title)
    UpdateVisibility(self.CanvasPanelMonsterInfo, true)
    self:PlayAni_In()
  else
    print("WBP_MovieShow_C:ShowMonsterInfo BossTypeId Is InValid", self.BossTypeId)
  end
end

function WBP_MovieShow_C:HideMonsterInfo()
  self:PlayAni_Out()
end

function WBP_MovieShow_C:PlayAni_In()
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  if LevelSubSystem and LevelSubSystem:GetMatchGameMode() == TableEnums.ENUMGameMode.BOSSRUSH then
    self:PlayAnimation(self.Ani_Season_in)
    return
  end
  self:PlayAnimation(self.AniFadeIn)
end

function WBP_MovieShow_C:PlayAni_Out()
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  if LevelSubSystem and LevelSubSystem:GetMatchGameMode() == TableEnums.ENUMGameMode.BOSSRUSH then
    self:PlayAnimation(self.Ani_Season_out)
    return
  end
  self:PlayAnimation(self.AniFadeOut)
end

return WBP_MovieShow_C
