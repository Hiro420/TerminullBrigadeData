local SeasonData = require("Modules.Season.SeasonData")
local SeasonHandler = require("Protocol.Season.SeasonHandler")
local LocalSeasonModeDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SeasonMode/SeasonModeData_" .. "Default" .. ".json"
local rapidjson = require("rapidjson")
local SeasonModule = LuaClass()

function SeasonModule:Ctor()
  self.bShowSeasonModeSelectPop = false
end

function SeasonModule:OnInit()
  print("SeasonModule:OnInit...........")
  LogicTeam.InitDefaultId()
  self.bHadCheckShowSeasonModulePop = false
  EventSystem.AddListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
end

function SeasonModule:OnShutdown()
  print("SeasonModule:OnShutdown...........")
  EventSystem.RemoveListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
  SeasonModule:SaveSeasonMode()
end

function SeasonModule:BindOnLoginProtocolSuccess()
  self.bHadCheckShowSeasonModulePop = false
end

function SeasonModule:SaveSeasonMode()
  local curSeasonID
  local curSelectSeasonMode = SeasonData.CurSelectSeasonMode
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalSeasonModeDataFilePath)
  if Result then
    local seasonModeData = rapidjson.decode(FileStr)
    curSeasonID = seasonModeData.CurSeasonID
  end
  local seasonModeDataSave = RapidJsonEncode({CurSeasonID = curSeasonID, SaveCurSelectSeasonMode = curSelectSeasonMode})
  print("SeasonModule:SaveSeasonMode seasonModeData = ", curSeasonID, curSelectSeasonMode, seasonModeDataSave)
  UE.URGBlueprintLibrary.SaveStringToFile(LocalSeasonModeDataFilePath, seasonModeDataSave)
end

function SeasonModule:SaveCurSeasonIDToFile()
  local curSeasonID = SeasonData.CurSeasonID
  local curSelectSeasonMode
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalSeasonModeDataFilePath)
  if Result then
    local seasonModeData = rapidjson.decode(FileStr)
    curSelectSeasonMode = seasonModeData.SaveCurSelectSeasonMode
  end
  local seasonModeData = RapidJsonEncode({CurSeasonID = curSeasonID, SaveCurSelectSeasonMode = curSelectSeasonMode})
  UE.URGBlueprintLibrary.SaveStringToFile(LocalSeasonModeDataFilePath, seasonModeData)
end

function SeasonModule:ShowSeasonModePopPanel()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr:IsSystemOpen(SystemOpenID.SEASON_MODE_POP, false) == false then
    return
  end
  local LobbyModule = ModuleManager:Get("LobbyModule")
  if LobbyModule then
    local viewData = {
      ViewID = ViewID.UI_SeasonMode_Pop,
      Params = {}
    }
    LobbyModule:PushView(viewData)
  end
end

function SeasonModule:CheckShowSeasonModulePop()
  if self.bHadCheckShowSeasonModulePop then
    return
  end
  LocalSeasonModeDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/SeasonMode/SeasonModeData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalSeasonModeDataFilePath)
  if Result then
    local seasonModeData = rapidjson.decode(FileStr)
    local saveCurSeasonID = seasonModeData.CurSeasonID
    local seasonMode = seasonModeData.SaveCurSelectSeasonMode or ESeasonMode.SeasonMode
    if saveCurSeasonID == SeasonData.CurSeasonID then
      self:SetSeasonMode(seasonMode)
    else
      self:ShowSeasonModePopPanel()
    end
  else
    self:ShowSeasonModePopPanel()
  end
  self.bHadCheckShowSeasonModulePop = true
end

function SeasonModule:GetCurSeasonID()
  return SeasonData.CurSeasonID
end

function SeasonModule:SetSeasonMode(SeasonModeParam)
  local SeasonMode = ESeasonMode.SeasonMode
  SeasonData.CurSelectSeasonMode = SeasonMode
  EventSystem.Invoke(EventDef.Season.SeasonModeChanged, SeasonMode)
  print("SeasonModule:SetSeasonMode SeasonMode = ", SeasonMode)
  LogicTeam.InitGameModeInfo()
  self:SaveSeasonMode()
end

function SeasonModule:GetSeasonMode()
  return SeasonData.CurSelectSeasonMode
end

function SeasonModule:SelectPastSeasonID(SeasonID)
  SeasonHandler.RequestSelectedPastGrowthSeasonID(SeasonID)
end

function SeasonModule:CheckIsInSeasonMode()
  return SeasonData.CurSelectSeasonMode == ESeasonMode.SeasonMode
end

function SeasonModule:CheckIsInNormal(ModeId)
  return ModeId == TableEnums.ENUMGameMode.SEASONNORMAL or ModeId == TableEnums.ENUMGameMode.NORMAL
end

function SeasonModule:CheckIsInFirstSeason()
  return 1 == SeasonData.CurSeasonID
end

function SeasonModule:GetCurNormalMode()
  if self:CheckIsInSeasonMode() and SeasonData.CurSeasonID > 1 then
    return TableEnums.ENUMGameMode.SEASONNORMAL
  else
    return TableEnums.ENUMGameMode.NORMAL
  end
end

return SeasonModule
