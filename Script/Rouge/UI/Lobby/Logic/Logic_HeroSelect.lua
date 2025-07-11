local rapidJson = require("rapidjson")
LogicHeroSelect = LogicHeroSelect or {}
function LogicHeroSelect.Init()
  LogicHeroSelect.CloseShotHeroModel = nil
  LogicHeroSelect.IsInHeroSelection = false
  EventSystem.AddListener(nil, EventDef.WSMessage.PickHeroDone, LogicHeroSelect.BindOnPickHeroDone)
end
function LogicHeroSelect.RequestPickHeroToServer(InHeroId, SuccFunc)
  local TeamInfo = DataMgr.GetTeamInfo()
  local Param = {
    heroId = InHeroId,
    teamid = TeamInfo.teamid
  }
  HttpCommunication.Request("team/pickhero", Param, {
    GameInstance,
    function()
      print("PickHero Succ!")
      if SuccFunc then
        SuccFunc[2](SuccFunc[1])
      end
      LogicAudio.PickHero(InHeroId)
    end
  }, {
    GameInstance,
    function()
      print("PickHero Fail!")
    end
  })
end
function LogicHeroSelect.RequestPickHeroDoneToServer()
  local TeamInfo = DataMgr.GetTeamInfo()
  HttpCommunication.Request("team/pickherodone", {
    teamid = TeamInfo.teamid
  }, {
    GameInstance,
    function()
      print("PickHeroDone Succ!")
      EventSystem.Invoke(EventDef.HeroSelect.OnPickHeroStateChanged, true)
    end
  }, {
    GameInstance,
    function()
      print("PickHeroDone Fail!")
    end
  })
end
function LogicHeroSelect.RequestCancelPickHeroToServer()
  local TeamInfo = DataMgr.GetTeamInfo()
  HttpCommunication.Request("team/cancelpickhero", {
    teamid = TeamInfo.teamid
  }, {
    GameInstance,
    function()
      print("CancelPickHero Succ!")
      EventSystem.Invoke(EventDef.HeroSelect.OnPickHeroStateChanged, false)
    end
  }, {
    GameInstance,
    function()
      print("CancelPickHero Fail!")
    end
  })
end
function LogicHeroSelect.GetCloseShotHeroModel()
  if not LogicHeroSelect.CloseShotHeroModel or not LogicHeroSelect.CloseShotHeroModel:IsValid() then
    local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "CloseShotHeroSelectRole", nil)
    for i, SingleRoleActor in pairs(RoleActorList) do
      LogicHeroSelect.CloseShotHeroModel = SingleRoleActor
      break
    end
  end
  return LogicHeroSelect.CloseShotHeroModel
end
function LogicHeroSelect.GetStartTime()
  return LogicHeroSelect.StartTime
end
function LogicHeroSelect.SetStartTime(InStartTime)
  LogicHeroSelect.StartTime = InStartTime
end
function LogicHeroSelect.GetEndTime()
  return LogicHeroSelect.EndTime
end
function LogicHeroSelect.SetEndTime(InEndTime)
  LogicHeroSelect.EndTime = InEndTime
end
function LogicHeroSelect.BindOnPickHeroDone(Json)
  print("BindOnPickHeroDone")
  local JsonTable = rapidJson.decode(Json)
  DataMgr.SetTimeVelocityDifferenceByServer(JsonTable.startTime)
  LogicHeroSelect.SetStartTime(JsonTable.startTime)
  LogicHeroSelect.SetEndTime(JsonTable.endTime)
end
function LogicHeroSelect.GetCurSelectHero()
  local TeamInfo = DataMgr.GetTeamInfo()
  for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
    if SinglePlayerInfo.id == DataMgr.GetUserId() then
      return SinglePlayerInfo.pickHeroInfo.id
    end
  end
  return 0
end
function LogicHeroSelect.Clear()
  LogicHeroSelect.CloseShotHeroModel = nil
end
