local M = {IsInit = false, CanShowDamageNumber = true}
_G.LogicDamageNumber = _G.LogicDamageNumber or M
local ListContainer = require("Rouge.UI.Common.ListContainer")

function LogicDamageNumber.Init()
  if LogicDamageNumber.IsInit then
    print("LogicDamageNumber \229\183\178\229\136\157\229\167\139\229\140\150")
    return
  end
  LogicDamageNumber.IsInit = true
  LogicDamageNumber.LuckyShotNum = 0
  LogicDamageNumber.LastHitActor = nil
  local DamageSettings = UE.URGDamageSettings.GetSettings()
  if DamageSettings then
    LogicDamageNumber.MaxDamageNum = DamageSettings.MaxDamageNumberNum
  else
    LogicDamageNumber.MaxDamageNum = 20
  end
  LogicDamageNumber.MaxLastDamageValueNum = DamageSettings.MaxLastDamageValueNum
  LogicDamageNumber.BigDamagePercent = DamageSettings.BigDamagePercent
  LogicDamageNumber.LastDamageValueList = {}
  LogicDamageNumber.LatestAttackId = nil
  LogicDamageNumber.LatestWidgets = {}
  local WidgetSoftPath = UE.UKismetSystemLibrary.MakeSoftObjectPath("/Game/Rouge/UI/Battle/WBP_DamageNumber.WBP_DamageNumber_C")
  LogicDamageNumber.WidgetClass = UE.URGAssetManager.GetAssetByPath(WidgetSoftPath, true)
  LogicDamageNumber.ListContainer = ListContainer.New(LogicDamageNumber.WidgetClass, LogicDamageNumber.MaxDamageNum)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if PC and PC.DamageComponent then
    PC.DamageComponent.OnMakeDamage:Add(GameInstance, LogicDamageNumber.BindOnMakeDamage)
  else
    print("LogicDamageNumber.Init PC", PC, "DamageComponent", PC.DamageComponent)
    LogicDamageNumber.BindMakeDamageTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
        if PC and PC.DamageComponent then
          PC.DamageComponent.OnMakeDamage:Add(GameInstance, LogicDamageNumber.BindOnMakeDamage)
          if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(LogicDamageNumber.BindMakeDamageTimer) then
            UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, LogicDamageNumber.BindMakeDamageTimer)
          end
        end
      end
    }, 0.1, true)
  end
  ListenObjectMessage(nil, GMP.MSG_Global_RequestHitReactionSucceed, GameInstance, LogicDamageNumber.BindOnGlobalRequestHitReactionSucceed)
  ListenObjectMessage(nil, GMP.MSG_GM_ChangeAllUIVis, GameInstance, LogicDamageNumber.BindOnChangeAllUIVis)
  EventSystem.AddListener(nil, EventDef.Battle.OnHealthChanged, LogicDamageNumber.BindOnHealthChanged)
end

function LogicDamageNumber:BindOnMakeDamage(SourceActor, TargetActor, Params)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local ParamsInstigator = UE.URGDamageStatics.GetDamageParams_Instigator(Params)
  if TargetActor == Character then
    return
  end
  if not SourceActor then
    print("LogicDamageNumber:BindOnMakeDamage SourceActor is nil!")
    return
  end
  local IsNotCauseBySourceInstigator = Character ~= ParamsInstigator and not UE.URGDamageStatics.IsLocalPlayerAttack(SourceActor)
  if not (Character and SourceActor) or Character ~= SourceActor and IsNotCauseBySourceInstigator then
    print("LogicDamageNumber:BindOnMakeDamage \228\184\141\230\152\175\232\135\170\229\183\177\233\128\160\230\136\144\231\154\132\228\188\164\229\174\179")
    return
  end
  if UE.URGDamageStatics.IsVisibleNumber(Params) == false then
    print("LogicDamageNumber:BindOnMakeDamage \228\184\141\230\152\190\231\164\186\228\188\164\229\174\179\232\183\179\229\173\151")
    return
  end
  LogicAudio.OnSkillHit(Params, TargetActor, SourceActor)
  if LogicDamageNumber.ListContainer:GetAllUseWidgetsCount() >= LogicDamageNumber.MaxDamageNum then
    local Item = LogicDamageNumber.ListContainer:GetOrCreateItem()
    LogicDamageNumber.ListContainer:HideItem(Item)
  end
  local DamageValue = UE.URGDamageStatics.GetDamageValue(Params)
  if 0 ~= DamageValue then
    if #LogicDamageNumber.LastDamageValueList >= LogicDamageNumber.MaxLastDamageValueNum then
      table.remove(LogicDamageNumber.LastDamageValueList, 1)
    end
    table.insert(LogicDamageNumber.LastDamageValueList, DamageValue)
  end
  LogicDamageNumber:UpdateLuckyShotNum(TargetActor, Params)
  LogicDamageNumber:CreateDamageNumberWidget(TargetActor, Params, nil)
