require("Rouge.UI.UIBase.RGUIMgr")
require("Rouge.UI.DataManager.ChatDataMgr")
local UILayer = require("Framework.UIMgr.UILayer")
local MAXSCREENSIZE = 2.388888888888889
local MINSCREENSIZE = 1.3333333333333333
local RGUIManager_C = UnLua.Class()
function RGUIManager_C:Bp_Init()
  if not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    print("RGUIManager_C Bp_Init on Client")
    RGUIMgr:Init()
    ChatDataMgr.Init()
  end
end
function RGUIManager_C:BP_OnViewportResized(x, y)
  local PlatformName = UE.URGBlueprintLibrary.GetPlatformName()
  if "Windows" ~= PlatformName then
    return
  end
  local scale = UE.URGBlueprintLibrary.GetCurrentViewportScale(UE.RGUtil.GetWorld())
  local screenSize = UE.URGBlueprintLibrary.GetCurrentViewportSize(UE.RGUtil.GetWorld()) / scale
  local RootWidget = self:GetRootWidget()
  local needList = {}
  if RootWidget then
    needList = {
      RootWidget.LowPanel,
      RootWidget.MiddlePanel,
      RootWidget.HighPanel,
      RootWidget.ModalPanel,
      RootWidget.KoreaAge
    }
  end
  if screenSize.X / screenSize.Y > MAXSCREENSIZE then
    local newx = MAXSCREENSIZE * screenSize.Y
    for _, layer in pairs(UILayer) do
      local ui = UIMgr:GetUIRootLayerObject(layer)
      if ui then
        local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
        Slot:SetAnchors(UE.FAnchors(0.5, 0.5, 0.5, 0.5))
        Slot:SetAlignment(UE.FVector2D(0.5, 0.5))
        Slot:SetSize(UE.FVector2D(newx, screenSize.Y))
        Slot:SetPosition(UE.FVector2D(screenSize.X / 2, screenSize.Y / 2))
      end
    end
    for _, ui in pairs(needList) do
      if ui then
        local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
        Slot:SetAnchors(UE.FAnchors(0.5, 0.5, 0.5, 0.5))
        Slot:SetAlignment(UE.FVector2D(0.5, 0.5))
        Slot:SetSize(UE.FVector2D(newx, screenSize.Y))
        Slot:SetPosition(UE.FVector2D(screenSize.X / 2, screenSize.Y / 2))
      end
    end
    EventSystem.Invoke(EventDef.Global.OnViewportResized)
    return
  end
  if screenSize.X / screenSize.Y < MINSCREENSIZE then
    local newy = screenSize.X / MINSCREENSIZE
    for _, layer in pairs(UILayer) do
      local ui = UIMgr:GetUIRootLayerObject(layer)
      if ui then
        local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
        Slot:SetAnchors(UE.FAnchors(0.5, 0.5, 0.5, 0.5))
        Slot:SetAlignment(UE.FVector2D(0.5, 0.5))
        Slot:SetSize(UE.FVector2D(screenSize.X, newy))
        Slot:SetPosition(UE.FVector2D(screenSize.X / 2, screenSize.Y / 2))
      end
    end
    for _, ui in pairs(needList) do
      if ui then
        local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
        Slot:SetAnchors(UE.FAnchors(0.5, 0.5, 0.5, 0.5))
        Slot:SetAlignment(UE.FVector2D(0.5, 0.5))
        Slot:SetSize(UE.FVector2D(screenSize.X, newy))
        Slot:SetPosition(UE.FVector2D(screenSize.X / 2, screenSize.Y / 2))
      end
    end
    EventSystem.Invoke(EventDef.Global.OnViewportResized)
    return
  end
  for _, layer in pairs(UILayer) do
    local ui = UIMgr:GetUIRootLayerObject(layer)
    if ui then
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
      Slot:SetAnchors(UE.FAnchors(0, 0, 1, 1))
      Slot:SetAlignment(UE.FVector2D(0, 0))
      Slot:SetSize(UE.FVector2D(screenSize.X, screenSize.Y))
      Slot:SetPosition(UE.FVector2D(0, 0))
    end
  end
  for _, ui in pairs(needList) do
    if ui then
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
      Slot:SetAnchors(UE.FAnchors(0, 0, 1, 1))
      Slot:SetAlignment(UE.FVector2D(0, 0))
      Slot:SetSize(UE.FVector2D(screenSize.X, screenSize.Y))
      Slot:SetPosition(UE.FVector2D(0, 0))
    end
  end
  EventSystem.Invoke(EventDef.Global.OnViewportResized)
end
function RGUIManager_C:Bp_UnInit()
  if not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    print("RGUIManager_C:Bp_UnInit on Client")
    RGUIMgr:UnInit()
    ChatDataMgr.Clear()
  end
end
function RGUIManager_C:Bp_SendMsg(Msg, RoleId, ChannelId)
  ChatDataMgr.SendChatMsg(RoleId, ChannelId, Msg)
end
function RGUIManager_C:Bp_GetCurSceneStatus()
  return GetCurSceneStatus()
end
function RGUIManager_C:AddErroMsgToChannelImp(ChannelId)
  local ErrorStr = UE.URGBlueprintLibrary.TextFromStringTable("1101")
  ChatDataMgr.AddErroMsgToChannel(ChannelId, ErrorStr)
end
function RGUIManager_C:SetImageIcon(itemID, ImageWidget)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TBGeneral[tonumber(itemID)] then
    SetImageBrushByPath(ImageWidget, TBGeneral[tonumber(itemID)].Icon)
  end
end
return RGUIManager_C
