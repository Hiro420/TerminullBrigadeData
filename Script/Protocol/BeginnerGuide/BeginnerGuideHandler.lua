local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local BeginnerGuideHandler = {}
function BeginnerGuideHandler.RequestGetFinishedGuideListFromServer(SuccCallback, FailCallback)
  HttpCommunication.Request("playergrowth/freshmanguide/pulldata", {}, {
    GameInstance,
    function(Target, JsonResponse)
      print("BeginnerGuideHandler.RequestGetFinishedGuideListFromServer freshmanguide/pulldata Success ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      BeginnerGuideData.FinishedGuideList = JsonTable.guideInfoList
      BeginnerGuideData.FreshmanBDFinished = JsonTable.freshmanBDFinished
      EventSystem.Invoke(EventDef.BeginnerGuide.OnGetFinishedGuideList, JsonTable)
      if SuccCallback then
        SuccCallback[2](SuccCallback[1], JsonResponse.Content)
      end
    end
  }, {
    GameInstance,
    function(Error)
      print("freshmanguide/pulldata Error", Error.ErrorCode, Error.ErrorMessage)
      if FailCallback then
        FailCallback[2](FailCallback[1])
      end
    end
  })
end
function BeginnerGuideHandler.RequestFinishGuideToServer(GuideId, SuccCallback)
  HttpCommunication.Request("playergrowth/freshmanguide/finishfreshmanguide", {guideID = GuideId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("freshmanguide/finishfreshmanguide Success ", JsonResponse.Content)
      if SuccCallback and SuccCallback[1] and SuccCallback[2] then
        SuccCallback[2](SuccCallback[1])
      end
    end
  }, {
    GameInstance,
    function(Error)
      print("freshmanguide/finishfreshmanguide Error", Error.ErrorCode, Error.ErrorMessage)
    end
  })
end
return BeginnerGuideHandler
