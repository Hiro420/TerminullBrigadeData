local rapidjson = require("rapidjson")
BtbStyle = BtbStyle or {
  Normal = 1,
  Cover = 2,
  Select = 3
}
Logic_IllustratedGuide = Logic_IllustratedGuide or {}
Logic_IllustratedGuide.GodGroup = {}
Logic_IllustratedGuide.GenericModifySubGroup = {}
Logic_IllustratedGuide.DataObjCls = UE.UClass.Load("/Game/Rouge/UI/IllustratedGuide/BP_IGuideData.BP_IGuideData_C")
Logic_IllustratedGuide.CurGenericModifyInfo = nil
Logic_IllustratedGuide.CurFocusGenericModifySubGroup = {}
function Logic_IllustratedGuide.CreateItemData()
  local ItemData = {}
  ItemData.RowName = 0
  ItemData.ModifieConfig = UE.FRGGenericModifyTableRow()
  ItemData.Quality = UE.ERGGenericModifyType.Normal
  ItemData.bLock = false
  ItemData.bObtained = false
  ItemData.bDual = false
  return ItemData
end
function Logic_IllustratedGuide.CreateGodListItemData()
  local ItemData = {}
  ItemData.RowName = 0
  ItemData.Id = 0
  ItemData.Icon = UE.FSoftObjectPath()
  ItemData.bMark = false
  ItemData.bDual = false
  return ItemData
end
function Logic_IllustratedGuide.IsLobbyRoom()
  local world = GameInstance:GetWorld()
  local PC = UE.UGameplayStatics.GetPlayerController(world, 0)
  return not PC:Cast(UE.ARGPlayerController)
end
function Logic_IllustratedGuide.GetGodNameList()
  local NameList = GetAllRowNames(DT.DT_GenericModifyGroup)
  table.sort(NameList, function(a, b)
    return b < a
  end)
  return NameList
end
function Logic_IllustratedGuide.GetGodListData()
  local ReturnTable = {}
  Logic_IllustratedGuide.DataObjCls = UE.UClass.Load("/Game/Rouge/UI/IllustratedGuide/BP_IGuideData.BP_IGuideData_C")
  for index, value in ipairs(Logic_IllustratedGuide.GetGodNameList()) do
    local DataObj = NewObject(Logic_IllustratedGuide.DataObjCls, GameInstance, nil)
    local Data = Logic_IllustratedGuide.CreateGodListItemData()
    local Result, RowInfo = GetRowData(DT.DT_GenericModifyGroup, value)
    if Result then
      Data.Icon = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(RowInfo.ChoosePanelIcon)
      RowInfo.GenericModifyType = UE.ERGGenericModifyType.Dual
    end
    Data.RowName = value
    Data.Id = value
    if DataObj:IsValid() then
      DataObj.Data = Data
      ReturnTable[index] = DataObj
    else
      print("LJS", "Logic_IllustratedGuide.GetGodListData", "DataObj is nil")
    end
  end
  return ReturnTable
end
function Logic_IllustratedGuide.SetCurGodId(GodId)
  if Logic_IllustratedGuide.CurGodId == GodId then
    return
  end
  Logic_IllustratedGuide.CurGodId = GodId
end
function Logic_IllustratedGuide.GetGenericModifyByGodGroupId(GodGroup)
  if Logic_IllustratedGuide.GodGroup[GodGroup] then
    return Logic_IllustratedGuide.GodGroup[GodGroup]
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return
  end
  local GenericModifyArr = Logic_IllustratedGuide.GetAllModifiesOfGroup(GodGroup)
  local CacheSubGroup = {}
  for index, value in ipairs(GenericModifyArr) do
    local ModifyId = tostring(value.ModifyId)
    local Result, RowInfo = GetRowData(DT.DT_GenericModify, ModifyId)
    if RowInfo and (CacheSubGroup[RowInfo.SubGroupId] == nil or CacheSubGroup[RowInfo.SubGroupId].SubGroupId > RowInfo.SubGroupId) then
      CacheSubGroup[RowInfo.SubGroupId] = RowInfo
    end
  end
