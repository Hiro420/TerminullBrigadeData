local WBP_RGBeginnerGuidanceMovieTip_C = UnLua.Class()

function WBP_RGBeginnerGuidanceMovieTip_C:Construct()
  self.BeginnerRowIdList = {}
  self.CurBeginnerRowIdIndex = -1
end

function WBP_RGBeginnerGuidanceMovieTip_C:RefreshInfo(BeginnerRowId, MissionId)
  self.MissionId = MissionId
  table.insert(self.BeginnerRowIdList, BeginnerRowId)
  if -1 == self.CurBeginnerRowIdIndex then
    self.CurBeginnerRowIdIndex = 1
    if not IsListeningForInputAction(self, self.NextKeyRowName) then
      ListenForInputAction(self.NextKeyRowName, UE.EInputEvent.IE_Pressed, true, {
        self,
        self.BindOnNextKeyRowName
      })
    end
    if not IsListeningForInputAction(self, self.LastKeyRowName) then
      ListenForInputAction(self.LastKeyRowName, UE.EInputEvent.IE_Pressed, true, {
        self,
        self.BindOnLastKeyRowName
      })
    end
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    SetInputIgnore(Character, true)
    self:SetInvincible(true)
    self:RefreshPanelInfo()
    LogicAudio.OnMovieTipAppear()
  end
  self:RefreshOperateTipVis()
end

function WBP_RGBeginnerGuidanceMovieTip_C:RefreshPanelInfo()
  local TargetBeginnerRowId = self.BeginnerRowIdList[self.CurBeginnerRowIdIndex]
  if not TargetBeginnerRowId then
    print("WBP_RGBeginnerGuidanceMovieTip_C:RefreshPanelInfo not BeginnerRowId, Index is ", self.CurBeginnerRowIdIndex)
    self:Hide()
    return
  end
  local Result, RowInfo = GetRowData(DT.DT_RGBeginnerGuidanceTip, TargetBeginnerRowId)
  if not Result then
    print("WBP_RGBeginnerGuidanceMovieTip_C:RefreshInfo not found BeginnerRowInfo, ", TargetBeginnerRowId)
    self:SetVisibility(UE.ESlateVisibility.Collasped)
    return
  end
  local InputHandle = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
  InputHandle:ReleaseAllBindEvents()
  self.Txt_Title:SetText(RowInfo.Title)
  if UE.URGBlueprintLibrary.IsValidSoftObjectPath(RowInfo.Media) then
    local MediaObj = UE.URGAssetManager.GetAssetByPath(RowInfo.Media, true)
    if MediaObj then
      self.MediaPlayer:SetLooping(true)
      UpdateVisibility(self.Img_Movie, true)
      self.MediaPlayer:OpenSource(MediaObj)
      self.MediaPlayer:Rewind()
    end
  end
  local AllChildren = self.DescItemList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local Item, Index = nil, 1
  local KeyInfoList = {}
  for key, SingleDesc in pairs(RowInfo.DescList) do
    Item = self.DescItemList:GetChildAt(Index - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.RGBeginnerGuidanceDescItem:StaticClass())
      self.DescItemList:AddChild(Item)
    end
    Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if RowInfo.KeyInfoList:IsValidIndex(Index) then
      KeyInfoList = RowInfo.KeyInfoList:GetRef(Index).KeyInfoList
    else
      KeyInfoList = nil
    end
    Item:UpdateText(SingleDesc, KeyInfoList)
    Index = Index + 1
  end
end

function WBP_RGBeginnerGuidanceMovieTip_C:BindOnNextKeyRowName()
  if self.CurBeginnerRowIdIndex == table.count(self.BeginnerRowIdList) then
    print("WBP_RGBeginnerGuidanceMovieTip_C:BindOnNextKeyRowName\229\183\178\231\187\143\230\156\128\229\164\167")
    self:Hide()
    self:SendMovieStoppedMessage()
    EventSystem.Invoke(EventDef.BeginnerGuide.OnBeginnerMissionFinished, self.MissionId)
    self:SetInvincible(false)
    LogicAudio.OnMovieTipDisappear()
    return
  end
  self.CurBeginnerRowIdIndex = math.clamp(self.CurBeginnerRowIdIndex + 1, 1, table.count(self.BeginnerRowIdList))
  self:RefreshOperateTipVis()
  self:RefreshPanelInfo()
end

function WBP_RGBeginnerGuidanceMovieTip_C:BindOnLastKeyRowName()
  if 1 == self.CurBeginnerRowIdIndex then
    print("WBP_RGBeginnerGuidanceMovieTip_C:BindOnLastKeyRowName\229\183\178\231\187\143\230\156\128\229\176\143")
    return
  end
  self.CurBeginnerRowIdIndex = math.clamp(self.CurBeginnerRowIdIndex - 1, 1, table.count(self.BeginnerRowIdList))
  self:RefreshOperateTipVis()
  self:RefreshPanelInfo()
end

function WBP_RGBeginnerGuidanceMovieTip_C:RefreshOperateTipVis()
  if table.count(self.BeginnerRowIdList) > 1 then
    if 1 == self.CurBeginnerRowIdIndex then
      self.LastStepInteractTip:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.LastStepInteractTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.LastStepInteractTip:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_RGBeginnerGuidanceMovieTip_C:Hide()
  self.BeginnerRowIdList = {}
  self.CurBeginnerRowIdIndex = -1
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if IsListeningForInputAction(self, self.NextKeyRowName) then
    StopListeningForInputAction(self, self.NextKeyRowName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.LastKeyRowName) then
    StopListeningForInputAction(self, self.LastKeyRowName, UE.EInputEvent.IE_Pressed)
  end
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
      SetInputIgnore(Character, false)
    end
  })
end

function WBP_RGBeginnerGuidanceMovieTip_C:SetInvincible(IsInvincible)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  CoreComp:SetInvincible(IsInvincible)
end

return WBP_RGBeginnerGuidanceMovieTip_C
