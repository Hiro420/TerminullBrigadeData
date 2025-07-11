local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local RewardIncreaseHandler = {}
function RewardIncreaseHandler.RequestGetRewardIncreaseCount()
  HttpCommunication.RequestByGet("playergrowth/rewardincrease/rewardincreasecount", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetRewardIncreaseCount" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local rewardIncreaseCount = JsonTable.rewardIncreaseCount
      DataMgr.SetRewardIncreaseCount(rewardIncreaseCount)
      EventSystem.Invoke(EventDef.RewardIncrease.RewardIncreaseSucc)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end
function RewardIncreaseHandler.RequestReceiverewardIncrease()
  HttpCommunication.Request("playergrowth/rewardincrease/receiverewardincrease", {}, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestReceiverewardIncrease Succ" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for i, v in ipairs(JsonTable.resources) do
        v.extra = rapidjson.decode(v.extra)
      end
      local count = math.max(0, DataMgr.RewardIncreaseCount - 1)
      DataMgr.SetRewardIncreaseCount(count)
      EventSystem.Invoke(EventDef.RewardIncrease.ReceiveRewardIncreaseSucc, JsonTable.resources)
    end
  }, {
    GameInstance,
    function()
      print("RequestReceiverewardIncrease Failed")
      EventSystem.Invoke(EventDef.RewardIncrease.ReceiveRewardIncreaseFailed)
    end
  }, false, true)
end
return RewardIncreaseHandler
