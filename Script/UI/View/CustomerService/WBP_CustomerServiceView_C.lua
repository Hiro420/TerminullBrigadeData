local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UIUtil = require("Framework.UIMgr.UIUtil")
local rapidjson = require("rapidjson")
local WBP_CustomerServiceView_C = Class(ViewBase)
local LanguageType = {
  [0] = "zh",
  [1] = "en"
}
function WBP_CustomerServiceView_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_CustomerServiceView_C:OnDestroy()
  self.Overridden.Destruct(self)
end
function WBP_CustomerServiceView_C:OnShow(...)
  print("WBP_CustomerServiceView_C:OnShow CursorVirtualFocus 1")
  UE.URGBlueprintLibrary.CursorVirtualFocus(1)
  self:OnDisplay()
end
function WBP_CustomerServiceView_C:OnHide(...)
  print("WBP_CustomerServiceView_C:OnHide CursorVirtualFocus 0")
  UE.URGBlueprintLibrary.CursorVirtualFocus(0)
  self:OnUnDisplay()
end
function WBP_CustomerServiceView_C:OnDisplay()
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.ListenForEscInputAction)
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self, UE.EMouseLockMode.LockAlways)
  if not UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    HttpCommunication.RequestByGet("diplomat/vlink/token", {
      GameInstance,
      function(Target, JsonResponse)
        local token = rapidjson.decode(JsonResponse.Content).token
        local url = self:GetUrlByToken(token)
        self.RGWebBrowser:LoadURL(url)
        self.RGWebBrowser:RefreshInputMethod()
      end
    }, {
      GameInstance,
      function()
        UnLua.LogError("\228\187\142\229\144\142\231\171\175\232\142\183\229\143\150\231\159\165\229\183\177token\229\164\177\232\180\165!")
      end
    })
  else
    HttpCommunication.RequestByGet("diplomat/vlink/token", {
      GameInstance,
      function(Target, JsonResponse)
        local token = rapidjson.decode(JsonResponse.Content).token
        local sign = rapidjson.decode(JsonResponse.Content).sign
        local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
        local language_tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Interface")
        local language = LanguageType[RGGameUserSettings:GetGameSettingByTag(language_tag)]
        local url = self:GetUrlByTokenAndSign(token, sign, language)
        self.RGWebBrowser:LoadURL(url)
        self.RGWebBrowser:RefreshInputMethod()
      end
    }, {
      GameInstance,
      function()
        UnLua.LogError("\228\187\142\229\144\142\231\171\175\232\142\183\229\143\150\231\159\165\229\183\177token\229\164\177\232\180\165!")
      end
    })
  end
end
function WBP_CustomerServiceView_C:OnUnDisplay()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
end
function WBP_CustomerServiceView_C:ListenForEscInputAction()
  if LogicLobby.IsInLobbyLevel() then
    UIMgr:Hide(ViewID.UI_CustomerServiceView, true)
    UIMgr:DestroyView(self, ViewID.UI_CustomerServiceView)
  else
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if not UIManager then
      return
    end
    local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/CustomerService/WBP_CustomerServiceView.WBP_CustomerServiceView_C")
    UIManager:Switch(WidgetClass, true)
  end
end
function WBP_CustomerServiceView_C:GetUrlByToken(Token)
  local BaseUrl = "https://xyapi.game.qq.com/xiaoyue/service/redirect"
  local Param = {
    game_id = "21216",
    source = "xy_games",
    login_type = "zhiji",
    system_id = "1",
    plat_id = "2",
    role_id = tostring(DataMgr:GetUserId()),
    area_id = "0",
    partition_id = "0",
    role_name = UrlEncode(tostring(DataMgr.GetPlayerNickNameById(DataMgr:GetUserId()))),
    region_id = "1",
    fullscreen = "0",
    openid = tostring(DataMgr:GetUserId()),
    token = Token
  }
  local UrlParamStr
  for k, v in pairs(Param) do
    if not UrlParamStr then
      UrlParamStr = k .. "=" .. v
    else
      UrlParamStr = UrlParamStr .. "&" .. k .. "=" .. v
    end
  end
  return BaseUrl .. "?" .. UrlParamStr
end
function WBP_CustomerServiceView_C:GetUrlByTokenAndSign(Token, Sign, Language)
  local BaseUrl = "https://test-h5.vlinkapi.com/pc/index.html"
  local Param = {
    itop_game_id = "88913",
    channel_id = "21",
    os = "5",
    ts = tostring(GetCurrentUTCTimestamp()),
    seq = tostring(GetCurrentUTCTimestamp()),
    itop_source = "0",
    sig = Sign,
    env = "1",
    token = Token,
    open_id = tostring(DataMgr:GetUserId()),
    business_id = "1020",
    game_id = "88913",
    source = "pc",
    language = Language,
    login_type = "24",
    role_name = UrlEncode(tostring(DataMgr.GetPlayerNickNameById(DataMgr:GetUserId())))
  }
  local UrlParamStr
  for k, v in pairs(Param) do
    if not UrlParamStr then
      UrlParamStr = k .. "=" .. v
    else
      UrlParamStr = UrlParamStr .. "&" .. k .. "=" .. v
    end
  end
  return BaseUrl .. "?" .. UrlParamStr
end
function WBP_CustomerServiceView_C:FocusInput()
  self.Overridden.FocusInput(self)
  local Pawn = self:GetOwningPlayerPawn()
  if not Pawn then
    return
  end
  SetInputIgnore(Pawn, true)
  local InputComp = Pawn:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
  InputComp:SetMoveInputIgnored(false)
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_CustomerServiceView_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  local PC = self:GetOwningPlayer()
  local Pawn = self:GetOwningPlayerPawn()
  if not PC or not Pawn then
    return
  end
  SetInputIgnore(Pawn, false)
  self:SetEnhancedInputActionBlocking(false)
end
return WBP_CustomerServiceView_C
