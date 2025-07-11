local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local TeamVoiceModule = require("Modules.TeamVoice.TeamVoiceModule")
local SurvivorData = require("Modules.Survivor.SurvivorData")
local WBP_HUD_C = UnLua.Class()
local LowHelalthValue = 60
local LowHelalthPercent = 0.3
local HeadIconParam = "CharacterIconTex"
local HeadIconAnimParam = "GlitchInt"
local EliteAISpawnTipId = 1118
local PreInteract = "PrevWeapon"
local NextInteract = "NextWeapon"
local MenuKeyName = "Menu"
local ShowTeamDamagePanelName = "ShowTeamDamagePanel"
local InteractUpdateTimer = -1
local InteractUpdateInterval = 0.3
local HeynckesTypeId = 1060
local GetOptimalTargetInteractTipId = function(OptimalTarget)
  local InteractComp = OptimalTarget:GetComponentByClass(UE.URGInteractComponent:StaticClass())
  if not InteractComp then
    return 0
  end
  local TipId = InteractComp.TipId
  if OptimalTarget.GetInteractTipId then
    TipId = OptimalTarget:GetInteractTipId()
  end
  return TipId
end
function WBP_HUD_C:Construct()
  self.DyingMarkTable = {}
  self:ListenLevelOnLevelClean(true)
  self:ListenGlobalAbilityRadio(true)
  self:ListenHeroDying(true)
  self:ListenHeroRescue(true)
  self:ListenHeroRespawn(true)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.InvalidationBox_5, false)
  else
    UpdateVisibility(self.InvalidationBox_5, true)
  end
  UpdateVisibility(self.CanvasPanel_CountDown, false)
  self:InitHUDActor()
  self.FXWidgetList = {}
  self.CrossMainWidget = self.WBP_MainCross
  if DataMgr and DataMgr.GetDSInfo().name then
    self.Txt_DSName:SetText(DataMgr.GetDSInfo().name)
    self.Txt_DSName:SetVisibility(UE.ESlateVisibility.Visible)
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC or PC.DamageComponent then
  end
  local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.PostItemChanged:Add(self, self.BindOnPostItemChanged)
  end
  ListenObjectMessage(nil, GMP.MSG_OnAbilityTagUpdate, self, self.BindOnAbilityTagUpdate)
  ListenObjectMessage(nil, GMP.MSG_Localization_UpdateCulture, self, self.BindOnUpdateCulture)
  ListenObjectMessage(nil, GMP.MSG_AI_OnAISpawned, self, self.BindOnAISpawned)
  ListenObjectMessage(nil, GMP.MSG_CharacterSkill_PlayHeirloomSkillUIFX, self, self.BindOnPlayHeirloomSkillUIFX)
  EventSystem.AddListener(self, EventDef.Battle.OnControlledPawnChanged, WBP_HUD_C.BindOnControlledPawnChanged)
  EventSystem.AddListener(self, EventDef.Battle.OnBuffAdded, self.BindOnBuffAdded)
  EventSystem.AddListener(self, EventDef.Battle.OnBuffChanged, self.BindOnBuffChanged)
  EventSystem.AddListener(self, EventDef.GenericModify.OnChoosePanelHideByFinishInteract, self.BindOnFinishInteract)
  self:BindOnControlledPawnChanged()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character:GetTypeID() == HeynckesTypeId then
    ListenObjectMessage(Character, GMP.MSG_CharacterSkill_TriggerHeroSkill, self, self.BindOnTriggerHeroSkill)
    ListenObjectMessage(Character, GMP.MSG_CharacterSkill_HeroSkillEnd, self, self.BindOnHeroSkillEnd)
  end
  self:InitTabData()
  self.TabActionName = "ScanWeakness"
  self.FreeSpeakActionName = "FreeSpeakAction"
  self.SpeakActionName = "PressSpeakAction"
  self.SwitchBagName = "SwitchBag"
  self.IllustratedName = "Illustrated"
  self.PermissionSelect = "PermissionSelect"
  self.PermissionLevelUp = "PermissionLevelUp"
  self.PotentialKey = "PotentialKey"
  self.SurvivalCtrl = "SurvivalCtrl"
  self.SurvivorPermission = "SurvivorPermission"
  self.SurvivorSelectRight = "SurvivorSelectRight"
  self.SurvivorConfirm = "SurvivorConfirm"
  self.WBP_ModLearnedPanel:UpdateModList()
  self:OnGameDebugUI()
  self:BindOnGameDebugUI(true)
  EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, WBP_HUD_C.BindOnKeyChanged)
  EventSystem.AddListener(self, EventDef.GenericModify.OnAddModify, WBP_HUD_C.AddGenericModifyList)
  EventSystem.AddListener(self, EventDef.GenericModify.OnRemoveModify, WBP_HUD_C.UpdateGenericModifyList)
  EventSystem.AddListener(self, EventDef.GenericModify.OnUpgradeModify, WBP_HUD_C.UpdateGenericModifyList)
  EventSystem.AddListener(self, EventDef.NPCAward.NPCAwardNumInteractFinish, WBP_HUD_C.OnAwardFinishInteract)
  EventSystem.AddListener(self, EventDef.NPCAward.NPCAwardNumAdd, WBP_HUD_C.OnNPCAwardNumAdd)
  EventSystem.AddListener(self, EventDef.SpecificModify.OnAddModify, WBP_HUD_C.AddSpecificModifyList)
  EventSystem.AddListener(self, EventDef.HUD.PlayScreenEdgeEffect, WBP_HUD_C.OnPlayScreenEdgeEffect)
  EventSystem.AddListener(self, EventDef.HUD.PlayScreenEdgeShieldEffect, WBP_HUD_C.OnPlayScreenEdgeShieldEffect)
  EventSystem.AddListener(self, EventDef.HUD.UpdateScreenEdgeShieldMat, WBP_HUD_C.OnUpdateScreenEdgeShieldMat)
  EventSystem.AddListener(self, EventDef.SurvivalModify.OnAddModify, WBP_HUD_C.OnAddSurvivalModify)
  EventSystem.AddListener(self, EventDef.SurvivalModify.OnUpgradeModify, WBP_HUD_C.OnUpgradeSurvivalModify)
  EventSystem.AddListener(self, EventDef.SurvivalModify.OnSpecificModify, WBP_HUD_C.OnSurvivalSpecificModify)
  EventSystem.AddListener(self, EventDef.SurvivalModify.OnModifyCountChange, WBP_HUD_C.OnModifyCountChange)
  self.Button_PermissionSelect.OnClicked:Add(self, self.OnPermissionSelectClick)
  self.Button_PermissionLevelUp.OnClicked:Add(self, self.OnPermissionLevelUpClick)
  self.Button_PotentialKey.OnClicked:Add(self, self.OnPotentialKeyClick)
  UE.UGameUserSettings.GetGameUserSettings().OnGameUserSettingsChanged:Add(self, WBP_HUD_C.UpdateTeamVoiceUI)
  ListenObjectMessage(nil, GMP.MSG_Level_OnLevelPass, self, WBP_HUD_C.OnAwardFinishInteract)
  ListenObjectMessage(nil, GMP.MSG_UI_HUD_PlayOrHideFullScreenFX, self, self.BindOnPlayOrHideFullScreenFX)
  ListenObjectMessage(nil, GMP.MSG_World_OnPawnAcknowledgeFinished, self, self.OnPawnAcknowledgeFinished)
  ListenObjectMessage(nil, GMP.MSG_Level_BattleExp_Change, self, self.BindOnBattleExpChange)
  ListenObjectMessage(nil, GMP.MSG_Level_BattleExp_LevelUp, self, self.BindOnBattleLevelUp)
  ListenObjectMessage(nil, GMP.MSG_Game_PlayerRevivalSuccess, self, self.BindOnPlayerRevivalSuccess)
  self:ListenOrUnListenOnQTEStart(true)
  self:UpdateTeamVoiceUI()
  self:UpdateConiVis()
  self.bNeedTickUpdateScrollList = false
  self:InitMainTask()
  LogicHUD:RegistWidgetToManager(self.InteractKeyPanel)
  self.UIEffectInst = -1
  self:ChangeMainSkillReadyWindowVis(false)
  self:InitSurvivalExp()
  self:InitSurvivalModify()
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem.StaticClass())
  if GameLevelSystem then
    GameLevelSystem.OnNotifyWorldInfo:Add(self, self.BindOnNotifyWorldInfo)
  end
  self:InactiveSurvivorInput()
end
function WBP_HUD_C:BindOnTriggerHeroSkill(SkillType)
  print("WBP_HUD_C:BindOnTriggerHeroSkill")
  if SkillType ~= UE.ESkillType.PrimarySkill then
    return
  end
  if not self.HeynckesSkillQCountWidget or not self.HeynckesSkillQCountWidget:IsValid() then
    local HeynckesSkillQCountWidgetClass = GetAssetByPath(self.HeynckesSkillQCountWidgetClass, true)
    self.HeynckesSkillQCountWidget = UE.UWidgetBlueprintLibrary.Create(self, HeynckesSkillQCountWidgetClass)
    self:AddChildToMainPanel(self.HeynckesSkillQCountWidget)
  end
  self.HeynckesSkillQCountWidget:Show()
end
function WBP_HUD_C:BindOnHeroSkillEnd(SkillType)
  print("WBP_HUD_C:BindOnHeroSkillEnd")
  if SkillType ~= UE.ESkillType.PrimarySkill then
    return
  end
  self.HeynckesSkillQCountWidget:Hide()
end
function WBP_HUD_C:InitMainTask()
  local PC = self:GetOwningPlayer()
  if PC then
    local TaskComponent = PC:GetComponentByClass(UE.URGPlayerMainlineTaskComponent:StaticClass())
    if TaskComponent then
      local TaskList = UE.TArray(UE.FRGMainlineTask)
      for key, value in pairs(Logic_MainTask.TaskInfo) do
        local Item = UE.FRGMainlineTask()
        local Events = UE.TArray(UE.FRGMainlineTaskEvent)
        Item.TaskId = key
        Item.State = value.state
        for key2, value2 in pairs(value.counters) do
          local Event = UE.FRGMainlineTaskEvent()
          Event.CountValue = value2.countValue
          Event.TargetValue = value2.TargetValue
          Event.EventId = value2.counterID
          Events:Add(Event)
        end
        Item.Events = Events
        TaskList:Add(Item)
      end
      TaskComponent:SetMainlineTasks(TaskList)
    end
  end
end
function WBP_HUD_C:PlayStartMapRadioBySwitchLevel()
  local StartMapRadioInfo = LogicRadio.GetStartMapRadioInfoTable()
  if -1 ~= StartMapRadioInfo.RadioId then
    local RadioWidget = self.WBP_Radio
    LogicRadio.ShowRadioPanel(StartMapRadioInfo.RadioConditionId, {})
  end
end
function WBP_HUD_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  self:ShowHUDActor()
  self:ShowBattleLagacyReminder()
  self:ShowSpecificHeroHUD()
end
function WBP_HUD_C:InitGenericPack()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
  if not GenericPackComp then
    return
  end
  if GenericPackComp.PreviewModifyData.Status == UE.ERGGenericModifyPackStatus.Ready then
    self:UpdateGenericPack()
  else
    GenericPackComp.PreviewModifyDataChangeDelegate:Remove(self, self.UpdateGenericPack)
    GenericPackComp.PreviewModifyDataChangeDelegate:Add(self, self.UpdateGenericPack)
  end
