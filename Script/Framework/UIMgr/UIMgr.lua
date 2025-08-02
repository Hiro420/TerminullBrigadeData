local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary
local UWidgetLayoutLibrary = UE.UWidgetLayoutLibrary
local EUMGSequencePlayMode = UE.EUMGSequencePlayMode
local UClass = UE.UClass
local GlobalTimer = _G.GlobalTimer
local ViewInfoDef = _G.UIDef
local ViewNameListDef = _G.ViewNameList
local UIUtil = require("Framework.UIMgr.UIUtil")
local UIModelMgr = _G.UIModelMgr
local FuncUtil = require("Framework.Utils.FuncUtil")
local LinkTable = require("Framework.DataStruct.LinkTable")
local UILayer = require("Framework.UIMgr.UILayer")
local UIMutexRule = require("UI.UIMutexRule")
local UIMutexList = require("UI.UIMutexList")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local UIMgr = LuaClass()

function UIMgr:Ctor()
  self.bInited = false
  self.UIRoot = nil
  self.UIRootProxy = nil
  self.bAddToViewport = false
  self.ActiveViews = LinkTable:New()
  self.DisableViews = LinkTable:New()
  self.PreloadWidgetPool = {}
  self.LruDisableViews = LinkTable:New()
  self.LruMaxViews = 3
  self.LruMinViews = 2
  self.LruTimer = 0
  self.LruTickCheckTime = 20
  self.EnableLruCache = true
  self.MaxDepth = {}
  self.DISABLE_VIEW_MAX_COUNT = 32
  self.DelayHideList = {}
  self.LayerZOrder = {}
  self.bClearDirtyViewing = false
  self.bHideThenDestroy = false
end

function UIMgr:Init(RootZOrder)
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("=====UIMgr:Init()=====")
  self.bInited = true
  self:_InitTick()
  self.HoldUIDic = {}
  self.RollbackMap = {}
  self.RollbackShowArgs = {}
  self.BackUIStack = LinkTable:New()
  UIModelMgr:Init()
  self:InitLayer()
  self:InitRoot(RootZOrder)
  self.EnableLruCache = false
  local scale = UWidgetLayoutLibrary.GetViewportScale(UE.RGUtil.GetWorld())
  local screenSize = UWidgetLayoutLibrary.GetViewportSize(UE.RGUtil.GetWorld()) / scale
  UIUtil.ViewportScale = scale
  UIUtil.ViewportScreenSize = screenSize
end

function UIMgr:IsInitialized()
  return self.bInited == true and self.UIRoot ~= nil
end

function UIMgr:Shutdown()
  self:_ClearTick()
end

function UIMgr:ClearDirtyView()
  print("=====UIMgr:ClearDirtyView()=====")
  self.bClearDirtyViewing = true
  UIModelMgr:ClearDirtyViewModel()
  self.bClearDirtyViewing = false
end

function UIMgr:InitRoot(RootZOrder)
  print("UIMgr:InitRoot()")
  if self.UIRoot == nil or UE.RGUtil.IsUObjectValid(self.UIRoot.Object) == false then
    self.UIRoot = UIUtil.GetWidgetLuaCtrl("/Game/Rouge/UI/WBP_Root")
    if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() then
      print("UIMgr:InitRoot - LIPass is enabled, setting UIRoot to LIPass", self.UIRoot.RootPanel)
      UE.ULevelInfiniteAPI.SetUIRoot(self.UIRoot.RootPanel)
    end
    self.UIRootProxy = UnLua.Ref(self.UIRoot.Object)
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  UIManager:BP_OnViewportResized()
  if self.UIRoot:GetIsVisible() then
    print("UIMgr:InitRoot - uiroot was already added to the screen.")
  elseif RootZOrder then
    self.UIRoot:AddToViewport(RootZOrder)
  else
    self.UIRoot:AddToViewport(0)
  end
  self.bAddToViewport = true
end

function UIMgr:Clear()
  print("=====UIMgr:Clear()=====")
  self:ClearAllViews(true)
  if self.UIRoot and UE.RGUtil.IsUObjectValid(self.UIRoot.Object) then
    self.UIRoot:RemoveFromViewport()
    self.UIRootProxy = nil
  end
  self.UIRoot = nil
  if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() then
    print("UIMgr:InitRoot - LIPass is enabled, clear UIRoot")
    UE.ULevelInfiniteAPI.SetUIRoot(nil)
  end
end

function UIMgr:Reset()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("=====UIMgr:Reset()=====")
  self:InitRoot()
end

function UIMgr:ToggleViewHideThenDestroy()
  self.bHideThenDestroy = not self.bHideThenDestroy
  print("UIMgr.bHideThenDestroy:", self.bHideThenDestroy)
