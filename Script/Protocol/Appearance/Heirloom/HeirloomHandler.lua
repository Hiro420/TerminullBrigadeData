local rapidjson = require("rapidjson")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local HeirloomHandler = {}
function HeirloomHandler:RequestGetFamilytreasureToServer(SuccFunc)
  print("HeirloomHandler:RequestGetFamilytreasureToServer")
  HttpCommunication.RequestByGet("hero/getfamilytreasure", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetFamilytreasureToServer success! ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      HeirloomData:SetUnLockHeirloomList(JsonTable.familyTreasure)
      EventSystem.Invoke(EventDef.Heirloom.OnHeirloomInfoChanged)
      if SuccFunc then
        SuccFunc()
      end
    end
  }, {
    GameInstance,
    function()
      print("RequestGetFamilytreasureToServer fail!")
    end
  })
end
function HeirloomHandler:RequestUpgradeFamilyTreasure(Id)
  if HeirloomHandler.LastRequestTime and GetCurrentUTCTimestamp() - HeirloomHandler.LastRequestTime < 1.0 then
    print("HeirloomHandler:RequestUpgradeFamilyTreasure \229\143\145\233\128\129\229\164\170\233\162\145\231\185\129")
    return
  end
  local CurHeirloomId = HeirloomData:GetCurSelectHeirloomId()
  local TargetLevel = HeirloomData:GetCurSelectLevel()
  HeirloomHandler.LastRequestTime = GetCurrentUTCTimestamp()
  HttpCommunication.Request("hero/upgradefamilytreasure", {id = Id}, {
    GameInstance,
    function()
      print("RequestUpgradeFamilyTreasure Success!")
      HeirloomHandler:RequestGetFamilytreasureToServer(function()
        EventSystem.Invoke(EventDef.Heirloom.OnHeirloomUpgradeSuccess, CurHeirloomId, TargetLevel)
      end)
    end
  }, {
    GameInstance,
    function()
      print("RequestUpgradeFamilyTreasure Fail!")
    end
  })
end
return HeirloomHandler