end
function WBP_HUD_C:UpdateGenericPack()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
  if not GenericPackComp then
    return
  end
  if GenericPackComp.PreviewModifyData.Status ~= UE.ERGGenericModifyPackStatus.Ready then
    return
  end
  if GenericPackComp.PreviewModifyData.PreviewModifyList:Num() <= 0 then
    return
  end
  if GenericPackComp.PreviewModifyData.DialogueId > 0 then
    if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyDialog_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyDialog_C.UIName, true)
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyDialog_C.UIName)
      if ChoosePanel then
        ChoosePanel:OpenGenericModifyDialogByPack(GenericPackComp.PreviewModifyData.DialogueId)
      end
    end
  else
    local bPackIsOpen = RGUIMgr:IsShown(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName)
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName, true)
    local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName)
    if ChoosePanel then
      if not bPackIsOpen then
        ChoosePanel:SetFromDialog(true)
        ChoosePanel:ShowTitle()
      end
      LogicHUD:UpdateGenericModifyListShow(false)
    end
  end
end
function WBP_HUD_C:ShowSpecificHeroHUD()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    local result, row = GetRowData(DT.DT_UIConfig_Hero, Character:GetTypeID())
    if result then
      RGUIMgr:OpenUI(row.UIName)
    end
  end
end
function WBP_HUD_C:OnShowByHideOther()
  self.Overridden.OnShowByHideOther(self)
  self:ShowHUDActor()
end
function WBP_HUD_C:ChangeMainSkillReadyWindowVis(IsShow)
  UpdateVisibility(self.WBP_MainSkillReadyWaveWindow, IsShow)
  if IsShow then
    self.WBP_MainSkillReadyWaveWindow:ShowWaveWindowAnim()
    self.MainSkillReadyTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:ChangeMainSkillReadyWindowVis(false)
      end
    }, self.MainSkillReadyDuration, false)
  else
    self.WBP_MainSkillReadyWaveWindow:StopAllAnimations()
    if self.MainSkillReadyTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.MainSkillReadyTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.MainSkillReadyTimer)
    end
  end
end
function WBP_HUD_C:OnHideByOther()
  self.Overridden.OnHideByOther(self)
  self:HideHUDActor()
end
function WBP_HUD_C:Hide(bCollapsed, Activate)
  self.Overridden.Hide(self, bCollapsed, Activate)
  self:HideHUDActor()
end
function WBP_HUD_C:ShowBattleLagacyReminder()
  if not LogicHUD.bHadShowBattleLagacy and BattleLagacyModule:CheckBattleLagacyIsActive() then
    if BattleLagacyData.CurBattleLagacyData ~= nil and BattleLagacyData.CurBattleLagacyData.BattleLagacyId ~= "0" then
      if BattleLagacyData.CurBattleLagacyData.BattleLagacyType == EBattleLagacyType.GeneircModify then
        RGUIMgr:OpenUI(UIConfig.WBP_BattleLagacyModifyRewardReminder_C.UIName)
        local battleLagacyModifyRewardReminder_C = RGUIMgr:GetUI(UIConfig.WBP_BattleLagacyModifyRewardReminder_C.UIName)
        if battleLagacyModifyRewardReminder_C then
          battleLagacyModifyRewardReminder_C:InitBattleLagacyModifyRewardReminder(BattleLagacyData.CurBattleLagacyData, false)
        end
      elseif BattleLagacyData.CurBattleLagacyData.BattleLagacyType == EBattleLagacyType.Inscription then
        RGUIMgr:OpenUI(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName)
        local battleLagacyInscriptionRewardReminder = RGUIMgr:GetUI(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName)
        if battleLagacyInscriptionRewardReminder then
          battleLagacyInscriptionRewardReminder:InitBattleLagacyInscriptionRewardReminder(BattleLagacyData.CurBattleLagacyData, false)
        end
      end
    end
    LogicHUD.bHadShowBattleLagacy = true
  end
end
function WBP_HUD_C:ShowQTEProgressPanel(ConfigData)
  print("LogicHUD.BindOnSkillQTEStart WBP_HUD_C:ShowQTEProgressPanel")
  self.WBP_QTEProgressWindow:Show(ConfigData)
end
function WBP_HUD_C:HideQTEProgressPanel()
  self.WBP_QTEProgressWindow:Hide()
end
function WBP_HUD_C:UpdateQTEProgressStatus(Index, IsSuccess)
  self.WBP_QTEProgressWindow:UpdateQTEProgressStatus(Index, IsSuccess)
end
function WBP_HUD_C:InitHUDActor()
  self.WBP_HUD_Normal:Init()
  self.WBP_HUD_MiddleTop:Init()
  EventSystem.Invoke(EventDef.HUD.InitHUDActor)
end
function WBP_HUD_C:ShowHUDActor()
  UpdateVisibility(self.WBP_HUD_Right, true)
  UpdateVisibility(self.WBP_HUD_Normal, true)
  UpdateVisibility(self.WBP_HUD_Left, true)
  UpdateVisibility(self.WBP_HUD_MiddleTop, true)
end
function WBP_HUD_C:HideHUDActor()
  UpdateVisibility(self.WBP_HUD_Right, false)
  UpdateVisibility(self.WBP_HUD_Normal, false)
  UpdateVisibility(self.WBP_HUD_Left, false)
  UpdateVisibility(self.WBP_HUD_MiddleTop, false)
end
function WBP_HUD_C:UnInitHUDActor()
  self.WBP_HUD_Normal:UnInit()
  self.WBP_HUD_MiddleTop:UnInit()
end
function WBP_HUD_C:BindOnControlledPawnChanged()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    Character.AttributeModifyComponent.OnAddModify:Remove(self, self.ModifyTips)
    Character.AttributeModifyComponent.OnAddSet:Remove(self, self.OnSetAdd)
    Character.AttributeModifyComponent.OnChangeSet:Remove(self, self.OnSetChanged)
    Character.AttributeModifyComponent.OnRemoveSet:Remove(self, self.UpdateScrollSetList)
    Character.AttributeModifyComponent.OnPropertiesInitialized:Remove(self, self.UpdateScrollSetList)
    Character.InscriptionComponentV2.OnInscriptionMakeAttributeChange:Remove(self, self.OnAttributeChangeTips)
    Character.AttributeModifyComponent.OnAddModify:Add(self, self.ModifyTips)
    Character.AttributeModifyComponent.OnAddSet:Add(self, self.OnSetAdd)
    Character.AttributeModifyComponent.OnChangeSet:Add(self, self.OnSetChanged)
    Character.AttributeModifyComponent.OnRemoveSet:Add(self, self.UpdateScrollSetList)
    Character.AttributeModifyComponent.OnPropertiesInitialized:Add(self, self.UpdateScrollSetList)
    Character.InscriptionComponentV2.OnInscriptionMakeAttributeChange:Add(self, self.OnAttributeChangeTips)
    self:InitLevelTips()
    self:InitGenericPack()
  end
  Character.OnNotifyPlayerStateRep:Add(self, WBP_HUD_C.BindOnNotifyPlayerStateRep)
  local LogicStateComp = Character:GetComponentByClass(UE.URGLogicStateComponent:StaticClass())
  if LogicStateComp then
    LogicStateComp.PostEnterState:Add(self, self.BindOnPostEnterState)
    LogicStateComp.PostExitState:Add(self, self.BindOnPostExitState)
  end
  self:UpdateGenericModifyList()
end
function WBP_HUD_C:BindOnKeyChanged()
  self:RefreshInteractTipKeyName()
end
function WBP_HUD_C:BindOnUpdateCulture()
  self:UpdateScrollSetList()
end
function WBP_HUD_C:BindOnPostEnterState(InState)
  if not UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(self.SlidingTag, InState, true) then
    return
  end
  self:ShowUIEffect("Stengthen")
end
function WBP_HUD_C:BindOnPostExitState(InState, Blocked)
  if not UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(self.SlidingTag, InState, true) then
    return
  end
  self:ShowUIEffect("Stengthen", UE.EUMGSequencePlayMode.Reverse)
end
function WBP_HUD_C:RefreshInteractTipKeyName()
  if self.CurInteractWidget and self.CurInteractWidget.SetKeyName then
    self.CurInteractWidget:SetKeyName(LogicGameSetting.GetCurSelectedKeyNameByKeyRowName("Interact"))
  end
end
function WBP_HUD_C:BindOnAbilityTagUpdate(Tag, bTagExists, TargetActor)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if TargetActor ~= Character then
    return
  end
  if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(Tag, self.FreezeAttackTag) then
    if bTagExists then
      self.WBP_MainCross:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.WBP_MainCross:SetVisibility(UE.ESlateVisibility.Visible)
    end
  end
end
function WBP_HUD_C:BindOnBuffAdded(AddedBuff)
  local BuffCurrentCount = LogicBuffList.BuffIdList[AddedBuff.ID]
  if BuffCurrentCount then
    return
  end
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
  if BuffData and BuffData.IsNeedShowWaveWindow then
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if RGWaveWindowManager then
      local Params = {}
      table.insert(Params, BuffData.BuffDescription)
      RGWaveWindowManager:ShowWaveWindow(1044, Params)
    end
  end
end
function WBP_HUD_C:BindOnBuffChanged(AddedBuff)
  local BuffCurrentCount = LogicBuffList.BuffIdList[AddedBuff.ID]
  print("WBP_HUD_C:BindOnBuffChanged", BuffCurrentCount, AddedBuff.CurrentCount)
  if not BuffCurrentCount or 0 == AddedBuff.CurrentCount or BuffCurrentCount >= AddedBuff.CurrentCount then
    return
  end
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
  if BuffData and BuffData.IsNeedShowWaveWindowWhenBuffChanged then
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if RGWaveWindowManager then
      local Params = {}
      table.insert(Params, BuffData.BuffDescription)
      RGWaveWindowManager:ShowWaveWindow(1044, Params)
    end
  end
end
function WBP_HUD_C:BindOnSettlement()
  LogicSettlement.ShowSettlement()
end
function WBP_HUD_C:BindOnGameDebugUI(Bind)
  local setting = UE.URGGlobalSettings.GetSettings()
  if setting then
    if Bind then
      setting.GameDebugUIDelegate:Add(self, WBP_HUD_C.OnGameDebugUI)
    else
      setting.GameDebugUIDelegate:Remove(self, WBP_HUD_C.OnGameDebugUI)
    end
  end
end
function WBP_HUD_C:OnGameDebugUI()
  local setting = UE.URGGlobalSettings.GetSettings()
  if setting then
    if setting.GameDebugUI then
      self.Button_GM:SetVisibility(UE.ESlateVisibility.Visible)
    else
      self.Button_GM:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end
function WBP_HUD_C:InitTabData()
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
  if GameLevelSystem and GameLevelSystem:CanEnableScanWeaknessTabPanel() then
    self.bIsCanShowTabAni = true
    UpdateVisibility(self.CanvasPanelTab, true)
    self:PlayAnimation(self.tab_loop, 0, 0)
    UpdateVisibility(self.URGImage_33, true)
  else
    self.bIsCanShowTabAni = false
    UpdateVisibility(self.CanvasPanelTab, false)
    self:StopAnimation(self.tab_loop)
    UpdateVisibility(self.URGImage_33, false)
  end