end
function Logic_IllustratedGuide.GetAllModifiesOfGroup(GodGroup)
  if Logic_IllustratedGuide.GodGroup[GodGroup] ~= nil then
    return Logic_IllustratedGuide.GodGroup[GodGroup]
  end
  local RowNames = GetAllRowNames(DT.DT_GenericModify)
  local CacheSubGroup = {}
  for key, value in pairs(RowNames) do
    local Result, RowInfo = GetRowData(DT.DT_GenericModify, value)
    if RowInfo and RowInfo.GroupId == tonumber(GodGroup) and RowInfo.bShowInIllustrated and (nil == CacheSubGroup[RowInfo.SubGroupId] or CacheSubGroup[RowInfo.SubGroupId].SubGroupId > RowInfo.SubGroupId) then
      RowInfo.ModifyId = tonumber(value)
      CacheSubGroup[RowInfo.SubGroupId] = RowInfo
    end
  end
  Logic_IllustratedGuide.GodGroup[GodGroup] = CacheSubGroup
  return CacheSubGroup
end
function Logic_IllustratedGuide.GetAllModifiesDataOfGroup(GodGroup)
  local ReturnTable = {}
  Logic_IllustratedGuide.DataObjCls = UE.UClass.Load("/Game/Rouge/UI/IllustratedGuide/BP_IGuideData.BP_IGuideData_C")
  for key, value in pairs(Logic_IllustratedGuide.GetAllModifiesOfGroup(GodGroup)) do
    local DataObj = NewObject(Logic_IllustratedGuide.DataObjCls, GameInstance, nil)
    local Data = Logic_IllustratedGuide.CreateItemData()
    Data.RowName = value.ModifyId
    Data.ModifieConfig = value
    Data.bLock = Logic_IllustratedGuide.IsLockGenericModify(value.FrontConditions)
    Data.Quality = value.GenericModifyType
    Data.bObtained = Logic_IllustratedGuide.IsObtained(value.ModifyId)
    Data.bDual = value.GenericModifyType == UE.ERGGenericModifyType.Dual
    Data.Slot = value.Slot
    if DataObj:IsValid() then
      DataObj.Data = Data
      table.insert(ReturnTable, DataObj)
    else
      print("LJS", "Logic_IllustratedGuide.GetAllModifiesDataOfGroup", "DataObj is nil")
    end
  end
  table.sort(ReturnTable, function(a, b)
    if a.Data.Quality == b.Data.Quality then
      if a.Data.bObtained == b.Data.bObtained then
        if a.Data.bLock ~= b.Data.bLock then
          return not a.Data.bLock
        end
      else
        return a.Data.bObtained == true
      end
    else
      return a.Data.Quality < b.Data.Quality
    end
  end)
  return ReturnTable
end
function Logic_IllustratedGuide.IsObtained(ModifyId)
  local GenericModifyTable = Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
  if nil == GenericModifyTable then
    return false
  end
  for index, GenericModifyId in ipairs(GenericModifyTable) do
    if Logic_IllustratedGuide.GenericModify_SubGroupIdEqual(GenericModifyId, ModifyId) then
      return true
    end
  end
  return false
end
function Logic_IllustratedGuide.MeetFrontCondition(FrontCondition)
  local GenericModifyArr = Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
  for key2, SetValue in pairs(FrontCondition.SubGroupIds:ToTable()) do
    if nil == GenericModifyArr then
      return false
    end
    for key1, GenericModify in pairs(GenericModifyArr) do
      local Result, RowInfo = GetRowData(DT.DT_GenericModify, GenericModify)
      if Result and RowInfo.SubGroupId == SetValue then
        return true
      end
    end
  end
  return false
end
function Logic_IllustratedGuide.UnLockGenericModify(FrontConditions)
  local UnLockNum = 0
  local UnLockIndex = false
  local Break1 = false
  local Break2 = false
  local GenericModifyArr = Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
  if nil == GenericModifyArr then
    GenericModifyArr = {}
  end
  if FrontConditions:Num() >= 1 and FrontConditions:GetRef(1) and GenericModifyArr then
    for key2, SetValue in pairs(FrontConditions:GetRef(1).SubGroupIds:ToTable()) do
      if Break1 then
        break
      end
      for key1, GenericModify in pairs(GenericModifyArr) do
        local Result, RowInfo = GetRowData(DT.DT_GenericModify, GenericModify)
        if Result and RowInfo.SubGroupId == SetValue then
          UnLockIndex = true
          UnLockNum = UnLockNum + 1
          Break1 = true
          break
        end
      end
    end
  end
  if FrontConditions:Num() >= 2 and FrontConditions:GetRef(2) then
    for key2, SetValue in pairs(FrontConditions:GetRef(2).SubGroupIds:ToTable()) do
      if Break2 then
        break
      end
      for key1, GenericModify in pairs(GenericModifyArr) do
        local Result, RowInfo = GetRowData(DT.DT_GenericModify, GenericModify)
        if Result and RowInfo.SubGroupId == SetValue then
          UnLockNum = UnLockNum + 1
          Break2 = true
          break
        end
      end
    end
  end
  return UnLockNum
