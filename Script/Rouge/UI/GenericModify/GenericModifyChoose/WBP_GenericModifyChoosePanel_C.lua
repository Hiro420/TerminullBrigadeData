local WBP_GenericModifyChoosePanel_C = UnLua.Class()
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local MainPanelClsPath = "/Game/Rouge/UI/Core/MainPanel/WBP_MainPanel.WBP_MainPanel_C"
local ResultToWaveId = {
  [2] = 1169,
  [3] = 1170
}
local EChoosePanelTitleStatus = {
  BattleLagacy = "BattleLagacy",
  Other = "Other"
}
local HideAllEffects = function(self)
  self.StateCtrl_TitleEff:ChangeStatus("-1")
  for i, v in pairs(self.StateCtrl_TitleEff.Elements) do
    local TitleName = "AutoLoad_TitleGroup_" .. v.Key
    if self[TitleName] then
      self[TitleName]:StopAnimation("ani_GenericModifyChoosePanel_in")
      self[TitleName]:StopAnimation("Ani_move")
    end
  end
  self.WBP_GenericModifyChoosePanel_Special:StopAnimation(self.WBP_GenericModifyChoosePanel_Special.ani_GenericModifyChoosePanel_in)
  UpdateVisibility(self.WBP_GenericModifyChoosePanel_Special, false)
  if UE.RGUtil.IsUObjectValid(self.AutoLoad_SpecificExchange.ChildWidget) then
    self.AutoLoad_SpecificExchange.ChildWidget:StopAnimation(self.AutoLoad_SpecificExchange.ChildWidget.ani_GenericModifyChoosePanel_in)
  end
  UpdateVisibility(self.AutoLoad_SpecificExchange, false)
  self.WBP_GenericModifyChoosePanel_Upgrade:StopAnimation(self.WBP_GenericModifyChoosePanel_Upgrade.ani_GenericModifyChoosePanel_in)
  UpdateVisibility(self.WBP_GenericModifyChoosePanel_Upgrade, false)
  self.WBP_GenericModifyChoosePanel_QualityUpgrades:StopAnimation(self.WBP_GenericModifyChoosePanel_QualityUpgrades.ani_GenericModifyChoosePanel_in)
  UpdateVisibility(self.WBP_GenericModifyChoosePanel_QualityUpgrades, false)
  if self.RGStateControllerTitle then
    self.RGStateControllerTitle:ChangeStatus(EChoosePanelTitleStatus.Other)
  end
end

function WBP_GenericModifyChoosePanel_C:OnPreload()
  self.Overridden.OnPreload(self)
end

function WBP_GenericModifyChoosePanel_C:OnPreloadReset()
  self.Overridden.OnPreloadReset(self)
end

function WBP_GenericModifyChoosePanel_C:OnCreate()
  self.Overridden.OnCreate(self)
  self.EscActionName = "PauseGame"
  self.TabKeyEvent = "TabKeyEvent"
  self.CKeyEvent = "BattleRoleInfoShortcut"
  self.SwitchBag = "SwitchBag"
end

function WBP_GenericModifyChoosePanel_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  if not IsListeningForInputAction(self, self.EscActionName) then
    ListenForInputAction(self.EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_GenericModifyChoosePanel_C.ListenForEscInputAction
    })
  end
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Add(self, self.OnCKeyEvent)
  if not IsListeningForInputAction(self, self.CKeyEvent) then
    ListenForInputAction(self.CKeyEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_GenericModifyChoosePanel_C.OnCKeyEvent
    })
  end
  if not IsListeningForInputAction(self, self.SwitchBag) then
    ListenForInputAction(self.SwitchBag, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_GenericModifyChoosePanel_C.OnSwitchBag
    })
  end
  self.BP_ButtonWithSoundAbandoned.OnClicked:Add(self, self.OnAbandonedClick)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.ListenForEscInputAction)
  self.BP_ButtonWithSoundRefresh.OnClicked:Add(self, self.OnRefreshClick)
  local PlayerPawn = self:GetOwningPlayerPawn()
  if PlayerPawn and PlayerPawn.GenericModifyComponent then
    PlayerPawn.GenericModifyComponent.OnGenericModifyRefreshCountChange:Remove(self, WBP_GenericModifyChoosePanel_C.RefreshNum)
    PlayerPawn.GenericModifyComponent.OnGenericModifyRefreshCountChange:Add(self, WBP_GenericModifyChoosePanel_C.RefreshNum)
  end
  self:UpdateHudListNav()
end

function WBP_GenericModifyChoosePanel_C:RefreshNum()
  if self.ModifyChooseType == ModifyChooseType.SpecificModify or self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
    return
  end
  local PlayerPawn = self:GetOwningPlayerPawn()
  if PlayerPawn and PlayerPawn.GenericModifyComponent then
    local refreshCount = PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCount()
    print("WBP_GenericModifyChoosePanel_C:RefreshNum", refreshCount)
    self.RGTextRefreshNum:SetText(refreshCount)
  end
end

function WBP_GenericModifyChoosePanel_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  self:ComInitGeneric()
  self.bCanShowBattleRoleInfo = true
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  EventSystem.AddListener(self, EventDef.GenericModify.OnAddModify, WBP_GenericModifyChoosePanel_C.UpdateChoosePanel)
  EventSystem.AddListener(self, EventDef.GenericModify.OnRemoveModify, WBP_GenericModifyChoosePanel_C.UpdateChoosePanel)
  EventSystem.AddListener(self, EventDef.GenericModify.OnUpgradeModify, WBP_GenericModifyChoosePanel_C.OnUpgradeModify)
  EventSystem.AddListener(self, EventDef.GenericModify.OnFinishInteract, WBP_GenericModifyChoosePanel_C.OnFinishChoosePanel)
  EventSystem.AddListener(self, EventDef.GenericModify.OnCancelInteract, WBP_GenericModifyChoosePanel_C.OnCancelChoosePanel)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnTriggerCurrBattleLagacy, self, WBP_GenericModifyChoosePanel_C.OnFinishChooseBattleLagacy)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnSelectBattleLagacyFailed, self, WBP_GenericModifyChoosePanel_C.OnSelectBattleLagacyFailed)
  EventSystem.AddListener(self, EventDef.SpecificModify.OnAddModify, WBP_GenericModifyChoosePanel_C.UpdateSpecificChoosePanel)
  EventSystem.AddListener(self, EventDef.SpecificModify.OnRemoveModify, WBP_GenericModifyChoosePanel_C.UpdateSpecificChoosePanel)
  EventSystem.AddListenerNew(EventDef.SpecificModify.OnRefreshCountChange, self, WBP_GenericModifyChoosePanel_C.UpdateSpecificModifyRefresh)
  BeginnerGuideData:UpdateWidget("CanvasPanel_SpecificModify_step1", self.CanvasPanel_SpecificModify_step1)
  BeginnerGuideData:UpdateWidget("CanvasPanel_SpecificModify_step2", self.CanvasPanel_SpecificModify_step2)
  BeginnerGuideData:UpdateWidget("CanvasPanel_GenericModify_step1", self.CanvasPanel_GenericModify_step1)
  BeginnerGuideData:UpdateWidget("CanvasPanel_GenericModify_step2", self.CanvasPanel_GenericModify_step2)
  BeginnerGuideData:UpdateWidget("CanvasPanel_SpecificModify_step3", self.CanvasPanel_SpecificModify_step3)
  BeginnerGuideData:UpdateWidget("CanvasPanel_SpecificModify_step4", self.CanvasPanel_SpecificModify_step4)
  UpdateVisibility(self.Txt_BattleLagacyCountDown, false)
  UpdateVisibility(self.CanvasPanel_SurvivalModify, self:IsSurvivalMode())
  self:BindAttributeChanged()
