local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local ChipData = require("Modules.Chip.ChipData")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local SettlementConfig = require("GameConfig.Settlement.SettlementConfig")
local WBP_SettlementIncomeItem_C = require("Rouge.UI.Battle.Settlement.WBP_SettlementIncomeItem_C")
local WBP_SettlementInComeView_C = UnLua.Class()
local ExpTxt = UE.URGBlueprintLibrary.TextFromStringTable("1151")
local FinisCountDown = 9
local IncreaseHour = 5

function WBP_SettlementInComeView_C:Construct()
  self.Overridden.Construct(self)
  self.WBP_CommonButton_Finish.OnMainButtonClicked:Add(self, self.FinishClick)
  self.WBP_CommonButton_CheckEff.OnMainButtonClicked:Add(self, self.CheckClick)
  self.WBP_CommonButton_Talent.OnMainButtonClicked:Add(self, self.OpenTalentClick)
  self.Btn_RewardIncrease.OnPressed:Add(self, self.OnRewardIncreasePressed)
  self.Btn_RewardIncrease.OnReleased:Add(self, self.OnRewardIncreaseReleased)
  self.Btn_RewardIncrease.OnHovered:Add(self, self.OnRewardIncreaseHovered)
  self.Btn_RewardIncrease.OnUnhovered:Add(self, self.OnRewardIncreaseUnHovered)
  self.WBP_CommonButton_SaveGrowthSnap.OnMainButtonClicked:Add(self, self.OpenSaveGrowthSnap)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnTriggerBattleLagacyList, self, self.OnTriggerBattleLagacyList)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnTriggerCurrBattleLagacy, self, self.OnTriggerCurrBattleLagacy)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnBattleLagacyInscriptionReminderClose, self, self.OnInscriptionReminderClose)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnBattleLagacyModifyClose, self, self.OnModifyClose)
  EventSystem.AddListenerNew(EventDef.RewardIncrease.ReceiveRewardIncreaseSucc, self, self.OnReceiveRewardIncreaseSucc)
  EventSystem.AddListenerNew(EventDef.RewardIncrease.ReceiveRewardIncreaseFailed, self, self.OnRewardAbandomClick)
  EventSystem.AddListenerNew(EventDef.RewardIncrease.RewardIncreaseSucc, self, self.OnRewardIncreaseSucc)
end

function WBP_SettlementInComeView_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
  end
end

function WBP_SettlementInComeView_C:NextStep()
  self.StepTimer = 0
  self.CurSettleIncomeStep = self.CurSettleIncomeStep + 1
  if SettlementStepInfo[self.CurSettleIncomeStep] then
    self[SettlementStepInfo[self.CurSettleIncomeStep].FuncName](self)
    local aniName = SettlementStepInfo[self.CurSettleIncomeStep].AniName
    if aniName and "" ~= aniName and self[aniName] then
      self:PlayAnimation(self[aniName])
    end
  end
end

function WBP_SettlementInComeView_C:ShowInit()
  self.bIncreaseCountDownTimer = nil
  UpdateVisibility(self.CanvasPanelAchieved, false)
  UpdateVisibility(self.CanvasPanelExplorationEnded, false)
  self.RGTextDiff:SetText("")
  self.RGTextWorldName:SetText("")
  UpdateVisibility(self.CanvasPanelChip, false)
  UpdateVisibility(self.Canvas_BattleLagacy, false)
  UpdateVisibility(self.WBP_ProfySettlementUpgradeLevelView, false)
  UpdateVisibility(self.SizeBox_ChipList, false)
  UpdateVisibility(self.CanvasPanelOtherInCome, false)
  UpdateVisibility(self.CanvasPanel_BeginnerClearReward, false)
  UpdateVisibility(self.CanvasPanelOperator, false)
  UpdateVisibility(self.CanvasPanelIcrease, false)
  UpdateVisibility(self.Canvas_Hover, false)
  UpdateVisibility(self.up, false)
  print("WBP_SettlementInComeView_C:ShowInit", LogicSettlement:GetGameMode(), LogicSettlement:GetGameModeType())
  self:RefreshBtnSaveGrowthSnapVis()
  UpdateVisibility(self.WBP_CommonButton_Talent, LogicSettlement:GetGameModeType() ~= UE.EGameModeType.TowerClimb, true)
  self.Img_Cover:SetClippingValue(0)
  if LogicSettlement.ClearanceStatus == SettlementStatus.Finish then
    self.StateCtrl_Result:ChangeStatus(ESettleStatus.Succ)
  else
    self.StateCtrl_Result:ChangeStatus(ESettleStatus.Failed)
  end
end

function WBP_SettlementInComeView_C:RefreshBtnSaveGrowthSnapVis()
  local bShow = LogicSettlement:CheckCanShowSaveGrowthBtn()
  UpdateVisibility(self.Btn_SaveGrowthSnap, bShow, true)
  UpdateVisibility(self.WBP_SaveGrowth_AutoSave, bShow)
end