end

function LogicDamageNumber.BindOnGlobalRequestHitReactionSucceed(SourceActor, TargetActor, HitReactionTag)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if TargetActor == Character then
    return
  end
  if not SourceActor then
    return
  end
  local IsNotCauseBySourceInstigator = not UE.URGDamageStatics.IsLocalPlayerAttack(SourceActor)
  if not (Character and SourceActor) or Character ~= SourceActor and IsNotCauseBySourceInstigator then
    print("LogicDamageNumber:BindOnGlobalRequestHitReactionSucceed \228\184\141\230\152\175\232\135\170\229\183\177\233\128\160\230\136\144\231\154\132")
    return
  end
  local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(HitReactionTag)
  local Result, RowInfo = GetRowData(DT.DT_NumberStyleByHitReaction, TagName)
  if not Result then
    print("LogicDamageNumber:BindOnGlobalRequestHitReactionSucceed not found RowInfo, RowName:", TagName)
    return
  end
  print("LogicDamageNumber:BindOnGlobalRequestHitReactionSucceed \229\136\155\229\187\186\229\143\151\229\135\187\230\149\136\230\158\156\232\183\179\229\173\151")
  if LogicDamageNumber.ListContainer:GetAllUseWidgetsCount() >= LogicDamageNumber.MaxDamageNum then
    local Item = LogicDamageNumber.ListContainer:GetOrCreateItem()
    LogicDamageNumber.ListContainer:HideItem(Item)
  end
  LogicDamageNumber:CreateDamageNumberWidget(TargetActor, nil, HitReactionTag)
end

function LogicDamageNumber.BindOnChangeAllUIVis(IsHide, IsShowDamageNumber)
  print("LogicDamageNumber:BindOnChangeAllUIVis IsHide:", IsHide, "IsShowDamageNumber:", IsShowDamageNumber)
  local IsNeedShowDamageNumber = true
  if IsHide then
    IsNeedShowDamageNumber = IsShowDamageNumber
  end
  LogicDamageNumber.CanShowDamageNumber = IsNeedShowDamageNumber
end

function LogicDamageNumber.BindOnHealthChanged(NewValue, OldValue)
  if not (NewValue and OldValue) or -1 == OldValue or NewValue <= OldValue then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  print("LogicDamageNumber:BindOnHealthChanged \229\136\155\229\187\186\229\155\158\232\161\128\230\149\136\230\158\156\232\183\179\229\173\151")
  if LogicDamageNumber.ListContainer:GetAllUseWidgetsCount() >= LogicDamageNumber.MaxDamageNum then
    local Item = LogicDamageNumber.ListContainer:GetOrCreateItem()
    LogicDamageNumber.ListContainer:HideItem(Item)
  end
  LogicDamageNumber:CreateDamageNumberWidget(Character, nil, nil, NewValue - OldValue)
end

function LogicDamageNumber:CreateDamageNumberWidget(TargetActor, Params, HitReactionTag, HealthChangedText)
  if not LogicDamageNumber.CanShowDamageNumber then
    print("LogicDamageNumber:CreateDamageNumberWidget CanShowDamageNumber is false")
    return
  end
  local Widget = LogicDamageNumber.ListContainer:GetOrCreateItem()
  if Widget then
    if not Widget:IsInViewport() then
      Widget:AddToViewport(-1)
    end
    LogicDamageNumber.ListContainer:ShowItem(Widget, TargetActor, Params, HitReactionTag, HealthChangedText)
    if not HealthChangedText and not HitReactionTag and not UE.URGDamageStatics.IsDot(Params) then
      if LogicDamageNumber.LatestAttackId and not UE.URGDamageStatics.EqualEqual_AttackId(UE.URGDamageStatics.GetAttackId(Params), LogicDamageNumber.LatestAttackId) then
        for i, SingleWidget in ipairs(LogicDamageNumber.LatestWidgets) do
          if table.Contain(LogicDamageNumber.ListContainer.AllUseWidgets, SingleWidget) then
            SingleWidget:ShowOrHideLatestMark(false)
          end
        end
        LogicDamageNumber.LatestWidgets = {}
      end
      LogicDamageNumber.LatestAttackId = UE.URGDamageStatics.GetAttackId(Params)
      table.insert(LogicDamageNumber.LatestWidgets, Widget)
      Widget:ShowOrHideLatestMark(true)
    end
  end