end

function WBP_GenericModifyChoosePanel_C:BindAttributeChanged()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  CoreComp:BindAttributeChanged(self.HealthAttribute, {
    self,
    self.BindOnHealthAttributeChanged
  })
end

function WBP_GenericModifyChoosePanel_C:UnBindAttributeChanged()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  CoreComp:UnBindAttributeChanged(self.HealthAttribute, {
    self,
    self.BindOnHealthAttributeChanged
  })
end

function WBP_GenericModifyChoosePanel_C:ComInitGeneric()
  self.ShopNPC = nil
  self:SetFromDialog(false)
  self.WBP_GenericModifySpecificExchangeOld:Hide()
  self.WBP_GenericModifySpecificExchangeNew:Hide()
  UpdateVisibility(self.Icon_Arrow, false)
  UpdateVisibility(self.Txt_Exchange, false)
  UpdateVisibility(self.CanvasPanel_SpecificExchange, false)
  UpdateVisibility(self.CanvasPanelMoney, false)
  UpdateVisibility(self.CanvasPanelAbandoned, false)
  UpdateVisibility(self.CanvasPanel_Invincible, false)
end

function WBP_GenericModifyChoosePanel_C:CloseChoosePanel()
  LogicGenericModify:CloseGenericModifyChoosePanel(self.Target)
end

function WBP_GenericModifyChoosePanel_C:ListenForEscInputAction()
  if self:CanExitPanel() then
    if self:CheckNeedConfirmExit() then
      self.BattleLagacyConfirmWnd = ShowWaveWindowWithDelegate(1206, {}, function()
        if UE.RGUtil.IsUObjectValid(self) then
          self:BattleLagacyModifyClose()
        end
      end)
    else
      self:CloseChoosePanel()
    end
  else
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if RGWaveWindowManager then
      RGWaveWindowManager:ShowWaveWindow(self.CanNotExitTip, {})
    end
  end
end

function WBP_GenericModifyChoosePanel_C:OnTabKeyEvent()
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

function WBP_GenericModifyChoosePanel_C:OnCKeyEvent()
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

function WBP_GenericModifyChoosePanel_C:OnSwitchBag()
end

function WBP_GenericModifyChoosePanel_C:SetFromDialog(bIsFromDialog)
  self.bIsFromDialog = bIsFromDialog
end

function WBP_GenericModifyChoosePanel_C:InitGenericModifyChoosePanel(InteractComp, Target)
  self.Target = Target
  self.IsInShop = false
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, false)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, true, true)
  self.InteractComp = InteractComp
  local ModifyChooseTypeTemp = ModifyChooseType.GenericModify
  if self.InteractComp then
    if self.InteractComp.OnPreviewGenericModifyRep then
      self.InteractComp.OnPreviewGenericModifyRep:Remove(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
      self.InteractComp.OnPreviewGenericModifyRep:Add(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
    end
    if self.InteractComp.OnPreviewUpgradeRarityListChanged then
      self.InteractComp.OnPreviewUpgradeRarityListChanged:Remove(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
      self.InteractComp.OnPreviewUpgradeRarityListChanged:Add(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
    end
    if self.InteractComp.OnPreviewModifyListChanged then
      self.InteractComp.OnPreviewModifyListChanged:Remove(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
      self.InteractComp.OnPreviewModifyListChanged:Add(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
    end
    if self.InteractComp.PreviewGenericModifyChangedDelegate then
      self.InteractComp.PreviewGenericModifyChangedDelegate:Remove(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
      self.InteractComp.PreviewGenericModifyChangedDelegate:Add(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
    end
    UpdateVisibility(self.WBP_HUD_GenericModifyList, true)
    local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
    if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
      UpdateVisibility(self.WBP_InteractTipWidget, false)
    else
      UpdateVisibility(self.WBP_InteractTipWidget, true)
    end
    self.WBP_HUD_GenericModifyList:SelectClick()
    HideAllEffects(self)
    if InteractComp:Cast(UE.URGInteractComponent_SpecificModify:StaticClass()) then
      InteractComp.PreviewSpecificModifyRefreshed:Remove(self, self.PreviewSpecificModifyRefreshed)
      InteractComp.PreviewSpecificModifyRefreshed:Add(self, self.PreviewSpecificModifyRefreshed)
    end
    ModifyChooseTypeTemp = LogicGenericModify:GetModifyTypeByComp(InteractComp)
    self.ModifyChooseType = ModifyChooseTypeTemp
    self:UpdateAbandonedInfo()
    if self.ModifyChooseType ~= ModifyChooseType.SpecificModify and self.ModifyChooseType ~= ModifyChooseType.SpecificModifyReplace then
      self:RefreshNum()
    end
    self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
    self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
    if ModifyChooseTypeTemp == ModifyChooseType.GenericModify then
      UpdateVisibility(self.CanvasPanelGroupName, true)
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem and self.InteractComp then
        local Result, GenericModifyGroupRow = DTSubsystem:GetGenericModifyGroupDataByName(self.InteractComp.GroupId, nil)
        if Result then
          self:InitTitle(GenericModifyGroupRow.Name, GenericModifyGroupRow.ChoosePanelColor, GenericModifyGroupRow.ChoosePanelShadowColor, GenericModifyGroupRow.ChoosePanelIcon)
        end
      end
      local Text = UE.URGBlueprintLibrary.TextFromStringTable("1051")
      self.RGTextDesc:SetText(Text)
      local GroupIdName = tostring(self.InteractComp.GroupId)
      self:ShowTitle(GroupIdName, self.bIsFromDialog)
      if self.ModifyChooseType == ModifyChooseType.GenericModify then
        local PlayerPawn = self:GetOwningPlayerPawn()
        if PlayerPawn and PlayerPawn.GenericModifyComponent then
          local RefreshCount = PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCount()
          UpdateVisibility(self.BP_ButtonWithSoundRefresh, RefreshCount > 0, true)
        end
      end
      UpdateVisibility(self.CanvasPanelMoney, false)
      local HasDoubleModify = false
      for key, ModifyId in pairs(self.InteractComp.PreviewModifyList) do
        local Result, RowInfo = GetRowData(DT.DT_GenericModify, ModifyId)
        if Result and RowInfo.GenericModifyType == UE.ERGGenericModifyType.Dual then
          HasDoubleModify = true
        end
      end
      self.IsDoubleGenericModify = HasDoubleModify
      if HasDoubleModify then
        local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[ModifyChooseType.DoubleGenericModify]
        NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnDoubleGenericModifyPanelShow, OpenTime)
      else
        local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[ModifyChooseType.GenericModify]
        NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnGenericModifyPanelShow, OpenTime)
      end
    elseif ModifyChooseTypeTemp == ModifyChooseType.UpgradeModify then
      UpdateVisibility(self.WBP_GenericModifyChoosePanel_Upgrade, true)
      self.WBP_GenericModifyChoosePanel_Upgrade:PlayAnimation(self.WBP_GenericModifyChoosePanel_Upgrade.ani_GenericModifyChoosePanel_in)
      self:InitTitle(self.UpgradeModifyTitle, self.UpgradeModifyTitleColor, self.UpgradeModifyTitleShadowColor, self.UpgradeModifyIconSprite)
      local Text = UE.URGBlueprintLibrary.TextFromStringTable("1052")
      self.RGTextDesc:SetText(Text)
      UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
      UpdateVisibility(self.CanvasPanelMoney, false)
      local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[ModifyChooseType.UpgradeModify]
      NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnUpgradeModifyPanelShow, OpenTime)
    elseif ModifyChooseTypeTemp == ModifyChooseType.SpecificModify then
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
      if bagComponent then
        bagComponent.PostItemChanged:Add(self, self.OnItemChanged)
      end
      UpdateVisibility(self.WBP_GenericModifyChoosePanel_Special, true)
      self.WBP_GenericModifyChoosePanel_Special:PlayAnimation(self.WBP_GenericModifyChoosePanel_Special.ani_GenericModifyChoosePanel_in)
      self:InitTitle(self.ModTitle, self.ModTitleColor, self.ModTitleShadowColor, self.ModIconSoftSprite)
      local Text = UE.URGBlueprintLibrary.TextFromStringTable("1053")
      self.RGTextDesc:SetText(Text)
      UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
      self:UpdateSpecificModifyRefresh()
      if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
      end
      UpdateVisibility(self.WBP_GenericModifyChooseItemList, false)
      local delay = self.DelayShowSpecific or 1.14
      self.DelayShowModfyListHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        GameInstance,
        function()
          self:UpdatePanel()
          local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[ModifyChooseType.SpecificModify]
          NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnSpecificModifyPanelShow, OpenTime)
          self.WBP_GenericModifyChooseItemList.WBP_GenericModifyChooseItem1:SetFocus()
        end
      }, delay, false)
    elseif ModifyChooseTypeTemp == ModifyChooseType.SpecificModifyReplace then
      UpdateVisibility(self.CanvasPanel_SpecificExchange, true)
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
      if bagComponent then
        bagComponent.PostItemChanged:Add(self, self.OnItemChanged)
      end
      UpdateVisibility(self.AutoLoad_SpecificExchange, true)
      self.AutoLoad_SpecificExchange.ChildWidget:PlayAnimation(self.AutoLoad_SpecificExchange.ChildWidget.ani_GenericModifyChoosePanel_in)
      self:InitTitle(self.ModTitle, self.ModTitleColor, self.ModTitleShadowColor, self.ModIconSoftSprite)
      local Text = UE.URGBlueprintLibrary.TextFromStringTable("1053")
      self.RGTextDesc:SetText(Text)
      UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
      self:UpdateSpecificModifyRefresh()
      if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
      end
      UpdateVisibility(self.WBP_GenericModifyChooseItemList, false)
      local delay = self.DelayShowSpecific or 1.14
      self.DelayShowModfyListHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        GameInstance,
        function()
          self:UpdatePanel()
          local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[ModifyChooseType.SpecificModify]
          NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnSpecificModifyPanelShow, OpenTime)
          local curSpecificModify = LogicGenericModify:GetFirstSpecificModify()
          if curSpecificModify then
            self.WBP_GenericModifySpecificExchangeOld:InitGenericModifySpecificExchange(curSpecificModify.ModifyId, self)
          else
            UpdateVisibility(self.WBP_GenericModifySpecificExchangeOld, false)
          end
          self.WBP_GenericModifyChooseItemList.WBP_GenericModifyChooseItem1:SetFocus()
        end
      }, delay, false)
    elseif ModifyChooseTypeTemp == ModifyChooseType.RarityUpModify then
      UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
      UpdateVisibility(self.WBP_GenericModifyChoosePanel_QualityUpgrades, true)
      self.WBP_GenericModifyChoosePanel_QualityUpgrades:PlayAnimation(self.WBP_GenericModifyChoosePanel_QualityUpgrades.ani_GenericModifyChoosePanel_in)
      self:InitTitle(self.ShopModifyTitle, self.UpgradeModifyTitleColor, self.UpgradeModifyTitleShadowColor, self.UpgradeModifyIconSprite)
    end
  end
  if ModifyChooseTypeTemp ~= ModifyChooseType.SpecificModify and ModifyChooseTypeTemp ~= ModifyChooseType.SpecificModifyReplace then
    self:UpdatePanel()
  end
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
end

