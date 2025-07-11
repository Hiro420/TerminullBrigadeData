local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local ChipData = require("Modules.Chip.ChipData")
local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")
local SaveGrowthSnapHandler = require("Protocol.SaveGrowthSnap.SaveGrowthSnapHandler")
local rapidjson = require("rapidjson")
require("Rouge.UI.HUD.Logic.Logic_Lobby")
require("GameConfig.Settlement.SettlementConfig")
local M = {
  Widget = nil,
  Exp = 0,
  IncrementExp = 0,
  ClearanceWorlds = {},
  ClearanceStatus = SettlementStatus.Finish,
  CommonSpirit = 0,
  IncrementGetCommonSpirit = 0,
  RoleSpirit = 0,
  IncrementRoleSpirit = 0,
  ClearanceDuration = 3600,
  PlayerList = nil,
  SelfPlayerId = -1,
  SummaryDataMap = nil
}
_G.LogicSettlement = _G.LogicSettlement or M
local RankScoreRatio = {
  1,
  0.6,
  0.3
}
function LogicSettlement.Clear()
  LogicSettlement.PlayerInfoList = nil
  LogicSettlement.MvpPlayer = nil
  LogicSettlement.PlayerTitleMap = nil
  LogicSettlement.PlayerList = nil
  LogicSettlement.CommonSpirit = 0
  LogicSettlement.IncrementGetCommonSpirit = 0
  LogicSettlement.RoleSpirit = 0
  LogicSettlement.SummaryDataMap = nil
  LogicSettlement.PlayerToItemListData = nil
  LogicSettlement.PlayerToGenericListData = nil
  LogicSettlement.PlayerToScrollListData = nil
  LogicSettlement.SelfHeroId = -1
  LogicSettlement.SelfPlayerId = -1
  LogicSettlement.ChipSubAttrList = nil
  LogicSettlement.GameMode = 0
  LogicSettlement.bIsInited = false
  LogicSettlement.BattleLegacyData = nil
  LogicSettlement.PuzzleInfoList = nil
  LogicSettlement.GemInfoList = nil
  UE.URGStatisticsSubsystem.Get(GameInstance):ClearSettlementData()
  UnListenObjectMessage(GMP.MSG_OnSettlement, GameInstance)
  LogicSettlement.bInited = false
end
function LogicSettlement.ShowSettlement()
  UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
    GameInstance,
    function()
      LogicSettlement.InitSettlementData()
      LogicSettlement.ChangeLevel()
      local chipSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGChipSubsystem:StaticClass())
      if chipSubSys then
        chipSubSys:ResetInfo()
      end
    end
  })
end
function LogicSettlement.InitSettlementData()
  if LogicSettlement.bIsInited then
    return
  end
  LogicSettlement.bIsInited = true
  LogicSettlement.PlayerInfoList = nil
  LogicSettlement.MvpPlayer = nil
  LogicSettlement.PlayerTitleMap = nil
  if LogicSettlement.ClearanceStatus == SettlementStatus.Exit then
    LogicSettlement:InitGeneircListByExit()
    LogicSettlement:InitScrollListByExit()
    LogicSettlement:InitItemListByExit()
  end
  LogicSettlement:InitGameMode()
  LogicSettlement:GetOrInitSelfPlayerId()
  LogicSettlement:GetOrInitPlayerList()
  LogicSettlement:CalcTitle()
  LogicSettlement:CalMvp()
  LogicSettlement:GetOrInitCurHeroId()
  LogicSettlement:InitClearanceDuration()
  LogicSettlement:InitWorldList()
  LogicSettlement:GetOrInitCurHeroId()
  LogicSettlement:GetOrInitPuzzleInfoList()
  LogicSettlement:GetOrInitGemInfoList()
  SaveGrowthSnapData.SnapshotStaging = UE.URGStatisticsSubsystem.Get(GameInstance).SnapshotJsonStr
  print("LogicSettlement.InitSettlementData", SaveGrowthSnapData.SnapshotStaging, UE.URGStatisticsSubsystem.Get(GameInstance).SnapshotJsonStr)
end
function LogicSettlement:InitBattleLegacyData(BattleLegacyData)
  LogicSettlement.BattleLegacyData = {
    bIsGenericModify = BattleLegacyData.bIsGenericModify,
    BattleLagacyId = BattleLegacyData.InscriptionId,
    BattleLegacyArray = BattleLegacyData.BattleLegacyArray:ToTable()
  }
  print("LogicSettlement:InitBattleLegacyData1", BattleLegacyData.bIsGenericModify, BattleLegacyData.InscriptionId)
  print("LogicSettlement:InitBattleLegacyData2", LogicSettlement.BattleLegacyData.bIsGenericModify, LogicSettlement.BattleLegacyData.BattleLagacyId)
end
function LogicSettlement.ChangeLevel()
  print("LogicSettlement.ChangeLevel()")
  UE.UAsyncLoadingScreenLibrary.ClearLoadingScreenType()
  if not LogicAutoRobot or not LogicAutoRobot.GetIsAutoBot() then
    UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("BattleToLobby")
    UE.UGameplayStatics.OpenLevel(GameInstance, "Settlement")
  else
    LogicLobby.OpenLobbyLevel()
  end