end
function WBP_HUD_C:InitTeamIndexInfo()
  print("InitTeamIndexInfo")
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  if not Character.PlayerState then
    print("Init Team Index Info not found PlayerState")
    return
  end
  self.Txt_TeamIndex:SetText(Character.PlayerState:GetTeamIndex())
  if LogicHUD.TeamIndexColor[Character.PlayerState:GetTeamIndex()] then
    self.Img_TeamIndex:SetColorAndOpacity(LogicHUD.TeamIndexColor[Character.PlayerState:GetTeamIndex()])
  else
    self.Img_TeamIndex:SetColorAndOpacity(LogicHUD.TeamIndexColor[1])
  end
end
function WBP_HUD_C:BindOnNotifyPlayerStateRep()
  print("OnNotifyPlayerStateRep")
  self:InitSurvivalExp()
  self:InitSurvivalModify()
end
function WBP_HUD_C:BindOnMakeDamage(SourceActor, TargetActor, Params)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character or Character == SourceActor then
    return
  end
end
function WBP_HUD_C:BindOnBeginInteract(Target)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local PickupTarget = Target:Cast(UE.ARGPickup)
  if not PickupTarget then
    return
  end
  local ItemData = DTSubsystem:K2_GetItemTableRow(PickupTarget:GetItemId(), nil)
  if ItemData.ArticleType == UE.EArticleDataType.Weapon then
    local PickWeapon = PickupTarget:GetWeapon()
    if not PickWeapon then
      return
    end
    local AccessoryComp = PickWeapon.AccessoryComponent
    if not AccessoryComp then
      return
    end
    if AccessoryComp:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel) then
      local ArticleId = AccessoryComp:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
      local ItemId = UE.URGArticleStatics.GetConfigId(ArticleId)
      ItemData = DTSubsystem:K2_GetItemTableRow(ItemId)
    end
    self:ShowPickWeaponAccessoryWaveWindow(ItemData, PickWeapon:GetWeaponLevel())
  end
end
function WBP_HUD_C:BindOnOptimalTargetChanged(OptimalTargetParam)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local targetList = LogicHUD:GetCanInteractTargetList()
  local OptimalTarget = OptimalTargetParam
  if targetList and targetList:IsValidIndex(1) then
    OptimalTarget = targetList:Get(1)
    LogicHUD.CurInteractIdx = 1
  end
  if OptimalTarget then
    local InteractComp = OptimalTarget:GetComponentByClass(UE.URGInteractComponent:StaticClass())
    if InteractComp then
      local TipId = GetOptimalTargetInteractTipId(OptimalTarget)
      if 0 ~= TipId and InteractComp:CanInteractWith(Character) then
        local bResult, InteractTipRow = DTSubsystem:GetInteractTipRowByID(TipId, nil)
        if bResult then
          HUD:UpdateInteractWidget(InteractTipRow, OptimalTarget, true)
        end
      end
      LogicHUD.PreOptimalTarget = OptimalTarget
      EventSystem.Invoke(EventDef.Interact.OnOptimalTargetChanged, OptimalTarget)
      return
    end
  end
  LogicHUD.CurInteractIdx = -1
  HUD:UpdateInteractWidget(nil, OptimalTarget, false)
  LogicHUD.PreOptimalTarget = nil
  EventSystem.Invoke(EventDef.Interact.OnOptimalTargetChanged, nil)
end
function WBP_HUD_C:BindOnFinishInteract(Target, Instigator)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local PickupTarget = Target:Cast(UE.ARGPickup)
  if not PickupTarget then
    return
  end
  local ItemData = DTSubsystem:K2_GetItemTableRow(PickupTarget:GetItemId(), nil)
  if ItemData.ArticleType == UE.EArticleDataType.Weapon then
    local PickWeapon = PickupTarget:GetWeapon()
    if not PickWeapon then
      return
    end
    local AccessoryComp = PickWeapon.AccessoryComponent
    if not AccessoryComp then
      return
    end
    if AccessoryComp:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel) then
      local ArticleId = AccessoryComp:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
      local ItemId = UE.URGArticleStatics.GetConfigId(ArticleId)
      ItemData = DTSubsystem:K2_GetItemTableRow(ItemId)
    end
    self:ShowPickWeaponAccessoryWaveWindow(ItemData, PickWeapon:GetWeaponLevel())
    PlaySound2DEffect(10003, "WBP_HUD_C:BindOnFinishInteract")
  end
  if ItemData.ArticleType == UE.EArticleDataType.Accessory then
    self:ShowPickWeaponAccessoryWaveWindow(ItemData, 0)
    PlaySound2DEffect(10010, "WBP_HUD_C:BindOnFinishInteract")
  end
end
function WBP_HUD_C:SetCurLevelCleanId(LevelId)
  print("WBP_HUD_C:SetCurLevelCleanId", LevelId)
  BattleData.SetCurLevelCleanId(LevelId)
end
function WBP_HUD_C:SetCurTriggerSkillId(SkillId)
  BattleData.SetCurTriggerSkillId(SkillId)
end
function WBP_HUD_C:ShowPickupScrollWaveWindow(ScrollId)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local Result, RowData = GetRowData(DT.DT_AttributeModify, ScrollId)
  if Result and RowData.Rarity == UE.ERGItemRarity.EIR_Legend then
    WaveId = 1123
    local Param = {}
    local WaveWindowParam = UE.FWaveWindowParam()
    WaveWindowParam.IntParam0 = ScrollId
    WaveWindowManager:ShowWaveWindowWithWaveParam(WaveId, Param, nil, {}, {}, WaveWindowParam)
  else
    local Result, RowInfo = GetRowData(DT.DT_WaveWindow, "1096")
    if not Result then
      return
    end
    local WidgetClass = UE.URGAssetManager.GetAssetByPath(RowInfo.WidgetClass, true)
    local Widget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
    if Widget then
      EventSystem.Invoke(EventDef.PickTipList.OnAddPickTipList, Widget)
      Widget:Show(ScrollId)
    end
  end
end
function WBP_HUD_C:ShowPickWeaponAccessoryWaveWindow(ItemData, WeaponLevel)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
end
function WBP_HUD_C:InitCharacterInfo()
  self:PlayStartMapRadioBySwitchLevel()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if InteractHandle then
    InteractHandle.OnFinishInteract:Add(self, WBP_HUD_C.BindOnFinishInteract)
    InteractHandle.OnBeginInteract:Add(self, WBP_HUD_C.BindOnBeginInteract)
    InteractHandle.OnOptimalTargetChanged:Add(self, self.BindOnOptimalTargetChanged)
  end
  self.WBP_HUD_Right:InitGloriaRobotInfo()
end
function WBP_HUD_C:PlayDamageTakenAnim(IsHealthDamage)
  if IsHealthDamage then
    self:ShowUIEffect("BloodHit")
  else
    self:ShowUIEffect("ShieldHit")
  end
end
function WBP_HUD_C:UpdateReadyState()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and self.Image_Ready then
    local ReadyStateShow = Character:Cast(UE.ARGHeroCharacterBase).bPortalReadyState
    print("WBP_HUD_C:UpdateReadyState()", Character, ReadyStateShow, self.Image_Ready)
    if ReadyStateShow then
      self.Image_Ready:SetVisibility(UE.ESlateVisibility.Visible)
    else
      self.Image_Ready:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end
function WBP_HUD_C:ChangeGMButtonVisibility(IsShow)
  if IsShow then
    self.Button_GM:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self.Button_GM:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_HUD_C:UpdateInteractWidget(InteractTipRow, TargetActor, bIsShow)
  local bIsValidSoftCls = InteractTipRow and UE.UKismetSystemLibrary.IsValidSoftClassReference(InteractTipRow.InteractSoftCls)
  if bIsShow and bIsValidSoftCls then
    self.WBP_InteractScrollList:UpdateInteractScrollListByIndex(LogicHUD.CurInteractIdx)
    if InteractTipRow.InteractWidgetType == UE.EInteractWidgetType.HUD then
      if bIsValidSoftCls then
        local WidgetCls = UE.UKismetSystemLibrary.LoadClassAsset_Blocking(InteractTipRow.InteractSoftCls)
        local InteractWidget = self.InteractMap:Find(WidgetCls)
        if InteractWidget then
          UpdateVisibility(InteractWidget, true)
        else
          InteractWidget = UE.UWidgetBlueprintLibrary.Create(self.InteractTipPanel, WidgetCls)
          self.InteractTipPanel:AddChild(InteractWidget)
          self.InteractMap:Add(WidgetCls, InteractWidget)
        end
        if InteractWidget.GetRealInteractTipWidget then
          InteractWidget = InteractWidget:GetRealInteractTipWidget()
          UpdateVisibility(InteractWidget, true)
        end
        if InteractWidget and InteractWidget.UpdateInteractInfo then
          InteractWidget:UpdateInteractInfo(InteractTipRow, TargetActor)
          UpdateVisibility(InteractWidget.URGImageInteractScrollTag, false)
        end
        if InteractWidget and InteractWidget.PlayInAnimation then
          InteractWidget:PlayInAnimation()
        end
        if InteractWidget and InteractWidget.SetWidgetConfig then
          InteractWidget:SetWidgetConfig(InteractTipRow.IsNeedProgress, "Interact", InteractTipRow.Info, InteractTipRow.IsShowDescBottom)
        end
        if InteractWidget and InteractWidget.SetInteractActor then
          InteractWidget:SetInteractActor(TargetActor)
        end
        if self.CurInteractWidget and self.CurInteractWidget ~= InteractWidget then
          if self.CurInteractWidget.UpdateInteractItem then
            self.CurInteractWidget:UpdateInteractItem(false)
          elseif self.CurInteractWidget.HideWidget then
            self.CurInteractWidget:HideWidget()
          end
          UpdateVisibility(self.CurInteractWidget, false)
        end
        self.CurInteractWidget = InteractWidget
        self:RefreshInteractTipKeyName()
        UpdateVisibility(self.InteractTipPanel, true)
        self.bNeedTickUpdateScrollList = true
      end
    else
      local WidgetCls
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem then
        local Result, CharacterRow = DTSubsystem:GetMarkDataByName(InteractTipRow.MarkRowName, nil)
        if Result and UE.UKismetSystemLibrary.IsValidSoftClassReference(CharacterRow.MarkUIItemCls) then
          WidgetCls = UE.UKismetSystemLibrary.LoadClassAsset_Blocking(CharacterRow.MarkUIItemCls)
        end
      end
      local InteractWidget = UE.URGBlueprintLibrary.GetMarkItem(self, TargetActor, WidgetCls)
      if InteractWidget then
      else
        UE.URGBlueprintLibrary.TriggerInteractMark(TargetActor, InteractTipRow.MarkRowName)
        InteractWidget = UE.URGBlueprintLibrary.GetMarkItem(self, TargetActor, WidgetCls)
        if InteractWidget.SetIsShowMark then
          InteractWidget:SetIsShowMark(false)
        end
      end
      if InteractWidget and InteractWidget.InitInteractItem then
        InteractWidget:InitInteractItem(TargetActor, InteractTipRow.Info)
      end
      if InteractWidget and InteractWidget.UpdateInteractItem then
        InteractWidget:UpdateInteractItem(true)
      end
      if InteractWidget then
        UpdateVisibility(InteractWidget.URGImageInteractScrollTag, false)
      end
      if self.CurInteractWidget and self.CurInteractWidget ~= InteractWidget then
        if self.CurInteractWidget.UpdateInteractItem then
          self.CurInteractWidget:UpdateInteractItem(false)
        elseif self.CurInteractWidget.HideWidget then
          self.CurInteractWidget:HideWidget()
        end
        UpdateVisibility(self.CurInteractWidget, false)
      end
      self.CurInteractWidget = InteractWidget
      self.bNeedTickUpdateScrollList = true
    end
  else
    if self.CurInteractWidget then
      if self.CurInteractWidget.UpdateInteractItem then
        self.CurInteractWidget:UpdateInteractItem(false)
      elseif self.CurInteractWidget.HideWidget then
        self.CurInteractWidget:HideWidget()
      end
      if self.CurInteractWidget.PlayOutAnimation then
        self.CurInteractWidget:PlayOutAnimation({
          self,
          function()
            UpdateVisibility(self.CurInteractWidget, false)
            self.CurInteractWidget = nil
            UpdateVisibility(self.InteractTipPanel, false)
          end
        })
      else
        UpdateVisibility(self.CurInteractWidget, false)
        self.CurInteractWidget = nil
        UpdateVisibility(self.InteractTipPanel, false)
      end
    else
      self.CurInteractWidget = nil
      UpdateVisibility(self.InteractTipPanel, false)
    end
    self.WBP_InteractScrollList:Hide()
    self.bNeedTickUpdateScrollList = false
  end
