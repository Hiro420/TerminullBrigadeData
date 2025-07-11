local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local AchievementData, AchievementItemData = require("Modules.Achievement.AchievementData")
local AchievementHandler = {}
function AchievementHandler.RequestGetAchievementInfo(RoleID, callback, bIsShowLoadingParam)
  local bIsShowLoading = bIsShowLoadingParam
  if nil == bIsShowLoadingParam then
    bIsShowLoading = true
  end
  local param = {}
  if RoleID then
    param = {roleID = RoleID}
  end
  HttpCommunication.Request("playergrowth/achievement/info", param, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetAchievementInfo" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local point = JsonTable.point
      local displayBadges = JsonTable.displayBadges
      if DataMgr.GetUserId() == RoleID or not DataMgr.GetUserId() then
        AchievementData.DisplayBadges = displayBadges
        AchievementData.CurAchievementPointNum = point
      end
      if callback then
        callback(displayBadges, point)
      end
      EventSystem.Invoke(EventDef.Achievement.GetAchievementInfo)
    end
  }, {
    GameInstance,
    function()
      EventSystem.Invoke(EventDef.Achievement.GetAchievementInfoFailed)
    end
  }, false, bIsShowLoading)
end
function AchievementHandler.RequestSetDisplayBadges(displayBadgesList)
  if table.IsEmpty(displayBadgesList) then
    displayBadgesList = {
      0,
      0,
      0,
      0,
      0,
      0
    }
  end
  HttpCommunication.Request("playergrowth/achievement/setdisplaybadges", {displayBadges = displayBadgesList}, {
    GameInstance,
    function()
      print("RequestSetDisplayBadges Succ")
      AchievementData.DisplayBadges = DeepCopy(displayBadgesList)
      EventSystem.Invoke(EventDef.Achievement.SetDisplayBadges)
    end
  }, {
    GameInstance,
    function()
      print("RequestSetDisplayBadges Failed")
      EventSystem.Invoke(EventDef.Achievement.SetDisplayBadgesFailed)
    end
  })
end
return AchievementHandler
