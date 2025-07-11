local WBP_RGBeginnerGuidanceOperateTip_C = UnLua.Class()
function WBP_RGBeginnerGuidanceOperateTip_C:Construct()
  self.AppendText = ""
  self.OriginText = ""
  self.IsLeft = true
  self.IsWaitInit = false
end
function WBP_RGBeginnerGuidanceOperateTip_C:RefreshInfo(BeginnerGuidanceTipRowId, MissionId)
  self.BeginnerGuidanceTipRowId = BeginnerGuidanceTipRowId
  self.MissionId = MissionId
  if self:IsAnimationPlaying(self.Ani_out) then
    print("\230\173\163\229\156\168\230\146\173\230\148\190\231\187\147\230\157\159\229\138\168\231\148\187\239\188\140\229\136\157\229\167\139\229\140\150\230\142\168\232\191\159")
    self.IsWaitInit = true
    return
  end
  local Result, RowInfo = GetRowData(DT.DT_RGBeginnerGuidanceTip, BeginnerGuidanceTipRowId)
  if not Result then
    return
  end
  if self:IsAnimationPlaying(self.Ani_in) then
    self:StopAnimation(self.Ani_in)
  end
  self:PlayAnimationForward(self.Ani_in)
  LogicAudio.OnOperateTipAppear()
  self.Txt_Title:SetText(RowInfo.Title)
  if UE.URGBlueprintLibrary.IsValidSoftObjectPath(RowInfo.SpecialDescWidgetClassPath) then
    self.RGBeginnerGuidanceDescItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.SpecialDescWidgetPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local WidgetClass = UE.URGAssetManager.GetAssetByPath(RowInfo.SpecialDescWidgetClassPath, true)
    local Item = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
    if Item.Show then
      Item:Show()
    end
    self.DescItemList:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.SpecialDescWidgetPanel:AddChild(Item)
  else
    self.SpecialDescWidgetPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.DescItemList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
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
end
function WBP_RGBeginnerGuidanceOperateTip_C:Hide()
  self.IsWaitInit = false
  if self:IsAnimationPlaying(self.Ani_out) then
    self.IsInitiativeStop = true
    self:StopAnimation(self.Ani_out)
  end
  self.IsInitiativeStop = false
  self:PlayAnimationForward(self.Ani_out)
end
function WBP_RGBeginnerGuidanceOperateTip_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_in then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimeoutAutoHideTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimeoutAutoHideTimer)
    end
    local Result, RowInfo = GetRowData(DT.DT_RGBeginnerGuidanceTip, self.BeginnerGuidanceTipRowId)
    if Result and 0 ~= RowInfo.MaxExistTime then
      self.TimeoutAutoHideTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        GameInstance,
        function()
          print("ywtao,WBP_RGBeginnerGuidanceOperateTip_C:TimeoutAutoHideTimer")
          self:Hide()
        end
      }, RowInfo.MaxExistTime, false)
    end
  end
  if Animation == self.Ani_out and not self.IsInitiativeStop then
    if self.IsWaitInit then
      self:RefreshInfo(self.BeginnerGuidanceTipRowId)
    else
      self.OriginText = ""
      self.AppendText = ""
      self:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.SpecialDescWidgetPanel:ClearChildren()
    end
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimeoutAutoHideTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimeoutAutoHideTimer)
    end
    EventSystem.Invoke(EventDef.BeginnerGuide.OnBeginnerMissionFinished, self.MissionId)
  end
end
return WBP_RGBeginnerGuidanceOperateTip_C