end
function WBP_HUD_C:UpdateInteractProgress(ProgressParam)
  if self.CurInteractWidget and self.CurInteractWidget.UpdateProgress then
    self.CurInteractWidget:UpdateProgress(ProgressParam)
  end
end
function WBP_HUD_C:UpdateInteractStatues(bIsUpdateInteractProgressParam, InteractComp)
  if bIsUpdateInteractProgressParam and InteractComp then
    local InitialPercent = 0
    if self.CurInteractWidget and self.CurInteractWidget.InitialPercent then
      InitialPercent = self.CurInteractWidget.InitialPercent
    end
    self:UpdateInteractProgress(InitialPercent)
    self.InteractCompCache = InteractComp
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InteractProgressTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.InteractProgressTimer)
    end
    self.InteractProgressTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function(self)
        local ElapsedTime = self.InteractCompCache:GetInteractingParams(UE.UGameplayStatics.GetPlayerCharacter(self, 0)).ElapsedTime
        local Progress = ElapsedTime / self.InteractCompCache.InteractConfig.Duration
        self:UpdateInteractProgress(Progress)
      end
    }, 0.02, true)
  else
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InteractProgressTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.InteractProgressTimer)
    end
    local InitialPercent = 0
    if self.CurInteractWidget and self.CurInteractWidget.InitialPercent then
      InitialPercent = self.CurInteractWidget.InitialPercent
    end
    self:UpdateInteractProgress(InitialPercent)
    self.InteractCompCache = nil
  end
end
function WBP_HUD_C:ModifyTips(ModifyId)
  local character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if UE.RGUtil.IsUObjectValid(character) and character.AttributeModifyComponent and character.AttributeModifyComponent:ShouldDiscardNotify() then
    return
  end
  self:ShowPickupScrollWaveWindow(ModifyId, 0)
  UpdateVisibility(self.URGImage_4, true)
  self:PlayAnimation(self.tab_loop_bag, 0, 2)
end
function WBP_HUD_C:OnSetChanged(SetData, OldSetData)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_HUD_C:OnSetChanged not DTSubsystem")
    return nil
  end
  if OldSetData.Level < SetData.Level then
    for i = OldSetData.Level + 1, SetData.Level do
      local setData = {
        Level = i,
        SetId = SetData.SetId,
        ModifyId = SetData.ModifyId
      }
      self:SetChangeTips(setData)
    end
    LogicAudio.OnActiveSet_Voice(self:GetOwningPlayerPawn(), SetData.Level)
  end
  self:UpdateScrollSetList()
end
function WBP_HUD_C:OnSetAdd(SetData)
  for i = 1, SetData.Level do
    local setData = {
      Level = i,
      SetId = SetData.SetId,
      ModifyId = SetData.ModifyId
    }
    self:SetChangeTips(setData)
  end
  self:UpdateScrollSetList()
end
function WBP_HUD_C:SetChangeTips(SetData)
  local character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if UE.RGUtil.IsUObjectValid(character) and character.AttributeModifyComponent and character.AttributeModifyComponent:ShouldDiscardNotify() then
    return
  end
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_HUD_C:SetChangeTips not DTSubsystem")
    return nil
  end
  local Param = {}
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(SetData.SetId, nil)
  local Inscription
  if ResultModifySet then
    Param = {
      AttributeModifySetRow.SetName
    }
    Inscription = Logic_Scroll:GetInscriptionBySetLv(SetData.Level, SetData.SetId)
  end
  if Inscription then
    local Id = 1122
    local WaveWindowParam = UE.FWaveWindowParam()
    WaveWindowParam.IntParam0 = SetData.Level
    WaveWindowParam.IntParam1 = SetData.SetId
    WaveWindowParam.IntParam2 = SetData.ModifyId
    WaveWindowManager:ShowWaveWindowWithWaveParam(Id, Param, nil, {}, {}, WaveWindowParam)
  end
end
function WBP_HUD_C:UpdateScrollSetList()
end
function WBP_HUD_C:AddGenericModifyList(RGGenericModifyParam)
end
function WBP_HUD_C:AddSpecificModifyList(RGSpecificModifyParam)
end
function WBP_HUD_C:UpdateGenericModifyList(RGGenericModify)
end
function WBP_HUD_C:OnAwardFinishInteract(LevelId)
  local bIsLevelClean = false
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
  if GameLevelSystem then
    bIsLevelClean = GameLevelSystem:IsLevelPass()
  end
  print("WBP_HUD_C:OnAwardFinishInteract bClean:%d, ActiveAwardNpcNum:%d", bIsLevelClean, LogicHUD:GetActiveAwardNpcNum())
  if LogicHUD:GetActiveAwardNpcNum() <= 0 and bIsLevelClean then
    UE.URGBlueprintLibrary.TriggerAllAwardGot()
  end
end
function WBP_HUD_C:OnNPCAwardNumAdd()
  if LogicHUD:GetActiveAwardNpcNum() > 0 then
    UE.URGBlueprintLibrary.TriggerHaveAward()
  end
end
function WBP_HUD_C:UpdateGenericModifyListShow(bIsShow)
  UpdateVisibility(self.WBP_HUD_GenericModifyList, bIsShow)
  self.WBP_HUD_GenericModifyList:SelectClick(false)
end
function WBP_HUD_C:OnPlayScreenEdgeEffect(Ani, PlayMode)
  self:ShowUIEffect(Ani, PlayMode)
end
function WBP_HUD_C:OnPlayScreenEdgeShieldEffect(AniName)
  if self[AniName] then
    self:PlayAnimationForward(self[AniName])
  end
end
function WBP_HUD_C:OnUpdateScreenEdgeShieldMat(floatValue)
  local DynamicMaterial = self.HUD:GetDynamicMaterial()
  if DynamicMaterial then
    DynamicMaterial:SetScalarParameterValue("alpha2", floatValue)
  end
end
function WBP_HUD_C:FocusInput()
  self.Overridden.FocusInput(self)
  self:PushInputAction()
  self.WBP_ChatView:FocusInput()
  if self:GetOwningPlayer() then
    self:GetOwningPlayer().bShowMouseCursor = false
  end
  if not IsListeningForInputAction(self, self.TabActionName) then
    ListenForInputAction(self.TabActionName, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_HUD_C.ListenForTabInputAction
    })
  end
  if not IsListeningForInputAction(self, PreInteract) then
    ListenForInputAction(PreInteract, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_HUD_C.ListenForPreInteract
    })
  end
  if not IsListeningForInputAction(self, NextInteract) then
    ListenForInputAction(NextInteract, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_HUD_C.ListenForNextInteract
    })
  end
  if not IsListeningForInputAction(self, self.BattleRoleInfoShortKey) then
    ListenForInputAction(self.BattleRoleInfoShortKey, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_HUD_C.BindOnListenForBattleRoleInfoShortKeyPressed
    })
  end
  if not IsListeningForInputAction(self, self.FreeSpeakActionName) then
    ListenForInputAction(self.FreeSpeakActionName, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_HUD_C.BindOnListenForFreeSpeakKeyPressed
    })
  end
  if not IsListeningForInputAction(self, self.SpeakActionName) then
    ListenForInputAction(self.SpeakActionName, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_HUD_C.BindOnListenForSpeakKeyPressed
    })
    ListenForInputAction(self.SpeakActionName, UE.EInputEvent.IE_Released, false, {
      self,
      WBP_HUD_C.BindOnListenForSpeakKeyReleased
    })
  end
  if not IsListeningForInputAction(self, MenuKeyName) then
    ListenForInputAction(MenuKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForMenuKeyPressed
    })
  end
  if not IsListeningForInputAction(self, ShowTeamDamagePanelName) then
    ListenForInputAction(ShowTeamDamagePanelName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForShowTeamDamagePanelKeyPressed
    })
  end
  if not IsListeningForInputAction(self, self.SwitchBagName) then
    ListenForInputAction(self.SwitchBagName, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForSwitchBag
    })
  end
  if not IsListeningForInputAction(self, self.IllustratedName) then
    ListenForInputAction(self.IllustratedName, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForIllustratedGuide
    })
  end
  if not IsListeningForInputAction(self, self.PermissionSelect) then
    ListenForInputAction(self.PermissionSelect, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForPermissionSelect
    })
  end
  if not IsListeningForInputAction(self, self.PermissionLevelUp) then
    ListenForInputAction(self.PermissionLevelUp, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForPermissionLevelUp
    })
  end
  if not IsListeningForInputAction(self, self.PotentialKey) then
    ListenForInputAction(self.PotentialKey, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForPotentialKey
    })
  end
  if not IsListeningForInputAction(self, self.SurvivalCtrl) then
    ListenForInputAction(self.SurvivalCtrl, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForSurvivalCtrl
    })
  end
  if not IsListeningForInputAction(self, self.SurvivorPermission) then
    ListenForInputAction(self.SurvivorPermission, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForSurvivorPermission
    })
  end
  if not IsListeningForInputAction(self, self.SurvivorConfirm) then
    ListenForInputAction(self.SurvivorConfirm, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForSurvivorConfirm
    })
  end
  self:RegisterScrollRecipient(self)
end
function WBP_HUD_C:ListenForMenuKeyPressed(...)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  if not PC.CheckCanOpenUI() or not PC:CheckCanOpenUI() then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_Pause_C.UIName) then
  else
    RGUIMgr:OpenUI(UIConfig.WBP_Pause_C.UIName)
  end
end
function WBP_HUD_C:ListenForTabInputAction()
  if self.bIsCanShowTabAni then
    self:StopAnimation(self.tab_loop)
    UpdateVisibility(self.URGImage_33, false)
    self.bIsCanShowTabAni = false
  end
end
function WBP_HUD_C:ListenForPreInteract()
  LogicHUD:ScrollInteract(false)
end
function WBP_HUD_C:ListenForNextInteract()
  LogicHUD:ScrollInteract(true)
end
function WBP_HUD_C:ListenForUITestInputAction()
  RGUIMgr:OpenUI(UIConfig.WBP_UITestView_C.UIName, true)
end
function WBP_HUD_C:ListenForShowTeamDamagePanelKeyPressed(...)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  if not PC.CheckCanOpenUI() or not PC:CheckCanOpenUI() then
    return
  end
  if self:IsSurvivalMode() and self.PermissionIndex ~= nil then
    self:ListenForSurvivorSelectLeft()
  elseif RGUIMgr:IsShown(UIConfig.WBP_TeamDamagePanel_C.UIName) then
  else
    local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
    if UserClickStatisticsMgr then
      UserClickStatisticsMgr:AddClickStatistics("DamageStatistics")
      print("BP_RGPlayerController_C:OperatorTeamDamagePanel AddClickStatistics")
    end
    RGUIMgr:OpenUI(UIConfig.WBP_TeamDamagePanel_C.UIName, false)
  end
