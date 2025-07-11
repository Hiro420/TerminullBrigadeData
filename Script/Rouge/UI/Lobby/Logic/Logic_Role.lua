local rapidjson = require("rapidjson")
local BattleRoleInfoActorPath = "/Game/Rouge/UI/Lobby/Role/BP_BattleRoleInfoActor.BP_BattleRoleInfoActor_C"
local GA_SkillE_AutoRecoveryDefaultPath = "/Game/Rouge/Gameplay/GAS/Hero/Common/GA_SkillE_AutoRecoveryDefault.GA_SkillE_AutoRecoveryDefault_C"
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local RoleCaptureRolePos = {
  {
    X = -13056,
    Y = 1242.474365,
    Z = 28619.058594
  },
  {
    X = -13056,
    Y = 1242.474365,
    Z = 28619.058594
  }
}
local DefaultSkinLightLevelPath = "/Game/Rouge/Map/Lobby/HeroLightMap.HeroLightMap"
local MAX_LEVEL_BG_NUM = 10
LogicRole = LogicRole or {
  IsInit = false,
  DefaultHeroBgLevelName = "/Game/Rouge/Map/Lobby/Hero.Hero",
  LevelBgMapData = {
    LevelBgMap = {},
    LevelBgAry = {}
  }
}
LogicRole.BGMesh = {
  RoleMain = "/Game/Rouge/UI/Texture/Bg/Textures/Role_Bg_js_01.Role_Bg_js_01",
  HeroTalent = "/Game/Rouge/UI/Texture/Bg/Textures/RolePower_bg_01.RolePower_bg_01"
}
function LogicRole.Init(IsBattle)
  if LogicRole.IsInit then
    LogicRole.InitAllRoleLightActor()
    return
  end
  LogicRole.IsRoleMainShow = false
  LogicRole.IsHeroTalentShow = false
  LogicRole.MainFetterHero = nil
  LogicRole.FetterList = {}
  LogicRole.IsNewDataTable = false
  LogicRole.HeroStarTable = {}
  LogicRole.HeroSkillTable = {}
  LogicRole.AllLightActors = {}
  LogicRole.IsInit = true
  LogicRole.CurSelectHeroId = -1
  LogicRole.CurHeroSkinLightMapName = ""
  LogicRole.HeroSkinLightMapList = {}
  if not IsBattle then
    LogicRole.InitFetterHero()
  end
  LogicRole.InitAllRoleLightActor()
  LogicRole.DealWithDataTable()
end
function LogicRole.InitAllRoleLightActor()
  local LightActorClass = UE.UClass.Load("/Game/Rouge/Gameplay/Actor/RoleMain/BP_RoleLight.BP_RoleLight_C")
  local AllLightActors = UE.UGameplayStatics.GetAllActorsOfClass(GameInstance, LightActorClass)
  for key, SingleLightActor in pairs(AllLightActors) do
    LogicRole.AllLightActors[SingleLightActor.HeroTagName] = SingleLightActor
  end
end
function LogicRole.InitFetterHero()
  local MainFetterHeroList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "MainFetterHero", nil)
  for i, SingleMainFetterHero in iterator(MainFetterHeroList) do
    LogicRole.MainFetterHero = SingleMainFetterHero
    break
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local AllFetterSlotIds = DTSubsystem:GetAllFetterSlotIds(nil)
  for i, SingleSlotId in iterator(AllFetterSlotIds) do
    local FetterHeroList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "FetterHero" .. tostring(SingleSlotId), nil)
    if FetterHeroList:IsValidIndex(1) then
      LogicRole.FetterList[SingleSlotId] = FetterHeroList:Get(1)
    else
      print("[LogicRole.InitFetterHero]: not found fetter hero" .. "FetterHero" .. tostring(SingleSlotId) .. ", please check the lobby map")
    end
  end
end
function LogicRole.GetHeroSkillInfo(SkillId)
  local HeroSkillTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroSkill)
  if not HeroSkillTable then
    return nil
  end
  for i, v in ipairs(HeroSkillTable) do
    if v.ID == SkillId then
      return v
    end
  end
  return nil
end
function LogicRole.DealWithDataTable()
  local HeroStarTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroStar)
  local HeroSkillTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroSkill)
  for i, SingleHeroStarInfo in ipairs(HeroStarTable) do
    local GroupList = LogicRole.HeroStarTable[SingleHeroStarInfo.ID]
    if GroupList then
      GroupList[SingleHeroStarInfo.Level] = SingleHeroStarInfo
    else
      local TempList = {}
      TempList[SingleHeroStarInfo.Level] = SingleHeroStarInfo
      LogicRole.HeroStarTable[SingleHeroStarInfo.ID] = TempList
    end
  end
  for i, SingleHeroSkillInfo in ipairs(HeroSkillTable) do
    local GroupList = LogicRole.HeroSkillTable[SingleHeroSkillInfo.Group]
    if GroupList then
      GroupList[SingleHeroSkillInfo.Star] = SingleHeroSkillInfo
    else
      local TempList = {}
      TempList[SingleHeroSkillInfo.Star] = SingleHeroSkillInfo
      LogicRole.HeroSkillTable[SingleHeroSkillInfo.Group] = TempList
    end
  end
end
function LogicRole.InitMainFetterHeroMesh(HeroId)
  if LogicRole.MainFetterHero then
    LogicRole.MainFetterHero:ChangeBodyMesh(HeroId)
  end
end
function LogicRole.InitFetterHeroesMesh(HeroId)
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(HeroId)
  for SlotId, SingleHero in pairs(LogicRole.FetterList) do
    SingleHero:SetActorHiddenInGame(true)
  end
  for i, SingleFetterHeroInfo in ipairs(FetterHeroInfo) do
    local FetterHero = LogicRole.FetterList[SingleFetterHeroInfo.slot]
    if FetterHero then
      if 0 == SingleFetterHeroInfo.id then
        FetterHero:SetActorHiddenInGame(true)
      else
        FetterHero:ChangeBodyMesh(SingleFetterHeroInfo.id)
        FetterHero:SetActorHiddenInGame(false)
      end
    end
  end
end
function LogicRole.GetCurHeroId()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if UE.RGUtil.IsUObjectValid(Character) then
    return Character:GetTypeID()
  end
  return LogicSettlement:GetOrInitCurHeroId()