end
function LogicSettlement.Init()
  if not LogicSettlement.bInited then
    ListenObjectMessage(nil, GMP.MSG_OnSettlement, GameInstance, LogicSettlement.ShowSettlement)
    LogicSettlement.bInited = true
  end
end
function LogicSettlement.IsShown()
  return RGUIMgr:IsShown(UIConfig.WBP_SettlementView_C.UIName)
end
function LogicSettlement:HideSettlement()
  if not RGUIMgr:IsShown(UIConfig.WBP_SettlementView_C.UIName) then
    return
  end
  UE.URGGameplayLibrary.TriggerOnClientEndSettlement(GameInstance)
  UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("BattleToLobby")
  LogicSettlement:CheckAndAutoSaveGrowth()
  LogicLobby.OpenLobbyLevel()
end
function LogicSettlement:CheckAndAutoSaveGrowth()
  if GetCurSceneStatus() ~= UE.ESceneStatus.ESettlement then
    print("LogicSettlement:CheckAndAutoSaveGrowth, not in settlement scene")
    return
  end
  if not SaveGrowthSnapData.bAutoSave then
    print("LogicSettlement:CheckAndAutoSaveGrowth, auto save is disabled")
    return
  end
  if not LogicSettlement:CheckCanSaveGrowth() then
    print("LogicSettlement:CheckAndAutoSaveGrowth, cannot show save growth button")
    return
  end
  local SavePos = LogicSettlement:GetAutoSavePos()
  local DefaultSaveNameFmt = UE.URGBlueprintLibrary.TextFromStringTable("1651")
  local DefaultSaveName = UE.FTextFormat(DefaultSaveNameFmt, SavePos + 1)
  SaveGrowthSnapHandler.RequestSaveGrowthSnapShot(SavePos, tostring(DefaultSaveName))
end
function LogicSettlement:GetHadSave()
  if GetCurSceneStatus() ~= UE.ESceneStatus.ESettlement then
    return true
  end
  local SettlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
  if SettlementView and IsValidObj(SettlementView) and SettlementView.WBP_SaveGrowthSnap.bHadSave then
    return SettlementView.WBP_SaveGrowthSnap.bHadSave
  end
  return false
end
function LogicSettlement:GetAutoSavePos()
  local EmptyPos = SaveGrowthSnapData:FindEmptyPos()
  if EmptyPos > 0 then
    return EmptyPos
  end
  local EarliestSavePos, _ = SaveGrowthSnapData:FindEarliestSave()
  if EarliestSavePos > 0 then
    return EarliestSavePos
  end
  print("LogicSettlement:GetAutoSavePos", EmptyPos, EarliestSavePos)
  return 0
end
function LogicSettlement:CheckCanSaveGrowth()
  if not LogicSettlement:CheckCanShowSaveGrowthBtn() then
    return false
  end
  if LogicSettlement:GetHadSave() then
    return false
  end
  return true
end
function LogicSettlement:CheckCanShowSaveGrowthBtn()
  if LogicSettlement:GetClearanceStatus() ~= SettlementStatus.Finish then
    return false
  end
  if LogicSettlement:GetGameModeType() ~= UE.EGameModeType.TowerClimb then
    return false
  end
  local SettlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
  if SettlementView and LogicSettlement:GetClearanceDifficulty() < SettlementView.ShowSaveGrowthDiffcult then
    return false
  end
  if SettlementView and SettlementView.bSaveGrowthSnapexpire then
    return false
  end
  return true
end
function LogicSettlement:GetItemStackAry(PlayerId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ItemStackSettleDataAry) do
    if PlayerId == v.UserId then
      return v.ItemStackArray
    end
  end
  return nil
end
function LogicSettlement:GetItemStacByConfigId(PlayerId, ConfigId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ItemStackSettleDataAry) do
    if PlayerId == v.UserId then
      for index, vStack in iterator(v.ItemStackArray.Stacks) do
        if UE.URGBlueprintLibrary.GetArticleIdConfigId(vStack.ArticleId) == ConfigId then
          return vStack.Stack
        end
      end
    end
  end
  return 0
end
function LogicSettlement:GetSettlementItemStackByConfigId(PlayerId, ConfigId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ItemStackSettleDataAry) do
    if PlayerId == v.UserId then
      for index, vItem in iterator(v.SettlementItemStackArray.Items) do
        if vItem.ItemId == ConfigId then
          local stackTotal = vItem.Stack
          local tbDetails = {}
          for idxPrivilegeDetail, vPrivilegeDetail in iterator(vItem.Details) do
            stackTotal = stackTotal - vPrivilegeDetail.Value
            table.insert(tbDetails, {
              PrivilegeSource = vPrivilegeDetail.Source,
              Value = vPrivilegeDetail.Value,
              ConfigId = ConfigId,
              IncreasePercent = vPrivilegeDetail.Percent
            })
          end
          return stackTotal, tbDetails
        end
      end
    end
  end
  return 0, {}
