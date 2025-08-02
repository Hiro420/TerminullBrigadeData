local VoiceItem = UnLua.Class()
local RedDotData = require("Modules.RedDot.RedDotData")
local SlotDragAvailable = function(self, SlotItem, PointerEvent)
  if not self.DataObj.bIsUnlocked then
    return false
  end
  if self.Interactive == false then
    return false
  end
  EventSystem.Invoke(EventDef.Communication.OnRouletteStartDrag, self)
  return true
end
local EndDrag = function(self)
  EventSystem.Invoke(EventDef.Communication.OnRouletteEndDrag, self)
end

function VoiceItem:Construct()
  self.LastFreshTextWidth = 0
  self.LastTextDesiredWidth = 0
  EventSystem.AddListenerNew(EventDef.Communication.OnCommSelectChanged, self, self.BindOnCommSelectChanged)
end

function VoiceItem:Destruct()
  EventSystem.RemoveListenerNew(EventDef.Communication.OnCommSelectChanged, self, self.BindOnCommSelectChanged)
end

function VoiceItem:InitVoiceItem(DataObj)
  UpdateVisibility(self, true)
  UpdateVisibility(self.Canvas_Hover, false)
  self.DataObj = DataObj
  local DataObjTemp = DataObj
  if not DataObjTemp then
    return
  end
  local voiceInfo = DataObj.ParentView.viewModel:GetVoiceDataByCommId(DataObjTemp.CommId)
  if not voiceInfo then
    return
  end
  self.Txt_VoiceName:SetText(voiceInfo.RowInfo.Name)
  self.Txt_VoiceName_1:SetText(voiceInfo.RowInfo.Name)
  UpdateVisibility(self.Canvas_Equip, DataObjTemp.bIsEquiped)
  self.RGStateController_Select:ChangeStatus(self.DataObj.bIsSelected and "Selected" or "Normal")
  self.WBP_DragDropItem:SetDragAvailableCallback(self, self, self.Img_Voice, SlotDragAvailable, EndDrag)
  if self.Interactive == false then
    self.WBP_RedDotView:ChangeRedDotId("")
    self.RGStateController_Lock:ChangeStatus("Unlock")
  else
    self.WBP_RedDotView:ChangeRedDotIdByTag(DataObjTemp.CommId)
    self.RGStateController_Lock:ChangeStatus(DataObjTemp.bIsUnlocked and "Unlock" or "Lock")
  end
  if DataObj.expireAt == nil or "" == DataObj.expireAt or DataObj.expireAt == "0" then
    UpdateVisibility(self.Canvas_expireAt, false)
  else
    UpdateVisibility(self.Canvas_expireAt, true)
    SetExpireAtColor(self.URGImage_1, DataObj.expireAt)
  end
end

function VoiceItem:Hide()
  self.WBP_RedDotView:ChangeRedDotId("")
  self.DataObj = nil
  UpdateVisibility(self.Canvas_Hover, false)
  UpdateVisibility(self, false)
end

function VoiceItem:BP_OnEntryReleased()
  self.WBP_RedDotView:ChangeRedDotId("")
  self.DataObj = nil
end

function VoiceItem:RefreshText()
  local TxtMarkSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Canvas_TxtMark)
  local TxtNameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_VoiceName)
  TxtNameSlot:SetSize(UE.FVector2D(TxtNameSlot:GetSize().X + self.TextMoveDistance, TxtNameSlot:GetSize().Y))
  TxtNameSlot:SetPosition(UE.FVector2D(TxtNameSlot:GetPosition().X - self.TextMoveDistance, TxtNameSlot:GetPosition().Y))
  if self.Txt_VoiceName:GetDesiredSize().X >= self.Txt_VoiceName_1:GetDesiredSize().X then
    if TxtNameSlot:GetSize().X - self.Txt_VoiceName:GetDesiredSize().X - 60 > TxtMarkSlot:GetSize().X then
      TxtNameSlot:SetSize(UE.FVector2D(TxtMarkSlot:GetSize().X + 60, TxtMarkSlot:GetSize().Y))
      TxtNameSlot:SetPosition(UE.FVector2D(-self.TextMoveDistance, 0))
    end
  else
    print("Txt_VoiceName:GetDesiredSize().X:" .. self.Txt_VoiceName:GetDesiredSize().X)
    print("Txt_VoiceName_1:GetDesiredSize().X:" .. self.Txt_VoiceName_1:GetDesiredSize().X)
  end
end

function VoiceItem:OnMouseEnter()
  UpdateVisibility(self.Canvas_Hover, true)
  local TxtMarkSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Canvas_TxtMark)
  local TxtNameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_VoiceName)
  self.LastFreshTextWidth = math.floor(TxtNameSlot:GetSize().X)
  self.LastTextDesiredWidth = math.floor(self.Txt_VoiceName:GetDesiredSize().X)
  if self.Txt_VoiceName_1:GetDesiredSize().X ~= self.Txt_VoiceName:GetDesiredSize().X then
    TxtNameSlot:SetSize(UE.FVector2D(TxtMarkSlot:GetSize().X + 60, TxtMarkSlot:GetSize().Y))
    self.RefreshTextTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      VoiceItem.RefreshText
    }, self.TextMoveFrequency, true)
  end
end

function VoiceItem:OnMouseLeave()
  UpdateVisibility(self.Canvas_Hover, false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RefreshTextTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RefreshTextTimer)
  end
  local TxtMarkSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Canvas_TxtMark)
  local TxtNameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_VoiceName)
  TxtNameSlot:SetSize(TxtMarkSlot:GetSize())
  TxtNameSlot:SetPosition(UE.FVector2D(0, 0))
end

function VoiceItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  if not self.DataObj then
    return
  end
  self.DataObj.ParentView:SelectVoice(self.DataObj.CommId)
  self.WBP_RedDotView:SetNum(0)
  return UE.UWidgetBlueprintLibrary.Handled()
end

function VoiceItem:BindOnCommSelectChanged(CommId)
  if not self.DataObj then
    return
  end
  self.DataObj.bIsSelected = self.DataObj.CommId == CommId
  self.RGStateController_Select:ChangeStatus(self.DataObj.bIsSelected and "Selected" or "Normal")
end

function VoiceItem:SetInteractive(IsCanInteractive)
  self.Interactive = IsCanInteractive
end

return VoiceItem
