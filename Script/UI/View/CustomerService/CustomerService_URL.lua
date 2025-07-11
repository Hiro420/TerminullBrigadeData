local INTL_URL_Test = "https://global.yzfchat.com/xv-test/newgames/scene_product.html"
local INTL_SceneId_Test = "1749431703792390"
local INTL_URL = "https://global.yzfchat.com/newgames/scene_product.html"
local INTL_SceneId = "1749176970398259"
local CustomerService_URL = UnLua.Class()
function CustomerService_URL:Construct()
  self.Overridden.Construct(self)
  UpdateVisibility(self, true, true)
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
  self.bUseTestUrl = bTest
end
function CustomerService_URL:OnLinkToUrlClicked()
  if DataMgr.GetDistributionChannel() == LogicLobby.DistributionChannelList.LIPass then
    local Url = self:GetUrlByTokenIntl()
    print("CustomerService_URL:OnLinkToUrlClicked Intl", Url)
    UE.UKismetSystemLibrary.LaunchURL(Url)
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
  local BaseUrl = "https://kf.qq.com/touch/kfgames/A11249/v2/PClient/conf/index.html"
  local Param = {
    scene_id = "CSCE20250507172254DbklDZrr",
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
  local ChannelId = ""
  if ViewModel and ViewModel.LIPassLoginParam then
    OpenId = ViewModel.LIPassLoginParam.uid or ""
    ChannelId = ViewModel.LIPassLoginParam.channelID or ""
  end
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  local TxtCultureTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Interface")
  local TxtCultureValue = RGGameUserSettings:GetGameSettingByTag(TxtCultureTag)
  local Lan = ECultureINTLType[TxtCultureValue]
  print("CustomerService_URL:GetUrlByTokenIntl", OpenId, Lan)
  local BaseUrl = INTL_URL
  local SceneId = INTL_SceneId
  if self.bUseTestUrl then
    BaseUrl = INTL_URL_Test
    SceneId = INTL_SceneId_Test
  end
  local Param = {
    scene_id = SceneId,
    platid = 3,
    channelid = ChannelId,
    appid = "30133",
    openid = OpenId,
    uid = "",
    role = UrlEncode(tostring(DataMgr.GetBasicInfo().nickname)),
    roleicon = "",
    safe = "0",
    lang_type = Lan,
    sCountry = GetRegionId() or "",
    topc = "1",
    screenOrientation = 1,
    fullScreenEnable = "true",
    encryptEnable = "true",
    systemBrowserEnable = "false",
    extraJson = "{\"notch_full_screen\":\194\1601,\194\160\"BG_COLOR\":\194\160\"000000\",\"PROGRESS_TYPE\":\194\1601}"
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