end
function Logic_IllustratedGuide.IsLockGenericModify(FrontConditions)
  local Num = FrontConditions:Num()
  local UnLockNum = Logic_IllustratedGuide.UnLockGenericModify(FrontConditions)
  return Num > UnLockNum
end
function Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return
  end
  local GenericModifyArr = RGGenericModifyComponent:GetAllModifies(nil)
  local ReturnTable = {}
  for key, value in pairs(GenericModifyArr:ToTable()) do
    table.insert(ReturnTable, value.ModifyId)
  end
  return ReturnTable
end
function Logic_IllustratedGuide.GetAllGenericModifyDataByCharacter(Character)
  if not Character then
    return
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return
  end
  local GenericModifyArr = RGGenericModifyComponent:GetAllModifies(nil)
  local ReturnTable = {}
  for key, value in pairs(GenericModifyArr:ToTable()) do
    table.insert(ReturnTable, value)
  end
  return ReturnTable
end
function Logic_IllustratedGuide.DoesPlayerHaveGenericModify(GenericModifyId, bSubGroupIdEqual)
  local PlayerGenericModifys = Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
  if nil == PlayerGenericModifys then
    PlayerGenericModifys = {}
  end
  for index, PlayerGenericModify in ipairs(PlayerGenericModifys) do
    if bSubGroupIdEqual then
      if Logic_IllustratedGuide.GenericModify_SubGroupIdEqual(GenericModifyId, PlayerGenericModify) then
        print("[LJS]\239\188\154\230\159\165\232\175\162\229\136\176\231\142\169\229\174\182\230\139\165\230\156\137 ", PlayerGenericModify, "\228\184\142", GenericModifyId, "\231\187\132ID\231\155\184\229\144\140")
        return true
      end
    elseif PlayerGenericModify == GenericModifyId then
      print("[LJS]\239\188\154\230\159\165\232\175\162\229\136\176\231\142\169\229\174\182\230\139\165\230\156\137 ", PlayerGenericModify)
      return true
    end
  end
  return false
end
function Logic_IllustratedGuide.GenericModify_SubGroupIdEqual(ModifyIdA, ModifyIdB)
  local ResultA, RowInfoA = GetRowData(DT.DT_GenericModify, ModifyIdA)
  if not ResultA then
    return false
  end
  local ResultB, RowInfoB = GetRowData(DT.DT_GenericModify, ModifyIdB)
  if not ResultB then
    return false
  end
  return RowInfoB.SubGroupId == RowInfoA.SubGroupId
end
function Logic_IllustratedGuide.LoadGenericModifyTable()
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("\231\165\157\231\166\143\229\155\190\233\137\180, \230\150\176\230\137\139\229\133\179 \228\184\141\230\137\167\232\161\140\229\155\190\233\137\180\229\138\160\232\189\189")
    return
  end
  print("LoadGenericModifyTable")
  Logic_IllustratedGuide.CurFocusGenericModifySubGroup = {}
  Logic_IllustratedGuide.GenericModifySubGroup = {}
  local RowNames = GetAllRowNames(DT.DT_GenericModify)
  local CacheSubGroup = {}
  for key, value in pairs(RowNames) do
    local Result = false
    local RowInfo = UE.FRGGenericModifyTableRow
    Result, RowInfo = GetRowData(DT.DT_GenericModify, value)
    if Result then
      if Logic_IllustratedGuide.GenericModifySubGroup[RowInfo.SubGroupId] == nil then
        Logic_IllustratedGuide.GenericModifySubGroup[RowInfo.SubGroupId] = {}
      end
      table.insert(Logic_IllustratedGuide.GenericModifySubGroup[RowInfo.SubGroupId], value)
    end
  end
