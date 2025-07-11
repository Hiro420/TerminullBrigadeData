local WBP_LevelCleanTips_C = UnLua.Class()
function WBP_LevelCleanTips_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_LevelCleanTips_C:Init()
  ListenObjectMessage(nil, GMP.MSG_Level_BattleChange, self, self.Show)
  ListenObjectMessage(nil, GMP.MSG_FinishPlayMovie, self, self.OnFinisPlayMovie)
  ListenObjectMessage(nil, GMP.MSG_AI_OnAISpawned, self, self.OnAISpawned)
  ListenObjectMessage(nil, GMP.MSG_Level_OnLevelEntry, self, self.OnLevelEntry)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelPass, self, self.OnLevelPass)
  self.BossTypeId = -1
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem:StaticClass())
  if GameLevelSystem and GameLevelSystem:ClientIsInNewLevel() then
    print("WBP_EnterLevelTips_C:Show2 ", GameLevelSystem:GetLevelId())
    self:OnLevelEntry(GameLevelSystem:GetLevelId())
  end
end
function WBP_LevelCleanTips_C:OnLevelEntry(LevelId)
  print("WBP_LevelCleanTips_C:OnLevelEntry", LevelId)
  print("WBP_LevelCleanTips_C:Init()")
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem:StaticClass())
  if GameLevelSystem then
    local LevelId = GameLevelSystem:GetLevelId()
    print("WBP_LevelCleanTips_C:Init111()", LevelId)
    self.LevelId = LevelId
    local Result, RowData = GetRowData(DT.DT_WorldLevelPool, LevelId)
    print("WBP_LevelCleanTips_C:Init222()", LevelId, Result, RowData)
    if Result then
      self.LevelType = RowData.LevelType
      print("WBP_LevelCleanTips_C:Init333()", LevelId, Result, RowData, self.LevelType, UE.ERGLevelType.BossRoom)
      if RowData.LevelType == UE.ERGLevelType.BossRoom then
        self:InitBossInfo()
      end
    end
  end
end
function WBP_LevelCleanTips_C:UnInit()
  UnListenObjectMessage(GMP.MSG_Level_BattleChange, self)
  UnListenObjectMessage(GMP.MSG_FinishPlayMovie, self)
  UnListenObjectMessage(GMP.MSG_AI_OnAISpawned, self)
  UnListenObjectMessage(GMP.MSG_Level_OnLevelEntry, self)
  UnListenObjectMessage(GMP.MSG_Level_LevelPass, self)
end
function WBP_LevelCleanTips_C:OnFinisPlayMovie(CurrMovieId)
  local Result, MovieData = GetRowData(DT.DT_MoviePlaySetting, tostring(CurrMovieId))
  if Result and MovieData.MovieType == UE.EMovieType.EBossDeath then
    print("WBP_LevelCleanTips_C:OnFinisPlayMovie", CurrMovieId)
    self:ShowBossInfo()
  end
end
function WBP_LevelCleanTips_C:OnAISpawned(AIActor)
  print("WBP_LevelCleanTips_C:OnAISpawned()", UE.RGUtil.IsUObjectValid(AIActor))
  if UE.RGUtil.IsUObjectValid(AIActor) and AIActor:IsBossAI() then
    print("WBP_LevelCleanTips_C:OnAISpawned111()")
    self:InitBossInfo()
  end
end
function WBP_LevelCleanTips_C:InitBossInfo()
  local BossActor = self:GetBossActor()
  print("WBP_LevelCleanTips_C:InitBossInfo", BossActor)
  if BossActor then
    self.BossTypeId = BossActor:GetTypeID()
    print("WBP_LevelCleanTips_C:InitBossInfo BossTypeId", BossActor, self.BossTypeId)
  end
