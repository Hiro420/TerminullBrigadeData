local WBP_GenericModifyChooseSell_C = UnLua.Class()
local MainPanelClsPath = "/Game/Rouge/UI/Core/MainPanel/WBP_MainPanel.WBP_MainPanel_C"
local EChoosePanelTitleStatus = {
  BattleLagacy = "BattleLagacy",
  Other = "Other"
}

function WBP_GenericModifyChooseSell_C:OnPreload()
  self.Overridden.OnPreload(self)
end

function WBP_GenericModifyChooseSell_C:OnPreloadReset()
  self.Overridden.OnPreloadReset(self)
end

function WBP_GenericModifyChooseSell_C:OnCreate()
  self.Overridden.OnCreate(self)
  self.EscActionName = "PauseGame"
  self.TabKeyEvent = "TabKeyEvent"
  self.CKeyEvent = "BattleRoleInfoShortcut"
  self.SwitchBag = "SwitchBag"
end

function WBP_GenericModifyChooseSell_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  self.WBP_InteractTipWidget_109.OnMainButtonClicked:Add(self, self.ListenForEscInputAction)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.OnSwitchBag)
  if not IsListeningForInputAction(self, self.EscActionName) then
    ListenForInputAction(self.EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_GenericModifyChooseSell_C.ListenForEscInputAction
    })
  end
  if not IsListeningForInputAction(self, self.CKeyEvent) then
    ListenForInputAction(self.CKeyEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_GenericModifyChooseSell_C.OnCKeyEvent
    })
  end
  if not IsListeningForInputAction(self, self.SwitchBag) then
    ListenForInputAction(self.SwitchBag, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_GenericModifyChooseSell_C.OnSwitchBag
    })
  end
  self:StopAnimation(self.Ani_Currency_add)
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.OnBagChanged:Add(self, WBP_GenericModifyChooseSell_C.UpdateCurrencyNum)
    self.CurrencyNum = tonumber(self.Dimond.Txt_Price:GetText())
  end
  self.Dimond:RemoveEvent()
end

function WBP_GenericModifyChooseSell_C:UpdateCurrencyNum()
  self:PlayAnimation(self.Ani_Currency_add)
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local AddNumber = BagComp:GetItemByConfigId(self.Dimond.ItemId).Stack - self.CurrencyNum
  self.AddCurrency:SetText("+" .. tostring(AddNumber))
  self.CurrencyNum = tonumber(BagComp:GetItemByConfigId(self.Dimond.ItemId).Stack)
end

function WBP_GenericModifyChooseSell_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  self.bCanShowBattleRoleInfo = true
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  EventSystem.AddListener(self, EventDef.GenericModify.OnAddModify, WBP_GenericModifyChooseSell_C.UpdateChoosePanel)
  EventSystem.AddListener(self, EventDef.GenericModify.OnRemoveModify, WBP_GenericModifyChooseSell_C.UpdateChoosePanel)
  EventSystem.AddListener(self, EventDef.GenericModify.OnUpgradeModify, WBP_GenericModifyChooseSell_C.UpdateChoosePanel)
  EventSystem.AddListener(self, EventDef.GenericModify.OnFinishInteract, WBP_GenericModifyChooseSell_C.OnFinishChoosePanel)
  EventSystem.AddListener(self, EventDef.GenericModify.OnCancelInteract, WBP_GenericModifyChooseSell_C.OnCancelChoosePanel)
end

function WBP_GenericModifyChooseSell_C:CloseChoosePanel()
  LogicGenericModify:CloseGenericModifyChoosePanel(self.Target)
  self.WBP_InteractTipWidget_109.OnMainButtonClicked:Remove(self, self.ListenForEscInputAction)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.OnSwitchBag)
end

function WBP_GenericModifyChooseSell_C:ListenForEscInputAction()
  if self:CanExitPanel() then
    self:CloseChoosePanel()
  else
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if RGWaveWindowManager then
      RGWaveWindowManager:ShowWaveWindow(self.CanNotExitTip, {})
    end
  end
end

function WBP_GenericModifyChooseSell_C:OnTabKeyEvent()
  if not self:IsAnimationPlaying(self.ani_33_modchoosepanel_in) and not self:IsAnimationPlaying(self.ani_33_modchoosepanel_out) and not self.ModChoose and SwitchUI(self.MainPanelClass, true) then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager and UIManager:IsValid() then
      local widget = UIManager:K2_GetUI(self.MainPanelClass)
      if widget and widget:IsValid() then
        widget:ActivateModPanel()
      end
    end
  end
end

