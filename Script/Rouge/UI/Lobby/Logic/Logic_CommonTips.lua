LogicCommonTips = LogicCommonTips or {
  IsInit = false,
  CommonTipsClassPath = "/Game/Rouge/UI/Common/WBP_CommonTips.WBP_CommonTips_C",
  RootCanvas = nil,
  CommonTipsPool = {},
  ENUMTipsPosType = {
    RIGHTDOWN = 1,
    RIGHTUP = 2,
    RIGHTMIDDLE = 3,
    LEFTDOWN = 4,
    LEFTUP = 5,
    LEFTMIDDLE = 6
  }
}
local ENUMTipsPosType = {
  RIGHTDOWN = 1,
  RIGHTUP = 2,
  RIGHTMIDDLE = 3,
  LEFTDOWN = 4,
  LEFTUP = 5,
  LEFTMIDDLE = 6
}

function LogicCommonTips.Init()
  if LogicCommonTips.IsInit then
    print("LogicDamageNumber \229\183\178\229\136\157\229\167\139\229\140\150")
    return
  end
  LogicCommonTips.IsInit = true
end

function LogicCommonTips.Clear()
end

function LogicCommonTips.GetSceneStatusIsLobby()
  local world = GameInstance:GetWorld()
  local PC = UE.UGameplayStatics.GetPlayerController(world, 0)
  if PC and PC.GetCurSceneStatus then
    return PC:GetCurSceneStatus()
  end
  return UE.ESceneStatus.None
end

function LogicCommonTips.CreateTipsWidget(TipsParent, TipsClassPath, TipsClass)
  local TipsWidget
  local WidgetClassPath = ""
  local WidgetClass = TipsClass
  if not WidgetClass then
    if not TipsClassPath then
      WidgetClassPath = LogicCommonTips.CommonTipsClassPath
    else
      WidgetClassPath = TipsClassPath
    end
    WidgetClass = UE.UClass.Load(WidgetClassPath)
  end
  if WidgetClass then
    if LogicCommonTips.CommonTipsPool[WidgetClassPath] and LogicCommonTips.CommonTipsPool[WidgetClassPath]:IsValid() then
      local TipWidget = LogicCommonTips.CommonTipsPool[WidgetClassPath]
      if not TipsParent:HasChild(TipWidget) then
        TipsParent:AddChild(TipWidget)
      end
      return TipWidget
    else
      TipsWidget = UE.UWidgetBlueprintLibrary.Create(TipsParent, WidgetClass)
      TipsParent:AddChild(TipsWidget)
      LogicCommonTips.CommonTipsPool[WidgetClassPath] = TipsWidget
    end
  end
  return TipsWidget
end

function LogicCommonTips.SetCommonTipsAbsolutePosition(HoverItemPos, HoverItemSize, HoverTips, PosType, TipsSize, Offset, bDontAutoSize)
  if HoverTips then
    local TipsPos = UE.FVector2D(0)
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(HoverTips)
    if PosType == ENUMTipsPosType.RIGHTDOWN then
      TipsPos.X = HoverItemPos.X + HoverItemSize.X
      TipsPos.Y = HoverItemPos.Y
    elseif PosType == ENUMTipsPosType.RIGHTUP then
      TipsPos.X = HoverItemPos.X + HoverItemSize.X
      TipsPos.Y = HoverItemPos.Y - (TipsSize.Y - HoverItemSize.Y)
    elseif PosType == ENUMTipsPosType.RIGHTMIDDLE then
      TipsPos.X = HoverItemPos.X + HoverItemSize.X
      TipsPos.Y = HoverItemPos.Y - (TipsSize.Y - HoverItemSize.Y) / 2
    elseif PosType == ENUMTipsPosType.LEFTDOWN then
      TipsPos.X = HoverItemPos.X - TipsSize.X - 50
      TipsPos.Y = HoverItemPos.Y
    elseif PosType == ENUMTipsPosType.LEFTUP then
      TipsPos.X = HoverItemPos.X - TipsSize.X
      TipsPos.Y = HoverItemPos.Y - (TipsSize.Y - HoverItemSize.Y)
    elseif PosType == ENUMTipsPosType.LEFTMIDDLE then
      TipsPos.X = HoverItemPos.X - TipsSize.X
      TipsPos.Y = HoverItemPos.Y - (TipsSize.Y - HoverItemSize.Y) / 2
    end
    if not bDontAutoSize then
      slotCanvas:SetAutoSize(true)
    end
    TipsPos = Offset and TipsPos + Offset or TipsPos
    slotCanvas:SetPosition(TipsPos)
  end
end