end

function LogicDamageNumber.IsBigDamage(Params)
  if not Params then
    return false
  end
  if UE.URGDamageStatics.IsDot(Params) then
    return false
  end
  local DamageValue = UE.URGDamageStatics.GetDamageValue(Params)
  local MoreCount = 0
  for index, SingleValue in ipairs(LogicDamageNumber.LastDamageValueList) do
    if SingleValue < DamageValue then
      MoreCount = MoreCount + 1
    end
  end
  return MoreCount / LogicDamageNumber.MaxLastDamageValueNum >= LogicDamageNumber.BigDamagePercent
end

function LogicDamageNumber:CreateMultiElementWidget(TargetActor, Params)
  if UE.URGDamageStatics.IsMixedElementTriggered(Params) then
    local FirstElementId = 0
    local SecondElementId = 0
    if UE.URGDamageStatics.IsFire(Params) then
      if 0 == FirstElementId then
        FirstElementId = UE.ERGElementType.Fire
      else
        SecondElementId = UE.ERGElementType.Fire
      end
    end
    if UE.URGDamageStatics.IsIce(Params) then
      if 0 == FirstElementId then
        FirstElementId = UE.ERGElementType.Ice
      else
        SecondElementId = UE.ERGElementType.Ice
      end
    end
    if UE.URGDamageStatics.IsElectric(Params) then
      if 0 == FirstElementId then
        FirstElementId = UE.ERGElementType.Electric
      else
        SecondElementId = UE.ERGElementType.Electric
      end
    end
    if UE.URGDamageStatics.IsPoison(Params) then
      if 0 == FirstElementId then
        FirstElementId = UE.ERGElementType.Poison
      else
        SecondElementId = UE.ERGElementType.Poison
      end
    end
    local TargetElementId = UE.URGElementStatics.MakeMixedElementId(FirstElementId, SecondElementId)
    LogicDamageNumber:CreateDamageNumberWidget(TargetActor, Params, TargetElementId)
  end
end

function LogicDamageNumber:GetTriggerElementType(Params)
  if not Params then
    return 0
  end
  if UE.URGDamageStatics.IsFireTriggered(Params) then
    return UE.ERGElementType.Fire
  end
  if UE.URGDamageStatics.IsIceTriggered(Params) then
    return UE.ERGElementType.Ice
  end
  if UE.URGDamageStatics.IsElectricTriggered(Params) then
    return UE.ERGElementType.Electric
  end
  if UE.URGDamageStatics.IsPoisonTriggered(Params) then
    return UE.ERGElementType.Poison
  end
  return 0
end

function LogicDamageNumber:UpdateLuckyShotNum(TargetActor, Params)
  if not UE.URGDamageStatics.IsLuckyShot(Params) then
    LogicDamageNumber.LuckyShotNum = 0
    LogicDamageNumber.LastHitActor = nil
    return
  end
  if LogicDamageNumber.LastHitActor and LogicDamageNumber.LastHitActor == TargetActor then
    LogicDamageNumber.LuckyShotNum = LogicDamageNumber.LuckyShotNum + 1
  else
    LogicDamageNumber.LuckyShotNum = 1
    LogicDamageNumber.LastHitActor = TargetActor
  end
end

function LogicDamageNumber:Clear()
  print("Clear LogicDamageNumber")
  LogicDamageNumber.LastDamageValueList = {}
  if LogicDamageNumber.ListContainer then
    LogicDamageNumber.ListContainer:ClearAllWidgets()
    LogicDamageNumber.ListContainer = nil
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(LogicDamageNumber.BindMakeDamageTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, LogicDamageNumber.BindMakeDamageTimer)
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if PC and PC.DamageComponent then
    PC.DamageComponent.OnMakeDamage:Remove(GameInstance, LogicDamageNumber.BindOnMakeDamage)
  end
  LogicDamageNumber.IsInit = false
  UnListenObjectMessage(GMP.MSG_Global_RequestHitReactionSucceed, GameInstance)
  UnListenObjectMessage(GMP.MSG_GM_ChangeAllUIVis, GameInstance)
  EventSystem.RemoveListener(EventDef.Battle.OnHealthChanged, LogicDamageNumber.BindOnHealthChanged)
end
