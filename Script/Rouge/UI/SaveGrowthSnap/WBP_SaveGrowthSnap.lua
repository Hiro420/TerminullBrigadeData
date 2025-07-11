local WBP_SaveGrowthSnap = UnLua.Class()
local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")
local SaveGrowthSnapHandler = require("Protocol.SaveGrowthSnap.SaveGrowthSnapHandler")
local SaveMaxNum = 3
local EscActionName = "PauseGame"
function WBP_SaveGrowthSnap:Construct()
  self.WBP_CommonButton_Overwrite.OnMainButtonClicked:Add(self, self.OnSave)
  self.WBP_CommonButton_Save.OnMainButtonClicked:Add(self, self.OnSave)
  self.WBP_CommonButton_Select.OnMainButtonClicked:Add(self, self.OnSelect)
  self.RGToggleComGroup_Save.OnCheckStateChanged:Add(self, self.OnToggleStateChanged)
  SaveGrowthSnapData.CurSelectTogglePos = SaveGrowthSnapData.CurSelectPos or 0
  EventSystem.AddListenerNew(EventDef.SaveGrowthSnap.OnRefreshSnap, self, self.OnRefreshSnap)
  EventSystem.AddListenerNew(EventDef.SaveGrowthSnap.OnRefreshSelect, self, self.OnUpdateSelect)
