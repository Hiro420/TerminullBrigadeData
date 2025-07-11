local SocailPlayerInfoTips = Class()
function SocailPlayerInfoTips:Construct()
  self.Overridden.Construct(self)
end
function SocailPlayerInfoTips:InitSocailPlayerInfoTips(PlayerInfo)
  self:StopAnimation(self.Ani_out)
  UpdateVisibility(self, true)
  self.achievementViewModel = UIModelMgr:Get("AchievementViewModel")
  self.playerInfoViewModel = UIModelMgr:Get("PlayerInfoViewModel")
  if self.playerInfoViewModel then
    local tbBannerData = self.playerInfoViewModel:GetTBBannerDataByBannerId(PlayerInfo.banner)
    if tbBannerData then
      self.ComBannerItem:InitComBannerItem(tbBannerData.bannerIconPathInInfo, tbBannerData.EffectPath)
    end
  end
  local tbPortraitData = LogicLobby.GetPlayerPortraitTableRowInfo(PlayerInfo.portrait)
  self.ComPortraitItem:InitComPortraitItem(tbPortraitData.portraitIconPath, tbPortraitData.EffectPath)
  self.RGTextNickName:SetText(PlayerInfo.nickname)
  if self.PlatformIconPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo SocailPlayerInfoTips PlayerInfo.roleid: %s", tostring(PlayerInfo.roleid)))
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo SocailPlayerInfoTips PlayerInfo.channelUID: %s", tostring(PlayerInfo.channelUID)))
    self.PlatformIconPanel:UpdateChannelInfo(PlayerInfo.roleid, false, PlayerInfo.channelUID)
  end
  self.achievementViewModel:RequestGetAchievementInfo(PlayerInfo.roleid, function(displayBadges, point)
    self.RGTextAchievementPoint:SetText(point)
    local badges = displayBadges or {}
    local displayBadgesCopy = DeepCopy(badges)
    local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    table.sort(displayBadgesCopy, function(a, b)
      if tbGeneral and tbGeneral[tonumber(a)] and tbGeneral[tonumber(b)] then
        local rareA = tbGeneral[tonumber(a)].Rare
        local rareB = tbGeneral[tonumber(b)].Rare
        if rareA ~= rareB then
          return rareA > rareB
        end
      end
      return b < a
    end)
    for i, v in ipairs(displayBadgesCopy) do
      local item = GetOrCreateItem(self.WrapBoxAchievementBadges, i, self.WBP_AchievePlayerInfoBadgesItem:GetClass())
      item:InitAchievePlayerInfoBadgesItem(v)
    end
    HideOtherItem(self.WrapBoxAchievementBadges, #displayBadgesCopy + 1)
  end, false)
  self:PlayAnimation(self.Ani_in)
end
function SocailPlayerInfoTips:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end
function SocailPlayerInfoTips:Hide()
  self:StopAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_out)
end
return SocailPlayerInfoTips
