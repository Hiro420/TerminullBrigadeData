local EscName = "PauseGame"
local SpaceName = "Space"
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local ProficiencyHandler = require("Protocol.Proficiency.ProficiencyHandler")
local WBP_ProficiencyLegendSynopsis = UnLua.Class()

function WBP_ProficiencyLegendSynopsis:OnBindUIInput()
  self.WBP_InteractTipWidgetClaimRewards:BindInteractAndClickEvent(self, self.BindOnReceiveRewardButtonClicked)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnListenEscKeyPressed
    })
  end
end

function WBP_ProficiencyLegendSynopsis:OnUnBindUIInput()
  self.WBP_InteractTipWidgetClaimRewards:UnBindInteractAndClickEvent(self, self.BindOnReceiveRewardButtonClicked)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
end

function WBP_ProficiencyLegendSynopsis:Construct()
  self.RGToggleGroupProfySynop.OnCheckStateChanged:Add(self, self.OnToggleGroupProfySynopChanged)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.BindOnListenEscKeyPressed)
  self.Btn_SynopsisDetail.OnClicked:Add(self, self.BindOnSynopsisDetailButtonClicked)
  self.Btn_SynopsisDetail.OnHovered:Add(self, self.BindOnSynopsisDetailButtonHovered)
  self.Btn_SynopsisDetail.OnUnhovered:Add(self, self.BindOnSynopsisDetailButtonUnhovered)
  self.Btn_ClaimRewards.OnClicked:Add(self, self.BindOnReceiveRewardButtonClicked)
end

function WBP_ProficiencyLegendSynopsis:Destruct()
  self.RGToggleGroupProfySynop.OnCheckStateChanged:Remove(self, self.OnToggleGroupProfySynopChanged)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.BindOnListenEscKeyPressed)
  self.Btn_SynopsisDetail.OnClicked:Remove(self, self.BindOnSynopsisDetailButtonClicked)
  self.Btn_SynopsisDetail.OnHovered:Remove(self, self.BindOnSynopsisDetailButtonHovered)
  self.Btn_SynopsisDetail.OnUnhovered:Remove(self, self.BindOnSynopsisDetailButtonUnhovered)
  self.Btn_ClaimRewards.OnClicked:Remove(self, self.BindOnReceiveRewardButtonClicked)
end

function WBP_ProficiencyLegendSynopsis:OnShow(HeroId, Level)
  self.CurHeroId = HeroId
  self.CurSelectLevel = Level
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, HeroId)
  if Result then
    self.Txt_HeroName:SetText(RowInfo.Name)
  end
  self:RefreshSynopsisItemList()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo)
end

function WBP_ProficiencyLegendSynopsis:RefreshSynopsisItemList()
  self.RGToggleGroupProfySynop:ClearGroup()
  local scrollWidget, Item
  local Index = 1
  for i = 1, ProficiencyData:GetMaxProfyLevel(self.CurHeroId) do
    local Result, RowInfo = ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(self.CurHeroId, i)
    if Result then
      Item = GetOrCreateItem(self.ScrollBox_Synopsis, Index, self.WBP_ProficiencySynopsisItem:GetClass())
      Item:InitProficiencySynopsisItem(self.CurHeroId, i)
      self.RGToggleGroupProfySynop:AddToGroup(i, Item)
      if i == self.CurSelectLevel then
        scrollWidget = Item
      end
      Index = Index + 1
    end
  end
  HideOtherItem(self.ScrollBox_Synopsis, Index, true)
  self.RGToggleGroupProfySynop:SelectId(self.CurSelectLevel)
  if scrollWidget then
    self.ScrollBox_Synopsis:ScrollWidgetIntoView(scrollWidget, false)
  end
end

