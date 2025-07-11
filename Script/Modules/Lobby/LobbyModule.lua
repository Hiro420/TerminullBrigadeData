local LobbyModule = LuaClass()
local ProrityQueue = require("Framework.DataStruct.ProrityQueue")
local RewardIncreaseHandler = require("Protocol.RewardIncrease.RewardIncreaseHandler")
local LocalSpecificUnlockDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SpecificUnlock/SpecificUnlockData_" .. "Default" .. ".json"
local LocalSpecificAniDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SpecificUnlock/IllustratedGuideSpecificAni" .. "Default" .. ".json"
local LocalSaveGrowthSnapFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SaveGrowthSnap/SaveGrowthSnapData" .. "Default" .. ".json"
local LocalSurvivorDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/Survivor/SurvivorData_" .. "Default" .. ".json"
local LocalRechargeDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/Recharge/RechargeData_" .. "Default" .. ".json"
local LocalVoiceControlFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/LocalVoiceControl/LocalVoiceControlData" .. "Default" .. ".json"
local rapidjson = require("rapidjson")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")
local SaveSurvivorData = require("Modules.Survivor.SurvivorData")
local SaveRechargeData = require("Modules.Recharge.RechargeData")
local ShowViewQueueInViews = {
  [ViewID.UI_LobbyMain] = true
}
local ViewQueuePrority = {
  [ViewID.UI_LevelUp] = 10,
  [ViewID.UI_ModeSelectionUnlockPanel] = 9,
  [ViewID.UI_ChipSlotUnlockView] = 8,
  [ViewID.UI_ChipSeasonSlotUnlockView] = 7,
  [ViewID.UI_LoginRewards] = 6,
  [ViewID.UI_SpecificLobbyUnlockShow] = 5,
  [ViewID.UI_SeasonMode_Pop] = 20,
  [ViewID.UI_InitialRoleSelection] = 1000,
  [ViewID.UI_ProfyUpgradeAnimPanel] = 4
}
function LobbyModule:Ctor()
end
function LobbyModule:OnInit()
  print("LobbyModule:OnInit...........")
  EventSystem.AddListenerNew(EventDef.ViewAction.ViewOnHide, self, self.OnShowViewQueue)
  EventSystem.AddListenerNew(EventDef.ViewAction.ViewOnShow, self, self.OnViewShow)
  EventSystem.AddListenerNew(EventDef.Lobby.OnUpdateGameFloorInfo, self, self.BindOnUpdateGameFloorInfo)
  EventSystem.AddListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
  self.AttributeList = {}
  self.SpecificList = {}
  self.GenericList = {}
  self.PagesVisbleDelegateList = {}
  self:AddLabelVisbleDelgate("LobbyLabel.Season", self, self.CheckIsInSeasonMode)
end
function LobbyModule:OnShutdown()
  self:RemoveLabelVisbleDelegate("LobbyLabel.Season", self, self.CheckIsInSeasonMode)
  self.PagesVisbleDelegateList = {}
  print("LobbyModule:OnShutdown...........")
  EventSystem.RemoveListenerNew(EventDef.ViewAction.ViewOnHide, self, self.OnShowViewQueue)
  EventSystem.RemoveListenerNew(EventDef.ViewAction.ViewOnShow, self, self.OnViewShow)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OnUpdateGameFloorInfo, self, self.BindOnUpdateGameFloorInfo)
  EventSystem.RemoveListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
  self:SaveSpecificDataToLocal()
  self:SaveGrowthSnapDataToLocal()
  self:SaveSurvivalDataToLocal()
  self:SaveRechargeDataToLocal()
  self:SaveVoiceControlDataToLocal()
