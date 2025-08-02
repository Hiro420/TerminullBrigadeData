local UnLua = _G.UnLua
local RGUtil = _G.UE.RGUtil
local UIConfig = _G.UIConfig
local MAX_INVISIBLE_UI_NUM = 5
local RootWidgetPath = "WidgetBlueprint'/Game/Rouge/UI/HUD/WBP_RootPanel.WBP_RootPanel_C'"
local RGUIMgr = {
  AliveWidgets = {},
  UILayerGroupMap = {},
  HideWidgetsForCheat = {},
  LRUWidgetAry = {},
  RootWidget = nil,
  RootWidgetRef = nil,
  bCanShowWidget = true,
  AsyncHandleIDTable = {}
}
_G.RGUIMgr = _G.RGUIMgr or RGUIMgr

function RGUIMgr:Init()
  self:InitLayerGroupMap()
end

function RGUIMgr:UnInit()
  self:Reset()
end

function RGUIMgr:Tick(DeltaTime)
end

function RGUIMgr:AsyncOpen(UIName, HideOther, LayerParam)
  if RGUtil.IsDedicatedServer() then
    return
  end
  if self.AsyncHandleIDTable[UIName] and 0 ~= self.AsyncHandleIDTable[UIName] then
    return
  end
  local UIInfo = UIConfig[UIName]
  if not UIInfo then
    UnLua.LogInfo("RGUIMgr:AsyncOpen - UIName=", UIName)
    return
  end
  if not self.AsyncHandleIDTable[UIName] then
    self.AsyncHandleIDTable[UIName] = UE.URGAssetManager.AsyncLoadAsset(UIInfo.WidgetPath, function(LoadedRes)
      if LoadedRes then
        self.AsyncHandleIDTable[UIName] = nil
        self:OpenUI1(UIName, HideOther, LayerParam)
      else
        UnLua.LogError("RGUIMgr:AsyncOpen - Load finished but asset is nil, WidgetPath=", UIInfo.WidgetPath)
      end
    end)
  else
    self:OpenUI1(UIName, HideOther, LayerParam)
  end
end

function RGUIMgr:OpenUI(UIName, HideOther, LayerParam)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager and UIName then
    return UIManager:OpenUIByName(UIName, HideOther, LayerParam)
  end
  return false
end

function RGUIMgr:OpenUILink(UIName, HideOther, LayerParam, LinkParams, ...)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager and UIName then
    UIManager:OpenUIByName(UIName, HideOther, LayerParam)
    local uiInst = self:GetUI(UIName)
    if UE.RGUtil.IsUObjectValid(uiInst) and uiInst.OnShowLink then
      uiInst:OnShowLink(LinkParams, ...)
    end
  end
end

function RGUIMgr:OpenUI1(UIName, HideOther, LayerParam)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  if not self.bCanShowWidget then
    return false
  end
  local UIInstance = self:GetUI1(UIName)
  if UIInstance then
    self:RemoveFromLRUWidgetAry(UIName)
    return self:Display(UIInstance, HideOther, true, LayerParam)
  end
  return self:CreateUI(UIName, HideOther, LayerParam)
end

function RGUIMgr:HideUI(UIName)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  if not self.bCanShowWidget then
    return false
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager and UIName then
    return UIManager:HideUIByName(UIName)
  end
  return false
end

function RGUIMgr:HideUI1(UIName)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  local UIInstance = self:GetUI1(UIName)
  if UIInstance and (UIInstance:IsShown() or UIInstance.ViewStatus == UE.EViewStatus.LayerHide) then
    return self:UnDisplay(UIInstance)
  end
  return false
end

function RGUIMgr:IsShown(UIName)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager and UIName then
    return UIManager:IsShownByName(UIName)
  end
end

function RGUIMgr:IsShown1(UIName)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  local UIInstance = self:GetUI(UIName)
  if UIInstance then
    return UIInstance:IsShown()
  end
  return false
end

function RGUIMgr:GetUI(UIName)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return nil
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager and UIName then
    return UIManager:GetUIByName(UIName)
  end
  return nil
end

function RGUIMgr:GetUI1(UIName)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return nil
  end
  return self.AliveWidgets[UIName]
end

function RGUIMgr:CloseUI(UIName)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager and UIName then
    return UIManager:K2_CloseUIByName(UIName)
  end
end