function WBP_GenericModifyChooseSell_C:OnCKeyEvent()
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    print("OnCKeyEvent \230\150\176\230\137\139\229\133\179\228\184\141\232\131\189\229\188\128\232\131\140\229\140\133")
    return
  end
  if not self.bCanShowBattleRoleInfo then
    print("OnCKeyEvent bCanShowBattleRoleInfo Is False")
    return
  end
  local MainPanelCls = UE.UClass.Load(MainPanelClsPath)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:OpenUI(MainPanelCls, false)
    local widget = UIManager:K2_GetUI(MainPanelCls)
    if widget and widget:IsValid() then
      widget:ShowRoleInfoPanel()
    end
  end
end

function WBP_GenericModifyChooseSell_C:OnSwitchBag()
  if RGUIMgr:IsShown(UIConfig.WBP_MainPanel_C.UIName) then
    RGUIMgr:HideUI(UIConfig.WBP_MainPanel_C.UIName)
  else
    RGUIMgr:OpenUI(UIConfig.WBP_MainPanel_C.UIName, false)
    local MainPanelObj = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
    if MainPanelObj then
      MainPanelObj:ShowScrollInfoPanel()
    end
  end
end

function WBP_GenericModifyChooseSell_C:InitGenericModifyChoosePanel(InteractComp, Target)
  self.Target = Target
  self.IsInShop = false
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, false)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, true, true)
  self.InteractComp = InteractComp
  if self.InteractComp then
    if self.InteractComp.PreviewGenericModifyChangedDelegate then
      self.InteractComp.PreviewGenericModifyChangedDelegate:Remove(self, WBP_GenericModifyChooseSell_C.UpdatePanel)
      self.InteractComp.PreviewGenericModifyChangedDelegate:Add(self, WBP_GenericModifyChooseSell_C.UpdatePanel)
    end
    UpdateVisibility(self.WBP_InteractTipWidget, true)
    local ModifyChooseTypeTemp = ModifyChooseType.GenericModify
    if InteractComp:Cast(UE.URGInteractComponent_GenericModifySell:StaticClass()) then
      ModifyChooseTypeTemp = ModifyChooseType.GenericModifySell
    end
    self.ModifyChooseType = ModifyChooseTypeTemp
  end
  self:UpdatePanel()
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
  self.WBP_GenericModifyChoosePanel_sell:PlayAnimation(self.WBP_GenericModifyChoosePanel_sell.ani_GenericModifyChoosePanel_in)
end

function WBP_GenericModifyChooseSell_C:InitTitle(Title, Color, ShadowColor, Sprite)
  local Font = self.RGTextGenericModifyGroupNameShadow.Font
  Font.OutlineSettings.OutlineColor = ShadowColor
  self.RGTextGenericModifyGroupNameShadow:SetFont(Font)
  self.RGTextGenericModifyGroupName:SetText(Title)
  self.RGTextGenericModifyGroupNameShadow:SetText(Title)
  self.RGTextGenericModifyGroupName:SetColorAndOpacity(Color)
  SetImageBrushBySoftObject(self.URGImageIcon, Sprite)
  SetImageBrushBySoftObject(self.URGImageIcon_1, Sprite)
  UpdateVisibility(self.CanvasPanelGroupName, true)
end

function WBP_GenericModifyChooseSell_C:FinishInteractGenericModify()
  LogicGenericModify:FinishInteractGenericModify(self.Target)
end

function WBP_GenericModifyChooseSell_C:UpdatePanel(PreviewModifyListParam)
  if PreviewModifyListParam then
    self.WBP_GenericModifyChooseItemList:UpdatePanel(PreviewModifyListParam, self.InteractComp, self.HoverFunc, self)
    UpdateVisibility(self.RGCoolDownTextBlock_91, 0 == PreviewModifyListParam:Length())
  else
    print("WBP_GenericModifyChooseSell_C", self.InteractComp.PreviewGenericModifyAry, self.InteractComp.PreviewGenericModifyAry:Length())
    self.WBP_GenericModifyChooseItemList:UpdatePanel(self.InteractComp.PreviewGenericModifyAry, self.InteractComp, self.HoverFunc, self)
    UpdateVisibility(self.RGCoolDownTextBlock_91, self.InteractComp.PreviewGenericModifyAry == nil or 0 == self.InteractComp.PreviewGenericModifyAry:Length())
  end
end

function WBP_GenericModifyChooseSell_C:CanExitPanel()
  if self.IsInShop then
    return false
  elseif self.ModifyChooseType == ModifyChooseType.BattleLagacy then
    return false
  else
    return true
  end
end

