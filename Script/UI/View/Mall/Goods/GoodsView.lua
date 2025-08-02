local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local MallGoodsViewModel = require("UI.ViewModel.Mall.Goods.MallGoodsViewModel")
local GoodsView = Class(ViewBase)
local CurrentPosterWidget
local PosterWidgetToTableName = {}

function GoodsView:OnRollback()
  if CurrentPosterWidget then
    CurrentPosterWidget.WBP_InteractTipWidgetBuy:BindInteractAndClickEvent(self, self.OnBuyBtnConsoleClicked)
  end
end

function GoodsView:OnHideByOther()
  if CurrentPosterWidget then
    CurrentPosterWidget.WBP_InteractTipWidgetBuy:UnBindInteractAndClickEvent(self, self.OnBuyBtnConsoleClicked)
  end
end

function GoodsView:BindNewPosterWidget(PosterWidget)
  if PosterWidget and PosterWidget == CurrentPosterWidget then
    return
  end
  if CurrentPosterWidget then
    CurrentPosterWidget.WBP_InteractTipWidgetBuy:UnBindInteractAndClickEvent(self, self.OnBuyBtnConsoleClicked)
    CurrentPosterWidget = nil
  end
  if PosterWidget then
    PosterWidget.WBP_InteractTipWidgetBuy:BindInteractAndClickEvent(self, self.OnBuyBtnConsoleClicked)
    CurrentPosterWidget = PosterWidget
  end
end

function GoodsView:OnBuyBtnConsoleClicked()
  if PosterWidgetToTableName[CurrentPosterWidget] then
    self:BuyGoods(PosterWidgetToTableName[CurrentPosterWidget])
  end
end

function GoodsView:BindClickHandler()
end

function GoodsView:UnBindClickHandler()
end

function GoodsView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function GoodsView:OnDestroy()
  self:UnBindClickHandler()
end

function GoodsView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.ChildWidgetClass = UE.UClass.Load("/Game/Rouge/UI/Mall/Goods/WBP_Mall_Goods_Poster.WBP_Mall_Goods_Poster_C")
  self.NavigationTabWidgetClass = UE.UClass.Load("/Game/Rouge/UI/Mall/Goods/WBP_Mall_Goods_NavigationTab.WBP_Mall_Goods_NavigationTab_C")
  local TableName = TableNames.TBMallRecommendPage
  self.RecommendPageDatas = LuaTableMgr.GetLuaTableByName(TableName)
  self.ScrollBox_Poster:ClearChildren()
  self.NavigationTab:ClearChildren()
  PosterWidgetToTableName = {}
  self.MaxNum = 0
  for key, value in pairs(self.RecommendPageDatas) do
    if self:InShowTime(key) then
      self:AddChildPoster(key)
      self.MaxNum = self.MaxNum + 1
    end
  end
  self.Interval = 10
  self.CumulativeInterval = 0
  self.CurIndex = 1
  self.ScrollBox_Poster.OnUserScrolled:Add(self, GoodsView.OnUserScrolled)
  self:PlayAnimation(self.Ani_in)
  LogicLobby.ChangeLobbyMainModelVis(false)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.ReturnLobby)
  EventSystem.AddListener(self, EventDef.Lobby.RoleSkillTip, GoodsView.BindOnShowSkillTips)
end

function GoodsView:OpenSetting()
  LogicGameSetting.ShowGameSettingPanel()
end

function GoodsView:ReturnLobby()
  local LobbyDefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
  local CurShowLabelName = LogicLobby.GetCurSelectedLabelName()
  if CurShowLabelName == LobbyDefaultLabelName then
    EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, not self.IsShowLobbyMenuPanel)
  else
    LogicLobby.ChangeLobbyPanelLabelSelected(LobbyDefaultLabelName)
  end
end

function GoodsView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  LogicLobby.ChangeLobbyMainModelVis(true)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Remove(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.ReturnLobby)
  self:BindNewPosterWidget(nil)
  EventSystem.RemoveListener(EventDef.Lobby.RoleSkillTip, GoodsView.BindOnShowSkillTips)
end

function GoodsView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    self:BindOnOutAnimationFinished()
  end
end

function GoodsView:BindOnOutAnimationFinished()
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
end

