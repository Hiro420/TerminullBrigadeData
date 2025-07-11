local WBP_RouletteAreaItem_C = UnLua.Class()
local SlotDragAvailable = function(self, SlotItem, PointerEvent)
  if 0 == self.CommId then
    return false
  end
  EventSystem.Invoke(EventDef.Communication.OnRouletteStartDrag, self)
  return true
end
local EndDrag = function(self)
  EventSystem.Invoke(EventDef.Communication.OnRouletteEndDrag, self)
end
local SlotDropAvailable = function(self, DragDropItem, PickupItem, PointerEvent)
  local SlotId = self.SlotId
  local CommunicationViewModel = UIModelMgr:Get("CommunicationViewModel")
  CommunicationViewModel:EquipCommBySlotId(SlotId)
  print("SlotDropAvailable", SlotId)
end
function WBP_RouletteAreaItem_C:Construct()
  self.Overridden.Construct(self)
  self.SlotId = 0
  self.CommId = 0
  self.CurCoolDownTime = 0
  self.TotalCoolDownTime = 0
  self.bIsDraging = false
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteAreaSelectChanged, self, self.OnRouletteAreaSelectChanged)
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteAreaHoverChanged, self, self.OnRouletteAreaHoverChanged)
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteAreaUsed, self, self.OnRouletteAreaUsed)
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteStartDrag, self, self.OnRouletteStartDrag)
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteEndDrag, self, self.OnRouletteEndDrag)
end
function WBP_RouletteAreaItem_C:Destruct()
  self.Overridden.Destruct(self)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteAreaSelectChanged, self, self.OnRouletteAreaSelectChanged)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteAreaHoverChanged, self, self.OnRouletteAreaHoverChanged)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteAreaUsed, self, self.OnRouletteAreaUsed)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteStartDrag, self, self.OnRouletteStartDrag)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteEndDrag, self, self.OnRouletteEndDrag)
end
function WBP_RouletteAreaItem_C:InitByCommId(CommId, SlotId)
  local bChange = self.CommId ~= CommId
  self.SlotId = SlotId
  self.CommId = CommId
  self:SetRenderTransformAngle(45 * (SlotId - 1))
  self.Canvas_Bg:SetRenderTransformAngle(-45 * (SlotId - 1))
  self.Canvas_Spray:SetRenderTransformAngle(-45 * (SlotId - 1))
  self.Canvas_Voice:SetRenderTransformAngle(-45 * (SlotId - 1))
  self.Canvas_DragDrop:SetRenderTransformAngle(-45 * (SlotId - 1))
  self.Canvas_CoolDown:SetRenderTransformAngle(-45 * (SlotId - 1))
  self.Img_Bg_Hover_Dec:SetRenderTransformAngle(-45 * (SlotId - 1))
  self.CanvasPanel_putin:SetRenderTransformAngle(-45 * (SlotId - 1))
  UpdateVisibility(self.Canvas_Hover, false)
  UpdateVisibility(self.Canvas_Spray, false)
  UpdateVisibility(self.Canvas_Voice, false)
  UpdateVisibility(self.Canvas_Selected, false)
  self.WBP_DragDropItem:SetDragAvailableCallback(self, self, self.SizeBox_SprayIcon, SlotDragAvailable, EndDrag)
  self.WBP_DragDropItem:SetDropAvailableCallback(self, self, SlotDropAvailable, nil)
  self.RGStateController_Index:ChangeStatus(tostring(SlotId))
  if 0 == CommId then
    return
  end
  local tbCommunication = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  local CommData = tbCommunication[CommId]
  if not CommData then
    return
  end
  if 1 == CommData.Type then
    UpdateVisibility(self.Canvas_Spray, true)
    SetImageBrushByPath(self.Img_SprayIcon, CommData.Icon)
    if bChange then
      self:PlayAnimation(self.Ani_put)
    end
  elseif 3 == CommData.Type then
    UpdateVisibility(self.Canvas_Voice, true)
    self.Txt_VoiceName:SetText(CommData.Name)
    self.Txt_VoiceName_1:SetText(CommData.Name)
    self.WBP_DragDropItem:SetDragAvailableCallback(self, self, self.Img_Voice, SlotDragAvailable, EndDrag)
    if bChange then
      self:PlayAnimation(self.Ani_put)
    end
  end
  if not Logic_IllustratedGuide.IsLobbyRoom() then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    local WheelComp = Character:GetComponentByClass(UE.URGCommunicationWheelComponent:StaticClass())
    local TimeComp = Character:GetComponentByClass(UE.URGTimeSynchronizeComponent:StaticClass())
    if WheelComp and TimeComp then
      if 1 == CommData.Type then
        self.CurCoolDownTime = WheelComp:CanActivateWheel(UE.ERGCommunicationWheelType.Paint, TimeComp:GetServerTimeInSeconds())
        self.TotalCoolDownTime = WheelComp.PaintCoolDownTimeSeconds
      elseif 3 == CommData.Type then
        self.CurCoolDownTime = WheelComp:CanActivateWheel(UE.ERGCommunicationWheelType.Voice, TimeComp:GetServerTimeInSeconds())
        self.TotalCoolDownTime = WheelComp.VoiceCoolDownTimeSeconds
      end
    else
      self.CurCoolDownTime = 0
      self.TotalCoolDownTime = 0
    end
  end