end
function LobbyModule:BindOnLoginProtocolSuccess()
  LocalSpecificUnlockDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SpecificUnlock/SpecificUnlockData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalSpecificUnlockDataFilePath)
  if Result then
    IllustratedGuideData.NewUnlockSpecificModifyList = rapidjson.decode(FileStr)
  end
  LocalSpecificAniDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SpecificUnlock/IllustratedGuideSpecificAni_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalSpecificAniDataFilePath)
  if Result then
    IllustratedGuideData.SpecificUnlockAniMap = rapidjson.decode(FileStr).Content or {}
  end
  LocalSaveGrowthSnapFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SaveGrowthSnap/SaveGrowthSnapData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalSaveGrowthSnapFilePath)
  if Result then
    local LocalSaveGrowthSnapData = rapidjson.decode(FileStr) or {}
    SaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes = LocalSaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes or {}
    SaveGrowthSnapData.bAutoSave = LocalSaveGrowthSnapData.bAutoSave or true
  end
  LocalSurvivorDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/Survivor/SurvivorData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalSurvivorDataFilePath)
  if Result then
    SaveSurvivorData.LocalSaveData = rapidjson.decode(FileStr)
  end
  LocalRechargeDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/Recharge/RechargeData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalRechargeDataFilePath)
  if Result then
    SaveRechargeData.LocalSaveData = rapidjson.decode(FileStr)
  end
  LocalVoiceControlFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/LocalVoiceControl/LocalVoiceControlData" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalVoiceControlFilePath)
  if Result then
    local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
    if VoiceControlModule then
      VoiceControlModule.LocalVoiceControlData = rapidjson.decode(FileStr) or false
    end
  end
end
function LobbyModule:EnterLobby()
  print("LobbyModule::EnterLobby CursorVirtualFocus 0")
  UE.URGBlueprintLibrary.CursorVirtualFocus(0)
  ModuleManager:Get("BeginnerGuideModule").bCanRequestMyHeroInfo = true
  ModuleManager:Get("BeginnerGuideModule").bCanRequestTeamGameFloorData = true
  local RewardIncreaseModule = ModuleManager:Get("RewardIncreaseModule")
  RewardIncreaseModule:RequestGetRewardIncreaseCount(nil, true)
  UE.URGBlueprintLibrary.OnEnterLobby()
  UIMgr:Show(ViewID.UI_Marquee)
  if DataMgr.GetPreSceneStatus() ~= UE.ESceneStatus.ELogin then
    LogicLobby.RequestGetRoleListInfoToServer({
      DataMgr.GetUserId()
    })
  end
  if not table.IsEmpty(IllustratedGuideData.NewUnlockSpecificModifyList) then
    local viewData = {
      ViewID = ViewID.UI_SpecificLobbyUnlockShow,
      Params = {}
    }
    self:PushView(viewData)
  end
end
function LobbyModule:CheckIsInSeasonMode()
  local SeasonModule = ModuleManager:Get("SeasonModule")
  if not SeasonModule then
    return false
  end
  return SeasonModule:CheckIsInSeasonMode()
end
function LobbyModule:SaveSpecificDataToLocal()
  local newUnlockSpecificModifyListJson = RapidJsonEncode(IllustratedGuideData.NewUnlockSpecificModifyList)
  UE.URGBlueprintLibrary.SaveStringToFile(LocalSpecificUnlockDataFilePath, newUnlockSpecificModifyListJson)
  local specificUnlockAniMapJson = RapidJsonEncode({
    Content = IllustratedGuideData.SpecificUnlockAniMap
  })
  UE.URGBlueprintLibrary.SaveStringToFile(LocalSpecificAniDataFilePath, specificUnlockAniMapJson)
end
function LobbyModule:SaveGrowthSnapDataToLocal()
  local localSaveSnapData = {
    SaveGrowthSnapTipNoUseTimes = SaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes,
    bAutoSave = SaveGrowthSnapData.bAutoSave
  }
  local localSaveGrowthSnapDataJson = RapidJsonEncode(localSaveSnapData)
  UE.URGBlueprintLibrary.SaveStringToFile(LocalSaveGrowthSnapFilePath, localSaveGrowthSnapDataJson)
end
function LobbyModule:SaveSurvivalDataToLocal()
  local newSurvivorDataListJson = RapidJsonEncode(SaveSurvivorData.LocalSaveData)
  UE.URGBlueprintLibrary.SaveStringToFile(LocalSurvivorDataFilePath, newSurvivorDataListJson)
end
function LobbyModule:SaveRechargeDataToLocal()
  local newRechargeDataListJson = RapidJsonEncode(SaveRechargeData.LocalSaveData)
  UE.URGBlueprintLibrary.SaveStringToFile(LocalRechargeDataFilePath, newRechargeDataListJson)
end
function LobbyModule:SaveVoiceControlDataToLocal()
  local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
  if not VoiceControlModule or not VoiceControlModule.LocalVoiceControlData then
    return
  end
  if not VoiceControlModule.LocalVoiceControlData then
    VoiceControlModule.LocalVoiceControlData = false
  end
  local localSaveGrowthSnapDataJson = RapidJsonEncode(VoiceControlModule.LocalVoiceControlData)
  UE.URGBlueprintLibrary.SaveStringToFile(LocalVoiceControlFilePath, localSaveGrowthSnapDataJson)
