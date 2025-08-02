local PandoraModule = LuaClass()
local rapidjson = require("rapidjson")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local PandoraData = require("Modules.Pandora.PandoraData")
local RedDotData = require("Modules.RedDot.RedDotData")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local EAppPage = {
  Index = "index",
  Menu = "secondMenu",
  Popup = "popup"
}
_G.EAppPage = EAppPage

function PandoraModule:Ctor()
end

function PandoraModule:OnInit()
  if not UE.URGPandoraSubsystem then
    return
  end
  print("PandoraModule:OnInit...........")
  PandoraModule.AppWidgetPool = {}
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if PandoraSubsystem and PandoraSubsystem.bOpened then
    self:BindOnPandoraOpened()
  end
  ListenObjectMessage(nil, GMP.MSG_UI_Pandora_Opened, GameInstance, PandoraModule.BindOnPandoraOpened)
  ListenObjectMessage(nil, GMP.MSG_UI_Pandora_Closed, GameInstance, PandoraModule.BindOnPandoraClosed)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraShowEntrance, self.BindOnShowEntrance)
  EventSystem.AddListener(self, EventDef.Pandora.panameraADPositionReady, self.BindOnADPositionReady)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraOpenUrl, self.BindOnOpenUrl)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraGoSystem, self.BindOnGoSystem)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraShowRedpoint, self.BindOnShowRedpoint)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraGoPandora, self.BindPandoraGoPandora)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraShowItemTip, self.BindPandoraShowItemTip)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraActCenterRedpoint, self.BindPandoraActCenterRedpoint)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraActCenterReady, self.BindPandoraActCenterReady)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraShowTextTip, self.BindPandoraShowTextTip)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraGetUserInfo, self.BindpandoraGetUserInfo)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraActTabReady, self.BindOnPandoraActTabReady)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraCloseApp, self.BindOnPandoraCloseApp)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraCopyMessageToClipboard, self.BindPandoraCopyMessageToClipboard)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraMidasPay, self.BindPandoraMidasPay)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraGetProductInfo, self.BindPandoraGetProductInfo)
  EventSystem.AddListener(self, "OnViewShow_UI_LobbyMain", self.OnShowLobbyMain)
  EventSystem.AddListener(self, EventDef.BeginnerGuide.OnBeginnerGuideFinished, self.BindOnBeginnerMissionFinished)
  PandoraModule.TipsWidget = nil
end

function PandoraModule:BindPandoraShowItemTip(MsgObj)
  print("PandoraModule:BindPandoraShowItemTip MsgObj:", MsgObj)
  local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonItemDetail.WBP_CommonItemDetail_C"
  if MsgObj.mouseEvent == "enter" then
    if MsgObj.content then
      if PandoraModule.TipsWidget then
        UpdateVisibility(PandoraModule.TipsWidget)
      end
      PandoraModule.TipsWidget = ShowCommonTipsForPos(nil, nil, WidgetClassPath)
      PandoraModule.TipsWidget:InitCommonItemDetail(tonumber(MsgObj.content))
    elseif PandoraModule.TipsWidget then
      UpdateVisibility(PandoraModule.TipsWidget)
    end
  elseif MsgObj.mouseEvent == "move" then
    if PandoraModule.TipsWidget then
      PandoraModule.TipsWidget = ShowCommonTipsForPos(nil, PandoraModule.TipsWidget, WidgetClassPath, nil)
    end
  elseif MsgObj.mouseEvent == "leave" then
    UpdateVisibility(PandoraModule.TipsWidget)
  end
end

function PandoraModule:BindpandoraGetUserInfo(MsgObj)
  print("PandoraModule:BindpandoraGetUserInfo MsgObj:", MsgObj.content)
  DataMgr.GetOrQueryPlayerInfo({
    MsgObj.roleId
  }, false, function(PlayerInfoList)
    local PlayerInfo
    for i, SingleInfo in ipairs(PlayerInfoList) do
      if SingleInfo.playerInfo.roleid == MsgObj.roleId then
        PlayerInfo = SingleInfo.playerInfo
        break
      end
    end
    if PlayerInfo then
      local content = self:ConstructUserInfo(PlayerInfo, MsgObj.content)
      PandoraHandler.GetUserInfoResult(content, MsgObj.source, MsgObj.roleId, MsgObj.appId)
    end
  end)