end
function WBP_HUD_C:ListenForSwitchBag()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  if not PC.CheckCanOpenUI() or not PC:CheckCanOpenUI() then
    return
  end
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("SwitchBag \230\150\176\230\137\139\229\133\179\228\184\141\232\131\189\229\188\128\232\131\140\229\140\133")
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_HUD_C.UIName) then
    if RGUIMgr:IsShown(UIConfig.WBP_MainPanel_C.UIName) then
      local MainPanel = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
      if MainPanel then
      end
    else
      local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
      if UserClickStatisticsMgr then
        UserClickStatisticsMgr:AddClickStatistics("OpenBackpack")
      end
      RGUIMgr:OpenUI(UIConfig.WBP_MainPanel_C.UIName, false)
      local MainPanelObj = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
      if MainPanelObj then
        MainPanelObj:ShowScrollInfoPanel()
      end
    end
  end
end
function WBP_HUD_C:ListenForIllustratedGuide()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  if not PC.CheckCanOpenUI() or not PC:CheckCanOpenUI() then
    return
  end
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("IllustratedGuide \230\150\176\230\137\139\229\133\179\228\184\141\232\131\189\229\188\128\232\131\140\229\140\133")
    return
  end
  if not RGUIMgr:IsShown(UIConfig.WBP_HUD_C.UIName) or RGUIMgr:IsShown(UIConfig.WBP_MainPanel_C.UIName) then
  else
    local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
    if UserClickStatisticsMgr then
      UserClickStatisticsMgr:AddClickStatistics("InGameIGuideGeneric")
    end
    RGUIMgr:OpenUI(UIConfig.WBP_MainPanel_C.UIName, false)
    local MainPanelObj = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
    if MainPanelObj then
      MainPanelObj:ShowIllustratedGuidePanel()
    end
  end
end
function WBP_HUD_C:BindOnAISpawned(AI)
  if not AI.IsEliteAI or not AI:IsEliteAI() then
    return
  end
  local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not RGWaveWindowManager then
    return
  end
  self.TipWindow = RGWaveWindowManager:ShowWaveWindow(EliteAISpawnTipId, {}, nil)
  if self.TipWindow then
    self.TipWindow:SetInfoText(self.TipWindow:GetTipInfo(AI))
  end
end
function WBP_HUD_C:BindOnPlayHeirloomSkillUIFX()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    print("WBP_HUD_C:BindOnPlayHeirloomSkillUIFX PC is nil")
    return
  end
  local PS = PC.PlayerState
  if not PS then
    print("WBP_HUD_C:BindOnPlayHeirloomSkillUIFX PS is nil")
    return
  end
  local PlayerInfo = PS:GetPlayerInfo()
  local Result, RowInfo = GetRowData(DT.DT_HeirloomSkin, PlayerInfo.hero.skin)
  if not Result then
    print("WBP_HUD_C:BindOnPlayHeirloomSkillUIFX not found HeirloomSkin RowInfo, RowId:", PlayerInfo.hero.skin)
    return
  end
  local WidgetClass
  if UE.URGBlueprintLibrary.IsValidSoftObjectPath(RowInfo.SkillQFXWidgetClassPath) then
    WidgetClass = UE.URGAssetManager.GetAssetByPath(RowInfo.SkillQFXWidgetClassPath, true)
  else
    print("WBP_HUD_C:BindOnPlayHeirloomSkillUIFX SkillQFXWidgetClassPath is invalid!, RowId:", PlayerInfo.hero.skin)
    return
  end
  if not UE.UKismetSystemLibrary.IsValidClass(WidgetClass) then
    print("WBP_HUD_C:BindOnPlayHeirloomSkillUIFX Widget Class is InValid!")
    return
  end
  local TargetWidget = self:GetOrCreateFXWidget(RowInfo.SkillQFXWidgetClassPath)
  if TargetWidget and TargetWidget.StartPlayAnimation then
    TargetWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    TargetWidget:StartPlayAnimation()
  end
end
function WBP_HUD_C:OnPawnAcknowledgeFinished(Character)
  self:InitTabData()
end
function WBP_HUD_C:BindOnBattleExpChange(UserId, RowExp, DataExp, NextExp, Level)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if UserId ~= Character:GetUserId() then
    return
  end
  local CurLevelResult, CurLevelRowData = GetRowData(DT.DT_BattleMonsterExpLevel, Level)
  if CurLevelResult then
    local IsMaxLevel = 0 == NextExp
    local CurLevelExp = 0
    local NextLevelExp = 0
    if IsMaxLevel then
      local LastLevelResult, LastLevelRowData = GetRowData(DT.DT_BattleMonsterExpLevel, Level - 1)
      if LastLevelResult then
        CurLevelExp = CurLevelRowData.Exp - LastLevelRowData.Exp
        NextLevelExp = CurLevelRowData.Exp - LastLevelRowData.Exp
      end
    else
      CurLevelExp = DataExp - CurLevelRowData.Exp
      NextLevelExp = NextExp - CurLevelRowData.Exp
    end
    local Percent = CurLevelExp / NextLevelExp
    self.ProgressBar_Exp:SetPercent(Percent)
    local LevelUpExp = string.format("%d/%d", CurLevelExp, NextLevelExp)
    self.TXT_LevelUpExp:SetText(LevelUpExp)
  end
end
function WBP_HUD_C:BindOnBattleLevelUp(UserId, ExpLevel, CurrentExp)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if UserId ~= Character:GetUserId() then
    return
  end
  self.TxT_Level:SetText(ExpLevel)
  local CurLevelResult, CurLevelRowData = GetRowData(DT.DT_BattleMonsterExpLevel, ExpLevel)
  local NextLevelResult, NextLevelRowData = GetRowData(DT.DT_BattleMonsterExpLevel, ExpLevel + 1)
  if CurLevelResult then
    if NextLevelResult then
      local NextExp = NextLevelRowData.Exp - CurLevelRowData.Exp
      local CurExp = CurrentExp - CurLevelRowData.Exp
      local Percent = CurExp / NextExp
      local LevelUpExp = string.format("%d/%d", CurExp, NextExp)
      self.TXT_LevelUpExp:SetText(LevelUpExp)
      self.ProgressBar_Exp:SetPercent(Percent)
    else
      local LastLevelResult, LastLevelRowData = GetRowData(DT.DT_BattleMonsterExpLevel, ExpLevel - 1)
      local CurExp = 0
      if LastLevelResult then
        CurExp = CurLevelRowData.Exp - LastLevelRowData.Exp
      end
      local LevelUpExp = string.format("%d/%d", CurExp, CurExp)
      self.TXT_LevelUpExp:SetText(LevelUpExp)
      self.ProgressBar_Exp:SetPercent(1)
    end
  end
  LogicAudio.BattleLevelUp()
  self:PlayAnimation(self.Anim_SurvivalExp_Add)
end
function WBP_HUD_C:BindOnPlayOrHideFullScreenFX(IsPlay, WidgetSoftClass, AnimationName)
  local TargetFXWidget
  if not UE.UKismetSystemLibrary.IsValidSoftClassReference(WidgetSoftClass) then
    TargetFXWidget = self.ScreenEdgeFXUI
  else
    local WidgetClassStr = UE.UKismetSystemLibrary.Conv_SoftClassReferenceToString(WidgetSoftClass)
    local WidgetSoftClassPath = UE.UKismetSystemLibrary.MakeSoftClassPath(WidgetClassStr)
    TargetFXWidget = self:GetOrCreateFXWidget(WidgetSoftClassPath)
  end
  if not TargetFXWidget then
    return
  end
  local TargetAnimation = TargetFXWidget[AnimationName]
  if not TargetAnimation then
    print(string.format("WBP_HUD_C:BindOnPlayOrHideFullScreenFX not found Animation: %s, Widget: %s", AnimationName, UE.UKismetSystemLibrary.GetDisplayName(TargetFXWidget)))
    return
  end
  if IsPlay then
    TargetFXWidget:PlayAnimationForward(TargetAnimation)
  else
    TargetFXWidget:PlayAnimationReverse(TargetAnimation)
  end
end
function WBP_HUD_C:GetOrCreateFXWidget(WidgetSoftClassPath)
  local WidgetClassStr = UE.UKismetSystemLibrary.BreakSoftClassPath(WidgetSoftClassPath, nil)
  local FinalWidget = self.FXWidgetList[WidgetClassStr]
  if not FinalWidget or not FinalWidget:IsValid() then
    local WidgetClass = UE.URGAssetManager.GetAssetByPath(WidgetSoftClassPath, true)
    FinalWidget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
    local OverlaySlot = self.FullScreenFXPanel:AddChild(FinalWidget)
    if OverlaySlot then
      OverlaySlot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
      OverlaySlot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
    end
    self.FXWidgetList[WidgetClassStr] = FinalWidget
  end
  return FinalWidget
end
function WBP_HUD_C:BindOnListenForBattleRoleInfoShortKeyPressed()
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("BindOnListenForBattleRoleInfoShortKeyPressed \230\150\176\230\137\139\229\133\179\228\184\141\232\131\189\229\188\128\232\131\140\229\140\133")
    return
  end
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("OpenState")
  end
  RGUIMgr:OpenUI(UIConfig.WBP_MainPanel_C.UIName, false)
  local MainPanelObj = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
  if MainPanelObj then
    MainPanelObj:ShowRoleInfoPanel()
  end
end
function WBP_HUD_C:BindOnListenForFreeSpeakKeyPressed()
  print("ccccccccccccc")
  ChatDataMgr.GetVoiceBanStatus(function()
    local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys then
      local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
      local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
      TeamVoiceModule:SetMicMode(1 - CurValue, true)
    end
  end)
end
function WBP_HUD_C:BindOnListenForSpeakKeyPressed()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
    local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
    if 1 == CurValue then
      TeamVoiceModule:SetMicMode(0, false)
    end
  end
end
function WBP_HUD_C:BindOnListenForSpeakKeyReleased()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
    local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
    if 1 == CurValue then
      TeamVoiceModule:SetMicMode(CurValue, false)
    end
  end
end
function WBP_HUD_C:ShowScrollView()
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("ShowScrollView \230\150\176\230\137\139\229\133\179\228\184\141\232\131\189\229\188\128\232\131\140\229\140\133")
    return
  end
  RGUIMgr:OpenUI(UIConfig.WBP_MainPanel_C.UIName, false)
  local MainPanelObj = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
  if MainPanelObj then
    MainPanelObj:ShowScrollInfoPanel()
  end
end
function WBP_HUD_C:ShowIllustratedGuidePanel()
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("ShowIllustratedGuidePanel \230\150\176\230\137\139\229\133\179\228\184\141\232\131\189\229\188\128\232\131\140\229\140\133")
    return
  end
  RGUIMgr:OpenUI(UIConfig.WBP_MainPanel_C.UIName, false)
  local MainPanelObj = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
  if MainPanelObj then
    MainPanelObj:ShowIllustratedGuidePanel()
  end
end
function WBP_HUD_C:ShowCountDownUI(DelayTime)
  self.CountDownTime = math.floor(DelayTime)
  self:UpdateCountCount()
  UpdateVisibility(self.CanvasPanel_CountDown, true)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CountDownTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CountDownTimer)
  end
  self.CountDownTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.UpdateCountCount
  }, 1, true)