end
function LobbyModule:BindOnUpdateGameFloorInfo(...)
  local LobbySaveGame = LogicLobby.GetLobbySaveGame()
  local GameModeId = LogicTeam and GetCurNormalMode() or 1001
  local CurGameFloorData = DataMgr.GetGameFloorInfoByGameMode(GameModeId)
  if LobbySaveGame and CurGameFloorData then
    local Result, CacheGameFloorData = LobbySaveGame:GetGameFloorDataByUserId(DataMgr.GetUserId(), GameModeId, nil)
    if Result then
      local ShowWorldFloorList = {}
      for WorldId, Floor in pairs(CurGameFloorData) do
        local CacheFloor = CacheGameFloorData.GameFloorData:Find(WorldId)
        CacheFloor = CacheFloor or 0
        local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
        if TBGameFloor then
          for LevelId, LevelInfo in pairs(TBGameFloor) do
            if LevelInfo.initUnlock and LevelInfo.gameWorldID == tonumber(WorldId) and CacheFloor < LevelInfo.floor then
              CacheFloor = LevelInfo.floor
            end
          end
        end
        if Floor > CacheFloor then
          if 0 == CacheFloor then
            ShowWorldFloorList[WorldId] = 0
          else
            ShowWorldFloorList[WorldId] = Floor
          end
        end
      end
      if next(ShowWorldFloorList) ~= nil then
        local ViewData = {
          ViewID = ViewID.UI_ModeSelectionUnlockPanel,
          Params = {ShowWorldFloorList}
        }
        self:PushView(ViewData)
      end
    end
  end
end
function LobbyModule:ExitLobby()
  if self.ViewProrityQueue then
    self.ViewProrityQueue:Clear()
  end
  self.CurShowViewData = nil
end
function LobbyModule:CheckCanShowQueueView()
  print("LobbyModule:CheckCanShowQueueView", self.CurShowViewData)
  if not self.CurShowViewData then
    for k, v in pairs(ShowViewQueueInViews) do
      if UIMgr:IsShow(k) then
        return true
      end
    end
  else
    print("LobbyModule:CheckCanShowQueueView CurShowViewID =", self.CurShowViewData)
  end
  return false
end
function LobbyModule:PushView(ViewData)
  if not self.ViewProrityQueue then
    self.ViewProrityQueue = ProrityQueue.New({}, self.SortQueue)
  end
  self.ViewProrityQueue:Enqueue(ViewData)
  if self:CheckCanShowQueueView() then
    self:OnShowViewQueue(nil, true)
  end
end
function LobbyModule:UpdateViewData(ViewData)
  if not self.ViewProrityQueue then
    self:PushView(ViewData)
    return
  end
  local bFind = false
  for i, v in pairs(self.ViewProrityQueue) do
    if v.ViewID == ViewData.ViewID then
      bFind = true
      v.Params = ViewData.Params or {}
      break
    end
  end
  if not bFind then
    self:PushView(ViewData)
  elseif self:CheckCanShowQueueView() then
    self:OnShowViewQueue(nil, true)
  end
end
function LobbyModule.SortQueue(A, B)
  if not ViewQueuePrority[A.ViewID] then
    error("Pls Check ViewQueuePrority Is Contain ViewID:", A.ViewID)
  end
  if not ViewQueuePrority[B.ViewID] then
    error("Pls Check ViewQueuePrority Is Contain ViewID:", B.ViewID)
  end
  return ViewQueuePrority[A.ViewID] > ViewQueuePrority[B.ViewID]
end
function LobbyModule:OnViewShow(ViewID)
  print("LobbyModule:OnViewShow", ViewID)
  if ShowViewQueueInViews[ViewID] and not self.CurShowViewData then
    self:OnShowViewQueue(nil, true)
  end
  local ViewName = GetViewNameByViewId(ViewID)
  if nil ~= ViewName then
    EventSystem.Invoke("OnViewShow_" .. GetViewNameByViewId(ViewID))
  end
