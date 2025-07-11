LogicElement = LogicElement or {IsInit = false}
function LogicElement.Init()
  if LogicElement.IsInit then
    print("LogicElement \229\183\178\229\136\157\229\167\139\229\140\150")
    LogicElement:BindDelegate()
    return
  end
  LogicElement.IsInit = true
  LogicElement.AllActorElementList = {}
  LogicElement:BindDelegate()
end
function LogicElement:BindDelegate()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PS = PC.PlayerState
  if not PS then
    return
  end
  local ElementComp = PS:GetComponentByClass(UE.URGPlayerElementComponent:StaticClass())
  if not ElementComp then
    return
  end
  ElementComp.OnTriggerElement:Add(GameInstance, LogicElement.BindOnTriggerElement)
  ElementComp.OnStopElement:Add(GameInstance, LogicElement.BindOnStopElement)
end
function LogicElement:BindOnTriggerElement(BuffId, Params)
  print("BindOnTriggerElement", BuffId, Params.Target, BuffId.TypeA, BuffId.TypeB, Params.RemainTime)
  if LogicElement.AllActorElementList[Params.Target] then
    local ElementList = LogicElement.AllActorElementList[Params.Target]
    local TempElementId = UE.FRGElementId()
    TempElementId.TypeA = BuffId.TypeA
    TempElementId.TypeB = BuffId.TypeB
    local IsAdd = false
    for i, SingleElementInfo in ipairs(ElementList) do
      if SingleElementInfo.ElementId == TempElementId then
        SingleElementInfo.Duration = Params.RemainTime
        IsAdd = true
        break
      end
    end
    if not IsAdd then
      local TempList = {}
      TempList.ElementId = TempElementId
      TempList.Duration = Params.RemainTime
      table.insert(ElementList, TempList)
    end
  else
    local ElementList = {}
    local TempList = {}
    local TempElementId = UE.FRGElementId()
    TempElementId.TypeA = BuffId.TypeA
    TempElementId.TypeB = BuffId.TypeB
    TempList.ElementId = TempElementId
    TempList.Duration = Params.RemainTime
    table.insert(ElementList, TempList)
    LogicElement.AllActorElementList[Params.Target] = ElementList
  end
  EventSystem.Invoke(EventDef.Battle.ElementChanged, BuffId, Params, true)
end
function LogicElement:BindOnStopElement(BuffId, Params)
  print("BindOnStopElement", BuffId.TypeA, BuffId.TypeB, Params.Target)
  if not Params.Target then
    return
  end
  if Params.Target:Cast(UE.ARGBodyPartActor) then
    print("PartOwner", Params.Target:GetOwner())
  end
  local TargetElementList = LogicElement.AllActorElementList[Params.Target]
  if TargetElementList then
    local RemoveIndex = 0
    for Index, SingleElementInfo in ipairs(TargetElementList) do
      if SingleElementInfo.ElementId == BuffId then
        RemoveIndex = Index
        break
      end
    end
    if TargetElementList[RemoveIndex] then
      table.remove(TargetElementList, RemoveIndex)
    end
    if 0 == table.count(LogicElement.AllActorElementList[Params.Target]) then
      LogicElement.AllActorElementList[Params.Target] = nil
    end
  end
  EventSystem.Invoke(EventDef.Battle.ElementChanged, BuffId, Params, false)
end
function LogicElement.Clear()
  LogicElement.AllActorElementList = {}
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PS = PC.PlayerState
  if not PS then
    return
  end
  local ElementComp = PS:GetComponentByClass(UE.URGPlayerElementComponent:StaticClass())
  if not ElementComp then
    return
  end
  ElementComp.OnTriggerElement:Remove(GameInstance, LogicElement.BindOnTriggerElement)
  ElementComp.OnStopElement:Remove(GameInstance, LogicElement.BindOnStopElement)
  LogicElement.IsInit = false
end