end

function UIMgr:Show(viewId, bHideOther, ...)
  if self:IsInitialized() == false then
    print("UIMgr:Show - UIMgr is not initialized")
    return
  end
  local viewDef = self:GetViewDefine(viewId)
  if not viewDef then
    print("UIMgr:Show - GetViewDefine failed, viewId=", viewId)
    return
  end
  if viewDef.SwitchID then
    local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
    if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(viewDef.SwitchID) then
      return
    end
  end
  if ViewNameListDef[viewId + 1] then
    local viewName = ViewNameListDef[viewId + 1]
    if not CheckAndShowTipsSysUnlock(viewName) then
      return
    end
  end
  if self:IsDelayHide(viewId) then
    GlobalTimer.DeleteDelayCallback(self.DelayHideList[viewId].timerId)
    self.DelayHideList[viewId] = nil
  end
  local args = {
    ...
  }
  if nil ~= next(args) then
    self.RollbackShowArgs[viewId] = args
  end
  local luaInstance = self.ActiveViews:Get(viewId)
  if nil ~= luaInstance then
    luaInstance.bHideOther = bHideOther
    self:ShowInit(luaInstance, viewId, bHideOther, ...)
    return luaInstance
  end
  luaInstance = self:DoShowView(viewId, bHideOther, ...)
  luaInstance.bHideOther = bHideOther
  return luaInstance
end

function UIMgr:ShowLink(viewId, bHideOther, LinkParams, ...)
  local luaInst = self:Show(viewId, bHideOther, ...)
  if luaInst and luaInst.OnShowLink then
    luaInst:OnShowLink(LinkParams, ...)
  end
end

function UIMgr:IsSuppressExclusiveView()
  return self.SuppressExclusiveView and self.SuppressExclusiveView > 0
end

function UIMgr:IsExclusiveView(viewId)
  local rlt = false
  if UIMutexRule.Exclusive and next(UIMutexRule.Exclusive) then
    for i = 1, #UIMutexRule.Exclusive do
      if viewId == UIMutexRule.Exclusive[i] then
        rlt = true
        break
      end
    end
  end
  return rlt
end

function UIMgr:PushExclusiveView(viewId)
  self.ExclusiveViewRecoverList = self.ExclusiveViewRecoverList or {}
  self.SuppressExclusiveView = self.SuppressExclusiveView or 0
  self.SuppressExclusiveView = self.SuppressExclusiveView + 1
  self:Hide(viewId, nil, nil, nil)
  self.SuppressExclusiveView = self.SuppressExclusiveView - 1
  local bExist = false
  for _, id in pairs(self.ExclusiveViewRecoverList) do
    if id == viewId then
      bExist = true
    end
  end
  if not bExist then
    table.insert(self.ExclusiveViewRecoverList, viewId)
  end
end

function UIMgr:PopExclusiveView()
  self.ExclusiveViewRecoverList = self.ExclusiveViewRecoverList or {}
  local viewId = table.remove(self.ExclusiveViewRecoverList)
  self.SuppressExclusiveView = self.SuppressExclusiveView or 0
  self.SuppressExclusiveView = self.SuppressExclusiveView + 1
  if viewId and ViewInfoDef[viewId] then
    local luaInstance = self:GetLuaFromActiveView(viewId)
    if luaInstance then
      local args = luaInstance.LastShowArgTable or {}
      self:Show(viewId, nil, table.unpack(args))
    end
  end
  self.SuppressExclusiveView = self.SuppressExclusiveView - 1
end