function WBP_SettlementInComeView_C:ShowModeInfo()
  if LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish then
    UpdateVisibility(self.CanvasPanelAchieved, true)
    UpdateVisibility(self.CanvasPanelExplorationEnded, false)
  else
    UpdateVisibility(self.CanvasPanelAchieved, false)
    UpdateVisibility(self.CanvasPanelExplorationEnded, true)
  end
  local difficulty = LogicSettlement:GetClearanceDifficulty()
  self.RGTextDiff:SetText(difficulty)
  local gameMode = LogicSettlement:GetGameMode()
  local result, row = GetRowData(DT.DT_GameMode, tostring(gameMode))
  if result then
    self.RGTextWorldName:SetText(row.Name)
  end
end

function WBP_SettlementInComeView_C:ShowBattleLagacyStep()
  if LogicSettlement.CheckHaveBattleLagacy() then
    if LogicSettlement.BattleLegacyData.bIsGenericModify then
      self:ShowBattleLagacyModifyChoosePanel(LogicSettlement.BattleLegacyData.BattleLegacyArray)
    else
      self:ShowBattleLagacy(LogicSettlement.BattleLegacyData)
    end
  else
    self:NextStep()
  end
end

function WBP_SettlementInComeView_C:ShowProfy()
  self.WBP_ProfySettlementUpgradeLevelView:Show()
end