end
function LogicRole.HideAllHeroLight()
  local AllLightActors = LogicRole.AllLightActors
  if not AllLightActors or next(AllLightActors) == nil then
    local LightActorClass = UE.UClass.Load("/Game/Rouge/Gameplay/Actor/RoleMain/BP_RoleLight.BP_RoleLight_C")
    AllLightActors = UE.UGameplayStatics.GetAllActorsOfClass(GameInstance, LightActorClass)
  end
  for key, SingleLightActor in pairs(AllLightActors) do
    local AllChildActors = SingleLightActor:GetAttachedActors(nil, true)
    SingleLightActor:SetActorHiddenInGame(true)
    for key, SingleChildActor in pairs(AllChildActors) do
      SingleChildActor:SetActorHiddenInGame(true)
    end
  end
end
function LogicRole.EditorChangeHeroLight(LightName)
  local AllLightActors = LogicRole.AllLightActors
  if not AllLightActors then
    local LightActorClass = UE.UClass.Load("/Game/Rouge/Gameplay/Actor/RoleMain/BP_RoleLight.BP_RoleLight_C")
    AllLightActors = UE.UGameplayStatics.GetAllActorsOfClass(GameInstance, LightActorClass)
  end
  for key, SingleLightActor in pairs(AllLightActors) do
    local AllChildActors = SingleLightActor:GetAttachedActors(nil, true)
    if not UE.UKismetStringLibrary.IsEmpty(LightName) and SingleLightActor.HeroTagName == LightName then
      SingleLightActor:SetActorHiddenInGame(false)
      for key, SingleChildActor in pairs(AllChildActors) do
        SingleChildActor:SetActorHiddenInGame(false)
      end
    else
      SingleLightActor:SetActorHiddenInGame(true)
      for key, SingleChildActor in pairs(AllChildActors) do
        SingleChildActor:SetActorHiddenInGame(true)
      end
    end
  end
end
function LogicRole.ShowOrHideRoleMainHero(IsShow)
  if not LogicRole.RoleMainActor or not LogicRole.RoleMainActor:IsValid() then
    local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleMainHero", nil)
    for i, SingleRoleActor in pairs(RoleActorList) do
      LogicRole.RoleMainActor = SingleRoleActor
      break
    end
  end
  if not LogicRole.RoleMainActor then
    return
  end
  if IsShow then
    LogicRole.RoleMainActor:SetHiddenInGame(false)
  else
    LogicRole.RoleMainActor:SetHiddenInGame(true)
  end
end
function LogicRole.ChangeRoleMainTransform(RowName)
  local result, row = GetRowData(DT.DT_RoleMainTransform, RowName)
  if result then
    local roleActor = LogicRole.GetRoleMainActor()
    if roleActor and roleActor:IsValid() then
      roleActor:K2_SetActorTransform(row.RoleMainTransform, false, nil, false)
    end
  else
    local resultDefault, rowDefault = GetRowData(DT.DT_RoleMainTransform, "Default")
    if resultDefault then
      local roleActor = LogicRole.GetRoleMainActor()
      if roleActor and roleActor:IsValid() then
        roleActor:K2_SetActorTransform(rowDefault.RoleMainTransform, false, nil, false)
      end
    end
  end
end
function LogicRole.ChangeRoleSkyLight(IsRole)
  local RoleSkyLightList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleSkyLight", nil)
  local LobbySkyLightList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "LobbySkyLight", nil)
  for i, SingleRoleSkyLight in pairs(RoleSkyLightList) do
    SingleRoleSkyLight:SetActorHiddenInGame(not IsRole)
  end
  for i, SingleLobbySkyLight in pairs(LobbySkyLightList) do
    SingleLobbySkyLight:SetActorHiddenInGame(IsRole)
  end
end
function LogicRole.ChangeBGMesh(BGName)
  local RoleBGList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleBG", nil)
  local RoleBG
  for i, SingleRoleBG in pairs(RoleBGList) do
    RoleBG = SingleRoleBG
    break
  end
  local SoftObjRef = MakeStringToSoftObjectReference("/Game/Rouge/Map/Lobby/M_RoleBackGround.M_RoleBackGround")
  local SourceMaterial = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef)
  local MaterialInstance = RoleBG.StaticMeshComponent:CreateDynamicMaterialInstance(0, SourceMaterial, "None")
  if LogicRole.BGMesh[BGName] then
    local TargetObjRef = MakeStringToSoftObjectReference(LogicRole.BGMesh[BGName])
    local TargetTexture = UE.UKismetSystemLibrary.LoadAsset_Blocking(TargetObjRef)
    MaterialInstance:SetTextureParameterValue("Color", TargetTexture)
  end
end
function LogicRole.GetHeroStarInfo(HeroId)
  return LogicRole.HeroStarTable[HeroId]
end
function LogicRole.GetMaxHeroStar(HeroId)
  local HeroStarInfo = LogicRole.GetHeroStarInfo(HeroId)
  local MaxStar = 1
  if HeroStarInfo then
    for Star, value in pairs(HeroStarInfo) do
      if Star > MaxStar then
        MaxStar = Star
      end
    end
  end
  return MaxStar
end
function LogicRole.GetCharacterTableRow(HeroId)
  local RowInfo
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  RowInfo = CharacterTable[HeroId]
  return RowInfo
end
function LogicRole.CheckIsHeroMonster(ResourceId)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if ResourceTable and ResourceTable[ResourceId] then
    return ResourceTable[ResourceId].Type == TableEnums.ENUMResourceType.HERO
  end
  return false
end
function LogicRole.GetFetterSkillGroupIdByHeroId(HeroId)
  local HeroRowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if not HeroRowInfo then
    return 0
  end
  for index, SingleSkillGroupId in ipairs(HeroRowInfo.SkillList) do
    local SkillGroupInfo = LogicRole.GetSkillTableRow(SingleSkillGroupId)
    if SkillGroupInfo and SkillGroupInfo[1] and SkillGroupInfo[1].Type == TableEnums.ENUMSkillType.Fetter then
      return SingleSkillGroupId
    end
  end
  return 0
end
function LogicRole.GetAllCanSelectCharacterList()
  local List = {}
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  for CharacterId, SingleCharacterInfo in pairs(CharacterTable) do
    if SingleCharacterInfo.CanChoose and SingleCharacterInfo.Type == TableEnums.ENUMHeroType.Hero then
      table.insert(List, CharacterId)
    end
  end
  return List
end
function LogicRole.CheckCharacterUnlock(CharacterId)
  return DataMgr.IsOwnHero(CharacterId)
end
function LogicRole.GetSkillTableRow(SkillGroupId)
  local RowInfo = LogicRole.HeroSkillTable[SkillGroupId]
  return RowInfo
end
function LogicRole.GetAllFetterSlotIds()
  local List = {}
  local FetterSlotTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFetterSlot)
  for SlotId, value in pairs(FetterSlotTable) do
    table.insert(List, SlotId)
  end
  return List
