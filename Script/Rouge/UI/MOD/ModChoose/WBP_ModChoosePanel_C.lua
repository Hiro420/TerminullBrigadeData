local WBP_ModChoosePanel_C = UnLua.Class()
function WBP_ModChoosePanel_C:Construct()
  self.bModChoose = false
  self.modComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass())
  self:BindOnMODResultDelegate(true)
  self.TabKeyEvent = "TabKeyEvent"
  self.CKeyEvent = "CKeyEvent"
  self.EscapeKeyEvent = "EscapeKeyEvent"
  self.LocalUserId = self:GetOwningPlayer().PlayerState:GetUserId()
end
function WBP_ModChoosePanel_C:Destruct()
  self:BindOnMODResultDelegate(false)
  self.modComponent = nil
end
function WBP_ModChoosePanel_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  if not IsListeningForInputAction(self, self.TabKeyEvent) then
    ListenForInputAction(self.TabKeyEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_ModChoosePanel_C.OnTabKeyEvent
    })
  end
  if not IsListeningForInputAction(self, self.CKeyEvent) then
    ListenForInputAction(self.CKeyEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_ModChoosePanel_C.OnCKeyEvent
    })
  end
  if not IsListeningForInputAction(self, self.EscapeKeyEvent) then
    ListenForInputAction(self.EscapeKeyEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_ModChoosePanel_C.OnEscapeKeyEvent
    })
  end
end
function WBP_ModChoosePanel_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  if IsListeningForInputAction(self, self.TabKeyEvent) then
    StopListeningForInputAction(self, self.TabKeyEvent, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.CKeyEvent) then
    StopListeningForInputAction(self, self.CKeyEvent, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.EscapeKeyEvent) then
    StopListeningForInputAction(self, self.EscapeKeyEvent, UE.EInputEvent.IE_Pressed)
  end
end
function WBP_ModChoosePanel_C:OnAnimationFinished(Animation)
  if Animation == self.ani_33_modchoosepanel_out then
    self:Exit()
  end
end
function WBP_ModChoosePanel_C:OnOpenModUI(InNPCCharacterMOD)
  self.Image_ExitAnimation:SetVisibility(UE.ESlateVisibility.Hidden)
  self.NPCCharacterMOD = InNPCCharacterMOD
  self.ModNumber = 3
  self:InitModWidgets()
  self:PlayAnimation(self.ani_33_modchoosepanel_in)
  self.Index = 1
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_ModChoosePanel_C.PlayModAnimation
  }, 0.3, false)
  self:UpdateModWidgetByType()
  if self.bInitInfo then
    self:UpdateModTypeCounts()
  else
    self:InitModTypeCounts()
  end
  self.bInitInfo = true
end
function WBP_ModChoosePanel_C:InitModWidgets()
  local widgets = self.CanvasPanel_Mods:GetAllChildren()
  local arrayLength = widgets:Length()
  if arrayLength < self.ModNumber then
    local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModChoose/WBP_ModChooseBox.WBP_ModChooseBox_C")
    local widget, slot
    local position = UE.FVector2D()
    for i = 1, self.ModNumber - arrayLength do
      widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
      if widget then
        widget.ModChooseDelegate:Add(self, WBP_ModChoosePanel_C.OnModChoose)
        slot = self.CanvasPanel_Mods:AddChild(widget)
        if slot then
          position.X = 420 * (arrayLength + i - 1)
          position.Y = 10
          slot:SetPosition(position)
        end
      end
    end
  end
  if arrayLength > self.ModNumber then
    local widget
    for i = self.ModNumber, arrayLength do
      if arrayLength > i then
        widget = self.HorizontalBox_ModLevel:Get(arrayLength - i + 1)
        if widget then
          widget.ModChooseDelegate:Remove(self, WBP_ModChoosePanel_C.OnModChoose)
        end
        self.HorizontalBox_ModLevel:RemoveChildAt(arrayLength - i)
      end
    end
  end
  widgets = self.CanvasPanel_Mods:GetAllChildren()
  arrayLength = widgets:Length()
  local widget = widgets:Get(arrayLength)
  if widget then
    widget.Image_Line:SetVisibility(UE.ESlateVisibility.Hidden)
  end
  for key, value in pairs(widgets) do
    value:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_ModChoosePanel_C:BindOnMODResultDelegate(Bind)
  if self.modComponent then
    if Bind then
      self.modComponent.OnMODResultDelegate:Add(self, self.OnMODResultDelegate)
    else
      self.modComponent.OnMODResultDelegate:Remove(self, self.OnMODResultDelegate)
    end
  end
end
function WBP_ModChoosePanel_C:OnMODResultDelegate(NPC, Result)
  if Result then
    print("\230\168\161\231\187\132\233\128\137\230\139\169\230\136\144\229\138\159!!!!!!!")
    self:Exit()
  else
    print("\230\168\161\231\187\132\233\128\137\230\139\169\229\164\177\232\180\165!!!!!!!")
    self:DisableAllMod(false)
    self.bModChoose = false
  end
end
function WBP_ModChoosePanel_C:OnModChoose()
  self.bModChoose = true
  self:DisableAllMod(true)
end
function WBP_ModChoosePanel_C:OnTabKeyEvent()
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
function WBP_ModChoosePanel_C:OnCKeyEvent()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    return UIManager:Switch(UIClass, HideOther)
  end
  if SwitchUI(self.MainPanelClass, true) then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager and UIManager:IsValid() then
      local widget = UIManager:K2_GetUI(self.MainPanelClass)
      if widget and widget:IsValid() then
        widget:ActivatePagePanel(2)
      end
    end
  end
