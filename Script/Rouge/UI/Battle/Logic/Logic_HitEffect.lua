LogicHitEffect = LogicHitEffect or {IsInit = false}
local ListContainer = require("Rouge.UI.Common.ListContainer")

function LogicHitEffect.Init()
  if LogicHitEffect.IsInit then
    print("LogicHitEffect \229\183\178\229\136\157\229\167\139\229\140\150")
    LogicHitEffect.InitHealthAndShieldValue()
    return
  end
  LogicHitEffect.IsInit = true
  LogicHitEffect.InitHealthAndShieldValue()
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HitEffect.WBP_HitEffect_C")
  LogicHitEffect.ListContainer = ListContainer.New(WidgetClass, 5)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if PC and PC.DamageComponent then
    PC.DamageComponent.OnMakeDamage:Add(GameInstance, LogicHitEffect.BindOnMakeDamage)
  end
end

function LogicHitEffect.InitHealthAndShieldValue()
  local LocalPlayer = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local CoreComp = LocalPlayer.CoreComponent
  if not CoreComp then
    return
  end
  LogicHitEffect.LastHealthValue = CoreComp:GetHealth()
  LogicHitEffect.LastShieldValue = CoreComp:GetShield()
end

function LogicHitEffect:BindOnMakeDamage(SourceActor, TargetActor, Params)
  if not SourceActor then
    return
  end
  local LocalPlayer = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not LocalPlayer or LocalPlayer ~= TargetActor then
    return
  end
  local CoreComp = LocalPlayer.CoreComponent
  if not CoreComp then
    return
  end
  local Item
  for index, SingleWidget in ipairs(LogicHitEffect.ListContainer:GetAllUseWidgetsList()) do
    if SingleWidget:IsSameSourceActor(SourceActor) then
      Item = SingleWidget
    end
  end
  local DamageValue = UE.URGDamageStatics.GetDamageValue(Params)
  local MaxHealth = CoreComp:GetMaxHealth()
  local MaxShield = CoreComp:GetMaxShield()
  local Ratio = DamageValue / (MaxHealth + MaxShield) * 3
  local IsHealthDamage = UE.URGDamageStatics.IsBloodDamage(Params)
  Item = Item or LogicHitEffect.ListContainer:GetOrCreateItem()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local HUD = UIManager:K2_GetUI(UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C"))
  if not HUD then
    return
  end
  if not UE.URGDamageStatics.IsInvincible(Params) then
    HUD:PlayDamageTakenAnim(IsHealthDamage)
  end
  if not HUD.HitEffectPanel:HasChild(Item) then
    local Slot = HUD.HitEffectPanel:AddChild(Item)
    Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
    Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
  end
  LogicHitEffect.ListContainer:ShowItem(Item, SourceActor, Ratio, IsHealthDamage)
end

function LogicHitEffect:Clear()
  print("Clear LogicHitEffect")
  if LogicHitEffect.ListContainer then
    LogicHitEffect.ListContainer:ClearAllWidgets()
    LogicHitEffect.ListContainer = nil
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if PC and PC.DamageComponent then
    PC.DamageComponent.OnMakeDamage:Remove(GameInstance, LogicHitEffect.BindOnMakeDamage)
  end
  LogicHitEffect.IsInit = false
end
