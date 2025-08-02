local rapidjson = require("rapidjson")
LogicOutsideWeapon = LogicOutsideWeapon or {IsInit = false, WeaponDetailsAttrPreviewNum = 3}

function LogicOutsideWeapon.Init()
  LogicOutsideWeapon.HeroWeaponList = {}
  LogicOutsideWeapon.DealWithTable()
end

function LogicOutsideWeapon.Clear()
  LogicOutsideWeapon.HeroWeaponList = {}
end

function LogicOutsideWeapon.DealWithTable()
  local WeaponTable = LuaTableMgr.GetLuaTableByName(TableNames.TBWeapon)
  if not WeaponTable then
    return
  end
  for WeaponId, WeaponInfo in pairs(WeaponTable) do
    for index, SingleHeroRelate in ipairs(WeaponInfo.HeroRelate) do
      if LogicOutsideWeapon.HeroWeaponList[SingleHeroRelate] then
        table.insert(LogicOutsideWeapon.HeroWeaponList[SingleHeroRelate], WeaponId)
      else
        local TempTable = {WeaponId}
        LogicOutsideWeapon.HeroWeaponList[SingleHeroRelate] = TempTable
      end
    end
  end
end

function LogicOutsideWeapon.GetCurCanEquipWeaponList(HeroId)
  local AllHeroCanEquipWeaponList = LogicOutsideWeapon.GetAllCanEquipWeaponList(HeroId)
  if not AllHeroCanEquipWeaponList then
    return nil
  end
  local AllWeaponList = DataMgr.GetWeaponList()
  local TargetList = {}
  for index, SingleWeaponInfo in ipairs(AllWeaponList) do
    if table.Contain(AllHeroCanEquipWeaponList, tonumber(SingleWeaponInfo.resourceId)) then
      table.insert(TargetList, SingleWeaponInfo)
    end
  end
  return TargetList
end

function LogicOutsideWeapon.GetAllCanEquipWeaponDataList(HeroId)
  local AllHeroCanEquipWeaponList = LogicOutsideWeapon.GetAllCanEquipWeaponList(HeroId)
  if not AllHeroCanEquipWeaponList then
    return nil
  end
  local AllWeaponList = DataMgr.GetWeaponList()
  local TargetList = {}
  local idxTb = {}
  for i, v in ipairs(AllHeroCanEquipWeaponList) do
    for index, SingleWeaponInfo in ipairs(AllWeaponList) do
      if v == tonumber(SingleWeaponInfo.resourceId) then
        table.insert(TargetList, {
          WeaponData = SingleWeaponInfo,
          resourceId = SingleWeaponInfo.resourceId,
          uuid = SingleWeaponInfo.uuid
        })
        idxTb[i] = true
      end
    end
  end
  for i, v in ipairs(AllHeroCanEquipWeaponList) do
    if not idxTb[i] then
      table.insert(TargetList, {
        WeaponData = nil,
        resourceId = v,
        uuid = -1
      })
    end
  end
  return TargetList
end

function LogicOutsideWeapon.GetHeroIdByWeaponId(WeaponId)
  for heroId, v in pairs(LogicOutsideWeapon.HeroWeaponList) do
    for iWeapon, vWeapon in pairs(v) do
      if vWeapon == WeaponId then
        return heroId
      end
    end
  end
  return -1
end

function LogicOutsideWeapon.GetResStoneEquipDataByWeaponId(WeaponId)
  local AllWeaponList = DataMgr.GetWeaponList()
  local weaponInfo
  for index, SingleWeaponInfo in ipairs(AllWeaponList) do
    if SingleWeaponInfo.uuid == WeaponId then
      weaponInfo = SingleWeaponInfo
      break
    end
  end
  if weaponInfo then
    for k, v in pairs(LogicOutsideWeapon.HeroWeaponList) do
      if table.Contain(v, tonumber(weaponInfo.resourceId)) then
        return k, weaponInfo.resourceId
      end
    end
  end
  return nil, nil
end

function LogicOutsideWeapon.GetWeaponInfoByWeaponResId(WeaponResId)
  local AllWeaponList = DataMgr.GetWeaponList()
  for index, SingleWeaponInfo in ipairs(AllWeaponList) do
    if tonumber(SingleWeaponInfo.resourceId) == WeaponResId then
      return SingleWeaponInfo
    end
  end
  return nil
end

function LogicOutsideWeapon.GetAllCanEquipWeaponList(HeroId)
  if not LogicOutsideWeapon.HeroWeaponList then
    return nil
  end
  return LogicOutsideWeapon.HeroWeaponList[HeroId]
end

function LogicOutsideWeapon.RequestEquippedWeaponInfo(HeroId, callback)
  print("LogicOutsideWeapon.RequestEquippedWeaponInfo", HeroId)
  local Path = "hero/getheroequipweapon?heroId=" .. HeroId
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      print("EquippedWeaponInfo" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetEquippedWeaponList(HeroId, JsonTable.weaponlist)
      if callback then
        callback()
      end
      EventSystem.Invoke(EventDef.Lobby.EquippedWeaponInfoChanged, HeroId)
      print("LogicOutsideWeapon.RequestEquippedWeaponInfo Succ", HeroId)
    end
  }, {
    GameInstance,
    function()
      print("RequestEquippedWeaponInfo Failed", HeroId)
    end
  })
