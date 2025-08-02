local PandoraHandler = {}
local PandoraData = require("Modules.Pandora.PandoraData")
local rapidjson = require("rapidjson")
local PandoraGameEventType = {
  PandoraActivityPanel_OnMouseLeave = "PandoraActivityPanel_OnMouseLeave",
  PandoraActivityPanel_OnMouseEnter = "PandoraActivityPanel_OnMouseEnter"
}
_G.PandoraGameEventType = PandoraGameEventType

function PandoraHandler.ProcessProtocal(MsgType, MsgObj)
  if not MsgType then
    return
  end
  local EventName = EventDef.Pandora[MsgType]
  if EventName then
    EventSystem.Invoke(EventName, MsgObj)
  else
    print("Error: No handler found for protocol " .. MsgType)
  end
end

function PandoraHandler.SendRefreshADData(adId)
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local Params = {
    type = "panameraRefreshADData",
    IsForce = "true",
    adId = adId
  }
  local ParamStr = RapidJsonEncode(Params)
  PandoraSubsystem:SendMessageToApp("5179", ParamStr)
end

function PandoraHandler.GetUserInfoResult(content, source, roleId, appId)
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local Params = {
    type = "getUserInfoResult",
    content = RapidJsonEncode(content),
    source = source,
    roleId = roleId
  }
  local ParamStr = RapidJsonEncode(Params)
  PandoraSubsystem:SendMessageToApp(appId, ParamStr)
end

function PandoraHandler.SendGameEventToPandora(content, extend)
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local Params = {
    type = "informGameEvent",
    content = RapidJsonEncode(content),
    extend = RapidJsonEncode(extend)
  }
  local ParamStr = RapidJsonEncode(Params)
  local AppId = PandoraData:GetEventAppId()
  PandoraSubsystem:SendMessageToApp("*", ParamStr)
end

function PandoraHandler.SendMidasPayCallBack()
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local Params = {
    type = "midasSteamPayCallback",
    content = "rmb",
    appId = "",
    appName = ""
  }
  local ParamStr = RapidJsonEncode(Params)
  local AppId = PandoraData:GetPayAppId()
  PandoraSubsystem:SendMessageToApp(AppId, ParamStr)
end

function PandoraHandler.SendGetProductInfoResult(RespInfo)
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local Params = {
    type = "pandoraGetProductInfoResult",
    respInfo = RespInfo,
    appId = PandoraData:GetProductInfoAppId(),
    appName = ""
  }
  local ParamStr = RapidJsonEncode(Params)
  local AppId = PandoraData:GetProductInfoAppId()
  PandoraSubsystem:SendMessageToApp(AppId, ParamStr)
end

function PandoraHandler.SendMidasPayCallBack_WeGame(EventData)
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local Params = {
    type = "midasPayCallback",
    result = EventData,
    appId = "",
    appName = ""
  }
  local ParamStr = RapidJsonEncode(Params)
  PandoraSubsystem:SendMessageToApp("*", ParamStr)
end

function PandoraHandler.SendPandoraPayWindowClose()
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local Params = {
    type = "PandoraPayWindow_OnClose",
    appId = "",
    appName = ""
  }
  local ParamStr = RapidJsonEncode(Params)
  PandoraSubsystem:SendMessageToApp("*", ParamStr)
end

function PandoraHandler.GoPandoraActivity(Index, LinkSource)
  local Result, TBPandoraInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPandoraInfo, Index)
  if not Result then
    print("PandoraHandler.GoPandoraActivity: Failed to get TBPandoraInfo for Index: " .. tostring(Index), "Source:", LinkSource)
    return false
  end
  local LinkId = TBPandoraInfo.LinkId
  local JumpParams = TBPandoraInfo.JumpParams
  local TabId = TBPandoraInfo.TabId
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    JumpParams = TBPandoraInfo.JumpParamsIntl
    TabId = TBPandoraInfo.TabIdIntl
  end
  local Content = {
    LinkId = LinkId,
    LinkType = 1,
    bCloseCurWidget = true,
    LinkSource = LinkSource,
    Parameters = {
      {Param_Name = "TabId", Param_Value = TabId},
      {
        Param_Name = "OpenAppJumpParams",
        Param_Value = JumpParams
      }
    }
  }
  local MsgObj = {
    content = RapidJsonEncode(Content),
    appId = "-1",
    appName = "\232\183\179\232\189\172"
  }
  local PandoraModule = ModuleManager:Get("PandoraModule")
  PandoraModule:BindOnGoSystem(MsgObj)
  return true
end

function PandoraHandler.SetLoginChannel(ChannelId)
  if 1 == ChannelId or 2 == ChannelId or 3 == ChannelId then
    ChannelId = 52
  end
  if 4 == ChannelId then
    ChannelId = 53
  end
  local PandoraModule = ModuleManager:Get("PandoraModule")
  PandoraModule:AddUserData("sLoginChannel", ChannelId)
end

return PandoraHandler
