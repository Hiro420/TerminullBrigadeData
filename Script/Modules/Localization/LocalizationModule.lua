local LocalizationModule = LuaClass()
local LocalizationConfig = require("GameConfig.Localization.LocalizationConfig")
function LocalizationModule:Ctor()
end
function LocalizationModule:OnInit()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("LocalizationModule:OnInit...........")
  EventSystem.AddListenerNew(EventDef.GameSettings.OnSettingsSaved, self, self.BindOnSettingsSaved)
  if not UE.RGUtil or not UE.RGUtil.IsEditor() then
    local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
    local TxtCultureTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Interface")
    local TxtCultureValue = RGGameUserSettings:GetGameSettingByTag(TxtCultureTag)
    self:LuaCustomSetCurrentCulture(ECultureType[TxtCultureValue], false)
  end
end
function LocalizationModule:OnShutdown()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("LocalizationModule:OnShutdown...........")
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnSettingsSaved, self, self.BindOnSettingsSaved)
end
function LocalizationModule:BindOnSettingTempValue(TagName, SettingValue)
  if "Settings.Language.Common.Interface" == TagName then
    self:LuaCustomSetCurrentCulture(ECultureType[SettingValue], true)
  end
end
function LocalizationModule:BindOnSettingsSaved()
  if UE.RGUtil and UE.RGUtil.IsEditor() then
    return
  end
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  local TxtCultureTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Interface")
  local TxtCultureValue = RGGameUserSettings:GetGameSettingByTag(TxtCultureTag)
  self:LuaCustomSetCurrentCulture(ECultureType[TxtCultureValue], true)
  local voiceCultureTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Voice")
  local voicCultureValue = RGGameUserSettings:GetGameSettingByTag(voiceCultureTag)
  UE.UAudioManager.SetVoiceLanguage(EVoiceCultureType[voicCultureValue])
end
function LocalizationModule:LuaCustomSetCurrentCulture(InCulture, bOnlySaveToConfig)
  self.CurCulture = InCulture
  UE.URGBlueprintLibrary.CustomSetCurrentCulture(InCulture, bOnlySaveToConfig)
end
function LocalizationModule:CheckIsCN()
  if not self.CurCulture then
    return true
  end
  return self.CurCulture == ECultureType[0] or self.CurCulture == "zh-Hans-CN"
end
return LocalizationModule