end

function PandoraModule:ConstructUserInfo(PlayerInfo, content)
  local KeyDict = {
    AccountName = PlayerInfo.nickname,
    OldLevel = PlayerInfo.level
  }
  local FinalData = {}
  local NeedKeyDict = Split(content, ",")
  for key, value in pairs(NeedKeyDict) do
    if KeyDict[value] then
      FinalData[value] = KeyDict[value]
    end
  end
  return FinalData
end

function PandoraModule:BindPandoraActCenterRedpoint(MsgObj)
  local RedDotId = "Activity_TabList_" .. MsgObj.appId
  print("PandoraModule:BindPandoraActCenterRedpoint MsgObj:", RedDotId, MsgObj.content)
  local IsNewCreate = RedDotData:CreateRedDotState(RedDotId, "Activity_TabList")
  local RedDotState = {}
  RedDotState.Num = MsgObj.content
  RedDotData:UpdateRedDotState(RedDotId, RedDotState)
end

function PandoraModule:BindPandoraActCenterReady(MsgObj)
  print("PandoraModule:BindPandoraActCenterReady MsgObj:", MsgObj.appId, MsgObj.iconName)
  table.Print(MsgObj)
  if PandoraModule.ActivityInfo == nil then
    PandoraModule.ActivityInfo = {}
  end
  PandoraModule.ActivityInfo[MsgObj.appId] = MsgObj
  local RedDotId = "Activity_TabList_" .. MsgObj.appId
  local IsNewCreate = RedDotData:CreateRedDotState(RedDotId, "Activity_TabList")
  local RedDotState = {}
  RedDotState.Num = tonumber(MsgObj.redPoint)
  RedDotData:UpdateRedDotState(RedDotId, RedDotState)
  if 2 == MsgObj.state then
    local Pandora = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGPandoraSubsystem:StaticClass())
    if Pandora then
      Pandora:CloseApp(MsgObj.appId)
      PandoraModule.ActivityInfo[MsgObj.appId] = {}
    end
  end
  EventSystem.Invoke(EventDef.Activity.OnPandoraActivityRefresh, MsgObj.appId)
end

function PandoraModule:BindPandoraShowTextTip(MsgObj)
  print("PandoraModule:BindPandoraShowTextTip MsgObj:", MsgObj.content)
  if MsgObj and MsgObj.content then
    ShowWaveWindow(100001, {
      MsgObj.content
    })
  end
end

function PandoraModule:BindOnPandoraActTabReady(MsgObj)
  local IsNewCreate = RedDotData:CreateRedDotState(tonumber(MsgObj.appId), "Activity_Tab")
  local RedDotState = {}
  RedDotState.Num = tonumber(MsgObj.redPoint)
  RedDotData:UpdateRedDotState(tonumber(MsgObj.appId), RedDotState)
  if not PandoraModule.ActivityTabInfo then
    PandoraModule.ActivityTabInfo = {}
  end
  for i, v in ipairs(PandoraModule.ActivityTabInfo) do
    if v.appId == MsgObj.appId then
      PandoraModule.ActivityTabInfo[i] = MsgObj
      EventSystem.Invoke(EventDef.Activity.OnPandoraRefreshActivitiesTab, true)
      print("PandoraModule:BindOnPandoraActTabReady \229\136\183\230\150\176")
      return
    end
  end
  table.insert(PandoraModule.ActivityTabInfo, MsgObj)
  table.sort(PandoraModule.ActivityTabInfo, function(a, b)
    if a.sortPriority == b.sortPriority then
      return a.appId < b.appId
    end
    return a.sortPriority < b.sortPriority
  end)
  print("PandoraModule:BindOnPandoraActTabReady")
  EventSystem.Invoke(EventDef.Activity.OnPandoraRefreshActivitiesTab)
end

