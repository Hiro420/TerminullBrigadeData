local WBP_IllustratedGuide_Item_C = UnLua.Class()

function WBP_IllustratedGuide_Item_C:Construct()
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnFocusModify, WBP_IllustratedGuide_Item_C.SetMark)
end

function WBP_IllustratedGuide_Item_C:OnListItemObjectSet(ListItemObj)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnGenericModifyItemSelectionChanged, WBP_IllustratedGuide_Item_C.OnSelectionChanged)
  self.Data = ListItemObj.Data
  self:OnSelectionChanged(Logic_IllustratedGuide.CurGenericModifyInfo.RowName)
  if self.Data.ModifieConfig then
    local size = {X = 130, Y = 141}
    SetImageBrushBySoftObject(self.Img_Icon, self.Data.ModifieConfig.Icon)
    SetImageBrushBySoftObject(self.Img_Icon_Notobtained, self.Data.ModifieConfig.Icon)
    SetImageBrushBySoftObject(self.Img_Icon_Lock, self.Data.ModifieConfig.Icon)
    local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if logicCommandDataSubsystem then
      local OutSaveData = GetLuaInscription(self.Data.ModifieConfig.Inscription)
      if OutSaveData then
        local name = GetInscriptionName(self.Data.ModifieConfig.Inscription)
        self.Txt_Name:SetText(name)
      else
        print("ERROE : \231\165\157\231\166\143\232\161\168 ", self.Data.ModifieConfig.Id, "\232\175\141\230\157\161\231\154\132\233\133\141\231\189\174\228\184\141\229\175\185")
      end
    end
    self:IsLock()
    self:SetMark()
    self:HaveYouObtained()
    self:SetQuality()
    if self.Data.ModifieConfig.GenericModifyType == UE.ERGGenericModifyType.ShareWin then
      self.RGStateController_Tag:ChangeStatus("ShareWin")
    elseif self.Data.ModifieConfig.GenericModifyType == UE.ERGGenericModifyType.Legend then
      self.RGStateController_Tag:ChangeStatus("Legend")
    else
      self.RGStateController_Tag:ChangeStatus("None")
    end
    if self.Data.ModifieConfig.Slot == UE.ERGGenericModifySlot.None then
      UpdateVisibility(self.Overlay_SkillName, false)
    else
      UpdateVisibility(self.Overlay_SkillName, true)
      self.Text_SkillName:SetText(GenericModifySlotDesc[self.Data.ModifieConfig.Slot]())
    end
  end
end

function WBP_IllustratedGuide_Item_C:IsLock()
  if Logic_IllustratedGuide.IsLobbyRoom() then
    UpdateVisibility(self.Lock, false)
    UpdateVisibility(self.Img_Icon_Lock, false)
    return
  end
  if self.Data.ModifieConfig.GenericModifyType == UE.ERGGenericModifyType.ShareWin then
    UpdateVisibility(self.Lock, false)
    UpdateVisibility(self.Img_Icon_Lock, true)
    return
  end
  local Num = self.Data.ModifieConfig.FrontConditions:Num()
  local UnLockNum = Logic_IllustratedGuide.UnLockGenericModify(self.Data.ModifieConfig.FrontConditions)
  UpdateVisibility(self.Lock, Num > UnLockNum)
  UpdateVisibility(self.Img_Icon_Lock, Num > UnLockNum)
  Num = self.Data.ModifieConfig.FrontConditions:Num()
  self.LockNum:SetText(string.format(self.LockText, UnLockNum, Num))
end

function WBP_IllustratedGuide_Item_C:HaveYouObtained()
  if Logic_IllustratedGuide.IsLobbyRoom() then
    return
  end
  local GenericModifyTable = Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
  UpdateVisibility(self.Img_Icon_Notobtained, true)
  UpdateVisibility(self.Img_Icon, false)
  UpdateVisibility(self.Hover, false)
  if nil == GenericModifyTable then
    return
  end
  for index, GenericModifyId in ipairs(GenericModifyTable) do
    if Logic_IllustratedGuide.GenericModify_SubGroupIdEqual(GenericModifyId, self.Data.ModifieConfig.ModifyId) then
      UpdateVisibility(self.Img_Icon_Notobtained, false)
      UpdateVisibility(self.Img_Icon, true)
      return
    end
  end
end

function WBP_IllustratedGuide_Item_C:SetQuality()
  if not self.Data then
    return
  end
  UpdateVisibility(self.Img_Quality_Normal, false)
  UpdateVisibility(self.Img_Quality_Hero, false)
  UpdateVisibility(self.Img_Quality_Dual, false)
  if self.Data.ModifieConfig.GenericModifyType == UE.ERGGenericModifyType.Normal then
    UpdateVisibility(self.Img_Quality_Normal, true)
  elseif self.Data.ModifieConfig.GenericModifyType == UE.ERGGenericModifyType.Hero then
    UpdateVisibility(self.Img_Quality_Hero, true)
  elseif self.Data.ModifieConfig.GenericModifyType == UE.ERGGenericModifyType.Dual then
    UpdateVisibility(self.Img_Quality_Dual, true)
  end
end

function WBP_IllustratedGuide_Item_C:SetMark()
  local Result = false
  local RowInfo = UE.FRGGenericModifyTableRow
  Result, RowInfo = GetRowData(DT.DT_GenericModify, self.Data.RowName)
  if Result then
    UpdateVisibility(self.Mark, 1 == Logic_IllustratedGuide.FocusStatus(RowInfo))
  end
end

function WBP_IllustratedGuide_Item_C:OnSelectionChanged(Id)
  UpdateVisibility(self.Img_Select, Id == self.Data.RowName)
end

function WBP_IllustratedGuide_Item_C:BP_OnEntryReleased()
  UpdateVisibility(self.Img_Select, false)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnGenericModifyItemSelectionChanged, WBP_IllustratedGuide_Item_C.OnSelectionChanged, self)
end

function WBP_IllustratedGuide_Item_C:SetSelect(bSelect)
end

function WBP_IllustratedGuide_Item_C:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, true)
  PlaySound2DEffect(50006, "")
end

function WBP_IllustratedGuide_Item_C:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, false)
  UpdateVisibility(self.HoverTips, false)
end

return WBP_IllustratedGuide_Item_C
