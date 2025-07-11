local WBP_MarkUIInteractTip_Refresh_C = UnLua.Class()
function WBP_MarkUIInteractTip_Refresh_C:Construct()
  self:InitInfo()
  if self.CanInteract then
    self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
    self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
    self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  end
  EventSystem.AddListener(self, EventDef.Interact.OnOptimalTargetChanged, WBP_MarkUIInteractTip_Refresh_C.OnOptimalTargetChanged)
end
function WBP_MarkUIInteractTip_Refresh_C:OnOptimalTargetChanged(Target)
  if self.TargetActor then
    if Target ~= self.TargetActor then
      StopListeningForInputAction(self, "RefreshNPC", UE.EInputEvent.IE_Pressed)
    else
      local PlayerPawn = self:GetOwningPlayerPawn()
      if (PlayerPawn.GenericModifyComponent:GetGroupIdRefreshCount() > 0 or PlayerPawn.GenericModifyComponent.GroupIdRefreshCountMax > 0 or PlayerPawn.GenericModifyComponent:CanGenericModifyRefreshByCoin()) and not IsListeningForInputAction(self, "RefreshNPC") then
        ListenForInputAction("RefreshNPC", UE.EInputEvent.IE_Pressed, false, {
          self,
          WBP_MarkUIInteractTip_Refresh_C.BindRefreshNPC
        })
      end
    end
  end
end
function WBP_MarkUIInteractTip_Refresh_C:BindOnMainButtonClicked()
  self.OnMainButtonClicked:Broadcast()
end
function WBP_MarkUIInteractTip_Refresh_C:BindOnMainButtonHovered()
  self.WBP_CustomKeyName:PlayHoverOrUnhoverAnim(true)
end
function WBP_MarkUIInteractTip_Refresh_C:BindOnMainButtonUnhovered()
  self.WBP_CustomKeyName:PlayHoverOrUnhoverAnim(false)
end
function WBP_MarkUIInteractTip_Refresh_C:SetWidgetConfig(IsNeedProgress, KeyRowName, KeyDesc, IsNeedShowDescBottom)
  self.IsNeedProgress = IsNeedProgress
  self.KeyRowName = KeyRowName
  self.KeyDesc = KeyDesc
  self.KeyIcon = nil
  self.IsShowDescBottom = IsNeedShowDescBottom
  self:InitInfo()
  self:SetWidgetStyle()
end
function WBP_MarkUIInteractTip_Refresh_C:BindRefreshNPC()
  if self.TargetActor then
    local PC = self:GetOwningPlayer()
    local PlayerPawn = self:GetOwningPlayerPawn()
    if not PlayerPawn then
      return
    end
    if not PlayerPawn.GenericModifyComponent then
      return
    end
    if PlayerPawn.GenericModifyComponent:GetGroupIdRefreshCount() <= 0 and not PlayerPawn.GenericModifyComponent:CanGenericModifyRefreshByCoin() then
      ShowWaveWindow(201002)
      return
    end
    SetInputIgnore(PlayerPawn, true)
    local PromptId = 201006
    local PromptStack = 1
    if PlayerPawn.GenericModifyComponent:GetGroupIdRefreshCount() <= 0 and PlayerPawn.GenericModifyComponent:CanGenericModifyRefreshByCoin() then
      PromptId = 201008
      PromptStack = PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCoin()
    end
    ShowWaveWindowWithDelegate(PromptId, {PromptStack}, function()
      if PC and PC.MiscHelper then
        PC.MiscHelper:GenericModifyRefreshGroupId(self.TargetActor.RGInteractComponent_GenericModify)
      end
      SetInputIgnore(PlayerPawn, false)
    end, function()
      SetInputIgnore(PlayerPawn, false)
    end)
  else
    print("RefreshNPC TargetActor Is Null")
  end
end
function WBP_MarkUIInteractTip_Refresh_C:SetInteractActor(TargetActor)
  print("WBP_MarkUIInteractTip_Refresh_C:SetInteractActor")
  self.TargetActor = TargetActor
  local PlayerPawn = self:GetOwningPlayerPawn()
  if PlayerPawn and PlayerPawn.GenericModifyComponent then
    PlayerPawn.GenericModifyComponent.OnGenericModifyGroupIdRefreshCountChange:Add(self, WBP_MarkUIInteractTip_Refresh_C.RefreshNum)
  end
  self:RefreshNum(true)