end
function LogicSettlement:GetPrivilegeDetailList(PlayerId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ItemStackSettleDataAry) do
    if PlayerId == v.UserId then
      local tbDetails = {}
      for index, vItem in iterator(v.SettlementItemStackArray.Items) do
        local resultItem, rowItem = GetRowData(DT.DT_Item, tostring(vItem.ItemId))
        if resultItem and rowItem.ArticleType ~= UE.EArticleDataType.Gem and rowItem.ArticleType ~= UE.EArticleDataType.Mod then
          for idxPrivilegeDetail, vPrivilegeDetail in iterator(vItem.Details) do
            table.insert(tbDetails, {
              PrivilegeSource = vPrivilegeDetail.Source,
              Value = vPrivilegeDetail.Value,
              ConfigId = vItem.ItemId,
              IncreasePercent = vPrivilegeDetail.Percent
            })
            print("GetPrivilegeDetailList   ", tostring(vPrivilegeDetail.Source))
          end
        end
      end
      return tbDetails
    end
  end
  return {}
end
function LogicSettlement:GetChipListByPlayerId(PlayerId)
  local chipList = {}
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ItemStackSettleDataAry) do
    if PlayerId == v.UserId then
      for index, vStack in iterator(v.ItemStackArray.Stacks) do
        local configId = UE.URGBlueprintLibrary.GetArticleIdConfigId(vStack.ArticleId)
        if ChipData:IsChip(configId) then
          local instId = UE.URGBlueprintLibrary.GetInstanceIdConfigId(vStack.ArticleId)
          local chipInfo = {InstId = instId, ConfigId = configId}
          table.insert(chipList, chipInfo)
        end
      end
    end
  end
  return chipList
end
function LogicSettlement:GetChipList()
  local chipList = {}
  for i = UE.ERGItemRarity.EIR_Normal, UE.ERGItemRarity.EIR_Max - 1 do
    local chipItemIdList = ChipData:GetChipItemIdListByRarity(i)
    for idxChip, vChip in ipairs(chipItemIdList) do
      table.insert(chipList, vChip)
    end
  end
  return chipList
end
function LogicSettlement:GetClearanceWorlds()
  return self.ClearanceWorlds
end
function LogicSettlement:GetClearanceStatus()
  return self.ClearanceStatus
end
function LogicSettlement.SetClearanceStatus(Status)
  LogicSettlement.ClearanceStatus = Status
  if SettlementStatus.Finish == Status then
    UE.UAudioManager.SetStateByName("Settlement", "Win", "\231\187\147\231\174\151")
  else
    UE.UAudioManager.SetStateByName("Settlement", "Lose", "\231\187\147\231\174\151")
  end
end
function LogicSettlement:GetClearanceDifficulty()
  local difficult = LogicTeam.GetFloor()
  print("LogicSettlement:GetClearanceDifficulty", difficult)
  return difficult or -1
end
function LogicSettlement:GetWorldList()
  return self.WroldList or {}
end
function LogicSettlement:GetLevel(IncrementValue)
  print("LogicSettlement:GetLevel chj", IncrementValue)
  local LevelTemp, _ = DataMgr.CalcUpLevel(IncrementValue)
  return LevelTemp
end
function LogicSettlement:GetExp()
  local playerId = LogicSettlement:GetOrInitSelfPlayerId()
  print(playerId)
  return UE.URGBlueprintLibrary.GetPlayerExp(playerId), UE.URGBlueprintLibrary.GetPlayerExp(playerId)
end
function LogicSettlement:GetCommonSpirit()
  local playerId = LogicSettlement:GetOrInitSelfPlayerId()
  return UE.URGBlueprintLibrary.GetPlayerSoul(playerId), UE.URGBlueprintLibrary.GetPlayerSoul(playerId)
end
function LogicSettlement:GetRoleSpirit()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return 0, 0
  end
  local playerId = LogicSettlement:GetOrInitSelfPlayerId()
  return UE.URGBlueprintLibrary.GetPlayerRoleSoul(playerId), UE.URGBlueprintLibrary.GetPlayerRoleSoul(playerId)
end
function LogicSettlement:GetClearanceDuration()
  return self.ClearanceDuration
end
function LogicSettlement:GetPlayerInfoById(PlayerId)
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return nil
  end
  for i, SinglePS in iterator(GS.PlayerArray) do
    if SinglePS.PlayerId == PlayerId then
      return SinglePS
    end
  end
  return nil
end
function LogicSettlement:GetPlayerInfoByPlayerId(PlayerId)
  local playerList = LogicSettlement:GetOrInitPlayerList()
  for i, v in ipairs(playerList) do
    if v.roleid == PlayerId then
      return v
    end
  end
  return nil
end
function LogicSettlement:InitClearanceDuration()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    self.ClearanceDuration = 0
    return
  end
  if self.ClearanceStatus == SettlementStatus.Exit then
    local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
    self.ClearanceDuration = GameLevelSystem:GetBattleElapsedTimeOnClient()
  else
    self.ClearanceDuration = UE.URGStatisticsSubsystem.Get(GameInstance).ClearDuration
  end