function WBP_GenericModifyChoosePanel_C:ShowSpecificReplaceTips(bIsShow, ModifyId)
  if bIsShow then
    self.WBP_GenericModifyBagTips:InitSpecificModifyTips(ModifyId)
    UpdateVisibility(self.CanvasPanel_SpecificExchangeTips, true)
  else
    UpdateVisibility(self.CanvasPanel_SpecificExchangeTips, false)
  end
end

function WBP_GenericModifyChoosePanel_C:ShowSpecificModifyReplaceHover(bIsShow, ModifyId)
  if bIsShow then
    SetHitTestInvisible(self.WBP_GenericModifySpecificExchangeNew)
    UpdateVisibility(self.Icon_Arrow, true)
    UpdateVisibility(self.Txt_Exchange, true)
    self.WBP_GenericModifySpecificExchangeNew:InitGenericModifySpecificExchange(ModifyId)
    self:StopAnimation(self.Ani_replacement_out)
    self:PlayAnimation(self.Ani_replacement_in)
  else
    self.WBP_GenericModifySpecificExchangeNew:Hide()
    SetHitTestInvisible(self.WBP_GenericModifySpecificExchangeNew)
    self:StopAnimation(self.Ani_replacement_in)
    self:PlayAnimation(self.Ani_replacement_out)
  end
end

function WBP_GenericModifyChoosePanel_C:InitGenericModifyChoosePanelByPushPreview(PreviewModifyList)
  LogicGenericModify.bCanOperator = true
  self.ModifyChooseType = ModifyChooseType.DoubleGenericModifyUpgrade
  self.InteractComp = nil
  self.Target = nil
  self.IsInShop = false
  local PlayerPawn = self:GetOwningPlayerPawn()
  if PlayerPawn and PlayerPawn.GenericModifyComponent then
    self:RefreshNum()
    self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
    self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCount() > 0, true)
    self.InteractComp = PlayerPawn.GenericModifyComponent
  end
  UpdateVisibility(self.WBP_HUD_GenericModifyList, true)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, false)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, true, true)
  self.WBP_HUD_GenericModifyList:SelectClick()
  self.WBP_GenericModifyChooseItemList:UpdateModifyListByPushPreview(PreviewModifyList, self.HoverFunc, self)
  HideAllEffects(self)
  if PreviewModifyList.bIsUpgrade then
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
    UpdateVisibility(self.WBP_GenericModifyChoosePanel_Upgrade, false)
    self.WBP_GenericModifyChoosePanel_Upgrade:PlayAnimation(self.WBP_GenericModifyChoosePanel_Upgrade.ani_GenericModifyChoosePanel_in)
    self:InitTitle(self.UpgradeModifyTitle, self.UpgradeModifyTitleColor, self.UpgradeModifyTitleShadowColor, self.UpgradeModifyIconSprite)
  end
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
end

function WBP_GenericModifyChoosePanel_C:OnItemChanged(ArticleId, OldStack, NewStack)
  local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
  if RGGlobalSettings and UE.URGBlueprintLibrary.GetArticleIdConfigId(ArticleId) == RGGlobalSettings.SpecificModifyRefreshCostConfigId then
    self:UpdateSpecificModifyRefresh()
  end
  if self:IsSurvivalMode() then
    self:InitSurvivalModifyCount()
  end
end

