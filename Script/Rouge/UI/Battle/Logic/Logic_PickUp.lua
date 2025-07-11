LogicPickup = LogicPickup or {IsInit = false}
local ListContainer = require("Rouge.UI.Common.ListContainer")
function LogicPickup.Init()
  if LogicPickup.IsInit then
    print("LogicPickup \229\183\178\229\136\157\229\167\139\229\140\150")
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    LogicPickup:BindDelegate(Character)
    return
  end
  LogicPickup.IsInit = true
  LogicPickup.CurSelectPickupActor = nil
  LogicPickup.IsShowOptimalDetailPanel = false
  LogicPickup.IsShowComparePanel = true
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  LogicPickup:BindDelegate(Character)
  EventSystem.AddListener(nil, EventDef.Battle.OnControlledPawnChanged, LogicPickup.BindOnControlledPawnChanged)
end
function LogicPickup.BindOnControlledPawnChanged(Character)
  LogicPickup:BindDelegate(Character)
end
function LogicPickup:BindDelegate(Character)
end
function LogicPickup.SetIsIgnoreInput(IsIngore)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InputComp = Character:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
  if not InputComp then
    return
  end
  InputComp:SetAllInputIgnored(IsIngore)
  if IsIngore then
    InputComp:SetMoveInputIgnored(false)
  end
end
function LogicPickup.Clear()
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, LogicPickup.BindOnControlledPawnChanged, nil)
  LogicPickup.IsInit = false
end
