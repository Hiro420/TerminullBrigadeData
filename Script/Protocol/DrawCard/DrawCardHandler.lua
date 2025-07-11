local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local DrawCardData = require("Modules.DrawCard.DrawCardData")
local DrawCardHandler = {}
local RequestingList = {}
function DrawCardHandler.RequestGetCardPoolListFromServer(CallBack)
  if RequestingList["mallservice/gachainfo"] then
    print("mallservice/gachainfo is requesting")
    return
  end
  RequestingList["mallservice/gachainfo"] = true
  HttpCommunication.RequestByGet("mallservice/gachainfo", {
    GameInstance,
    function(Target, JsonResponse)
      print("mallservice/gachainfo Success ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for _, PoolInfo in pairs(JsonTable.GachaList) do
        DrawCardData:SetCardPoolOpenCount(PoolInfo.RewardPondID, PoolInfo.TotalGachaTimes)
        DrawCardData:SetCardPoolGuarantList(PoolInfo.RewardPondID, PoolInfo.SafeguardList)
      end
      if CallBack then
        CallBack(JsonTable.GachaList)
      end
      RequestingList["mallservice/gachainfo"] = nil
    end
  }, {
    GameInstance,
    function(Error)
      print("mallservice/gachainfo Error", Error.ErrorCode, Error.ErrorMessage)
      EventSystem.Invoke(EventDef.DrawCard.OnGetCardPoolList, nil)
      RequestingList["mallservice/gachainfo"] = nil
    end
  })
end
function DrawCardHandler.RequestDrawCardToServer(PondId, DrawTimes)
  if RequestingList["mallservice/dogacha"] then
    print("mallservice/dogacha is requesting")
    return
  end
  RequestingList["mallservice/dogacha"] = true
  HttpCommunication.Request("mallservice/dogacha", {pondId = PondId, times = DrawTimes}, {
    GameInstance,
    function(Target, JsonResponse)
      print("mallservice/dogacha Success", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.DrawCard.OnGetDrawCardResult, JsonTable)
      RequestingList["mallservice/dogacha"] = nil
    end
  }, {
    GameInstance,
    function(Error)
      print("mallservice/dogacha Error", Error.ErrorCode, Error.ErrorMessage)
      RequestingList["mallservice/dogacha"] = nil
      EventSystem.Invoke(EventDef.DrawCard.OnGetDrawCardResult, nil)
    end
  })
end
return DrawCardHandler
