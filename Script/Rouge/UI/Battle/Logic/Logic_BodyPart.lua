local M = {
  MaxShowNum = 3,
  CurShowWidgetList = {},
  CanShowBodyPartWidget = true
}
_G.LogicBodyPart = _G.LogicBodyPart or M

function LogicBodyPart.Init()
  LogicBodyPart.CurShowWidgetList = {}
end

function LogicBodyPart.ShowOrHidePartInfo(OwnerActor, PartIndex)
  if not LogicBodyPart.CanShowBodyPartWidget then
    return
  end
  if not OwnerActor then
    return
  end
  local BodyPartComponent = OwnerActor:GetComponentByClass(UE.URGAIBodyPartComponent:StaticClass())
  if not BodyPartComponent then
    return
  end
  if not BodyPartComponent:IsValidPartIndex(PartIndex) then
    return
  end
  local TargetPartInfoWidgetComponent = BodyPartComponent.PartInfoWidgets:Find(PartIndex)
  if not TargetPartInfoWidgetComponent then
    return
  end
  local TargetUserWidget = TargetPartInfoWidgetComponent:GetUserWidgetObject()
  if TargetUserWidget and TargetUserWidget.CanShowPanel and TargetUserWidget:CanShowPanel() then
    TargetUserWidget:ShowPanel()
    if not table.Contain(LogicBodyPart.CurShowWidgetList, TargetUserWidget) then
      table.insert(LogicBodyPart.CurShowWidgetList, TargetUserWidget)
    end
    if table.count(LogicBodyPart.CurShowWidgetList) > LogicBodyPart.MaxShowNum then
      local NeedHideWidget = LogicBodyPart.CurShowWidgetList[1]
      if NeedHideWidget and NeedHideWidget:IsValid() then
        LogicBodyPart.HideWidget(NeedHideWidget)
      end
    end
  else
    LogicBodyPart.HideWidget(TargetUserWidget)
  end
end

function LogicBodyPart.HideWidget(UserWidget)
  UserWidget:HidePanel()
  if table.Contain(LogicBodyPart.CurShowWidgetList, UserWidget) then
    table.RemoveItem(LogicBodyPart.CurShowWidgetList, UserWidget)
  end
end

function LogicBodyPart.SetCanShowBodyPartWidget(IsHide)
  LogicBodyPart.CanShowBodyPartWidget = not IsHide
end

function LogicBodyPart.GetCanShowBodyPartWidget()
  return LogicBodyPart.CanShowBodyPartWidget
end

function LogicBodyPart.Clear()
  LogicBodyPart.CurShowWidgetList = {}
end