function WBP_GenericModifyChoosePanel_C:UpdateSpecificModifyRefresh()
  if self.ModifyChooseType == ModifyChooseType.SpecificModify or self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
    local PlayerPawn = self:GetOwningPlayerPawn()
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if PlayerPawn and PlayerPawn.SpecificModifyComponent and RGGlobalSettings then
      local leftRefreshCount = self:GetLeftRefreshCount()
      local costId = RGGlobalSettings.SpecificModifyReplace_CompensateItemConfigId
      if self.ModifyChooseType == ModifyChooseType.SpecificModify then
        costId = RGGlobalSettings.SpecificModifyRefreshCostConfigId
      end
      local costEnough, bagCount, needCount = self:CheckRefreshCost()
      if leftRefreshCount <= 0 or false == costEnough then
        self.StateCtrl_BtnRefresh:ChangeStatus("CantRefresh")
      else
        self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
      end
      if costEnough then
        self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
      else
        self.StateCtrl_BtnRefreshCost:ChangeStatus("CantCost")
      end
      self.RGTextRefreshNum:SetText(leftRefreshCount)
      local result, row = GetRowData(DT.DT_Item, tostring(costId))
      if result then
        SetImageBrushBySoftObject(self.Img_CostIcon, row.SpriteIcon)
      end
      self.Txt_Cost:SetText(needCount)
      UpdateVisibility(self.CanvasPanelMoney, true)
      UpdateVisibility(self.BP_ButtonWithSoundRefresh, true, true)
    end
  end
end

function WBP_GenericModifyChoosePanel_C:InitTitle(Title, Color, ShadowColor, Sprite)
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

function WBP_GenericModifyChoosePanel_C:FinishInteractGenericModify()
  LogicGenericModify:FinishInteractGenericModify(self.Target)
end

function WBP_GenericModifyChoosePanel_C:UpdatePanel(PreviewModifyListParam)
  if PreviewModifyListParam then
    self.WBP_GenericModifyChooseItemList:UpdatePanel(PreviewModifyListParam, self.InteractComp, self.HoverFunc, self, true)
  else
    self.WBP_GenericModifyChooseItemList:UpdatePanel(self.InteractComp.PreviewGenericModifyAry, self.InteractComp, self.HoverFunc, self)
  end
  UpdateVisibility(self.URGImageMask, false)
  self:UpdateSpecificModifyRefresh()
end

function WBP_GenericModifyChoosePanel_C:PreviewSpecificModifyRefreshed(Result)
  UpdateVisibility(self.URGImageMask, false)
  if ResultToWaveId[Result] then
    ShowWaveWindow(ResultToWaveId[Result])
  end
end

function WBP_GenericModifyChoosePanel_C:UpdateModifyListByShop(PreviewModifyList, ShopNPC)
  self.ShopNPC = ShopNPC
  local PlayerPawn = self:GetOwningPlayerPawn()
  if PlayerPawn and PlayerPawn.GenericModifyComponent then
    self:RefreshNum()
    self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
    self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCount() > 0, true)
  end
  UpdateVisibility(self.WBP_HUD_GenericModifyList, true)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, false)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, true, true)
  self.WBP_HUD_GenericModifyList:SelectClick()
  self.WBP_GenericModifyChooseItemList:UpdateModifyListByShop(PreviewModifyList, self.HoverFunc, self)
  self:UpdateAbandonedInfo()
  HideAllEffects(self)
  if PreviewModifyList.NpcType == UE.ERGNpcType.NT_UpgradeModify then
    self.ModifyChooseType = ModifyChooseType.UpgradeModify
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
    UpdateVisibility(self.WBP_GenericModifyChoosePanel_Upgrade, true)
    self.WBP_GenericModifyChoosePanel_Upgrade:PlayAnimation(self.WBP_GenericModifyChoosePanel_Upgrade.ani_GenericModifyChoosePanel_in)
    self:InitTitle(self.ShopModifyTitle, self.UpgradeModifyTitleColor, self.UpgradeModifyTitleShadowColor, self.UpgradeModifyIconSprite)
  elseif PreviewModifyList.NpcType == UE.ERGNpcType.NT_RarityUpModify then
    self.ModifyChooseType = ModifyChooseType.RarityUpModify
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
    UpdateVisibility(self.WBP_GenericModifyChoosePanel_QualityUpgrades, true)
    self.WBP_GenericModifyChoosePanel_QualityUpgrades:PlayAnimation(self.WBP_GenericModifyChoosePanel_QualityUpgrades.ani_GenericModifyChoosePanel_in)
    self:InitTitle(self.ShopModifyTitle, self.UpgradeModifyTitleColor, self.UpgradeModifyTitleShadowColor, self.UpgradeModifyIconSprite)
  else
    self.ModifyChooseType = ModifyChooseType.GenericModify
    local GroupId = LogicGenericModify:GetGroupIDByFirstModify(PreviewModifyList)
    UpdateVisibility(self.CanvasPanelGroupName, true)
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local Result, GenericModifyGroupRow = DTSubsystem:GetGenericModifyGroupDataByName(GroupId, nil)
      if Result then
        self:InitTitle(GenericModifyGroupRow.Name, GenericModifyGroupRow.ChoosePanelColor, GenericModifyGroupRow.ChoosePanelShadowColor, GenericModifyGroupRow.ChoosePanelIcon)
      end
    end
    local Text = UE.URGBlueprintLibrary.TextFromStringTable("1051")
    self.RGTextDesc:SetText(Text)
    local GroupIdName = tostring(GroupId)
    self:ShowTitle(GroupIdName, self.bIsFromDialog)
  end
  print("Shop", PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCount(), self.ModifyChooseType, ModifyChooseType.GenericModify)
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
end

function WBP_GenericModifyChoosePanel_C:InitSurvivalModifyList(PreviewModifyData)
  local PlayerPawn = self:GetOwningPlayerPawn()
  self.IsInShop = false
  LogicGenericModify.bCanOperator = true
  if PlayerPawn and PlayerPawn.GenericModifyComponent then
    self:RefreshNum()
    self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
    self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
  end
  UpdateVisibility(self.WBP_HUD_GenericModifyList, true)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, false)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, true, true)
  self.WBP_HUD_GenericModifyList:SelectClick()
  self.WBP_GenericModifyChooseItemList:UpdateSurvivalModifyList(ModifyChooseType.SurvivalAddModify, PreviewModifyData.PreviewModifyList, self.HoverFunc, self)
  self:UpdateAbandonedInfo()
  HideAllEffects(self)
  self.ModifyChooseType = ModifyChooseType.SurvivalAddModify
  local GroupId = LogicGenericModify:GetSurvivalGroupIDByFirstModify(PreviewModifyData.PreviewModifyList)
  UpdateVisibility(self.CanvasPanelGroupName, true)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local Result, GenericModifyGroupRow = DTSubsystem:GetGenericModifyGroupDataByName(GroupId, nil)
    if Result then
      self:InitTitle(GenericModifyGroupRow.Name, GenericModifyGroupRow.ChoosePanelColor, GenericModifyGroupRow.ChoosePanelShadowColor, GenericModifyGroupRow.ChoosePanelIcon)
    end
  end
  local Text = UE.URGBlueprintLibrary.TextFromStringTable("1051")
  self.RGTextDesc:SetText(Text)
  local GroupIdName = tostring(GroupId)
  self:ShowTitle(GroupIdName, self.bIsFromDialog)
  UpdateVisibility(self.CanvasPanel_Invincible, false)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
  if bagComponent then
    bagComponent.PostItemChanged:Add(self, self.OnItemChanged)
  end
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
  self:InitSurvivalModifyCount()
  self.RGStateController_SurvivalModifyMode:ChangeStatus("PermissionSelect")
end

function WBP_GenericModifyChoosePanel_C:BattleLagacyModifyClose()
  UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.BattleLagacyCountDownHandle)
  if self.ModifyChooseType == ModifyChooseType.BattleLagacy then
    EventSystem.Invoke(EventDef.BattleLagacy.OnBattleLagacyModifyClose)
    if UE.RGUtil.IsUObjectValid(self.BattleLagacyConfirmWnd) then
      CloseWaveWindow(self.BattleLagacyConfirmWnd)
    end
    self.BattleLagacyConfirmWnd = nil
    LogicGenericModify:CloseGenericModifyChoosePanel(self.Target)
  end
end