function WBP_SettlementInComeView_C:ShowChip()
  UpdateVisibility(self.CanvasPanelChip, true)
  self.Txt_Desc:SetText(self.PuzzleTxtDesc)
  local puzzleList = LogicSettlement:GetOrInitPuzzleInfoList()
  self.curPuzzleNum = 0
  local index = 1
  if #puzzleList > 0 then
    self.Txt_Desc:SetText(self.PuzzleTxtDesc)
    UpdateVisibility(self.CanvasPanelIcrease, true)
    for idxPuzzle, vPuzzle in ipairs(puzzleList) do
      local item = GetOrCreateItem(self.ScrollBoxChipList, index, self.WBP_SettlementChipItem:GetClass())
      local chipId = tonumber(vPuzzle.ConfigId)
      local subAttr = vPuzzle.SubAttrList
      local puzzlePackageInfo = PuzzleData:CreatePuzzlePackageInfo(chipId, vPuzzle.BindHeroID, -1, vPuzzle.Inscription)
      local puzzleDetailInfo = PuzzleData:CreatePuzzleDetailInfo(subAttr)
      item:InitSettlementChipItem(chipId, 1, false, function()
        self:ShowPuzzleTips(true, item, puzzlePackageInfo, puzzleDetailInfo)
      end, function()
        self:ShowPuzzleTips(false)
      end, false, vPuzzle.DropType)
      index = index + 1
    end
    self.curPuzzleNum = index
  end
  local gemList = LogicSettlement:GetOrInitGemInfoList()
  if #gemList > 0 then
    self.Txt_Desc:SetText(self.GemTxtDesc)
    UpdateVisibility(self.CanvasPanelIcrease, true)
    for idxGem, vGem in ipairs(gemList) do
      local item = GetOrCreateItem(self.ScrollBoxChipList, index, self.WBP_SettlementChipItem:GetClass())
      local gemId = tonumber(vGem.resourceID)
      local gemPackageInfo = vGem
      item:InitSettlementChipItem(gemId, 1, false, function()
        self:ShowGemTips(true, item, gemId, gemPackageInfo)
      end, function()
        self:ShowGemTips(false)
      end, false, vGem.DropType)
      index = index + 1
    end
    self.curPuzzleNum = index
  end
  print(string.format("\230\156\172\229\177\128\229\156\168\233\154\190\229\186\166:%d,\232\142\183\229\190\151\230\160\184\229\191\131\230\149\176\233\135\143\228\184\186:%d", LogicSettlement:GetClearanceDifficulty(), #gemList))
  HideOtherItem(self.ScrollBoxChipList, index, true)
  if index <= 1 then
    UpdateVisibility(self.CanvasPanelIcrease, false)
    UpdateVisibility(self.SizeBox_ChipList, false)
    UpdateVisibility(self.Txt_NoChip, true)
  else
    UpdateVisibility(self.Txt_NoChip, false)
    UpdateVisibility(self.SizeBox_ChipList, true)
  end
end

function WBP_SettlementInComeView_C:ShowIncome()
  UpdateVisibility(self.CanvasPanelOtherInCome, true)
  local BaseValueExp, IncrementValueExp = LogicSettlement:GetExp()
  print("WBP_SettlementInComeView_C:RewardView Exp", BaseValueExp, IncrementValueExp)
  self.SettlementIncomeItemExp:InitByItemId(IncrementValueExp, 99996, ExpTxt, true)
  local BaseValueCommonSpirit, DetailsCommonSpirit = LogicSettlement:GetSettlementItemStackByConfigId(LogicSettlement:GetOrInitSelfPlayerId(), 99994)
  local TalentTxt = UE.URGBlueprintLibrary.TextFromStringTable("1152")
  self.SettlementIncomeItemCommonSpirit:InitByItemId(BaseValueCommonSpirit, 99994, TalentTxt, true)
  UpdateVisibility(self.SettlementIncomeItemRoleSpirit, false)
  local FragmentPropIdList = IllustratedGuideData:GetFragmentPropIdList()
  local FragmentCount = 0
  for i, v in ipairs(FragmentPropIdList) do
    local num = LogicSettlement:GetItemStacByConfigId(LogicSettlement:GetOrInitSelfPlayerId(), tonumber(v))
    if num > 0 then
      FragmentCount = FragmentCount + num
    end
  end
  local WorldId = LogicTeam.GetWorldId()
  local TbStoryWorld = LuaTableMgr.GetLuaTableByName(TableNames.TBWorld)
  local WorldPlotFragmentName = ""
  local WorldPlotFragmentIcon = ""
  for i, v in ipairs(TbStoryWorld) do
    if v.worldID == WorldId then
      WorldPlotFragmentName = v.SettlementIncomeItemName
      WorldPlotFragmentIcon = MakeStringToSoftObjectReference(v.SettlementIncomeItemIcon)
      break
    end
  end
  self.SettlementIncomeItemPlotFragment:Init(FragmentCount, WorldPlotFragmentName, WorldPlotFragmentIcon, true)
  print("WBP_SettlementInComeView_C:ShowIncome1", IncrementValueExp, BaseValueCommonSpirit, FragmentCount)
  local idx = 5
  local bHasInCome = false
  local IncomePropIdMap = {}
  for i, v in ipairs(SettlementIncomePropId) do
    if not IncomePropIdMap[v] then
      local item = GetOrCreateItem(self.WrapBoxInComeList, idx, self.SettlementIncomeItemPlotFragment:GetClass())
      local num, tbDetails, stackTotal = LogicSettlement:GetSettlementItemStackByConfigId(LogicSettlement:GetOrInitSelfPlayerId(), tonumber(v))
      item:InitByItemId(num, v, nil, true)
      idx = idx + 1
      IncomePropIdMap[v] = true
      if num > 0 then
        bHasInCome = true
      end
      print("WBP_SettlementInComeView_C:ShowIncome SettlementIncomePropId", num, v)
      if SettlementstatisticsIdMap[v] then
        local ResName = ""
        local resultGeneral, rowGeneral = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, v)
        if resultGeneral then
          ResName = tostring(rowGeneral.Name)
        end
        if stackTotal > 0 then
          print(string.format("\230\156\172\229\177\128\229\156\168\233\154\190\229\186\166:%d,\232\142\183\229\190\151\231\187\147\231\174\151\233\129\147\229\133\183ID:%d,\229\144\141\231\167\176:%s,\229\159\186\231\161\128\230\149\176\233\135\143\228\184\186:%d,\230\157\131\231\155\138\229\138\160\230\136\144\230\149\176\233\135\143\228\184\186:%d,\230\128\187\230\149\176\233\135\143\228\184\186:%d", LogicSettlement:GetClearanceDifficulty(), v, ResName, num, tbDetails.Value or 0, stackTotal))
        end
      end
    else
      UnLua.LogWarn("SettlementIncomePropId \233\133\141\231\189\174\230\156\137\233\135\141\229\164\141", v)
    end
  end
  local DetailsPrivilege = LogicSettlement:GetPrivilegeDetailList(LogicSettlement:GetOrInitSelfPlayerId())
  for i, v in ipairs(DetailsPrivilege) do
    local item = GetOrCreateItem(self.WrapBoxInComeList, idx, self.SettlementIncomeItemCommonSpirit:GetClass())
    item:InitByItemId(v.Value, v.ConfigId, nil, true, v)
    print("DetailsPrivilege", v.Value, v.ConfigId)
    idx = idx + 1
    if v.Value > 0 then
      bHasInCome = true
    end
  end
  print("WBP_SettlementInComeView_C:ShowIncome2", idx, bHasInCome)
  HideOtherItem(self.WrapBoxInComeList, idx)
  if IncrementValueExp + BaseValueCommonSpirit + FragmentCount <= 0 and not bHasInCome then
    UpdateVisibility(self.Txt_NoIncome, true)
  else
    UpdateVisibility(self.Txt_NoIncome, false)
  end
  self.Img_IncreaseIcon:SetIsEnabled(true)
  UpdateVisibility(self.RGTextUsed, false)
  self:UpdateIncreaseInfo(true)
  self:ShowBeginnerClearReward()
end

function WBP_SettlementInComeView_C:ShowBeginnerClearReward()
  if LogicTeam.GetModeId() ~= TableEnums.ENUMGameMode.BEGINERGUIDANCE then
    return
  end
  self:PlayAnimation(self.Ani_BeginnerClearReward_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
  UpdateVisibility(self.CanvasPanel_BeginnerClearReward, true)
  UpdateVisibility(self.Txt_BeginnerNoValue, LogicSettlement:GetClearanceStatus() ~= SettlementStatus.Finish)
  UpdateVisibility(self.ScrollBox_BeginnerClearRewardList, LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish)
  if LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish then
    local WorldId = LogicTeam.GetWorldId()
    local AllLevels = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
    local RowInfo
    for LevelID, LevelFloorInfo in pairs(AllLevels) do
      if LevelFloorInfo.gameWorldID == WorldId then
        RowInfo = LevelFloorInfo
        break
      end
    end
    local Index = 1
    if RowInfo then
      for i, RewardInfo in ipairs(RowInfo.FirstPassReward) do
        local Item = GetOrCreateItem(self.BeginnerClearRewardList, Index, self.BeginnerItemTemplate:StaticClass())
        Item:InitByItemId(RewardInfo.value, RewardInfo.key)
        Item:ShowBeginnerClearFlag()
        UpdateVisibility(Item, true)
        Index = Index + 1
      end
    end
    HideOtherItem(self.BeginnerClearRewardList, Index, true)
  end
end

function WBP_SettlementInComeView_C:UpdateIncreaseInfo(bRequest)
  if bRequest then
    local RewardIncreaseModule = ModuleManager:Get("RewardIncreaseModule")
    RewardIncreaseModule:RequestGetRewardIncreaseCount(nil, true)
  end
  if not self.bReciveRewardIncreaseSucc then
    if LogicSettlement.CheckIsInscreaseReward() then
      self.Txt_Num:SetText(DataMgr.RewardIncreaseCount)
      self.Txt_Num:SetColorAndOpacity(self.IncreaseEnableColor)
      self.Txt_EnableNum:SetText(DataMgr.RewardIncreaseCount)
      UpdateVisibility(self.Canvas_Enable, true)
      self.StateCtrl_Used:ChangeStatus(ESettleIncreaseUsed.UnUsed)
      UpdateVisibility(self.Canvas_Disable, false)
      UpdateVisibility(self.Txt_NumMax, true)
      self.bIncreaseCountDownTimer = nil
    else
      self.Txt_Num:SetText(0)
      self.Txt_Num:SetColorAndOpacity(self.IncreaseDisableColor)
      self.Txt_EnableNum:SetText(0)
      UpdateVisibility(self.Canvas_Enable, false)
      UpdateVisibility(self.Canvas_Disable, true)
      UpdateVisibility(self.Txt_NumMax, false)
      self.bIncreaseCountDownTimer = 0
      local timeStamp = CalcTartUnixTimeStamp(IncreaseHour)
      local countDown = os.time() - timeStamp
      self.Txt_CountDown:SetText(Format(countDown, "hh:mm:ss"))
      self.bIncreaseCountDownTimer = 0
    end
  end
end

function WBP_SettlementInComeView_C:ShowInteract()
  UpdateVisibility(self.CanvasPanelOperator, true)
  if LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish then
    EventSystem.Invoke(EventDef.Settlement.OnSettlementSuccess)
    local settlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
    if LogicSettlement:GetClearanceDifficulty() >= settlementView.ShowSaveGrowthDiffcult and not self.ParentView.bSaveGrowthSnapexpire and not BeginnerGuideData:CheckGuideIsFinished(310) and LogicSettlement:GetGameModeType() == UE.EGameModeType.TowerClimb then
      EventSystem.Invoke(EventDef.BeginnerGuide.OnSettlementInComeViewShow)
    end
  elseif LogicSettlement:GetGameModeType() ~= UE.EGameModeType.TowerClimb then
    EventSystem.Invoke(EventDef.Settlement.OnSettlementFail)
    print("WBP_SettlementInComeView_C:ShowInteract OnSettlementFail")
  end
end

function WBP_SettlementInComeView_C:ShowInComeView(ParentView)
  self.ParentView = ParentView
  self.CurSettleIncomeStep = -1
  UpdateVisibility(self, true)
  self:NextStep()
end

function WBP_SettlementInComeView_C:TriggerIncomeAni()
  print("WBP_SettlementInComeView_C:TriggerIncomeAni")
  if self.curPuzzleNum > 0 then
    self:PlayAnimation(self.Ani_Chip_In)
    local puzzleList = LogicSettlement:GetOrInitPuzzleInfoList()
    if #puzzleList > 0 then
      PlaySound2DByName("UI_Settle_DoubleReward_Appear", "\231\191\187\229\128\141\229\165\150\229\138\177\229\135\186\231\142\176")
    end
  else
    self:PlayAnimation(self.Ani_Other_In)
  end
end

function WBP_SettlementInComeView_C:TriggerAniOtherIn()
  print("WBP_SettlementInComeView_C:TriggerAniOtherIn")
  self:PlayAnimation(self.Ani_Other_In)
end

function WBP_SettlementInComeView_C:PlaySeq(SoftObjPath)
  local LevelSequenceAsset = UE.URGBlueprintLibrary.TryLoadSoftPath(SoftObjPath)
  if not LevelSequenceAsset then
    return
  end
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  local SequencePlayer, SequenceActor = UE.ULevelSequencePlayer.CreateLevelSequencePlayer(self, LevelSequenceAsset, setting, nil)
  if nil == SequencePlayer or nil == SequenceActor then
    print("[WBP_SettlementInComeView_C::Play] Player or SequenceActor is Empty!")
    return
  end
  SequencePlayer:Play()
end

function WBP_SettlementInComeView_C:UpdateClearanceStatus()
  if LogicSettlement:GetClearanceStatus() == SettlementStatus.Finish then
    UpdateVisibility(self.CanvasPanelAchieved, true)
    UpdateVisibility(self.CanvasPanelExplorationEnded, false)
    UpdateVisibility(self.VerticalBoxStrongerList, false, false, true)
  else
    UpdateVisibility(self.CanvasPanelAchieved, false)
    UpdateVisibility(self.CanvasPanelExplorationEnded, true)
  end
end

function WBP_SettlementInComeView_C:GetIconById(ItemId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local ItemRow = DTSubsystem:K2_GetItemTableRow(tostring(ItemId), nil)
    if ItemRow then
      return ItemRow.SpriteIcon
    end
  end
  return nil
end

function WBP_SettlementInComeView_C:GetNameById(ItemId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local ItemRow = DTSubsystem:K2_GetItemTableRow(tostring(ItemId), nil)
    if ItemRow then
      return ItemRow.Name
    end
  end
  return nil
end

function WBP_SettlementInComeView_C:FinishClick()
  LogicSettlement:HideSettlement()
end

function WBP_SettlementInComeView_C:OpenTalentClick()
  FuncUtil.AddClickStatistics("PromoteAbilitymodule")
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.TALENT) then
    return
  end
  EventSystem.Invoke(EventDef.Settlement.OnClickSettlementTalent)
  self.ParentView:OnOpenTalentClick()
end

function WBP_SettlementInComeView_C:OpenSaveGrowthSnap()
  if LogicSettlement:GetClearanceStatus() ~= SettlementStatus.Finish then
    ShowWaveWindow(1405)
    return
  end
  local settlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
  if LogicSettlement:GetClearanceDifficulty() < settlementView.ShowSaveGrowthDiffcult then
    ShowWaveWindow(1412, {
      settlementView.ShowSaveGrowthDiffcult
    })
    return
  end
  self.ParentView:OpenSaveGrowthSnap()
end

function WBP_SettlementInComeView_C:OnRewardIncrease()
  local RewardIncreaseModule = ModuleManager:Get("RewardIncreaseModule")
  RewardIncreaseModule:RequestReceiverewardIncrease()
end

function WBP_SettlementInComeView_C:OnRewardIncreasePressed()
  if LogicSettlement:CheckIsInscreaseReward() then
    self.IncreaseLongPressTimer = 0
    LogicAudio.StartPowerUpReward()
  end
end

function WBP_SettlementInComeView_C:OnRewardIncreaseReleased()
  if self.IncreaseLongPressTimer then
    self.bRevertIncreaseClip = true
  end
  self.IncreaseLongPressTimer = nil
  LogicAudio.EndPowerUpReward()
end

function WBP_SettlementInComeView_C:OnRewardIncreaseHovered()
end

function WBP_SettlementInComeView_C:OnRewardIncreaseUnHovered()
end

function WBP_SettlementInComeView_C:OnRewardAbandomClick()
end

function WBP_SettlementInComeView_C:OnAnimationFinished(Animation)
end

function WBP_SettlementInComeView_C:CheckClick()
  local SelfPlayerId = LogicSettlement:GetOrInitSelfPlayerId()
  print("WBP_SettlementInComeView_C:CheckClick", SelfPlayerId)
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowSettlementPlayerInfoView(SelfPlayerId)
  end
end

function WBP_SettlementInComeView_C:OnOpenTalentClick()
  UpdateVisibility(self.WBP_SettlementTalentView, true)
  self.WBP_SettlementTalentView:InitSettlementTalentView()
end

function WBP_SettlementInComeView_C:UpdateWorldList()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  local WorldList = LogicSettlement:GetWorldList()
  if DTSubsystem and WorldList then
    local Count = 1
    for iWorld, vWorld in ipairs(WorldList) do
      local WorldItem = GetOrCreateItem(self.ScrollBoxWorldList, Count, self.WBP_SettlementWorldItem:GetClass())
      local ResultWorld, World = DTSubsystem:GetWorldTableRow(vWorld.PassInfo.WorldId)
      if ResultWorld then
        local WorldInfo = {
          bIsFinish = vWorld.bPass,
          WorldIcon = World.WorldIcon,
          Name = World.WorldName,
          bIsFirst = 1 == iWorld,
          WorldBg = World.WorldBg,
          bUnKnow = vWorld.bUnKnow
        }
        WorldItem:Init(WorldInfo)
        Count = Count + 1
      end
    end
    HideOtherItem(self.ScrollBoxWorldList, Count)
  end
end

function WBP_SettlementInComeView_C:ShowPuzzleTips(bIsShow, Target, puzzlePackageInfo, puzzleDetailInfo)
  UpdateVisibility(self.RGAutoLoadPanelChipAttrListTips, bIsShow)
  if bIsShow then
    self.RGAutoLoadPanelChipAttrListTips:SetRenderOpacity(0)
    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
      GameInstance,
      function()
        UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
          GameInstance,
          function()
            self.RGAutoLoadPanelChipAttrListTips:SetRenderOpacity(1)
            local GeometryTarget = Target:GetCachedGeometry()
            local GeometryCanvasPanelTips = self.CanvasPanelTips:GetCachedGeometry()
            local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelTips, GeometryTarget)
            local tipsSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.RGAutoLoadPanelChipAttrListTips)
            local TipsSize = self.RGAutoLoadPanelChipAttrListTips.ChildWidget:GetDesiredSize()
            self.RGAutoLoadPanelChipAttrListTips.Slot:SetSize(TipsSize)
            local HoverItemSize = UE.FVector2D(self.ChipItemSize.X, self.ChipItemSize.Y)
            local PosType = LogicCommonTips.GetCommonTipsType(self.CanvasPanelTips, GeometryTarget, self.RGAutoLoadPanelChipAttrListTips, TipsSize)
            LogicCommonTips.SetCommonTipsAbsolutePosition(Pos, HoverItemSize, self.RGAutoLoadPanelChipAttrListTips, PosType, TipsSize, self.ChipTipsOffset, true)
            self.RGAutoLoadPanelChipAttrListTips.ChildWidget:ShowWithoutOperator(nil, puzzlePackageInfo, puzzleDetailInfo)
          end
        })
      end
    })
  end
