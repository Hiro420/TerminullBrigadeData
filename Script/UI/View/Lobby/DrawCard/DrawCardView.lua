local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local DrawCardHandler = require("Protocol.DrawCard.DrawCardHandler")
local rapidjson = require("rapidjson")
local DrawCardViewType = {
  DrawCardMain = 1,
  DrawCardOnce = 2,
  DrawCardMulti = 3,
  DrawCardPoolDetail = 4
}
local ServerPoolList = {}
local DrawCardView = Class(ViewBase)
local MultiDrawTimes = 10
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Red = UE.FLinearColor(1.0, 0.0, 0.0, 1.0)
}
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end
function DrawCardView:BindClickHandler()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateResourceInfo, self.UpdateCost)
  self.ButtonOnce.OnClicked:Add(self, self.DrawOnce)
  self.ButtonMulti.OnClicked:Add(self, self.DrawMulti)
  self.Btn_ShowPrivilege_1.OnHovered:Add(self, self.BtnShowPrivilege_1_OnHover)
  self.Btn_ShowPrivilege_1.OnUnhovered:Add(self, self.HideCommonTips)
  self.Btn_ShowPrivilege_2.OnHovered:Add(self, self.BtnShowPrivilege_2_OnHover)
  self.Btn_ShowPrivilege_2.OnUnhovered:Add(self, self.HideCommonTips)
  self.Btn_RuleDescription.OnClicked:Add(self, self.BindOnRuleDescriptionButtonClicked)
  self.Btn_RuleDescription.OnHovered:Add(self, self.BindOnRuleDescriptionButtonHovered)
  self.Btn_RuleDescription.OnUnhovered:Add(self, self.BindOnRuleDescriptionButtonUnhovered)
  self.WBP_CommonButton_Preview.OnMainButtonClicked:Add(self, self.ShowCardPoolDetail)
  self.WBP_CommonButton_Exchange.OnMainButtonClicked:Add(self, self.BindOnExchangeButtonClicked)
  EventSystem.AddListener(self, EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.BindOnChangeDrawCardPoolSelected)
  EventSystem.AddListener(self, EventDef.DrawCard.OnGetDrawCardResult, self.BindOnGetDrawCardResult)
  EventSystem.AddListener(self, EventDef.DrawCard.OnGetCardPoolList, self.BindOnGetCardPoolList)
end
function DrawCardView:UnBindClickHandler()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfo, self.UpdateCost)
  self.ButtonOnce.OnClicked:Remove(self, self.DrawOnce)
  self.ButtonMulti.OnClicked:Remove(self, self.DrawMulti)
  self.Btn_ShowPrivilege_1.OnHovered:Remove(self, self.BtnShowPrivilege_1_OnHover)
  self.Btn_ShowPrivilege_1.OnUnhovered:Remove(self, self.HideCommonTips)
  self.Btn_ShowPrivilege_2.OnHovered:Remove(self, self.BtnShowPrivilege_2_OnHover)
  self.Btn_ShowPrivilege_2.OnUnhovered:Remove(self, self.HideCommonTips)
  self.Btn_RuleDescription.OnClicked:Remove(self, self.BindOnRuleDescriptionButtonClicked)
  self.Btn_RuleDescription.OnHovered:Remove(self, self.BindOnRuleDescriptionButtonHovered)
  self.Btn_RuleDescription.OnUnhovered:Remove(self, self.BindOnRuleDescriptionButtonUnhovered)
  self.WBP_CommonButton_Preview.OnMainButtonClicked:Remove(self, self.ShowCardPoolDetail)
  self.WBP_CommonButton_Exchange.OnMainButtonClicked:Remove(self, self.BindOnExchangeButtonClicked)
  self.WBP_InteractTipWidget_Continue:UnBindInteractAndClickEvent(self, self.ListenForContinueInputAction)
  self.WBP_InteractTipWidget_Esc:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
  self.WBP_InteractTipWidget_Skip:UnBindInteractAndClickEvent(self, self.ListenForSkipInputAction)
  EventSystem.RemoveListener(EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.BindOnChangeDrawCardPoolSelected, self)
  EventSystem.RemoveListener(EventDef.DrawCard.OnGetDrawCardResult, self.BindOnGetDrawCardResult, self)
  EventSystem.RemoveListener(EventDef.DrawCard.OnGetCardPoolList, self.BindOnGetCardPoolList, self)
