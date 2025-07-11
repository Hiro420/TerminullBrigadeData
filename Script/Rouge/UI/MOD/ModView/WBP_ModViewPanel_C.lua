local WBP_ModViewPanel_C = UnLua.Class()
function WBP_ModViewPanel_C:Construct()
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local rgCharacter = pawn:Cast(UE.ARGCharacterBase)
    if rgCharacter then
      self:InitAllModInfo(rgCharacter:GetTypeID())
    end
  end
  EventSystem.AddListener(self, EventDef.MainPanel.MainPanelChanged, WBP_ModViewPanel_C.OnActiveWidgetChange)
end
function WBP_ModViewPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.MainPanel.MainPanelChanged, WBP_ModViewPanel_C.OnActiveWidgetChange)
end
function WBP_ModViewPanel_C:InitAllModInfo(TypeID)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local Result, CharacterRow = GetRowDataForCharacter(TypeID)
    if Result then
      local legendConfig = CharacterRow.ModConfig.LegendConfig
      if legendConfig.LegendList:Length() > 0 then
        self.WBP_SingleModTypePanel_Legend:InitModInfo(legendConfig)
        self.WBP_SingleModTypePanel_Legend:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      else
        self.WBP_SingleModTypePanel_Legend:SetVisibility(UE.ESlateVisibility.Hidden)
      end
      for key, value in iterator(self.CanvasPanel_ESQ:GetAllChildren()) do
        value:SetVisibility(UE.ESlateVisibility.Hidden)
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
        widget = self.CanvasPanel_ESQ:GetChildAt(index)
        if widget then
          widget:InitModInfo(value)
          widget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
end
function WBP_ModViewPanel_C:UpdateAllModInfo()
  self.WBP_SingleModTypePanel_Legend:UpdateModInfo()
  for key, value in iterator(self.CanvasPanel_ESQ:GetAllChildren()) do
    value:UpdateModInfo()
  end
end
function WBP_ModViewPanel_C:OnActiveWidgetChange(LastActiveWidget, CurActiveWidget)
  if CurActiveWidget == self then
    self:UpdateAllModInfo()
  end
end
return WBP_ModViewPanel_C
