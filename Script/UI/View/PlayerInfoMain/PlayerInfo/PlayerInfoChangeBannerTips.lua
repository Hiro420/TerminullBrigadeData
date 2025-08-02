local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local PlayerInfoChangeBannerTips = Class()

function PlayerInfoChangeBannerTips:BindUIInput()
  self.WBP_InteractTipWidgetBuy:BindInteractAndClickEvent(self, self.OnLinkClicked)
end

function PlayerInfoChangeBannerTips:UnBindUIInput()
  self.WBP_InteractTipWidgetBuy:UnBindInteractAndClickEvent(self, self.OnLinkClicked)
end

function PlayerInfoChangeBannerTips:Construct()
  self.Overridden.Construct(self)
end

function PlayerInfoChangeBannerTips:InitPlayerInfoChangeBannerTips()
  self:StopAnimation(self.Ani_out)
  if not CheckIsVisility(self) then
    self:PlayAnimation(self.Ani_in)
  end
  UpdateVisibility(self, true)
  self:BindUIInput()
  self.viewModel = UIModelMgr:Get("PlayerInfoViewModel")
  self.BP_ButtonWithSoundEquip.Onclicked:Add(self, self.OperatorBanner)
  self.RGToggleGroupBanner.OnCheckStateChanged:Add(self, self.OnToggleGroupStateChanged)
  self.BP_ButtonWithSoundLink.Onclicked:Add(self, self.OnLinkClicked)
  self.RGToggleGroupBanner:ClearGroup()
  local num = #self.viewModel:GetOwnerBannerList()
  local sum = self:GetTotalBannerNum()
  local numStr = string.format("%d/%d", num, sum)
  self.RGTextBannerNum:SetText(numStr)
  local defaultBannerId = self.viewModel:GetDefaultBannerInfo().bannerID
  self.WBP_PlayerInfoBannerItem:InitPlayerInfoBannerItem(self.viewModel:GetDefaultBannerInfo(), self.viewModel:GetBannerState(defaultBannerId))
  self.RGToggleGroupBanner:AddToGroup(defaultBannerId, self.WBP_PlayerInfoBannerItem)
  local idx = 2
  local bannerSortList = self.viewModel:GetBannerList()
  for i, v in ipairs(bannerSortList) do
    local BannerState = self.viewModel:GetBannerState(v.bannerID)
    if v.IsUnlockShow and BannerState == EPlayerInfoEquipedState.Lock then
    else
      local item = GetOrCreateItem(self.ScrollBoxBannerList, idx, self.WBP_PlayerInfoBannerItem:GetClass())
      if item.Slot.SetHorizontalAlignment then
        item.Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
      end
      self.RGToggleGroupBanner:AddToGroup(v.bannerID, item)
      item:InitPlayerInfoBannerItem(v, self.viewModel:GetBannerState(v.bannerID))
      idx = idx + 1
    end
  end
  HideOtherItem(self.ScrollBoxBannerList, idx)
  self.RGToggleGroupBanner:SelectId(DataMgr.GetBasicInfo().banner)
end

function PlayerInfoChangeBannerTips:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end

function PlayerInfoChangeBannerTips:GetTotalBannerNum()
  local sum = 0
  local tbBanner = LuaTableMgr.GetLuaTableByName(TableNames.TBBanner)
  if tbBanner then
    for k, v in pairs(tbBanner) do
      sum = sum + 1
    end
  end
  return sum
end

function PlayerInfoChangeBannerTips:OnToggleGroupStateChanged(SelectId)
  self.SelectId = SelectId
  self:UpdateDetails(SelectId)
end

function PlayerInfoChangeBannerTips:UpdateLinkInfo()
  UpdateVisibility(self.BP_ButtonWithSoundLink, false)
  local tbBanner = LuaTableMgr.GetLuaTableByName(TableNames.TBBanner)
  local tbBannerData, tbBannerDataTemp
  if tbBanner then
    for k, v in pairs(tbBanner) do
      if v.bannerID == self.SelectId then
        tbBannerDataTemp = v
        break
      end
    end
    if tbBannerDataTemp and tbBannerDataTemp.acquirePathID > 0 then
      tbBannerData = tbBannerDataTemp
    end
  end
  local state = self.viewModel:GetBannerState(self.SelectId)
  if tbBannerData then
    local goodsId = -1
    if tbBannerData.ParamList and tbBannerData.ParamList[2] then
      goodsId = tbBannerData.ParamList[2]
    end
    self:InitBuyPanel(tbBannerData.acquirePathID, goodsId, state ~= EPlayerInfoEquipedState.Lock, tbBannerData)
    UpdateVisibility(self.BP_ButtonWithSoundLink, true, true)
    UpdateVisibility(self.RGTextLink, true)
    UpdateVisibility(self.CanvasPanelUnableAccess, false)
  elseif state == EPlayerInfoEquipedState.Lock then
    UpdateVisibility(self.RGTextLink, false)
    UpdateVisibility(self.BP_ButtonWithSoundLink, false)
    UpdateVisibility(self.CanvasPanelUnableAccess, true)
    if tbBannerDataTemp and tbBannerDataTemp.LinkDesc then
      self.RGTextAccess:SetText(tbBannerDataTemp.LinkDesc)
    end
  end
