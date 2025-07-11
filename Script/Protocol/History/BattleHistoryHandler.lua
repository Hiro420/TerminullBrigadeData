local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local BattleHistoryData = require("Modules.PlayerInfoMain.History.BattleHistoryData")
local BattleHistoryHandler = {}
function BattleHistoryHandler.RequestGetBattleHistory(RoleID)
  local roleID = RoleID or DataMgr.GetUserId()
  local path = string.format("record/pull/battlehistory?roleID=%s", roleID)
  HttpCommunication.RequestByGet(path, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetBattleHistory Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
      BattleHistoryData.BattleHistory[roleID] = JsonTable
      for i, v in ipairs(BattleHistoryData.BattleHistory[roleID].battleHistory) do
        for i1, v1 in ipairs(v.battleHistoryDatas) do
          local tb = rapidjson.decode(tostring(v1))
          v.battleHistoryDatas[i1] = tb
        end
      end
      for i, v in ipairs(BattleHistoryData.BattleHistory[roleID].recentBattleHistory) do
        BattleHistoryData.BattleHistory[roleID].recentBattleHistory[i] = rapidjson.decode(tostring(v))
      end
      EventSystem.Invoke(EventDef.PlayerInfo.GetBattleHistory, BattleHistoryData.BattleHistory[roleID], roleID)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
return BattleHistoryHandler
