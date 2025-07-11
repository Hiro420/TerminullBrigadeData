local WBP_HeroTalent_C = UnLua.Class()
function WBP_HeroTalent_C:Construct()
  self.Btn_Cost.OnClicked:Add(self, WBP_HeroTalent_C.BindOnCostButtonClicked)
  EventSystem.AddListener(self, EventDef.Lobby.LobbyPanelChanged, WBP_HeroTalent_C.BindOnLobbyActivePanelChanged)
  EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, WBP_HeroTalent_C.BindOnRoleItemClicked)
end
function WBP_HeroTalent_C:BindOnLobbyActivePanelChanged(LastActiveWidget, CurActiveWidget)
  if LastActiveWidget == CurActiveWidget then
    if CurActiveWidget == self then
    end
    return
  end
  if CurActiveWidget == self then
    self:Show(self.CurHeroId)
  end
  if LastActiveWidget == self then
    self:Hide()
  end
end
function WBP_HeroTalent_C:BindOnCostButtonClicked()
  local CurLevel = DataMgr.GetHeroTalentLevelById(self.CurHeroId, self.CurTalentId)
  local MaxLevel = LogicTalent.GetMaxLevelByTalentId(self.CurTalentId)
  if CurLevel >= MaxLevel then
    self:ShowWaveWindow(1059)
    return
  end
  if not LogicTalent.IsMeetPreHeroTalentGroupCondition(self.CurHeroId, self.CurTalentId, CurLevel + 1) then
    self:ShowWaveWindow(1037)
    return
  end
  if not LogicTalent.IsMeetHeroTalentRoleLevelCondition(self.CurHeroId, self.CurTalentId, CurLevel + 1) then
    self:ShowWaveWindow(1040)
    return
  end
  if not LogicTalent.IsMeetHeroTalentUpgradeCostCondition(self.CurHeroId, self.CurTalentId, CurLevel + 1) then
    self:ShowWaveWindow(1036)
    return
  end
  LogicTalent.RequestUpgradeHeroTalentToServer(self.CurHeroId, self.CurTalentId)
end
function WBP_HeroTalent_C:ShowWaveWindow(Id)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindow(Id, {})
end
function WBP_HeroTalent_C:Show(HeroId)
  self.IsInitChoose = false
  EventSystem.AddListener(self, EventDef.Lobby.HeroTalentIconItemClicked, WBP_HeroTalent_C.BindOnHeroTalentIconItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateHeroTalentInfo, WBP_HeroTalent_C.BindOnHeroTalentInfoUpdate)
  LogicRole.IsHeroTalentShow = true
  LogicRole.ShowOrHideRoleChangeList(true, self.CurHeroId, self.RoleChangeList)
  self:SetRoleActorOffset(self.RoleActorOffset)
end
function WBP_HeroTalent_C:SetRoleActorOffset(WorldOffset)
  local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(self, "RoleMainHero", nil)
  local RoleActor
  for i, SingleRoleActor in pairs(RoleActorList) do
    RoleActor = SingleRoleActor
    break
  end
  if RoleActor then
    RoleActor:K2_AddActorWorldOffset(WorldOffset, false, nil, false)
  end
end
function WBP_HeroTalent_C:BindOnRoleItemClicked(HeroId)
  if self.CurHeroId ~= HeroId then
    self.IsInitChoose = false
  end
  self.CurHeroId = HeroId
  local CurActiveWidget = LogicLobby.GetCurLobbyActiveWidget()
  if not CurActiveWidget or CurActiveWidget ~= self then
    return
  end
  local CharacterRow = LogicRole.GetCharacterTableRow(self.CurHeroId)
  if CharacterRow then
    self.Txt_HeroName:SetText(CharacterRow.Name)
  end
  if DataMgr.IsOwnHero(self.CurHeroId) then
    LogicTalent.RequestGetHeroTalentsToServer(self.CurHeroId)
  else
    self.MainPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local HeroTalentList = LogicTalent.GetHeroTalentList(HeroId)
  if not HeroTalentList then
    self.MainPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    print("not found hero talent list, please check the config, heroid:", HeroId)
    return
  end
  self.MainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local AllChildren = self.TalentPanel:GetAllChildren()
  local SingleItemClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Talent/WBP_SingleHeroTalentIconItem.WBP_SingleHeroTalentIconItem_C")
  for i, SingleItem in pairs(AllChildren) do
    if SingleItem:Cast(SingleItemClass) then
      SingleItem:Show(HeroTalentList[SingleItem.Index + 1], self.CurHeroId)
    end
  end
