local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local IllustratedGuideHandler = {}

function IllustratedGuideHandler.RequestGetOwnedSpecificModifyListFromServer()
  HttpCommunication.Request("resource/pullinfiniteproppack", {infinitePropType = 1}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      print("resource/pullinfiniteproppack Success ", JsonTable)
      local OwnedSpecificModifyList = {}
      for k, v in pairs(JsonTable.infiniteProps) do
        table.insert(OwnedSpecificModifyList, v.ID)
      end
      UIModelMgr:Get("IllustratedGuideSpecificModifyViewModel"):SetOwnedSpecificModifyList(OwnedSpecificModifyList)
      EventSystem.Invoke(EventDef.IllustratedGuide.OnUpdateAllSpecificModifyInfo, OwnedSpecificModifyList)
    end
  }, {
    GameInstance,
    function(Error)
      print("resource/pullinfiniteproppack Error", Error.ErrorCode, Error.ErrorMessage)
    end
  })
end

return IllustratedGuideHandler