function RGUIMgr:CloseUI1(UIName, bNeedRefreshGroupParam)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return
  end
  local bNeedRefreshGroupTemp = bNeedRefreshGroupParam or true
  local UIInstance = self:GetUI1(UIName)
  if UIInstance then
    UIInstance:UnfocusInput()
    UIInstance:OnClose()
    local LayerGroupTemp = self.UILayerGroupMap[UIInstance:GetUILayer()]
    if LayerGroupTemp then
      LayerGroupTemp:RemoveFromGroup(UIInstance)
    end
    if bNeedRefreshGroupTemp and UIInstance:IsFullScreen() then
      self:SetNotFullScreenWindowInactive()
    end
    self:FocusHighestUIInst()
    UnLua.Unref(UIInstance)
    table.RemoveItem(self.LRUWidgetAry, UIName)
    self.AliveWidgets[UIName] = nil
  end
end

function RGUIMgr:HideAllWidget(IsHide)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return
  end
  if IsHide then
    self.HideWidgetsForCheat = {}
    for k, v in pairs(self.AliveWidgets) do
      if v:IsShown() then
        self.HideWidgetsForCheat[v] = v:GetVisibility()
        v:SetVisibility(UE.ESlateVisibility.Hidden)
      end
    end
  else
    for k, v in pairs(self.HideWidgetsForCheat) do
      k:SetVisibility(v)
    end
    self.HideWidgetsForCheat = {}
  end
  self:SetCanShowWidget(not IsHide)
end

function RGUIMgr:SetCanShowWidget(CanShowWidget)
  self.bCanShowWidget = CanShowWidget
end

function RGUIMgr:Display(UIInstance, HideOther, Activate, LayerParam)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  local ActivateTemp = Activate or true
  if not UIInstance:CanShow() then
    return false
  end
  UIInstance:SetIsFullScreen(HideOther)
  local UILayerTemp = EUILayer.Low
  if nil == LayerParam or LayerParam == EUILayer.None then
    if UIConfig[UE.URGBlueprintLibrary.GetClassName(UIInstance)] then
      UILayerTemp = UIConfig[UE.URGBlueprintLibrary.GetClassName(UIInstance)].Layer
    end
  else
    UILayerTemp = LayerParam
  end
  if UIInstance:GetUILayer() ~= UILayerTemp then
    local LayerGroupTemp = self.UILayerGroupMap[UIInstance:GetUILayer()]
    if LayerGroupTemp then
      LayerGroupTemp:RemoveFromGroup(UIInstance)
    end
    self.RootWidget:AddChildByLayer(UILayerTemp, UIInstance)
  end
  if self.UILayerGroupMap[UIInstance:GetUILayer()] then
    self.UILayerGroupMap[UIInstance:GetUILayer()]:AddToGroup(UIInstance)
  end
  UIInstance:OnDisplay()
  UIInstance:Show(true, ActivateTemp)
  if UIInstance:IsFullScreen() then
    self:SetNotFullScreenWindowInactive()
  else
    local HighestFullScreenWnd = self:GetHighestFullScreenUIInst()
    if HighestFullScreenWnd and self:CmpLayerHigherThanSecond(HighestFullScreenWnd, UIInstance) then
      UIInstance:UnfocusInput()
      UIInstance:OnHideByLayer()
    end
  end
  self:FocusHighestUIInst()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.DisplayDelegate:Execute(true)
  end
  return true
end

function RGUIMgr:UnDisplay(UIInstance)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  if not UIInstance:CanHide() then
    return false
  end
  UIInstance:UnfocusInput()
  UIInstance:InternalHide(true, true)
  UIInstance:OnUnDisplay()
  if UIInstance:IsFullScreen() then
    self:SetNotFullScreenWindowInactive()
  end
  self:FocusHighestUIInst()
  self:AddToLRUWidgetAry(UE.URGBlueprintLibrary.GetClassName(UIInstance))
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.DisplayDelegate:Execute(false)
  end
  return true
end

function RGUIMgr:FocusHighestUIInst()
  local HighestUIInstTemp = self:GetHighestUIInst()
  if HighestUIInstTemp then
    if self.CurrentFocusUI ~= HighestUIInstTemp then
      HighestUIInstTemp:FocusInput()
      self.CurrentFocusUI = HighestUIInstTemp
    end
  else
    self.CurrentFocusUI = nil
  end
end

function RGUIMgr:GetHighestUIInst()
  for i = EUILayer.Count - 1, EUILayer.None + 1, -1 do
    local LayerGroupTemp = self.UILayerGroupMap[i]
    if LayerGroupTemp then
      local UIInstTemp = LayerGroupTemp:GetHighestNeedFocusUIInst()
      if UIInstTemp and UIInstTemp:IsShown() then
        return UIInstTemp
      end
    end
  end
  return nil