function PandoraModule:BindOnPandoraCloseApp(MsgObj)
  print("PandoraModule:BindOnPandoraCloseApp", MsgObj)
  local Pandora = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if Pandora then
    if PandoraModule.ActivityTabInfo ~= nil then
      for index, value in ipairs(PandoraModule.ActivityTabInfo) do
        if value.appId == MsgObj.targetAppId then
          PandoraModule.ActivityTabInfo[index] = nil
          EventSystem.Invoke(EventDef.Activity.OnPandoraRefreshActivitiesTab)
          return
        end
      end
    end
    Pandora:CloseApp(MsgObj.targetAppId)
  end
end

function PandoraModule:BindOnPandoraOpened()
  print("PandoraModule:BindOnPandoraOpened...........")
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if PandoraSubsystem then
    PandoraSubsystem.PandoraSDKMessageDelegate:Add(GameInstance, PandoraModule.OnSDKMessage)
    PandoraSubsystem.OnPandoraWidgetCreated:Add(GameInstance, PandoraModule.BindOnPandoraWidgetCreated)
    PandoraSubsystem.OnPandoraWidgetAboutToDestroy:Add(GameInstance, PandoraModule.BindOnPandoraWidgetAboutToDestroy)
    PandoraSubsystem.OnPandoraPaySuccess:Add(GameInstance, PandoraModule.BindOnPandoraPaySuccess)
    PandoraSubsystem.OnPandoraPayWindowClose:Add(GameInstance, PandoraModule.BindOnPandoraPayWindowClose)
  end
end

function PandoraModule:BindOnPandoraClosed()
  print("PandoraModule:BindOnPandoraClosed...........")
  local PandoraSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if PandoraSubsystem then
    PandoraSubsystem.PandoraSDKMessageDelegate:Clear()
    PandoraSubsystem.OnPandoraWidgetCreated:Remove(GameInstance, PandoraModule.BindOnPandoraWidgetCreated)
    PandoraSubsystem.OnPandoraWidgetAboutToDestroy:Remove(GameInstance, PandoraModule.BindOnPandoraWidgetAboutToDestroy)
    PandoraSubsystem.OnPandoraPaySuccess:Remove(GameInstance, PandoraModule.BindOnPandoraPaySuccess)
    PandoraSubsystem.OnPandoraPayWindowClose:Remove(GameInstance, PandoraModule.BindOnPandoraPayWindowClose)
  end
end

function PandoraModule:BindOnPandoraPaySuccess(MsgObj)
  PandoraHandler.SendMidasPayCallBack_WeGame(MsgObj)
end

function PandoraModule:BindOnPandoraPayWindowClose()
  PandoraHandler.SendPandoraPayWindowClose()
end

function PandoraModule:BindPandoraCopyMessageToClipboard(MsgObj)
  print("PandoraModule:BindPandoraCopyMessageToClipboard", MsgObj.content)
  UE.URGBlueprintLibrary.CopyMessageToClipboard(MsgObj.content)
end

function PandoraModule:BindPandoraMidasPay(MsgObj)
  print("PandoraModule:BindPandoraMidasPay", MsgObj.appId, MsgObj.payInfo)
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    print("PandoraModule:BindPandoraMidasPay \230\181\183\229\164\150", MsgObj.appId, MsgObj.payInfo)
    UE.URGPlatformFunctionLibrary.CTIPay(MsgObj.payInfo)
    PandoraModule:BindCTIPayCallback()
  else
    print("PandoraModule:BindPandoraMidasPay \229\155\189\229\134\133", MsgObj.appId)
    local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
    if PandorSubsystem then
      PandorSubsystem:AsyncCreateBrowser(MsgObj.payUrl, 800, 800)
    end
  end
end

function PandoraModule:OnPayClose()
  print("PandoraModule:OnPayClose")
  PandoraHandler.SendMidasPayCallBack()
end

function PandoraModule:BindCTIPayCallback()
  local PlatformSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlatformCommonSubsystemBase:StaticClass())
  if PlatformSubsystem then
    PlatformSubsystem.OnCtiPurchasePayCallback:Add(GameInstance, PandoraModule.BindOnPurchaseProductsResponseDelegate)
  end
end

function PandoraModule:BindOnPurchaseProductsResponseDelegate(Result)
  local PlatformSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlatformCommonSubsystemBase:StaticClass())
  if PlatformSubsystem then
    PlatformSubsystem.OnCtiPurchasePayCallback:Remove(GameInstance, PandoraModule.BindOnPurchaseProductsResponseDelegate)
  end
  PandoraModule:OnPayClose()