end
function LogicRole.GetFetterSlotInfoById(SlotId)
  local FetterSlotTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFetterSlot)
  return FetterSlotTable[SlotId]
end
function LogicRole.IsSlotUnlock(SlotId)
  local HeroInfo = DataMgr.GetMyHeroInfo()
  local SlotStatus = HeroInfo.slots[SlotId]
  return SlotStatus and SlotStatus == TableEnums.ENUMSlotStatus.Open or false
end
function LogicRole.GetCurSlotHeroId(MainHeroId, SlotId)
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(MainHeroId)
  local SlotHeroId = 0
  if FetterHeroInfo then
    for i, SingleFetterHeroInfo in ipairs(FetterHeroInfo) do
      if SingleFetterHeroInfo.slot == SlotId then
        SlotHeroId = SingleFetterHeroInfo.id
      end
    end
  end
  return SlotHeroId
end
function LogicRole.RequestMyHeroInfoToServer(Callback)
  local HeroPath = "hero/getmyheroinfo?type=0"
  HttpCommunication.RequestByGet(HeroPath, {
    GameInstance,
    function(Target, JsonResponse)
      print(JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetMyHeroInfo(JsonTable)
      if Callback then
        Callback(JsonTable)
      end
      PuzzleData:ClearEquipPuzzleIdList()
      for i, SingleHeroInfo in ipairs(JsonTable.heros) do
        if DataMgr.IsOwnHero(SingleHeroInfo.id) and SingleHeroInfo.puzzleSlotsInfo then
          for i, SingleSlotInfo in ipairs(SingleHeroInfo.puzzleSlotsInfo) do
            local PuzzleId = SingleSlotInfo.uniqueID
            PuzzleData:SetSlotEquipId(PuzzleId, SingleSlotInfo.slotIDs)
            PuzzleData:AddEquipPuzzleId(SingleHeroInfo.id, PuzzleId)
            for i, SingleSlotId in ipairs(SingleSlotInfo.slotIDs) do
              PuzzleData:RefreshSlotStatus(SingleSlotId, PuzzleId)
            end
          end
        end
      end
      EventSystem.Invoke(EventDef.Lobby.UpdateMyHeroInfo)
    end
  }, {
    GameInstance,
    function()
      print("RequestMyHeroInfoToServer failed")
    end
  })
end
function LogicRole.RequestEquipHeroToServer(HeroId, Callback)
  HttpCommunication.Request("hero/equiphero", {heroId = HeroId}, {
    GameInstance,
    function()
      DataMgr.UpdateEquipHero(HeroId)
      if Callback then
        Callback()
      end
      EventSystem.Invoke(EventDef.Lobby.UpdateMyHeroInfo)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function LogicRole.RequestGetHeroFetterInfoToServer(HeroId, SuccFuncList)
  HttpCommunication.Request("hero/getherofetterinfo", {heroId = HeroId}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      print(JsonResponse.Content)
      DataMgr.SetFetterHeroInfoById(HeroId, JsonTable.fetterheros)
      if SuccFuncList then
        SuccFuncList[2](SuccFuncList[1], JsonResponse)
      end
      EventSystem.Invoke(EventDef.Lobby.FetterHeroInfoUpdate)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function LogicRole.RequestEquipFetterHeroToServer(SlotId, EquipHeroId, MainHeroId)
  local Param = {
    heroId = MainHeroId,
    slot = SlotId,
    fetterHeroId = EquipHeroId
  }
  HttpCommunication.Request("hero/equipfetterhero", Param, {
    GameInstance,
    function()
      print("EquipSuccess")
      LogicRole.RequestGetHeroFetterInfoToServer(MainHeroId)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function LogicRole.SetCurSelectRoleId(InHeroId)
  LogicRole.CurSelectHeroId = InHeroId
end
function LogicRole.ShowOrHideRoleChangeList(IsShow, SelectHeroId, AppointWidget)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    if IsShow then
      ChangeLobbyCamera(GameInstance, "Role")
      LogicRole.ShowOrLoadLevel(-1)
      local HeroInfo = DataMgr.GetMyHeroInfo()
      local SelectHeroId = -1 ~= SelectHeroId and SelectHeroId or HeroInfo and HeroInfo.equipHero or 0
      local Widget = AppointWidget
      if AppointWidget then
        Widget:ShowPanel(SelectHeroId)
      end
      LogicRole.ChangeRoleSkyLight(true)
      LogicRole.ShowOrHideRoleMainHero(true)
    else
      if LogicRole.IsRoleMainShow or LogicRole.IsHeroTalentShow then
        return
      end
      LogicRole.CurSelectHeroId = -1
      LogicRole.ShowOrHideRoleMainHero(false)
      LogicRole.ShowOrLoadLevel(-1)
      LogicRole.ChangeRoleSkyLight(false)
      ChangeToLobbyAnimCamera()
      LogicRole.HideCurSkinLightMap()
    end
  end
end
function LogicRole.GetSkinSequence(SkinId)
  local result, row = GetRowData(DT.DT_HeirloomSkin, tostring(SkinId))
  if result then
    local path = UE.UKismetSystemLibrary.BreakSoftObjectPath(row.LevelSequencePath)
    if path and "" ~= path then
      return row.LevelSequencePath
    else
      return nil
    end
  else
    return nil
  end
end
function LogicRole.GetSequenceActor()
  local OutActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "SequencePos"):ToTable()
  if OutActors[1] then
    return OutActors[1]
  end
end
function LogicRole.AddLevel(FileNamePart, SoftPtr, ShowLevelSequence)
  if LogicRole.LevelBgMapData.LevelBgMap[FileNamePart] then
    if LogicRole.LevelBgMapData.LevelBgMap[FileNamePart].bShouldBeVisible == false then
      LogicRole.LevelBgMapData.LevelBgMap[FileNamePart]:SetShouldBeVisible(true)
    end
  else
    if #LogicRole.LevelBgMapData.LevelBgAry >= MAX_LEVEL_BG_NUM then
      local levelStream = LogicRole.LevelBgMapData.LevelBgMap[LogicRole.LevelBgMapData.LevelBgAry[1].LevelName]
      if levelStream and UE.RGUtil.IsUObjectValid(levelStream) and levelStream.bShouldBeLoaded then
        levelStream:SetShouldBeLoaded(false)
      end
      LogicRole.LevelBgMapData.LevelBgMap[LogicRole.LevelBgMapData.LevelBgAry[1].LevelName] = nil
      table.remove(LogicRole.LevelBgMapData.LevelBgAry, 1)
    end
    local levelBgData = {LevelName = FileNamePart, SoftObj = SoftPtr}
    table.insert(LogicRole.LevelBgMapData.LevelBgAry, levelBgData)
    local transform = LogicRole.GetSequenceActor() and ShowLevelSequence and LogicRole.GetSequenceActor():GetTransform() or UE.FTransform()
    LogicRole.LevelBgMapData.LevelBgMap[FileNamePart] = UE.ULevelToolBPLibrary.ExLoadStreamLevelByObj(GameInstance, SoftPtr, transform)
  end
end
function LogicRole.ShowLevelForSequence(Show)
  local viewModel = UIModelMgr:Get("SkinViewModel")
  if not viewModel or not viewModel.ShowSeq then
    return
  end
  local Lobby_02 = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "Lobby_02")
  if Lobby_02 then
    Lobby_02:SetShouldBeVisible(Show)
  else
    return
  end
  local Hero_Ground = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "Hero_Ground")
  if Hero_Ground then
    Hero_Ground:SetShouldBeVisible(Show and LogicLobby.ShowGroundLevel)
  end
  local La_MetaverseCenter_START2_2 = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "La_MetaverseCenter_START2_2")
  if La_MetaverseCenter_START2_2 then
    La_MetaverseCenter_START2_2:SetShouldBeVisible(Show)
  end
end
function LogicRole.GetSequenceLevel(SkinId)
  local result, row = GetRowData(DT.DT_DisplaySkin, tostring(SkinId))
  if result then
    local SequencePath = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(row.LevelSequenceLevelSoftPtr, nil)
    local PathPart, FileNamePart_SQ, ExtensionPart = UE.UBlueprintPathsLibrary.Split(SequencePath, nil, nil, nil)
    return LogicRole.LevelBgMapData.LevelBgMap[FileNamePart_SQ]
  end
  return nil
end
function LogicRole.ShowOrLoadLevel(SkinId, ShowLevelSequence)
  local result, row = GetRowData(DT.DT_DisplaySkin, tostring(SkinId))
  if not LogicRole.LevelBgMapData then
    LogicRole.LevelBgMapData = {}
    LogicRole.LevelBgMapData.LevelBgMap = {}
    LogicRole.LevelBgMapData.LevelBgAry = {}
  end
  local DefaultPathPart, DefaultFileNamePart, DefaultExtensionPart = UE.UBlueprintPathsLibrary.Split(LogicRole.DefaultHeroBgLevelName, nil, nil, nil)
  if not LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart] then
    LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart] = UE.UGameplayStatics.GetStreamingLevel(GameInstance, DefaultFileNamePart)
  end
  if result then
    if not UE.UKismetSystemLibrary.IsValidSoftObjectReference(row.LevelSequenceLevelSoftPtr) then
      LogicRole.ShowLevelForSequence(true)
    else
      LogicRole.ShowLevelForSequence(false)
    end
    if UE.UKismetSystemLibrary.IsValidSoftObjectReference(row.SkinBgLevelSoftPtr) then
      local LevelPath = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(row.SkinBgLevelSoftPtr, nil)
      local PathPart, FileNamePart, ExtensionPart = UE.UBlueprintPathsLibrary.Split(LevelPath, nil, nil, nil)
      for k, v in pairs(LogicRole.LevelBgMapData.LevelBgMap) do
        if k ~= FileNamePart and UE.RGUtil.IsUObjectValid(v) and v.bShouldBeVisible then
          v:SetShouldBeVisible(false)
        end
      end
      LogicRole.AddLevel(FileNamePart, row.SkinBgLevelSoftPtr)
      if ShowLevelSequence and UE.UKismetSystemLibrary.IsValidSoftObjectReference(row.LevelSequenceLevelSoftPtr) then
        if LogicRole.LevelBgMapData.LevelBgMap[FileNamePart] then
          LogicRole.LevelBgMapData.LevelBgMap[FileNamePart]:SetShouldBeVisible(false)
        end
        local SequencePath = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(row.LevelSequenceLevelSoftPtr, nil)
        local PathPart, FileNamePart_SQ, ExtensionPart = UE.UBlueprintPathsLibrary.Split(SequencePath, nil, nil, nil)
        LogicRole.AddLevel(FileNamePart_SQ, row.LevelSequenceLevelSoftPtr, ShowLevelSequence)
      end
    else
      for k, v in pairs(LogicRole.LevelBgMapData.LevelBgMap) do
        if k ~= DefaultFileNamePart and UE.RGUtil.IsUObjectValid(v) and v.bShouldBeVisible then
          v:SetShouldBeVisible(false)
        end
      end
      if UE.RGUtil.IsUObjectValid(LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart]) and LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart].bShouldBeVisible == false then
        LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart]:SetShouldBeVisible(true)
      end
      LogicRole.ShowLevelForSequence(true)
    end
  else
    for k, v in pairs(LogicRole.LevelBgMapData.LevelBgMap) do
      if k ~= DefaultFileNamePart and UE.RGUtil.IsUObjectValid(v) and v.bShouldBeVisible then
        v:SetShouldBeVisible(false)
      end
    end
    if UE.RGUtil.IsUObjectValid(LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart]) and LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart].bShouldBeVisible == false then
      LogicRole.LevelBgMapData.LevelBgMap[DefaultFileNamePart]:SetShouldBeVisible(true)
    end
    LogicRole.ShowLevelForSequence(true)
  end