end
function WBP_ModChoosePanel_C:OnEscapeKeyEvent()
  if not self:IsAnimationPlaying(self.ani_33_modchoosepanel_in) and not self:IsAnimationPlaying(self.ani_33_modchoosepanel_out) and not self.ModChoose then
    self:PlayExitAnimation()
  end
end
function WBP_ModChoosePanel_C:UpdateModWidgetByType()
  local selectedMODId = self.NPCCharacterMOD.SelectedMODId
  if selectedMODId:IsValidIndex(1) then
    print("selectedMODId")
    print(selectedMODId:Get(1))
    print(selectedMODId:Get(2))
    if selectedMODId:Get(1) > 0 then
      if self:HasCompanionAI() and selectedMODId:IsValidIndex(2) then
        if selectedMODId:Get(2) < 0 then
          self:ActivatePagePanel(1)
        else
          self:Exit()
        end
      end
    else
      self:ActivatePagePanel(0)
    end
  end
end
function WBP_ModChoosePanel_C:UpdateModWidgets(StartIndex)
  local modWidgets = self.CanvasPanel_Mods:GetAllChildren()
  local modList = self.NPCCharacterMOD.MODList
  for key, value in iterator(modWidgets) do
    if modList:IsValidIndex(StartIndex) then
      value:UpdateModInfo(modList:Get(StartIndex), self.ChooseType)
    end
    StartIndex = StartIndex + 1
  end
end
function WBP_ModChoosePanel_C:InitModTypeCounts()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local pawn = self:GetOwningPlayerPawn()
    if pawn then
      local rgCharacter = pawn:Cast(UE.ARGCharacterBase)
      if rgCharacter then
        local Result, CharacterRow = GetRowDataForCharacter(rgCharacter:GetTypeID())
        if Result then
          local legendConfig = CharacterRow.ModConfig.LegendConfig
          if legendConfig.LegendList:Length() > 0 then
            self.WBP_ModTypeCount_Legend:InitModTypeInfo(legendConfig)
            self.WBP_ModTypeCount_Legend:SetVisibility(UE.ESlateVisibility.Visible)
          else
            self.WBP_ModTypeCount_Legend:SetVisibility(UE.ESlateVisibility.Collapsed)
          end
          for key, value in iterator(self.HorizontalBox_ESQ:GetAllChildren()) do
            value:SetVisibility(UE.ESlateVisibility.Collapsed)
          end
          local widget, index
          for key, value in iterator(CharacterRow.ModConfig.QESList) do
            if value.ModType == UE.ERGModType.ESkillMod then
              index = 0
            end
            if value.ModType == UE.ERGModType.SSkillMod then
              index = 1
            end
            if value.ModType == UE.ERGModType.QSkillMod then
              index = 2
            end
            widget = self.HorizontalBox_ESQ:GetChildAt(index)
            if widget then
              widget:InitModTypeInfo(value)
              widget:SetVisibility(UE.ESlateVisibility.Visible)
            end
          end
          self:UpdateModTypeCounts()
        end
      end
    end
  end
end
function WBP_ModChoosePanel_C:UpdateModTypeCounts()
  self.WBP_ModTypeCount_Legend:UpdateModTypeInfo()
  for key, value in iterator(self.HorizontalBox_ESQ:GetAllChildren()) do
    value:UpdateModTypeInfo()
  end
end
function WBP_ModChoosePanel_C:ActivatePagePanel(Index)
  self:ActivatePageTitle(Index)
  if 0 == Index then
    self.ChooseType = UE.ERGMODChooseType.Character
    self:UpdateModWidgets(1)
  end
  if 1 == Index then
    self.ChooseType = UE.ERGMODChooseType.AI
    self:UpdateModWidgets(1 + self.ModNumber)
  end
end
function WBP_ModChoosePanel_C:ActivatePageTitle(Index)
end
function WBP_ModChoosePanel_C:DisableAllMod(Disable)
  for key, value in iterator(self.CanvasPanel_Mods:GetAllChildren()) do
    value:DisableMod(Disable)
  end
end
function WBP_ModChoosePanel_C:HasCompanionAI()
  if not self.CompanionComp then
    self.CompanionComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.UCompanionComponent:StaticClass())
  end
  if self.CompanionComp and self.CompanionComp:GetCompanionAI() then
    return true
  else
    return false
  end
end
function WBP_ModChoosePanel_C:PlayModAnimation()
  local widgets = self.CanvasPanel_Mods:GetAllChildren()
  local arrayLength = widgets:Length()
  if arrayLength < self.Index then
    self.Index = 1
  else
    local widget = widgets:Get(self.Index)
    if widget and widget:IsValid() then
      widget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      widget:PlayAnimation(widget.ani_modchoosebox_in)
      self.Index = self.Index + 1
      UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        WBP_ModChoosePanel_C.PlayModAnimation
      }, 0.13, false)
    end
  end
end
function WBP_ModChoosePanel_C:PlayExitAnimation()
  self.Image_ExitAnimation:SetVisibility(UE.ESlateVisibility.Visible)
  self:PlayAnimation(self.ani_33_modchoosepanel_out)
  local widgets = self.CanvasPanel_Mods:GetAllChildren()
  for key, value in pairs(widgets) do
    value:PlayAnimation(value.ani_modchoosebox_out)
  end
end
return WBP_ModChoosePanel_C