function LogicCommonTips.SetCommonTipsRelativePosition(HoverItem, HoverTips, PosType, TipsSize, Offset)
  local TipsWidget = HoverTips
  if TipsWidget then
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(TipsWidget)
    local GeometryItem = HoverItem:GetCachedGeometry()
    local HoverItemPosition = HoverItem.Slot:GetPosition()
    local HoverItemSize = UE.USlateBlueprintLibrary.GetLocalSize(GeometryItem)
    local TipsPos = UE.FVector2D(0)
    if PosType == ENUMTipsPosType.RIGHTDOWN then
      TipsPos.X = HoverItemPosition.X + HoverItemSize.X
      TipsPos.Y = HoverItemPosition.Y
    elseif PosType == ENUMTipsPosType.RIGHTUP then
      TipsPos.X = HoverItemPosition.X + HoverItemSize.X
      TipsPos.Y = HoverItemPosition.Y - TipsSize.Y
    elseif PosType == ENUMTipsPosType.RIGHTMIDDLE then
      TipsPos.X = HoverItemPosition.X + HoverItemSize.X
      TipsPos.Y = HoverItemPosition.Y - (TipsSize.Y - HoverItemSize.Y) / 2
    elseif PosType == ENUMTipsPosType.LEFTDOWN then
      TipsPos.X = HoverItemPosition.X - TipsSize.X
      TipsPos.Y = HoverItemPosition.Y
    elseif PosType == ENUMTipsPosType.LEFTUP then
      TipsPos.X = HoverItemPosition.X - TipsSize.X
      TipsPos.Y = HoverItemPosition.Y - TipsSize.Y
    elseif PosType == ENUMTipsPosType.LEFTMIDDLE then
      TipsPos.X = HoverItemPosition.X - TipsSize.X
      TipsPos.Y = HoverItemPosition.Y - (TipsSize.Y - HoverItemSize.Y) / 2
    end
    TipsPos = Offset and TipsPos + Offset or TipsPos
    slotCanvas:SetPosition(TipsPos)
    return TipsWidget
  end
end

function LogicCommonTips.GetCommonTipsType(TipsParent, GeometryItem, TipsWidget, TipsSize)
  if TipsWidget then
    local GeometryTipsParent = TipsParent:GetCachedGeometry()
    local scale = UE.UWidgetLayoutLibrary.GetViewportScale(TipsParent)
    local ScreenSize = UE.UWidgetLayoutLibrary.GetViewportSize(TipsParent) / scale
    local HoverItemPos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryTipsParent, GeometryItem)
    local HoverItemSize = UE.USlateBlueprintLibrary.GetLocalSize(GeometryItem)
    local IsRight = false
    local IsUp = false
    local IsDown = false
    if HoverItemPos.X + HoverItemSize.X + TipsSize.X <= ScreenSize.X then
      IsRight = true
    end
    if HoverItemPos.Y + TipsSize.Y < ScreenSize.Y then
      IsDown = true
    elseif HoverItemPos.Y > TipsSize.Y then
      IsUp = true
    end
    if IsRight then
      if IsUp then
        return ENUMTipsPosType.RIGHTUP
      elseif IsDown then
        return ENUMTipsPosType.RIGHTDOWN
      else
        return ENUMTipsPosType.RIGHTMIDDLE
      end
    elseif IsUp then
      return ENUMTipsPosType.LEFTUP
    elseif IsDown then
      return ENUMTipsPosType.LEFTDOWN
    else
      return ENUMTipsPosType.LEFTMIDDLE
    end
    return nil
  end
end

function LogicCommonTips.GetCommonTipsTypeForPos(TipsParent, HoverItemPos, TipsWidget, TipsSize)
  if TipsWidget then
    local scale = UE.UWidgetLayoutLibrary.GetViewportScale(TipsParent)
    local ScreenSize = UE.UWidgetLayoutLibrary.GetViewportSize(TipsParent) / scale
    local IsRight = false
    local IsUp = false
    local IsDown = false
    if HoverItemPos.X + TipsSize.X <= ScreenSize.X then
      IsRight = true
    end
    if HoverItemPos.Y + TipsSize.Y > ScreenSize.Y then
      IsUp = true
    else
      IsDown = true
    end
    if IsRight then
      if IsUp then
        return ENUMTipsPosType.RIGHTUP
      elseif IsDown then
        return ENUMTipsPosType.RIGHTDOWN
      else
        return ENUMTipsPosType.RIGHTMIDDLE
      end
    elseif IsUp then
      return ENUMTipsPosType.LEFTUP
    elseif IsDown then
      return ENUMTipsPosType.LEFTDOWN
    else
      return ENUMTipsPosType.LEFTMIDDLE
    end
    return nil
  end
end
