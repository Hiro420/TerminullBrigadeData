local rapidjson = require("rapidjson")
local M = {CurSelectSoulCoreId = -1}
_G.LogicSoulCore = _G.LogicSoulCore or M
local SoulCoreViewClsPath = "/Game/Rouge/UI/Lobby/SoulCore/WBP_SoulCoreView.WBP_SoulCoreView_C"

function LogicSoulCore.Init()
end

function LogicSoulCore:ShowSoulCore()
end

function LogicSoulCore:HideSelf()
end

function LogicSoulCore:GetSoulCoreList()
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if not CharacterTable then
    return nil
  end
  local CharacterTb = {}
  local Index = 1
  for i, v in pairs(CharacterTable) do
    CharacterTb[Index] = v
    Index = Index + 1
  end
  table.sort(CharacterTb, self.SoulCoreListSort)
  return CharacterTb
end

function LogicSoulCore:CheckCantEquipSoulCore(CharacterId)
  if self.CurSelectSoulCoreId == CharacterId then
    return true
  end
  return false
end

function LogicSoulCore.SoulCoreListSort(First, Second)
  if LogicRole.CheckCharacterUnlock(First.ID) and LogicRole.CheckCharacterUnlock(Second.ID) == false then
    return true
  elseif LogicRole.CheckCharacterUnlock(First.ID) == false and LogicRole.CheckCharacterUnlock(Second.ID) then
    return false
  end
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TotalResourceTable and TotalResourceTable[First.ResourceId] and TotalResourceTable[Second.ResourceId] then
    local FirstRare = TotalResourceTable[First.ResourceId].Rare
    local SecondRare = TotalResourceTable[Second.ResourceId].Rare
    if FirstRare > SecondRare then
      return true
    elseif FirstRare < SecondRare then
      return false
    end
  end
  local FirstLv = DataMgr.GetHeroLevelByHeroId(First.ID)
  local SecondLv = DataMgr.GetHeroLevelByHeroId(Second.ID)
  if FirstLv > SecondLv then
    return true
  elseif FirstLv < SecondLv then
    return false
  end
  return First.ID < Second.ID
end

function LogicSoulCore:GetCharacterTableRow(CharacterId)
  local RowInfo
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  RowInfo = CharacterTable[CharacterId]
  return RowInfo
end

function LogicSoulCore:GetHeroTableRow(ResourceId)
  local HeroTb = LuaTableMgr.GetLuaTableByName(TableNames.TBHero)
  if not HeroTb then
    return nil
  end
  return HeroTb[ResourceId]
end

function LogicSoulCore:GetHeroArtResTableRow(IdParam)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicSoulCore.GetHeroArtResTableRow not DTSubsystem")
    return nil
  end
  local Result, DTHeroArtRow = DTSubsystem:GetHeroArtResDataById(tonumber(IdParam), nil)
  if Result then
    return DTHeroArtRow
  end
  print("\233\133\141\231\189\174\229\188\130\229\184\184\239\188\140\232\175\165\231\173\137\231\186\167\229\156\168\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168", IdParam)
  return nil
end

function LogicSoulCore:DrawFailed()
end

function LogicSoulCore:GetCost(Times, PondId)
  local GachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  for i, v in ipairs(GachaPondTable[PondId].ExpendResource) do
    return v.key, v.value * Times, self:CheckCost(Times, PondId)
  end
  return 0, 0, false
end

function LogicSoulCore:CheckCost(Times, PondId)
  local NeedCostNumTb = {}
  local GachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  if GachaPondTable and GachaPondTable[PondId] then
    for i, v in ipairs(GachaPondTable[PondId].ExpendResource) do
      local ResNum = DataMgr.GetPackbackNumById(v.key)
      local NeedNum = v.value
      if not NeedCostNumTb[v.key] then
        NeedCostNumTb[v.key] = 0
      end
      if NeedCostNumTb[v.key] then
        NeedNum = NeedNum + NeedCostNumTb[v.key]
        NeedCostNumTb[v.key] = NeedNum
      end
      NeedNum = NeedNum * Times
      if ResNum < NeedNum then
        return false
      end
    end
  end
  return true
end

function LogicSoulCore:Clear()
  LogicSoulCore:HideSelf()
end