end
function LogicRole.HideAndUnloadAllBgStreamLevel()
  if LogicRole.LevelBgMapData.LevelBgMap then
    for i, v in ipairs(LogicRole.LevelBgMapData.LevelBgAry) do
      local levelStream = LogicRole.LevelBgMapData.LevelBgMap[v.LevelName]
      if levelStream and UE.RGUtil.IsUObjectValid(levelStream) and levelStream.bShouldBeLoaded then
        levelStream:SetShouldBeLoaded(false)
      end
    end
  end
  LogicRole.LevelBgMapData.LevelBgMap = {}
  LogicRole.LevelBgMapData.LevelBgAry = {}
  LogicRole.ShowLevelForSequence(true)
end
function LogicRole.HideCurSkinLightMap()
  local CurHeroSkinLightMap = LogicRole.HeroSkinLightMapList and LogicRole.HeroSkinLightMapList[LogicRole.CurHeroSkinLightMapName]
  if not CurHeroSkinLightMap or not CurHeroSkinLightMap:IsValid() then
    print("LogicRole.ShowHeroSkinLightMap CurHeroSkinLightMap is empty!")
    return
  end
  if CurHeroSkinLightMap.bShouldBeVisible then
    print("LogicRole.ShowHeroSkinLightMap \233\154\144\232\151\143\229\189\147\229\137\141\229\133\137\231\133\167\229\133\179")
    CurHeroSkinLightMap:SetShouldBeVisible(false)
    LogicRole.CurHeroSkinLightMapName = ""
  end