end

function PandoraModule:BindPandoraGetProductInfo(MsgObj)
  print("PandoraModule:BindPandoraGetProductInfo", MsgObj.unifiedProductIds, MsgObj.appid)
  UE.URGPlatformFunctionLibrary.CTIGetProductInfo(Split(MsgObj.unifiedProductIds, ","))
  local PlatformSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlatformCommonSubsystemBase:StaticClass())
  if PlatformSubsystem then
    PlatformSubsystem.OnCtiGetProductInfoCallback:Add(GameInstance, PandoraModule.BindOnGetProductInfoCallback)
  end
end

function PandoraModule:BindOnGetProductInfoCallback(RetCode, ProductInfo)
  local PlatformSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlatformCommonSubsystemBase:StaticClass())
  if PlatformSubsystem then
    PlatformSubsystem.OnCtiGetProductInfoCallback:Remove(GameInstance, PandoraModule.BindOnGetProductInfoCallback)
  end
  PandoraHandler.SendGetProductInfoResult(ProductInfo)
end

function PandoraModule:OnSDKMessage(Message)
  print("PandoraModule:OnSDKMessage", Message)
  local MsgObj = rapidjson.decode(Message)
  PandoraHandler.ProcessProtocal(MsgObj.type, MsgObj)
end

function PandoraModule:BindOnPandoraWidgetCreated(Widget, AppId, AppInfo)
  local MsgObj = rapidjson.decode(AppInfo)
  print("PandoraModule:BindOnPandoraWidgetCreated", Widget, AppId, MsgObj.appPage)
  local CarouselImageAppId = PandoraData:GetCarouselImageAppId()
  local TreasureAppId = PandoraData:GetTreasureAppId()
  if AppId == TreasureAppId or AppId == CarouselImageAppId then
    EventSystem.Invoke(EventDef.Pandora.pandoraWidgetCreated, Widget, AppId)
    return
  end
  if PandoraData:ShowPandoraPanle(AppId) then
    UIMgr:Show(ViewID.UI_PandoraRootPanel, false, Widget, AppId, MsgObj.appPage)
  else
    local WidgetPanel = {}
    if MsgObj.windowConfig == nil or nil == MsgObj.windowConfig.parameter or nil == MsgObj.windowConfig.parameter.containerType or 0 == MsgObj.windowConfig.parameter.containerType then
      WidgetPanel = UIMgr:Show(ViewID.UI_PandoraActivityPanel, false, AppId)
    elseif 1 == MsgObj.windowConfig.parameter.containerType then
      WidgetPanel = UIMgr:Show(ViewID.UI_PandoraActivityPanel_Menu, false, AppId)
    elseif 2 == MsgObj.windowConfig.parameter.containerType then
      WidgetPanel = UIMgr:Show(ViewID.UI_PandoraActivityPanel_Popup, false, AppId)
      WidgetPanel:SetEnhancedInputActionBlocking(true)
    end
    WidgetPanel:OnWidgetCreated(Widget, AppId, EAppPage.Index)
  end
end

function PandoraModule:BindOnPandoraWidgetAboutToDestroy(Widget, AppId, AppInfo)
  print("PandoraModule:OnPandoraWidgetAboutToDestroy")
  local MsgObj = rapidjson.decode(AppInfo)
  PandoraModule.AppWidgetPool[AppId] = nil
  if "7479" == AppId or "7485" == AppId then
    EventSystem.Invoke(EventDef.Pandora.pandoraWidgetDestroy, Widget, AppId)
    return
  end
  if PandoraData:ShowPandoraPanle(AppId) then
    UIMgr:Hide(ViewID.UI_PandoraRootPanel)
  elseif nil == MsgObj.windowConfig or nil == MsgObj.windowConfig.parameter or nil == MsgObj.windowConfig.parameter.containerType or 0 == MsgObj.windowConfig.parameter.containerType then
    UIMgr:Hide(ViewID.UI_PandoraActivityPanel)
  elseif 1 == MsgObj.windowConfig.parameter.containerType then
    UIMgr:Hide(ViewID.UI_PandoraActivityPanel_Menu)
  elseif 2 == MsgObj.windowConfig.parameter.containerType then
    UIMgr:Hide(ViewID.UI_PandoraActivityPanel_Popup)
  end
