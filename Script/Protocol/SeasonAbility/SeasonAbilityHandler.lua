local rapidjson = require("rapidjson")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityHandler = {}
local SeasonId = 1
local GetCurSeasonId = function(...)
  return SeasonId
end
function SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(HeroId)
  local Path = string.format("playergrowth/seasonability/seasonability?seasonID=%d&heroID=%d", GetCurSeasonId(), HeroId)
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      print("SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      SeasonAbilityData:SetSeasonAbilityInfo(HeroId, JsonTable)
      SeasonAbilityData:ResetPreAbilityInfo()
      EventSystem.Invoke(EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated, HeroId)
    end
  })
end
function SeasonAbilityHandler:RequestUpgradeSeasonAbilityToServer(HeroId, SchemeId, AbilitiesList)
  local ExchangeAbilitiesList = SeasonAbilityData:SortUpgradeAbilityList(AbilitiesList)
  local Params = {
    abilities = ExchangeAbilitiesList,
    heroID = HeroId,
    schemeID = SchemeId,
    seasonID = GetCurSeasonId()
  }
  HttpCommunication.Request("playergrowth/seasonability/upgradeseasonability", Params, {
    GameInstance,
    function()
      print("SeasonAbilityHandler:RequestUpgradeSeasonAbilityToServer Success!")
      SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(HeroId)
      SeasonAbilityHandler:RequestGetSpecialAbilityInfoToServer()
    end
  })
end
function SeasonAbilityHandler:RequestResetSeasonAbilityToServer(HeroId)
  local Params = {
    heroID = HeroId,
    seasonID = GetCurSeasonId()
  }
  HttpCommunication.Request("playergrowth/seasonability/resetseasonability", Params, {
    GameInstance,
    function()
      print("SeasonAbilityHandler:RequestResetSeasonAbilityToServer Success!")
      SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(HeroId)
      SeasonAbilityHandler:RequestGetSpecialAbilityInfoToServer()
      EventSystem.Invoke(EventDef.SeasonAbility.OnResetSeasonAbilitySuccess)
    end
  })
end
function SeasonAbilityHandler:RequestGetHeroesSeasonAbilityPointNumToServer(HeroIdList)
  if not HeroIdList[1] then
    return
  end
  local PathParam = string.format("heroIDs=%d", HeroIdList[1])
  for i = 2, table.count(HeroIdList) do
    PathParam = string.format("%s&%d", PathParam, HeroIdList[i])
  end
  local Path = string.format("playergrowth/seasonability/herosseasonabilitypointnum?%s", PathParam)
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      print("SeasonAbilityHandler:RequestGetHeroesSeasonAbilityPointNumToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      SeasonAbilityData:SetHeroAbilityPointNumList(JsonTable.herosPointNum)
      EventSystem.Invoke(EventDef.SeasonAbility.OnHeroesSeasonAbilityPointNumUpdated)
    end
  })
end
function SeasonAbilityHandler:RequestExchangeAbilityPointToServer(HeroId, ExchangeNum, SuccCallback)
  local Params = {
    exchangeNum = ExchangeNum,
    heroID = HeroId,
    seasonID = GetCurSeasonId()
  }
  HttpCommunication.Request("playergrowth/seasonability/exchangeabilitypoint", Params, {
    GameInstance,
    function()
      print("SeasonAbilityHandler:RequestExchangeAbilityPointToServer Success!")
      if SuccCallback then
        SuccCallback[2](SuccCallback[1])
      else
        SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(HeroId)
      end
    end
  })
end
function SeasonAbilityHandler:RequestGetSpecialAbilityInfoToServer(...)
  local LastSpecialAbilityPoint = SeasonAbilityData:GetSpecialAbilityCurrentMaxPointNum()
  HttpCommunication.RequestByGet("playergrowth/seasonability/specialability", {
    GameInstance,
    function(Target, JsonResponse)
      print("SeasonAbilityHandler:RequestGetSpecialAbilityInfoToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      SeasonAbilityData:SetSpecialAbilityInfo(JsonTable)
      local CurSpecialAbilityPoint = SeasonAbilityData:GetSpecialAbilityCurrentMaxPointNum()
      EventSystem.Invoke(EventDef.SeasonAbility.OnSpecialAbilityInfoUpdated)
      EventSystem.Invoke(EventDef.SeasonAbility.OnAddSpecialAbilityPoint, CurSpecialAbilityPoint - LastSpecialAbilityPoint)
    end
  })
end
function SeasonAbilityHandler:RequestActivateSpecialAbilityToServer(SpecialAbilityId)
  local Params = {specialAbilityID = SpecialAbilityId}
  HttpCommunication.Request("playergrowth/seasonability/activatespecialability", Params, {
    GameInstance,
    function()
      print("SeasonAbilityHandler:RequestActivateSpecialAbilityToServer Success!")
      SeasonAbilityHandler:RequestGetSpecialAbilityInfoToServer()
      UIMgr:Show(ViewID.UI_SpecialAbilityActivatedPanel, false, SpecialAbilityId)
    end
  })
end
function SeasonAbilityHandler:RequestUnlockSchemeToServer(HeroId)
  local Params = {
    roleID = DataMgr.GetUserId(),
    seasonID = GetCurSeasonId()
  }
  HttpCommunication.Request("playergrowth/seasonability/unlockscheme", Params, {
    GameInstance,
    function()
      print("SeasonAbilityHandler:RequestUnlockSchemeToServer Success!")
      SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(HeroId)
    end
  })
end
function SeasonAbilityHandler:RequestRenameSchemeToServer(HeroId, SchemeId, SchemeName)
  local Params = {
    heroID = HeroId,
    schemeID = SchemeId,
    schemeName = SchemeName,
    seasonID = GetCurSeasonId()
  }
  HttpCommunication.Request("playergrowth/seasonability/renamescheme", Params, {
    GameInstance,
    function()
      print("SeasonAbilityHandler:RequestRenameSchemeToServer Success!")
      SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(HeroId)
    end
  })
end
function SeasonAbilityHandler:RequestEquipSchemeToServer(HeroId, SchemeId)
  local Params = {
    heroID = HeroId,
    schemeID = SchemeId,
    seasonID = GetCurSeasonId()
  }
  HttpCommunication.Request("playergrowth/seasonability/equipscheme", Params, {
    GameInstance,
    function()
      print("SeasonAbilityHandler:RequestEquipSchemeToServer Success!")
      EventSystem.Invoke(EventDef.SeasonAbility.OnChangeEquipScheme)
      SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(HeroId)
    end
  })
end
return SeasonAbilityHandler