end
function LogicRole.ShowSkinLightMap(SkinId)
  LogicRole.HideCurSkinLightMap()
  local Result, RowInfo = GetRowData(DT.DT_DisplaySkin, tostring(SkinId))
  if not Result then
    Result, RowInfo = GetRowData(DT.DT_DisplayWeaponSkin, tostring(SkinId))
    if not Result then
      print("LogicRole.ShowHeroSkinLightMap invalid SkinId", SkinId)
    end
  end
  local LightMapSoftPtr
  if Result then
    LightMapSoftPtr = RowInfo.LightMapSoftPtr
  end
  local LevelPath = ""
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(LightMapSoftPtr) then
    LevelPath = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(LightMapSoftPtr)
  end
  if UE.UKismetStringLibrary.IsEmpty(LevelPath) then
    LevelPath = DefaultSkinLightLevelPath
    LightMapSoftPtr = UE.UKismetSystemLibrary.Conv_SoftObjPathToSoftObjRef(UE.UKismetSystemLibrary.MakeSoftObjectPath(LevelPath))
  end
  local TargetStreamLevel = LogicRole.HeroSkinLightMapList[LevelPath]
  if not TargetStreamLevel then
    TargetStreamLevel = UE.ULevelToolBPLibrary.ExLoadStreamLevelByObj(GameInstance, LightMapSoftPtr, UE.FTransform())
    LogicRole.HeroSkinLightMapList[LevelPath] = TargetStreamLevel
  end
  if TargetStreamLevel and not TargetStreamLevel.bShouldBeVisible then
    TargetStreamLevel:SetShouldBeVisible(true)
  end
  LogicRole.CurHeroSkinLightMapName = LevelPath
end
function LogicRole.IsInRoleMain()
  if LogicRole.IsRoleMainShow or LogicRole.IsHeroTalentShow then
    return true
  end
  return false
end
function LogicRole.GetRoleChangeList()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return nil
  end
  local RoleChangeList = UE.UClass.Load("/Game/Rouge/UI/Lobby/Role/WBP_RoleChangeList.WBP_RoleChangeList_C")
  local Widget = UIManager:K2_GetUI(RoleChangeList, nil)
  return Widget
end
function LogicRole.EquipFetterHeroByPos(SlotId, MainHeroId, SoulCoreId)
  if not LogicRole.IsSlotUnlock(SlotId) then
    return
  end
  local Param = {
    heroId = MainHeroId,
    slot = SlotId,
    fetterHeroId = SoulCoreId
  }
  HttpCommunication.Request("hero/equipfetterhero", Param, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      print(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Lobby.EquipFetterHeroByPosSuccess)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function LogicRole.UnlockFetterSlot(SlotId)
  HttpCommunication.Request("hero/unlockfetterslot", {slot = SlotId}, {
    GameInstance,
    function(Target, JsonResponse)
      EventSystem.Invoke(EventDef.Lobby.EquipFetterHeroByPosSuccess)
    end
  }, {
    self,
    function()
    end
  })
end
function LogicRole.UpdateRole(CurHeroId, SkinChangedCallback)
  LogicRole.InitModelMesh(CurHeroId, SkinChangedCallback)
  LogicRole.ChangeRoleSkyLight(true)
end
function LogicRole.UpdateUICaptureBgActor(bIsShow)
  if UE.RGUtil.IsUObjectValid(LogicRole.Capture) then
    if bIsShow then
      LogicRole.Capture.SceneCaptureComponent2D:CaptureScene()
    end
    LogicRole.Capture.SceneCaptureComponent2D.bCaptureEveryFrame = bIsShow
  else
    local CameraList = UE.TArray(UE.AActor)
    UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleMainCapture", CameraList)
    if CameraList:IsValidIndex(1) then
      LogicRole.Capture = CameraList:Get(1)
      if bIsShow then
        LogicRole.Capture.SceneCaptureComponent2D:CaptureScene()
      end
      LogicRole.Capture.SceneCaptureComponent2D.bCaptureEveryFrame = bIsShow
    end
  end
  local characterSkyPath = "Blueprint'/Game/Rouge/MaterialTemplate/CharacterSkyADD.CharacterSkyADD_C'"
  local characterSkyCls = UE.LoadClass(characterSkyPath)
  if characterSkyCls then
    if bIsShow then
      if -1 == LogicRole.OldIntensity or LogicRole.OldIntensity == nil then
        LogicRole.OldIntensity = UE.URGGameplayLibrary.RGSetCharacterLightingIntensity(GameInstance, characterSkyCls, 0)
      end
    elseif -1 ~= LogicRole.OldIntensity and LogicRole.OldIntensity ~= nil then
      UE.URGGameplayLibrary.RGSetCharacterLightingIntensity(GameInstance, characterSkyCls, LogicRole.OldIntensity or 0)
      LogicRole.OldIntensity = -1
    end
  end
end
function LogicRole.UpdatePreCharacterLevelVis(bIsVis, SkinChangedCallback)
  if bIsVis then
    local succ = false
    if UE.RGUtil.IsUObjectValid(LogicRole.RoleInfoMap) then
      LogicRole.RoleInfoMap:SetShouldBeVisible(true)
    else
      local gameState = UE.UGameplayStatics.GetGameState(GameInstance)
      if gameState and gameState.BP_RGGameLevelComp then
        LogicRole.RoleInfoMap = UE.ULevelToolBPLibrary.ExLoadStreamLevelByObj(GameInstance, gameState.BP_RGGameLevelComp.RoleInfoMap, UE.FTransform())
      end
    end
  elseif UE.RGUtil.IsUObjectValid(LogicRole.RoleInfoMap) then
    LogicRole.RoleInfoMap:SetShouldBeVisible(false)
  end
  if bIsVis then
    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
      GameInstance,
      function()
        UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
          GameInstance,
          function()
            LogicRole.UpdateUICaptureBgActor(bIsVis)
            local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
            if bIsVis and UE.RGUtil.IsUObjectValid(Character) then
              LogicRole.UpdateRole(Character:GetTypeID(), SkinChangedCallback)
              LogicRole.UpdateCapturePos(1)
            end
          end
        })
      end
    })
  else
    LogicRole.UpdateUICaptureBgActor(bIsVis)
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if bIsVis and UE.RGUtil.IsUObjectValid(Character) then
      LogicRole.UpdateRole(Character:GetTypeID(), SkinChangedCallback)
      LogicRole.UpdateCapturePos(1)
    end
  end
