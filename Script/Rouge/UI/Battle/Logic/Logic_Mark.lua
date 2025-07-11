local ListContainer = require("Rouge.UI.Common.ListContainer")
LogicMark = LogicMark or {IsInit = false}
function LogicMark.Init()
  if LogicMark.IsInit then
    print("LogicMark\229\183\178\229\136\157\229\167\139\229\140\150")
    LogicMark.CurMarkList = {}
    LogicMark.BindDelegate()
    return
  end
  LogicMark.IsInit = true
  LogicMark.CurMarkList = {}
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Mark/WBP_MarkItem.WBP_MarkItem_C")
  LogicMark.ListContainer = ListContainer.New(WidgetClass)
  LogicMark.BindDelegate()
  LogicMark.BindOnMarkListChanged()
end
function LogicMark.BindDelegate()
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if GS then
    local MarkComp = GS:GetComponentByClass(UE.URGMarkManager:StaticClass())
    if MarkComp then
      MarkComp.OnMarkListChanged:Add(GameInstance, LogicMark.BindOnMarkListChanged)
    else
      print("LogicMark BindDelegate Fail! not found MarkComponent")
    end
  end
end
function LogicMark.BindOnMarkListChanged()
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if not GS then
    return
  end
  local MarkComp = GS:GetComponentByClass(UE.URGMarkManager:StaticClass())
  if not MarkComp then
    return
  end
  local AllUseWidgets = LogicMark.ListContainer:GetAllUseWidgetsList()
  local TargetRemoveList = {}
  for i, SingleWidget in ipairs(AllUseWidgets) do
    if not SingleWidget:IsValidMarkItem() then
      table.insert(TargetRemoveList, SingleWidget)
      table.RemoveItem(LogicMark.CurMarkList, SingleWidget.MarkInfo)
    end
  end
  for i, SingleWidget in ipairs(TargetRemoveList) do
    SingleWidget:HidePanel()
  end
  local AllMarkInfo = MarkComp.MarkList:ToTable()
  for i, SingleMarkInfo in pairs(AllMarkInfo) do
    if not table.Contain(LogicMark.CurMarkList, SingleMarkInfo) then
      local Item = LogicMark.ListContainer:GetOrCreateItem()
      LogicMark.ListContainer:ShowItem(Item, SingleMarkInfo)
      table.insert(LogicMark.CurMarkList, SingleMarkInfo)
    end
  end
end
function LogicMark.Clear()
  LogicMark.IsInit = false
  LogicMark.CurMarkList = {}
  if LogicMark.ListContainer then
    LogicMark.ListContainer:ClearAllWidgets()
    LogicMark.ListContainer = nil
  end
end
