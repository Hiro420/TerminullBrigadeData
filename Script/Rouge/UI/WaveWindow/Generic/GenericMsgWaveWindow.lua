local GenericMsgWaveWindow = UnLua.Class()
function GenericMsgWaveWindow:InitGenericMsgWaveWindow(OldModifyData, NewModifyData)
  self.WBP_GenericModifyMsgItemLeft:InitGenericModifyMsgItem(OldModifyData, self, true)
  self.WBP_GenericModifyMsgItemRight:InitGenericModifyMsgItem(NewModifyData, self, false)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.OnCancelClick)
end
function GenericMsgWaveWindow:InitSpecificReplaceMsgWaveWindow(OldInscription, NewInscription)
  self.WBP_GenericModifyMsgItemLeft:InitSpecificModifyMsgItem(OldInscription, self, true)
  self.WBP_GenericModifyMsgItemRight:InitSpecificModifyMsgItem(NewInscription, self, false)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.OnCancelClick)
end
function GenericMsgWaveWindow:ShowModifyTips(bIsShow, ModifyData, bLeft)
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not logicCommandDataSubsystem then
    return
  end
  if bLeft then
    UpdateVisibility(self.WBP_GenericModifyBagTipsLeft, bIsShow)
    if bIsShow then
      local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyData.ModifyId))
      if result then
        self.WBP_GenericModifyBagTipsLeft:InitGenericModifyTips(ModifyData.ModifyId, false, row.Slot)
      end
    end
  else
    UpdateVisibility(self.WBP_GenericModifyBagTipsRight, bIsShow)
    if bIsShow then
      local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyData.ModifyId))
      if result then
        self.WBP_GenericModifyBagTipsRight:InitGenericModifyTips(ModifyData.ModifyId, false, row.Slot)
      end
    end
  end
end
function GenericMsgWaveWindow:ShowSpecificTips(bIsShow, InscriptionID, bLeft)
  if bLeft then
    UpdateVisibility(self.WBP_GenericModifyBagTipsLeft, bIsShow)
    if bIsShow then
      self.WBP_GenericModifyBagTipsLeft:InitSpecificModifyTips(InscriptionID, false)
    end
  else
    UpdateVisibility(self.WBP_GenericModifyBagTipsRight, bIsShow)
    if bIsShow then
      self.WBP_GenericModifyBagTipsRight:InitSpecificModifyTips(InscriptionID, false)
    end
  end
end
return GenericMsgWaveWindow