end
function LogicSettlement:InitWorldList()
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
  if GameLevelSystem then
    local WroldList = {}
    local bIsFirstUnPassWorld = true
    for i, v in iterator(GameLevelSystem:GetPassLevelsInfo()) do
      local passInfo = {
        PassInfo = v,
        bPass = v.bPass,
        bUnKnow = false
      }
      if v.bPass then
        if LogicSettlement.ClearanceStatus == SettlementStatus.Finish then
          passInfo.bPass = true
        end
        table.insert(WroldList, passInfo)
      else
        if LogicSettlement.ClearanceStatus == SettlementStatus.Finish then
          passInfo.bPass = true
        elseif bIsFirstUnPassWorld then
          bIsFirstUnPassWorld = false
        else
          passInfo.bUnKnow = true
        end
        table.insert(WroldList, passInfo)
      end
    end
    self.WroldList = WroldList
  end
end
function LogicSettlement:InitGenericList(ModifySettleDataAryParam)
  for i, v in iterator(ModifySettleDataAryParam) do
    local playerId = v.UserId
    if not self.PlayerToGenericListData then
      self.PlayerToGenericListData = {}
    end
    if not self.PlayerToGenericListData[playerId] then
      self.PlayerToGenericListData[playerId] = {
        SlotModifyAry = v.SlotModifyArray:ToTable(),
        PassiveModifyArray = v.PassiveModifyArray:ToTable(),
        ActivatedModifies = v.ActivatedModifies:ToTable()
      }
    end
  end
end
function LogicSettlement:GetPassiveModifyAryByPlayerId(PlayerId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ModifySettleDataAry) do
    if PlayerId == v.UserId then
      return v.PassiveModifyArray:ToTable()
    end
  end
  return {}
end
function LogicSettlement:GetActivatedModifiesByPlayerId(PlayerId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ModifySettleDataAry) do
    if PlayerId == v.UserId then
      return v.ActivatedModifies:ToTable()
    end
  end
  return {}
end
function LogicSettlement:GetGenericModifyBySlotByPlayerId(PlayerId, SlotParam)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).ModifySettleDataAry) do
    if PlayerId == v.UserId then
      for index, vSlot in iterator(v.SlotModifyArray) do
        if index == SlotParam then
          return vSlot
        end
      end
    end
  end
  return nil
end
function LogicSettlement:InitScrollList(AttributeModifySettleDataAryParam)
  for i, v in pairs(AttributeModifySettleDataAryParam) do
    if not self.PlayerToScrollListData then
      self.PlayerToScrollListData = {}
    end
    local playerId = v.UserId
    if not self.PlayerToScrollListData[playerId] then
      self.PlayerToScrollListData[playerId] = {
        ActivatedModifies = v.ActivatedModifies:ToTable(),
        ActivatedSets = v.ActivatedSets:ToTable()
      }
    end
  end
end
function LogicSettlement:InitScrollListByExit()
  if not self.PlayerToScrollListData then
    self.PlayerToScrollListData = {}
  end
  local character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local playerId = -1
  if character then
    playerId = character:GetUserId()
  end
  if playerId > 0 then
    local attributeModifyCom = character:GetComponentByClass(UE.URGAttributeModifyComponent.StaticClass())
    if not self.PlayerToScrollListData[playerId] then
      self.PlayerToScrollListData[playerId] = {
        ActivatedModifies = {},
        ActivatedSets = {}
      }
    end
    if attributeModifyCom then
      self.PlayerToScrollListData[playerId].ActivatedModifies = attributeModifyCom.ActivatedModifies:ToTable()
      self.PlayerToScrollListData[playerId].ActivatedSets = attributeModifyCom.ActivatedSets:ToTable()
    end
  end
end
function LogicSettlement:InitGeneircListByExit()
  if not self.PlayerToGenericListData then
    self.PlayerToGenericListData = {}
  end
  local character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local playerId = -1
  if character then
    playerId = character:GetUserId()
  end
  if playerId > 0 then
    local genericCom = character:GetComponentByClass(UE.URGGenericModifyComponent.StaticClass())
    local specialCom = character:GetComponentByClass(UE.URGSpecificModifyComponent.StaticClass())
    local modify = UE.FModifySettleData()
    modify.UserId = playerId
    if genericCom then
      modify.SlotModifyArray = genericCom.SlotModifyArray
      modify.PassiveModifyArray = genericCom.PassiveModifyArray
    end
    if specialCom then
      modify.ActivatedModifies = specialCom.ActivatedModifies
    end
    UE.URGStatisticsSubsystem.Get(GameInstance).ModifySettleDataAry:Add(modify)
  end
end
function LogicSettlement:InitItemListByExit()
  if not self.PlayerToItemListData then
    self.PlayerToItemListData = {}
  end
  local character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local playerId = -1
  if character then
    playerId = character:GetUserId()
  end
  if playerId > 0 then
    local ItemData = UE.FItemStackArySettleData()
    ItemData.UserId = playerId
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
    if bagComponent then
      ItemData.ItemStackArray = bagComponent.StackList
    end
    UE.URGStatisticsSubsystem.Get(GameInstance).ItemStackSettleDataAry:Add(ItemData)
  end