end
function DrawCardView:OnInit()
  self.DataBindTable = {
    {
      Source = "CurCardPoolName",
      Target = "Text_CardPoolName",
      Policy = DataBinding.DirectText()
    },
    {
      Source = "CurCardPoolOpenCount",
      Callback = DrawCardView.UpdateOpenCount
    },
    {
      Source = "CurGuarantList",
      Callback = DrawCardView.UpdateCardGuarantList
    },
    {
      Source = "CurCardPoolEndTime",
      Callback = DrawCardView.UpdateCardPoolEndTime
    },
    {
      Source = "CurCardPoolBgPath",
      Target = "URGImage_33",
      Policy = DataBinding.DirectImageBrush(false, true)
    }
  }
  self.viewModel = UIModelMgr:Get("DrawCardViewModel")
end
function DrawCardView:OnDestroy()
end
function DrawCardView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.bIsSequencePlaying = false
  self.bIsDrawRequesting = false
  LogicRole.ShowOrHideRoleMainHero(true)
  LogicLobby.ShowOrHideGround(true)
  LogicLobby.ShowOrHideDrawCardLevel(true)
  DrawCardHandler.RequestGetCardPoolListFromServer(function(GachaList)
    EventSystem.Invoke(EventDef.DrawCard.OnGetCardPoolList, GachaList)
  end)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    self.AppearanceActor:UpdateActived(true)
    self.AppearanceActor:HideMesh()
    LogicRole.ShowOrLoadLevel(-1)
  end
  self:PushInputAction()
  self.WBP_ChatView:FocusInput()
  self:BindClickHandler()
  local RegionId = GetRegionId()
  if RegionId and "" ~= RegionId then
    self.RGStateController_Region:ChangeStatus(RegionId)
  else
    self.RGStateController_Region:ChangeStatus("default")
  end
  self:RefreshInteractTipWidgetBindEvent()
end
function DrawCardView:OnShowLink(LinkParams, FormView)
  if LinkParams and LinkParams:IsValidIndex(1) then
    self.CardPoolId = LinkParams:GetRef(1).IntParam
  end
  if FormView then
    self.bShowLink = "UI_Mall" ~= FormView
  else
    self.bShowLink = true
  end
end
function DrawCardView:OnPreHide()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    self.AppearanceActor:UpdateActived(false, true, false)
  end
  if not self.bShowLink then
    LogicRole.ShowOrHideRoleMainHero(false)
    ChangeToLobbyAnimCamera()
  else
    local skinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
    if skinView then
      skinView:RebackView()
    end
  end
  self.bShowLink = false
  self.WBP_ChatView:UnfocusInput()
  LogicLobby.ShowOrHideDrawCardLevel(false)
end
function DrawCardView:OnHide()
  self.AnimMap = {}
  self:UnBindClickHandler()
  UpdateVisibility(self.Canvas_Main, false)
  self.WBP_DrawCardPoolDetailView:OnHide()
  self.WBP_DrawOnceResultView:OnHide()
  self.WBP_DrawMultiResultView:OnHide()
  self:HideCommonTips()
end
function DrawCardView:ListenForEscInputAction()
  if self.bIsDrawRequesting then
    print("ywtao,ListenForEscInputAction: bIsDrawRequesting is true")
    return
  end
  if self.bIsSequencePlaying then
    print("ywtao,ListenForEscInputAction: bIsSequencePlaying is true")
    return
  end
  if self.ViewType == DrawCardViewType.DrawCardMain then
    self.viewModel:HideSelf()
  elseif self.ViewType == DrawCardViewType.DrawCardOnce then
    if self.WBP_DrawOnceResultView.ParentView == self then
      self.WBP_DrawOnceResultView:HideSelf()
    end
  elseif self.ViewType == DrawCardViewType.DrawCardMulti then
    self.WBP_DrawMultiResultView:HideSelf()
  elseif self.ViewType == DrawCardViewType.DrawCardPoolDetail then
    self.WBP_DrawCardPoolDetailView:HideSelf()
  end
end
function DrawCardView:DrawOnce()
  self:Draw(1)
end
function DrawCardView:DrawMulti()
  self:Draw(MultiDrawTimes)
end
function DrawCardView:BtnShowPrivilege_1_OnHover()
  self.TipsWidget = ShowCommonTips(nil, self.Btn_ShowPrivilege_1, self.WBP_CommonTips, nil, nil, nil, UE.FVector2D(-40, 0))
  self.TipsWidget:ShowTipsByItemID(self.RightResPrivilegeId)
end
function DrawCardView:BtnShowPrivilege_2_OnHover()
  self.TipsWidget = ShowCommonTips(nil, self.Btn_ShowPrivilege_2, self.WBP_CommonTips, nil, nil, nil, UE.FVector2D(-40, 0))
  self.TipsWidget:ShowTipsByItemID(self.LeftResPrivilegeId)
