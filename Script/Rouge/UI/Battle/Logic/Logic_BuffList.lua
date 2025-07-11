LogicBuffList = LogicBuffList or {IsInit = false}
local ListContainer = require("Rouge.UI.Common.ListContainer")
function LogicBuffList.Init()
  if LogicBuffList.IsInit then
    print("LogicBuffList \229\183\178\229\136\157\229\167\139\229\140\150")
    LogicBuffList.BindCharacterDelegate()
    return
  end
  LogicBuffList.IsInit = true
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/Buff/WBP_BuffIcon.WBP_BuffIcon_C")
  LogicBuffList.ListContainer = ListContainer.New(WidgetClass)
  for i = 1, 20 do
    LogicBuffList.ListContainer:CreateItem()
  end
  LogicBuffList.BindCharacterDelegate()
  LogicBuffList.BuffIdList = {}
end
function LogicBuffList.BindCharacterDelegate(...)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local BuffComp = Character.BuffComponent
  if BuffComp then
    BuffComp.OnBuffAdded:Add(GameInstance, LogicBuffList.BindOnBuffAdded)
    BuffComp.OnBuffChanged:Add(GameInstance, LogicBuffList.BindOnBuffChanged)
    BuffComp.OnBuffRemove:Add(GameInstance, LogicBuffList.BindOnBuffRemove)
  end
end
function LogicBuffList.BindOnBuffAdded(Target, AddedBuff)
  EventSystem.Invoke(EventDef.Battle.OnBuffAdded, AddedBuff)
  LogicBuffList.BuffIdList[AddedBuff.ID] = AddedBuff.CurrentCount
end
function LogicBuffList.BindOnBuffChanged(Target, ChangedBuff)
  EventSystem.Invoke(EventDef.Battle.OnBuffChanged, ChangedBuff)
  LogicBuffList.BuffIdList[ChangedBuff.ID] = ChangedBuff.CurrentCount
end
function LogicBuffList.BindOnBuffRemove(Target, RemoveBuff)
  LogicBuffList.BuffIdList[RemoveBuff.ID] = nil
end
function LogicBuffList.Clear()
  print("Clear LogicBuffList")
  if LogicBuffList.ListContainer then
    LogicBuffList.ListContainer:ClearAllWidgets()
    LogicBuffList.ListContainer = nil
  end
  LogicBuffList.BuffIdList = {}
  LogicBuffList.IsInit = false
end