function WBP_ProficiencyLegendSynopsis:OnToggleGroupProfySynopChanged(SelectId)
  self.CurSelectLevel = SelectId
  local CurUnlockLevel = ProficiencyData:GetMaxUnlockProfyLevel(self.CurHeroId)
  UpdateVisibility(self.LockDetailInfoPanel, false)
  UpdateVisibility(self.UnlockDetailInfoPanel, false)
  if SelectId > CurUnlockLevel then
    UpdateVisibility(self.LockDetailInfoPanel, true)
    self.Txt_LockDetailInfoTip:SetText(UE.FTextFormat(self.LockDetailInfoTip, SelectId))
  else
    UpdateVisibility(self.UnlockDetailInfoPanel, true)
    local Result, RowInfo = ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(self.CurHeroId, SelectId)
    if not Result then
      return
    end
    self.RGTextName:SetText(RowInfo.Name)
    self.RGTextNum:SetText(UE.FTextFormat(self.ChapterFormatText, NumToTxt(SelectId)))
    self.RGTextDesc:SetText(RowInfo.SimpleDesc)
    self.DescScrollPanel:ScrollToStart()
    SetImageBrushByPath(self.Img_SynopsisIcon, RowInfo.IconPath)
    self:RefreshAwardInfo(RowInfo.StoryRewardList)
    UpdateVisibility(self.Btn_ClaimRewards, not ProficiencyData:IsCurProfyStoryRewardReceived(self.CurHeroId, self.CurSelectLevel))
  end
end

function WBP_ProficiencyLegendSynopsis:RefreshAwardInfo(AwardList)
  local Index = 1
  for index, SingleAwardInfo in ipairs(AwardList) do
    local Item = GetOrCreateItem(self.AwardListPanel, Index, self.WBP_Item)
    UpdateVisibility(Item, true)
    Item:InitItem(SingleAwardInfo.key, SingleAwardInfo.value)
    Item:UpdateReceivedPanelVis(ProficiencyData:IsCurProfyStoryRewardReceived(self.CurHeroId, self.CurSelectLevel))
    Index = Index + 1
  end
  HideOtherItem(self.AwardListPanel, Index, true)
end

function WBP_ProficiencyLegendSynopsis:BindOnSynopsisDetailButtonClicked()
  EventSystem.Invoke(EventDef.Proficiency.OnProficiencySynopsisDetailPanelVisChanged, true, self.CurHeroId, self.CurSelectLevel)
end

function WBP_ProficiencyLegendSynopsis:BindOnSynopsisDetailButtonHovered(...)
  UpdateVisibility(self.Img_SynopsisDetail_Hovered, true)
end

function WBP_ProficiencyLegendSynopsis:BindOnSynopsisDetailButtonUnhovered(...)
  UpdateVisibility(self.Img_SynopsisDetail_Hovered, false)
end

function WBP_ProficiencyLegendSynopsis:BindOnReceiveRewardButtonClicked(...)
  local BtnVisibility = self.UnlockDetailInfoPanel:GetVisibility()
  if BtnVisibility == UE.ESlateVisibility.Collapsed or BtnVisibility == UE.ESlateVisibility.Hidden then
    return
  end
  if not ProficiencyData:IsCurProfyStoryRewardReceived(self.CurHeroId, self.CurSelectLevel) then
    ProficiencyHandler:RequestGetHeroProfyStoryRewardToServer(self.CurHeroId, self.CurSelectLevel)
  end
end

function WBP_ProficiencyLegendSynopsis:BindOnUpdateMyHeroInfo(...)
  self:RefreshSynopsisItemList()
  local AllItem = self.AwardListPanel:GetAllChildren()
  for key, SingleItem in pairs(AllItem) do
    if SingleItem:IsVisible() then
      SingleItem:UpdateReceivedPanelVis(ProficiencyData:IsCurProfyStoryRewardReceived(self.CurHeroId, self.CurSelectLevel))
    end
  end
end

function WBP_ProficiencyLegendSynopsis:BindOnListenEscKeyPressed(...)
  UIMgr:Hide(ViewID.UI_ProficiencyLegendSynopsis, true)
end

function WBP_ProficiencyLegendSynopsis:OnPreHide(...)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo, self)
end

function WBP_ProficiencyLegendSynopsis:OnHide()
end

return WBP_ProficiencyLegendSynopsis