function UIMgr:ShowInit(luaInstance, viewId, bHideOther, ...)
  local viewDef = self:GetViewDefine(viewId)
  if not viewDef then
    print("UIMgr:ShowInit - GetViewDefine failed, viewId=", viewId)
    return
  end
  luaInstance.LastShowArgTable = {
    ...
  }
  self:_RemoveViewTick(viewId)
  if not self:IsSuppressExclusiveView() and self:IsExclusiveView(viewDef.Id) then
    for i = 1, #UIMutexRule.Exclusive do
      if viewDef.Id ~= UIMutexRule.Exclusive[i] and self:IsShow(UIMutexRule.Exclusive[i]) then
        self:PushExclusiveView(UIMutexRule.Exclusive[i])
      end
    end
  end
  if viewDef.Mutex ~= nil and UIMutexList[viewDef.Mutex] ~= nil then
    for k, v in pairs(UIMutexList[viewDef.Mutex]) do
      if v ~= viewId then
        self:Hide(v)
      end
    end
  end
  local HideViewList
  if not viewDef.DontHideOther and true == bHideOther and (nil == viewDef.bSubView or viewDef.bSubView == false) then
    HideViewList = {}
    local tempNode = self.ActiveViews:HeadNode()
    if nil ~= tempNode then
      repeat
        if tempNode.key ~= viewId then
          local tempView = tempNode.data
          if UIUtil.IsVisible(tempView.Object) and not self.DelayHideList[tempNode.key] then
            local ViewConfig = self:GetViewDefine(tempNode.key)
            if not ViewConfig.DontHideOther then
              table.insert(HideViewList, tempNode.key)
            end
          end
        end
        tempNode = tempNode.next
      until nil == tempNode
    end
  end
  self.RollbackMap[viewId] = nil
  if nil ~= HideViewList and nil ~= next(HideViewList) then
    for i, id in ipairs(HideViewList) do
      local viewToHide = self:GetLuaFromActiveView(id)
      if viewToHide then
        viewToHide.bHideByOther = true
        self:HideView(viewToHide, id, true, viewDef.bJustSendHideNotify)
      end
    end
    self.RollbackMap[viewId] = HideViewList
  end
  UIUtil.SetVisibility(luaInstance.Object, true)
  local slotCanvas = UWidgetLayoutLibrary.SlotAsCanvasSlot(luaInstance.Object)
  local layer = viewDef.Layer
  if slotCanvas and layer then
    local zOrder = viewDef.ZOrder
    if not zOrder then
      local layerLastZOrder = self.LayerZOrder[layer] or 0
      local layerNewOrder = layerLastZOrder + 1
      self.LayerZOrder[layer] = layerNewOrder
      slotCanvas:SetZOrder(layerNewOrder)
    else
      zOrder = math.min(990, zOrder)
      slotCanvas:SetZOrder(zOrder)
    end
  end
  if nil ~= luaInstance.OnShow then
    if viewDef.CameraLobbyRow then
      local SkinId = SkinData.GetEquipedSkinIdByHeroId(DataMgr.HeroInfo.equipHero)
      LogicRole.ShowOrLoadLevel(-1)
      ChangeLobbyCamera(GameInstance, viewDef.CameraLobbyRow)
    end
    if viewDef.ShowActorListTagName then
      local ActorTagList = viewDef.ShowActorListTagName
      for i, v in ipairs(ActorTagList) do
        local ok, errors = pcall(FindAndShowActorList, v)
        if not ok then
          print("FindAndShowActorList failed:", v, errors)
        end
      end
    end
    if viewDef.HideActorListTagName then
      local ActorTagList = viewDef.HideActorListTagName
      for i, v in ipairs(ActorTagList) do
        local ok, errors = pcall(FindAndHideActorList, v)
        if not ok then
          print("FindAndHideActorList failed:", v, errors)
        end
      end
    end
    SetGroundLevelByViewID(viewId)
    luaInstance:OnShow(...)
    EventSystem.Invoke(EventDef.ViewAction.ViewOnShow, viewId)
    if nil ~= luaInstance.BindUIInput then
      luaInstance:BindUIInput()
    end
    if luaInstance.PushInputAction then
      luaInstance:PushInputAction()
    end
    local delayTime = 0
    if luaInstance.Anim_OUT then
      luaInstance:StopAnimation(luaInstance.Anim_OUT)
    end
    if luaInstance.Anim_IN then
      luaInstance:PlayAnimation(luaInstance.Anim_IN, 0, 1, EUMGSequencePlayMode.Forward, 1)
      delayTime = luaInstance.Anim_IN:GetEndTime()
    end
    if luaInstance.Anim_LOOP then
      luaInstance:PlayAnimation(luaInstance.Anim_LOOP, 0, 0, EUMGSequencePlayMode.Forward, 1)
    end
    if luaInstance.OnOpenSoundID then
      PlaySound2DEffect(luaInstance.OnOpenSoundID, "OnShow")
    end
  end
  self:_RegisterViewTick(viewId, luaInstance)
  if viewDef.SupportBack then
    self.BackUIStack:Push(viewId, viewId)
  end
end

