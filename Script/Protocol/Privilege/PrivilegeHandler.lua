local PrivilegeHandler = {}
local rapidjson = require("rapidjson")
local PrivilegeData = require("Modules.Privilege.PrivilegeData")
function PrivilegeHandler:RequestRolesPrivilegeInfoToServer(IdList)
  local Params = {roleIDs = IdList}
  HttpCommunication.Request("playergrowth/privilege/rolesprivilegeinfo", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("PrivilegeHandler:RequestRolesSprivilegeInfoToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      PrivilegeData:SetRolePrivilegeInfo(JsonTable.rolesPrivilegeInfo)
      EventSystem.Invoke(EventDef.MonthCard.OnUpdateRolesRivilegeInfo)
    end
  })
end
return PrivilegeHandler
