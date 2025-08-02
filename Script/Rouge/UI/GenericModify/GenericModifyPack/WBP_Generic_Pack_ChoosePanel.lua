local WBP_Generic_Pack_ChoosePanel = UnLua.Class()

function WBP_Generic_Pack_ChoosePanel:OnCreate()
  self.Overridden.OnCreate(self)
  self.EscActionName = "PauseGame"
end

function WBP_Generic_Pack_ChoosePanel:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  if not IsListeningForInputAction(self, self.EscActionName) then
    ListenForInputAction(self.EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_Generic_Pack_ChoosePanel.ListenForEscInputAction
    })
  end
  self.BP_ButtonWithSoundRefresh.OnClicked:Add(self, self.OnRefreshClick)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.ListenForEscInputAction)
  self:UpdateHudListNav()
end

function WBP_Generic_Pack_ChoosePanel:OnDisplay()
  self.Overridden.OnDisplay(self)
  LogicGenericModify.bCanOperator = true
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
    if GenericPackComp then
      GenericPackComp.InteractFinishDelegate:Remove(self, WBP_Generic_Pack_ChoosePanel.FinishInteractGenericModify)
      GenericPackComp.InteractFinishDelegate:Add(self, WBP_Generic_Pack_ChoosePanel.FinishInteractGenericModify)
    end
  end
  self:ComInitGeneric()
  self.bCanShowBattleRoleInfo = true
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self.WBP_InteractTipWidget, false)
  else
    UpdateVisibility(self.WBP_InteractTipWidget, true)
  end
  self:InitGenericModifyPackChoosePanel()
end

function WBP_Generic_Pack_ChoosePanel:ComInitGeneric()
  self:SetFromDialog(false)
end

function WBP_Generic_Pack_ChoosePanel:CloseChoosePanel()
  LogicGenericModify:GiveUpGenericPack()
end

function WBP_Generic_Pack_ChoosePanel:OnRefreshClick()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
  if not GenericPackComp then
    return nil
  end
  if 0 == GenericPackComp.PreviewModifyData.RefreshCount then
    ShowWaveWindow(1066)
    return nil
  end
  LogicGenericModify:RefreshGenericPack()
end

function WBP_Generic_Pack_ChoosePanel:ListenForEscInputAction()
  if self:IsAnimationPlaying(self.ani_GenericModifyChoosePanel_out) then
    print("WBP_Generic_Pack_ChoosePanel:ListenForEscInputAction ani_GenericModifyChoosePanel_out is playing")
    return
  end
  self.CommonMsg = ShowWaveWindowWithDelegate(1303, {}, {
    self,
    function()
      if UE.RGUtil.IsUObjectValid(self) then
        self:CloseChoosePanel()
      end
    end
  })
end

function WBP_Generic_Pack_ChoosePanel:SetFromDialog(bIsFromDialog)
  self.bIsFromDialog = bIsFromDialog
end

function WBP_Generic_Pack_ChoosePanel:InitGenericModifyPackChoosePanel()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
  if not GenericPackComp then
    return nil
  end
  local modifyLuaList = GenericPackComp.PreviewModifyData.PreviewModifyList:ToTable()
  for i, v in ipairs(modifyLuaList) do
    local itemName = "WBP_GenericModify_Pack_ChooseItem_" .. i
    if self[itemName] then
      self[itemName]:InitGenericModifyPackChooseItem(v, i, nil, self)
    end
  end
  local RefreshCount = GenericPackComp.PreviewModifyData.RefreshCount
  if RefreshCount > 0 then
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, true, true)
    UpdateVisibility(self.RefreshNum, true)
    self.RGTextRefreshNum:SetText(RefreshCount)
  elseif -1 == RefreshCount then
    UpdateVisibility(self.BP_ButtonWithSoundRefresh, true, true)
    UpdateVisibility(self.RefreshNum, false)
  else
    UpdateVisibility(self.RefreshNum, false)
  end
  UpdateVisibility(self.WBP_HUD_GenericModifyList, true)
  self.WBP_HUD_GenericModifyList:SelectClick()
  self:PlayAnimation(self.ani_GenericModifyChoosePanel_in)
end

function WBP_Generic_Pack_ChoosePanel:InitTitle(Title, Color, ShadowColor, Sprite)
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

function WBP_Generic_Pack_ChoosePanel:FinishInteractGenericModify()
  LogicGenericModify:FinishInteractGenericModify(self.Target)
