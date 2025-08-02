local WBP_ItemPanel_C = UnLua.Class()

function WBP_ItemPanel_C:PreConstruct(IsDesignTime)
  self.Panels:AddUnique(self.WBP_AccessoryPanel)
  self.Panels:AddUnique(self.WBP_WeaponPanel)
  self.Panels:AddUnique(self.WBP_ShieldPanel)
  self.WBP_AccessoryPanel.ItemPanel = self
  self.WBP_WeaponPanel.ItemPanel = self
  self.WBP_ShieldPanel.ItemPanel = self
end

function WBP_ItemPanel_C:Construct()
  self:OnOpen()
  self.AccessoryBox.OnClicked:Add(self, WBP_ItemPanel_C.OnClicked_AccessoryBox)
  self.WeaponBox.OnClicked:Add(self, WBP_ItemPanel_C.OnClicked_WeaponBox)
  self.ShieldBox.OnClicked:Add(self, WBP_ItemPanel_C.OnClicked_ShieldBox)
end

function WBP_ItemPanel_C:SwitchPanel(ParentClass_BasePanel)
  local length = self.Panels:Length()
  local tempElemnt
  for i = 1, length do
    tempElemnt = self.Panels:Get(i)
    if tempElemnt ~= ParentClass_BasePanel then
      tempElemnt:SetVisibility(UE.ESlateVisibility.Collapsed)
      tempElemnt:OnClosePanel()
    end
  end
  ParentClass_BasePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.CurrentPanel = ParentClass_BasePanel
  ParentClass_BasePanel:OnLoadPanel()
  ParentClass_BasePanel:OnOpenPanel()
  ParentClass_BasePanel.bIsFocusable = true
end

function WBP_ItemPanel_C:ShowMessage(Message_Text)
  self.WBP_MessageBox:Show(Message_Text)
end

function WBP_ItemPanel_C:HideMessage()
  self.WBP_MessageBox:Hide()
end

function WBP_ItemPanel_C:OnClicked_AccessoryBox(InButton)
  self:SwitchPanel(self.WBP_AccessoryPanel)
end

function WBP_ItemPanel_C:OnClicked_WeaponBox(InButton)
  self:SwitchPanel(self.WBP_WeaponPanel)
end

function WBP_ItemPanel_C:OnClicked_ShieldBox(InButton)
  self:SwitchPanel(self.WBP_ShieldPanel)
end

function WBP_ItemPanel_C:Show(bSelfHitTestInvisible)
  self.Overridden.Show(self, bSelfHitTestInvisible)
  self:OnOpen()
  local InputHandle = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGCharacterInputHandle.StaticClass())
  InputHandle:SetMoveInputIgnored(true)
  InputHandle:SetLookInputIgnored(true)
  InputHandle:SetInputIgnored(UE.ERGAbilityInputID.Jump, true)
end

function WBP_ItemPanel_C:Hide(bCollapsed, bActivate)
  self.Overridden.Show(self, bCollapsed, bActivate)
  self:OnClose()
  local InputHandle = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGCharacterInputHandle.StaticClass())
  InputHandle:SetMoveInputIgnored(false)
  InputHandle:SetLookInputIgnored(false)
  InputHandle:SetInputIgnored(UE.ERGAbilityInputID.Jump, false)
end

function WBP_ItemPanel_C:OnOpen()
  self:SwitchPanel(self.WBP_AccessoryPanel)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_ItemPanel_C:OnClose()
  self:RecoverDisplayCamera()
end

return WBP_ItemPanel_C