end
function WBP_SaveGrowthSnap:ShowSnap(SaveGrowthSnapFrom)
  SaveGrowthSnapHandler.RequestGetGrowthSnapShot()
  local saveGrowthSnapFrom = SaveGrowthSnapFrom or ESaveGrowthSnapFrom.Settle
  self.SaveGrowthSnapFrom = saveGrowthSnapFrom
  if not IsListeningForInputAction(self, EscActionName) then
    ListenForInputAction(EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  self.WBP_InteractTipWidget_Esc.Btn_Main.OnClicked:Add(self, self.ListenForEscInputAction)
  self.StateCtrl_From:ChangeStatus(saveGrowthSnapFrom)
  UpdateVisibility(self, true)
  self:InitToggle()
  if SaveGrowthSnapFrom == ESaveGrowthSnapFrom.Settle then
    self:UpdateExpire()
  end
  self:PushInputAction()
end
function WBP_SaveGrowthSnap:ListenForEscInputAction()
  self:HideSnap()
end
function WBP_SaveGrowthSnap:HideSnap()
  self.WBP_InteractTipWidget_Esc.Btn_Main.OnClicked:Remove(self, self.ListenForEscInputAction)
  if IsListeningForInputAction(self, EscActionName) then
    StopListeningForInputAction(self, EscActionName, UE.EInputEvent.IE_Pressed)
  end
  UpdateVisibility(self, false)
end
function WBP_SaveGrowthSnap:OnRefreshSnap(bFromSave)
  if bFromSave then
    self.bHadSave = true
  end
  if self.bHadSave then
    UpdateVisibility(self.RGCanvas_Overwrite, false)
    UpdateVisibility(self.RGCanvas_Save, false)
  else
    UpdateVisibility(self.RGCanvas_Overwrite, true)
    UpdateVisibility(self.RGCanvas_Save, true)
  end
  self:InitToggle()
  local day, hour = GetTimeUntilTarget(1, 5)
  local str = UE.FTextFormat(self.InvalidCountDownFmt, day, hour)
  self.RGTxt_InvalidCountDown:SetText(str)
end
function WBP_SaveGrowthSnap:UpdateExpire()
  local settlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
  if UE.RGUtil.IsUObjectValid(settlementView) and settlementView.bSaveGrowthSnapexpire then
    self.RGCanvas_Save:SetIsEnabled(false)
    self.RGCanvas_Overwrite:SetIsEnabled(false)
  else
    self.RGCanvas_Save:SetIsEnabled(true)
    self.RGCanvas_Overwrite:SetIsEnabled(true)
  end
end
function WBP_SaveGrowthSnap:InitToggle()
  print("WBP_SaveGrowthSnap:InitToggle", #SaveGrowthSnapData.SaveGrowthSnapMap)
  SaveMaxNum = #SaveGrowthSnapData.SaveGrowthSnapMap + 1
  self.RGToggleComGroup_Save:ClearGroup()
  for i = 1, SaveMaxNum do
    local pos = i - 1
    local SaveGrowthSnapItem = GetOrCreateItem(self.RGScrollBox_Toggle, i, self.WBP_SaveGrowthSnapToggle:GetClass())
    local toggleComp = SaveGrowthSnapItem:GetWidgetComp2DByName(UE.URGWidgetCom2D_Toggle.StaticClass():GetName(), false)
    if toggleComp then
      self.RGToggleComGroup_Save:AddToGroup(i - 1, toggleComp)
    end
    SaveGrowthSnapItem:InitSaveGrowthSnapToggle(pos, SaveGrowthSnapData.SaveGrowthSnapMap[pos])
    UpdateVisibility(SaveGrowthSnapItem, true, true)
  end
  self.RGToggleComGroup_Save:SelectId(SaveGrowthSnapData.CurSelectTogglePos)
  HideOtherItem(self.RGScrollBox_Toggle, SaveMaxNum + 1, true)
end
function WBP_SaveGrowthSnap:OnToggleStateChanged(ToggleId)
  print("WBP_SaveGrowthSnap:OnToggleStateChanged", ToggleId)
  local pos = tonumber(ToggleId)
  SaveGrowthSnapData.CurSelectTogglePos = pos
  self:InitSaveGrowSnapByPos(SaveGrowthSnapData.CurSelectTogglePos)
  self:OnUpdateSelect()
end
function WBP_SaveGrowthSnap:OnUpdateSelect()
  if SaveGrowthSnapData.CurSelectPos ~= SaveGrowthSnapData.CurSelectTogglePos then
    UpdateVisibility(self.RGCanvas_Select, true)
    UpdateVisibility(self.RGCanvas_HadSelected, false)
  else
    UpdateVisibility(self.RGCanvas_Select, false)
    UpdateVisibility(self.RGCanvas_HadSelected, true)
  end
end
function WBP_SaveGrowthSnap:InitSaveGrowSnapByStaging()
  self:InitSaveGrowSnapByStaging(SaveGrowthSnapData.SnapshotStaging)
end
function WBP_SaveGrowthSnap:InitSaveGrowSnapByCurSelectPos()
  if self.bHadSave then
    UpdateVisibility(self.RGCanvas_Overwrite, false)
    UpdateVisibility(self.RGCanvas_Save, false)
  else
    UpdateVisibility(self.RGCanvas_Overwrite, true)
    UpdateVisibility(self.RGCanvas_Save, true)
  end
  local curSaveGrowthSnap = SaveGrowthSnapData.SaveGrowthSnapMap[SaveGrowthSnapData.CurSelectPos]
  if not SaveGrowthSnapData:CheckIsEmpty(SaveGrowthSnapData.CurSelectPos) then
    self:InitSaveGrowthSnapByData(curSaveGrowthSnap.GrowthSnapShot)
    self.StateCtrl_Empty:ChangeStatus(EEmpty.NotEmpty)
  else
    self.StateCtrl_Empty:ChangeStatus(EEmpty.Empty)
  end
end
function WBP_SaveGrowthSnap:InitSaveGrowSnapByPos(Pos)
  if self.bHadSave then
    UpdateVisibility(self.RGCanvas_Overwrite, false)
    UpdateVisibility(self.RGCanvas_Save, false)
  else
    UpdateVisibility(self.RGCanvas_Overwrite, true)
    UpdateVisibility(self.RGCanvas_Save, true)
  end
  local curSaveGrowthSnap = SaveGrowthSnapData.SaveGrowthSnapMap[Pos]
  if not SaveGrowthSnapData:CheckIsEmpty(Pos) then
    self:InitSaveGrowthSnapByData(curSaveGrowthSnap.GrowthSnapShot)
    self.StateCtrl_Empty:ChangeStatus(EEmpty.NotEmpty)
  else
    self.StateCtrl_Empty:ChangeStatus(EEmpty.Empty)
  end
end
function WBP_SaveGrowthSnap:InitSaveGrowthSnapByData(SnapData)
  if SnapData and SnapData.gold_coin then
    self.RGTxt_Coin:SetText(SnapData.gold_coin)
    UpdateVisibility(self.RGTxt_Coin, true)
    UpdateVisibility(self.RGTxt_Coin_1, true)
  else
    UpdateVisibility(self.RGTxt_Coin, false)
    UpdateVisibility(self.RGTxt_Coin_1, false)
  end
  for i, v in pairs(self.SlotList) do
    if SnapData and SnapData.generic_modify then
      local bIsEmpty = true
      for idx = 1, #SnapData.generic_modify, 2 do
        local genericId = SnapData.generic_modify[idx]
        local result, genericRow = GetRowData(DT.DT_GenericModify, genericId)
        if result and genericRow.Slot == v then
          local level = SnapData.generic_modify[idx + 1]
          local genericData = {ModifyId = genericId, Level = level}
          local GenericModifyItem = GetOrCreateItem(self.RGScrollBox_Slot_Generic, i, self.WBP_BagRoleGenericItem_SettlementSlot:GetClass())
          if genericData and genericData.ModifyId > 0 then
            bIsEmpty = false
            GenericModifyItem:InitBagRoleGenericItem(genericData, v, self.UpdateGenericModifyTipsFunc, self)
          else
            GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
          end
        end
      end
      if bIsEmpty then
        local GenericModifyItem = GetOrCreateItem(self.RGScrollBox_Slot_Generic, i, self.WBP_BagRoleGenericItem_SettlementSlot:GetClass())
        GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
      end
    else
      local GenericModifyItem = GetOrCreateItem(self.RGScrollBox_Slot_Generic, i, self.WBP_BagRoleGenericItem_SettlementSlot:GetClass())
      GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
    end
  end
  local idxNoSlot = 1
  if SnapData and SnapData.generic_modify then
    for i = 1, #SnapData.generic_modify, 2 do
      local genericId = SnapData.generic_modify[i]
      local result, genericRow = GetRowData(DT.DT_GenericModify, genericId)
      if result and genericRow.Slot == UE.ERGGenericModifySlot.None then
        local level = SnapData.generic_modify[i + 1]
        local genericData = {ModifyId = genericId, Level = level}
        local GenericModifyItem = GetOrCreateItem(self.WrapBox_GenericNoSlot, idxNoSlot, self.WBP_BagRoleGenericItem_Settlement:GetClass())
        if genericData and genericData.ModifyId > 0 then
          GenericModifyItem:InitBagRoleGenericItem(genericData, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self)
        else
          GenericModifyItem:InitBagRoleGenericItem(nil, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self)
        end
        idxNoSlot = idxNoSlot + 1
      end
    end
  end
  if SnapData and SnapData.specific_modify then
    for i, v in ipairs(SnapData.specific_modify) do
      local SpecificModifyItem = GetOrCreateItem(self.WrapBox_GenericNoSlot, idxNoSlot, self.WBP_BagRoleGenericItem_Settlement:GetClass())
      if v > 0 then
        SpecificModifyItem:InitSpecificModifyItem({ModifyId = v}, -1, self.UpdateGenericModifyTipsFunc, self)
      else
        SpecificModifyItem:InitSpecificModifyItem(nil, -1, self.UpdateGenericModifyTipsFunc, self)
      end
      idxNoSlot = idxNoSlot + 1
    end
  end
  HideOtherItem(self.WrapBox_GenericNoSlot, idxNoSlot)
  if 1 == idxNoSlot then
    self.StateCtrl_PasstiveEmpty:ChangeStatus(EPasstiveEmpty.PasstiveEmpty)
  else
    self.StateCtrl_PasstiveEmpty:ChangeStatus(EPasstiveEmpty.NotPasstiveEmpty)
  end
  local count = 0
  if SnapData and SnapData.attribute_modify then
    for i, v in ipairs(SnapData.attribute_modify) do
      local AttributeModifyItem = GetOrCreateItem(self.WrapBoxScrollList, i, self.WBP_Item_1:GetClass())
      if v and v > 0 then
        local scrollId = v
        local hoverFunc = function(Item)
          if IsValidObj(self) and IsValidObj(Item) then
            self:UpdateShowPickupTipsView(true, scrollId, Item, EScrollTipsOpenType.EFromSaveGrowthSnap, true)
          end
        end
        local unhoverFunc = function(Item)
          if IsValidObj(self) then
            UpdateVisibility(self.WBP_ScrollPickUpTipsView, false)
          end
        end
        AttributeModifyItem:InitItem(scrollId)
        AttributeModifyItem:BindOnMainButtonHovered(hoverFunc)
        AttributeModifyItem:BindOnMainButtonUnHovered(unhoverFunc)
        UpdateVisibility(AttributeModifyItem, true)
      end
    end
    count = #SnapData.attribute_modify
  end
  HideOtherItem(self.WrapBoxScrollList, count + 1, true)
  local idxSet = 1
  if SnapData and SnapData.attribute_modify_set then
    for i = 1, #SnapData.attribute_modify_set, 2 do
      local scrollId = SnapData.attribute_modify_set[i]
      local level = SnapData.attribute_modify_set[i + 1]
      local scrollData = {SetId = scrollId, Level = level}
      local AttributeSetItem = GetOrCreateItem(self.WrapBoxScrollSetList, idxSet, self.WBP_SettlementScrollSetItem:GetClass())
      AttributeSetItem:InitScrollSetItem(scrollData, self.UpdateScrollSetTips, self, idxSet)
      idxSet = idxSet + 1
    end
  end
  HideOtherItem(self.WrapBoxScrollSetList, idxSet)
end
function WBP_SaveGrowthSnap:OnAnimationFinished(Animation)
end
function WBP_SaveGrowthSnap:OnSave()
  local WaveWindParam = UE.FWaveWindowParam()
  WaveWindParam.IntParam0 = UE.EComMsgPopupStateType.EditTextWithoutCost
  WaveWindParam.StringParam0 = "\232\175\183\232\190\147\229\133\165\229\164\135\230\179\168"
  local waveWndMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if waveWndMgr then
    waveWndMgr:ShowWaveWindowWithWaveParam(1403, {}, nil, function()
      self:UpdateExpire()
      local settlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
      if UE.RGUtil.IsUObjectValid(settlementView) and settlementView.bSaveGrowthSnapexpire then
        ShowWaveWindow(1404)
      else
        local remark = waveWndMgr:GetComMsgPopupNickName()
        SaveGrowthSnapHandler.RequestSaveGrowthSnapShot(SaveGrowthSnapData.CurSelectTogglePos, remark)
      end
    end, nil, WaveWindParam)
  end
end
function WBP_SaveGrowthSnap:OnSelect()
  SaveGrowthSnapHandler.RequestSetGrowthSnapShot(SaveGrowthSnapData.CurSelectTogglePos)
end
function WBP_SaveGrowthSnap:UpdateShowPickupTipsView(bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  print("WBP_SettlementPlayerInfoView_C:UpdateShowPickupTipsView", bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  if ScrollId and ScrollId > 0 then
    self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ScrollId, ScrollTipsOpenType, TargetItem, bIsNeedInit, self.SelectPlayerId)
    self.WBP_ScrollPickUpTipsView:Show(true)
    SetHitTestInvisible(self.WBP_ScrollPickUpTipsView)
  else
    UpdateVisibility(self.WBP_ScrollPickUpTipsView, false)
  end
end
function WBP_SaveGrowthSnap:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTipsBySettlement(Data, Slot)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    SetHitTestInvisible(self.WBP_GenericModifyBagTips)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end
function WBP_SaveGrowthSnap:UpdateScrollSetTips(bIsShow, ActivatedSetData, ScrollSetItem)
  if bIsShow then
    self.WBP_ScrollSetTips:InitScrollSetTips(ActivatedSetData)
    local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
    if TipsCanvasSlot then
      local GeometryScrollSetItem = ScrollSetItem:GetCachedGeometry()
      local GeometryCanvasPanelScroll = self.CanvasPanelScroll:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelScroll, GeometryScrollSetItem)
      TipsCanvasSlot:SetPosition(UE.FVector2D(TipsCanvasSlot:GetPosition().X, Pos.Y))
    end
    SetHitTestInvisible(self.WBP_ScrollSetTips)
  else
    UpdateVisibility(self.WBP_ScrollSetTips, false)
  end
end
function WBP_SaveGrowthSnap:Destruct()
  print("WBP_SaveGrowthSnap:Destruct()")
  self.bHadSave = false
  self.WBP_CommonButton_Overwrite.OnMainButtonClicked:Remove(self, self.OnSave)
  self.WBP_CommonButton_Save.OnMainButtonClicked:Remove(self, self.OnSave)
  self.WBP_CommonButton_Select.OnMainButtonClicked:Remove(self, self.OnSelect)
  self.RGToggleComGroup_Save.OnCheckStateChanged:Remove(self, self.OnToggleStateChanged)
  EventSystem.RemoveListenerNew(EventDef.SaveGrowthSnap.OnRefreshSnap, self, self.OnRefreshSnap)
  EventSystem.RemoveListenerNew(EventDef.SaveGrowthSnap.OnRefreshSelect, self, self.OnUpdateSelect)
end
return WBP_SaveGrowthSnap
