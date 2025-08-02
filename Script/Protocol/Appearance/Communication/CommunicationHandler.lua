local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local CommunicationHandler = {}

function CommunicationHandler.RequestGetCommunicationBag(SuccCallback)
  print("LoginFlow", "CommunicationHandler.RequestGetCommunicationBag - \229\188\128\229\167\139\230\139\137\229\143\150\231\142\169\229\174\182\230\178\159\233\128\154\232\189\174\231\155\152\232\131\140\229\140\133\230\149\176\230\141\174")
  CommunicationData.ExpireAtData = {}
  HttpCommunication.RequestByGet("hero/getcommunicationroulette", {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local RoulleteList = {}
      for i, v in ipairs(JsonTable.commonRoulettes) do
        table.insert(RoulleteList, v.RouletteID)
        if CommunicationData.ExpireAtData[v.RouletteID] == nil then
          CommunicationData.ExpireAtData[v.RouletteID] = 0
        end
        CommunicationData.ExpireAtData[v.RouletteID] = v.expireAt
      end
      CommunicationData.HeroCommBag = RoulleteList
      EventSystem.Invoke(EventDef.Communication.OnGetCommList, RoulleteList)
      if SuccCallback then
        SuccCallback()
      end
    end
  }, {
    GameInstance,
    function()
      print("CommunicationHandler.RequestGetCommunicationBag Failed")
    end
  }, false, true)
end

function CommunicationHandler.RequestEquipCommunication(HeroId, Pos, RouletteId, SuccCallback)
  HttpCommunication.Request("hero/equipcommunicationroulette", {
    heroID = HeroId,
    pos = Pos,
    rouletteID = RouletteId
  }, {
    GameInstance,
    function()
      if SuccCallback then
        SuccCallback()
      end
    end
  }, {
    GameInstance,
    function()
      print("CommunicationHandler.RequestEquipCommunication Failed")
    end
  }, false, true)
end

function CommunicationHandler.RequestUnEquipCommunication(HeroId, Pos, SuccCallback)
  HttpCommunication.Request("hero/unequipcommunicationroulette", {heroID = HeroId, pos = Pos}, {
    GameInstance,
    function()
      if SuccCallback then
        SuccCallback()
      end
    end
  }, {
    GameInstance,
    function()
      print("CommunicationHandler.RequestEquipCommunication Failed")
    end
  }, false, true)
end

return CommunicationHandler