end

function WBP_SettlementInComeView_C:ShowGemTips(bIsShow, Target, GemId, GemPackageInfo)
  UpdateVisibility(self.RGAutoLoadPanelGemTips, bIsShow)
  if bIsShow then
    self.RGAutoLoadPanelGemTips:SetRenderOpacity(0)
    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
      GameInstance,
      function()
        UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
          GameInstance,
          function()
            self.RGAutoLoadPanelGemTips:SetRenderOpacity(1)
            local GeometryTarget = Target:GetCachedGeometry()
            local GeometryCanvasPanelTips = self.CanvasPanelTips:GetCachedGeometry()
            local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelTips, GeometryTarget)
            local tipsSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.RGAutoLoadPanelGemTips)
            local TipsSize = self.RGAutoLoadPanelGemTips.ChildWidget:GetDesiredSize()
            self.RGAutoLoadPanelGemTips.Slot:SetSize(TipsSize)
            local HoverItemSize = UE.FVector2D(self.ChipItemSize.X, self.ChipItemSize.Y)
            local PosType = LogicCommonTips.GetCommonTipsType(self.CanvasPanelTips, GeometryTarget, self.RGAutoLoadPanelChipAttrListTips, TipsSize)
            LogicCommonTips.SetCommonTipsAbsolutePosition(Pos, HoverItemSize, self.RGAutoLoadPanelGemTips, PosType, TipsSize, self.ChipTipsOffset, true)
            self.RGAutoLoadPanelGemTips.ChildWidget:ShowWithoutOperator(GemId, GemPackageInfo)
          end
        })
      end
    })
  end