function UIMgr:DoShowView(viewId, bHideOther, ...)
  local viewDef = self:GetViewDefine(viewId)
  if not viewDef then
    return
  end
  local luaInstance = self:GetLuaFromDisableView(viewId, true)
  if nil ~= luaInstance then
    if viewDef.IsAlwaysUpdateLayer then
      self.UIRoot:RootAddChild(luaInstance.Object, viewDef.Layer)
    end
    self:ShowInit(luaInstance, viewId, nil, ...)
    return luaInstance
  end
  luaInstance = self:GetLuaFromLruDisableView(viewId)
  if nil ~= luaInstance then
    self.LruDisableViews:Remove(viewId)
    if viewDef.IsAlwaysUpdateLayer then
      self.UIRoot:RootAddChild(luaInstance.Object, viewDef.Layer)
    end
    self:ShowInit(luaInstance, viewId, nil, ...)
    self.ActiveViews:Push(viewId, luaInstance)
    return luaInstance
  end
  luaInstance = self:CreateView(viewId, ...)
  if nil == luaInstance or nil == luaInstance.Object then
    print("UIMgr:DoShowView  CreateView Failed:", viewDef.UIBP)
    return nil
  end
  self.UIRoot:RootAddChild(luaInstance.Object, viewDef.Layer)
  self.ActiveViews:Push(viewId, luaInstance)
  self:ShowInit(luaInstance, viewId, bHideOther, ...)
  return luaInstance
end

function UIMgr:_RollbackShow(viewId, bJustSendHideNotify)
  if not self.bInited then
    return
  end
  local viewDef = self:GetViewDefine(viewId)
  if not viewDef then
    print("UIMgr:_RollbackShow - GetViewDefine failed, viewId=", viewId)
    return
  end
  local luaInstance = self.ActiveViews:Get(viewId)
  if not luaInstance then
    print("UIMgr:_RollbackShow Get failed, force show.")
    local args = self.RollbackShowArgs[viewId] or {}
    self:Show(viewId, false, table.unpack(args))
    return
  end
  luaInstance.bHideByOther = false
  if not bJustSendHideNotify then
    UIUtil.SetVisibility(luaInstance.Object, true)
  end
  self:_RemoveViewTick(viewId)
  if luaInstance.OnRollback ~= nil then
    luaInstance:OnRollback()
    EventSystem.Invoke(EventDef.ViewAction.ViewOnShow, viewId)
    SetGroundLevelByViewID(viewId)
  end
  if nil ~= luaInstance.BindUIInput then
    luaInstance:BindUIInput()
  end
  self:_RegisterViewTick(viewId, luaInstance)
end

function UIMgr:HideAndRollback(viewIdToHide)
  if not viewIdToHide then
    return
  end
  local viewToHide = self:GetLuaFromActiveView(viewIdToHide)
  if not viewToHide then
    return
  end
  if UIUtil.IsVisible(viewToHide.Object) == false then
    return
  end
  viewToHide.bHideByOther = false
  if viewToHide and nil ~= viewToHide.OnPreHide and type(viewToHide.OnPreHide) == "function" then
    viewToHide:OnPreHide()
  end
  self:HideView(viewToHide, viewIdToHide)
  local viewDef = self:GetViewDefine(viewIdToHide)
  local bJustSendHideNotify = false
  if viewDef then
    bJustSendHideNotify = viewDef.bJustSendHideNotify
  end
  local rollbackList = self.RollbackMap[viewIdToHide]
  if nil ~= rollbackList and nil ~= next(rollbackList) then
    for k, v in ipairs(rollbackList) do
      self:_RollbackShow(v, bJustSendHideNotify)
    end
  end
  if self.bHideThenDestroy == true then
    self:DestroyView(viewToHide, viewIdToHide)
  end
end

function UIMgr:Hide(viewId, bRollback, clear, withoutAnimation)
  if not viewId then
    error("UIMgr:Hide viewId is nil")
    return
  end
  if self:IsDelayHide(viewId) then
    GlobalTimer.DeleteDelayCallback(self.DelayHideList[viewId].timerId)
    self.DelayHideList[viewId] = nil
  end
  if true == bRollback then
    self:HideAndRollback(viewId)
    return
  end
  local luaInstance
  luaInstance = self.ActiveViews:Get(viewId)
  if luaInstance then
    if UIUtil.IsVisible(luaInstance.Object) then
      self.RollbackMap[viewId] = nil
      if luaInstance and nil ~= luaInstance.OnPreHide and type(luaInstance.OnPreHide) == "function" then
        luaInstance:OnPreHide()
      end
      if luaInstance and luaInstance.Anim_IN then
        luaInstance:StopAnimation(luaInstance.Anim_IN)
      end
      if luaInstance and luaInstance.Anim_LOOP then
        luaInstance:StopAnimation(luaInstance.Anim_LOOP)
      end
      if true ~= withoutAnimation and luaInstance.Anim_OUT then
        if self.DelayHideList[viewId] then
          return
        end
        if nil ~= luaInstance.OnPreHide then
          luaInstance:OnPreHide()
        end
        luaInstance:PlayAnimation(luaInstance.Anim_OUT, 0, 1, EUMGSequencePlayMode.Forward, 1)
        local duration = luaInstance.Anim_OUT:GetEndTime()
        local timerId = GlobalTimer.DelayCallback(duration, function()
          self:ExcuteHide(viewId, clear)
        end)
        local DelayHideInfo = {
          viewId = viewId,
          clear = clear,
          timerId = timerId
        }
        self.DelayHideList[viewId] = DelayHideInfo
      else
        if nil ~= luaInstance.OnPreHide then
          luaInstance:OnPreHide()
        end
        self:ExcuteHide(viewId, clear)
      end
    elseif true == luaInstance.bHideByOther then
      luaInstance.bHideByOther = nil
      if nil ~= luaInstance.OnPreHide then
        luaInstance:OnPreHide()
      end
      self:ExcuteHide(viewId, clear)
    end
  else
    return
  end
