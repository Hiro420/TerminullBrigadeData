local KoreaComplianceModule = LuaClass()
local rapidjson = require("rapidjson")
local RedDotData = require("Modules.RedDot.RedDotData")
local MailHandler = require("Protocol.Mail.MailHandler")
local MailData = require("Modules.Mail.MailData")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local IllustratedGuideHandler = require("Protocol.IllustratedGuide.IllustratedGuideHandler")
local ChipData = require("Modules.Chip.ChipData")
local AchievementData = require("Modules.Achievement.AchievementData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
local LocalRedDotDataFilePath
local TickInterval = 60
local HourInterval = 3600

function KoreaComplianceModule:Ctor()
end

function KoreaComplianceModule:OnInit()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("KoreaComplianceModule:OnInit...........")
  EventSystem.AddListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
end

function KoreaComplianceModule:OnShutdown()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("KoreaComplianceModule:OnShutdown...........")
  self:StopCheckNeedSaveToFileTimer()
  EventSystem.RemoveListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
  self:SaveKoreaComplianceDataToLocal()
end

function KoreaComplianceModule:SaveKoreaComplianceDataToLocal()
  if IsPlayerAdult() then
    return
  end
  local RedDotNumListJson = RapidJsonEncode(KoreaComplianceModule.LoginData)
  if LocalRedDotDataFilePath then
    UE.URGBlueprintLibrary.SaveStringToFile(LocalRedDotDataFilePath, RedDotNumListJson)
  end
end

function KoreaComplianceModule:StartCheckNeedSaveToFileTimer()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.KoreaComplianceSaveToFileTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.KoreaComplianceSaveToFileTimer)
  end
  self.KoreaComplianceSaveToFileTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    KoreaComplianceModule.CheckNeedSaveToFile
  }, TickInterval, true)
end

function KoreaComplianceModule:StopCheckNeedSaveToFileTimer()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.KoreaComplianceSaveToFileTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.KoreaComplianceSaveToFileTimer)
  end
end

function KoreaComplianceModule:CheckNeedSaveToFile()
  if not KoreaComplianceModule.LastShowPic then
    return
  end
  local CurrentTime = GetTimeWithServerDelta()
  local LoginView = UIMgr:GetLuaFromActiveView(ViewID.UI_Login)
  if CurrentTime - KoreaComplianceModule.LastShowPic >= HourInterval and not LoginView then
    KoreaComplianceModule.LastShowPic = CurrentTime
    EventSystem.Invoke(EventDef.KoreaCompliance.ShowAgePic)
  end
  if KoreaComplianceModule:IsCrossDay() then
    KoreaComplianceModule.LoginData.LoginTime = GetTimeWithServerDelta()
    KoreaComplianceModule.LoginData.DailyLoginDuration = 0
    KoreaComplianceModule.DailyShowTipCount = 0
  else
    KoreaComplianceModule.LoginData.DailyLoginDuration = KoreaComplianceModule.LoginData.DailyLoginDuration + TickInterval
    local DailyShowTipCount = math.floor(KoreaComplianceModule.LoginData.DailyLoginDuration / HourInterval)
    if DailyShowTipCount > KoreaComplianceModule.DailyShowTipCount and not IsPlayerAdult() then
      KoreaComplianceModule.DailyShowTipCount = DailyShowTipCount
      KoreaComplianceModule:SendMsg()
    end
  end
  KoreaComplianceModule:SaveKoreaComplianceDataToLocal()
end

function KoreaComplianceModule:SendMsg()
  local msg = {
    SystemMsgID = tonumber(5),
    extra = {
      params = {
        KoreaComplianceModule.DailyShowTipCount
      }
    },
    channelId = UE.EChatChannel.System
  }
  local msgJson = RapidJsonEncode(msg)
  ChatDataMgr.OnChatMsg(msgJson)
end

function KoreaComplianceModule:BindOnLoginProtocolSuccess()
  if not KoreaComplianceModule:IsKorea() then
    self:StopCheckNeedSaveToFileTimer()
    return
  end
  LocalRedDotDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/KoreaCompliance/KoreaComplianceData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalRedDotDataFilePath)
  if Result then
    KoreaComplianceModule.LoginData = rapidjson.decode(FileStr)
  end
  if not KoreaComplianceModule.LoginData then
    KoreaComplianceModule.LoginData = {}
    KoreaComplianceModule.LoginData.LoginTime = GetTimeWithServerDelta()
    KoreaComplianceModule.LoginData.DailyLoginDuration = 0
  end
  local LastLoginTime = KoreaComplianceModule.LoginData.LoginTime or GetTimeWithServerDelta()
  KoreaComplianceModule.LoginData.LoginTime = GetTimeWithServerDelta()
  if not IsSameDay(LastLoginTime, KoreaComplianceModule.LoginData.LoginTime, 5) then
    KoreaComplianceModule.LoginData.DailyLoginDuration = 0
  end
  if not KoreaComplianceModule.LoginData.DailyLoginDuration then
    KoreaComplianceModule.LoginData.DailyLoginDuration = 0
  end
  KoreaComplianceModule.DailyShowTipCount = math.floor(KoreaComplianceModule.LoginData.DailyLoginDuration / HourInterval)
  KoreaComplianceModule.LastShowPic = GetTimeWithServerDelta()
  KoreaComplianceModule:StartCheckNeedSaveToFileTimer()
end

function KoreaComplianceModule:IsCrossDay()
  if not KoreaComplianceModule.LoginData then
    return false
  end
  if not KoreaComplianceModule.LoginData.LoginTime then
    return false
  end
  local CurrentTime = GetTimeWithServerDelta()
  if not IsSameDay(CurrentTime, KoreaComplianceModule.LoginData.LoginTime, 5) then
    return true
  end
  return false
end

function KoreaComplianceModule:IsKorea()
  local AccountCom = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGAccountSubsystem:StaticClass())
  if AccountCom then
    local RegionCode = AccountCom:GetRegion()
    if "410" == RegionCode then
      return true
    end
  end
  return false
end

return KoreaComplianceModule