end
function Logic_IllustratedGuide.FocusStatus(ModifyInfo)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    Logic_IllustratedGuide.CurFocusGenericModifySubGroup = nil
    return 0
  end
  for key, value in pairs(Logic_IllustratedGuide.CurFocusGenericModifySubGroup) do
    if value == ModifyInfo.SubGroupId then
      return 1
    end
  end
  local AllGenericModify = Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
  if nil == AllGenericModify then
    return 0
  end
  for index, value in ipairs(AllGenericModify) do
    if Logic_IllustratedGuide.GenericModify_SubGroupIdEqual(ModifyInfo.ModifyId, value) then
      return 2
    end
  end
  return 0
end
function Logic_IllustratedGuide.FocusModify(ModifyInfo)
  local Status = Logic_IllustratedGuide.FocusStatus(ModifyInfo)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return
  end
  if 0 == Status then
    if #Logic_IllustratedGuide.CurFocusGenericModifySubGroup >= 3 then
      ShowWaveWindow(102001)
      return
    end
    table.insert(Logic_IllustratedGuide.CurFocusGenericModifySubGroup, ModifyInfo.SubGroupId)
    RGGenericModifyComponent:FocusGenericModifySubGroup(ModifyInfo.SubGroupId)
  elseif 1 == Status then
    table.RemoveItem(Logic_IllustratedGuide.CurFocusGenericModifySubGroup, ModifyInfo.SubGroupId)
    RGGenericModifyComponent:UnFocusGenericModifySubGroup(ModifyInfo.SubGroupId)
  elseif 2 == Status then
  end
end
Logic_IllustratedGuide.SearchKeyword = ""
Logic_IllustratedGuide.KeywordCache = {}
Logic_IllustratedGuide.AttributeModifySet = {}
Logic_IllustratedGuide.UnLockAttributeModify = {}
function Logic_IllustratedGuide.CreateSetListItemData()
  local ItemData = {}
  ItemData.Id = 0
  return ItemData
end
function Logic_IllustratedGuide.CreateAttributeModifyListItemData()
  local ItemData = {}
  ItemData.Id = 0
  return ItemData
end
function Logic_IllustratedGuide.GetSetListData()
  local ItemList = {}
  Logic_IllustratedGuide.DataObjCls = UE.UClass.Load("/Game/Rouge/UI/IllustratedGuide/BP_IGuideData.BP_IGuideData_C")
  if Logic_IllustratedGuide.SearchKeyword == "" then
    for key, value in pairs(GetAllRowNames(DT.DT_AttributeModifySet)) do
      local DataObj = NewObject(Logic_IllustratedGuide.DataObjCls, GameInstance, nil)
      local Data = Logic_IllustratedGuide.CreateSetListItemData()
      Data.Id = value
      DataObj.Data = Data
      table.insert(ItemList, DataObj)
    end
    return ItemList
  end
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if nil == logicCommandDataSubsystem then
    return ItemList
  end
  for key, value in pairs(GetAllRowNames(DT.DT_AttributeModifySet)) do
    local Result = false
    local RowInfo = UE.FRGAttributeModifySetTableRow
    Result, RowInfo = GetRowData(DT.DT_AttributeModifySet, value)
    if Result and nil == Logic_IllustratedGuide.KeywordCache[value] then
      Logic_IllustratedGuide.KeywordCache[value] = {}
      table.insert(Logic_IllustratedGuide.KeywordCache[value], RowInfo.SetName)
      local OutBaseSaveData = GetLuaInscription(RowInfo.BaseInscription.BaseInscriptionId)
      if OutBaseSaveData then
        local desc = GetLuaInscriptionDesc(RowInfo.BaseInscription.BaseInscriptionId)
        table.insert(Logic_IllustratedGuide.KeywordCache[value], desc)
      end
      local LevelInscriptionMap = RowInfo.LevelInscriptionMap:ToTable()
      for key1, Inscription in pairs(LevelInscriptionMap) do
        local OutSaveData = GetLuaInscription(Inscription)
        if OutSaveData then
          local desc = GetLuaInscriptionDesc(Inscription)
          table.insert(Logic_IllustratedGuide.KeywordCache[value], desc)
        end
      end
    end
  end
  for Id, KeywordTable in pairs(Logic_IllustratedGuide.KeywordCache) do
    for key2, KeywordCache in pairs(KeywordTable) do
      if string.find(KeywordCache, Logic_IllustratedGuide.SearchKeyword) then
        local DataObj = NewObject(Logic_IllustratedGuide.DataObjCls, GameInstance, nil)
        local Data = Logic_IllustratedGuide.CreateSetListItemData()
        Data.Id = Id
        DataObj.Data = Data
        table.insert(ItemList, DataObj)
        break
      end
    end
  end
  return ItemList