end

function RGUIMgr:GetHighestFullScreenUIInst()
  for i = EUILayer.Count - 1, EUILayer.None + 1, -1 do
    local LayerGroupTemp = self.UILayerGroupMap[i]
    if LayerGroupTemp then
      local UIInst = LayerGroupTemp:GetHighestFullScreenWnd()
      if UIInst then
        return UIInst
      end
    end
  end
  return nil
end

function RGUIMgr:InitLayerGroupMap()
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return
  end
  for i = EUILayer.None + 1, EUILayer.Count - 1 do
    if not self.UILayerGroupMap[i] then
      local UILayerGroupTemp = UILayerGroup.New()
      UILayerGroupTemp:SetLayerId(i)
      self.UILayerGroupMap[i] = UILayerGroupTemp
    end
  end
end

function RGUIMgr:AddToLRUWidgetAry(UIName)
  local Index = table.IndexOf(self.LRUWidgetAry, UIName)
  if Index then
    table.remove(self.LRUWidgetAry, Index)
  end
  if #self.LRUWidgetAry >= MAX_INVISIBLE_UI_NUM then
    self:CloseUI1(self.LRUWidgetAry[1], false)
    table.insert(self.LRUWidgetAry, UIName)
  end
end

function RGUIMgr:RemoveFromLRUWidgetAry(UIName)
  table.RemoveItem(self.LRUWidgetAry, UIName)
end

function RGUIMgr:CreateRootWidget(ZOrder)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  local RootCls = UE.LoadClass(RootWidgetPath)
  if not RootCls then
    return false
  end
  self.RootWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, RootCls)
  if self.RootWidget then
    self.RootWidgetRef = UnLua.Ref(self.RootWidget)
    self.RootWidget:AddToViewport(2)
    return true
  end
  return false
end

function RGUIMgr:CreateUI(UIName, HideOther, LayerParam)
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return false
  end
  if not UIConfig[UIName] then
    return false
  end
  if not self.RootWidget then
    self:CreateRootWidget(0)
  end
  local UIInst
  local WidgetCls = UE.LoadClass(UIConfig[UIName].WidgetPath)
  if WidgetCls then
    UIInst = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetCls)
  end
  if UIInst then
    UnLua.Ref(UIInst)
    UIInst:OnCreate()
    local LayerTemp = LayerParam or EUILayer.None
    if LayerTemp == EUILayer.None then
      LayerTemp = UIConfig[UIName].Layer
    end
    self.RootWidget:AddChildByLayer(LayerTemp, UIInst)
    if self:Display(UIInst, HideOther, true, LayerTemp) then
      self.AliveWidgets[UIName] = UIInst
      return true
    end
  end
  return false
end

function RGUIMgr:Reset()
  if UE.UKismetSystemLibrary.IsDedicatedServer(GameInstance) then
    return
  end
  self.CurrentFocusUI = nil
  for i, v in ipairs(self.UILayerGroupMap) do
    v:Clear()
  end
  for k, v in pairs(self.AliveWidgets) do
    self:CloseUI1(k, false)
  end
  if self.RootWidget then
    self.RootWidget:RemoveFromViewport()
    UnLua.Unref(self.RootWidget)
    self.RootWidget = nil
  end
  self.RootWidgetRef = nil
  self.LRUWidgetAry = {}
  self.AliveWidgets = {}
  self.UIInstSetRef = {}
  self:SetCanShowWidget(true)
end

function RGUIMgr:SetNotFullScreenWindowInactive()
  local ContainFullScreenWindow = false
  for i = #self.UILayerGroupMap, EUILayer.None + 1, -1 do
    local LayerGroupTemp = self.UILayerGroupMap[i]
    LayerGroupTemp:SetGroupActive(ContainFullScreenWindow)
    if false == ContainFullScreenWindow then
      ContainFullScreenWindow = LayerGroupTemp:GetContainFullScreenWindow()
    end
  end
end

function RGUIMgr:CmpLayerHigherThanSecond(UIInstFirst, UIInstSecond)
  if UIInstFirst:GetUILayer() > UIInstSecond:GetUILayer() then
    return true
  end
  if UIInstFirst:GetUILayer() < UIInstSecond:GetUILayer() then
    return false
  end
  return UIInstFirst:GetZOrder() > UIInstSecond:GetZOrder()
end

return RGUIMgr