end
function LogicSettlement:InitItemList(ItemSettleDataAryParam)
  for i, v in iterator(ItemSettleDataAryParam) do
    if not self.PlayerToItemListData then
      self.PlayerToItemListData = {}
    end
    local playerId = v.UserId
    if not self.PlayerToItemListData[playerId] then
      self.PlayerToItemListData[playerId] = v.ItemStackArray
    end
  end
end
function LogicSettlement:GetScrollListByPlayerId(PlayerId)
  print("LogicSettlement:GetScrollListByPlayerId", PlayerId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).AttributeModifySettleDataAry) do
    print("LogicSettlement:GetScrollListByPlayerId111", PlayerId, v.UserId)
    if PlayerId == v.UserId then
      return v.ActivatedModifies:ToTable()
    end
  end
  if LogicSettlement.PlayerToScrollListData and LogicSettlement.PlayerToScrollListData[PlayerId] then
    return LogicSettlement.PlayerToScrollListData[PlayerId].ActivatedModifies or {}
  end
  return {}
end
function LogicSettlement:GetScrollSetListByPlayerId(PlayerId)
  for i, v in iterator(UE.URGStatisticsSubsystem.Get(GameInstance).AttributeModifySettleDataAry) do
    if PlayerId == v.UserId then
      return v.ActivatedSets:ToTable()
    end
  end
  if LogicSettlement.PlayerToScrollListData and LogicSettlement.PlayerToScrollListData[PlayerId] then
    return LogicSettlement.PlayerToScrollListData[PlayerId].ActivatedSets or {}
  end
  return {}
end
function LogicSettlement:InitGameMode()
  LogicSettlement.GameMode = UE.URGGameLevelSystem.GetInstance(GameInstance).WorldConfigs.WorldModeID
end
function LogicSettlement:GetGameMode()
  return LogicSettlement.GameMode or 0
end
function LogicSettlement:GetGameModeType()
  local gameMode = LogicSettlement:GetGameMode()
  local result, row = GetRowData(DT.DT_GameMode, tostring(gameMode))
  if result then
    return row.ModeType
  end
  return UE.EGameModeType.Test
end
function LogicSettlement:GetOrInitPlayerList()
  if self.PlayerList then
    return self.PlayerList
  end
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return {}
  end
  local validPlayers = UE.TArray(UE.int64)
  TeamSubsystem:GetValidPlayers(validPlayers)
  self.PlayerList = {}
  print("cccccccccccxxxxxxxxxx3333", validPlayers:Num())
  for i, v in iterator(validPlayers) do
    if LogicSettlement.ClearanceStatus == SettlementStatus.Exit then
      if TeamSubsystem:GetPlayerInfo(v).roleid == LogicSettlement:GetOrInitSelfPlayerId() then
        table.insert(self.PlayerList, TeamSubsystem:GetPlayerInfo(v))
        print("cccccccccccxxxxxxxxxx22222", v, TeamSubsystem:GetPlayerInfo(v).roleid, TeamSubsystem:GetPlayerInfo(v).name, TeamSubsystem:GetPlayerInfo(v).hero.id)
      end
    else
      table.insert(self.PlayerList, TeamSubsystem:GetPlayerInfo(v))
      print("LogicSettlement:GetOrInitPlayerList", v, TeamSubsystem:GetPlayerInfo(v).roleid, TeamSubsystem:GetPlayerInfo(v).name)
    end
  end
  table.sort(self.PlayerList, self.PlayerListSort)
  return self.PlayerList
end
function LogicSettlement:GetOrInitSelfPlayerId()
  if LogicSettlement.SelfPlayerId > 0 then
    return LogicSettlement.SelfPlayerId
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if UE.RGUtil.IsUObjectValid(Character) then
    LogicSettlement.SelfPlayerId = Character:GetUserId()
    print("LogicSettlement:GetOrInitSelfPlayerId", LogicSettlement.SelfPlayerId)
    return LogicSettlement.SelfPlayerId
  end
  return -1
end
function LogicSettlement:GetOrInitCurHeroId()
  if LogicSettlement.SelfHeroId and LogicSettlement.SelfHeroId > 0 then
    return LogicSettlement.SelfHeroId
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if UE.RGUtil.IsUObjectValid(Character) then
    LogicSettlement.SelfHeroId = Character:GetTypeID()
    return LogicSettlement.SelfHeroId
  end
  return -1