end
function WBP_LevelCleanTips_C:GetBossActor()
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
function WBP_LevelCleanTips_C:OnLevelPass(LevelId)
  print("WBP_LevelCleanTips_C:OnLevelPass", LevelId)
  if self.LevelType == UE.ERGLevelType.BossRoom then
    print("WBP_LevelCleanTips_C:OnLevelPass11")
    self:ShowCleanTips()
  end
end
function WBP_LevelCleanTips_C:OnAnimationFinished(Ani)
  if Ani == self.TaskAni then
    UpdateVisibility(self.CanvasPanelNormal, false)
  elseif Ani == self.BossAni then
    UpdateVisibility(self.CanvasPanelBoss, false)
  end
end
function WBP_LevelCleanTips_C:ShowCleanTips()
  print("WBP_LevelCleanTips_C:Show BossRoom ShowCleanTips")
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem:StaticClass())
  if not GameLevelSystem then
    return
  end
  local LevelId = GameLevelSystem:GetLevelId()
  local Result, RowData = GetRowData(DT.DT_WorldLevelPool, LevelId)
  if not Result then
    return
  end
  UpdateVisibility(self, true)
  UpdateVisibility(self.CanvasPanelNormal, RowData.LevelType == UE.ERGLevelType.LevelRoom)
  UpdateVisibility(self.CanvasPanelBoss, RowData.LevelType == UE.ERGLevelType.BossRoom)
  self:PlayAnimation(self.TaskAni)
  if RowData.LevelType == UE.ERGLevelType.LevelRoom then
    self:PlayAnimation(self.NormalAni)
    local Desc = RowData.CleanTipsData.TipsDesc
    if tostring(Desc) == "" then
      Desc = self.NormalDefaultDesc
    end
    self.RGTextNormalDesc_touying:SetText(Desc)
    self.RGTextNormalDesc:SetText(Desc)
    self.RGTextBossDesc:SetText(Desc)
    self.RGTextBossDesc_touying:SetText(Desc)
  elseif RowData.LevelType == UE.ERGLevelType.BossRoom then
    print("WBP_LevelCleanTips_C:Show BossRoom ShowBossInfo")
    self:ShowBossInfo()
  end
end
function WBP_LevelCleanTips_C:Show(LevelBattleActor, RGBattleState)
  print("WBP_LevelCleanTips_C:Show", RGBattleState)
  if RGBattleState ~= UE.ERGBattleState.Finished then
    return
  end
  if self.LevelType ~= UE.ERGLevelType.BossRoom then
    local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
    if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
      print("WBP_LevelCleanTips_C:ShowCleanTips \230\150\176\230\137\139\229\133\179\228\184\141\230\143\144\231\164\186\233\128\154\229\133\179\230\143\144\231\164\186")
      return
    end
    print("WBP_LevelCleanTips_C:Show11", RGBattleState)
    self:ShowCleanTips()
  end
end
function WBP_LevelCleanTips_C:ShowBossInfo()
  local Result, RowData = GetRowData(DT.DT_WorldLevelPool, self.LevelId)
  if not Result then
    return
  end
  self:PlayAnimation(self.BossAni)
  UpdateVisibility(self.CanvasPanelBoss, true)
  local ResultMonster, RowMonsterData = GetRowData(DT.DT_Monster, self.BossTypeId)
  print("WBP_LevelCleanTips_C:Show BossRoom", self.BossTypeId, ResultMonster, RowMonsterData)
  if ResultMonster then
    local TipsDesc = RowData.CleanTipsData.TipsDesc
    if tostring(TipsDesc) == "" then
      TipsDesc = self.BossDefaultDesc
    end
    local Desc = UE.FTextFormat(TipsDesc, RowMonsterData.Desc)
    self.RGTextBossDesc_touying:SetText(Desc)
    self.RGTextBossDesc:SetText(Desc)
  end
end
function WBP_LevelCleanTips_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_LevelCleanTips_C:Destruct()
  self.Overridden.Destruct(self)
end
return WBP_LevelCleanTips_C