end

function PlayerInfoChangeBannerTips:InitBuyPanel(LinkId, GoodsId, bUnlocked, tbBannerData)
  if bUnlocked then
    UpdateVisibility(self.CanvasPanelBuy, false)
    return
  end
  UpdateVisibility(self.CanvasPanelBuy, tonumber(LinkId) == 1007)
  if tonumber(LinkId) == 1007 then
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[GoodsId] then
      local GoodsInfo = TBMall[GoodsId]
      self.WBP_Price:SetPrice(GoodsInfo.ConsumeResources[1].z, GoodsInfo.ConsumeResources[1].y, GoodsInfo.ConsumeResources[1].x)
      UpdateVisibility(self.WBP_Price_1, GoodsInfo.ConsumeResources[2] ~= nil)
      if GoodsInfo.ConsumeResources[2] then
        self.WBP_Price_1:SetPrice(GoodsInfo.ConsumeResources[2].y, GoodsInfo.ConsumeResources[2].z, GoodsInfo.ConsumeResources[2].x)
      end
    end
  elseif tbBannerData and tbBannerData.LinkDesc then
    self.RGTextLink:SetText(tbBannerData.LinkDesc)
  end
end

function PlayerInfoChangeBannerTips:UpdateDetails(SelectId)
  local tbBannerData = self.viewModel:GetTBBannerDataByBannerId(SelectId)
  if not tbBannerData and SelectId > 0 then
    print("tbBannerData is nil, please check table tbBannerData, bannerID is:", SelectId)
    return
  end
  self.RGTextBannerName:SetText(tbBannerData.bannerName)
  self.RGStateControllerBannerState:ChangeStatus(self.viewModel:GetBannerState(SelectId))
  self:UpdateLinkInfo()
  UpdateVisibility(self.WBP_CommonExpireAt, false)
  for index, value in ipairs(PlayerInfoData.BannerData) do
    if value.rid == SelectId then
      self.WBP_CommonExpireAt:InitCommonExpireAt(value.expireAt)
      UpdateVisibility(self.WBP_CommonExpireAt, value.expireAt ~= nil and value.expireAt ~= "0" and value.expireAt ~= "" and value.expireAt ~= "1")
      break
    end
  end
end

function PlayerInfoChangeBannerTips:OperatorBanner()
  self.viewModel:OperatorBanner(self.SelectId)
end

function PlayerInfoChangeBannerTips:OnLinkClicked()
  local tbBanner = LuaTableMgr.GetLuaTableByName(TableNames.TBBanner)
  if tbBanner then
    local tbBannerDataTemp
    for k, v in pairs(tbBanner) do
      if v.bannerID == self.SelectId then
        tbBannerDataTemp = v
        break
      end
    end
    if tbBannerDataTemp and not LinkPurchaseConfirm(tbBannerDataTemp.acquirePathID, tbBannerDataTemp.ParamList) then
      local result, row = GetRowData(DT.DT_CommonLink, tbBannerDataTemp.acquirePathID)
      if result and row.ComLinkType == UE.EComLink.LinkToView and row.UIName == "UI_PlayerInfoMain" then
        local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
        local roleID = playerInfoMainVM:GetCurRoleID()
        local callback = function()
          local playerInfoMainVMTemp = UIModelMgr:Get("PlayerInfoMainViewModel")
          playerInfoMainVMTemp:HidePlayerMainView(true)
        end
        ComLink(tostring(tbBannerDataTemp.acquirePathID), callback, roleID)
      else
        local callback
        
        function callback()
          local playerInfoMainVMTemp = UIModelMgr:Get("PlayerInfoMainViewModel")
          playerInfoMainVMTemp:HidePlayerMainView(true)
          local LobbyDefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
          EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LobbyDefaultLabelName)
        end
        
        ComLink(tostring(tbBannerDataTemp.acquirePathID), callback)
      end
    end
  end
end

function PlayerInfoChangeBannerTips:Hide()
  self.RGToggleGroupBanner.OnCheckStateChanged:Remove(self, self.OnToggleGroupStateChanged)
  self.BP_ButtonWithSoundLink.Onclicked:Remove(self, self.OnLinkClicked)
  self.BP_ButtonWithSoundEquip.Onclicked:Remove(self, self.OperatorBanner)
  self:UnBindUIInput()
  SetHitTestInvisible(self)
  self:PlayAnimation(self.Ani_out)
end

function PlayerInfoChangeBannerTips:OnMouseEnter(MyGeometry, MouseEvent)
end

function PlayerInfoChangeBannerTips:OnMouseLeave(MyGeometry, MouseEvent)
end

return PlayerInfoChangeBannerTips
