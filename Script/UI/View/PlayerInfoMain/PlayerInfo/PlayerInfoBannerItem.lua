local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local PlayerInfoBannerItem = Class()
function PlayerInfoBannerItem:Construct()
  self.Overridden.Construct(self)
end
function PlayerInfoBannerItem:InitPlayerInfoBannerItem(tbBannerData, BannerState)
  if not tbBannerData then
    error("tbBannerData is nil, please check table tbBannerData:")
    return
  end
  self.RGStateControllerBannerState:ChangeStatus(BannerState)
  local viewModel = UIModelMgr:Get("PlayerInfoViewModel")
  if tbBannerData.bannerID == viewModel:GetDefaultBannerInfo().bannerID then
    self.RGStateControllerEmpty:ChangeStatus(EEmpty.Empty)
  else
    self.RGStateControllerEmpty:ChangeStatus(EEmpty.NotEmpty)
  end
  self.ComBannerItem:InitComBannerItem(tbBannerData.bannerIconPathInInfo, tbBannerData.EffectPath)
  UpdateVisibility(self.WBP_CommonExpireAt, false)
  for index, value in ipairs(PlayerInfoData.BannerData) do
    if value.rid == tbBannerData.bannerID then
      self.WBP_CommonCountdown:SetTargetTimestamp(value.expireAt)
      UpdateVisibility(self.WBP_CommonCountdown, value.expireAt ~= nil and value.expireAt ~= "0" and value.expireAt ~= "" and value.expireAt ~= "1")
      break
    end
  end
end
function PlayerInfoBannerItem:Hide()
  UpdateVisibility(self, false)
end
function PlayerInfoBannerItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end
function PlayerInfoBannerItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end
return PlayerInfoBannerItem
