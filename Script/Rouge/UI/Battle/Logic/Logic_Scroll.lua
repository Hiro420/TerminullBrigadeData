local M = {
  IsInit = false,
  MaxScrollNum = 8,
  NumToZh = {
    NSLOCTEXT("Logic_Scroll", "NumToZh1", "\228\184\128\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh2", "\228\184\164\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh3", "\228\184\137\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh4", "\229\155\155\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh5", "\228\186\148\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh6", "\229\133\173\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh7", "\228\184\131\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh8", "\229\133\171\228\187\182\229\165\151:{0}"),
    NSLOCTEXT("Logic_Scroll", "NumToZh9", "\228\185\157\228\187\182\229\165\151:{0}")
  }
}
_G.Logic_Scroll = _G.Logic_Scroll or M
local INDEX_NONE = -1
EScrollTipsOpenType = {
  EFromBag = 1,
  EFromPickup = 2,
  EFromTeamDamage = 3,
  EFromAllScrollDetailsTips = 4,
  EFromScrollSlot = 5,
  EFromBagPickupList = 6,
  EFromShop = 7,
  EFromScrollSlotSettlement = 8,
  EFromSaveGrowthSnap = 9
}

function Logic_Scroll.Init()
  if Logic_Scroll.IsInit then
    print("Logic_Scroll \229\183\178\229\136\157\229\167\139\229\140\150")
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    Logic_Scroll:BindDelegate(Character)
    return
  end
  Logic_Scroll.IsInit = true
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  Logic_Scroll:BindDelegate(Character)
  EventSystem.AddListener(nil, EventDef.Battle.OnControlledPawnChanged, Logic_Scroll.BindOnControlledPawnChanged)
end

function Logic_Scroll.BindOnControlledPawnChanged(Character)
  Logic_Scroll:BindDelegate(Character)
end

function Logic_Scroll:BindDelegate(Character)
  if not Character then
    return
  end
  EventSystem.AddListenerNew(EventDef.Interact.OnOptimalTargetChanged, nil, Logic_Scroll.BindOnOptimalTargetChanged)
end

function Logic_Scroll.BindOnOptimalTargetChanged(OptimalTarget)
  Logic_Scroll.SetPreOptimalTarget(OptimalTarget)
end

function Logic_Scroll.SetPreOptimalTarget(OptimalTarget)
  Logic_Scroll.PreOptimalTarget = OptimalTarget
end

function Logic_Scroll.ShareAndMarkModify()
  if Logic_Scroll.CheckPickUpCanShare() then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if not Character or not Character.AttributeModifyComponent then
      return
    end
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    if not PC then
      return
    end
    local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
    if not PlayerMiscComp then
      return
    end
    PlayerMiscComp:SharePickupAttributeModify(Logic_Scroll.PreOptimalTarget, Character)
    local MarkHandle = PC:GetComponentByClass(UE.URGMarkHandle:StaticClass())
    if not MarkHandle then
      return
    end
    local MarkInfo = UE.FMarkInfo()
    MarkInfo.TargetActor = Logic_Scroll.PreOptimalTarget
    MarkInfo.HitLocation = Logic_Scroll.PreOptimalTarget:K2_GetActorLocation()
    MarkInfo.Owner = Character
    MarkHandle:ServerAddMark(MarkInfo)
  end
end

function Logic_Scroll.CheckPickUpCanShare()
  if not Logic_Scroll.PreOptimalTarget then
    print(" WBP_ScrollTipsView_C:CheckCanShare PreOptimalTarget IsNull")
    return false
  end
  if not Logic_Scroll.PreOptimalTarget.ModifyId then
    print(" WBP_ScrollTipsView_C:CheckCanShare PreOptimalTarget ModifyId IsNull")
    return false
  end
  return not Logic_Scroll.PreOptimalTarget:IsShared()
end

