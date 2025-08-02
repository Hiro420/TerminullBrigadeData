local WBP_GenericModifyWaitPanel_C = UnLua.Class()
local ChoosePanelPath = "/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyChoosePanel.WBP_GenericModifyChoosePanel_C"

function WBP_GenericModifyWaitPanel_C:OnCreate()
  self.Overridden.OnCreate(self)
end

function WBP_GenericModifyWaitPanel_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
end

function WBP_GenericModifyWaitPanel_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      WBP_GenericModifyWaitPanel_C.WaitFinish
    }, 0.6, false)
  end
  EventSystem.AddListener(self, EventDef.GenericModify.OnCancelInteract, WBP_GenericModifyWaitPanel_C.OnCancelChoosePanel)
end

function WBP_GenericModifyWaitPanel_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
end

function WBP_GenericModifyWaitPanel_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  EventSystem.RemoveListener(EventDef.GenericModify.OnCancelInteract, WBP_GenericModifyWaitPanel_C.OnCancelChoosePanel, self)
  self:Reset()
end

function WBP_GenericModifyWaitPanel_C:OnCancelChoosePanel(Target, Instigator)
  print("WBP_GenericModifyWaitPanel_C:OnCancelChoosePanel", Target, self.Target)
  if Target ~= self.Target then
    return
  end
  self:Exit()
end

function WBP_GenericModifyWaitPanel_C:OnClose()
  self.Overridden.OnClose(self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnCancelInteract, WBP_GenericModifyWaitPanel_C.OnCancelChoosePanel, self)
  self:Reset()
end

function WBP_GenericModifyWaitPanel_C:InitGenericModifyWaitPanel(InteractComp, Target)
  self.InteractComp = InteractComp
  self.Target = Target
end

function WBP_GenericModifyWaitPanel_C:WaitFinish()
  local InteractComp = self.InteractComp
  local Target = self.Target
  self:Exit()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  if InteractComp:Cast(UE.URGInteractComponent_GenericModifySell:StaticClass()) then
    if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChooseSell_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChooseSell_C.UIName, true)
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChooseSell_C.UIName)
      if ChoosePanel and Target then
        ChoosePanel:InitGenericModifyChoosePanel(InteractComp, Target)
        LogicHUD:UpdateGenericModifyListShow(false)
      end
      LogicGenericModify.bCanOperator = true
      LogicGenericModify.bCanFinish = true
    end
    return
  end
  if -1 ~= InteractComp.DialogueId and not InteractComp.bDialoguePlayEnd and InteractComp:Cast(UE.URGInteractComponent_GenericModify:StaticClass()) then
    if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyDialog_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyDialog_C.UIName, true)
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyDialog_C.UIName)
      if ChoosePanel then
        ChoosePanel:OpenGenericModifyDialog(InteractComp, Target)
      end
    end
  elseif not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName, true)
    local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if ChoosePanel and Target then
      ChoosePanel:InitGenericModifyChoosePanel(InteractComp, Target)
      LogicHUD:UpdateGenericModifyListShow(false)
    end
    LogicGenericModify.bCanOperator = true
    LogicGenericModify.bCanFinish = true
  end
end

function WBP_GenericModifyWaitPanel_C:Reset()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  self.InteractComp = nil
  self.Target = nil
end

function WBP_GenericModifyWaitPanel_C:Destruct()
  self.Overridden.Destruct(self)
  self:Reset()
end

return WBP_GenericModifyWaitPanel_C
