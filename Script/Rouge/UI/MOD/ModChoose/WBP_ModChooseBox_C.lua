local WBP_ModChooseBox_C = UnLua.Class()

function WBP_ModChooseBox_C:Construct()
  self.Disable = false
  self.Button_ModChoose.OnClicked:Add(self, WBP_ModChooseBox_C.OnClicked)
  self.Button_ModChoose.OnHovered:Add(self, WBP_ModChooseBox_C.OnHovered)
  self.Button_ModChoose.OnUnhovered:Add(self, WBP_ModChooseBox_C.OnUnHovered)
  self.modComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass())
end

function WBP_ModChooseBox_C:Destruct()
  self.Button_ModChoose.OnClicked:Remove(self, WBP_ModChooseBox_C.OnClicked)
  self.Button_ModChoose.OnHovered:Remove(self, WBP_ModChooseBox_C.OnHovered)
  self.Button_ModChoose.OnUnhovered:Remove(self, WBP_ModChooseBox_C.OnUnHovered)
  self.modComponent = nil
end

function WBP_ModChooseBox_C:OnClicked()
  if not self.Disable then
    self.Disable = true
    if self.modComponent then
      self.modComponent:TryUpgradeMOD(self.ModID, self.ChooseType, -1, self.ModType)
    end
    self.ModChooseDelegate:Broadcast()
  end
end

function WBP_ModChooseBox_C:OnHovered()
  if not self.Disable then
    self.WBP_ModChooseTip:InitModInfo(self.ModID, self.ChooseType, self.ModType, true)
    self.WBP_ModChooseTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self):SetZOrder(100)
    self:UpdateModAddition()
  end
end

function WBP_ModChooseBox_C:OnUnHovered()
  self.WBP_ModChooseTip:SetVisibility(UE.ESlateVisibility.Hidden)
  self.VerticalBox_ModAdd:SetVisibility(UE.ESlateVisibility.Hidden)
  UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self):SetZOrder(0)
end

local CostTextColor = {
  Black = UE.FLinearColor(0, 0, 0, 1.0),
  Yellow = UE.FLinearColor(0.904661, 0.116971, 0.008568, 1.0)
}

function WBP_ModChooseBox_C:UpdateModInfo(ModID, ChooseType)
  if ModID <= 0 then
    self.Overlay_Full:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Button_ModChoose:SetVisibility(UE.ESlateVisibility.Hidden)
    self.CanvasPanel_ModInfo:SetVisibility(UE.ESlateVisibility.Hidden)
  else
    self.Overlay_Full:SetVisibility(UE.ESlateVisibility.Hidden)
    self.Button_ModChoose:SetVisibility(UE.ESlateVisibility.Visible)
    self.CanvasPanel_ModInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Disable = false
  self.ModID = ModID
  self.ChooseType = ChooseType
  self:UpdateModInfoByID()
  self:UpdateModInfoByModType()
  self:UpdateModLevelInfo()
  self:UpdateModInfoByChooseType()
  self:UpdateModEffect()
  self:UpdateModGenreRoutine()
end

function WBP_ModChooseBox_C:UpdateModInfoByModType()
  local tempModIconBack, tempButtonStyle
  local SlateColor = UE.FSlateColor()
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  if self.ModType == UE.ERGModType.LegendMod then
    tempModIconBack = self.LegendModIconBack
    SlateColor.SpecifiedColor = CostTextColor.Yellow
    tempButtonStyle = self.LegendStyle
  else
    tempModIconBack = self.NormalModIconBack
    SlateColor.SpecifiedColor = CostTextColor.Black
    tempButtonStyle = self.NormalStyle
  end
  local modIconBackIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(tempModIconBack)
  if modIconBackIconObj then
    local modBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(modIconBackIconObj, 0, 0)
    self.Image_ModIconBack:SetBrush(modBrush)
  end
  self.TextBlock_ModName:SetColorAndOpacity(SlateColor)
  self.Button_ModChoose:SetStyle(tempButtonStyle)
end