function Logic_Scroll.ShareModify(ScrollId)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character and Character.AttributeModifyComponent then
    LogicAudio.OnDropReel()
    Character.AttributeModifyComponent:ShareModify(ScrollId, false)
  end
end

function Logic_Scroll.DiscardModify(ScrollId)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character and Character.AttributeModifyComponent then
    LogicAudio.OnDropReel()
    Character.AttributeModifyComponent:DiscardModify(ScrollId, false)
  end
end

function Logic_Scroll.PickupScroll(Target, bIsShowTips)
  if not Target then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  if Character.LifeState ~= UE.ERGLifeState.Alive then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local MiscHelper = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not MiscHelper then
    return
  end
  local ModifyCount = Character.AttributeModifyComponent.ActivatedModifies:Num()
  if ModifyCount >= Logic_Scroll.MaxScrollNum then
    if bIsShowTips then
      local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if WaveWindowManager then
        local Param = {}
        WaveWindowManager:ShowWaveWindow(1124, Param)
      end
    end
    return
  end
  for i, v in iterator(Character.AttributeModifyComponent.ActivatedModifies) do
    if v == Target.ScrollId then
      local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if WaveWindowManager then
        local Param = {}
        WaveWindowManager:ShowWaveWindow(1137, Param)
      end
      return
    end
  end
  local attrCom = Character:GetComponentByClass(UE.URGAttributeModifyComponent:StaticClass())
  attrCom:StoreEquipModify(Target.ScrollId, Target.IsShared)
end

function Logic_Scroll:CheckScrollIsFull()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character and Character.AttributeModifyComponent then
    return Character.AttributeModifyComponent.ActivatedModifies:Length() >= Logic_Scroll.MaxScrollNum
  end
  return false
end

function Logic_Scroll:CheckScrollIsDuplicated(ScrollId)
  if not ScrollId then
    return false
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character and Character.AttributeModifyComponent then
    for i, v in iterator(Character.AttributeModifyComponent.ActivatedModifies) do
      if ScrollId == v then
        return true
      end
    end
  end
  return false
end

function Logic_Scroll:CheckSetIsActived(SetData)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("Logic_Scroll:CheckSetIsActived not DTSubsystem")
    return false
  end
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(SetData.SetId, nil)
  if ResultModifySet then
    if AttributeModifySetRow.BaseInscription.Level <= SetData.Level then
      return true
    end
    for k, v in pairs(AttributeModifySetRow.LevelInscriptionMap) do
      if k <= SetData.Level then
        return true
      end
    end
  end
  return false
end

function Logic_Scroll:GetModifySetMaxLevel(SetData)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollSetItem_C:InitScrollSetItem not DTSubsystem")
    return 0
  end
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(SetData.SetId, nil)
  if ResultModifySet then
    local Level = 0
    for k, v in pairs(AttributeModifySetRow.LevelInscriptionMap) do
      if k > Level then
        Level = k
      end
    end
    if Level <= AttributeModifySetRow.BaseInscription.Level then
      Level = AttributeModifySetRow.BaseInscription.Level
    end
    return Level
  end
  return 0
end

function Logic_Scroll:GetInscriptionBySetLv(Lv, SetId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollSetHintItem_C:InitHudScrollSetItem not DTSubsystem")
    return nil
  end
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(SetId, nil)
  if ResultModifySet then
    if AttributeModifySetRow.BaseInscription.Level == Lv then
      return AttributeModifySetRow.BaseInscription.BaseInscriptionId
    else
      return AttributeModifySetRow.LevelInscriptionMap:Find(Lv)
    end
  end
end

function Logic_Scroll.Clear()
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, Logic_Scroll.BindOnControlledPawnChanged, nil)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  EventSystem.RemoveListenerNew(EventDef.Interact.OnOptimalTargetChanged, nil, Logic_Scroll.BindOnOptimalTargetChanged)
  Logic_Scroll.IsInit = false
end