end
function Logic_IllustratedGuide.SortSetListData(ItemList)
  table.sort(ItemList, function(a, b)
    return a.Data.Id > b.Data.Id
  end)
  return ItemList
end
function Logic_IllustratedGuide.GetAttributeModifyListData(SetId)
  local ItemList = {}
  local AttributeModifyTable = Logic_IllustratedGuide.GetAttributeModifysBySetId(SetId)
  for key, value in pairs(AttributeModifyTable) do
    local DataObj = NewObject(Logic_IllustratedGuide.DataObjCls, GameInstance, nil)
    local Data = Logic_IllustratedGuide.CreateAttributeModifyListItemData()
    Data.Id = value
    DataObj.Data = Data
    table.insert(ItemList, DataObj)
  end
  table.sort(ItemList, function(a, b)
    local Result = false
    local RowInfoA = UE.FRGAttributeModifyTableRow
    local RowInfoB = UE.FRGAttributeModifyTableRow
    Result, RowInfoA = GetRowData(DT.DT_AttributeModify, a.Data.Id)
    if not Result then
      return false
    end
    Result, RowInfoB = GetRowData(DT.DT_AttributeModify, b.Data.Id)
    if not Result then
      return false
    end
    if RowInfoA.Rarity > RowInfoB.Rarity then
      return true
    end
    if RowInfoA.Rarity == RowInfoB.Rarity then
      return a.Data.Id > b.Data.Id
    end
  end)
  return ItemList
end
function Logic_IllustratedGuide.LoadAttributeModifyCategory()
  print("LJS : LoadAttributeModifyCategory")
  Logic_IllustratedGuide.AttributeModifySet = {}
  for key, RowName in pairs(GetAllRowNames(DT.DT_AttributeModify)) do
    local Result = false
    local RowInfo = UE.FRGAttributeModifyTableRow
    Result, RowInfo = GetRowData(DT.DT_AttributeModify, RowName)
    if Result then
      for key, value in pairs(RowInfo.SetArray:ToTable()) do
        if Logic_IllustratedGuide.AttributeModifySet[value] == nil then
          Logic_IllustratedGuide.AttributeModifySet[value] = {}
        end
        table.insert(Logic_IllustratedGuide.AttributeModifySet[value], RowName)
      end
    end
  end
end
Logic_IllustratedGuide.LoadAttributeModifyCategory()
function Logic_IllustratedGuide.GetAttributeModifysBySetId(SetId)
  if Logic_IllustratedGuide.AttributeModifySet[tonumber(SetId)] then
    return Logic_IllustratedGuide.AttributeModifySet[tonumber(SetId)]
  end
  Logic_IllustratedGuide.LoadAttributeModifyCategory()
  return Logic_IllustratedGuide.AttributeModifySet[tonumber(SetId)]
end
function Logic_IllustratedGuide.PullUnLockAttributeModify()
  HttpCommunication.Request("resource/pulldigitalcollectionpack", {}, {
    GameInstance,
    function(Target, JsonResponse)
      Logic_IllustratedGuide.OnPullUnLockAttributeModifySuccess(JsonResponse)
    end
  }, {
    GameInstance,
    function()
      Logic_IllustratedGuide.OnPullUnLockAttributeModifyFail()
    end
  })
end
function Logic_IllustratedGuide.OnPullUnLockAttributeModifySuccess(JsonResponse)
  print("OnPullUnLockAttributeModifySuccess", JsonResponse.Content)
  local response = rapidjson.decode(JsonResponse.Content)
  for key, value in pairs(response.digitalcollections) do
    Logic_IllustratedGuide.UnLockAttributeModify[value.ID] = true
  end
end
function Logic_IllustratedGuide.OnPullUnLockAttributeModifyFail()
end
