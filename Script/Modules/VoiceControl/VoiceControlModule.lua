local VoiceControlModule = LuaClass()
local rapidjson = require("rapidjson")

function VoiceControlModule:Ctor()
end

function VoiceControlModule:OnInit()
  print("VoiceControlModule:OnInit...........")
end

function VoiceControlModule:OnShutdown()
  print("VoiceControlModule:OnShutdown...........")
end

function VoiceControlModule:SaveGrowthSnapDataToLocal()
  local localSaveSnapData = SaveGrowthSnapData.SaveGrowthSnapTipNoUseTimes
  local localSaveGrowthSnapDataJson = RapidJsonEncode(localSaveSnapData)
  UE.URGBlueprintLibrary.SaveStringToFile(LocalSaveGrowthSnapFilePath, localSaveGrowthSnapDataJson)
end

function VoiceControlModule:CheckIsVoiceControl(Target, Callback)
  if not self:CheckIsVoiceControlEnable() then
    return false
  end
  local LIPassSystemClass = UE.ULIPassSubsystem:StaticClass()
  local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, LIPassSystemClass)
  if LIPassSystem then
    LIPassSystem:GetSocialFeatureStatus()
    LIPassSystem.Delegate_OnLIEvent:Remove(Target, Callback)
    LIPassSystem.Delegate_OnLIEvent:Add(Target, Callback)
    return true
  else
    print("[LIPass] LIPassSystem is nil")
  end
  return false
end

function VoiceControlModule:RemoveLiEvent(Target, Event)
  if not self:CheckIsVoiceControlEnable() then
    return
  end
  local LIPassSystemClass = UE.ULIPassSubsystem:StaticClass()
  local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, LIPassSystemClass)
  if LIPassSystem then
    if Target and Event then
      LIPassSystem.Delegate_OnLIEvent:Remove(Target, Event)
    else
      LIPassSystem.Delegate_OnLIEvent:Clear()
    end
  else
    print("[LIPass] LIPassSystem is nil")
  end
end

function VoiceControlModule:CheckIsVoiceControlEnable()
  return UE.URGPlatformFunctionLibrary.IsLIPassEnabled()
end

function VoiceControlModule:OnLiPassEvent(evt, Target, Callback)
  local VoiceControlModuleTemp = ModuleManager:Get("VoiceControlModule")
  if nil == VoiceControlModuleTemp then
    print("[LIPass] VoiceControlModule is nil")
    return
  end
  VoiceControlModuleTemp:RemoveLiEvent()
  print("============VoiceControlModule1", evt.EventType, evt.ExtraJson, Target, Callback)
  if evt.EventType == UE.ELIEventType.SOCIAL_FEATURE_APPROVE_STATUS then
    local EventParams = rapidjson.decode(evt.ExtraJson)
    print("============VoiceControlModule2", 0 == EventParams.needVoiceControl, 1 == EventParams.voiceControlStatus)
    if 0 == EventParams.needVoiceControl and 1 == EventParams.voiceControlStatus then
      print("=============VoiceControlModule3")
      Callback(Target)
    elseif 1 == EventParams.needVoiceControl and (1 == EventParams.voiceControlStatus or 0 == EventParams.voiceControlStatus) then
      Callback(Target)
      if VoiceControlModuleTemp and not VoiceControlModuleTemp.LocalVoiceControlData then
        ShowWaveWindow(1552)
        VoiceControlModuleTemp.LocalVoiceControlData = true
      end
    elseif -1 == EventParams.voiceControlStatus then
      ShowWaveWindow(1551)
    end
  end
end

return VoiceControlModule