end
function WBP_MarkUIInteractTip_Refresh_C:RefreshNum(...)
  if not (...) then
    PlaySound3DEffect(10032, self.TargetActor)
  end
  UpdateVisibility(self.Btn_Main_1, true, true)
  local PlayerPawn = self:GetOwningPlayerPawn()
  if PlayerPawn.GenericModifyComponent:GetGroupIdRefreshCount() > 0 or PlayerPawn.GenericModifyComponent.GroupIdRefreshCountMax > 0 or PlayerPawn.GenericModifyComponent:CanGenericModifyRefreshByCoin() then
    UpdateVisibility(self.Btn_Main_1, true, true)
    if not IsListeningForInputAction(self, "RefreshNPC") then
      ListenForInputAction("RefreshNPC", UE.EInputEvent.IE_Pressed, false, {
        self,
        WBP_MarkUIInteractTip_Refresh_C.BindRefreshNPC
      })
    end
  else
    UpdateVisibility(self.Btn_Main_1, false, false)
    StopListeningForInputAction(self, "RefreshNPC", UE.EInputEvent.IE_Pressed)
  end
  local RefreshText = NSLOCTEXT("WBP_MarkUIInteractTip_Refresh_C", "Refresh", "\229\136\183\230\150\176({0}/{1})")
  self.Txt_Desc_1:SetText(UE.FTextFormat(RefreshText(), PlayerPawn.GenericModifyComponent:GetGroupIdRefreshCount(), PlayerPawn.GenericModifyComponent.GroupIdRefreshCountMax))
  UpdateVisibility(self.DescPanel_1, true, true)
  UpdateVisibility(self.DescPanel_2, false, false)
  if PlayerPawn.GenericModifyComponent:GetGroupIdRefreshCount() <= 0 and PlayerPawn.GenericModifyComponent:CanGenericModifyRefreshByCoin() then
    self.Txt_Desc_2:SetText(tostring(UE.FTextFormat(self.TransferInteractTip, PlayerPawn.GenericModifyComponent:GetGenericModifyRefreshCoin())))
    UpdateVisibility(self.DescPanel_2, true, true)
    UpdateVisibility(self.DescPanel_1, false, false)
  end
end
function WBP_MarkUIInteractTip_Refresh_C:InitInfo()
  if self.IsNeedProgress then
    self:UpdateProgress(0.0)
    self.Img_Progress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.WBP_CustomKeyName:SetCustomKeyConfig(self.KeyRowName, self.KeyIcon)
  self.Txt_Desc:SetText(self.KeyDesc)
  if UE.UKismetTextLibrary.TextIsEmpty(self.KeyDesc) then
    self.DescPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.DescPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self.IsShowDescBottom then
      self.Img_DescBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Img_DescBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end
function WBP_MarkUIInteractTip_Refresh_C:UpdateProgress(ProgressParam)
  local Mat = self.Img_Progress:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue("Percent", ProgressParam)
  end
end
function WBP_MarkUIInteractTip_Refresh_C:UpdateKeyDesc(Desc)
  self.KeyDesc = Desc
  self.Txt_Desc:SetText(self.KeyDesc)
end
function WBP_MarkUIInteractTip_Refresh_C:PlayInAnimation()
  if self:IsAnimationPlaying(self.Ani_out) then
    self.IsInitiativeStop = true
    self:StopAnimation(self.Ani_out)
  end
  self:PlayAnimationForward(self.Ani_in)
end
function WBP_MarkUIInteractTip_Refresh_C:PlayOutAnimation(AnimationFinishedEvent)
  self:PlayAnimationForward(self.Ani_out)
  self.OutAnimationFinishedEvent = AnimationFinishedEvent
  StopListeningForInputAction(self, "RefreshNPC", UE.EInputEvent.IE_Pressed)
  local PlayerPawn = self:GetOwningPlayerPawn()
  if PlayerPawn and PlayerPawn.GenericModifyComponent then
    PlayerPawn.GenericModifyComponent.OnGenericModifyGroupIdRefreshCountChange:Remove(self, WBP_MarkUIInteractTip_Refresh_C.RefreshNum)
  end
end
function WBP_MarkUIInteractTip_Refresh_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_Out then
    if self.IsInitiativeStop then
      self.IsInitiativeStop = false
    else
      self.OutAnimationFinishedEvent[2](self.OutAnimationFinishedEvent[1])
    end
  end
end
return WBP_MarkUIInteractTip_Refresh_C