end
function WBP_HeroTalent_C:BindOnHeroTalentIconItemClicked(TalentId)
  if 0 == TalentId then
    if self.HeroTalentMediaPlayer:IsPlaying() then
      self.HeroTalentMediaPlayer:Close()
    end
    self.HeroTalentInfoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self.HeroTalentInfoPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  print("HeroTalentIconItemClicked", self)
  self.CurTalentId = TalentId
  local HeroTalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  local CurLevel = DataMgr.GetHeroTalentLevelById(self.CurHeroId, TalentId)
  local TargetTalentInfo = HeroTalentInfo[CurLevel]
  if 0 == CurLevel then
    TargetTalentInfo = HeroTalentInfo[1]
  end
  if not TargetTalentInfo then
    print("not found talent info, talentid:", TalentId, "CurLevel:", CurLevel)
    return
  end
  self.Txt_Name:SetText(TargetTalentInfo.Name)
  if 0 == CurLevel then
    if not LogicTalent.IsMeetPreHeroTalentGroupCondition(self.CurHeroId, TalentId, CurLevel + 1) then
      self.Txt_CostStatus:SetText("\233\156\128\232\167\163\233\148\129\229\137\141\231\189\174\232\138\130\231\130\185")
    else
      self.Txt_CostStatus:SetText("\232\167\163\233\148\129")
    end
  else
    self.Txt_CostStatus:SetText("\229\141\135\231\186\167")
  end
  local CanUpgrade = LogicTalent.IsMeetPreHeroTalentGroupCondition(self.CurHeroId, TalentId, CurLevel + 1) and LogicTalent.IsMeetHeroTalentRoleLevelCondition(self.CurHeroId, TalentId, CurLevel + 1) and LogicTalent.IsMeetHeroTalentUpgradeCostCondition(self.CurHeroId, TalentId, CurLevel + 1)
  if CanUpgrade then
    local Color = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
    self.Img_CostBtn:SetColorAndOpacity(Color)
  else
    local Color = UE.FLinearColor(0.215861, 0.215861, 0.215861, 1.0)
    self.Img_CostBtn:SetColorAndOpacity(Color)
  end
  local NextLevelTalentInfo = HeroTalentInfo[CurLevel + 1]
  if NextLevelTalentInfo then
    self.CostPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Txt_CostNum:SetText(NextLevelTalentInfo.ArrCost[1].value)
    self.CostId = NextLevelTalentInfo.ArrCost[1].key
    local HaveNum = LogicOutsidePackback.GetResourceNumById(NextLevelTalentInfo.ArrCost[1].key)
    self.Txt_HaveNum:SetText(HaveNum)
    local SlateColor = UE.FSlateColor()
    SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
    if HaveNum >= NextLevelTalentInfo.ArrCost[1].value then
      SlateColor.SpecifiedColor = UE.FLinearColor(0.068478, 0.597202, 0.991102, 1.0)
    else
      SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 0.0, 0.0, 1.0)
    end
    self.Txt_CostNum:SetColorAndOpacity(SlateColor)
    local GeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    local ResourceRow = GeneralTable[NextLevelTalentInfo.ArrCost[1].key]
    if ResourceRow then
      SetImageBrushByPath(self.Img_CostIcon, ResourceRow.Icon)
    end
  else
    self.CostPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local AllChildren = self.RoleTalentDescList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local Index = 0
  for Level, SingleTalentInfo in pairs(HeroTalentInfo) do
    local Item = self.RoleTalentDescList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.HeroTalentItemTemplate:StaticClass())
      local Slot = self.RoleTalentDescList:AddChild(Item)
      local Padding = UE.FMargin()
      Padding.Bottom = 10
      Slot:SetPadding(Padding)
    end
    Item:Show(TalentId, Level, CurLevel, CanUpgrade)
    Index = Index + 1
  end
  self.HeroTalentMediaPlayer:SetLooping(true)
  self.HeroTalentMediaPlayer:OpenSource(nil)
  local ObjRef = MakeStringToSoftObjectReference(TargetTalentInfo.Url)
  if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
    local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
    if Obj and Obj:Cast(UE.UFileMediaSource) then
      self.HeroTalentMediaPlayer:OpenSource(Obj)
      self.HeroTalentMediaPlayer:Rewind()
    end
  end