end

function PandoraModule:BindOnShowEntrance(MsgObj)
  print("pandoraShowEntrance:", MsgObj.appId, MsgObj.appName)
end

function PandoraModule:BindOnADPositionReady(MsgObj)
  print("BindOnADPositionReady:", MsgObj.adId, MsgObj.openAppId, MsgObj.openAppName, MsgObj.materialCount, MsgObj.appId, MsgObj.appName)
  local AdInfo = {
    AdId = MsgObj.adId,
    OpenAppId = MsgObj.openAppId,
    OpenAppName = MsgObj.openAppName,
    MaterialCount = MsgObj.materialCount,
    AppId = MsgObj.appId,
    AppName = MsgObj.appName
  }
  PandoraData:AddAdInfo(MsgObj.adId, AdInfo)
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if PandorSubsystem and PandoraData:IsDisruptiveUI(MsgObj.openAppId) then
    local LobbyModule = ModuleManager:Get("LobbyModule")
    print("panameraADPositionReady", LobbyModule:CheckCanShowQueueView(), not BeginnerGuideData:GetNowGuide())
    table.Print(BeginnerGuideData:GetNowGuide())
    if LobbyModule:CheckCanShowQueueView() and not BeginnerGuideData:GetNowGuide() then
      return PandorSubsystem:OpenApp(MsgObj.openAppId, "BindOnADPositionReady")
    else
      table.insert(PandoraData.DisruptiveUI, MsgObj.openAppId)
    end
  end
  EventSystem.Invoke(EventDef.Pandora.NotifyPandoraADPositionReady)
end

function PandoraModule:BindOnOpenUrl(MsgObj)
  print("pandoraOpenUrl:", MsgObj.content, MsgObj.urlType, MsgObj.appId, MsgObj.appName)
  if MsgObj.urlType == "1" then
    UIMgr:Show(ViewID.UI_WebBrowserView, false, MsgObj.content)
  elseif MsgObj.urlType == "2" then
    UE.UKismetSystemLibrary.LaunchURL(MsgObj.content)
  end
end

function PandoraModule:BindOnGoSystem(MsgObj)
  print("pandoraGoSystem:", MsgObj.content, MsgObj.appId, MsgObj.appName)
  local JsonTable = rapidjson.decode(MsgObj.content)
  if JsonTable then
    local Param1, Param2, Param3, Param4, Param5
    Param1 = Param1 or JsonTable.Parameters[1] and JsonTable.Parameters[1].Param_Value
    Param2 = Param2 or JsonTable.Parameters[2] and JsonTable.Parameters[2].Param_Value
    Param3 = Param3 or JsonTable.Parameters[3] and JsonTable.Parameters[3].Param_Value
    Param4 = Param4 or JsonTable.Parameters[4] and JsonTable.Parameters[4].Param_Value
    Param5 = Param5 or JsonTable.Parameters[5] and JsonTable.Parameters[5].Param_Value
    if 0 == JsonTable.LinkType then
      if JsonTable.bCloseCurWidget then
        UIMgr:Hide(ViewID.UI_ActivityPanel, true)
        UIMgr:Hide(ViewID.UI_PandoraRootPanel, false)
      end
      ComLink(JsonTable.LinkId, nil, Param1, Param2, Param3, Param4, Param5)
    elseif UIMgr:IsShow(ViewID.UI_ActivityPanel) then
      if JsonTable.bCloseCurWidget then
        UIMgr:Hide(ViewID.UI_PandoraRootPanel, false)
        EventSystem.Invoke(EventDef.Activity.OnPandoraActivityTabSelected, Param1, Param2, Param3, Param4, Param5)
      end
    else
      if JsonTable.bCloseCurWidget then
        UIMgr:Hide(ViewID.UI_ActivityPanel, true)
        UIMgr:Hide(ViewID.UI_PandoraRootPanel, false)
      end
      ComLink(JsonTable.LinkId, nil, nil, nil, true, Param1, Param2, Param3, Param4, Param5)
    end
    print("pandoraGoSystem LinkId:", JsonTable.LinkId, JsonTable.LinkSource)
  end
