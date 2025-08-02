local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")
local SaveGrowthSnapHandler = {}

function SaveGrowthSnapHandler.RequestGetGrowthSnapShot()
  print("SaveGrowthSnapHandler", "SaveGrowthSnapHandler.RequestGetGrowthSnapShot - \230\139\137\229\143\150\229\191\171\231\133\167\228\191\161\230\129\175")
  HttpCommunication.RequestByGet("playergrowth/growthsnapshot/getgrowthsnapshot", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetGrowthSnapShot", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      SaveGrowthSnapData.SaveGrowthSnapMap = {}
      for i, v in ipairs(JsonTable.growthSnapshotDatas) do
        local snapShotJson = rapidjson.decode(v.growthSnapshot)
        SaveGrowthSnapData.SaveGrowthSnapMap[i - 1] = {
          GrowthSnapShot = snapShotJson,
          Remark = v.remark,
          Pos = i - 1,
          SnapshotStagingTime = v.snapshotTime,
          UseTimes = v.usedTimes
        }
      end
      SaveGrowthSnapData.CurSelectPos = JsonTable.pos
      SaveGrowthSnapData.SnapshotStaging = JsonTable.snapshotStaging
      if SaveGrowthSnapData:CheckSnapMapIsEmpty() then
        SaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes = {}
      else
        local bShowTip = false
        for k, v in pairs(SaveGrowthSnapData.SaveGrowthSnapMap) do
          if 0 == SaveGrowthSnapData:GetGrowthSnapUseLeftNum(v.UseTimes) and not SaveGrowthSnapData:CheckIsEmpty(k) then
            local PosStr = tostring(k + 1)
            if not SaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes[PosStr] then
              if false == bShowTip then
                bShowTip = true
                ShowWaveWindow(1406)
              end
              SaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes[PosStr] = true
              local LobbyModule = ModuleManager:Get("LobbyModule")
              if LobbyModule then
                local Ok, Errors = pcall(LobbyModule.SaveGrowthSnapDataToLocal, LobbyModule)
                if not Ok then
                  print(" Error SaveGrowthSnapDataToLocal", Errors)
                end
              end
            end
            SaveGrowthSnapData:ResetSnapData(v)
          end
        end
      end
      EventSystem.Invoke(EventDef.SaveGrowthSnap.OnRefreshSnap)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

function SaveGrowthSnapHandler.RequestSaveGrowthSnapShot(Pos, Remark)
  local param = {
    pos = tonumber(Pos),
    remark = tostring(Remark)
  }
  local path = "playergrowth/growthsnapshot/savegrowthsnapshot"
  HttpCommunication.Request(path, param, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSaveGrowthSnapShot Succ", Pos, Remark, SaveGrowthSnapData.SnapshotStaging)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if not SaveGrowthSnapData.SaveGrowthSnapMap then
        SaveGrowthSnapData.SaveGrowthSnapMap = {}
      end
      local SnapshotStagingJson = rapidjson.decode(SaveGrowthSnapData.SnapshotStaging)
      local PosNumber = tonumber(Pos)
      local RemarkStr = tostring(Remark)
      SaveGrowthSnapData.SaveGrowthSnapMap[PosNumber] = {
        GrowthSnapShot = SnapshotStagingJson,
        Remark = RemarkStr,
        Pos = PosNumber,
        SnapshotStagingTime = JsonTable.snapshotTime,
        UseTimes = 0
      }
      SaveGrowthSnapData.SnapshotStaging = nil
      local PosStr = tostring(PosNumber + 1)
      SaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes[PosStr] = false
      EventSystem.Invoke(EventDef.SaveGrowthSnap.OnRefreshSnap, true)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

function SaveGrowthSnapHandler.RequestSetGrowthSnapShot(Pos)
  local param = {
    pos = tonumber(Pos)
  }
  local path = string.format("playergrowth/growthsnapshot/setgrowthsnapshot")
  HttpCommunication.Request(path, param, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSetGrowthSnapShot Succ", Pos)
      SaveGrowthSnapData.CurSelectPos = Pos
      EventSystem.Invoke(EventDef.SaveGrowthSnap.OnRefreshSelect)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

return SaveGrowthSnapHandler