end
function WBP_HUD_C:UpdateCountCount()
  self.TxT_CountDown:SetText(self.CountDownTime)
  if 0 == self.CountDownTime then
    self:HideCountDownUI()
  end
  self.CountDownTime = self.CountDownTime - 1
end
function WBP_HUD_C:HideCountDownUI()
  UpdateVisibility(self.CanvasPanel_CountDown, false)
  UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CountDownTimer)
end
function WBP_HUD_C:AddChildToMainPanel(Widget)
  local Slot = self.MainPanel:AddChild(Widget)
  local Anchors = UE.FAnchors()
  Anchors.Minimum = UE.FVector2D(0, 0)
  Anchors.Maximum = UE.FVector2D(1.0, 1.0)
  Slot:SetAnchors(Anchors)
  local Offsets = UE.FMargin()
  Slot:SetOffsets(Offsets)
end
function WBP_HUD_C:AddMarkItemToPanel(Item)
  if self.MarkPanel:HasChild(Item) then
    return UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
  else
    local Slot = self.MarkPanel:AddChildToCanvas(Item)
    Slot:SetAutoSize(true)
    return Slot
  end
end
function WBP_HUD_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  self:HideHUDActor()
  self.WBP_ChatView:UnfocusInput()
  self:PopInputAction()
  self:UnregisterScrollRecipient(self)
end
function WBP_HUD_C:Destruct()
  self.FXWidgetList = {}
  self:ListenLevelOnLevelClean(false)
  self:ListenGlobalAbilityRadio(false)
  self:ListenHeroDying(false)
  self:ListenHeroRescue(false)
  self:ListenHeroRespawn(false)
  self:UnInitHUDActor()
  self:PopInputAction()
  self:UnInitLevelTips()
  LogicHUD:UnRegistWidgetToManager(self.InteractKeyPanel)
  UE.UGameUserSettings.GetGameUserSettings().OnGameUserSettingsChanged:Remove(self, WBP_HUD_C.UpdateTeamVoiceUI)
  if self.MainSkillReadyTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.MainSkillReadyTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.MainSkillReadyTimer)
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
    if InteractHandle then
      InteractHandle.OnFinishInteract:Remove(self, WBP_HUD_C.BindOnFinishInteract)
      InteractHandle.OnBeginInteract:Remove(self, WBP_HUD_C.BindOnBeginInteract)
      InteractHandle.OnOptimalTargetChanged:Remove(self, self.BindOnOptimalTargetChanged)
    end
    Character.OnNotifyPlayerStateRep:Remove(self, WBP_HUD_C.BindOnNotifyPlayerStateRep)
    local LogicStateComp = Character:GetComponentByClass(UE.URGLogicStateComponent:StaticClass())
    if LogicStateComp then
      LogicStateComp.PostEnterState:Remove(self, self.BindOnPostEnterState)
      LogicStateComp.PostExitState:Remove(self, self.BindOnPostExitState)
    end
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CharacterIconTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CharacterIconTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InteractProgressTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.InteractProgressTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ExtraShieldTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ExtraShieldTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CoinVisTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CoinVisTimer)
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC and PC.DamageComponent then
    PC.DamageComponent.OnMakeDamage:Remove(self, WBP_HUD_C.BindOnMakeDamage)
  end
  if PC then
    local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
    if BagComp then
      BagComp.PostItemChanged:Remove(self, self.BindOnPostItemChanged)
    end
  end
  if self.IsLowHealth then
    PlaySound2DEffect(10007, "WBP_HUD_C:Destruct")
    self.IsLowHealth = false
  end
  UnListenObjectMessage(GMP.MSG_OnAbilityTagUpdate, self)
  UnListenObjectMessage(GMP.MSG_Localization_UpdateCulture, self)
  UnListenObjectMessage(GMP.MSG_Level_OnTeamChange, self)
  UnListenObjectMessage(GMP.MSG_Level_LevelPass, self)
  UnListenObjectMessage(GMP.MSG_AI_OnAISpawned, self)
  UnListenObjectMessage(GMP.MSG_CharacterSkill_PlayHeirloomSkillUIFX, self)
  UnListenObjectMessage(GMP.MSG_UI_HUD_PlayOrHideFullScreenFX, self)
  UnListenObjectMessage(GMP.MSG_World_OnPawnAcknowledgeFinished, self)
  UnListenObjectMessage(GMP.MSG_CharacterSkill_TriggerHeroSkill, self)
  UnListenObjectMessage(GMP.MSG_CharacterSkill_HeroSkillEnd, self)
  UnListenObjectMessage(GMP.MSG_Level_BattleExp_Change, self)
  UnListenObjectMessage(GMP.MSG_Level_BattleExp_LevelUp, self)
  UnListenObjectMessage(GMP.MSG_Game_PlayerRevivalSuccess, self)
  self:ListenOrUnListenOnQTEStart(false)
  self:BindOnGameDebugUI(false)
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, WBP_HUD_C.BindOnKeyChanged, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnAddModify, WBP_HUD_C.AddGenericModifyList, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnRemoveModify, WBP_HUD_C.UpdateGenericModifyList, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnUpgradeModify, WBP_HUD_C.UpdateGenericModifyList, self)
  EventSystem.RemoveListener(EventDef.SurvivalModify.OnAddModify, WBP_HUD_C.OnAddSurvivalModify, self)
  EventSystem.RemoveListener(EventDef.SurvivalModify.OnUpgradeModify, WBP_HUD_C.OnUpgradeSurvivalModify, self)
  EventSystem.RemoveListener(EventDef.SurvivalModify.OnSpecificModify, WBP_HUD_C.OnSurvivalSpecificModify, self)
  EventSystem.RemoveListener(EventDef.SurvivalModify.OnModifyCountChange, WBP_HUD_C.OnModifyCountChange, self)
  EventSystem.RemoveListener(EventDef.SpecificModify.OnAddModify, WBP_HUD_C.AddSpecificModifyList, self)
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, WBP_HUD_C.BindOnControlledPawnChanged, self)
  EventSystem.RemoveListener(EventDef.NPCAward.NPCAwardNumInteractFinish, WBP_HUD_C.OnAwardFinishInteract, self)
  EventSystem.RemoveListener(EventDef.NPCAward.NPCAwardNumAdd, WBP_HUD_C.OnNPCAwardNumAdd, self)
  EventSystem.RemoveListener(EventDef.HUD.PlayScreenEdgeEffect, WBP_HUD_C.OnPlayScreenEdgeEffect, self)
  EventSystem.RemoveListener(EventDef.HUD.PlayScreenEdgeShieldEffect, WBP_HUD_C.OnPlayScreenEdgeShieldEffect, self)
  EventSystem.RemoveListener(EventDef.HUD.UpdateScreenEdgeShieldMat, WBP_HUD_C.OnUpdateScreenEdgeShieldMat, self)
  EventSystem.RemoveListener(EventDef.Battle.OnBuffAdded, self.BindOnBuffAdded, self)
  EventSystem.RemoveListener(EventDef.Battle.OnBuffChanged, self.BindOnBuffChanged, self)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    Character.AttributeModifyComponent.OnAddModify:Remove(self, self.ModifyTips)
    Character.AttributeModifyComponent.OnAddSet:Remove(self, self.OnSetAdd)
    Character.AttributeModifyComponent.OnChangeSet:Remove(self, self.OnSetChanged)
    Character.AttributeModifyComponent.OnRemoveSet:Remove(self, self.UpdateScrollSetList)
    Character.AttributeModifyComponent.OnPropertiesInitialized:Remove(self, self.UpdateScrollSetList)
    Character.InscriptionComponentV2.OnInscriptionMakeAttributeChange:Remove(self, self.OnAttributeChangeTips)
  end
  self.Button_PermissionSelect.OnClicked:Remove(self, self.OnPermissionSelectClick)
  self.Button_PermissionLevelUp.OnClicked:Remove(self, self.OnPermissionLevelUpClick)
  self.Button_PotentialKey.OnClicked:Remove(self, self.OnPotentialKeyClick)
  self.UIEffectInst = -1
end
function WBP_HUD_C:SetGenericModify(bIsShow)
  self:UpdateGenericModifyListShow(bIsShow)
end
function WBP_HUD_C:UpdatePing()
  local OwningPlayer = self:GetOwningPlayer()
  if OwningPlayer then
    local PS = OwningPlayer.PlayerState
    if PS then
      local pingValue = PS:GetActualPing()
      if pingValue >= 0 and pingValue <= 100 then
        self.TextBlock_Ping:SetColorAndOpacity(self.LowLatancyColor)
      elseif pingValue > 100 and pingValue <= 200 then
        self.TextBlock_Ping:SetColorAndOpacity(self.MiddleLatancyColor)
      elseif pingValue > 200 then
        self.TextBlock_Ping:SetColorAndOpacity(self.HighLatancyColor)
      end
      local str = "PING " .. pingValue
      self.TextBlock_Ping:SetText(str)
    end
  end
end
function WBP_HUD_C:ShowRift(TimeOffUTCStamp, SpawnTimeStamp, TimeOffStamp)
  UpdateVisibility(self.WBP_RiftCountDown, true)
  UpdateVisibility(self.WBP_RiftCountDown.WBP_BattleModeContent.CanvasPanel_Progress, false)
  self.WBP_HUD_MiddleTop:ShowRift(TimeOffUTCStamp, SpawnTimeStamp, TimeOffStamp)
end
function WBP_HUD_C:ShowRiftTimeOff()
  self.WBP_RiftCountDown.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.FailedStage)
  self.WBP_HUD_MiddleTop:HideRift()
end
function WBP_HUD_C:ShowRiftDestroyed()
  self.WBP_RiftCountDown.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.SuccessStage)
  self.WBP_HUD_MiddleTop:HideRift()
end
function WBP_HUD_C:ClearRift()
  UpdateVisibility(self.WBP_RiftCountDown, false)
  self.WBP_HUD_MiddleTop:HideRift()
end
function WBP_HUD_C:UpdateFps(deltatime)
  self.TextBlock_Fps:SetText(tostring(UE.UKismetMathLibrary.FTrunc(1 / deltatime)))
end
function WBP_HUD_C:LuaTick(InDeltaTime)
  self:UpdatePing()
  self:UpdateFps(InDeltaTime)
  if self.bNeedTickUpdateScrollList then
    if InteractUpdateTimer > InteractUpdateInterval then
      LogicHUD.UpdateScrollInteract()
      self.WBP_InteractScrollList:UpdateInteractScrollListByIndex(LogicHUD.CurInteractIdx)
      InteractUpdateTimer = 0
    else
      InteractUpdateTimer = InteractUpdateTimer + InDeltaTime
    end
  end
  self.WBP_HUD_MiddleTop:RiftTick()
end
function WBP_HUD_C:BindOnCharacterRescue(Bind)
  local pawn = self:GetOwningPlayerPawn()
  if pawn and pawn:IsValid() and Bind then
    pawn.OnCharacterRescue:Add(self, WBP_HUD_C.OnCharacterRescue)
  end
end
function WBP_HUD_C:OnCharacterRescue(Character)
  self.ScreenEdgeFXUI:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WBP_DyingHUD:HideDying()