end
function DrawCardView:HideCommonTips()
  if self.TipsWidget then
    UpdateVisibility(self.TipsWidget, false)
  end
end
function DrawCardView:Draw(DrawTimes, CallBack)
  if self.bIsDrawRequesting then
    print("ywtao\239\188\140\230\138\189\229\141\161\232\175\183\230\177\130\230\173\163\229\156\168\232\191\155\232\161\140\228\184\173\239\188\140\231\166\129\230\173\162\232\191\158\231\130\185")
    return
  end
  if not self.viewModel:CheckCost(DrawTimes, self.CardPoolId) then
    local GoodsId = self.viewModel:GetGoodsIdByCardPoolId(self.CardPoolId)
    local CurrencyId = self.viewModel:GetCost(0, self.CardPoolId)
    ComLink(1007, nil, GoodsId, 6, nil, DrawTimes - DataMgr.GetPackbackNumById(CurrencyId))
    return
  end
  if CallBack then
    CallBack()
  end
  self.bIsDrawRequesting = true
  DrawCardHandler.RequestDrawCardToServer(self.CardPoolId, DrawTimes)
end
function DrawCardView:BindOnGetDrawCardResult(DrawCardResult)
  self.bIsDrawRequesting = false
  if nil == DrawCardResult then
    print("ywtao,DrawCardResult == nil")
    return
  end
  if 1 == #DrawCardResult.Resources then
    self:DrawResultOnce(DrawCardResult.Resources[1], self)
  elseif #DrawCardResult.Resources > 1 then
    self:DrawResultMulti(DrawCardResult.Resources)
  end
  local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
  SkinHandler.SendGetHeroSkinList()
  SkinHandler.SendGetWeaponSkinList()
  DrawCardHandler.RequestGetCardPoolListFromServer(function()
    self.viewModel:InitInfoByCardPoolId(self.CardPoolId)
  end)
  self:RequestHeroInfo(DrawCardResult.Resources)