function WBP_GenericModifyChoosePanel_C:InitGenericModifyChoosePanelByBattleLagacy(BattleLagacyIDs)
  LogicGenericModify.bCanOperator = true
  self:PlayAnimation(self.Ani_in)
  UpdateVisibility(self, false)
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      if UE.RGUtil.IsUObjectValid(self) then
        UpdateVisibility(self, true)
      end
    end
  })
  HideAllEffects(self)
  if self.RGStateControllerTitle then
    self.RGStateControllerTitle:ChangeStatus(EChoosePanelTitleStatus.BattleLagacy)
  end
  UpdateVisibility(self.WBP_InteractTipWidget, false)
  UpdateVisibility(self.WBP_HUD_GenericModifyList, false)
  UpdateVisibility(self.Txt_BattleLagacyCountDown, true)
  self.ModifyChooseType = ModifyChooseType.BattleLagacy
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, true, true)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.BattleLagacyCountDownHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.BattleLagacyCountDownHandle)
  end
  self.BattleLagacyCountDownTimer = 0
  local txtCountDown = UE.FTextFormat(self.BattleLagacyCountDownFmt, tostring(self.BattleLagacyCountDownTimer))
  self.Txt_BattleLagacyCountDown:SetText(txtCountDown)
  self.BattleLagacyCountDownHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      self.BattleLagacyCountDownTimer = self.BattleLagacyCountDownTimer + 1
      local countDown = math.max(self.BattleLagacyCountDown - self.BattleLagacyCountDownTimer, 0)
      local txt = UE.FTextFormat(self.BattleLagacyCountDownFmt, tostring(countDown))
      self.Txt_BattleLagacyCountDown:SetText(txt)
      if self.BattleLagacyCountDownTimer >= self.BattleLagacyCountDown then
        self:BattleLagacyModifyClose()
      end
    end
  }, 1, true)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
  end
  local delay = self.DelayShowModifyListBattleLagacy or 1.57
  self.DelayShowModfyListHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      self.WBP_GenericModifyChooseItemList:UpdatePanelByBattleLagacy(BattleLagacyIDs, self)
    end
  }, delay, false)
  UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
end

function WBP_GenericModifyChoosePanel_C:UpdateAbandonedInfo()
  if UE.RGUtil.IsUObjectValid(LogicShop.ShopNPC) then
    local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
    if UE.RGUtil.IsUObjectValid(ShopInteractComp) then
      local itemStack = ShopInteractComp.ItemIfAbandonSelectInPreviewModifyList
      local configId = itemStack.ConfigId
      local cashCost = 0
      if LogicShop.ItemList and LogicShop.ModifyInstanceId and LogicShop.ItemList[LogicShop.ModifyInstanceId] then
        local TargetInstanceInfo = LogicShop.ItemList[LogicShop.ModifyInstanceId]
        cashCost = TargetInstanceInfo.CashCost
      end
      local stack = math.floor((1 - ShopInteractComp.DeductionRatioIfAbandonSelect) * cashCost + 0.5)
      print("WBP_GenericModifyChoosePanel_C:UpdateAbandonedInfo", configId, stack)
      self.RGTextAbandoned:SetText(stack)
      local result, row = GetRowData(DT.DT_Item, tostring(configId))
      if result then
        SetImageBrushBySoftObject(self.URGImageAbandonedIcon, row.SpriteIcon)
      end
    end
    UpdateVisibility(self.CanvasPanelMoney, false)
    UpdateVisibility(self.CanvasPanelAbandoned, true)
  elseif self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if RGGlobalSettings then
      local CompensateItemConfigId, CompensateItemCount = self.InteractComp:GetAbandonRefundItems()
      self.RGTextAbandoned:SetText(CompensateItemCount)
      local result, row = GetRowData(DT.DT_Item, tostring(RGGlobalSettings.SpecificModifyReplace_CompensateItemConfigId))
      if result then
        SetImageBrushBySoftObject(self.URGImageAbandonedIcon, row.SpriteIcon)
      end
    end
    UpdateVisibility(self.CanvasPanelAbandoned, true)
  end
end

function WBP_GenericModifyChoosePanel_C:OnAbandonedClick()
  if self:IsAnimationPlaying(self.ani_GenericModifyChoosePanel_out) then
    print("WBP_GenericModifyChoosePanel_C", "OnAbandonedClick")
    return
  end
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveWindowManager then
    self.bCanShowBattleRoleInfo = false
    if self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
      local stack = 0
      local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
      if RGGlobalSettings then
        stack = RGGlobalSettings.SpecificModifyReplace_CompensateItemCount
      end
      WaveWindowManager:ShowWaveWindowWithDelegate(1217, {stack, "\n"}, nil, {
        self,
        function()
          local PC = self:GetOwningPlayer()
          LogicGenericModify:AbandonSpecificModify(PC, self.InteractComp, self.Target)
          self.bCanShowBattleRoleInfo = true
        end
      }, {
        self,
        function()
          self.bCanShowBattleRoleInfo = true
        end
      })
    else
      WaveWindowManager:ShowWaveWindowWithDelegate(1148, {}, nil, {
        self,
        function()
          if UE.RGUtil.IsUObjectValid(self) then
            LogicShop:ShopAbandonPreviewModifyList(self.ShopNPC)
            self.bCanShowBattleRoleInfo = true
          end
        end
      }, {
        self,
        function()
          if UE.RGUtil.IsUObjectValid(self) then
            self.bCanShowBattleRoleInfo = true
          end
        end
      })
    end
  end
end

function WBP_GenericModifyChoosePanel_C:OnRefreshClick()
  if not LogicGenericModify.bCanOperator then
    print("WBP_GenericModifyChoosePanel_C:OnRefreshClick LogicGenericModify.bCanOperator Is False")
    return
  end
  if self.IsInShop then
    local RGWaveWindowManagr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if not RGWaveWindowManagr then
      return
    end
    RGWaveWindowManagr:ShowWaveWindowWithDelegate(201004, {}, nil, {
      self,
      function()
        LogicShop:RefreshModifyList(self:GetOwningPlayer())
      end
    })
    return
  end
  local PC = self:GetOwningPlayer()
  if PC and PC.MiscHelper then
    if self.ModifyChooseType == ModifyChooseType.SpecificModify or self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
      if self:GetLeftRefreshCount() <= 0 then
        ShowWaveWindow(1169)
      elseif not self:CheckRefreshCost() then
        ShowWaveWindow(1170)
      else
        local RGWaveWindowManagr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
        if not RGWaveWindowManagr then
          return
        end
        RGWaveWindowManagr:ShowWaveWindowWithDelegate(201005, {}, nil, {
          self,
          function()
            UpdateVisibility(self.URGImageMask, true, true)
            PC.MiscHelper:RefreshSpecificModify(self.InteractComp)
          end
        })
      end
    elseif self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
      if self:GetLeftRefreshCount() <= 0 then
        ShowWaveWindow(1169)
      elseif not self:CheckRefreshCost() then
        ShowWaveWindow(1170)
      else
        LogicGenericModify:SurvivalRequestSpecificModifyEx(true)
      end
    else
      local PlayerPawn = self:GetOwningPlayerPawn()
      if PlayerPawn and PlayerPawn.GenericModifyComponent and PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCount() > 0 then
        local RGWaveWindowManagr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
        if not RGWaveWindowManagr then
          return
        end
        RGWaveWindowManagr:ShowWaveWindowWithDelegate(201004, {}, nil, {
          self,
          function()
            EventSystem.Invoke(EventDef.GenericModify.OnRefreshGenericModify)
            PC.MiscHelper:GenericModifyRefreshPreviewModifyList(self.Target.RGInteractComponent_GenericModify)
          end
        })
      else
        ShowWaveWindow(201003)
      end
    end
  end