end
function WBP_HUD_C:OnHeroDying(HeroCharacter)
  local NickName = ""
  if HeroCharacter then
    NickName = HeroCharacter:GetUserNickName()
  end
  print("WBP_HUD_C OnHeroDying", NickName)
  if self:GetOwningPlayerPawn() == HeroCharacter then
    self.ScreenEdgeFXUI:SetVisibility(UE.ESlateVisibility.Hidden)
    UpdateVisibility(self.FullScreenFXCanvasPanel, false)
    self.WBP_DyingHUD:ShowDying()
  else
    print("WBP_HUD_C OnHeroDying TriggerMark:", NickName)
    local OwnerCharacter = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if OwnerCharacter then
      print("WBP_HUD_C OnHeroDying TriggerMark OwnerCharacter:", OwnerCharacter)
      local Result, RowData = GetRowData(DT.DT_Hero, OwnerCharacter:GetTypeID())
      if Result then
        print("WBP_HUD_C OnHeroDying TriggerMark RowName:", RowData.RescueInteractMark)
        self.DyingMarkTable[HeroCharacter] = UE.URGBlueprintLibrary.TriggerMark(self, HeroCharacter, RowData.RescueInteractMark)
      end
    end
  end
end
function WBP_HUD_C:OnHeroRescue(HeroCharacter)
  local NickName = ""
  if HeroCharacter then
    NickName = HeroCharacter:GetUserNickName()
  end
  print("WBP_HUD_C OnHeroRescue", NickName)
  if self:GetOwningPlayerPawn() == HeroCharacter then
    self.ScreenEdgeFXUI:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UpdateVisibility(self.FullScreenFXCanvasPanel, true)
    self.WBP_DyingHUD:HideDying()
  else
    print("WBP_HUD_C OnHeroRescue RemoveMark", NickName)
    UE.URGBlueprintLibrary.RemoveMarkById(self, self.DyingMarkTable[HeroCharacter])
  end
end
function WBP_HUD_C:OnHeroRespawn(HeroCharacter)
  local NickName = ""
  if HeroCharacter then
    NickName = HeroCharacter:GetUserNickName()
  end
  print("WBP_HUD_C OnHeroRespawn", NickName)
  if self:GetOwningPlayerPawn() == HeroCharacter then
    self.ScreenEdgeFXUI:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UpdateVisibility(self.FullScreenFXCanvasPanel, true)
    self.WBP_DyingHUD:HideDying()
  else
    print("WBP_HUD_C OnHeroRespawn RemoveMark", NickName)
    UE.URGBlueprintLibrary.RemoveMarkById(self, self.DyingMarkTable[HeroCharacter])
  end
end
function WBP_HUD_C:UpdateTeamVoiceUI()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
    local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
    UpdateVisibility(self.CanvasPanelFreeSpeak, 1 == CurValue)
    UpdateVisibility(self.CanvasPanelPressSpeak, 1 == CurValue)
    UpdateVisibility(self.CanvasPanelCloseFreeSpeak, 0 == CurValue)
  end
end
function WBP_HUD_C:InitLevelTips()
  self.WBP_EnterLevelTips:Init()
  self.WBP_LevelCleanTips:Init()
end
function WBP_HUD_C:UnInitLevelTips()
  self.WBP_EnterLevelTips:UnInit()
  self.WBP_LevelCleanTips:UnInit()
end
function WBP_HUD_C:ListenLevelOnLevelClean(IsListen)
  if IsListen then
    ListenObjectMessage(nil, GMP.MSG_Level_LevelPass, self, self.SetCurLevelCleanId)
  else
    UnListenObjectMessage(GMP.MSG_Level_LevelPass, self)
  end
end
function WBP_HUD_C:ListenGlobalAbilityRadio(IsListen)
  if IsListen then
    ListenObjectMessage(nil, GMP.MSG_Global_AbilityRadio, self, self.SetCurTriggerSkillId)
  else
    UnListenObjectMessage(GMP.MSG_Global_AbilityRadio, self)
  end
end
function WBP_HUD_C:ListenHeroDying(IsListen)
  if IsListen then
    ListenObjectMessage(nil, GMP.MSG_Hero_NotifyDying, self, self.OnHeroDying)
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if not Character then
      return
    end
    if Character.LifeState == UE.ERGLifeState.Dying then
      self:OnHeroDying(Character)
    end
  else
    UnListenObjectMessage(GMP.MSG_Hero_NotifyDying, self)
  end
end
function WBP_HUD_C:ListenHeroRescue(IsListen)
  if IsListen then
    ListenObjectMessage(nil, GMP.MSG_Hero_NotifyRescue, self, self.OnHeroRescue)
  else
    UnListenObjectMessage(GMP.MSG_Hero_NotifyRescue, self)
  end
end
function WBP_HUD_C:ListenHeroRespawn(IsListen)
  if IsListen then
    ListenObjectMessage(nil, GMP.MSG_Hero_NotifyRespawn, self, self.OnHeroRespawn)
  else
    UnListenObjectMessage(GMP.MSG_Hero_NotifyRespawn, self)
  end
end
function WBP_HUD_C:TidyAttributeChangeTips(AttributeChangeTipsDataAry)
  local TidyArr = {}
  for key, value in iterator(AttributeChangeTipsDataAry) do
    if value.AttributeChangeTipsId ~= nil then
      if not TidyArr[value.AttributeChangeTipsId] then
        TidyArr[value.AttributeChangeTipsId] = {}
      end
      table.insert(TidyArr[value.AttributeChangeTipsId], value)
    end
  end
  if not self.AttributeChangeTipsDataAryTemp then
    self.AttributeChangeTipsDataAryTemp = UE.TArray(UE.FAttributeChangeTipsData())
  end
  for key, value in pairs(TidyArr) do
    local AttributeData = UE.FAttributeChangeTipsData()
    for index, Values in ipairs(value) do
      if 1 == index then
        AttributeData = Values
      end
      AttributeData.NewValue = Values.NewValue
    end
    self.AttributeChangeTipsDataAryTemp:Add(AttributeData)
  end
end
function WBP_HUD_C:OnAttributeChangeTips(AttributeChangeTipsDataAry)
  self:TidyAttributeChangeTips(AttributeChangeTipsDataAry)
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    self.OnDelayAttributeChangeTips
  })
end
function WBP_HUD_C:OnDelayAttributeChangeTips()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local Result, RowInfo = GetRowData(DT.DT_WaveWindow, "1117")
  if not Result then
    return
  end
  for i, v in iterator(self.AttributeChangeTipsDataAryTemp) do
    local WaveWindowParam = UE.FWaveWindowParam()
    WaveWindowParam.IntParam0 = v.AttributeChangeTipsId
    WaveWindowParam.FloatParam0 = v.OldValue
    WaveWindowParam.FloatParam1 = v.NewValue
    local WidgetClass = UE.URGAssetManager.GetAssetByPath(RowInfo.WidgetClass, true)
    local Widget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
    if Widget then
      EventSystem.Invoke(EventDef.PickTipList.OnAddPickTipList, Widget)
      Widget:SetWaveWindowParam(WaveWindowParam)
    end
  end
  self.AttributeChangeTipsDataAryTemp:Clear()
end
function WBP_HUD_C:UpdateConiVis()
  self.Coin:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CoinVisTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CoinVisTimer)
  end
  self.CoinVisTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.Coin:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  }, self.CoinDuration, false)
end
function WBP_HUD_C:BindOnPostItemChanged(ArticleId, OldStack, NewStack)
  local ItemId = UE.URGArticleStatics.GetConfigId(ArticleId)
  if ItemId == self.Coin.ItemId then
    self:UpdateConiVis()
  elseif 9999900 == ItemId then
    self:UpdateSurvivalItemCount()
  elseif 9999901 == ItemId then
    self:UpdateSurvivalItemCount()
  end
end
function WBP_HUD_C:ShowUIEffect(AniName, PlayMode)
  if nil == PlayMode then
    PlayMode = UE.EUMGSequencePlayMode.Forward
  end
  if -1 == self.UIEffectInst then
    self.UIEffectInst = UE.URGUIEffectMgr.Get(self):CreateEffect(4, AniName)
  else
    local uiEffectWidget = UE.URGUIEffectMgr.Get(self):GetEffect(self.UIEffectInst)
    if uiEffectWidget then
      uiEffectWidget:ShowEffect()
      if PlayMode == UE.EUMGSequencePlayMode.Reverse then
        uiEffectWidget:PlayAnimation(uiEffectWidget[AniName], 0, 1, PlayMode, 1.0)
      elseif not uiEffectWidget:IsAnimationPlaying(uiEffectWidget[AniName]) then
        uiEffectWidget:PlayAnimation(uiEffectWidget[AniName], 0, 1, PlayMode, 1.0)
      end
    end
  end
end
function WBP_HUD_C:IsSurvivalMode()
  return LogicSurvivor.IsSurvivalMode()
end
function WBP_HUD_C:InitSurvivalExp()
  local IsSurvival = self:IsSurvivalMode()
  UpdateVisibility(self.CanvasPanel_SurvivalExp, IsSurvival)
  if not IsSurvival then
    return
  end
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return
  end
  local BattleExpManager = GS:GetComponentByClass(UE.URGBattleExpManager:StaticClass())
  if not BattleExpManager then
    return
  end
  local character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not character then
    return
  end
  local SurvavilBattleInfo = BattleExpManager:GetBattleExpInfo(character:GetUserId())
  local ExpLevel = SurvavilBattleInfo.ExpLevel
  self.ExpLevel = ExpLevel
  self.TxT_Level:SetText(ExpLevel)
  local CurLevelResult, CurLevelRowData = GetRowData(DT.DT_BattleMonsterExpLevel, ExpLevel)
  local NextLevelResult, NextLevelRowData = GetRowData(DT.DT_BattleMonsterExpLevel, ExpLevel + 1)
  if CurLevelResult and NextLevelResult then
    local CurExp = SurvavilBattleInfo.Exp - CurLevelRowData.Exp
    local MaxExp = NextLevelRowData.Exp - CurLevelRowData.Exp
    local LevelUpExp = string.format("%d/%d", CurExp, MaxExp)
    self.TXT_LevelUpExp:SetText(LevelUpExp)
    self.ProgressBar_Exp:SetPercent(CurExp / MaxExp)
  end
end
function WBP_HUD_C:InitSurvivalModify()
  local IsSurvival = self:IsSurvivalMode()
  local Visibility = IsSurvival and UE.ESlateVisibility.Visible or UE.ESlateVisibility.Hidden
  self.CanvasPanel_SurvivalBuild:SetVisibility(Visibility)
  if not IsSurvival then
    return
  end
  self.SurvivalUpgradeModifyCount = LogicGenericModify:GetSurvivalUpgradeModifyCount()
  self.SurvivalSpecificModifyCount = LogicGenericModify:GetSurvivalSpecificModifyCount()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  self.PermissionSelectCount = 0
  if SurvivalModeComp then
    self.PermissionSelectCount = SurvivalModeComp.Count
  end
  self:UpdateSurvivalItemCount()
  UpdateVisibility(self.CanvasPanel_SurvivalTips, false)
end
function WBP_HUD_C:ListenForPermissionSelect()
  self:OnPermissionSelectClick()
end
function WBP_HUD_C:ListenForPermissionLevelUp()
  self:OnPermissionLevelUpClick()
end
function WBP_HUD_C:ListenForPotentialKey()
  self:OnPotentialKeyClick()
end
function WBP_HUD_C:OnPermissionSelectClick()
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_LevelReady_C.UIName) then
    return
  end
  if self.WBP_DyingHUD:IsVisible() then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_LikeAttributeModifyWindow_C.UIName) then
    return
  end
  LogicGenericModify:SurvivalModify()
