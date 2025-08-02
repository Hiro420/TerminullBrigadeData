local WBP_BattleModeTip_C = UnLua.Class()

function WBP_BattleModeTip_C:InitInfo(Owner)
  self.Owner = Owner
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = DTSubsystem:GetBattleModeRowInfoById(Owner.BattleModeId, nil)
  if not Result then
    return
  end
  self.Txt_Name:SetText(RowInfo.Name)
  self.Txt_Desc:SetText(self.Owner:GetBattleDesc())
end

function WBP_BattleModeTip_C:SetIsInteract(IsInteract)
  self.IsInteract = IsInteract
end

function WBP_BattleModeTip_C:ChangeStatusWidget(Type)
  local LastType = self.Type
  self.Type = Type
  local TargetWidget = self.EmptyPanel
  if Type == UE.ERGBattleModeShowType.Lock then
    if self.IsInteract then
      TargetWidget = self.LockInteractPanel
    end
  elseif Type == UE.ERGBattleModeShowType.Pending then
    if self.IsInteract then
      if LastType and LastType ~= self.Type then
        local HUD = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
        if HUD then
          HUD:BindOnOptimalTargetChanged(self.Owner)
        end
      end
    else
      TargetWidget = self.PendingPanel
    end
  elseif Type == UE.ERGBattleModeShowType.Finished then
    TargetWidget = self.FinishPanel
    self:RefreshFinishRewardList()
  end
  self.StatusWidgetSwitcher:SetActiveWidget(TargetWidget)
end

function WBP_BattleModeTip_C:RefreshFinishRewardList()
  local AllChildren = self.FinishRewardList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local BattleModeReward = self.Owner:GetBattleModeReward()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = DTSubsystem:GetBattleModeRowInfoById(BattleModeReward.ModeId, nil)
  if not Result then
    return
  end
  local TargetRewardList, TargetRewardGroup
  if BattleModeReward.FinalRewardGrade == UE.EBattleModeRewardGrade.Gold then
    TargetRewardGroup = RowInfo.ARewards
  elseif BattleModeReward.FinalRewardGrade == UE.EBattleModeRewardGrade.Silver then
    TargetRewardGroup = RowInfo.BRewards
  elseif BattleModeReward.FinalRewardGrade == UE.EBattleModeRewardGrade.Copper then
    TargetRewardGroup = RowInfo.CRewards
  end
  if not TargetRewardGroup then
    return
  end
  if TargetRewardGroup:IsValidIndex(BattleModeReward.RewardGroupIndex + 1) then
    TargetRewardList = TargetRewardGroup:GetRef(BattleModeReward.RewardGroupIndex + 1).Items
  end
  local Padding = UE.FMargin()
  Padding.Right = self.RewardItemSpacer
  local Index = 0
  if TargetRewardList then
    for key, SingleRewardValue in pairs(TargetRewardList) do
      local ItemWidget = self.FinishRewardList:GetChildAt(Index)
      if not ItemWidget then
        ItemWidget = UE.UWidgetBlueprintLibrary.Create(self, UE.UGameplayStatics.GetObjectClass(self.FinishRewardItemTemplate))
        self.FinishRewardList:AddChild(ItemWidget)
      end
      local Slot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(ItemWidget)
      Slot:SetPadding(Padding)
      ItemWidget:Show(SingleRewardValue)
      Index = Index + 1
    end
  end
  if -1 ~= BattleModeReward.SpecialReward then
    local GroupItem = UE.FBattleModeRewardGroupItem()
    GroupItem.ItemId = BattleModeReward.SpecialReward
    GroupItem.Count = 1
    local SpecialWidget = self.FinishRewardList:GetChildAt(Index)
    if not SpecialWidget then
      SpecialWidget = UE.UWidgetBlueprintLibrary.Create(self, UE.UGameplayStatics.GetObjectClass(self.FinishRewardItemTemplate))
      self.FinishRewardList:AddChild(SpecialWidget)
    end
    local Slot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(SpecialWidget)
    Slot:SetPadding(Padding)
    SpecialWidget:Show(GroupItem)
  end
end

function WBP_BattleModeTip_C:Destruct()
end

return WBP_BattleModeTip_C