end

function WBP_SettlementInComeView_C:ShowBattleLagacyModifyChoosePanel(BattleLagacyList)
  print("WBP_SettlementInComeView_C:ShowBattleLagacyModifyChoosePanel", BattleLagacyList)
  if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    local genericModifyPanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if genericModifyPanel then
      genericModifyPanel:InitGenericModifyChoosePanelByBattleLagacy(BattleLagacyList)
    end
  end
end

function WBP_SettlementInComeView_C:ShowBattleLagacy(CurBattleLagacyData)
  print("WBP_SettlementInComeView_C:ShowBattleLagacy CurBattleLagacyData", CurBattleLagacyData)
  if not RGUIMgr:IsShown(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName)
    local battleLagacyInscriptionRewardReminder = RGUIMgr:GetUI(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName)
    if battleLagacyInscriptionRewardReminder then
      battleLagacyInscriptionRewardReminder:InitBattleLagacyInscriptionRewardReminder(CurBattleLagacyData, true)
    end
  end
end

function WBP_SettlementInComeView_C:OnTriggerBattleLagacyList(BattleLagacyList)
  self.BattleLagacyList = BattleLagacyList
  if self.bCanShowBattleLagacy then
    self:ShowBattleLagacyModifyChoosePanel(BattleLagacyList)
  end
