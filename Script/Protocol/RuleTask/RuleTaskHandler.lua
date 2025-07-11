local RuleTaskHandler = {}
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
local rapidjson = require("rapidjson")
function RuleTaskHandler:RequestGetRuleTaskDataToServer(ActivityId)
  local Path = "activity/ruletask/data?activityID=" .. ActivityId
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, Response)
      print("RuleTaskHandler:RequestGetRuleTaskDataToServer Success!", Response.Content)
      local JsonTable = rapidjson.decode(Response.Content)
      RuleTaskData:SetMainRewardState(ActivityId, JsonTable.state)
      EventSystem.Invoke(EventDef.RuleTask.OnMainRewardStateChanged)
    end
  })
end
function RuleTaskHandler:RequestReceiveRewardToServer(ActivityId)
  HttpCommunication.Request("activity/ruletask/receivereward", {activityID = ActivityId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("RuleTaskHandler:RequestReceiveRewardToServer Success!")
      RuleTaskData:SetMainRewardState(ActivityId, EMainRewardState.Received)
      EventSystem.Invoke(EventDef.RuleTask.OnMainRewardStateChanged)
    end
  })
end
function RuleTaskHandler:RequestReceiveOptionalGiftRewardToServer(ActivityId, OptionalGiftInfos)
  HttpCommunication.Request("activity/ruletask/receivereward", {activityID = ActivityId, optionalGiftInfos = OptionalGiftInfos}, {
    GameInstance,
    function(Target, JsonResponse)
      print("RuleTaskHandler:RequestReceiveRewardToServer Success!")
      RuleTaskData:SetMainRewardState(ActivityId, EMainRewardState.Received)
      EventSystem.Invoke(EventDef.RuleTask.OnMainRewardStateChanged)
    end
  })
end
return RuleTaskHandler
