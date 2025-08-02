local WBP_EnterLevelTips_C = UnLua.Class()

function WBP_EnterLevelTips_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_EnterLevelTips_C:Init()
  ListenObjectMessage(nil, GMP.MSG_Level_BattleChange, self, self.Hide)
  ListenObjectMessage(nil, GMP.MSG_Level_OnLevelEntry, self, self.OnLevelEntry)
  EventSystem.AddListenerNew(EventDef.BossTips.BossTipsUI, self, self.ShowBossTips)
  self:Show()
end

function WBP_EnterLevelTips_C:UnInit()
  UnListenObjectMessage(GMP.MSG_Level_BattleChange, self)
  UnListenObjectMessage(GMP.MSG_Level_OnLevelEntry, self)
  EventSystem.RemoveListenerNew(EventDef.BossTips.BossTipsUI, self, self.ShowBossTips)
end

function WBP_EnterLevelTips_C:OnLevelEntry(LevelId)
  print("WBP_EnterLevelTips_C:OnLevelEntry", LevelId)
  self:Show(LevelId)
end

function WBP_EnterLevelTips_C:Show(LevelIdParam)
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem:StaticClass())
  if not GameLevelSystem then
    return
  end
  local worldMode = LogicTeam.GetWorldId()
  local resultWorldMode, rowWorldMode = GetRowData(DT.DT_GameMode, tostring(worldMode))
  if resultWorldMode and rowWorldMode.ModeType == UE.EGameModeType.Survivor then
    return
  end
  print("WBP_EnterLevelTips_C:Show1 LevelIdParam", LevelIdParam)
  local LevelId
  if LevelIdParam then
    LevelId = LevelIdParam
  elseif GameLevelSystem:ClientIsInNewLevel() then
    print("WBP_EnterLevelTips_C:Show2 ", GameLevelSystem:GetLevelId())
    LevelId = GameLevelSystem:GetLevelId()
  end
  if not LevelId then
    print("WBP_EnterLevelTips_C:Show3 LevelId Is Nil")
    return
  end
  local GameModeId = GameLevelSystem:GetMatchGameMode()
  local Result, RowData = GetRowData(DT.DT_WorldLevelPool, LevelId)
  if not Result then
    return
  end
  UpdateVisibility(self, true)
  UpdateVisibility(self.CanvasPanelReady, RowData.LevelType == UE.ERGLevelType.ReadyRoom)
  UpdateVisibility(self.CanvasPanelNormal, RowData.LevelType == UE.ERGLevelType.LevelRoom)
  if RowData.LevelType == UE.ERGLevelType.ReadyRoom then
    self:PlayAnimation(self.ReadyAni)
    print("WBP_EnterLevelTips_C Show ReadyRoom", LevelId, RowData.LevelName)
    self.RGTextLevelName:SetText(RowData.LevelName)
    self.RGTextLevelName_1:SetText(RowData.LevelName)
  elseif RowData.LevelType == UE.ERGLevelType.LevelRoom then
    self:PlayAnimation(self.NormalAni)
    print("WBP_EnterLevelTips_C Show LevelRoom", LevelId, RowData.LevelName)
    self.RGTextNormalLevelName:SetText(RowData.LevelName)
    self.RGTextNormalLevelName_1:SetText(RowData.LevelName)
    self.RGTextNormalThemeName:SetText(RowData.LevelThemeName)
    UpdateVisibility(self.TowerClimbText, GameModeId == TableEnums.ENUMGameMode.TOWERClIMBING)
  elseif RowData.LevelType == UE.ERGLevelType.BossRoom then
    UpdateVisibility(self, false)
  end
end

function WBP_EnterLevelTips_C:ShowBossTips(BossType)
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
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local MatchGameMode = LevelSubSystem and LevelSubSystem:GetMatchGameMode() or TableEnums.ENUMGameMode.NORMAL
  print("WBP_EnterLevelTips_C ShowBossTips MatchGameMode", MatchGameMode)
  if MatchGameMode == TableEnums.ENUMGameMode.BOSSRUSH then
    UpdateVisibility(self.CanvasPanelBoss_Season, true)
    UpdateVisibility(self.CanvasPanelBoss, false)
    self:PlayAnimation(self.Boss_SeasonAni)
  elseif MatchGameMode == TableEnums.ENUMGameMode.SURVIVAL then
    UpdateVisibility(self.CanvasPanelBoss_Season, false)
    UpdateVisibility(self.CanvasPanelBoss, true)
    self:PlayAnimation(self.BossAni)
  else
    UpdateVisibility(self.CanvasPanelBoss, RowData.LevelType == UE.ERGLevelType.BossRoom)
    self:PlayAnimation(self.BossAni)
  end
  local BossTypeId = BossType
  if not BossTypeId or 0 == BossTypeId then
    local BossActor = self:GetBossActor()
    if BossActor then
      BossTypeId = BossActor:GetTypeID()
    end
  end
  print("WBP_EnterLevelTips_C Show BossRoom", LevelId, RowData.LevelName, BossTypeId)
  if BossTypeId and BossTypeId > 0 then
    local ResultMonster, RowMonsterData = GetRowData(DT.DT_Monster, tostring(BossTypeId))
    print("WBP_EnterLevelTips_C Show BossRoom SetBossName", ResultMonster, RowMonsterData, BossTypeId)
    if ResultMonster then
      local Name = ""
      if "" ~= tostring(RowMonsterData.NickName) then
        local bossNameFmt = NSLOCTEXT("WBP_EnterLevelTips_C", "BossNameFmt", "{0}({1})")
        Name = UE.FTextFormat(bossNameFmt(), RowMonsterData.Desc, RowMonsterData.NickName)
      else
        Name = RowMonsterData.Desc
      end
      self.RGTextBossName:SetText(Name)
      self.RGTextBossName_1:SetText(Name)
      self.RGTextBossName_touying:SetText(Name)
      self.RGTextBossLevelName:SetText(RowMonsterData.Title)
      self.RGTextBossLevelName_1:SetText(RowMonsterData.Title)
    end
  end
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local Difficulty = 0
  if LevelSubSystem then
    Difficulty = LevelSubSystem:GetDifficulty()
  end
  local R, RowInfo = GetRowData(DT.DT_BossBarConfig, Difficulty)
  if R then
    UpdateVisibility(self.MonsterTag, UE.URGBlueprintLibrary.IsValidSoftObjectPath(RowInfo.Icon) and RowInfo.bShowIconInTips)
    UpdateVisibility(self.boss_icon_4, RowInfo.bUsingDynamicMaterials)
    UpdateVisibility(self.DifficultyIcon, not RowInfo.bUsingDynamicMaterials)
    SetImageBrushBySoftObjectPath(self.DifficultyIcon, RowInfo.Icon)
    SetImageBrushBySoftObjectPath(self.DifficultyIcon_1, RowInfo.Icon)
    self.TagText_1:SetText(RowInfo.TagText)
  end
end

function WBP_EnterLevelTips_C:GetBossActor()
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

function WBP_EnterLevelTips_C:Hide(LevelBattleActor, RGBattleState)
  print("WBP_EnterLevelTips_C:Hide", RGBattleState)
  if RGBattleState ~= UE.ERGBattleState.Finished then
    return
  end
  UpdateVisibility(self, false)
end

function WBP_EnterLevelTips_C:Destruct()
  self.Overridden.Destruct(self)
end

return WBP_EnterLevelTips_C