end

function WBP_GenericModifyChoosePanel_C:CanExitPanel()
  if self.IsInShop then
    return false
  elseif self.ModifyChooseType == ModifyChooseType.DoubleGenericModifyUpgrade then
    return false
  else
    return true
  end
end

function WBP_GenericModifyChoosePanel_C:CheckNeedConfirmExit()
  if self.ModifyChooseType == ModifyChooseType.BattleLagacy then
    return true
  end
  return false
end

function WBP_GenericModifyChoosePanel_C:OnUpgradeModify(RGGenericModifyParam)
  if self.ModifyChooseType == ModifyChooseType.DoubleGenericModifyUpgrade then
    self:UpdateChoosePanel(RGGenericModifyParam, true)
  else
    self:UpdateChoosePanel(RGGenericModifyParam, false)
  end
end

function WBP_GenericModifyChoosePanel_C:CloseChoosePanelEx(ModifyId)
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
  print("LogicGenericModify: 1 UpdateChoosePanel" .. self.Object:GetVisibility())
  local GroupId
  if self.InteractComp then
    GroupId = self.InteractComp.GroupId
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
  end
  self.WBP_GenericModifyChooseItemList:FadeOut(ModifyId, GroupId)
  print("LogicGenericModify: 2 UpdateChoosePanel" .. self.Object:GetVisibility())
end

function WBP_GenericModifyChoosePanel_C:UpdateChoosePanel(RGGenericModifyParam, bIsHide)
  print("WBP_GenericModifyChoosePanel_C:UpdateChoosePanel", RGGenericModifyParam, self.IsInShop)
  local ModifyId = RGGenericModifyParam.ModifyId or self.ModifyId
  if self.IsInShop or bIsHide then
    self:CloseChoosePanelEx(ModifyId)
    return
  end
  if self.ModifyChooseType == ModifyChooseType.SurvivalAddModify or self.ModifyChooseType == ModifyChooseType.SurvivalUpgradeModify or self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
    self:CloseChoosePanelEx(ModifyId)
  end
end

function WBP_GenericModifyChoosePanel_C:SelectModifyId(ModifyId)
  print("WBP_GenericModifyChoosePanel_C:SelectModifyId", ModifyId, self.ModifyId)
  self.ModifyId = ModifyId
end

function WBP_GenericModifyChoosePanel_C:OnCancelChoosePanel(Target, Instigator)
  print("WBP_GenericModifyChoosePanel_C:OnCancelChoosePanel")
  if LogicGenericModify.IsFinishChooseModify then
    return
  end
  if Target ~= self.Target then
    return
  end
  print("WBP_GenericModifyChoosePanel_C:OnCancelChoosePanel CloseChoosePanel")
  self:CloseChoosePanel()
end

function WBP_GenericModifyChoosePanel_C:OnFinishChoosePanel(Target, Instigator)
  print("WBP_GenericModifyChoosePanel_C:OnFinishChoosePanel", self.IsInShop)
  if self.IsInShop then
    return
  end
  if Target ~= self.Target then
    print("WBP_GenericModifyChoosePanel_C:OnFinishChoosePanel Target Is not CurTarget")
    return
  end
  local TargetModifyChooseType = self.ModifyChooseType
  if self.ModifyChooseType == ModifyChooseType.GenericModify and self.IsDoubleGenericModify then
    TargetModifyChooseType = ModifyChooseType.DoubleGenericModify
  end
  local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[TargetModifyChooseType]
  OpenTime = OpenTime + 1
  LogicGenericModify.ChoosPanelOpenTimes[TargetModifyChooseType] = OpenTime
  LogicGenericModify.IsFinishChooseModify = true
  if self.ModifyId and self.ModifyId > 0 then
    print("WBP_GenericModifyChoosePanel_C:OnFinishChoosePanel ModifyId:", self.ModifyId)
    self:PlayAnimation(self.ani_GenericModifyChoosePanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    local GroupId
    if self.InteractComp then
      GroupId = self.InteractComp.GroupId
    end
    self.WBP_GenericModifyChooseItemList:FadeOut(self.ModifyId, GroupId)
  else
    print("WBP_GenericModifyChoosePanel_C:OnFinishChoosePanel CloseChoosePanel")
    self:CloseChoosePanel()
  end
end

function WBP_GenericModifyChoosePanel_C:OnFinishChooseBattleLagacy(CurBattleLagacyData)
  if CurBattleLagacyData.BattleLagacyType ~= EBattleLagacyType.GeneircModify then
    return
  end
  print("WBP_GenericModifyChoosePanel_C:OnFinishChooseBattleLagacy")
  if self.ModifyId and self.ModifyId > 0 then
    print("WBP_GenericModifyChoosePanel_C:OnFinishChooseBattleLagacy ModifyId:", self.ModifyId)
    self:PlayAnimation(self.ani_GenericModifyChoosePanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    local GroupId
    local result, row = GetRowData(DT.DT_GenericModify, tostring(self.ModifyId))
    if result then
      GroupId = row.GroupId
    end
    self.WBP_GenericModifyChooseItemList:SetItemCantSelect()
    self.WBP_GenericModifyChooseItemList:FadeOut(self.ModifyId, GroupId)
    self:StopAnimation(self.Ani_in)
    self:PlayAnimation(self.Ani_out)
  else
    LogicGenericModify:CloseGenericModifyChoosePanel(nil)
  end
end

function WBP_GenericModifyChoosePanel_C:OnSelectBattleLagacyFailed()
  if self.ModifyChooseType == ModifyChooseType.BattleLagacy then
    EventSystem.Invoke(EventDef.BattleLagacy.OnBattleLagacyModifyClose)
  end
  LogicGenericModify:CloseGenericModifyChoosePanel(nil)
end

function WBP_GenericModifyChoosePanel_C:UpdateSpecificChoosePanel(RGSpecificModifyParam)
  print("WBP_GenericModifyChoosePanel_C:UpdateSpecificChoosePanel", RGSpecificModifyParam, self.IsInShop)
  if self.IsInShop then
    self:PlayAnimation(self.ani_GenericModifyChoosePanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    local GroupId
    if self.InteractComp then
      GroupId = self.InteractComp.GroupId
    end
    self.WBP_GenericModifyChooseItemList:FadeOut(RGSpecificModifyParam.ModifyId, GroupId)
  end
  UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
end

function WBP_GenericModifyChoosePanel_C:OnAnimationFinished(Animation)
  if Animation == self.ani_GenericModifyChoosePanel_out then
    if self.ModifyChooseType == ModifyChooseType.BattleLagacy then
      EventSystem.Invoke(EventDef.BattleLagacy.OnBattleLagacyModifyClose)
    end
    print("LogicGenericModify:CloseGenericModifyChoosePanel" .. self.Object:GetVisibility())
    LogicGenericModify:CloseGenericModifyChoosePanel(self.Target)
  end
end

function WBP_GenericModifyChoosePanel_C:HoverFunc(Slot, bIsHover)
  self.WBP_HUD_GenericModifyList:HighLightModifyItem(Slot, bIsHover)
end

function WBP_GenericModifyChoosePanel_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_GenericModifyChoosePanel_C:UnfocusInput()
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
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Remove(self, self.OnCKeyEvent)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.ListenForEscInputAction)
  self.BP_ButtonWithSoundAbandoned.OnClicked:Remove(self, self.OnAbandonedClick)
end

function WBP_GenericModifyChoosePanel_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  self:SetFromDialog(false)
  self.ShopNPC = nil
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if self.ModifyChooseType == ModifyChooseType.SpecificModify then
    local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
    if bagComponent then
      bagComponent.PostItemChanged:Remove(self, self.OnItemChanged)
    end
  end
  self.WBP_GenericModifyChooseItemList:OnUnDisplay()
  UpdateVisibility(self.URGImageMask, false)
  UpdateVisibility(self.CanvasPanelAbandoned, false)
  if self.InteractComp and self.InteractComp.PreviewSpecificModifyRefreshed then
    self.InteractComp.PreviewSpecificModifyRefreshed:Remove(self, self.PreviewSpecificModifyRefreshed)
  end
  EventSystem.RemoveListener(EventDef.GenericModify.OnAddModify, WBP_GenericModifyChoosePanel_C.UpdateChoosePanel, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnRemoveModify, WBP_GenericModifyChoosePanel_C.UpdateChoosePanel, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnUpgradeModify, WBP_GenericModifyChoosePanel_C.OnUpgradeModify, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnFinishInteract, WBP_GenericModifyChoosePanel_C.OnFinishChoosePanel, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnCancelInteract, WBP_GenericModifyChoosePanel_C.OnCancelChoosePanel, self)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnTriggerCurrBattleLagacy, self, WBP_GenericModifyChoosePanel_C.OnFinishChooseBattleLagacy)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnSelectBattleLagacyFailed, self, WBP_GenericModifyChoosePanel_C.OnSelectBattleLagacyFailed)
  EventSystem.RemoveListener(EventDef.SpecificModify.OnAddModify, WBP_GenericModifyChoosePanel_C.UpdateSpecificChoosePanel, self)
  EventSystem.RemoveListener(EventDef.SpecificModify.OnRemoveModify, WBP_GenericModifyChoosePanel_C.UpdateSpecificChoosePanel, self)
  EventSystem.RemoveListenerNew(EventDef.SpecificModify.OnRefreshCountChange, self, WBP_GenericModifyChoosePanel_C.UpdateSpecificModifyRefresh)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.BattleLagacyCountDownHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.BattleLagacyCountDownHandle)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
  end
  self:Reset()
  self:StopAllAnimations()
  if LogicGenericModify.PushPreviewModifyList then
    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
      GameInstance,
      function()
        RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName, true)
        RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName):InitGenericModifyChoosePanelByPushPreview(LogicGenericModify.PushPreviewModifyList)
        LogicGenericModify.PushPreviewModifyList = nil
      end
    })
  end
  self.ModifyChooseType = ModifyChooseType.None
  if UE.RGUtil.IsUObjectValid(self.BattleLagacyConfirmWnd) then
    CloseWaveWindow(self.BattleLagacyConfirmWnd)
  end