end
function WBP_RouletteAreaItem_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    EventSystem.Invoke(EventDef.Communication.OnRouletteAreaSelectChanged, self.SlotId)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function WBP_RouletteAreaItem_C:OnRouletteAreaSelectChanged(SlotId)
  self.RGStateController_Selected:ChangeStatus(self.SlotId == SlotId and "Selected" or "UnSelected")
end
function WBP_RouletteAreaItem_C:OnRouletteAreaHoverChanged(SlotId)
  if self.SlotId == SlotId then
    local TxtMarkSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Canvas_TxtMark)
    local TxtNameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_VoiceName)
    self.LastFreshTextWidth = math.floor(TxtNameSlot:GetSize().X)
    self.LastTextDesiredWidth = math.floor(self.Txt_VoiceName:GetDesiredSize().X)
    if self.Txt_VoiceName_1:GetDesiredSize().X ~= self.Txt_VoiceName:GetDesiredSize().X then
      TxtNameSlot:SetSize(UE.FVector2D(TxtMarkSlot:GetSize().X + 12, TxtMarkSlot:GetSize().Y))
      self.RefreshTextTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        WBP_RouletteAreaItem_C.RefreshText
      }, self.TextMoveFrequency, true)
    end
    UpdateVisibility(self.WBP_DragDropItem, true, not self.bIsDraging)
    self.RGStateController_Hover:ChangeStatus("Hover")
  else
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RefreshTextTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RefreshTextTimer)
    end
    local TxtMarkSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Canvas_TxtMark)
    local TxtNameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_VoiceName)
    TxtNameSlot:SetSize(TxtMarkSlot:GetSize())
    TxtNameSlot:SetPosition(UE.FVector2D(0, 0))
    UpdateVisibility(self.WBP_DragDropItem, true, false)
    self.RGStateController_Hover:ChangeStatus("UnHover")
  end
end
function WBP_RouletteAreaItem_C:OnRouletteAreaUsed(SlotId)
  if self.CurCoolDownTime < 0 then
    return
  end
  if self.SlotId == SlotId then
    print("WBP_RouletteAreaItem_C:OnRouletteAreaUsed:" .. SlotId .. " " .. self.CommId)
    if 0 == self.CommId then
      return
    end
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    local WheelComp = Character:GetComponentByClass(UE.URGCommunicationWheelComponent:StaticClass())
    if WheelComp then
      local tbCommunication = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
      local CommData = tbCommunication[self.CommId]
      WheelComp:ActivateWheel(CommData.RouletteID)
    end
  end
end
function WBP_RouletteAreaItem_C:UpdateCoolDown(InDeltaTime)
  self.CurCoolDownTime = self.CurCoolDownTime + InDeltaTime
  if self.CurCoolDownTime < 0 and 0 ~= self.TotalCoolDownTime then
    self.Progress_CoolDown:SetPercent(1 + self.CurCoolDownTime / self.TotalCoolDownTime)
    self.RGStateController_Enable:ChangeStatus("Disable")
  else
    self.Progress_CoolDown:SetPercent(0)
    self.RGStateController_Enable:ChangeStatus("Enable")
  end
end
function WBP_RouletteAreaItem_C:RefreshText()
  local TxtMarkSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Canvas_TxtMark)
  local TxtNameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_VoiceName)
  TxtNameSlot:SetSize(UE.FVector2D(TxtNameSlot:GetSize().X + self.TextMoveDistance, TxtNameSlot:GetSize().Y))
  TxtNameSlot:SetPosition(UE.FVector2D(TxtNameSlot:GetPosition().X - self.TextMoveDistance, TxtNameSlot:GetPosition().Y))
  if self.Txt_VoiceName:GetDesiredSize().X >= self.Txt_VoiceName_1:GetDesiredSize().X and TxtNameSlot:GetSize().X - self.Txt_VoiceName:GetDesiredSize().X - 12 > TxtMarkSlot:GetSize().X then
    TxtNameSlot:SetSize(UE.FVector2D(TxtMarkSlot:GetSize().X + 12, TxtMarkSlot:GetSize().Y))
    TxtNameSlot:SetPosition(UE.FVector2D(-self.TextMoveDistance, 0))
  end
end
function WBP_RouletteAreaItem_C:OnRouletteStartDrag()
  self.bIsDraging = true
end
function WBP_RouletteAreaItem_C:OnRouletteEndDrag()
  self.bIsDraging = false
end
return WBP_RouletteAreaItem_C
