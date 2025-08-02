local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local WBP_Roulette_C = UnLua.Class()
local SlotDropAvailable = function(self, DragDropItem, PickupItem, PointerEvent)
  print(self, DragDropItem, PickupItem, PointerEvent)
  local SlotId = self:GetHoverAreaByMouseEvent(PointerEvent)
  local CommunicationViewModel = UIModelMgr:Get("CommunicationViewModel")
  CommunicationViewModel:EquipCommBySlotId(SlotId)
end
local SlotDropOverAvailable = function(self, DragDropItem, PickupItem, PointerEvent)
  self:OnMouseMove(PointerEvent, PickupItem)
end
local SlotDropLeaveAvailable = function(self, DragDropItem, PickupItem, PointerEvent)
  self:ChangeHoveredArea(0)
end

function WBP_Roulette_C:Construct()
  self.Overridden.Construct(self)
  self.CurHoveredArea = 0
  self.HeroId = 0
  self.CurCoolDownTime = 0
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteStartDrag, self, self.OnRouletteStartDrag)
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteEndDrag, self, self.OnRouletteEndDrag)
end

function WBP_Roulette_C:Destruct()
  self.Overridden.Destruct(self)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteStartDrag, self, self.OnRouletteStartDrag)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteEndDrag, self, self.OnRouletteEndDrag)
end

function WBP_Roulette_C:InitByHeroId(HeroId)
  self.HeroId = HeroId
  local rouletteSlots = DataMgr.GetRouletteSlotsByHeroId(HeroId)
  self:InitBySlots(rouletteSlots)
end

function WBP_Roulette_C:InitBySlots(RouletteSlots, bIsInitSelect)
  if bIsInitSelect then
    self.LastMousePosition = nil
  end
  for i, v in ipairs(RouletteSlots) do
    local rouletteAreaItem = GetOrCreateItem(self.Canvas_Root, i, self.WBP_RouletteAreaItem:GetClass())
    if 0 ~= v then
      rouletteAreaItem:InitByCommId(CommunicationData.GetCommIdByRoulleteId(v), i)
    else
      rouletteAreaItem:InitByCommId(0, i)
    end
  end
  UpdateVisibility(self.Canvas_CenterLobby, Logic_IllustratedGuide.IsLobbyRoom())
  UpdateVisibility(self.Canvas_CenterBattle, not Logic_IllustratedGuide.IsLobbyRoom())
  self.WBP_DragDropItem:SetDropAvailableCallback(self, self.WBP_DragDropBase, SlotDropAvailable, SlotDropOverAvailable, SlotDropLeaveAvailable)
end

function WBP_Roulette_C:OnMouseLeave()
  self:ChangeHoveredArea(0)
end

function WBP_Roulette_C:GetHoverAreaByMouseEvent(MouseEvent)
  local RouletteCenterX, RouletteCenterY = self:GetRouletteCenter()
  local ScreenPos = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local PixelPos, ViewportPos = UE.USlateBlueprintLibrary.AbsoluteToViewport(self, ScreenPos, nil, nil)
  local DeltaX = ViewportPos.X - RouletteCenterX
  local DeltaY = ViewportPos.Y - RouletteCenterY
  local Angle = math.atan(DeltaY, DeltaX) * (180 / math.pi)
  if Angle < 0 then
    Angle = 360 + Angle
  end
  local HoveredArea = math.floor((Angle + 22.5) % 360 / 45)
  HoveredArea = (HoveredArea + 2) % 8 + 1
  return HoveredArea
end

function WBP_Roulette_C:OnMouseMove(MyGeometry, MouseEvent)
  local CurrentMousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  if self.LastMousePosition then
    local DeltaX = CurrentMousePosition.X - self.LastMousePosition.X
    local DeltaY = CurrentMousePosition.Y - self.LastMousePosition.Y
    local DistanceSquared = DeltaX * DeltaX + DeltaY * DeltaY
    if DistanceSquared < 25 then
      return
    end
  else
    self.LastMousePosition = CurrentMousePosition
    self:ChangeHoveredArea(1)
    return
  end
  self.LastMousePosition = CurrentMousePosition
  local HoveredArea = self:GetHoverAreaByMouseEvent(MouseEvent)
  self:ChangeHoveredArea(HoveredArea)
end

function WBP_Roulette_C:GetRouletteCenter()
  local CachedGeometry = self.Img_CenterFlag:GetCachedGeometry()
  local AbsolutePos = UE.URGBlueprintLibrary.GetAbsolutePosition(CachedGeometry)
  local PixelPosition, ViewportPosition = UE.USlateBlueprintLibrary.LocalToViewport(self, CachedGeometry, UE.FVector2D(), nil, nil)
  return ViewportPosition.X, ViewportPosition.Y
end

function WBP_Roulette_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    EventSystem.Invoke(EventDef.Communication.OnRouletteAreaSelectChanged, self.CurHoveredArea)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_Roulette_C:UseSelectedAreaComm()
  EventSystem.Invoke(EventDef.Communication.OnRouletteAreaUsed, self.CurHoveredArea)
end

function WBP_Roulette_C:ChangeHoveredArea(HoveredArea)
  if self.CurHoveredArea == HoveredArea then
    return
  end
  self.CurHoveredArea = HoveredArea
  EventSystem.Invoke(EventDef.Communication.OnRouletteAreaHoverChanged, self.CurHoveredArea)
  UpdateVisibility(self.CanvasPanel_BG_loop, 0 ~= HoveredArea)
  self.Txt_CommName:SetText("")
  self.CurCoolDownTime = 0
  if 0 == HoveredArea then
    return
  end
  local rouletteAreaItem = GetOrCreateItem(self.Canvas_Root, HoveredArea, self.WBP_RouletteAreaItem:GetClass())
  local CommId = rouletteAreaItem.CommId
  if 0 == CommId then
    return
  end
  local tbCommunication = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  local CommData = tbCommunication[CommId]
  if not CommData then
    return
  end
  self.Txt_CommName:SetText(CommData.Name)
  self.CurCoolDownTime = rouletteAreaItem.CurCoolDownTime
end

function WBP_Roulette_C:UpdateAreaCoolDown(InDeltaTime)
  local RouletteAreaItemList = self.Canvas_Root:GetAllChildren()
  for i, RouletteAreaItem in pairs(RouletteAreaItemList) do
    RouletteAreaItem:UpdateCoolDown(InDeltaTime)
  end
  self.CurCoolDownTime = self.CurCoolDownTime + InDeltaTime
  if self.CurCoolDownTime < 0 then
    self.Txt_CommCD:SetText(math.ceil(math.abs(self.CurCoolDownTime)))
  else
    self.Txt_CommCD:SetText("")
  end
end

function WBP_Roulette_C:OnRouletteStartDrag()
  self.RGStateController_BG:ChangeStatus("Highlight")
end

function WBP_Roulette_C:OnRouletteEndDrag()
  self.RGStateController_BG:ChangeStatus("Normal")
end

function WBP_Roulette_C:PlayAnimationIn()
  self:PlayAnimation(self.Ani_in)
end

function WBP_Roulette_C:PlayAnimationOut()
  self:PlayAnimation(self.An_out)
end

return WBP_Roulette_C