end

function WBP_GenericModifyChoosePanel_C:OnClose()
  self.Overridden.OnClose(self)
  self:Reset()
end

function WBP_GenericModifyChoosePanel_C:Reset()
  if self.InteractComp then
    if self.InteractComp.OnPreviewGenericModifyRep then
      self.InteractComp.OnPreviewGenericModifyRep:Remove(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
    end
    if self.InteractComp.OnPreviewModifyListChanged then
      self.InteractComp.OnPreviewModifyListChanged:Remove(self, WBP_GenericModifyChoosePanel_C.UpdatePanel)
    end
  end
  self.ModifyId = nil
  self.InteractComp = nil
  self.Target = nil
end

function WBP_GenericModifyChoosePanel_C:GetLeftRefreshCount()
  if self.ModifyChooseType == ModifyChooseType.SpecificModify then
    local PlayerPawn = self:GetOwningPlayerPawn()
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if PlayerPawn and PlayerPawn.SpecificModifyComponent and RGGlobalSettings then
      local usedRefreshCount = PlayerPawn.SpecificModifyComponent.RefreshCount
      local maxRefreshCount = self.InteractComp:BP_GetMaxRefreshCount()
      local leftRefreshCount = maxRefreshCount - usedRefreshCount
      print("WBP_GenericModifyChoosePanel_C:GetLeftRefreshCount SpecificModify", usedRefreshCount, RGGlobalSettings.SpecificModifyRefreshCount, leftRefreshCount)
      return leftRefreshCount
    end
  elseif self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if self.InteractComp and self.InteractComp.ModifyReplaceCount and RGGlobalSettings then
      local usedRefreshCount = self.InteractComp.ModifyReplaceCount
      local maxRefreshCount = self.InteractComp:BP_GetMaxRefreshCount()
      local leftRefreshCount = maxRefreshCount - usedRefreshCount
      print("WBP_GenericModifyChoosePanel_C:GetLeftRefreshCount SpecificModifyReplace", usedRefreshCount, RGGlobalSettings.SpecificModifyReplace_RefreshCount, leftRefreshCount)
      return leftRefreshCount
    end
  elseif self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if RGGlobalSettings then
      local usedRefreshCount = LogicGenericModify:GetSurvivalSpecificModifyRefreshCount()
      local leftRefreshCount = RGGlobalSettings.SpecificModifyRefreshCount - usedRefreshCount
      print("WBP_GenericModifyChoosePanel_C:GetLeftRefreshCount SurvivalSpecificModify", usedRefreshCount, RGGlobalSettings.SpecificModifyRefreshCostCount, leftRefreshCount)
      return leftRefreshCount
    end
  end
  return 0
end

function WBP_GenericModifyChoosePanel_C:CheckRefreshCost()
  if self.ModifyChooseType == ModifyChooseType.SpecificModify then
    local PlayerPawn = self:GetOwningPlayerPawn()
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if PlayerPawn and PlayerPawn.SpecificModifyComponent and RGGlobalSettings then
      local costId, count = self.InteractComp:BP_GetRefreshCost()
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
      local itemStack = bagComponent:GetItemByConfigId(costId)
      local costEnough = count <= itemStack.Stack
      return costEnough, itemStack.Stack, count
    end
  elseif self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if RGGlobalSettings then
      local costId, count = self.InteractComp:BP_GetRefreshCost()
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
      local itemStack = bagComponent:GetItemByConfigId(costId)
      local costEnough = count <= itemStack.Stack
      return costEnough, itemStack.Stack, count
    end
  elseif self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
    local PlayerPawn = self:GetOwningPlayerPawn()
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if PlayerPawn and PlayerPawn.SpecificModifyComponent and RGGlobalSettings then
      local count = RGGlobalSettings.SpecificModifyRefreshCostCount
      local costId = RGGlobalSettings.SpecificModifyRefreshCostConfigId
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
      local itemStack = bagComponent:GetItemByConfigId(costId)
      local costEnough = count <= itemStack.Stack
      return costEnough, itemStack.Stack, count
    end
  end
  return false, 0, 0
end

function WBP_GenericModifyChoosePanel_C:UpdateHudListNav()
  self.WBP_HUD_GenericModifyList:InitFirstItemLeftNavTargetWidget(self.WBP_GenericModifyChooseItemList.WBP_GenericModifyChooseItem1)
end

function WBP_GenericModifyChoosePanel_C:ShowTitle(GroupId, bIsShowMove)
  self.StateCtrl_TitleEff:ChangeStatus(GroupId)
  local TitleEffName = "AutoLoad_TitleGroup_" .. GroupId
  if self[TitleEffName] then
    self[TitleEffName]:PlayAnimation("ani_GenericModifyChoosePanel_in")
    local DialogName = "WBP_GenericModifyDialog_Group_" .. GroupId
    if self[TitleEffName].ChildWidget and self[TitleEffName].ChildWidget[DialogName] then
      local DialogWidget = self[TitleEffName].ChildWidget[DialogName]
      if not bIsShowMove then
        DialogWidget:PlayAnimation(DialogWidget.Ani_GenericModifyChoose_in)
      end
      if bIsShowMove then
        DialogWidget:PlayAnimation(DialogWidget.Ani_move)
      end
    end
  end
end

function WBP_GenericModifyChoosePanel_C:Destruct()
  self:Reset()
  self:UnBindAttributeChanged()
end

function WBP_GenericModifyChoosePanel_C:BindOnHealthAttributeChanged(NewValue, OldValue)
  local bReduce = NewValue < OldValue
  if not bReduce then
    return
  end
  LogicGenericModify:CloseGenericModifyChoosePanel(self.Target)
end

function WBP_GenericModifyChoosePanel_C:InitSurvivalUpgradeModifyData(PreviewUpgradeModifyData)
  local PreviewModifyList = PreviewUpgradeModifyData.PreviewModifyList
  LogicGenericModify.bCanOperator = true
  self.IsInShop = false
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, false)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, true, true)
  UpdateVisibility(self.WBP_HUD_GenericModifyList, true)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  self.WBP_HUD_GenericModifyList:SelectClick()
  HideAllEffects(self)
  self.ModifyChooseType = ModifyChooseType.SurvivalUpgradeModify
  self:UpdateAbandonedInfo()
  self:RefreshNum()
  self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
  self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
  UpdateVisibility(self.WBP_GenericModifyChoosePanel_Upgrade, true)
  self.WBP_GenericModifyChoosePanel_Upgrade:PlayAnimation(self.WBP_GenericModifyChoosePanel_Upgrade.ani_GenericModifyChoosePanel_in)
  self:InitTitle(self.UpgradeModifyTitle, self.UpgradeModifyTitleColor, self.UpgradeModifyTitleShadowColor, self.UpgradeModifyIconSprite)
  local Text = UE.URGBlueprintLibrary.TextFromStringTable("1052")
  self.RGTextDesc:SetText(Text)
  UpdateVisibility(self.BP_ButtonWithSoundRefresh, false)
  UpdateVisibility(self.CanvasPanelMoney, false)
  local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[ModifyChooseType.SurvivalUpgradeModify]
  NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnUpgradeModifyPanelShow, OpenTime)
  local ModifyIdList = {}
  for i = 1, 3 do
    if i > PreviewModifyList:Length() then
      break
    end
    local ModifyId = PreviewModifyList:Get(i)
    table.insert(ModifyIdList, ModifyId)
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
  if bagComponent then
    bagComponent.PostItemChanged:Add(self, self.OnItemChanged)
  end
  self.WBP_GenericModifyChooseItemList:UpdatePanelNew(ModifyIdList, ModifyChooseType.SurvivalUpgradeModify, self.HoverFunc, self)
  UpdateVisibility(self.URGImageMask, false)
  self:UpdateSpecificModifyRefresh()
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
  self:InitSurvivalModifyCount()
  self.RGStateController_SurvivalModifyMode:ChangeStatus("PermissionLevelUp")
