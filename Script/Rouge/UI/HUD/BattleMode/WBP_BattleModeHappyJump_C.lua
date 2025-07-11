local WBP_BattleModeHappyJump_C = UnLua.Class()
function WBP_BattleModeHappyJump_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_BattleModeHappyJump_C:OnInit(Id)
  self:Reset()
  self.WBP_BattleModeContent.bNeedProgressBar = 1005 == Id
end
function WBP_BattleModeHappyJump_C:OnDeInit()
  self:Reset()
end
function WBP_BattleModeHappyJump_C:BeginAssembly()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.BeginAssemblyStage)
  LogicAudio.OnFunJumpGather()
end
function WBP_BattleModeHappyJump_C:EndAssembly()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.EndAssemblyStage)
end
function WBP_BattleModeHappyJump_C:BeginChanllenge()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.BeginChallengeStage)
  LogicAudio.OnFunJumpStart()
end
function WBP_BattleModeHappyJump_C:UpdateAwards(OverlayAward, AwardTempleteItem, HorizontalBoxAwardsRoot)
  do return end
  UpdateVisibility(OverlayAward, false)
  local BattleModeNpcCls = UE.ABattleModeNpc:StaticClass()
  local AllBattleModeNpcActors = UE.UGameplayStatics.GetAllActorsOfClass(self, BattleModeNpcCls, nil)
  if nil == AllBattleModeNpcActors or 0 == AllBattleModeNpcActors:Num() then
    return
  end
  local BattleModeNpc = AllBattleModeNpcActors:Get(1)
  local Index = 1
  if BattleModeNpc and BattleModeNpc:GetBattleModeReward().SpecialReward then
    UpdateVisibility(OverlayAward, true)
    local AwardItem = GetOrCreateItem(HorizontalBoxAwardsRoot, Index, AwardTempleteItem:GetClass())
    AwardItem:Init(BattleModeNpc:GetBattleModeReward().SpecialReward, 1)
    Index = Index + 1
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if LogicBattleMode.BattleMode and BattleModeNpc and DTSubsystem then
    local Result, RowInfo = DTSubsystem:GetBattleModeRowInfoById(LogicBattleMode.BattleMode:GetBattleModeId(), nil)
    local BattleModeRewardGroup
    if Result then
      if BattleModeNpc:GetBattleModeReward().FinalRewardGrade == UE.EBattleModeRewardGrade.Gold then
        BattleModeRewardGroup = RowInfo.ARewards:GetRef(BattleModeNpc:GetBattleModeReward().RewardGroupIndex)
      elseif BattleModeNpc:GetBattleModeReward().FinalRewardGrade == UE.EBattleModeRewardGrade.Silver then
        BattleModeRewardGroup = RowInfo.BRewards:GetRef(BattleModeNpc:GetBattleModeReward().RewardGroupIndex)
      elseif BattleModeNpc:GetBattleModeReward().FinalRewardGrade == UE.EBattleModeRewardGrade.Copper then
        BattleModeRewardGroup = RowInfo.CRewards:GetRef(BattleModeNpc:GetBattleModeReward().RewardGroupIndex)
      end
    end
    if BattleModeRewardGroup then
      UpdateVisibility(OverlayAward, true)
      for i, v in iterator(BattleModeRewardGroup.Items) do
        local AwardItem = GetOrCreateItem(HorizontalBoxAwardsRoot, Index, AwardTempleteItem:GetClass())
        AwardItem:Init(v.ItemId, v.Count)
        Index = Index + 1
      end
    end
  end
  HideOtherItem(HorizontalBoxAwardsRoot, Index)
end
function WBP_BattleModeHappyJump_C:EndChallenge()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.EndChallengeStage)
end
function WBP_BattleModeHappyJump_C:ShowSuccess()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.SuccessStage)
  LogicAudio.OnFunJumpSuccess()
end
function WBP_BattleModeHappyJump_C:ShowFailed()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.FailedStage)
  LogicAudio.OnFunJumpFail()
end
function WBP_BattleModeHappyJump_C:OccupancyShutdown()
end
function WBP_BattleModeHappyJump_C:Reset()
end
function WBP_BattleModeHappyJump_C:FocusInput()
  self.Overridden.UnfocusInput(self)
end
function WBP_BattleModeHappyJump_C:Destruct()
  self.Overridden.Destruct(self)
end
return WBP_BattleModeHappyJump_C