end
function LogicRole.SetLevelStreamVis(LevelName, bVisible)
  local TargetStreamLevel = UE.UGameplayStatics.GetStreamingLevel(GameInstance, LevelName)
  if TargetStreamLevel and TargetStreamLevel.bShouldBeVisible ~= bVisible then
    TargetStreamLevel:SetShouldBeVisible(bVisible)
  end
end
function LogicRole.InitModelMesh(HeroId, SkinChangedCallback)
  if UE.RGUtil.IsUObjectValid(LogicRole.LobbyRoleActor) then
    if SkinChangedCallback then
      SkinChangedCallback()
    end
    return
  end
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleMainHero", nil)
  local TargetActor
  for i, SingleActor in iterator(AllActors) do
    TargetActor = SingleActor
    break
  end
  if TargetActor then
    local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
    if CharacterRow then
      TargetActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
    TargetActor:ChangeBodyMesh(HeroId, nil, SkinChangedCallback)
    LogicRole.LobbyRoleActor = TargetActor
    local LobyRoleChildActorComponent = TargetActor.ChildActor
    if UE.RGUtil.IsUObjectValid(LobyRoleChildActorComponent.ChildActor) then
      LogicRole.Capture.SceneCaptureComponent2D.ShowOnlyActors:Add(LobyRoleChildActorComponent.ChildActor)
      local DisplayWeaponChildActorComponent = LobyRoleChildActorComponent.ChildActor.ChildActor
      if UE.RGUtil.IsUObjectValid(DisplayWeaponChildActorComponent.ChildActor) then
        LogicRole.Capture.SceneCaptureComponent2D.ShowOnlyActors:Add(DisplayWeaponChildActorComponent.ChildActor)
      end
    end
  end
end
function LogicRole.GetRoleMainActor()
  if not LogicRole.RoleMainActor or not LogicRole.RoleMainActor:IsValid() then
    local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleMainHero", nil)
    for i, SingleActor in iterator(AllActors) do
      LogicRole.RoleMainActor = SingleActor
      break
    end
  end
  return LogicRole.RoleMainActor
end
function LogicRole.PlayCharacterActionByHeroSkinId(TargetActor, CharacterActionRowId)
  local MontageList = {}
  local Result, CharacterActionRowInfo = GetRowData(DT.DT_CharacterAction, CharacterActionRowId)
  if Result then
    for MeshCompName, MontageSoftObjectPtr in pairs(CharacterActionRowInfo.Montage) do
      local MontageObject = GetAssetBySoftObjectPtr(MontageSoftObjectPtr, true)
      MontageList[MeshCompName] = MontageObject
    end
    TargetActor:PlayImprovisation(MontageList)
  end
end
function LogicRole.UpdateCapturePos(Index)
  local Pos = RoleCaptureRolePos[Index]
  local CameraList = UE.TArray(UE.AActor)
  UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleMainCapture", CameraList)
  if CameraList:IsValidIndex(1) then
    local Capture = CameraList:Get(1)
    local Result = UE.FHitResult()
    local CapturePos = UE.FVector(Pos.X, Pos.Y, Pos.Z)
    Capture:K2_SetActorLocation(CapturePos, true, Result, true)
  end
end
function LogicRole.GetAttrInitValue(RightName, HeroId)
  local resultBasicAttrInit, rowBasicAttrInit = GetRowData(DT.DT_BasicAttributeSetInitTable, HeroId)
  if resultBasicAttrInit and rowBasicAttrInit[RightName] then
    return rowBasicAttrInit[RightName]
  end
  local resultSkillAttrInit, rowSkillAttrInit = GetRowData(DT.DT_SkillAttributeSetInit, HeroId)
  if resultSkillAttrInit and rowSkillAttrInit[RightName] then
    return rowSkillAttrInit[RightName]
  end
  local resultEquipAttrInit, rowEquipAttrInit = GetRowData(DT.DT_EquipAttributeSetInit, HeroId)
  if resultEquipAttrInit and rowEquipAttrInit[RightName] then
    return rowEquipAttrInit[RightName]
  end
  return 0
end
function LogicRole.GetAttrDisplayNameList(AttributeDisplayPos)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local DataTableTemp = DTSubsystem:GetDataTable(DT.DT_HeroBasicAttribute)
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(DataTableTemp)
  local RowNameTb = {}
  local Result, RowData = false
  for key, SingleRowName in pairs(RowNames) do
    Result, RowData = GetRowData(DT.DT_HeroBasicAttribute, SingleRowName)
    if Result and RowData.DisplayInUI ~= UE.EAttributeDisplayPos.NoDisplay then
      if AttributeDisplayPos == UE.EAttributeDisplayPos.Detail and RowData.DisplayInUI ~= UE.EAttributeDisplayPos.NoDisplay then
        table.insert(RowNameTb, SingleRowName)
      elseif AttributeDisplayPos == UE.EAttributeDisplayPos.Main and RowData.DisplayInUI == UE.EAttributeDisplayPos.Main then
        table.insert(RowNameTb, SingleRowName)
      end
    end
  end
  table.sort(RowNameTb, function(A, B)
    local ResultA, AAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(A))
    local ResultB, BAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(B))
    return AAttrDisplay.PriorityLevel > BAttrDisplay.PriorityLevel
  end)
  return RowNameTb
