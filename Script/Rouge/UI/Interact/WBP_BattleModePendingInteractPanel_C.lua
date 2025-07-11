local WBP_BattleModePendingInteractPanel_C = UnLua.Class()
function WBP_BattleModePendingInteractPanel_C:UpdateInteractInfo(InteractTipRow, TargetActor)
  self.Owner = TargetActor
  local Result, RowInfo = GetRowData(DT.DT_BattleMode, self.Owner.BattleModeId)
  if Result then
    self.Txt_Name:SetText(RowInfo.Name)
    self.Txt_Desc:SetText(self.Owner:GetBattleDesc())
  end
  self:RefreshRewardList()
end
function WBP_BattleModePendingInteractPanel_C:RefreshRewardList()
  local AllChildren = self.RewardList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local BattleModeReward = self.Owner:GetBattleModeReward()
  local Result, RowInfo = GetRowData(DT.DT_BattleMode, BattleModeReward.ModeId)
  if not Result then
    return
  end
  local TargetRewardList
  if RowInfo.ARewards:IsValidIndex(BattleModeReward.RewardGroupIndex + 1) then
    TargetRewardList = RowInfo.ARewards:GetRef(BattleModeReward.RewardGroupIndex + 1).Items
  end
  local Padding = UE.FMargin()
  Padding.Right = self.RewardItemSpacer
  local Index = 0
  if TargetRewardList then
    for key, SingleRewardValue in pairs(TargetRewardList) do
      local ItemWidget = self.RewardList:GetChildAt(Index)
      if not ItemWidget then
        ItemWidget = UE.UWidgetBlueprintLibrary.Create(self, UE.UGameplayStatics.GetObjectClass(self.RewardItemTemplate))
        self.RewardList:AddChild(ItemWidget)
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
    local SpecialWidget = self.RewardList:GetChildAt(Index)
    if not SpecialWidget then
      SpecialWidget = UE.UWidgetBlueprintLibrary.Create(self, UE.UGameplayStatics.GetObjectClass(self.RewardItemTemplate))
      self.RewardList:AddChild(SpecialWidget)
    end
    local Slot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(SpecialWidget)
    Slot:SetPadding(Padding)
    SpecialWidget:Show(GroupItem)
  end
end
function WBP_BattleModePendingInteractPanel_C:BindOnGameplayTeachingPressed()
  print("\231\142\169\230\179\149\230\149\153\229\173\166")
  RGUIMgr:OpenUI(UIConfig.WBP_BattleModeTeaching_C.UIName)
  local TargetUI = RGUIMgr:GetUI(UIConfig.WBP_BattleModeTeaching_C.UIName)
  if TargetUI then
    TargetUI:InitInfo(self.Owner)
  end
end
function WBP_BattleModePendingInteractPanel_C:HideWidget()
end
function WBP_BattleModePendingInteractPanel_C:Destruct()
  self:HideWidget()
end
return WBP_BattleModePendingInteractPanel_C