end

function PandoraModule:OpenAnnounceApp()
  if not UE.URGPandoraSubsystem then
    return
  end
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local AppId = PandoraData:GetAnnounceAppId()
  if not UE.UKismetStringLibrary.IsEmpty(AppId) then
    PandorSubsystem:OpenApp(AppId, "")
  end
end

function PandoraModule:BindOnShowRedpoint(MsgObj)
  print("pandoraShowRedpoint:", MsgObj.content, MsgObj.appId, MsgObj.appName)
end

function PandoraModule:BindPandoraGoPandora(MsgObj)
  local appId = MsgObj.appId
  local targetAppId = MsgObj.targetAppId
  local targetAppPage = MsgObj.targetAppPage
  local jumpParams = MsgObj.jumpParams
  local openArgs = RapidJsonEncode({appPage = targetAppPage, jumpParams = jumpParams})
  print("pandoraGoPandora: appId", appId, "targetAppId", targetAppId, "opneArgs", openArgs)
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if PandorSubsystem then
    print("pandoraGoPandora open app", targetAppId, openArgs)
    return PandorSubsystem:OpenApp(targetAppId, openArgs)
  end
end

function PandoraModule:BindOnBeginnerMissionFinished(GuideId)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      local LobbyModule = ModuleManager:Get("LobbyModule")
      if LobbyModule:CheckCanShowQueueView() and not BeginnerGuideData:GetNowGuide() then
        table.Print(DataMgr.GetTeamInfo())
        local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
        for index, openAppId in ipairs(PandoraData.DisruptiveUI) do
          PandorSubsystem:OpenApp(openAppId, "OnShowLobbyMain")
        end
        PandoraData.DisruptiveUI = {}
      end
    end
  }, 1, false)
end

function PandoraModule:OnShowLobbyMain()
  print("panameraADPositionReady,OnShowLobbyMain", not BeginnerGuideData:GetNowGuide())
  if BeginnerGuideData:GetNowGuide() then
    return
  end
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      local LobbyModule = ModuleManager:Get("LobbyModule")
      if not LobbyModule:CheckCanShowQueueView() then
        return
      end
      local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
      for index, openAppId in ipairs(PandoraData.DisruptiveUI) do
        PandorSubsystem:OpenApp(openAppId, "OnShowLobbyMain")
      end
      PandoraData.DisruptiveUI = {}
    end
  }, 0.3, false)
end

function PandoraModule:AddUserData(Key, Value)
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if PandorSubsystem then
    PandorSubsystem:AddUserData(Key, Value)
  end
end

function PandoraModule:OnShutdown()
  if not UE.URGPandoraSubsystem then
    return
  end
  UnListenObjectMessage(GMP.MSG_UI_Pandora_Opened)
  UnListenObjectMessage(GMP.MSG_UI_Pandora_Closed)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraShowEntrance, self.BindOnShowEntrance, self)
  EventSystem.RemoveListener(EventDef.Pandora.panameraADPositionReady, self.BindOnADPositionReady, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraOpenUrl, self.BindOnOpenUrl, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraGoSystem, self.BindOnGoSystem, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraShowRedpoint, self.BindOnShowRedpoint, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraGoPandora, self.BindPandoraGoPandora, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraShowItemTip, self.BindPandoraShowItemTip, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraActCenterRedpoint, self.BindPandoraActCenterRedpoint, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraActCenterReady, self.BindPandoraActCenterReady, self)
  EventSystem.RemoveListener("OnViewShow_UI_LobbyMain", self.OnShowLobbyMain, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraShowTextTip, self.BindPandoraShowTextTip, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraGetUserInfo, self.BindpandoraGetUserInfo, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraActTabReady, self.BindOnPandoraActTabReady, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraCloseApp, self.BindOnPandoraCloseApp, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraCopyMessageToClipboard, self.BindPandoraCopyMessageToClipboard, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraMidasPay, self.BindPandoraMidasPay, self)
end

return PandoraModule