function GoodsView:CanDirectSwitch(NextTabWidget)
  self:PlayAnimation(self.Ani_out)
  return false
end

function GoodsView:Construct()
end

function GoodsView:AddChildPoster(TableName)
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, self.ChildWidgetClass)
  local NavigationTabWidget = UE.UWidgetBlueprintLibrary.Create(self, self.NavigationTabWidgetClass)
  local RecommendPageDatas = LuaTableMgr.GetLuaTableByName(TableNames.TBMallRecommendPage)
  if nil == RecommendPageDatas[TableName] then
    return
  end
  if Widget and NavigationTabWidget then
    self.ScrollBox_Poster:AddChild(Widget)
    PosterWidgetToTableName[Widget] = TableName
    Widget.Text_Name:SetText(RecommendPageDatas[TableName].Name)
    Widget.Btn_Name:SetText(RecommendPageDatas[TableName].LinkDesc)
    Widget.Text_Desc:SetText(RecommendPageDatas[TableName].Desc)
    SetImageBrushByPath(Widget.Image_Bg, RecommendPageDatas[TableName].PostResource)
    local _, _, y, m, d, _hour, _min, _sec = string.find(RecommendPageDatas[TableName].ShowStartTime, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
    local ShowStartTimestamp = os.time({
      year = y,
      month = m,
      day = d,
      hour = _hour,
      min = _min,
      sec = _sec
    })
    _, _, y, m, d, _hour, _min, _sec = string.find(RecommendPageDatas[TableName].ShowEndTime, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
    local ShowEndTimestamp = os.time({
      year = y,
      month = m,
      day = d,
      hour = _hour,
      min = _min,
      sec = _sec
    })
    local CurTimestamp = os.time()
    if ShowStartTimestamp < CurTimestamp then
      Widget.WBP_LimitedTime.TextBlock:SetText(RecommendPageDatas[TableName].ShowEndTime .. "\231\187\147\230\157\159")
    else
      Widget.WBP_LimitedTime.TextBlock:SetText(RecommendPageDatas[TableName].ShowStartTime .. "\229\188\128\229\148\174")
    end
    Widget.Button_Buy.OnClicked:Add(self, function()
      self:BuyGoods(TableName)
    end)
    NavigationTabWidget.Btn.OnClicked:Add(self, function()
      self.ScrollBox_Poster:ScrollWidgetIntoView(Widget)
      self:BindNewPosterWidget(Widget)
    end)
    local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if not TotalResourceTable then
      return
    end
    UpdateVisibility(Widget.WBP_Price, false)
    UpdateVisibility(Widget.SkillList, false)
    if nil ~= RecommendPageDatas[TableName].ResourceID and 0 ~= RecommendPageDatas[TableName].ResourceID then
      local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      local ResourceID = RecommendPageDatas[TableName].ResourceID
      local ResourceInfo = ResourceTable[ResourceID]
      if ResourceInfo and ResourceInfo.Type == TableEnums.ENUMResourceType.HERO then
        local TBHero = LuaTableMgr.GetLuaTableByName(TableNames.TBHero)
        if TBHero[ResourceID] then
          local HeroID = TBHero[ResourceID].HeroID
          local RowInfo = LogicRole.GetCharacterTableRow(HeroID)
          self:RefreshSkillInfo(RowInfo, Widget)
        end
        UpdateVisibility(Widget.SkillList, true)
      end
    end
  end
  self.NavigationTab:AddChild(NavigationTabWidget)
  self:BindNewPosterWidget(Widget)
  local Scale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
  local ViewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
  Widget.URGImage_41:SetBrushSize(ViewportSize / Scale)
end

function GoodsView:RefreshSkillInfo(RowInfo, Widget)
  local AllSkillItems = Widget.SkillList:GetAllChildren()
  local SkillItemList = {}
  for i, SingleItem in pairs(AllSkillItems) do
    SkillItemList[SingleItem.Type] = SingleItem
  end
  local RoleStar = DataMgr.GetHeroLevelByHeroId(RowInfo.ID)
  for i, SingleSkillId in ipairs(RowInfo.SkillList) do
    local SkillRowInfo = LogicRole.GetSkillTableRow(SingleSkillId)
    if SkillRowInfo then
      local TargetSkillLevelInfo = SkillRowInfo[RoleStar]
      if TargetSkillLevelInfo then
        local Item = SkillItemList[TargetSkillLevelInfo.Type]
        if Item then
          Item:RefreshInfo(TargetSkillLevelInfo)
        end
      elseif SkillRowInfo[1] then
        local Item = SkillItemList[SkillRowInfo[1].Type]
        if Item then
          Item:RefreshInfo(SkillRowInfo[1])
        end
      else
        print("GoodsView:RefreshSkillInfo not found star1 info, skillgroupid:", SingleSkillId)
      end
    end
  end
end

function GoodsView:BindOnShowSkillTips(IsShow, SkillGroupId, KeyName, SkillInputNameAry, inputNameAryPad, SkillItem)
  if IsShow then
    self.NormalSkillTip:RefreshInfo(SkillGroupId, KeyName, nil, SkillInputNameAry, inputNameAryPad)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    ShowCommonTips(nil, SkillItem, self.NormalSkillTip)
  else
    self.NormalSkillTip:Hide()
  end
end

function GoodsView:OnTick(InDeltaTime)
  if self.CumulativeInterval == nil then
    self.CumulativeInterval = 0
  end
  if nil == self.Interval then
    self.Interval = 10
  end
  self.CumulativeInterval = self.CumulativeInterval + InDeltaTime
  if self.CumulativeInterval > self.Interval then
    self.CumulativeInterval = 0
    self.CurIndex = self.CurIndex + 1
    if self.CurIndex > self.MaxNum then
      self.CurIndex = 1
    end
    local Widget = self.ScrollBox_Poster:GetAllChildren():Get(self.CurIndex)
    self.ScrollBox_Poster:ScrollWidgetIntoView(Widget)
    self:BindNewPosterWidget(Widget)
  end
  local Scale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
  local ViewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
  if ViewportSize / Scale ~= self.ViewPortSize then
    self.ViewPortSize = ViewportSize / Scale
    for index, Value in ipairs(self.ScrollBox_Poster:GetAllChildren():ToTable()) do
      Value.URGImage_41:SetBrushSize(self.ViewPortSize)
      print("GoodsView", self.ViewPortSize)
    end
  end
end

function GoodsView:OnUserScrolled(offset)
  self.CumulativeInterval = 0
  local EndOffset = self.ScrollBox_Poster:GetScrollOffsetOfEnd()
  local offset = self.ScrollBox_Poster:GetScrollOffset()
  self.TargetIndex = math.floor(offset / (EndOffset / (self.MaxNum - 1))) + 1
  if self.CurIndex > self.MaxNum then
    self.CurIndex = 1
  end
  if self.TargetIndex ~= self.CurIndex then
    self.CurIndex = self.TargetIndex
    local Widget = self.ScrollBox_Poster:GetAllChildren():Get(self.CurIndex)
    self.ScrollBox_Poster:ScrollWidgetIntoView(Widget)
    self:BindNewPosterWidget(Widget)
  end
end

function GoodsView:BuyGoods(Id)
  if self.RecommendPageDatas[Id] then
    ComLink(self.RecommendPageDatas[Id].GoodsJump, nil, "UI_Mall")
  end
end

function GoodsView:OnMouseButtonUp(MyGeometry, MouseEvent)
end

function GoodsView:InShowTime(TableName)
  local RecommendPageDatas = LuaTableMgr.GetLuaTableByName(TableNames.TBMallRecommendPage)
  if RecommendPageDatas[TableName] then
    local _, _, y, m, d, _hour, _min, _sec = string.find(RecommendPageDatas[TableName].ShowStartTime, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
    local ShowStartTimestamp = os.time({
      year = y,
      month = m,
      day = d,
      hour = _hour,
      min = _min,
      sec = _sec
    })
    _, _, y, m, d, _hour, _min, _sec = string.find(RecommendPageDatas[TableName].ShowEndTime, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
    local ShowEndTimestamp = os.time({
      year = y,
      month = m,
      day = d,
      hour = _hour,
      min = _min,
      sec = _sec
    })
    local CurTimestamp = os.time()
    return ShowEndTimestamp > CurTimestamp and ShowStartTimestamp < CurTimestamp
  end
  return false
end

return GoodsView