end

function UIMgr:ExcuteHide(viewId, clear)
  if self.DelayHideList[viewId] then
    GlobalTimer.DeleteDelayCallback(self.DelayHideList[viewId].timerId)
    self.DelayHideList[viewId] = nil
  end
  local luaInstance
  luaInstance = self.ActiveViews:Get(viewId)
  if luaInstance then
    if self.bHideThenDestroy == true then
      self:HideView(luaInstance, viewId)
      self:DestroyView(luaInstance, viewId)
      return
    end
    local bPreload = ViewInfoDef[viewId].PreLoad
    if not bPreload and clear then
      self:HideView(luaInstance, viewId)
      self:DestroyView(luaInstance, viewId)
      return
    end
    self:HideView(luaInstance, viewId)
    if bPreload then
      clear = false
    end
    if not luaInstance.Object then
      printError("UIMgr:ExcuteHide - luaInstance.Object is nil" .. ViewInfoDef[viewId].UIBP)
      return
    end
  else
    return
  end
end

function UIMgr:ShrinkLruDisableViews(maxLimitNum, destroyCntOnce)
  local breakIndex = 0
  while maxLimitNum < self.LruDisableViews:Count() do
    local disabledHudInfo, key = self.LruDisableViews:PopHead()
    if nil == disabledHudInfo then
      return
    end
    self:DestroyView(disabledHudInfo, key)
    breakIndex = breakIndex + 1
    if destroyCntOnce <= breakIndex then
      break
    end
  end
end

function UIMgr:HideView(luaInstance, viewId, bHideOther, bJustSendHideNotify)
  if not bJustSendHideNotify then
    UIUtil.SetVisibility(luaInstance.Object, false)
  end
  self:HideViewImp(luaInstance, viewId, bHideOther)
  local top_id = self.BackUIStack:End()
  if viewId == top_id then
    self.BackUIStack:RemoveEnd()
    local top_id2 = self.BackUIStack:PopEnd()
    if top_id2 then
      local luaInst = self.ActiveViews:Get(top_id2)
      if luaInst and luaInst.OnBackShow then
        luaInst:OnBackShow()
      end
    end
  end
end

function UIMgr:HideViewImp(luaInstance, viewId, bHideOther)
  if luaInstance.OnHideCallback ~= nil then
    luaInstance.OnHideCallback()
    luaInstance.OnHideCallback = nil
  end
  if not bHideOther then
    if nil ~= luaInstance.OnHide then
      local viewDef = self:GetViewDefine(viewId)
      if viewDef.ShowActorListTagName then
        local ActorTagList = viewDef.ShowActorListTagName
        for i, v in ipairs(ActorTagList) do
          local ok, errors = pcall(FindAndHideActorList, v)
          if not ok then
            print("FindAndHideActorList failed:", v, errors)
          end
        end
      end
      if viewDef.HideActorListTagName then
        local ActorTagList = viewDef.HideActorListTagName
        for i, v in ipairs(ActorTagList) do
          local ok, errors = pcall(FindAndShowActorList, v)
          if not ok then
            print("FindAndShowActorList failed:", v, errors)
          end
        end
      end
      if nil ~= luaInstance.UnBindUIInput then
        luaInstance:UnBindUIInput()
      end
      luaInstance:OnHide()
      luaInstance:StopAllAnimations()
      if luaInstance.OnCloseSoundID then
        PlaySound2DEffect(luaInstance.OnCloseSoundID, "OnHide")
      end
    end
    EventSystem.Invoke(EventDef.ViewAction.ViewOnHide, viewId)
  else
    if nil ~= luaInstance.UnBindUIInput then
      luaInstance:UnBindUIInput()
    end
    if nil ~= luaInstance.OnHideByOther then
      luaInstance:OnHideByOther()
      luaInstance:StopAllAnimations()
    end
  end
  self:_UnregisterViewTick(viewId)
end