end
function LogicSettlement:GetOrInitPuzzleInfoList()
  if LogicSettlement.PuzzleInfoList then
    return LogicSettlement.PuzzleInfoList
  end
  LogicSettlement.PuzzleInfoList = {}
  local puzzleComp = UE.URGMatrixModManager.GetInstance(GameInstance)
  local modInfoAry = puzzleComp:GetUserModInfo(LogicSettlement:GetOrInitSelfPlayerId())
  print("LogicSettlement:GetOrInitPuzzleInfoList2222", modInfoAry:Num())
  for k, v in pairs(modInfoAry) do
    local resId = v.ItemId
    local instId = v.InstantId
    local subAttr = {}
    print("LogicSettlement:GetOrInitPuzzleInfoList", resId, instId)
    for iSubAttr, vSubAttr in pairs(v.SubAttrV2) do
      table.insert(subAttr, {
        attrID = vSubAttr.attrid,
        value = vSubAttr.value,
        godAttr = vSubAttr.godattr,
        mutationType = vSubAttr.mutationType
      })
      print("LogicSettlement:GetOrInitPuzzleInfoList1111", iSubAttr, vSubAttr, vSubAttr.attrid, vSubAttr.value, vSubAttr.godattr, vSubAttr.mutationType)
    end
    local puzzleInfo = {
      ConfigId = resId,
      InstId = instId,
      SubAttrList = subAttr,
      BindHeroID = v.BindHeroID,
      Inscription = v.Inscription,
      DropReason = v.DropReason,
      DropType = v.droptype
    }
    table.insert(LogicSettlement.PuzzleInfoList, puzzleInfo)
  end
  return LogicSettlement.PuzzleInfoList
end
function LogicSettlement:GetOrInitGemInfoList()
  if LogicSettlement.GemInfoList then
    return LogicSettlement.GemInfoList
  end
  LogicSettlement.GemInfoList = {}
  local puzzleComp = UE.URGMatrixModManager.GetInstance(GameInstance)
  local modInfoAry = puzzleComp:GetUserGemInfo(LogicSettlement:GetOrInitSelfPlayerId())
  for k, v in pairs(modInfoAry) do
    local resId = v.ItemId
    local instId = v.InstantId
    local mainAttrIDs = {}
    print("LogicSettlement:GetOrInitGemInfoList", resId, instId)
    for iSubAttr, vSubAttr in pairs(v.mainAttrIDs) do
      table.insert(mainAttrIDs, vSubAttr)
      print("LogicSettlement:GetOrInitGemInfoList1111", iSubAttr, vSubAttr)
    end
    local mutationAttr = {}
    for iMutationAttr, vMutationAttr in pairs(v.mutationAttr) do
      table.insert(mutationAttr, {
        AttrID = vMutationAttr.AttrID,
        MutationType = vMutationAttr.MutationType,
        MutationValue = vMutationAttr.MutationValue
      })
      print("LogicSettlement:GetOrInitGemInfoList2222", iMutationAttr, vMutationAttr, vMutationAttr.AttrID, vMutationAttr.MutationType, vMutationAttr.MutationValue)
    end
    local gemInfo = {
      resourceID = resId,
      uniqueID = instId,
      mutation = v.mutation,
      level = 0,
      mutationAttr = mutationAttr,
      mainAttrIDs = mainAttrIDs,
      state = 0,
      pzUniqueID = "0",
      DropReason = v.DropReason,
      DropType = v.droptype
    }
    table.insert(LogicSettlement.GemInfoList, gemInfo)
  end
  return LogicSettlement.GemInfoList
end
function LogicSettlement.PlayerListSortByPlayerId(FistPlayer, SecondPlayer)
  return FistPlayer.PlayerId < SecondPlayer.PlayerId
end
function LogicSettlement.PlayerListSort(FistPlayer, SecondPlayer)
  return FistPlayer.roleid < SecondPlayer.roleid
end
function LogicSettlement:CheckIsTeamClearance()
  if self.ClearanceStatus == SettlementStatus.Exit then
    return false
  else
    return #self:GetOrInitPlayerList() > 1
  end
end
function LogicSettlement:GetPlayerNum()
  if self.PlayerInfoList then
    return #self.PlayerInfoList
  end
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if not GS then
    return 0
  end
  return GS.PlayerArray:Num()
end
function LogicSettlement:CalcTitle()
  if self.PlayerTitleMap then
    return self.PlayerTitleMap
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local dataTable = DTSubsystem:GetDataTable("Settlement")
  if not dataTable then
    return {}
  end
  self.PlayerTitleMap = {}
  local RownTb = self.GetSettleTitleTableRow(2)
  if RownTb then
    local PlayerList = self:GetOrInitPlayerList()
    local PlayersInfo = {}
    for iPlayer, vPlayer in ipairs(PlayerList) do
      local Value = UE.URGBlueprintLibrary.GetStatisticDataInt64(vPlayer.roleid, RownTb.StatisticsId)
      print("LogicSettlement:CalcTitle chj", RownTb.StatisticsId, vPlayer.roleid, Value)
      if Value > 0 then
        local data = {}
        data.Score = Value
        data.PlayerId = vPlayer.roleid
        data.TitleDesc = RownTb.TitleDesc
        table.insert(PlayersInfo, data)
      end
    end
    table.sort(PlayersInfo, self.SortScore)
    for i, vInfo in ipairs(PlayersInfo) do
      if SettlementDamageTitle[i] then
        vInfo.TitleName = SettlementDamageTitle[i]()
      else
        vInfo.TitleName = ""
      end
      self.PlayerTitleMap[vInfo.PlayerId] = vInfo
    end
  end
  return self.PlayerTitleMap
end
function LogicSettlement:GetPlayerList()
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if not GS then
    return {}
  end
  local PlayerList = GS.PlayerArray:ToTable()
  table.sort(PlayerList, self.PlayerListSortByPlayerId)
  return PlayerList
