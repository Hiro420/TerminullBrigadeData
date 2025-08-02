local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local GetPorpsViewModel = CreateDefaultViewModel()
local FilterItemTypeTb = {
  [TableEnums.ENUMResourceType.BattlePassToken] = true
}

function GetPorpsViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListenerNew(EventDef.Lobby.OnGetPropTip, self, self.ShowTip)
  EventSystem.AddListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
end

function GetPorpsViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  EventSystem.RemoveListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
end

function GetPorpsViewModel:OnResourceUpdate(JsonStr)
  local JsonTable = rapidjson.decode(JsonStr)
  if JsonTable.resources then
    local PropInfoList = {}
    self:InvokeResourceUpdate(JsonTable.resources)
    for index, value in ipairs(JsonTable.resources) do
      local ResourceId = tonumber(value.id)
      if not self:CheckReason(value.reason) then
      elseif not self:CheckType(ResourceId) then
      else
        local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBInfiniteProp, ResourceId)
        if result and row.unlockTaskId > 0 and GetCurSceneStatus() ~= UE.ESceneStatus.ELobby then
        else
          local SinglePropInfo = {}
          SinglePropInfo.Id = tonumber(value.id)
          SinglePropInfo.Num = value.amount
          SinglePropInfo.extra = rapidjson.decode(value.extra)
          SinglePropInfo.ExchangedAmount = value.ExchangedAmount
          SinglePropInfo.expireAt = value.expireAt
          SinglePropInfo.ExchangedResources = value.exchangedResources
          SinglePropInfo.TimeLimitedGiftId = value.timeLimitedGiftID
          table.insert(PropInfoList, SinglePropInfo)
        end
      end
    end
    if table.count(PropInfoList) > 0 then
      self:ShowTip(PropInfoList)
    end
  end
end

function GetPorpsViewModel:IsInscription(Id)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if ResourceTable and ResourceTable[tonumber(Id)] then
    return 18 == ResourceTable[tonumber(Id)].Type
  end
end

function GetPorpsViewModel:CheckReason(Reason)
  local ReasonTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGetPropsReason)
  if ReasonTable and ReasonTable[Reason] and 1 == ReasonTable[Reason].IsShow then
    return true
  end
  return false
end

function GetPorpsViewModel:CheckType(ResourceId)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if result and FilterItemTypeTb[row.Type] then
    return false
  end
  return true
end

function GetPorpsViewModel:InvokeResourceUpdate(PropInfoList)
  local ResourceTypeTable = {}
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  for index, value in ipairs(PropInfoList) do
    if ResourceTable and ResourceTable[tonumber(value.id)] and not table.Contain(ResourceTypeTable, ResourceTable[tonumber(value.id)].Type) then
      table.insert(ResourceTypeTable, ResourceTable[tonumber(value.id)].Type)
      print("InvokeResourceUpdate", ResourceTable[tonumber(value.id)].Type)
      EventSystem.Invoke(EventDef.Lobby.UpdateResourceInfoByType, ResourceTable[tonumber(value.id)].Type)
    end
  end
end

function GetPorpsViewModel:ShowTip(PropInfoList, CloseCallback)
  local Widget = UIMgr:Show(ViewID.UI_Common_GetProps)
  local ObjCls = UE.UClass.Load("/Game/Rouge/UI/Common/BP_GetPropData.BP_GetPropData_C")
  if Widget then
    Widget:SetCloseCallback(CloseCallback)
    Widget.PropList:ClearListItems()
    for key, SinglePropInfo in pairs(PropInfoList) do
      local DataObj = NewObject(ObjCls, GameInstance, nil)
      DataObj.PropId = SinglePropInfo.Id
      DataObj.PropNum = SinglePropInfo.Num
      DataObj.IsInscription = SinglePropInfo.IsInscription
      DataObj.extra = SinglePropInfo.extra
      DataObj.ExchangedAmount = SinglePropInfo.ExchangedAmount
      DataObj.ParentView = Widget
      DataObj.expireAt = SinglePropInfo.expireAt
      DataObj.ExchangedResources = SinglePropInfo.ExchangedResources
      DataObj.TimeLimitedGiftId = SinglePropInfo.TimeLimitedGiftId
      Widget.PropList:AddItem(DataObj)
    end
  end
end

return GetPorpsViewModel