function UIMgr:HideAllActiveViews(exceptViewIds)
  if nil == exceptViewIds or nil == next(exceptViewIds) then
    self:ClearActiveViews()
    return
  end
  if not self.ActiveViews then
    return
  end
  local ToHideViewList = {}
  for key, tItem in pairs(self.ActiveViews._table) do
    if tItem and not exceptViewIds[key] then
      table.insert(ToHideViewList, key)
    end
  end
  for i, viewId in ipairs(ToHideViewList) do
    self:Hide(viewId, nil, false, true)
  end
end

function UIMgr:IsShow(viewId)
  local v = self.ActiveViews:Get(viewId)
  return nil ~= v and UIUtil.IsVisible(v.Object) == true
end

function UIMgr:IsDelayHide(viewId)
  return self.DelayHideList[viewId] ~= nil
end

function UIMgr:GetAllActiveViews()
  return self.ActiveViews._table
end

function UIMgr:IsViewInstanceShow(viewInstance)
  for k, v in pairs(self.ActiveViews._table) do
    if v.data ~= nil and v.data == viewInstance then
      return k
    end
  end
  return false
end

function UIMgr:GetViewDefine(viewId)
  return ViewInfoDef[viewId]
end

function UIMgr:GetFromActiveView(viewId)
  local luaInstance = self.ActiveViews:Get(viewId)
  if luaInstance then
    return luaInstance.Object
  end
  return nil
end

function UIMgr:GetLuaFromActiveView(viewId)
  if self:IsShow(viewId) then
    return self.ActiveViews:Get(viewId)
  end
  return nil
end

function UIMgr:GetFromDisableView(viewId)
  if self.DisableViews ~= nil then
    local luaInstance = self.DisableViews:Get(viewId)
    if luaInstance then
      return luaInstance.Object
    end
    luaInstance = self.LruDisableViews:Get(viewId)
    if luaInstance then
      return luaInstance.Object
    end
  end
  return nil
end

function UIMgr:GetFromDisableView(viewId)
  if self.DisableViews ~= nil then
    local luaInstance = self.DisableViews:Get(viewId)
    if luaInstance then
      return luaInstance.Object
    end
    luaInstance = self.LruDisableViews:Get(viewId)
    if luaInstance then
      return luaInstance.Object
    end
  end
  return nil
end

function UIMgr:GetLuaFromDisableView(viewId, bOnlyDisableViews)
  if self.DisableViews ~= nil then
    local luaInstance = self.DisableViews:Get(viewId)
    if (not bOnlyDisableViews or false == bOnlyDisableViews) and not luaInstance then
      luaInstance = self.LruDisableViews:Get(viewId)
    end
    return luaInstance
  end
  return nil
end

function UIMgr:GetLuaFromLruDisableView(viewId)
  local luaInstance = self.LruDisableViews:Get(viewId)
  return luaInstance
end

function UIMgr:GetUIRoot()
  if self.UIRoot then
    return self.UIRoot
  end
  return nil
end

function UIMgr:GetUIRootLayerObject(layer)
  if self.UIRoot then
    return self.UIRoot:GetLayerObject(layer)
  end
  return nil
end

function UIMgr:ClearDisableViews()
  print("UIMgr:ClearDisableViews")
  if self.DisableViews then
    local nCount = self.DisableViews:Count()
    for _ = 1, nCount do
      local tItem, viewId = self.DisableViews:PopHead()
      if tItem then
        self:DestroyView(tItem, viewId)
      end
    end
    self.DisableViews:Clear()
  end
  self:ClearLruDisableViews(false)
end

function ClearUICache()
  print("UIMgr ClearUICache")
  self:ClearLruDisableViews(false)
end

function UIMgr:ClearActiveViews(saveHold)
  print("UIMgr:ClearActiveViews")
  if not self.ActiveViews then
    return
  end
  self.HoldUIDic = {}
  local AllActiveViewIds = {}
  for key, tItem in pairs(self.ActiveViews._table) do
    table.insert(AllActiveViewIds, key)
  end
  for i, SingleViewId in pairs(AllActiveViewIds) do
    local tItem = self.ActiveViews._table[SingleViewId]
    if tItem then
      if saveHold then
        local cfg = self:GetViewDefine(SingleViewId)
        if cfg and cfg.HoldInLoad and tItem.data.SaveOnHold then
          self.HoldUIDic[SingleViewId] = table.pack(tItem.data:SaveOnHold())
        end
      end
      self:Hide(SingleViewId, nil, true, true)
      self.ActiveViews:Remove(SingleViewId)
    end
  end
end

function UIMgr:RevertHoldUI()
  if not self.HoldUIDic or not next(self.HoldUIDic) then
    return
  end
  for key, value in pairs(self.HoldUIDic) do
    self:Show(key, nil, table.unpack(value))
  end
end