end
function DrawCardView:BindOnGetCardPoolList(GachaList)
  if nil == GachaList then
    print("ywtao,DrawCardView:BindOnGetCardPoolList: JsonTable == nil")
    self.viewModel:HideSelf()
    return
  end
  ServerPoolList = GachaList
  local LocalPoolList = self.viewModel:GetPoolInfo()
  for _, PoolInfo in pairs(ServerPoolList) do
    if LocalPoolList and LocalPoolList[PoolInfo.RewardPondID] then
      local PoolId = PoolInfo.RewardPondID
      local CardPoolListItem = GetOrCreateItem(self.ScrollBox_CardPoolList, _, self.WBP_DrawCardPoolListItem:GetClass())
      CardPoolListItem:InitInfo(self, PoolId, LocalPoolList[PoolId])
      if nil == self.CardPoolId then
        self.CardPoolId = PoolId
      end
    end
  end
  EventSystem.Invoke(EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.CardPoolId)
  HideOtherItem(self.ScrollBox_CardPoolList, #ServerPoolList + 1)
end
function DrawCardView:RequestHeroInfo(Resources)
  local bNeedRequestHeroInfo = false
  for i, v in ipairs(Resources) do
    if LogicRole:CheckIsHeroMonster(v.resourceId) then
      bNeedRequestHeroInfo = true
    end
  end
  if bNeedRequestHeroInfo then
    LogicRole:RequestMyHeroInfoToServer()
  end
end
function DrawCardView:DrawResultOnce(Resource, ParentView)
  self.Canvas_Main:SetVisibility(UE.ESlateVisibility.Collapsed)
  if ParentView == self then
    self.ViewType = DrawCardViewType.DrawCardOnce
  end
  self.WBP_DrawOnceResultView:InitInfo(Resource, self.CardPoolId, ParentView)
end
function DrawCardView:DrawResultMulti(ResourceList)
  self.Canvas_Main:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ViewType = DrawCardViewType.DrawCardMulti
  self.WBP_DrawMultiResultView:InitInfo(ResourceList, self.CardPoolId, self.CheckBox_SkipAni:IsChecked(), self)
end
function DrawCardView:ShowCardPoolDetail()
  self.Canvas_Main:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WBP_DrawCardPoolDetailView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WBP_DrawCardPoolDetailView:PlayAnimationIn()
  self.ViewType = DrawCardViewType.DrawCardPoolDetail
  self.WBP_DrawCardPoolDetailView:InitCardPoolInfo(self.CardPoolId, self)
end
function DrawCardView:BindOnExchangeButtonClicked()
  ComLink(1017, function()
    self:ListenForEscInputAction()
  end)
end
function DrawCardView:InitInfoByCardPoolId(CardPoolId)
  self.Canvas_Main:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.CardPoolId = CardPoolId
  self.ViewType = DrawCardViewType.DrawCardMain
  self.viewModel:InitInfoByCardPoolId(self.CardPoolId)
  local CostResId, CostNum, ResCurrencyId, ResOldPrice, ResCurPrice = self.viewModel:GetPriceInfo(self.CardPoolId)
  self.WBP_Price:SetPrice(ResCurPrice, ResOldPrice, ResCurrencyId)
  self.WBP_Price_1:SetPrice(CostNum, CostNum, CostResId)
  self.WBP_Price_OnceDraw:SetPrice(CostNum, CostNum, CostResId)
  self.WBP_Price_MultiDraw:SetPrice(CostNum * 10, CostNum * 10, CostResId)
  self:UpdateCost()
  if self.AnimMap == nil then
    self.AnimMap = {}
  end
  if not self.AnimMap[CardPoolId] then
    self:PlayAnimationIn()
    self.AnimMap[CardPoolId] = true
  end
  local PoolInfo = self.viewModel:GetPoolInfoByPoolId(self.CardPoolId)
  if PoolInfo then
    self.Text_Title1:SetText(PoolInfo.CharacterTitle1)
    self.Text_Name1:SetText(PoolInfo.CharacterName1)
    self.Text_Title2:SetText(PoolInfo.CharacterTitle2)
    self.Text_Name2:SetText(PoolInfo.CharacterName2)
    self:RefreshHeroPicture()
  end
end
function DrawCardView:UpdateCost()
  local CostResId, CostNum, bIsEnough = self.viewModel:GetCost(1, self.CardPoolId)
  local ResNum = DataMgr.GetPackbackNumById(CostResId)
  if self.ViewType == DrawCardViewType.DrawCardMulti then
    self.WBP_DrawMultiResultView:UpdateCost()
  end
  if self.ViewType == DrawCardViewType.DrawCardOnce then
    self.WBP_DrawOnceResultView:UpdateCost()
  end
end
function DrawCardView:BindFadeOutFinished()
  self.viewModel:HideSelf()
end
function DrawCardView:UpdateCardGuarantList(GuarantList)
  local _index = 0
  local TotalGuarantTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaSafeguard)
  local TotalRandomGiftTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRandomGift)
  local GuarantStrList = {}
  for _, GuarantInfo in pairs(GuarantList) do
    _index = _index + 1
    local DrawCardGuarantListItem = GetOrCreateItem(self.ScrollBox_GuarantList, _index, self.WBP_DrawCardGuarantListItem:GetClass())
    local GuarantStr = ""
    if GuarantInfo.HasSafeguard then
      GuarantStr = UE.FTextFormat(self.GuarantTextFmt1, tostring(GuarantInfo.TriggerRemanentTimes), tostring(TotalRandomGiftTable[TotalGuarantTable[GuarantInfo.SafeguardID].SafeguardGiftId].RichTextName))
    else
      GuarantStr = UE.FTextFormat(self.GuarantTextFmt2, tostring(TotalGuarantTable[GuarantInfo.SafeguardID].Name))
    end
    DrawCardGuarantListItem.RGRichTextBlock_Info:SetText(GuarantStr)
    table.insert(GuarantStrList, GuarantStr)
  end
  HideOtherItem(self.ScrollBox_GuarantList, _index + 1)
  self.WBP_DrawMultiResultView:UpdateCardGuarantList(GuarantStrList)
end
function DrawCardView:UpdateOpenCount(OpenCount)
  local CountDownTxt = UE.FTextFormat(self.CountDownTextFmt, tostring(OpenCount))
  self.RGRichTextBlock_OpenCount:SetText(CountDownTxt)
end
function DrawCardView:UpdateCardPoolEndTime(EndTime)
  local year, month, day, hour, minute, second = EndTime:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
  year = tonumber(year)
  month = tonumber(month)
  day = tonumber(day)
  hour = tonumber(hour)
  minute = tonumber(minute)
  second = tonumber(second)
  local timeTable = {
    year = year,
    month = month,
    day = day,
    hour = hour,
    min = minute,
    sec = second
  }
  local timestamp = os.time(timeTable)
  self.WBP_ItemCountdown:SetCountdownInfo(timestamp)
end
function DrawCardView:BindOnChangeDrawCardPoolSelected(PoolId)
  self:InitInfoByCardPoolId(PoolId)
