local INTL_URL_Test = "https://global.yzfchat.com/xv-test/newgames/scene_product.html"
local INTL_SceneId_Test = "1749431703792390"
local INTL_URL = "https://global.yzfchat.com/newgames/scene_product.html"
local INTL_SceneId = "1749176970398259"
local CustomerService_URL = UnLua.Class()

function StrEncode(_kf_params, _salt)
  local bytes = {}
  for i = 1, #_kf_params do
    local cur_unicode = string.byte(_kf_params, i) + _salt
    if cur_unicode >= 33 and cur_unicode <= 126 then
      bytes[i] = cur_unicode
    end
    if cur_unicode > 126 then
      bytes[i] = 32 + cur_unicode - 126
    end
    if cur_unicode < 33 then
      bytes[i] = 126 - (32 + cur_unicode)
    end
  end
  return bytes
end

function StrDecode(_bytes)
  local result = ""
  for i = 1, #_bytes do
    local cur_str = string.char(_bytes[i])
    result = result .. cur_str
  end
  return result
end

local urlEncode = function(s)
  s = string.gsub(s, "([^%w%.%- ])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return string.gsub(s, " ", "+")
end

function UnicodeEncryption(KF_Params)
  local timestamp = os.time()
  local salt = timestamp % 10
  if 9 == salt then
    salt = 8
  end
  if 0 == salt then
    salt = 1
  end
  local bytes = StrEncode(KF_Params, salt)
  local str = StrDecode(bytes)
  local eStr = urlEncode(str)
  print(eStr)
  return eStr, timestamp
end

function CustomerService_URL:Construct()
  self.Overridden.Construct(self)
  UpdateVisibility(self, true)
  self.Btn_LinkToUrl.OnClicked:Add(self, self.OnLinkToUrlClicked)
  EventSystem.AddListenerNew(EventDef.CustomerService.CheatShow, self, self.OnCheatShow)
  EventSystem.AddListenerNew(EventDef.CustomerService.CheatSwitchTest, self, self.OnCheatSwitchTest)
  if DataMgr.GetDistributionChannel() == LogicLobby.DistributionChannelList.LIPass then
    UpdateVisibility(self.Img_LiPassIcon, true)
    UpdateVisibility(self.Img_WeGameIcon, false)
  else
    UpdateVisibility(self.Img_LiPassIcon, false)
    UpdateVisibility(self.Img_WeGameIcon, true)
  end
  self.bUseTestUrl = false
end

function CustomerService_URL:Destruct()
  self.Overridden.Destruct(self)
  self.Btn_LinkToUrl.OnClicked:Remove(self, self.OnLinkToUrlClicked)
  EventSystem.RemoveListenerNew(EventDef.CustomerService.CheatShow, self, self.OnCheatShow)
  EventSystem.RemoveListenerNew(EventDef.CustomerService.CheatSwitchTest, self, self.OnCheatSwitchTest)
end

function CustomerService_URL:OnCheatShow(bShow)
  UpdateVisibility(self, bShow, true)
end

function CustomerService_URL:OnCheatSwitchTest(bTest)
  print("CustomerService_URL:OnCheatSwitchTest", bTest)
  self.bUseTestUrl = bTest
end

function CustomerService_URL:OnLinkToUrlClicked()
  if DataMgr.GetDistributionChannel() == LogicLobby.DistributionChannelList.LIPass then
    local Url = self:GetUrlByTokenIntl()
    print("CustomerService_URL:OnLinkToUrlClicked Intl", Url)
    local INTLSDK = UE.UINTLSDKAPI
    if INTLSDK then
      INTLSDK.OpenUrl(Url, UE.EINTLWebViewOrientation.kAuto, true, true, false, "{\"notch_full_screen\":\194\1601,\194\160\"BG_COLOR\":\194\160\"000000\",\"PROGRESS_TYPE\":\194\1601}")
    else
      print("INTLSDK is nil, cannot open URL")
    end
  else
    local Url = self:GetUrlByToken()
    print("CustomerService_URL:OnLinkToUrlClicked", Url)
    UE.UKismetSystemLibrary.LaunchURL(Url)
  end
end

function CustomerService_URL:GetUrlByToken()
  local ViewModel = UIModelMgr:Get("LoginViewModel")
  local OpenId = ""
  local Access_Token = ""
  if ViewModel and ViewModel.WeGameLoginParam then
    OpenId = ViewModel.WeGameLoginParam.uid or ""
    Access_Token = ViewModel.WeGameLoginParam.sessionTicket or ""
  end
  print("CustomerService_URL:GetUrlByToken", OpenId, Access_Token)
  local BaseUrl = "https://kf.qq.com/touch/kfgames/A11249/v2/PCweb/conf/index.html"
  local Param = {
    scene_id = "CSCE20250507165938NVSbFBEv",
    loginType = "2",
    accountType = "",
    openid = OpenId,
    access_token = Access_Token,
    role = UrlEncode(tostring(DataMgr.GetPlayerNickNameById(DataMgr:GetUserId()))),
    roleid = tostring(DataMgr:GetUserId()),
    appid = "",
    code = "",
    qq = "",
    z = 0,
    zn = ""
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

function CustomerService_URL:GetUrlByTokenIntl()
  local ViewModel = UIModelMgr:Get("LoginViewModel")
  local OpenId = ""
  local token = ""
  local ChannelId = ""
  if ViewModel and ViewModel.LIPassLoginParam then
    OpenId = ViewModel.LIPassLoginParam.uid or ""
    ChannelId = ViewModel.LIPassLoginParam.channelID or ""
    token = ViewModel.LIPassLoginParam.token or ""
  end
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  local TxtCultureTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Interface")
  local TxtCultureValue = RGGameUserSettings:GetGameSettingByTag(TxtCultureTag)
  local Lan = ECultureINTLType[TxtCultureValue]
  print("CustomerService_URL:GetUrlByTokenIntl", OpenId, Lan, token)
  local BaseUrl = INTL_URL
  local SceneId = INTL_SceneId
  if self.bUseTestUrl then
    BaseUrl = INTL_URL_Test
    SceneId = INTL_SceneId_Test
  end
  local Plaintext = string.format("openid=%s&uid=&channelid=%s&token=%s", OpenId, ChannelId, token)
  local Encryption, Salt = UnicodeEncryption(Plaintext)
  local Param = {
    scene_id = SceneId,
    platid = 3,
    appid = "30133",
    encryption = Encryption,
    kftimestamp = Salt,
    role = UrlEncode(tostring(DataMgr.GetBasicInfo().nickname)),
    roleicon = "",
    safe = "0",
    lang_type = Lan,
    sCountry = GetRegionId() or "",
    topc = "1",
    gameid = "30133"
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

return CustomerService_URL