end
function LogicRole.GetAttributeListNew(HeroId, AttributeDisplayPos)
  local Result, RowData = GetRowData(DT.DT_BasicAttributeSetInitTable, HeroId)
  if not Result then
    print("WBP_AbridgeAttrTips_C:RefreshHeroAttribtueInfo not found BasicAttribute Init Data, HeroId: ", HeroId)
    return {}, {}
  end
  local singleShotDamageAttr = "BasicAttributeSet.SingleShotDamage"
  local skillQ_EnergyRecover = "SkillAttributeSet.SkillQEnergyRecover"
  local skillE_RecoveryCountTimes = "SkillAttributeSet.SkillE_RecoveryCountTimes"
  local singleShotAttrIdx = 0
  local skillERecoverIdx = 0
  local AllAttribute = LogicRole.GetAttrDisplayNameList(AttributeDisplayPos)
  local InscriptionIdList = {}
  local attrDic, inscriptionIdList = PuzzleData:GetAllEquipAttrAndInscription(HeroId)
  for i, v in ipairs(inscriptionIdList) do
    table.insert(InscriptionIdList, v)
  end
  local puzzleAttrTagToAttrData = {}
  for k, v in pairs(attrDic) do
    local resultAttrModifyOp, rowAttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, tostring(k))
    if resultAttrModifyOp then
      local attributeTag = UE.UChipGameplayEffect.StaticGetChipAttribute(rowAttrModifyOp.GEClass).AttributeName
      local OP = rowAttrModifyOp.Op
      local attrValue = v
      if rowAttrModifyOp.bIsPercentValue then
        attrValue = attrValue / 100
      end
      if puzzleAttrTagToAttrData[attributeTag] then
        puzzleAttrTagToAttrData[attributeTag].Value = puzzleAttrTagToAttrData[attributeTag].Value + attrValue
      else
        puzzleAttrTagToAttrData[attributeTag] = {Value = attrValue, AttributeModifyOp = OP}
      end
    end
  end
  local HeroTalent = DataMgr.GetHeroTalentByHeroId(HeroId)
  if not HeroTalent then
    if DataMgr.IsOwnHero(HeroId) then
      LogicTalent.RequestGetHeroTalentsToServer(HeroId)
    end
  else
    for SingleGroupId, SingleInfo in pairs(HeroTalent) do
      local SingleGroupInfo = LogicTalent.GetTalentTableRow(SingleGroupId)
      local TargetInfo = SingleGroupInfo[SingleInfo.level]
      TargetInfo = TargetInfo or SingleGroupInfo[1]
      if TargetInfo then
        for index, SingleInscriptionId in ipairs(TargetInfo.Inscription) do
          table.insert(InscriptionIdList, SingleInscriptionId)
        end
      else
        print("\230\156\170\230\137\190\229\136\176\229\189\147\229\137\141\229\164\169\232\181\139\231\154\132\233\133\141\231\189\174\228\191\161\230\129\175", SingleGroupId)
      end
    end
  end
  local CommonTalents = DataMgr.GetCommonTalentInfos()
  if not CommonTalents or next(CommonTalents) == nil then
  else
    for SingleGroupId, SingleInfo in pairs(CommonTalents) do
      local SingleGroupInfo = LogicTalent.GetTalentTableRow(SingleGroupId)
      if SingleGroupInfo then
        local TargetInfo = SingleGroupInfo[SingleInfo.level]
        TargetInfo = TargetInfo or SingleGroupInfo[1]
        if TargetInfo then
          for index, SingleInscriptionId in ipairs(TargetInfo.Inscription) do
            table.insert(InscriptionIdList, SingleInscriptionId)
          end
        else
          print("\230\156\170\230\137\190\229\136\176\229\189\147\229\137\141\229\164\169\232\181\139\231\154\132\233\133\141\231\189\174\228\191\161\230\129\175", SingleGroupId)
        end
      end
    end
  end
  local profyInscriptionList = ProficiencyData:GetAllInscriptionReward(HeroId)
  for i, v in ipairs(profyInscriptionList) do
    table.insert(InscriptionIdList, v)
  end
  local EquippedWeaponInfo
  if not DataMgr.IsOwnHero(HeroId) then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, HeroId)
    if Result then
      EquippedWeaponInfo = {
        {
          resourceId = tostring(RowInfo.WeaponID),
          stones = {}
        }
      }
    end
  else
    EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(HeroId)
  end
  local TargetEquippedInfo = EquippedWeaponInfo and EquippedWeaponInfo[1] or nil
  local ModifyAttributeListNew = {}
  for index, SingleAttributeName in ipairs(AllAttribute) do
    local Result, LeftName, RightName = UE.UKismetStringLibrary.Split(SingleAttributeName, ".", nil, nil)
    local resultHeroBasic, rowHeroBasic = GetRowData(DT.DT_HeroBasicAttribute, tostring(SingleAttributeName))
    local attrTb = {FullAttrName = SingleAttributeName, Value = 0}
    if resultHeroBasic then
      if rowHeroBasic.bIsAttrOpMode then
        for i, v in pairs(rowHeroBasic.AttrOpCfgAry) do
          local valueOp = 0
          if v.bIsOpAttr then
            local RowName = UE.URGBlueprintLibrary.GetGameplayAttributeFullName(v.Attribute)
            valueOp = LogicRole.GetAttrValue(RowName, HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
          else
            valueOp = v.Value
          end
          if v.ModifierOp == UE.EGameplayModOp.Additive then
            attrTb.Value = attrTb.Value + valueOp
          elseif v.ModifierOp == UE.EGameplayModOp.Multiplicitive then
            attrTb.Value = attrTb.Value * valueOp
          elseif v.ModifierOp == UE.EGameplayModOp.Division then
            attrTb.Value = attrTb.Value / valueOp
          elseif v.ModifierOp == UE.EGameplayModOp.Override then
            attrTb.Value = valueOp
          end
        end
      else
        if SingleAttributeName == singleShotDamageAttr then
          singleShotAttrIdx = index
        elseif SingleAttributeName == skillQ_EnergyRecover then
        elseif SingleAttributeName == skillE_RecoveryCountTimes then
          skillERecoverIdx = index
        end
        attrTb.Value = LogicRole.GetAttrValue(SingleAttributeName, HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
      end
      table.insert(ModifyAttributeListNew, attrTb)
    end
  end
  local attrName = "BasicAttributeSet.BaseAttack"
  local Result, LeftName, RightName = UE.UKismetStringLibrary.Split(attrName, ".", nil, nil)
  local Attribute = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(attrName)
  local SingleAttributeConfigTemp = UE.FRGAttributeConfig()
  SingleAttributeConfigTemp.Attribute = Attribute
  SingleAttributeConfigTemp.Value = LogicRole.GetAttrInitValue(RightName, HeroId)
  local baseAttackValue = LogicRole.GetAttrValue(attrName, HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgRatio = 1
  if TargetEquippedInfo then
    weaponDmgRatio = LogicOutsideWeapon.GetWeaponDamage(TargetEquippedInfo.resourceId, false)
  end
  local baseAtkAdd = LogicRole.GetAttrValue("BasicAttributeSet.BaseAttackAdd", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local baseAtkRatio = LogicRole.GetAttrValue("BasicAttributeSet.BaseAttackRatio", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local baseAtkFixedAdd = LogicRole.GetAttrValue("BasicAttributeSet.BaseAttackFixedAdd", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local baseWeaponAtk = LogicRole.GetAttrValue("BasicAttributeSet.BaseWeaponAttack", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgAdd = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageAdd", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local comprehensiveAttackRatio = LogicRole.GetAttrValue("BasicAttributeSet.ComprehensiveAttackRatio", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgRatioAdd = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageRatioAdd", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgAdd_A = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageAdd_A", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgAdd_B = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageAdd_B", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgAdd_C = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageAdd_C", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgReduce_A = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageReduce_A", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDmgReduce_B = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageReduce_B", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local weaponDamageRatioReduce = LogicRole.GetAttrValue("EquipAttributeSet.WeaponDamageRatioReduce", HeroId, InscriptionIdList, puzzleAttrTagToAttrData)
  local bulletDmgRatio = (1 + weaponDmgRatioAdd + weaponDmgAdd_A) * (1 + weaponDmgAdd_B) * (1 + weaponDmgAdd_C) / ((1 + weaponDamageRatioReduce + weaponDmgReduce_A) * (1 + weaponDmgReduce_B))
  local atkValue = (baseAttackValue + baseAtkAdd) * baseAtkRatio + baseAtkFixedAdd
  local SingleShotDamageValue = ((atkValue + baseWeaponAtk) * comprehensiveAttackRatio * weaponDmgRatio + weaponDmgAdd) * bulletDmgRatio
  print("SingleShotDamageValue", SingleShotDamageValue, atkValue, baseAttackValue, baseAtkAdd, baseAtkRatio, baseAtkFixedAdd, baseWeaponAtk, comprehensiveAttackRatio, weaponDmgRatio, weaponDmgAdd, bulletDmgRatio)
  local attrSkillQGrowSpeed = "SkillQ_EnergyRecover_SelfGrowSpeed"
  local skillQEnergyRecoverValue = 100 / LogicRole.GetAttrInitValue(attrSkillQGrowSpeed, HeroId)
  local attrSkillERecoveryCountTimes = "SkillE_RecoveryCountTimes"
  local skillERecoveryCountTimesValue = 1 / LogicRole.GetAttrInitValue(attrSkillERecoveryCountTimes, HeroId) * LogicRole.GetSkillEInterval()
  local specificTb = {}
  if singleShotAttrIdx > 0 then
    specificTb[singleShotAttrIdx] = {Value = SingleShotDamageValue, RowName = singleShotDamageAttr}
  end
  if skillERecoverIdx > 0 then
    specificTb[skillERecoverIdx] = {Value = skillERecoveryCountTimesValue, RowName = skillE_RecoveryCountTimes}
  end
  return ModifyAttributeListNew, specificTb
end
function LogicRole.GetAttrValue(AttrName, HeroId, InscriptionIdList, PuzzleAttrTagToAttrData, InitValue)
  local Result, LeftName, RightName = UE.UKismetStringLibrary.Split(AttrName, ".", nil, nil)
  local Attribute = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(AttrName)
  local SingleAttributeConfigTemp = UE.FRGAttributeConfig()
  SingleAttributeConfigTemp.Attribute = Attribute
  SingleAttributeConfigTemp.Value = InitValue or LogicRole.GetAttrInitValue(RightName, HeroId)
  local AttrList = UE.URGBlueprintLibrary.GetAllAttributesByAttributeList(InscriptionIdList, {SingleAttributeConfigTemp})
  local AttrValue = AttrList:GetRef(1).Value
  if PuzzleAttrTagToAttrData and PuzzleAttrTagToAttrData[RightName] then
    if PuzzleAttrTagToAttrData[RightName].AttributeModifyOp == UE.ERGAttributeModifyOp.AddValue then
      AttrValue = AttrValue + PuzzleAttrTagToAttrData[RightName].Value
    elseif PuzzleAttrTagToAttrData[RightName].AttributeModifyOp == UE.ERGAttributeModifyOp.AddRatio then
      AttrValue = PuzzleAttrTagToAttrData[RightName].Value / 100 + AttrValue
    end
  end
  return AttrValue
end
function LogicRole.GetSkillEInterval()
  local cls = UE.LoadClass(GA_SkillE_AutoRecoveryDefaultPath)
  if not cls then
    return 0
  end
  local skillEGA = cls:GetDefaultObject()
  return skillEGA.Interval
end
function LogicRole.GetHeroDefaultSkinId(HeroId)
  local SkinId = -1
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, HeroId)
  if Result then
    SkinId = RowInfo.SkinID
  end
  return SkinId
end
function LogicRole.SetEffectState(Actor, SkinId, HeroID, IsShow)
  local result, rowInfo = GetRowData(DT.DT_DisplaySkin, SkinId)
  if result then
    local Effects = rowInfo.Effects
    local EffectKeys = {}
    local SkinSystem = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(GameInstance, UE.URGSkinSystem:StaticClass())
    for i, v in pairs(Effects:ToTable()) do
      if v.bDynamicCreate then
        table.insert(EffectKeys, v.NiagaraComponentKey)
      end
    end
    local EffectState = false
    local AttachId = SkinId
    local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, GetTbSkinRowNameBySkinID(SkinId))
    if result and 0 ~= rowInfo.ParentSkinId then
      AttachId = rowInfo.ParentSkinId
    end
    if nil == IsShow then
      local HeroInfo = DataMgr.GetMyHeroInfo().heros
      for i, v in ipairs(HeroInfo) do
        if v.id == HeroID then
          EffectState = v.specialEffectState[tostring(AttachId)]
        end
      end
    else
      EffectState = IsShow
    end
    if true == EffectState or 1 == EffectState then
      SkinSystem:CreateDynamicSubNiagaraComponent(Actor, EffectKeys)
    else
      SkinSystem:DestroyDynamic(Actor, EffectKeys)
    end
  end
end
function LogicRole.GetCurUseHeroId()
  if GetCurSceneStatus() == UE.ESceneStatus.EBattle then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if UE.RGUtil.IsUObjectValid(Character) then
      return Character:GetTypeID()
    end
    return -1
  else
    if DataMgr.GetMyHeroInfo() and DataMgr.GetMyHeroInfo().equipHero then
      return DataMgr.GetMyHeroInfo().equipHero
    end
    return -1
  end
end
function LogicRole.GetCurWeaponId()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if UE.RGUtil.IsUObjectValid(Character) then
    local CurrentWeapon = Character:GetCurrentWeapon()
    if UE.RGUtil.IsUObjectValid(CurrentWeapon) then
      return CurrentWeapon:GetItemId()
    end
  end
  return -1
end
function LogicRole.Clear()
  LogicRole.MainFetterHero = nil
  LogicRole.FetterList = {}
  LogicRole.HeroStarTable = {}
  LogicRole.HeroSkillTable = {}
  LogicRole.IsInit = false
  LogicRole.OldIntensity = -1
  LogicRole.LevelBgMapData.LevelBgMap = {}
  LogicRole.LevelBgMapData.LevelBgAry = {}
  LogicRole.CurHeroSkinLightMapName = ""
  LogicRole.HeroSkinLightMapList = {}
end