function WBP_GenericModifyChooseSell_C:UpdateChoosePanel(RGGenericModifyParam)
  if self.IsInShop then
    self:PlayAnimation(self.ani_GenericModifyChoosePanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    local GroupId
    if self.InteractComp then
      GroupId = self.InteractComp.GroupId
    end
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
    end
    self.WBP_GenericModifyChooseItemList:FadeOut(RGGenericModifyParam.ModifyId, GroupId)
  end
end

function WBP_GenericModifyChooseSell_C:SelectModifyId(ModifyId)
  print("WBP_GenericModifyChooseSell_C:SelectModifyId", ModifyId, self.ModifyId)
  if not self.ModifyId then
    self.ModifyId = ModifyId
  end
end

function WBP_GenericModifyChooseSell_C:OnCancelChoosePanel(Target, Instigator)
  print("WBP_GenericModifyChooseSell_C:OnCancelChoosePanel")
  if Target ~= self.Target then
    return
  end
  print("WBP_GenericModifyChooseSell_C:OnCancelChoosePanel CloseChoosePanel")
  self:CloseChoosePanel()
end

function WBP_GenericModifyChooseSell_C:OnFinishChoosePanel(Target, Instigator)
  print("WBP_GenericModifyChooseSell_C:OnFinishChoosePanel", self.IsInShop)
  if self.IsInShop then
    return
  end
  if Target ~= self.Target then
    print("WBP_GenericModifyChooseSell_C:OnFinishChoosePanel Target Is not CurTarget")
    return
  end
  if self.ModifyId and self.ModifyId > 0 then
    print("WBP_GenericModifyChooseSell_C:OnFinishChoosePanel ModifyId:", self.ModifyId)
    self:PlayAnimation(self.ani_GenericModifyChoosePanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    local GroupId
    if self.InteractComp then
      GroupId = self.InteractComp.GroupId
    end
    self.WBP_GenericModifyChooseItemList:FadeOut(self.ModifyId, GroupId)
  else
    print("WBP_GenericModifyChooseSell_C:OnFinishChoosePanel CloseChoosePanel")
    self:CloseChoosePanel()
  end
end

function WBP_GenericModifyChooseSell_C:OnAnimationFinished(Animation)
  if Animation == self.ani_GenericModifyChoosePanel_out then
    if self.ModifyChooseType == ModifyChooseType.BattleLagacy then
      EventSystem.Invoke(EventDef.BattleLagacy.OnBattleLagacyModifyClose)
    end
    print("LogicGenericModify:CloseGenericModifyChoosePanel")
    LogicGenericModify:CloseGenericModifyChoosePanel(self.Target)
  end
  if Animation == self.Ani_Currency_add then
    self.Dimond:UpdateCurrencyNum()
  end
end

function WBP_GenericModifyChooseSell_C:HoverFunc(Slot, bIsHover)
end

function WBP_GenericModifyChooseSell_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_GenericModifyChooseSell_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  if IsListeningForInputAction(self, self.EscActionName) then
    StopListeningForInputAction(self, self.EscActionName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.TabKeyEvent) then
    StopListeningForInputAction(self, self.TabKeyEvent, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.CKeyEvent) then
    StopListeningForInputAction(self, self.CKeyEvent, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.SwitchBag) then
    StopListeningForInputAction(self, self.SwitchBag, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_GenericModifyChooseSell_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  self.WBP_GenericModifyChooseItemList:OnUnDisplay()
  UpdateVisibility(self.CanvasPanelAbandoned, false)
  EventSystem.RemoveListener(EventDef.GenericModify.OnAddModify, WBP_GenericModifyChooseSell_C.UpdateChoosePanel, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnRemoveModify, WBP_GenericModifyChooseSell_C.UpdateChoosePanel, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnUpgradeModify, WBP_GenericModifyChooseSell_C.UpdateChoosePanel, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnFinishInteract, WBP_GenericModifyChooseSell_C.OnFinishChoosePanel, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnCancelInteract, WBP_GenericModifyChooseSell_C.OnCancelChoosePanel, self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
  end
  self:Reset()
  self:StopAllAnimations()
end

function WBP_GenericModifyChooseSell_C:OnClose()
  self.Overridden.OnClose(self)
  self:Reset()
end

function WBP_GenericModifyChooseSell_C:Reset()
  if self.InteractComp then
    if self.InteractComp.OnPreviewGenericModifyRep then
      self.InteractComp.OnPreviewGenericModifyRep:Remove(self, WBP_GenericModifyChooseSell_C.UpdatePanel)
    end
    if self.InteractComp.OnPreviewModifyListChanged then
      self.InteractComp.OnPreviewModifyListChanged:Remove(self, WBP_GenericModifyChooseSell_C.UpdatePanel)
    end
  end
  self.ModifyId = nil
  self.InteractComp = nil
  self.Target = nil
end

function WBP_GenericModifyChooseSell_C:Destruct()
  self:Reset()
end

return WBP_GenericModifyChooseSell_C