function WBP_ModChooseBox_C:UpdateModInfoByID()
  if self.modComponent then
    self.ModType = self.modComponent:GetModTypeById(self.ModID)
  end
  local ModInfo = GetLuaInscription(self.ModID)
  if ModInfo then
    SetImageBrushByPath(self.Image_ModIcon, ModInfo.Icon)
    self.TextBlock_ModName:SetText(ModInfo.Name)
    self.RichTextBlock_Des:SetText(ModInfo.Desc)
  else
    print("ModInfo Is Null.")
  end
end

function WBP_ModChooseBox_C:UpdateModLevelInfo()
  if self.modComponent then
    local modMaxLevel = self.modComponent:GetMaxMODLevel(self.ModID, self.ChooseType, self.ModType)
    print("ModID :" .. self.ModID .. "//" .. "ChooseType" .. self.ChooseType .. "//" .. "ModType" .. self.ModType .. "//" .. "CurrentMaxLevel " .. tostring(modMaxLevel))
    local margin = UE.FMargin()
    margin.Left = 10
    margin.right = 10
    local slot
    local widgets = self.HorizontalBox_ModLevel:GetAllChildren()
    local arrayLength = widgets:Length()
    if modMaxLevel > arrayLength then
      local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModChoose/WBP_ModLevel.WBP_ModLevel_C")
      local widget
      for i = 1, modMaxLevel - arrayLength do
        widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
        if widget then
          slot = self.HorizontalBox_ModLevel:AddChild(widget)
          if slot then
            slot:SetPadding(margin)
          end
        end
      end
    end
    if modMaxLevel < arrayLength then
      for i = modMaxLevel, arrayLength do
        if arrayLength > i then
          self.HorizontalBox_ModLevel:RemoveChildAt(arrayLength - i)
        end
      end
    end
    local modLevel = self.modComponent:GetMODLevel(self.ModID, self.ChooseType, self.ModType) + 1
    print("ModID :" .. self.ModID .. "//" .. "ChooseType" .. self.ChooseType .. "//" .. "ModType" .. self.ModType .. "//" .. "CurrentModLevel" .. "\239\188\154" .. tostring(modLevel - 1))
    widgets = self.HorizontalBox_ModLevel:GetAllChildren()
    for key, value in iterator(widgets) do
      value:UpdateActiveInfo(false)
    end
    local widget
    for i = 0, modLevel do
      if widgets:IsValidIndex(i + 1) then
        widget = self.HorizontalBox_ModLevel:GetChildAt(i)
        widget:UpdateActiveInfo(true)
      end
    end
  end
end

function WBP_ModChooseBox_C:UpdateModInfoByChooseType()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local pawn = self:GetOwningPlayerPawn()
    if pawn then
      local rgCharacter = pawn:Cast(UE.ARGCharacterBase)
      if rgCharacter then
        local Result, CharacterRow = GetRowDataForCharacter(rgCharacter:GetTypeID())
        if Result then
          local modInfo
          if self.ModType == UE.ERGModType.LegendMod then
            modInfo = CharacterRow.ModConfig.LegendConfig
          else
            for key, value in iterator(CharacterRow.ModConfig.QESList) do
              if value.ModType == self.ModType then
                modInfo = value
              end
            end
          end
          if nil == modInfo then
            self.TextBlock_Type:SetText("\230\168\161\231\187\132\231\177\187\229\158\139\233\133\141\231\189\174\233\148\153\232\175\175")
          else
            self.TextBlock_Type:SetText(modInfo.Name)
            local ModIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(modInfo.Icon)
            if ModIconObj then
              local ModBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(ModIconObj, 30, 20)
              self.Image_ModType:SetBrush(ModBrush)
            end
          end
        end
      end
    end
  end
end

