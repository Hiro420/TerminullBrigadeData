local ProficiencyHandler = {}
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")

function ProficiencyHandler:RequestGetHeroProfyLevelRewardToServer(HeroId, ProfyLevel)
  local Params = {heroID = HeroId, profy = ProfyLevel}
  HttpCommunication.Request("hero/getheroprofylvreward", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("ProficiencyHandler:RequestGetHeroProfyLevelReward Success !")
      ProficiencyData:ShowReceiveAwardPanel(HeroId, ProfyLevel)
      LogicRole.RequestMyHeroInfoToServer()
    end
  }, {
    GameInstance,
    function()
      print("ProficiencyHandler:RequestGetHeroProfyLevelReward Fail !")
    end
  })
end

function ProficiencyHandler:RequestGetHeroProfyStoryRewardToServer(HeroId, ProfyLevel)
  local Params = {heroID = HeroId, profy = ProfyLevel}
  HttpCommunication.Request("hero/getheroprofystoryreward", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("ProficiencyHandler:RequestGetHeroProfyStoryRewardToServer Success !")
      EventSystem.Invoke(EventDef.Proficiency.OnGetHeroProfyStoryRewardSuccess)
      LogicRole.RequestMyHeroInfoToServer()
    end
  }, {
    GameInstance,
    function()
      print("ProficiencyHandler:RequestGetHeroProfyStoryRewardToServer Fail !")
    end
  })
end

return ProficiencyHandler