end

function WBP_SettlementInComeView_C:OnTriggerCurrBattleLagacy(CurBattleLagacyData)
  self.CurBattleLagacyData = CurBattleLagacyData
  UpdateVisibility(self.Canvas_BattleLagacy, true)
  if CurBattleLagacyData.BattleLagacyType == EBattleLagacyType.Inscription then
    self:ShowBattleLagacy(CurBattleLagacyData)
    UpdateVisibility(self.WBP_SettlementBattleLagacyModifyItem, false)
    UpdateVisibility(self.WBP_SettlementBattleLagacyInscriptionItem, true, true)
    self.WBP_SettlementBattleLagacyInscriptionItem:InitSettlementBattleLagacyInscription(CurBattleLagacyData)
    self.WBP_SettlementBattleLagacyInscriptionItem:PlayAnimation(self.WBP_SettlementBattleLagacyInscriptionItem.Ani_in)
  else
    UpdateVisibility(self.WBP_SettlementBattleLagacyModifyItem, true, true)
    UpdateVisibility(self.WBP_SettlementBattleLagacyInscriptionItem, false)
    if self.WBP_SettlementBattleLagacyModifyItem.InitSettlementBattleLagacyModify then
      self.WBP_SettlementBattleLagacyModifyItem:InitSettlementBattleLagacyModify(CurBattleLagacyData, self)
      self.WBP_SettlementBattleLagacyModifyItem:PlayAnimation(self.WBP_SettlementBattleLagacyModifyItem.Ani_in)
    end
  end
end

function WBP_SettlementInComeView_C:OnModifyClose()
  print("WBP_SettlementInComeView_C:OnModifyClose()")
  self:NextStep()
