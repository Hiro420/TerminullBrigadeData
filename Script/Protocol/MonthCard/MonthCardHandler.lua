local MonthCardHandler = {}
local rapidjson = require("rapidjson")
local MonthCardData = require("Modules.MonthCard.MonthCardData")
function MonthCardHandler:RequestRolesMonthCardInfoToServer(IdList)
  local Params = {roleIDs = IdList}
  HttpCommunication.Request("playergrowth/monthcard/rolesmonthcardinfo", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("MonthCardHandler:RequestRolesMonthCardInfoToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for RoleId, SingleRoleMonthCardInfo in pairs(JsonTable.rolesMonthCardInfo) do
        MonthCardData:SetRoleMonthCardInfo(RoleId, SingleRoleMonthCardInfo.monthCardMap)
      end
      EventSystem.Invoke(EventDef.MonthCard.OnUpdateRolesMonthCardInfo, IdList)
    end
  })
end
return MonthCardHandler
