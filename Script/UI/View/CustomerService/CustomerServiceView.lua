local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UIUtil = require("Framework.UIMgr.UIUtil")
local rapidjson = require("rapidjson")
local CustomerServiceView = Class(ViewBase)
local LanguageType = {
  [0] = "zh",
  [1] = "en"
}
function CustomerServiceView:BindClickHandler()
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.ListenForEscInputAction)
end
function CustomerServiceView:UnBindClickHandler()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
end
function CustomerServiceView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function CustomerServiceView:OnDestroy()
  self:UnBindClickHandler()
end
function CustomerServiceView:OnShow(...)
  if not LogicLobby.IsInit then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return
    end
    SetInputMode_GameAndUIEx(PC, nil, UE.EMouseLockMode.LockAlways)
    PC.bShowMouseCursor = true
    SetInputIgnore(self:GetOwningPlayerPawn(), true)
    self:SetEnhancedInputActionBlocking(true)
  end
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
function CustomerServiceView:OnHide()
  if not LogicLobby.IsInit then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return
    end
    UE.UCommonInputLibrary.SetInputMode_GameOnly(PC)
    PC.bShowMouseCursor = false
    SetInputIgnore(self:GetOwningPlayerPawn(), false)
    self:SetEnhancedInputActionBlocking(false)
  end
end
function CustomerServiceView:ListenForEscInputAction()
  UIMgr:Hide(ViewID.UI_CustomerServiceView, true)
  UIMgr:DestroyView(self, ViewID.UI_CustomerServiceView)
end
function CustomerServiceView:GetUrlByToken(Token)
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
function CustomerServiceView:GetUrlByTokenAndSign(Token, Sign, Language)
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
return CustomerServiceView