end
function LogicSettlement:CalMvp(bIsFromPc)
  if self.MvpPlayer then
    return self.MvpPlayer
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return {}
  end
  local validPlayers = UE.TArray(UE.int64)
  TeamSubsystem:GetValidPlayers(validPlayers)
  local validPlayersTb = validPlayers:ToTable()
  local dataTable = DTSubsystem:GetDataTable("Settlement")
  if not dataTable then
    return {}
  end
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
  local RowNameTb = RowNames:ToTable()
  local PlayerScoreMap = {}
  for i, v in ipairs(RowNameTb) do
    local RownTb = self.GetSettleTitleTableRow(v)
    local PlayerList = {}
    if bIsFromPc then
      PlayerList = self:GetPlayerList()
    else
      PlayerList = self:GetOrInitPlayerList()
    end
    local RemovePlayerList = {}
    for iPlayer, vPlayer in ipairs(PlayerList) do
      local localUserId = 0
      if bIsFromPc then
        localUserId = vPlayer:GetUserId()
      else
        localUserId = vPlayer.roleid
      end
      if localUserId > 0 and not table.Contain(validPlayersTb, localUserId) then
        table.add(RemovePlayerList, iPlayer)
      end
    end
    for iPlayer, _ in pairs(RemovePlayerList) do
      table.remove(PlayerList, iPlayer)
    end
    print("LogicSettlement:CalMvp \231\142\169\229\174\182\230\149\176\233\135\143,", #PlayerList)
    if #PlayerList <= 1 then
      self.MvpPlayer = {}
      print("LogicSettlement:CalMvp \231\142\169\229\174\182\230\149\176\233\135\143<= 1")
      return self.MvpPlayer
    end
    local PlayersInfo = {}
    for iPlayer, vPlayer in ipairs(PlayerList) do
      local playerId = -1
      if bIsFromPc then
        playerId = vPlayer:GetUserId()
      else
        playerId = vPlayer.roleid
      end
      local Value = UE.URGBlueprintLibrary.GetStatisticDataInt64(playerId, RownTb.StatisticsId)
      print("LogicSettlement:CalMvp11", vPlayer.roleid, Value, RownTb.StatisticsId)
      PlayersInfo[iPlayer] = {}
      PlayersInfo[iPlayer].Score = Value
      if bIsFromPc then
        PlayersInfo[iPlayer].PlayerId = vPlayer:GetUserId()
      else
        PlayersInfo[iPlayer].PlayerId = vPlayer.roleid
      end
    end
    table.sort(PlayersInfo, self.SortPlayerInfo)
    for iInfo, vInfo in ipairs(PlayersInfo) do
      vInfo.Rank = iInfo
    end
    for iInfo, vInfo in ipairs(PlayersInfo) do
      if not PlayerScoreMap[vInfo.PlayerId] then
        PlayerScoreMap[vInfo.PlayerId] = 0
      end
      local Ratio = RankScoreRatio[vInfo.Rank] or 0
      print("LogicSettlement:CalMvp", vInfo.PlayerId, PlayerScoreMap[vInfo.PlayerId], Ratio, RownTb.RankWeight)
      PlayerScoreMap[vInfo.PlayerId] = PlayerScoreMap[vInfo.PlayerId] + Ratio * RownTb.RankWeight
    end
  end
  self.MvpPlayer = {PlayerId = 0, Score = 0}
  for k, v in pairs(PlayerScoreMap) do
    if v > self.MvpPlayer.Score or self.MvpPlayer.Score == v and k > self.MvpPlayer.PlayerId then
      self.MvpPlayer.PlayerId = k
      self.MvpPlayer.Score = v
    end
  end
  return self.MvpPlayer
end
function LogicSettlement:GetBattleInfoList(PlayerId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local dataTable = DTSubsystem:GetDataTable("Settlement")
  if not dataTable then
    return {}
  end
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
  local RowNameTb = RowNames:ToTable()
  local battleInfoList = {}
  for i, v in ipairs(RowNameTb) do
    local RownTb = self.GetSettleTitleTableRow(v)
    local Value = UE.URGBlueprintLibrary.GetStatisticDataInt64(PlayerId, RownTb.StatisticsId)
    local battleInfoData = {
      Name = RownTb.TitleDesc,
      Value = Value
    }
    table.insert(battleInfoList, battleInfoData)
  end
  return battleInfoList
end
function LogicSettlement.GetGameStatisticsItemValue(GameStatisticsItem)
  local Value
  if GameStatisticsItem.ParamType == UE.ERGParamType.Int then
    Value = UE.URGStatisticsLibrary.RGGetSummaryInt(GameStatisticsItem)
  elseif GameStatisticsItem.ParamType == UE.ERGParamType.Int64 then
    Value = UE.URGStatisticsLibrary.RGGetSummaryInt64(GameStatisticsItem)
  elseif GameStatisticsItem.ParamType == UE.ERGParamType.Float then
    Value = UE.URGStatisticsLibrary.RGGetSummaryFloat(GameStatisticsItem)
  elseif GameStatisticsItem.ParamType == UE.ERGParamType.String then
    Value = UE.URGStatisticsLibrary.RGGetSummaryValue(GameStatisticsItem)
  end
  return Value
end
function LogicSettlement.SortPlayerInfo(FirstInfo, SecondInfo)
  return FirstInfo.Score > SecondInfo.Score
end
function LogicSettlement.SortRow(FirstName, SecondName)
  local FirstRow = LogicSettlement.GetSettleTitleTableRow(FirstName)
  local SecondRow = LogicSettlement.GetSettleTitleTableRow(SecondName)
  return FirstRow.Queue < SecondRow.Queue
end
function LogicSettlement.GetSettleTitleTableRow(IdParam)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicSettlement.GetSettleTitleTableRow not DTSubsystem")
    return nil
  end
  local Result, DTScoreBoardRow = DTSubsystem:GetSettlementScoreBoardById(tonumber(IdParam), nil)
  if Result then
    return DTScoreBoardRow
  end
  print("\233\133\141\231\189\174\229\188\130\229\184\184\239\188\140\232\175\165\231\173\137\231\186\167\229\156\168\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168", IdParam)
  return nil
end
function LogicSettlement.GetHeroArtResTableRow(IdParam)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicSettlement.GetHeroArtResTableRow not DTSubsystem")
    return nil
  end
  local Result, DTHeroArtRow = DTSubsystem:GetHeroArtResDataById(tonumber(IdParam), nil)
  if Result then
    return DTHeroArtRow
  end
  print("\233\133\141\231\189\174\229\188\130\229\184\184\239\188\140\232\175\165\231\173\137\231\186\167\229\156\168\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168", IdParam)
  return nil
end
function LogicSettlement.SortScore(FirstInfo, SecondInfo)
  if FirstInfo.Score > SecondInfo.Score then
    return true
  end
  if FirstInfo.Score == SecondInfo.Score then
    return FirstInfo.PlayerId > SecondInfo.PlayerId
  end
  return false
end
function LogicSettlement.GetPresetWeaponData(TableId)
  local ToralResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not ToralResourceTable then
    return
  end
  return ToralResourceTable[TableId]
end
function LogicSettlement.GetLeftRole()
  if UE.RGUtil.IsUObjectValid(LogicSettlement.LeftRole) then
    return LogicSettlement.LeftRole
  end
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "LeftRole", nil)
  for i, v in iterator(AllActors) do
    LogicSettlement.LeftRole = v
  end
  return LogicSettlement.LeftRole
end
function LogicSettlement.GetMiddleRole()
  if UE.RGUtil.IsUObjectValid(LogicSettlement.MiddleRole) then
    return LogicSettlement.MiddleRole
  end
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "MiddleRole", nil)
  for i, v in iterator(AllActors) do
    LogicSettlement.MiddleRole = v
  end
  return LogicSettlement.MiddleRole
