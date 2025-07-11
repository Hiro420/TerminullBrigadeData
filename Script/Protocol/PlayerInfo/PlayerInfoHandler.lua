local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local PlayerInfoHandler = {}
function PlayerInfoHandler.RequestBattleStatistic(GameModeList, roleId)
  local roleID = roleId or DataMgr.GetUserId()
  local param = {
    gameMode = GameModeList,
    roleID = roleID,
    seasonID = 0
  }
  local path = "record/pull/battlestatistic"
  HttpCommunication.Request(path, param, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestBattleStatistic Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
      PlayerInfoData.BattleStatistic[roleID] = {}
      for k, v in pairs(JsonTable.careerData) do
        local statisticData = PlayerInfoData:NewStatisticData(v)
        if table.IsEmpty(PlayerInfoData.BattleStatistic[roleID]) then
          PlayerInfoData.BattleStatistic[roleID] = statisticData
        else
          PlayerInfoData.BattleStatistic[roleID] = PlayerInfoData.BattleStatistic[roleID] + statisticData
        end
      end
      EventSystem.Invoke(EventDef.PlayerInfo.GetBattleStatisticSucc, PlayerInfoData.BattleStatistic[roleID])
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function PlayerInfoHandler.RequestGetPortraits()
  HttpCommunication.RequestByGet("playerservice/portraits", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetPortraits Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
      PlayerInfoData.PortraitIDs = JsonTable.portraitIDs
      PlayerInfoData.PortraitData = JsonTable.portraits
      EventSystem.Invoke(EventDef.PlayerInfo.GetPortraitIds, PlayerInfoData.PortraitIDs)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function PlayerInfoHandler.RequestGetBanners()
  HttpCommunication.RequestByGet("playerservice/banners", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetBanners Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
      PlayerInfoData.BannerIDs = JsonTable.bannerIDs
      PlayerInfoData.BannerData = JsonTable.banners
      EventSystem.Invoke(EventDef.PlayerInfo.GetBannerIds, PlayerInfoData.BannerIDs)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function PlayerInfoHandler.RequestSetPortrait(PortraitID)
  HttpCommunication.Request("playerservice/portrait", {portraitID = PortraitID}, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSetPortrait Succ", JsonResponse.Content)
      DataMgr.SetPortraitId(PortraitID)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end
function PlayerInfoHandler.RequestSetNick(NickName)
  HttpCommunication.Request("playerservice/changenickname", {val = NickName}, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSetNick Succ", JsonResponse.Content)
      local Response = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetNickName(NickName)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end
function PlayerInfoHandler.RequestSetBanner(BannerId)
  HttpCommunication.Request("playerservice/banner", {bannerID = BannerId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSetBanner Succ", JsonResponse.Content)
      DataMgr.SetBannerId(BannerId)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end
function PlayerInfoHandler.RequestSetDisplayHero(HeroId, Callback)
  HttpCommunication.Request("hero/setdisplayhero", {heroID = HeroId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSetDisplayHero Succ", JsonResponse.Content)
      if Callback then
        Callback(HeroId)
      end
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end
function PlayerInfoHandler.RequestGetDisplayHeroInfo(RoleID)
  local Path = "hero/getdisplayheroinfo?roleID="
  if RoleID then
    Path = string.format("%s%s", Path, RoleID)
  end
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetDisplayHeroInfo Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
      local hero = JsonTable.hero
      local weapon = JsonTable.weapon
      if RoleID == DataMgr.GetUserId() then
        PlayerInfoData.CurShowHeroId = hero.id
      end
      EventSystem.Invoke(EventDef.PlayerInfo.GetDisplayHeroInfo, hero, weapon, RoleID)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
return PlayerInfoHandler
