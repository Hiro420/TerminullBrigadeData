require("Rouge.UI.Battle.Logic.Logic_Scroll")
local rapidjson = require("rapidjson")
local WBP_GRInformationPanel_C = UnLua.Class()

function WBP_GRInformationPanel_C:InitSettlemntPlayerInfo(BoardName, RankInfo)
  local boardName = "?boardName=" .. BoardName
  local uniqueIDs = "&&uniqueIDs=" .. RankInfo.uniqueID
  HttpCommunication.RequestByGet("rank/pulldata" .. boardName .. uniqueIDs, {
    self,
    self.OnSuccess
  }, {
    self,
    self.OnFail
  })
end

function WBP_GRInformationPanel_C:OnSuccess(JsonResponse)
  local Response = rapidjson.decode(JsonResponse.Content)
  if Response.datas and Response.datas[1] then
    self.PlayerInfoList = rapidjson.decode(Response.datas[1]).List
  else
    return
  end
  table.Print(Response)
  self:InitTitle()
  self:UpdateGenericList()
  self:UpdateScrollList()
  self:UpdateView()
end

function WBP_GRInformationPanel_C:OnFail(JsonResponse)
end

function WBP_GRInformationPanel_C:InitTitle()
  self.RGToggleGroupPlayerInfoTitle:ClearGroup()
  for i, PlayerInfo in ipairs(self.PlayerInfoList) do
    local item = GetOrCreateItem(self.HorizontalBoxPlayerInfoTitle, i, self.WBP_SettlementPlayerInfoTitle:GetClass())
    item:InitRankPlayerInfoTitle(tonumber(PlayerInfo.roleId), self.SelectPlayerId)
    self.RGToggleGroupPlayerInfoTitle:AddToGroup(tonumber(PlayerInfo.roleId), item)
  end
  HideOtherItem(self.HorizontalBoxPlayerInfoTitle, #self.PlayerInfoList + 1)
  if self.SelectPlayerId and self.SelectPlayerId > 0 then
    self.RGToggleGroupPlayerInfoTitle:SelectId(self.SelectPlayerId)
  end
  UpdateVisibility(self.CanvasPanelLeft, #self.PlayerInfoList > 1)
  UpdateVisibility(self.CanvasPanelRight, #self.PlayerInfoList > 1)
end

function WBP_GRInformationPanel_C:UpdateGenericList()
  local passiveModifyAry = self.PlayerInfoList[1].genericModifyList
  local index = 1
  for i, v in ipairs(passiveModifyAry) do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitBagRoleGenericItem(nil, UE.ERGGenericModifySlot.None)
    index = index + 1
  end
  for index, value in ipairs(self.WrapBoxGenericModify:GetAllChildren()) do
    value:InitBagRoleGenericItem(nil, UE.ERGGenericModifySlot.None)
  end
  HideOtherItem(self.WrapBoxGenericModify, index)
end

function WBP_GRInformationPanel_C:UpdateScrollList()
  for i = 1, Logic_Scroll.MaxScrollNum do
    local v
    local scrollList = self.PlayerInfoList[1].attributeModifyList
    if scrollList and scrollList[i] then
      v = scrollList[i]
    end
    local item = GetOrCreateItem(self.WrapBoxScrollList, i, self.WBP_ScrollItemSlot_Settlement:GetClass())
    item:UpdateScrollData(v, self.UpdateShowPickupTipsView, self, i)
  end
  HideOtherItem(self.WrapBoxScrollList, Logic_Scroll.MaxScrollNum + 1)
end

function WBP_GRInformationPanel_C:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTips(Data.ModifyId, false, Slot)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    UpdateVisibility(self.WBP_GenericModifyBagTips, true)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end

function WBP_GRInformationPanel_C:UpdateShowPickupTipsView(bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  if ScrollId and ScrollId > 0 then
    self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ScrollId, ScrollTipsOpenType, TargetItem, bIsNeedInit)
    UpdateVisibility(self.WBP_ScrollPickUpTipsView, true)
    self.WBP_ScrollPickUpTipsView:Show(true)
  else
    UpdateVisibility(self.WBP_ScrollPickUpTipsView, false)
  end
end

function WBP_GRInformationPanel_C:UpdateScrollSetTips(bIsShow, ActivatedSetData, ScrollSetItem)
  UpdateVisibility(self.WBP_ScrollSetTips, bIsShow)
  if bIsShow then
    self.WBP_ScrollSetTips:InitScrollSetTips(ActivatedSetData)
    local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
    if TipsCanvasSlot then
      local GeometryScrollSetItem = ScrollSetItem:GetCachedGeometry()
      local GeometryCanvasPanelScroll = self.CanvasPanelScroll:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelScroll, GeometryScrollSetItem)
      TipsCanvasSlot:SetPosition(UE.FVector2D(TipsCanvasSlot:GetPosition().X, Pos.Y))
    end
  end
end

function WBP_GRInformationPanel_C:UpdateView()
  local Diff = 0
  self.RGTextDiffculty:SetText(Diff)
  local Duration = math.floor(3605)
  local Hour = math.floor(Duration / 3600)
  local Min = math.floor((Duration - Hour * 3600) / 60)
  local Sec = Duration - Hour * 3600 - Min * 60
  local TimeStr = string.format("%02d:%02d:%02d", Hour, Min, Sec)
  self.RGTextTime:SetText(TimeStr)
end

return WBP_GRInformationPanel_C