function UIMgr:ClearDelayHideViews()
  print("UIMgr:ClearDelayHideViews")
  local HideList = {}
  for k, v in pairs(self.DelayHideList) do
    table.insert(HideList, k)
  end
  for i = 1, #HideList do
    local DelayInfo = self.DelayHideList[HideList[i]]
    if DelayInfo then
      self:ExcuteHide(DelayInfo.viewId, true)
    end
  end
end

function UIMgr:ClearLruDisableViews(bClearAll)
  print("UIMgr:ClearLruDisableViews")
  local nCount = self.LruDisableViews:Count()
  for i = 1, nCount do
    local tItem, viewId = self.LruDisableViews:PopHead()
    if tItem then
      self:DestroyView(tItem, viewId)
    end
  end
end

function UIMgr:ClearAllViews(IsSameMap)
  print("UIMgr:ClearAllViews")
  self:ClearDelayHideViews()
  self:ClearActiveViews(true)
  self:ClearDisableViews()
  self:ClearLruDisableViews(true)
  self:ClearPreloadWidgets()
  UIModelMgr:UnRegisterAllPropertyChanged()
  self.LayerZOrder = {}
  self:_ClearTick()
end

function UIMgr:DestroyView(luaInstance, viewId)
  if luaInstance then
    local viewDef = self:GetViewDefine(viewId)
    self.DisableViews:Remove(viewId)
    self.LruDisableViews:Remove(viewId)
    self.ActiveViews:Remove(viewId)
    self:_RemoveViewTick(viewId)
    luaInstance.LastShowArgTable = nil
    self:DoDestroyView(luaInstance)
    self.UIRoot:RootRemoveChild(luaInstance.Object, viewDef.Layer)
    if self.EnableLruCache then
      for k, _ in pairs(luaInstance) do
        luaInstance[k] = nil
      end
      setmetatable(luaInstance, {})
    end
  end
end

function UIMgr:DoDestroyView(luaInstance)
  if luaInstance then
    if luaInstance.OnDestroy then
      luaInstance:OnDestroy()
    end
    UIUtil.ClearWhenDestroy(luaInstance)
  end
end

function UIMgr:CreateView(viewId, ...)
  local viewDef = self:GetViewDefine(viewId)
  if nil == viewDef then
    return nil
  end
  local nameStr = UIUtil.GetUIBPName(viewDef.UIBP)
  if nil == nameStr or 0 == #nameStr then
    return nil
  end
  local tBPClass
  tBPClass = UClass.Load(viewDef.UIBP)
  if tBPClass then
    local tBPInstance = self:GetPreloadWidget(viewId)
    if not (tBPInstance and tBPInstance.Object) or not UE.RGUtil.IsUObjectValid(tBPInstance.Object) then
      tBPInstance = self:CreateWidget(tBPClass, nameStr, true)
    end
    if tBPInstance and tBPInstance.Object and UE.RGUtil.IsUObjectValid(tBPInstance.Object) then
      tBPInstance.ViewID = viewId
      if tBPInstance.OnInit then
        tBPInstance:OnInit(...)
      end
      return tBPInstance
    else
      printError("UIMgr:CreateView Error, " .. nameStr)
      return nil
    end
  end
  return nil
end

function UIMgr:PreloadWidget(viewId, cnt)
  local preloadPool = self.PreloadWidgetPool[viewId]
  if preloadPool and cnt <= #preloadPool then
    return
  end
  local viewDef = self:GetViewDefine(viewId)
  if nil == viewDef or cnt <= 0 then
    return nil
  end
  local nameStr = UIUtil.GetUIBPName(viewDef.UIBP)
  if nil == nameStr or 0 == #nameStr then
    return nil
  end
  local tBPClass = UClass.Load(viewDef.UIBP)
  if tBPClass then
    if not self.PreloadWidgetPool[viewId] then
      self.PreloadWidgetPool[viewId] = {}
    end
    local numNeedCreate = 1
    if preloadPool then
      numNeedCreate = cnt - #preloadPool
    end
    for i = 1, numNeedCreate do
      local tBPInstance = self:CreateWidget(tBPClass, nameStr, true)
      if tBPInstance then
        table.insert(self.PreloadWidgetPool[viewId], tBPInstance)
      end
    end
  end
end

function UIMgr:GetPreloadWidget(viewId)
  local preloadPool = self.PreloadWidgetPool[viewId]
  if preloadPool and #preloadPool > 0 then
    local tBPInstance = table.remove(preloadPool, 1)
    return tBPInstance
  end
  return nil
end

function UIMgr:ClearPreloadWidgets()
  print("UIMgr:ClearPreloadWidgets()")
  self.PreloadWidgetPool = {}
end