end

function WBP_SettlementInComeView_C:OnInscriptionReminderClose()
  print("WBP_SettlementInComeView_C:OnInscriptionReminderClose()")
  UpdateVisibility(self.Canvas_BattleLagacy, true)
  UpdateVisibility(self.WBP_SettlementBattleLagacyInscriptionItem, true, true)
  UpdateVisibility(self.WBP_SettlementBattleLagacyModifyItem, false)
  self.WBP_SettlementBattleLagacyModifyItem:PlayAnimation(self.WBP_SettlementBattleLagacyModifyItem.Ani_in)
  self.WBP_SettlementBattleLagacyInscriptionItem:PlayAnimation(self.WBP_SettlementBattleLagacyInscriptionItem.Ani_in)
  self.WBP_SettlementBattleLagacyInscriptionItem:InitSettlementBattleLagacyInscription(LogicSettlement.BattleLegacyData)
  self:NextStep()
end

function WBP_SettlementInComeView_C:InvokeBDSettlementFailEvent(...)
  print("WBP_SettlementInComeView_C:InvokeBDSettlementFailEvent", LogicSettlement:GetClearanceStatus(), self.IsShowBattleLegacyView, self.IsShowIncreaseRewardPanel)
  if LogicSettlement:GetClearanceStatus() ~= SettlementStatus.Finish and not self.IsShowBattleLegacyView and not self.IsShowIncreaseRewardPanel and LogicSettlement:GetGameModeType() ~= UE.EGameModeType.TowerClimb then
    EventSystem.Invoke(EventDef.Settlement.OnSettlementFail)
  end
end

function WBP_SettlementInComeView_C:LuaTick(InDeltaTime)
  if self.CurSettleIncomeStep and SettlementStepInfo[self.CurSettleIncomeStep] then
    self.StepTimer = self.StepTimer + InDeltaTime
    if self.StepTimer > SettlementStepInfo[self.CurSettleIncomeStep].Duration then
      self:NextStep()
    end
  end
  if self.IncreaseLongPressTimer then
    if self.IncreaseLongPressTimer <= SettlementConfig.LongPressTime then
      self.IncreaseLongPressTimer = self.IncreaseLongPressTimer + InDeltaTime
      self.Img_Cover:SetClippingValue(self.IncreaseLongPressTimer / SettlementConfig.LongPressTime)
      UpdateVisibility(self.Canvas_Hover, true)
      UpdateVisibility(self.up, true)
      UpdateVisibility(self.Img_IncreaseBg_02, false)
    else
      self:OnRewardIncrease()
      self.IncreaseLongPressTimer = nil
      LogicAudio.EndPowerUpReward()
      self.Img_Cover:SetClippingValue(0)
      UpdateVisibility(self.Img_IncreaseBg_02, true)
      UpdateVisibility(self.up, false)
      UpdateVisibility(self.Canvas_Hover, false)
    end
  end
  if self.bRevertIncreaseClip then
    local clip = self.Img_Cover.ClippingValue
    if clip > 0 then
      clip = clip - InDeltaTime / SettlementConfig.IncreaseRevertTime
      if clip < 0 then
        clip = 0
      end
      self.Img_Cover:SetClippingValue(clip)
      UpdateVisibility(self.Canvas_Hover, true)
      UpdateVisibility(self.up, false)
    else
      self.bRevertIncreaseClip = false
      self.Img_Cover:SetClippingValue(0)
      UpdateVisibility(self.Canvas_Hover, false)
      UpdateVisibility(self.up, false)
      UpdateVisibility(self.Img_IncreaseBg_02, true)
    end
  end
  if self.bIncreaseCountDownTimer then
    if self.bIncreaseCountDownTimer >= 1 then
      local timeStamp = CalcTartUnixTimeStamp(IncreaseHour)
      local countDown = timeStamp - os.time()
      self.Txt_CountDown:SetText(Format(countDown, "hh:mm:ss"))
      self.bIncreaseCountDownTimer = 0
      if countDown >= 86397 then
        self:UpdateIncreaseInfo(true)
      end
    else
      self.bIncreaseCountDownTimer = self.bIncreaseCountDownTimer + InDeltaTime
    end
  end
  if table.IsEmpty(self.IncreaseChipItemTb) then
    return
  end
  if self.IncreaseChipIdx > #self.IncreaseChipItemTb then
    return
  end
  if not self.PreTimeStamp then
    return
  end
  if self.PreTimeStamp > self.IncreaseChipAniInterval then
    self.IncreaseChipItemTb[self.IncreaseChipIdx]:PlayAnimation(self.IncreaseChipItemTb[self.IncreaseChipIdx].Ani_in)
    self.PreTimeStamp = 0
    self.IncreaseChipIdx = self.IncreaseChipIdx + 1
  else
    self.PreTimeStamp = self.PreTimeStamp + InDeltaTime
  end
end

function WBP_SettlementInComeView_C:ShowGenericModifyBagTips(bIsShow, ModifyId)
  UpdateVisibility(self.WBP_GenericModifyBagTips, bIsShow)
  if bIsShow then
    self.WBP_GenericModifyBagTips:InitGenericModifyTips(tonumber(ModifyId), false, -1)
  end
end