end
function LogicSettlement.GetRightRole()
  if UE.RGUtil.IsUObjectValid(LogicSettlement.RightRole) then
    return LogicSettlement.RightRole
  end
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RightRole", nil)
  for i, v in iterator(AllActors) do
    LogicSettlement.RightRole = v
  end
  return LogicSettlement.RightRole
end
function LogicSettlement.GetSettleCamera()
  if UE.RGUtil.IsUObjectValid(LogicSettlement.TargetCamera) then
    return LogicSettlement.TargetCamera
  end
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "MainCamera", nil)
  for i, SingleActor in iterator(AllActors) do
    LogicSettlement.TargetCamera = SingleActor
    break
  end
  return LogicSettlement.TargetCamera
end
function LogicSettlement.ResetBattleLagacy()
  BattleLagacyModule:Reset()
end
function LogicSettlement.GetCurrBattleLagacy()
  BattleLagacyModule:GetCurrBattleLagacy()
end
function LogicSettlement.GetBattleLagacyList()
  BattleLagacyModule:GetBattleLagacyList()
end
function LogicSettlement.UpdateBattleLagacyList(BattleLagacyList)
  BattleLagacyModule:UpdateBattleLagacyList(BattleLagacyList)
end
function LogicSettlement.UpdateCurBattleLagacyData(BattleLagacyID, BattleLagacyType)
  if nil ~= BattleLagacyID and tonumber(BattleLagacyID) > 0 then
    BattleLagacyModule:UpdateCurBattleLagacyData(BattleLagacyID, BattleLagacyType)
  end
end
function LogicSettlement.CheckIsInscreaseReward()
  local worldMode = LogicTeam.GetWorldId()
  local result, row = GetRowData(DT.DT_GameMode, tostring(worldMode))
  if result and row.bIsBeginnerMode then
    return false
  end
  if not DataMgr.RewardIncreaseCount then
    return false
  end
  return DataMgr.RewardIncreaseCount > 0
end
function LogicSettlement.CheckHaveBattleLagacy()
  if not LogicSettlement.BattleLegacyData then
    return false
  end
  if not LogicSettlement.BattleLegacyData.bIsGenericModify and not tonumber(LogicSettlement.BattleLegacyData.BattleLagacyId) then
    return false
  end
  return true
end