end

function LogicOutsideWeapon.RequestGetWeaponList(SuccFunc, SkinId, WeaponId)
  HttpCommunication.RequestByGet("hero/weaponlist", {
    GameInstance,
    function(Target, JsonResponse)
      print("GetWeaponList" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetWeaponList(JsonTable.weaponlist)
      EventSystem.Invoke(EventDef.Lobby.WeaponListChanged, SkinId, WeaponId)
      if SuccFunc and SuccFunc[1] and SuccFunc[2] then
        SuccFunc[2](SuccFunc[1])
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function LogicOutsideWeapon.RequestEquipWeapon(HeroId, WeaponId, SlotId, WeaponResId)
  local Param = {
    heroId = HeroId,
    uuid = WeaponId,
    slot = SlotId
  }
  local weaponResId = WeaponResId
  HttpCommunication.Request("hero/equipheroweapon", Param, {
    GameInstance,
    function()
      print("LogicOutsideWeapon.RequestEquipWeapon \232\163\133\229\164\135\230\136\144\229\138\159")
      print("LogicOutsideWeapon.RequestEquipWeapon Succ", HeroId, WeaponId, SlotId)
      EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false, 0)
      if weaponResId then
        DataMgr.UpdateEquippedWeaponList(HeroId, WeaponId, weaponResId)
        EventSystem.Invoke(EventDef.Lobby.EquippedWeaponInfoChanged, HeroId)
        print("EventDef.Lobby.EquippedWeaponInfoChanged", HeroId)
      else
        LogicOutsideWeapon.RequestEquippedWeaponInfo(HeroId)
      end
    end
  }, {
    GameInstance,
    function()
      print("LogicOutsideWeapon.RequestEquipWeapon Failed", HeroId, WeaponId, SlotId)
    end
  })
end

function LogicOutsideWeapon.RequestUnEquipWeapon(HeroId, SlotId)
  local Param = {heroId = HeroId, slot = SlotId}
  HttpCommunication.Request("hero/unequipheroweapon", Param, {
    GameInstance,
    function()
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function LogicOutsideWeapon.RequestAccessoryListToServer()
  HttpCommunication.RequestByGet("hero/accessorylist", {
    GameInstance,
    function(Target, JsonResponse)
      print("GetAccessoryList", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetAccessoryList(JsonTable.acclist)
      EventSystem.Invoke(EventDef.Lobby.AccessoryListChanged)
    end
  })
end

function LogicOutsideWeapon.GetWeaponDamage(MainBodyId, bIsBattle)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local TotalInscriptionList = {}
  local AllMainAttributeList = UE.URGBlueprintLibrary.GetOutsideWeaponAttributeList(GameInstance, false, tonumber(MainBodyId), TotalInscriptionList)
  local AllMainAttributeListTable = AllMainAttributeList:ToTable()
  for i, SingleAttributeConfig in ipairs(AllMainAttributeListTable) do
    local AttributeName = UE.URGBlueprintLibrary.GetAttributeName(SingleAttributeConfig)
    local AttributeFullName = UE.URGBlueprintLibrary.GetAttributeFullName(SingleAttributeConfig)
    if "WeaponDamageRatio" == AttributeName then
      SingleAttributeConfig.Value = LogicOutsideWeapon.GetWeaponAttributeValue(AttributeName, SingleAttributeConfig, AllMainAttributeListTable, bIsBattle)
      return SingleAttributeConfig.Value
    end
  end
end

function LogicOutsideWeapon.GetWeaponAttributeValue(TempString, AttributeConfig, AllMainAttributeListTable, bIsBattle)
  if bIsBattle then
    return LogicOutsideWeapon.SpecialBattleDealValue(TempString, AttributeConfig, AllMainAttributeListTable)
  else
    return LogicOutsideWeapon.SpecialDealValue(TempString, AttributeConfig, AllMainAttributeListTable)
  end
end

function LogicOutsideWeapon.SpecialBattleDealValue(TempString, AttributeConfig)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return AttributeConfig.Value
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return AttributeConfig.Value
  end
  local TargetValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, AttributeConfig.Attribute, nil)
  if "ReloadInterval" == TempString then
    local ReloadRatioAttribute = UE.URGBlueprintLibrary.MakeGameplayAttributeByName("EquipAttributeSet.ReloadRatio")
    local ReloadRatioValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, ReloadRatioAttribute, nil)
    TargetValue = TargetValue / ReloadRatioValue
  end
  return TargetValue
end

function LogicOutsideWeapon.SpecialDealValue(TempString, AttributeConfig, AllMainAttributeListTable)
  if "ReloadInterval" == TempString then
    for key, reloadValue in pairs(AllMainAttributeListTable) do
      if UE.URGBlueprintLibrary.GetAttributeName(reloadValue) == "ReloadRatio" then
        return AttributeConfig.value / reloadValue.Value
      end
    end
  end
  return AttributeConfig.Value
end
