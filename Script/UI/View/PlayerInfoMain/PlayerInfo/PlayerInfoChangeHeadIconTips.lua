local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local PlayerInfoChangeHeadIconTips = Class()

function PlayerInfoChangeHeadIconTips:BindUIInput()
  self.WBP_InteractTipWidgetBuy:BindInteractAndClickEvent(self, self.OperatorHeadIcon)
end

function PlayerInfoChangeHeadIconTips:UnBindUIInput()
  self.WBP_InteractTipWidgetBuy:UnBindInteractAndClickEvent(self, self.OperatorHeadIcon)
end

function PlayerInfoChangeHeadIconTips:Construct()
  self.Overridden.Construct(self)
end

function PlayerInfoChangeHeadIconTips:InitPlayerInfoChangeHeadIconTips()
  self:StopAnimation(self.Ani_out)
  if not CheckIsVisility(self) then
    self:PlayAnimation(self.Ani_in)
  end
  UpdateVisibility(self, true)
  self:BindUIInput()
  self.viewModel = UIModelMgr:Get("PlayerInfoViewModel")
  self.BP_ButtonWithSoundEquip.Onclicked:Add(self, self.OperatorHeadIcon)
  self.RGToggleGroupHeadIcon.OnCheckStateChanged:Add(self, self.OnToggleGroupStateChanged)
  self.BP_ButtonWithSoundLink.Onclicked:Add(self, self.OnLinkClicked)
  self.RGToggleGroupHeadIcon:ClearGroup()
  local num = #self.viewModel:GetOwnerPortraitList()
  local sum = self:GetTotalHeadIconNum()
  local numStr = string.format("%d/%d", num, sum)
  self.RGTextHeadIconNum:SetText(numStr)
  local poritraitSortList = self.viewModel:GetPortraitList()
  local index = 1
  for i, v in ipairs(poritraitSortList) do
    local HeadIconState = self.viewModel:GetHeadIconState(v.portraitID)
    if v.IsUnlockShow and HeadIconState == EPlayerInfoEquipedState.Lock then
    else
      local item = GetOrCreateItem(self.WrapBoxHeadIconList, index, self.WBP_PlayerInfoHeadIconItem:GetClass())
      index = index + 1
      self.RGToggleGroupHeadIcon:AddToGroup(v.portraitID, item)
      item:InitPlayerInfoHeadIconItem(v.portraitID, self.viewModel:GetHeadIconState(v.portraitID))
    end
  end
  HideOtherItem(self.WrapBoxHeadIconList, #poritraitSortList + 1)
  self.RGToggleGroupHeadIcon:SelectId(DataMgr.GetBasicInfo().portrait)
end

function PlayerInfoChangeHeadIconTips:UpdateLinkInfo()
  UpdateVisibility(self.BP_ButtonWithSoundLink, false)
  local tbPortrait = LuaTableMgr.GetLuaTableByName(TableNames.TBPortrait)
  local tbPortraitData, tbPortraitDataTemp
  if tbPortrait then
    for k, v in pairs(tbPortrait) do
      if v.portraitID == self.SelectId then
        tbPortraitDataTemp = v
        break
      end
    end
    if tbPortraitDataTemp and tbPortraitDataTemp.acquirePathID > 0 then
      tbPortraitData = tbPortraitDataTemp
    end
  end
  local state = self.viewModel:GetHeadIconState(self.SelectId)
  if tbPortraitData then
    local goodsId = -1
    if tbPortraitData.ParamList and tbPortraitData.ParamList[2] then
      goodsId = tbPortraitData.ParamList[2]
    end
    self:InitBuyPanel(tbPortraitData.acquirePathID, goodsId, state ~= EPlayerInfoEquipedState.Lock, tbPortraitData)
    UpdateVisibility(self.BP_ButtonWithSoundLink, true, true)
    UpdateVisibility(self.CanvasPanelUnableAccess, false)
    UpdateVisibility(self.RGTextLink, true)
  elseif state == EPlayerInfoEquipedState.Lock then
    UpdateVisibility(self.CanvasPanelUnableAccess, true)
    UpdateVisibility(self.BP_ButtonWithSoundLink, false)
    UpdateVisibility(self.RGTextLink, false)
    if tbPortraitDataTemp and tbPortraitDataTemp.LinkDesc then
      self.RGTextAccess:SetText(tbPortraitDataTemp.LinkDesc)
    end
  end
end

function PlayerInfoChangeHeadIconTips:InitBuyPanel(LinkId, GoodsId, bUnlocked, tbPortraitData)
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
  elseif tbPortraitData and tbPortraitData.LinkDesc then
    self.RGTextLink:SetText(tbPortraitData.LinkDesc)
  end
end

function PlayerInfoChangeHeadIconTips:GetTotalHeadIconNum()
  local sum = 0
  local tbPortrait = LuaTableMgr.GetLuaTableByName(TableNames.TBPortrait)
  if tbPortrait then
    for k, v in pairs(tbPortrait) do
      sum = sum + 1
    end
  end
  return sum
end

function PlayerInfoChangeHeadIconTips:OnToggleGroupStateChanged(SelectId)
  self.SelectId = SelectId
  self:UpdateDetails(SelectId)
end

function PlayerInfoChangeHeadIconTips:UpdateDetails(SelectId)
  local tbPortraitData = LogicLobby.GetPlayerPortraitTableRowInfo(SelectId)
  if not tbPortraitData then
    error("tbPortraitData is nil, please check table TBPortraitData, portraitId is:", SelectId)
    return
  end
  self.RGTextHeadIconName:SetText(tbPortraitData.portraitName)
  self.RGStateControllerHeadState:ChangeStatus(self.viewModel:GetHeadIconState(SelectId))
  self:UpdateLinkInfo()
  UpdateVisibility(self.WBP_CommonExpireAt, false)
  for index, value in ipairs(PlayerInfoData.PortraitData) do
    if value.rid == SelectId then
      self.WBP_CommonExpireAt:InitCommonExpireAt(value.expireAt)
      UpdateVisibility(self.WBP_CommonExpireAt, value.expireAt ~= nil and value.expireAt ~= "0" and value.expireAt ~= "" and value.expireAt ~= "1")
      break
    end
  end
end

function PlayerInfoChangeHeadIconTips:OperatorHeadIcon()
  self.viewModel:OperatorHeadIcon(self.SelectId)
end

function PlayerInfoChangeHeadIconTips:OnLinkClicked()
  local tbPortrait = LuaTableMgr.GetLuaTableByName(TableNames.TBPortrait)
  if tbPortrait then
    local tbPortraitDataTemp
    for k, v in pairs(tbPortrait) do
      if v.portraitID == self.SelectId then
        tbPortraitDataTemp = v
        break
      end
    end
    if tbPortraitDataTemp and not LinkPurchaseConfirm(tbPortraitDataTemp.acquirePathID, tbPortraitDataTemp.ParamList) then
      local result, row = GetRowData(DT.DT_CommonLink, tbPortraitDataTemp.acquirePathID)
      if result and row.ComLinkType == UE.EComLink.LinkToView and row.UIName == "UI_PlayerInfoMain" then
        local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
        local roleID = playerInfoMainVM:GetCurRoleID()
        local callback = function()
          local playerInfoMainVMTemp = UIModelMgr:Get("PlayerInfoMainViewModel")
          playerInfoMainVMTemp:HidePlayerMainView(true)
        end
        CommonLinkEx(nil, tostring(tbPortraitDataTemp.acquirePathID), callback, roleID)
      else
        local callback
        
        function callback()
          local playerInfoMainVMTemp = UIModelMgr:Get("PlayerInfoMainViewModel")
          playerInfoMainVMTemp:HidePlayerMainView(true)
          local LobbyDefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
          EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LobbyDefaultLabelName)
        end
        
        CommonLinkEx(nil, tostring(tbPortraitDataTemp.acquirePathID), callback)
      end
    end
  end
end

function PlayerInfoChangeHeadIconTips:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end

function PlayerInfoChangeHeadIconTips:Hide()
  self:UnBindUIInput()
  self.BP_ButtonWithSoundEquip.Onclicked:Remove(self, self.OperatorHeadIcon)
  self.RGToggleGroupHeadIcon.OnCheckStateChanged:Remove(self, self.OnToggleGroupStateChanged)
  self.BP_ButtonWithSoundLink.Onclicked:Remove(self, self.OnLinkClicked)
  SetHitTestInvisible(self)
  self:PlayAnimation(self.Ani_out)
end

return PlayerInfoChangeHeadIconTips