end

function WBP_GenericModifyChoosePanel_C:InitSurvivalSpecificModifyData(PreviewSpecificModifyData)
  LogicGenericModify.bCanOperator = true
  self.IsInShop = false
  UpdateVisibility(self.WBP_GenericModifyBg.URGImage_BattleLagacy, false)
  UpdateVisibility(self.WBP_GenericModifyBg.URGImageNormalBg, true, true)
  UpdateVisibility(self.WBP_HUD_GenericModifyList, true)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  self.WBP_HUD_GenericModifyList:SelectClick()
  HideAllEffects(self)
  self.ModifyChooseType = ModifyChooseType.SurvivalSpecificModify
  self:UpdateAbandonedInfo()
  self:RefreshNum()
  self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
  self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local bagComponent = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
  if bagComponent then
    bagComponent.PostItemChanged:Add(self, self.OnItemChanged)
  end
  UpdateVisibility(self.WBP_GenericModifyChoosePanel_Special, true)
  self.WBP_GenericModifyChoosePanel_Special:PlayAnimation(self.WBP_GenericModifyChoosePanel_Special.ani_GenericModifyChoosePanel_in)
  self:InitTitle(self.ModTitle, self.ModTitleColor, self.ModTitleShadowColor, self.ModIconSoftSprite)
  local Text = UE.URGBlueprintLibrary.TextFromStringTable("1053")
  self.RGTextDesc:SetText(Text)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayShowModfyListHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayShowModfyListHandle)
  end
  UpdateVisibility(self.WBP_GenericModifyChooseItemList, false)
  local PreviewModifyList = PreviewSpecificModifyData.PreviewModifyList
  local ModifyIdList = {}
  for i = 1, 3 do
    if i > PreviewModifyList:Length() then
      break
    end
    local ModifyId = PreviewModifyList:Get(i)
    table.insert(ModifyIdList, ModifyId)
  end
  local delay = self.DelayShowSpecific or 1.14
  self.DelayShowModfyListHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      self.WBP_GenericModifyChooseItemList:UpdatePanelNew(ModifyIdList, ModifyChooseType.SurvivalSpecificModify, self.HoverFunc, self)
      local OpenTime = LogicGenericModify.ChoosPanelOpenTimes[ModifyChooseType.SurvivalSpecificModify]
      NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnSpecificModifyPanelShow, OpenTime)
      self.WBP_GenericModifyChooseItemList.WBP_GenericModifyChooseItem1:SetFocus()
    end
  }, delay, false)
  UpdateVisibility(self.URGImageMask, false)
  self:UpdateSurvivalSpecificModifyRefresh()
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
  self:InitSurvivalModifyCount()
  UpdateVisibility(self.BP_ButtonWithSoundRefresh, true, true)
  self.RGStateController_SurvivalModifyMode:ChangeStatus("PotentialKey")
end

function WBP_GenericModifyChoosePanel_C:UpdateSurvivalSpecificModifyRefresh()
  if self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if RGGlobalSettings then
      local leftRefreshCount = self:GetLeftRefreshCount()
      local costId = RGGlobalSettings.SpecificModifyRefreshCostConfigId
      local costEnough, bagCount, needCount = self:CheckRefreshCost()
      if leftRefreshCount <= 0 or false == costEnough then
        self.StateCtrl_BtnRefresh:ChangeStatus("CantRefresh")
      else
        self.StateCtrl_BtnRefresh:ChangeStatus("Normal")
      end
      if costEnough then
        self.StateCtrl_BtnRefreshCost:ChangeStatus("Normal")
      else
        self.StateCtrl_BtnRefreshCost:ChangeStatus("CantCost")
      end
      self.RGTextRefreshNum:SetText(leftRefreshCount)
      local result, row = GetRowData(DT.DT_Item, tostring(costId))
      if result then
        SetImageBrushBySoftObject(self.Img_CostIcon, row.SpriteIcon)
      end
      self.Txt_Cost:SetText(needCount)
      UpdateVisibility(self.CanvasPanelMoney, true)
      UpdateVisibility(self.BP_ButtonWithSoundRefresh, true, true)
    end
  end
end

function WBP_GenericModifyChoosePanel_C:IsSurvivalMode()
  return LogicSurvivor.IsSurvivalMode()
end

function WBP_GenericModifyChoosePanel_C:InitSurvivalModifyCount()
  UpdateVisibility(self.CanvasPanel_SurvivalModify, self:IsSurvivalMode())
  local Count = 0
  if self.ModifyChooseType == ModifyChooseType.SurvivalAddModify then
    Count = LogicGenericModify:GetSurvivalModifyCount()
  elseif self.ModifyChooseType == ModifyChooseType.SurvivalUpgradeModify then
    Count = LogicGenericModify:GetSurvivalUpgradeModifyCount()
  elseif self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
    Count = LogicGenericModify:GetSurvivalSpecificModifyCount()
  end
  self.Txt_SurvivalModifyCount:SetText(Count)
end

return WBP_GenericModifyChoosePanel_C