function WBP_SettlementInComeView_C:OnRewardIncreaseSucc()
  self:UpdateIncreaseInfo()
end

function WBP_SettlementInComeView_C:OnReceiveRewardIncreaseSucc(resources)
  self.bReciveRewardIncreaseSucc = true
  LuaAddClickStatistics("ResultExtraReward")
  self.Img_IncreaseIcon:SetIsEnabled(false)
  self.StateCtrl_Used:ChangeStatus(ESettleIncreaseUsed.Used)
  UpdateVisibility(self.RGTextUsed, false)
  UpdateVisibility(self.Btn_RewardIncrease, false)
  UpdateVisibility(self.Canvas_UnHover, true)
  self.IsShowIncreaseRewardPanel = false
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not tbGeneral then
    return
  end
  self.IncreaseChipItemTb = {}
  self.IncreaseChipIdx = 1
  self.PreTimeStamp = 0
  local chipIdx = self.curPuzzleNum
  for i, v in ipairs(resources) do
    if tbGeneral[v.rid] and tbGeneral[v.rid].Type == TableEnums.ENUMResourceType.Puzzle then
      local item = GetOrCreateItem(self.ScrollBoxChipList, chipIdx, self.WBP_SettlementChipItem:GetClass())
      local chipId = tonumber(v.rid)
      local subAttr = PuzzleData:ConvertV2Struct(v.extra.subattrV2)
      local puzzlePackageInfo = PuzzleData:CreatePuzzlePackageInfo(v.rid, v.extra.bindheroID, -1, v.extra.inscription)
      local puzzleDetailInfo = PuzzleData:CreatePuzzleDetailInfo(subAttr)
      item:InitSettlementChipItem(chipId, v.amount, false, function()
        self:ShowPuzzleTips(true, item, puzzlePackageInfo, puzzleDetailInfo)
      end, function()
        self:ShowPuzzleTips(false)
      end, true)
      table.insert(self.IncreaseChipItemTb, item)
      chipIdx = chipIdx + 1
    elseif tbGeneral[v.rid] and tbGeneral[v.rid].Type == TableEnums.ENUMResourceType.Gem then
      local item = GetOrCreateItem(self.ScrollBoxChipList, chipIdx, self.WBP_SettlementChipItem:GetClass())
      local gemId = tonumber(v.rid)
      local gemPackageInfo = {
        resourceID = v.rid,
        uniqueID = "0",
        mutation = false,
        level = 0,
        mutationAttr = {},
        mainAttrIDs = v.extra.mainAttrIDs,
        state = 0,
        pzUniqueID = "0"
      }
      item:InitSettlementChipItem(gemId, v.amount, false, function()
        self:ShowGemTips(true, item, gemId, gemPackageInfo)
      end, function()
        self:ShowGemTips(false)
      end, true)
      table.insert(self.IncreaseChipItemTb, item)
      chipIdx = chipIdx + 1
    end
  end
  HideOtherItem(self.ScrollBoxChipList, chipIdx, true)
  if LogicSettlement.CheckIsInscreaseReward() then
    self.Txt_Num:SetText(DataMgr.RewardIncreaseCount)
    self.Txt_Num:SetColorAndOpacity(self.IncreaseEnableColor)
    self.Txt_EnableNum:SetText(DataMgr.RewardIncreaseCount)
  else
    self.Txt_Num:SetText(0)
    self.Txt_Num:SetColorAndOpacity(self.IncreaseDisableColor)
    self.Txt_EnableNum:SetText(0)
  end
  self:PlayAnimation(self.Ani_succeed)
  print("##############################")
  print("          \229\165\150\229\138\177\231\191\187\229\128\141             ")
  print("##############################")
end

function WBP_SettlementInComeView_C:Destruct()
  self.WBP_CommonButton_Finish.OnMainButtonClicked:Remove(self, self.FinishClick)
  self.WBP_CommonButton_CheckEff.OnMainButtonClicked:Remove(self, self.CheckClick)
  self.WBP_CommonButton_Talent.OnMainButtonClicked:Remove(self, self.OpenTalentClick)
  self.WBP_CommonButton_SaveGrowthSnap.OnMainButtonClicked:Remove(self, self.OpenSaveGrowthSnap)
  self.IncreaseChipItemTb = {}
  self.IncreaseChipIdx = 1
  self.PreTimeStamp = nil
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnTriggerBattleLagacyList, self, self.OnTriggerBattleLagacyList)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnTriggerCurrBattleLagacy, self, self.OnTriggerCurrBattleLagacy)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnBattleLagacyInscriptionReminderClose, self, self.OnInscriptionReminderClose)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnBattleLagacyModifyClose, self, self.OnModifyClose)
  EventSystem.RemoveListenerNew(EventDef.RewardIncrease.ReceiveRewardIncreaseSucc, self, self.OnReceiveRewardIncreaseSucc)
  EventSystem.RemoveListenerNew(EventDef.RewardIncrease.ReceiveRewardIncreaseFailed, self, self.OnRewardAbandomClick)
  EventSystem.RemoveListenerNew(EventDef.RewardIncrease.RewardIncreaseSucc, self, self.OnRewardIncreaseSucc)
end

return WBP_SettlementInComeView_C