end
function LobbyModule:OnShowViewQueue(ViewID, bForceDequeueView)
  if ViewID then
    print("LobbyModule:OnShowViewQueue", UIDef[ViewID].UIScript)
  end
  local bRemvoe = false
  if self.CurShowViewData and self.CurShowViewData.ViewID == ViewID then
    self.CurShowViewData = nil
    bRemvoe = true
  end
  if self.ViewProrityQueue and not self.ViewProrityQueue:IsEmpty() then
    if bRemvoe then
      local viewData = self.ViewProrityQueue:Dequeue()
      if viewData then
        self.CurShowViewData = viewData
        local bHideOther = viewData.Params.bHideOther or false
        UIMgr:Show(viewData.ViewID, bHideOther, table.unpack(viewData.Params))
        print(string.format("LobbyModule:OnShowViewQueue Show View %s When close View %s", UIDef[viewData.ViewID].UIScript, UIDef[ViewID].UIScript))
      else
        self.CurShowViewData = nil
      end
    elseif bForceDequeueView then
      if not self.ViewProrityQueue:IsEmpty() then
        local viewData = self.ViewProrityQueue:Dequeue()
        self.CurShowViewData = viewData
        local bHideOther = viewData.Params.bHideOther or false
        UIMgr:Show(viewData.ViewID, bHideOther, table.unpack(viewData.Params))
        for i, v in ipairs(viewData.Params) do
          print("LobbyModule:OnShowViewQueue Force Show Param", i, v)
        end
        print(string.format("LobbyModule:OnShowViewQueue Force Show View %s", UIDef[viewData.ViewID].UIScript))
      else
        self.CurShowViewData = nil
      end
    end
  elseif bRemvoe then
    EventSystem.Invoke(EventDef.ViewAction.ViewProrityQueueEmpty, ViewID)
  end
end
function LobbyModule:AddLabelVisbleDelgate(LabelTag, Obj, Delegate)
  if not self.PagesVisbleDelegateList then
    self.PagesVisbleDelegateList = {}
  end
  if not self.PagesVisbleDelegateList[LabelTag] then
    self.PagesVisbleDelegateList[LabelTag] = {}
  end
  table.insert(self.PagesVisbleDelegateList[LabelTag], {Obj, Delegate})
end
function LobbyModule:RemoveLabelVisbleDelegate(LabelTag, Obj, Delegate)
  if not self.PagesVisbleDelegateList then
    return
  end
  if not self.PagesVisbleDelegateList[LabelTag] then
    return
  end
  for i = #self.PagesVisbleDelegateList[LabelTag], 1, -1 do
    if self.PagesVisbleDelegateList[LabelTag][i][1] == Obj and self.PagesVisbleDelegateList[LabelTag][i][2] == Delegate then
      table.remove(self.PagesVisbleDelegateList[LabelTag], i)
      break
    end
  end
end
function LobbyModule:CheckLabelVisble(LabelTag)
  if not self.PagesVisbleDelegateList then
    return true
  end
  if not self.PagesVisbleDelegateList[LabelTag] then
    return true
  end
  for i = 1, #self.PagesVisbleDelegateList[LabelTag] do
    local func = self.PagesVisbleDelegateList[LabelTag][i][2]
    local obj = self.PagesVisbleDelegateList[LabelTag][i][1]
    if not func(obj) then
      return false
    end
  end
  return true
end
function LobbyModule:CheckShowInitialRoleSelection()
  local myHeroInfo = DataMgr.GetMyHeroInfo()
  if myHeroInfo and not myHeroInfo.bNotInited then
    if myHeroInfo.hasSelectHero == false and myHeroInfo.equipHero <= 0 then
      local initialRoleSelectionView = UIMgr:GetLuaFromActiveView(ViewID.UI_InitialRoleSelection)
      if initialRoleSelectionView then
        UIMgr:Show(ViewID.UI_InitialRoleSelection, true)
      else
        local viewData = {
          ViewID = ViewID.UI_InitialRoleSelection,
          Params = {bHideOther = true}
        }
        local LobbyModule = ModuleManager:Get("LobbyModule")
        LobbyModule:PushView(viewData)
        local SeasonModule = ModuleManager:Get("SeasonModule")
        if SeasonModule then
          SeasonModule:CheckShowSeasonModulePop()
        end
      end
    else
      local SeasonModule = ModuleManager:Get("SeasonModule")
      if SeasonModule then
        SeasonModule:CheckShowSeasonModulePop()
      end
    end
  else
    local callback = function()
      local LobbyModule = ModuleManager:Get("LobbyModule")
      if LobbyModule then
        LobbyModule:CheckShowInitialRoleSelection()
      end
    end
    LogicRole.RequestMyHeroInfoToServer(callback)
  end
end
return LobbyModule