end

function WBP_Generic_Pack_ChoosePanel:OnAbandonedClick()
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
          LogicShop:ShopAbandonPreviewModifyList()
          self.bCanShowBattleRoleInfo = true
        end
      }, {
        self,
        function()
          self.bCanShowBattleRoleInfo = true
        end
      })
    end
  end
end

function WBP_Generic_Pack_ChoosePanel:SelectModifyIdx(Idx)
  print("WBP_Generic_Pack_ChoosePanel:SelectModifyIdx", Idx, self.Idx)
  if not self.Idx then
    self.Idx = Idx
  end
end

function WBP_Generic_Pack_ChoosePanel:HoverItem(ModifyId, bIsHover)
  local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if result then
    local Slot = row.Slot
    self.WBP_HUD_GenericModifyList:HighLightModifyItem(Slot, bIsHover)
  else
    self.WBP_HUD_GenericModifyList:HighLightModifyItem(-1, false)
  end
end

function WBP_Generic_Pack_ChoosePanel:FinishInteractGenericModify()
  print("WBP_Generic_Pack_ChoosePanel:FinishInteractGenericModify", self.IsInShop)
  if self.Idx and self.Idx > 0 then
    self:PlayAnimation(self.ani_GenericModifyChoosePanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    for i = 1, 3 do
      local ItemName = "WBP_GenericModify_Pack_ChooseItem_" .. i
      if self[ItemName] then
        self[ItemName]:FadeOut(self.Idx)
      end
    end
  else
    print("WBP_Generic_Pack_ChoosePanel:FinishInteractGenericModify CloseChoosePanel")
    LogicGenericModify:CloseGenericPackChoosePanel()
  end
end

function WBP_Generic_Pack_ChoosePanel:HoverFunc(Slot, bIsHover)
  self.WBP_HUD_GenericModifyList:HighLightModifyItem(Slot, bIsHover)
end

function WBP_Generic_Pack_ChoosePanel:Hide()
  UpdateVisibility(self, false)
end

function WBP_Generic_Pack_ChoosePanel:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  LogicGenericModify.bCanOperator = true
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  self:PopInputAction()
  self.BP_ButtonWithSoundRefresh.OnClicked:Remove(self, self.OnRefreshClick)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.ListenForEscInputAction)
end

function WBP_Generic_Pack_ChoosePanel:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  self:SetFromDialog(false)
  if UE.RGUtil.IsUObjectValid(self.CommonMsg) then
    CloseWaveWindow(self.CommonMsg)
    self.CommonMsg = nil
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
    if GenericPackComp then
      GenericPackComp.InteractFinishDelegate:Remove(self, WBP_Generic_Pack_ChoosePanel.FinishInteractGenericModify)
    end
  end
  self:Reset()
  self:StopAllAnimations()
  self.ModifyChooseType = ModifyChooseType.None
end

function WBP_Generic_Pack_ChoosePanel:OnClose()
  self.Overridden.OnClose(self)
  self:Reset()
end

function WBP_Generic_Pack_ChoosePanel:Reset()
  self.Idx = -1
end

function WBP_Generic_Pack_ChoosePanel:ShowTitle()
  UpdateVisibility(self.AutoLoad_TitleGroup_0, true)
  self.AutoLoad_TitleGroup_0:PlayAnimation("ani_GenericModifyChoosePanel_in")
  local dialogInst = self.AutoLoad_TitleGroup_0.ChildWidget.WBP_GenericModifyDialog_Group_999
  if self.bIsFromDialog then
    dialogInst:PlayAnimation(dialogInst.Ani_move)
  else
    dialogInst:PlayAnimation(dialogInst.Ani_GenericModifyChoose_in)
  end
end

function WBP_Generic_Pack_ChoosePanel:OnAnimationFinished(Animation)
  if Animation == self.ani_GenericModifyChoosePanel_out then
    print("LogicGenericModify:CloseGenericPackChoosePanel")
    LogicGenericModify:CloseGenericPackChoosePanel()
  end
end

function WBP_Generic_Pack_ChoosePanel:UpdateHudListNav()
end

function WBP_Generic_Pack_ChoosePanel:ChooseItem_Nav_Down()
  return self.WBP_InteractTipWidgetEsc
end

function WBP_Generic_Pack_ChoosePanel:Destruct()
  self:Reset()
end

return WBP_Generic_Pack_ChoosePanel