end
function WBP_HUD_C:OnPermissionLevelUpClick()
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_LevelReady_C.UIName) then
    return
  end
  if self.WBP_DyingHUD:IsVisible() then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_LikeAttributeModifyWindow_C.UIName) then
    return
  end
  LogicGenericModify:SurvivalRequestUpgradeModify()
end
function WBP_HUD_C:OnPotentialKeyClick()
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    return
  end
  if self.WBP_DyingHUD:IsVisible() then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_LikeAttributeModifyWindow_C.UIName) then
    return
  end
  LogicGenericModify:SurvivalRequestSpecificModify()
end
function WBP_HUD_C:UpdateSurvivalItemCount()
  if not self:IsSurvivalMode() then
    return
  end
  local IsAddCount = false
  local SurvivalUpgradeModifyCount = LogicGenericModify:GetSurvivalUpgradeModifyCount()
  if SurvivalUpgradeModifyCount > self.SurvivalUpgradeModifyCount then
    self:PlayAnimation(self.Anim_PermissionLevelUp_Add)
    IsAddCount = true
  end
  self.SurvivalUpgradeModifyCount = SurvivalUpgradeModifyCount
  self.TXT_PermissionLevelUp:SetText(self.SurvivalUpgradeModifyCount)
  local PermissionLevelUpStatus = self.SurvivalUpgradeModifyCount > 0 and "HaveTimes" or "Normal"
  self.RGStateController_PermissionLevelUp:ChangeStatus(PermissionLevelUpStatus)
  local SurvivalSpecificModifyCount = LogicGenericModify:GetSurvivalSpecificModifyCount()
  if SurvivalSpecificModifyCount > self.SurvivalSpecificModifyCount then
    self:PlayAnimation(self.Anim_PotentialKey_Add)
    IsAddCount = true
  end
  self.SurvivalSpecificModifyCount = SurvivalSpecificModifyCount
  self.TXT_PotentialKey:SetText(self.SurvivalSpecificModifyCount)
  local PotentialKeyStatus = self.SurvivalSpecificModifyCount > 0 and "HaveTimes" or "Normal"
  self.RGStateController_PotentialKey:ChangeStatus(PotentialKeyStatus)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if SurvivalModeComp then
    local PermissionSelectCount = SurvivalModeComp.Count
    if PermissionSelectCount > self.PermissionSelectCount then
      self:PlayAnimation(self.Anim_PermissionSelect_Add)
      IsAddCount = true
    end
    self.PermissionSelectCount = PermissionSelectCount
    self.TxT_PermissionSelect:SetText(self.PermissionSelectCount)
    local PermissionSelectStatus = self.PermissionSelectCount > 0 and "HaveTimes" or "Normal"
    self.RGStateController_PermissionSelect:ChangeStatus(PermissionSelectStatus)
  end
  if IsAddCount and not SurvivorData.IsGuide() then
    self:ShowSurvivorGuide()
    SurvivorData.SetGuide(true)
  end
end
function WBP_HUD_C:OnAddSurvivalModify(PreviewModifyData)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if SurvivalModeComp then
    self.PermissionSelectCount = SurvivalModeComp.Count
    self.TxT_PermissionSelect:SetText(self.PermissionSelectCount)
  end
end
function WBP_HUD_C:OnUpgradeSurvivalModify(PreviewUpgradeModifyData)
  self:UpdateSurvivalItemCount()
end
function WBP_HUD_C:OnSurvivalSpecificModify(PreviewSpecificModifyData)
  self:UpdateSurvivalItemCount()
end
function WBP_HUD_C:OnModifyCountChange()
  self:UpdateSurvivalItemCount()
end
function WBP_HUD_C:BindOnNotifyWorldInfo()
  self:InitSurvivalExp()
  self:InitSurvivalModify()
end
function WBP_HUD_C:BindOnPlayerRevivalSuccess()
  self:InitSurvivalExp()
  self:InitSurvivalModify()
end
function WBP_HUD_C:ListenForSurvivalCtrl()
end
function WBP_HUD_C:GetSurvivorTips(Index)
  local Tips = self["Image_tips" .. Index]
  return Tips
end
function WBP_HUD_C:GetSurvivorDuration(Index)
  local Duration = self["SurvivorTipsTime" .. Index]
  return Duration
end
function WBP_HUD_C:ShowSurvivorGuide()
  do return end
  if self.SurvivorGuideTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.SurvivorGuideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.SurvivorGuideTimer)
  end
  UpdateVisibility(self.CanvasPanel_SurvivalTips, true)
  for i = 1, 3 do
    local Tips = self:GetSurvivorTips(i)
    UpdateVisibility(Tips, false)
  end
  local Index = 1
  self:DoShowSurvivorGuide(Index)
end
function WBP_HUD_C:DoShowSurvivorGuide(Index)
  UpdateVisibility(self:GetSurvivorTips(Index), true)
  self.SurvivorGuideTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      UpdateVisibility(self:GetSurvivorTips(Index), false)
      Index = Index + 1
      if Index <= 3 then
        self:DoShowSurvivorGuide(Index)
      elseif self.SurvivorGuideTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.SurvivorGuideTimer) then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.SurvivorGuideTimer)
      end
    end
  }, self:GetSurvivorDuration(Index), false)
end
function WBP_HUD_C:ListenForSurvivorPermission()
  if self.PermissionIndex ~= nil and self.PermissionIndex >= 3 then
    self:InactiveSurvivorInput()
    return
  end
  if self.PermissionIndex == nil then
    local SurvivalModifyCount = LogicGenericModify:GetSurvivalModifyCount()
    local SurvivalUpgradeModifyCount = LogicGenericModify:GetSurvivalUpgradeModifyCount()
    local SurvivalSpecificModifyCount = LogicGenericModify:GetSurvivalSpecificModifyCount()
    if SurvivalModifyCount > 0 then
      self.PermissionIndex = 1
    elseif SurvivalUpgradeModifyCount > 0 then
      self.PermissionIndex = 2
    elseif SurvivalSpecificModifyCount > 0 then
      self.PermissionIndex = 3
    end
    if self.PermissionIndex ~= nil then
      self:SetSurvivorGuideArea()
    end
    self:ActiveSurvivorInput()
  elseif not self:UpdatePermissionIndex(true) then
    self:InactiveSurvivorInput()
  else
    self:ActiveSurvivorInput()
  end
end
function WBP_HUD_C:ActiveSurvivorInput()
  if not self:IsSurvivalMode() then
    return
  end
  if not IsListeningForInputAction(self, self.SurvivorSelectRight) then
    ListenForInputAction(self.SurvivorSelectRight, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.ListenForSurvivorSelectRight
    })
  end
end
function WBP_HUD_C:InactiveSurvivorInput()
  self.PermissionIndex = nil
  UpdateVisibility(self.WBP_RGBeginnerGuidanceClickArea, false)
  StopListeningForInputAction(self, self.SurvivorSelectRight, UE.EInputEvent.IE_Pressed)
end
function WBP_HUD_C:SetSurvivorGuideArea()
  if self.PermissionIndex == nil then
    return
  end
  local SourceWidget
  if 1 == self.PermissionIndex then
    SourceWidget = self.Button_PermissionSelect
  elseif 2 == self.PermissionIndex then
    SourceWidget = self.Button_PermissionLevelUp
  elseif 3 == self.PermissionIndex then
    SourceWidget = self.Button_PotentialKey
  end
  if not SourceWidget then
    return
  end
  UpdateVisibility(self.WBP_RGBeginnerGuidanceClickArea, true)
  local SourceScreenPosition = UE.URGBlueprintLibrary.GetAbsolutePosition(SourceWidget:GetCachedGeometry())
  local TargetParent = self.WBP_RGBeginnerGuidanceClickArea:GetParent()
  local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(TargetParent:GetCachedGeometry(), SourceScreenPosition)
  self.WBP_RGBeginnerGuidanceClickArea.Slot:SetPosition(LocalPosition)
end
function WBP_HUD_C:BindOnFinishInteract()
  if not self:IsSurvivalMode() then
    return
  end
  self:InactiveSurvivorInput()
end
function WBP_HUD_C:ListenForSurvivorSelectRight()
  if not self:IsSurvivalMode() then
    return
  end
  if self.PermissionIndex == nil then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    return
  end
  if not self:UpdatePermissionIndex(true) then
    self:InactiveSurvivorInput()
  end
end
function WBP_HUD_C:ListenForSurvivorSelectLeft()
  if not self:IsSurvivalMode() then
    return
  end
  if self.PermissionIndex == nil then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    return
  end
  if not self:UpdatePermissionIndex(false) then
    self:InactiveSurvivorInput()
  end
end
function WBP_HUD_C:CheckPermissionIndex()
  local SurvivalModifyCount = LogicGenericModify:GetSurvivalModifyCount()
  local SurvivalUpgradeModifyCount = LogicGenericModify:GetSurvivalUpgradeModifyCount()
  local SurvivalSpecificModifyCount = LogicGenericModify:GetSurvivalSpecificModifyCount()
  if 1 == self.PermissionIndex and not (SurvivalModifyCount > 0) then
    return false
  end
  if 2 == self.PermissionIndex and not (SurvivalUpgradeModifyCount > 0) then
    return false
  end
  if 3 == self.PermissionIndex and not (SurvivalSpecificModifyCount > 0) then
    return false
  end
end
function WBP_HUD_C:UpdatePermissionIndex(IsAdd)
  local SurvivalModifyCount = LogicGenericModify:GetSurvivalModifyCount()
  local SurvivalUpgradeModifyCount = LogicGenericModify:GetSurvivalUpgradeModifyCount()
  local SurvivalSpecificModifyCount = LogicGenericModify:GetSurvivalSpecificModifyCount()
  local OldIndex = self.PermissionIndex
  if IsAdd then
    self.PermissionIndex = self.PermissionIndex + 1
    if self.PermissionIndex > 3 then
      self.PermissionIndex = OldIndex
      return false
    end
    if 2 == self.PermissionIndex then
      if not (SurvivalUpgradeModifyCount > 0) then
        if SurvivalSpecificModifyCount > 0 then
          self.PermissionIndex = 3
        else
          self.PermissionIndex = OldIndex
        end
      end
    elseif 3 == self.PermissionIndex and not (SurvivalSpecificModifyCount > 0) then
      self.PermissionIndex = OldIndex
    end
    self:SetSurvivorGuideArea()
  else
    self.PermissionIndex = self.PermissionIndex - 1
    if self.PermissionIndex < 1 then
      self.PermissionIndex = OldIndex
      return false
    end
    if 2 == self.PermissionIndex then
      if not (SurvivalUpgradeModifyCount > 0) then
        if SurvivalModifyCount > 0 then
          self.PermissionIndex = 1
        else
          self.PermissionIndex = OldIndex
        end
      end
    elseif 1 == self.PermissionIndex and not (SurvivalModifyCount > 0) then
      self.PermissionIndex = OldIndex
    end
    self:SetSurvivorGuideArea()
  end
  return OldIndex ~= self.PermissionIndex
end
function WBP_HUD_C:ListenForSurvivorConfirm()
  if self.PermissionIndex == nil then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    return
  end
  if 1 == self.PermissionIndex then
    self:OnPermissionSelectClick()
  elseif 2 == self.PermissionIndex then
    self:OnPermissionLevelUpClick()
  elseif 3 == self.PermissionIndex then
    self:OnPotentialKeyClick()
  end
end
return WBP_HUD_C