end
function WBP_HeroTalent_C:BindOnHeroTalentInfoUpdate(HeroId)
  if self.CurHeroId ~= HeroId then
    return
  end
  local HeroTalentList = LogicTalent.GetHeroTalentList(HeroId)
  if not HeroTalentList then
    return
  end
  if not self.IsInitChoose then
    local MaxTalentId = HeroTalentList[1]
    for key, TalentId in ipairs(HeroTalentList) do
      if 0 == DataMgr.GetHeroTalentLevelById(self.CurHeroId, TalentId) then
        break
      end
      MaxTalentId = TalentId
    end
    EventSystem.Invoke(EventDef.Lobby.HeroTalentIconItemClicked, MaxTalentId)
    local AllChildren = self.TalentPanel:GetAllChildren()
    local SingleItemClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Talent/WBP_SingleHeroTalentIconItem.WBP_SingleHeroTalentIconItem_C")
    local EndItem, TargetItem
    for i, SingleItem in pairs(AllChildren) do
      if SingleItem:Cast(SingleItemClass) then
        if SingleItem.TalentId == MaxTalentId then
          TargetItem = SingleItem
        end
        if 0 == SingleItem.Index then
          EndItem = SingleItem
        end
      end
    end
    if EndItem then
      self.ScrollList:ScrollWidgetIntoView(EndItem, true)
      UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        function(self)
          self.MaxScrollOffset = self.ScrollList:GetScrollOffset() + 15
          if TargetItem ~= EndItem then
            self.ScrollList:ScrollWidgetIntoView(TargetItem, true)
          else
            self.ScrollList:SetScrollOffset(self.MaxScrollOffset)
          end
        end
      }, 0.1, false)
    end
    self.IsInitChoose = true
  end
  if self.CurTalentId then
    self:BindOnHeroTalentIconItemClicked(self.CurTalentId)
  end
end
function WBP_HeroTalent_C:ResetHeroTalentTips()
  EventSystem.Invoke(EventDef.Lobby.HeroTalentIconItemClicked, 0)
end
function WBP_HeroTalent_C:OnMouseButtonUp(MyGeometry, MouseEvent)
  self.CanScroll = false
  return UE.UWidgetBlueprintLibrary.Handled()
end
function WBP_HeroTalent_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  self.CanScroll = self:IsMouseInScrollPanelRange(MouseEvent)
  if not self.CanScroll then
    self:ResetHeroTalentTips()
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function WBP_HeroTalent_C:OnMouseMove(MyGeometry, MouseEvent)
  if not self.CanScroll then
    return UE.FEventReply()
  end
  if not self:IsMouseInScrollPanelRange(MouseEvent) then
    self.CanScroll = false
    return UE.FEventReply()
  end
  local ScreenPos = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local PixelPos, ViewportPos = UE.USlateBlueprintLibrary.AbsoluteToViewport(self, ScreenPos, nil, nil)
  if 0.0 == ViewportPos.Y - self.LastY then
    return UE.FEventReply()
  end
  local ScrollArrowFactor = ViewportPos.Y - self.LastY > 0.0 and -1.0 or 1.0
  self.ScrollList:SetScrollOffset(math.clamp(self.ScrollSpeed * ScrollArrowFactor + self.ScrollList:GetScrollOffset(), 0.0, self.MaxScrollOffset))
  self.LastY = ViewportPos.Y
  return UE.FEventReply()
end
function WBP_HeroTalent_C:IsMouseInScrollPanelRange(MouseEvent)
  local ScreenPos = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local PixelPos, ViewportPos = UE.USlateBlueprintLibrary.AbsoluteToViewport(self, ScreenPos, nil, nil)
  local ScrollPanelPixelPos, ScrollPanelViewportPos = UE.USlateBlueprintLibrary.LocalToViewport(self, self.ScrollPanel:GetCachedGeometry(), UE.FVector2D(), nil, nil)
  local ScrollPanelSize = UE.USlateBlueprintLibrary.GetLocalSize(self.ScrollPanel:GetCachedGeometry())
  local Result = ViewportPos.X < ScrollPanelViewportPos.X or ViewportPos.X > ScrollPanelViewportPos.X + ScrollPanelSize.X or ViewportPos.Y < ScrollPanelViewportPos.Y or ViewportPos.Y > ScrollPanelViewportPos.Y + ScrollPanelSize.Y
  return not Result
end
function WBP_HeroTalent_C:Hide()
  self:SetRoleActorOffset(self.RoleActorOffset * -1)
  local SingleItemClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Talent/WBP_SingleHeroTalentIconItem.WBP_SingleHeroTalentIconItem_C")
  local AllChildren = self.TalentPanel:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    if SingleItem:Cast(SingleItemClass) then
      SingleItem:Hide()
    end
  end
  LogicRole.IsHeroTalentShow = false
  LogicRole.ShowOrHideRoleChangeList(false)
  EventSystem.RemoveListener(EventDef.Lobby.HeroTalentIconItemClicked, WBP_HeroTalent_C.BindOnHeroTalentIconItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateHeroTalentInfo, WBP_HeroTalent_C.BindOnHeroTalentInfoUpdate, self)
end
function WBP_HeroTalent_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.LobbyPanelChanged, WBP_HeroTalent_C.BindOnLobbyActivePanelChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, WBP_HeroTalent_C.BindOnRoleItemClicked, self)
  self:Hide()
end
return WBP_HeroTalent_C
