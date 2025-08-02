local TeamVoiceModule = LuaClass()
local rapidjson = require("rapidjson")
local BanTipId = 303005
local VoiceReportID = {
  [12300] = 303015,
  [12294] = 303017,
  [24577] = 303014
}

function TeamVoiceModule:Ctor()
end

function TeamVoiceModule:OnInit()
  if UE.RGUtil and not UE.RGUtil.IsEditor() and UE.RGUtil.IsDedicatedServer() then
    return
  end
  if UE.UGVoiceSubsystem == nil then
    return
  end
  print("TeamVoiceModule:OnInit...........", UE.UGVoiceSubsystem)
  EventSystem.AddListenerNew(EventDef.WSMessage.banVoice, self, self.OnBanVoice)
end

function TeamVoiceModule:InitGVoice()
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    print("TeamVoiceModule:OnInit1111...........", GVoice)
    if GVoice then
      print("TeamVoiceModule:OnInit()", GVoice)
      GVoice.JoinRoomDelegate:Remove(GVoice, self.OnGVoiceJoinRoom)
      GVoice.ReportPlayerDelegate:Remove(GVoice, self.OnGVoiceReportPlayer)
      GVoice.JoinRoomDelegate:Add(GVoice, self.OnGVoiceJoinRoom)
      GVoice.ReportPlayerDelegate:Add(GVoice, self.OnGVoiceReportPlayer)
    end
  end
end

function TeamVoiceModule:OnShutdown()
  if UE.RGUtil and not UE.RGUtil.IsEditor() and UE.RGUtil.IsDedicatedServer() then
    return
  end
  if UE.UGVoiceSubsystem == nil then
    return
  end
  print("TeamVoiceModule:OnShutdown...........")
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      print("TeamVoiceModule.OnShutdown")
      GVoice.JoinRoomDelegate:Remove(GVoice, self.OnGVoiceJoinRoom)
      GVoice.ReportPlayerDelegate:Remove(GVoice, self.OnGVoiceReportPlayer)
    end
  end
  EventSystem.RemoveListenerNew(EventDef.WSMessage.banVoice, self, self.OnBanVoice)
end

function TeamVoiceModule:OnGVoiceJoinRoom(Code, RoomName, MemberID)
  local curMemberId = LogicTeam.GetVoiceMemberIdByRoleId(DataMgr.GetUserId())
  local curGVoiceRoomName = ""
  if UE.UGVoiceSubsystem == nil then
    return
  end
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      curGVoiceRoomName = GVoice:GetCurrentTeamRoomName()
    end
  end
  print("TeamVoiceModule.OnGVoiceJoinRoom", Code, RoomName, DataMgr.MyTeamInfo.teamid, curGVoiceRoomName, MemberID, curMemberId)
  if 8193 ~= Code then
    return
  end
  local CurrentVoiceRoom = DataMgr.MyTeamInfo.teamid
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice and CurrentVoiceRoom == GVoice:GetCurrentTeamRoomName() and GVoice:GetCurrentTeamRoomName() == RoomName then
      GVoice:OpenSpeaker()
      GVoice:EnableReportAll(true)
      local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
      if VoiceControlModule and VoiceControlModule:CheckIsVoiceControl(GameInstance, function(Obj, evt)
        local VoiceControlModuleTemp = ModuleManager:Get("VoiceControlModule")
        if VoiceControlModuleTemp then
          VoiceControlModuleTemp:OnLiPassEvent(evt, self, function(Obj)
            UE.URGBlueprintLibrary.TriggerClearTempGameSettingValueList()
          end)
        end
      end) then
        print("TeamVoiceModule.OnGVoiceJoinRoom VoiceControlModule.CheckIsVoiceControl failed")
      end
    end
  end
end

function TeamVoiceModule:OnGVoiceReportPlayer(Code, CSZInfo)
  print(string.format("TeamVoiceModule:OnGVoiceReportPlayer Code:%d CSZInfo:%s", Code, CSZInfo))
  local code = VoiceReportID[Code] or 30301
  ShowWaveWindow(code)
end

function TeamVoiceModule:SetMicMode(Mode, bIsSaveGameSetting, bSkipCheckVoiceControl)
  if 0 == Mode then
    local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
    if not bSkipCheckVoiceControl and VoiceControlModule and VoiceControlModule:CheckIsVoiceControl(GameInstance, function(Obj, evt)
      local VoiceControlModuleTemp = ModuleManager:Get("VoiceControlModule")
      if VoiceControlModuleTemp then
        VoiceControlModuleTemp:OnLiPassEvent(evt, self, function(Obj)
          local TeamVoiceModuleTemp = ModuleManager:Get("TeamVoiceModule")
          if TeamVoiceModuleTemp then
            TeamVoiceModule:SetMicMode(0, bIsSaveGameSetting, true)
          end
        end)
      end
    end) then
      print("TeamVoiceModule:SetMicMode VoiceControlModule.CheckIsVoiceControl failed")
      return
    end
    if not CheckIsChannelCommunicateAllowed() then
      ShowWaveWindow(400001)
      return
    end
  end
  local callback = function()
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys then
      TeamVoiceSubSys:SetMicMode(Mode, bIsSaveGameSetting)
    end
  end
  if 0 == Mode then
    print("TeamVoiceModule:SetMicMode Mode:", Mode, bIsSaveGameSetting)
    ChatDataMgr.GetVoiceBanStatus(callback)
  else
    callback()
  end
end

function TeamVoiceModule:OnBanVoice(jsonStr)
  if not jsonStr then
    return
  end
  local rapidjson = require("rapidjson")
  local jsonTable = rapidjson.decode(jsonStr)
  if not jsonTable then
    UnLua.LogError("TeamVoiceModule:OnBanVoice decode json msg failed.")
    return
  end
  local BanReason = jsonTable.banReason
  local BanEndTime = jsonTable.banEndTime
  ChatDataMgr.BanInfo = {
    BanReasonId = BanReason,
    BanEndTime = tonumber(BanEndTime),
    ErrorCode = 17010
  }
  if 0 == BanReason then
    print("TeamVoiceModule:OnBanVoice BanReason Is 0")
    return
  end
  self:SetMicMode(1, true)
  self:ShowBanTips()
end

function TeamVoiceModule:ShowBanTips()
  print("TeamVoiceModule:ShowBanTips", ChatDataMgr.BanInfo.BanReasonId, ChatDataMgr.BanInfo.BanEndTime, ChatDataMgr.BanInfo.ErrorCode)
  local BanReason = "BanReason"
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBanReason, ChatDataMgr.BanInfo.BanReasonId)
  if Result then
    BanReason = RowInfo.Tips
  end
  local ErrorCodeDesc = ""
  local Result, ErrorCodeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBErrorCode, ChatDataMgr.BanInfo.ErrorCode)
  if Result then
    ErrorCodeDesc = ErrorCodeRowInfo.Tips
  end
  local BanEndTimeFormat = TimestampToDateTimeText(ChatDataMgr.BanInfo.BanEndTime)
  local Params = {
    BanReason,
    ErrorCodeDesc,
    BanEndTimeFormat
  }
  ShowWaveWindowWithConsoleCheck(BanTipId, Params, ChatDataMgr.BanInfo.ErrorCode)
end

return TeamVoiceModule