function UIMgr:CreateSubView(viewId, BP_obj, needClone, ...)
  local viewDef = self:GetViewDefine(viewId)
  if nil == viewDef then
    return nil
  end
  local tBPInstance = BP_obj
  if needClone then
    tBPInstance = self:GetPreloadWidget(viewId)
    if not tBPInstance then
      local tBPClass = UClass.Load(viewDef.UIBP)
      if tBPClass then
        local bpName = UIUtil.GetUIBPName(viewDef.UIBP)
        if not bpName or 0 == #bpName then
          return nil
        end
        tBPInstance = self:CreateWidget(tBPClass, bpName, false)
      end
    end
  end
  if tBPInstance then
    if tBPInstance.OnInit then
      tBPInstance:OnInit(...)
    end
    return tBPInstance
  end
  return nil
end

function UIMgr:CreateWidget(bpClass, nameStr, isMain)
  local bpInst = UWidgetBlueprintLibrary.Create(GameInstance, bpClass)
  return bpInst
end

function UIMgr:InitLayer()
  for _, nLayer in pairs(UILayer) do
    self.MaxDepth[nLayer] = nLayer * 100 + 1
  end
end

function UIMgr:GenerateNewLayer(nLayerType)
  if self.MaxDepth[nLayerType] ~= nil then
    local LayerIdx = self.MaxDepth[nLayerType] + 1
    self.MaxDepth[nLayerType] = LayerIdx
    return LayerIdx
  end
  return false
end

function UIMgr:GetLayerMaxDepth(nLayerType)
  return self.MaxDepth[nLayerType]
end

function UIMgr:IsOnShowArgChange(luaInstance, newArg)
  if not luaInstance then
    return true
  end
  if nil == newArg and 0 == #luaInstance.LastShowArgTable then
    return false
  end
  if FuncUtil.IsEqualVar(newArg, luaInstance.LastShowArgTable) then
    return false
  else
    return true
  end
end

function UIMgr:_InitTick()
  self.TickMap = {}
  self.TickDelMap = {}
  self.TickMapCount = 0
  if self.TickIndex then
    GlobalTimer.DeleteTickTimer(1, self.TickIndex)
    self.TickIndex = nil
  end
end

function UIMgr:_ClearTick()
  self.TickMap = {}
  self.TickDelMap = {}
end

function UIMgr:_CheckAndStartTick()
  if self.TickMapCount > 0 and self.TickIndex == nil then
    self.TickIndex = GlobalTimer.AddTickTimer(function(deltaSeconds)
      self:_LuaTick(deltaSeconds)
      return 1
    end, 0)
  end
end

function UIMgr:_CheckAndStopTick()
  if 0 == self.TickMapCount and self.TickIndex then
    GlobalTimer.DeleteTickTimer(self.TickIndex)
    self.TickIndex = nil
  end
end

function UIMgr:_RegisterViewTick(viewId, viewInst)
  if not viewId or not viewInst then
    return
  end
  if viewInst.OnTick ~= nil then
    if nil == self.TickMap[viewId] or self.TickDelMap[viewId] then
      self.TickDelMap[viewId] = nil
      self.TickMapCount = self.TickMapCount + 1
    end
    self.TickMap[viewId] = viewInst
  end
  self:_CheckAndStartTick()
end

function UIMgr:_RemoveViewTick(viewId)
  if self.TickMap[viewId] ~= nil and not self.TickDelMap[viewId] then
    self.TickDelMap[viewId] = true
    self.TickMapCount = self.TickMapCount - 1
  end
end

function UIMgr:_UnregisterViewTick(viewId)
  self:_RemoveViewTick(viewId)
  self:_CheckAndStopTick()
end

function UIMgr:_LuaTick(deltaSeconds)
  for k, v in pairs(self.TickMap) do
    if not self.TickDelMap[k] and v.OnTick then
      v:OnTick(deltaSeconds)
    end
  end
  for k, v in pairs(self.TickDelMap) do
    self.TickMap[k] = nil
  end
  self.TickDelMap = {}
  if not self.EnableLruCache then
    self:ShrinkLruDisableViews(0, 2)
    return
  end
  self.LruTimer = self.LruTimer + deltaSeconds
  if self.LruTimer > self.LruTickCheckTime then
    self.LruTimer = 0
    local viewCnt = self.LruDisableViews:Count()
    if viewCnt > self.LruMinViews then
      self.LruTickCheckTime = 10
      self:ShrinkLruDisableViews(self.LruMinViews, viewCnt - self.LruMinViews)
    else
      self.LruTickCheckTime = 20
      self:ShrinkLruDisableViews(0, 1)
    end
  end
end

_G.UIMgr = _G.UIMgr or UIMgr.New()