end
function DrawCardView:PlaySeq(SoftObjPath)
  local seqSubSys = UE.URGSequenceSubsystem.GetInstance(self)
  if not seqSubSys then
    self:LevelSequenceFinish()
    return
  end
  if self.SequencePlayer then
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
  end
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  self.SequencePlayer = seqSubSys:CreatePlayerFromLevelSequence(self, SoftObjPath, setting)
  if self.SequencePlayer == nil then
    self:LevelSequenceFinish()
    return
  end
  self.SequenceActor = self.SequencePlayer.SequenceActor
  if LogicRole.GetSequenceActor() then
    self.SequencePlayer:SetInstanceData(LogicRole.GetSequenceActor(), UE.FTransform())
  end
  self.SequencePlayer.OnPlay:Add(self, self.LevelSequencePlay)
  self.SequencePlayer.OnFinished:Add(self, self.LevelSequenceFinish)
  self.SequencePlayer:Play()
end
function DrawCardView:LevelSequencePlay()
  EventSystem.Invoke(EventDef.DrawCard.OnDrawCardSequencePlay)
  self:ChangeInteractTipWidgetStatus("Skip")
  self.bIsSequencePlaying = true
end
function DrawCardView:LevelSequenceFinish()
  self:SequenceFinished(true)
  EventSystem.Invoke(EventDef.DrawCard.OnDrawCardSequenceFinished)
  self.bIsSequencePlaying = false
end
function DrawCardView:SequenceFinished(SequenceFinish)
  if self.SequencePlayer then
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
  end
end
function DrawCardView:PlayAnimationIn()
  if not self.CardPoolId then
    return
  end
  local PoolInfo = self.viewModel:GetPoolInfoByPoolId(self.CardPoolId)
  if not PoolInfo then
    return
  end
  self:PlayAnimation(self.Anim_IN)
end
function DrawCardView:RefreshHeroPicture()
  local PoolInfo = self.viewModel:GetPoolInfoByPoolId(self.CardPoolId)
  if not PoolInfo then
    return
  end
  local AllChildren = self.CanvasPanel_Hero:GetAllChildren()
  for i, HeroCanvas in pairs(AllChildren) do
    HeroCanvas:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local CharacterList = PoolInfo.CharacterList
  for _, heroId in ipairs(CharacterList) do
    local HeroCanvas = self["CanvasPanel_Hero_" .. heroId]
    if HeroCanvas then
      HeroCanvas:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function DrawCardView:ListenForContinueInputAction()
  if not self.bIsSequencePlaying and not self.WBP_DrawMultiResultView.bShowRewardFinished then
    self.WBP_DrawOnceResultView:HideSelf()
    self.WBP_DrawMultiResultView:ContinueInitInfo()
  end
end
function DrawCardView:ListenForSkipInputAction()
  if self.bIsSequencePlaying then
    self:LevelSequenceFinish()
  end
end
function DrawCardView:ChangeInteractTipWidgetStatus(Status)
  self.RGStateController_InteractTipWidget:ChangeStatus(Status)
  UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
    GameInstance,
    function()
      self:RefreshInteractTipWidgetBindEvent()
    end
  })
end
function DrawCardView:RefreshInteractTipWidgetBindEvent()
  if not self.WBP_InteractTipWidget_Esc:IsVisible() then
    self.WBP_InteractTipWidget_Esc:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
  end
  if not self.WBP_InteractTipWidget_Continue:IsVisible() then
    self.WBP_InteractTipWidget_Continue:UnBindInteractAndClickEvent(self, self.ListenForContinueInputAction)
  end
  if not self.WBP_InteractTipWidget_Skip:IsVisible() then
    self.WBP_InteractTipWidget_Skip:UnBindInteractAndClickEvent(self, self.ListenForSkipInputAction)
  end
  if self.WBP_InteractTipWidget_Esc:IsVisible() then
    self.WBP_InteractTipWidget_Esc:BindInteractAndClickEvent(self, self.ListenForEscInputAction)
  end
  if self.WBP_InteractTipWidget_Continue:IsVisible() then
    self.WBP_InteractTipWidget_Continue:BindInteractAndClickEvent(self, self.ListenForContinueInputAction)
  end
  if self.WBP_InteractTipWidget_Skip:IsVisible() then
    self.WBP_InteractTipWidget_Skip:BindInteractAndClickEvent(self, self.ListenForSkipInputAction)
  end
end
function DrawCardView:BindOnRuleDescriptionButtonClicked()
  UIMgr:Show(ViewID.UI_DrawCardRule)
end
function DrawCardView:BindOnRuleDescriptionButtonHovered()
end
function DrawCardView:BindOnRuleDescriptionButtonUnhovered()
end
return DrawCardView
