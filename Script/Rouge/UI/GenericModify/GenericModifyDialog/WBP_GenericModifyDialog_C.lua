local WBP_GenericModifyDialog_C = UnLua.Class()
function WBP_GenericModifyDialog_C:Construct()
  self.Btn_NextPage.OnClicked:Add(self, function()
    self:NextPage(self.Index + 1)
  end)
end
function WBP_GenericModifyDialog_C:InitGenericModifyDialog()
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  self.Index = 1
end
function WBP_GenericModifyDialog_C:UnDisplay()
  self.Overridden.UnDisplay(self)
  self.bFromModifyPack = false
end
function WBP_GenericModifyDialog_C:OpenGenericModifyDialogByPack(DialogueId, bDebug)
  self.bFromModifyPack = true
  self.bDebug = bDebug
  self.DialogueId = DialogueId
  self:PlayAnimation(self.anim_in)
  self:InitGenericModifyDialog()
  self.WBP_GenericModifyDialog_Content:PlayAnimation(self.WBP_GenericModifyDialog_Content.anim_in)
  local r, v = GetRowData(DT.DT_GenericModifyDialogueItem, DialogueId)
  if not r then
    return
  end
  self:SetUserFocus(self:GetOwningPlayer())
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self)
  self.DialogList = v.DialogueList
  UpdateVisibility(self.WBP_InteractTipWidget, false)
  if v.CloseTime > 0 then
    if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
      self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        WBP_GenericModifyDialog_C.CloseTimer
      }, v.CloseTime, false)
    end
  else
    self:CloseTimer()
  end
  self:NextPage(1)
end
function WBP_GenericModifyDialog_C:OpenGenericModifyDialog(InteractComp, Target)
  self.bFromModifyPack = false
  self:PlayAnimation(self.anim_in)
  self:InitGenericModifyDialog()
  self.InteractComp = InteractComp
  self.Target = Target
  self.DialogueId = InteractComp.DialogueId
  print("WBP_GenericModifyDialog_C", self.DialogueId, self.InteractComp)
  if not self.InteractComp then
    return
  end
  UpdateVisibility(self, 0 ~= self.DialogueId)
  if 0 == self.DialogueId then
    InteractComp.OnPreviewGenericModifyRep:Add(self, WBP_GenericModifyDialog_C.UpdatePanel)
  end
  self.WBP_GenericModifyDialog_Content:PlayAnimation(self.WBP_GenericModifyDialog_Content.anim_in)
  local r, v = GetRowData(DT.DT_GenericModifyDialogueItem, InteractComp.DialogueId)
  if not r then
    self:CloseTimer()
    print("WBP_GenericModifyDialog_C DT_GenericModifyDialogueItem Nil")
    return
  end
  self:SetUserFocus(self:GetOwningPlayer())
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self)
  self.DialogList = v.DialogueList
  UpdateVisibility(self.WBP_InteractTipWidget, false)
  if v.CloseTime > 0 then
    if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
      self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        WBP_GenericModifyDialog_C.CloseTimer
      }, v.CloseTime, false)
    end
  else
    self:CloseTimer()
  end
  self:NextPage(1)
end
function WBP_GenericModifyDialog_C:UpdatePanel(PreviewModifyListParam)
  self:OpenGenericModifyDialog(self.InteractComp, self.Target)
end
function WBP_GenericModifyDialog_C:CloseGenericModifyDialog()
  local bFromModifyPack = self.bFromModifyPack
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.CloseGenericModifyDialog, "JumpAction")
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  local PC = self:GetOwningPlayer()
  if PC and PC.MiscHelper then
    PC.MiscHelper:EndGenericModifyDialogue(self.InteractComp)
  end
  RGUIMgr:HideUI(UIConfig.WBP_GenericModifyDialog_C.UIName)
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  if self.InteractComp then
    self.InteractComp.OnPreviewGenericModifyRep:Remove(self, WBP_GenericModifyDialog_C.UpdatePanel)
  end
  if self.bDebug then
    return
  end
  if bFromModifyPack then
    if not RGUIMgr:IsShown(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName, true)
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName)
      if ChoosePanel then
        ChoosePanel:SetFromDialog(true)
        ChoosePanel:ShowTitle()
        LogicHUD:UpdateGenericModifyListShow(false)
      end
      LogicGenericModify.bCanOperator = true
      LogicGenericModify.bCanFinish = true
    else
      print("WBP_GenericModifyDialog_C:CloseGenericModifyDialog Failed")
    end
  elseif not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName, true)
    local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if ChoosePanel and self.Target then
      ChoosePanel:SetFromDialog(true)
      ChoosePanel:InitGenericModifyChoosePanel(self.InteractComp, self.Target)
      LogicHUD:UpdateGenericModifyListShow(false)
    end
    LogicGenericModify.bCanOperator = true
    LogicGenericModify.bCanFinish = true
  else
    print("WBP_GenericModifyWaitPanel_C:WaitFinish Failed")
  end
end
function WBP_GenericModifyDialog_C:NextPage(Index)
  local r, v = GetRowData(DT.DT_GenericModifyDialogueItem, self.DialogueId)
  if not r then
    return
  end
  local DialogList = v.DialogueList
  if not DialogList or Index > DialogList:Length() then
    self:CloseGenericModifyDialog()
    self.WBP_GenericModifyDialog_Content:StopSound()
    return
  end
  local DialogContent = DialogList:Get(Index)
  self.Index = Index
  local RGMovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMovieSubSystem:StaticClass())
  local MediaSrc = RGMovieSubsystem:GetMediaSource(DialogContent.MovieId)
  if nil ~= MediaSrc then
    self.MediaPlayer:SetLooping(true)
    self.MediaPlayer:OpenSource(MediaSrc)
    self.MediaPlayer:Play()
  end
  self.WBP_GenericModifyDialog_Content:SetContent(DialogContent)
  local GroupId = DialogContent.MovieId
  if GroupId then
    local GroupIdName = tostring(GroupId)
    self.StateCtrl_Dialog:ChangeStatus(GroupIdName)
    local dialogName = "AutoLoad_GenericModifyDialog_Group_" .. GroupIdName
    if self[dialogName] then
      self[dialogName]:PlayAnimation("Ani_in")
    end
  end
end
function WBP_GenericModifyDialog_C:CloseTimer()
  UpdateVisibility(self.WBP_InteractTipWidget, true, true)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.CloseGenericModifyDialog, "JumpAction")
end
return WBP_GenericModifyDialog_C