function WBP_ModChooseBox_C:UpdateModAddition()
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if logicCommandDataSubsystem then
    local ModInfo = GetLuaInscription(self.ModID)
    if ModInfo then
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if not DTSubsystem then
        print("WBP_ModChooseBox_C: DTSubsystem is null.")
        return
      end
      local keyArray = {}
      if ModInfo.ModAdditionalNoteMap then
        local keysAry = ModInfo.ModAdditionalNoteMap:Keys()
        for k, v in pairs(keysAry) do
          table.insert(keyArray, k)
        end
      end
      local keyArrayLength = #keyArray
      local padding = UE.FMargin()
      padding.Top = 5
      self.SingleModNote:SetVisibility(UE.ESlateVisibility.Hidden)
      if keyArrayLength > 0 then
        local widgetPath = "/Game/Rouge/UI/MOD/ModChoose/WBP_SingleModNote.WBP_SingleModNote_C"
        UpdateWidgetContainer(self.VerticalBox_ModAdd, keyArrayLength, widgetPath, padding, self, self:GetOwningPlayer())
        self.SingleModNote:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        for key, value in pairs(self.VerticalBox_ModAdd:GetAllChildren()) do
          local Result, ModAdditionalNoteRow = DTSubsystem:GetModAdditionalNoteTableRow(keyArray[key], nil)
          if Result then
            value:UpdateInfo(ModAdditionalNoteRow)
          end
        end
        self.VerticalBox_ModAdd:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      print("ModInfo Is Null.")
    end
  end
end

function WBP_ModChooseBox_C:UpdateModEffect()
  self.RichTextBlock_Des_:SetText("")
  local gameState = UE.UGameplayStatics.GetGameState(self)
  if not gameState then
    return
  end
  local modManager = gameState:GetComponentByClass(UE.UMODManager:StaticClass())
  if not modManager then
    return
  end
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  local DataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem.StaticClass())
  if DataTableSubsystem and logicCommandDataSubsystem and self.modComponent then
    local result, row = DataTableSubsystem:GetModRefreshTableRow(self.ModID, nil)
    if result then
      local ModInfo
      local stringArray = UE.TArray(UE.FString)
      stringArray = UE.UKismetStringLibrary.ParseIntoArray(row.ShowEffect, ";", false)
      if stringArray:Length() > 0 then
        local tempString = ""
        local modString
        local hasLearned = false
        for key, value in pairs(stringArray) do
          ModInfo = logicCommandDataSubsystem:GetInscriptionDAByID(tonumber(value))
          if ModInfo then
            hasLearned = modManager:GetLearnedByModId(self:GetOwningPlayerPawn(), tonumber(value), self.modComponent:GetModTypeById(tonumber(value)))
            print(tonumber(value) .. ":   " .. tostring(hasLearned))
            if hasLearned then
              modString = ModInfo.Name
              print(modString)
              tempString = tempString .. modString .. ",   "
              print(tempString)
            end
          end
        end
        if #tempString > 0 then
          local totalString = "\229\189\177\229\147\141\229\183\178\230\156\137\231\154\132\230\168\161\231\187\132:  " .. tempString
          local finalString = string.sub(totalString, 1, -2)
          self.RichTextBlock_Des_:SetText(finalString)
        end
      end
    end
  end
end

function WBP_ModChooseBox_C:UpdateModGenreRoutine()
  self.SizeBox_ModGenreRoutine:SetVisibility(UE.ESlateVisibility.Collapsed)
  local DataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem.StaticClass())
  if not DataTableSubsystem:IsValid() then
    print("DataTableSubsystem is not valid -- WBP_ModChooseBox_C:UpdateModGenreRoutine()")
    return
  end
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not logicCommandDataSubsystem:IsValid() then
    print("logicCommandDataSubsystem is not valid -- WBP_ModChooseBox_C:UpdateModGenreRoutine()")
    return
  end
  local modInfo
  modInfo = logicCommandDataSubsystem:GetInscriptionDAByID(tonumber(self.ModID))
  if not modInfo:IsValid() then
    print("modInfo is not valid -- WBP_ModChooseBox_C:UpdateModGenreRoutine()")
    return
  end
  local result, row = DataTableSubsystem:GetModGenreRoutineTableRow(tonumber(modInfo.ModGenreRoutineRowName), nil)
  if result then
    if row.ModAdditionalNote == "" then
      return
    else
      self.RichTextBlock_ModGenreRoutine:SetText(row.ModAdditionalNote)
      self.SizeBox_ModGenreRoutine:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    end
  end
end

function WBP_ModChooseBox_C:DisableMod(Disable)
  self.Disable = Disable
end

return WBP_ModChooseBox_C
