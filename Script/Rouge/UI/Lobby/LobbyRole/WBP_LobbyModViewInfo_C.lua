local WBP_LobbyModViewInfo_C = UnLua.Class()

function WBP_LobbyModViewInfo_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.Image_ModHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_LobbyModViewInfo_C:OnMouseLeave(MouseEvent)
  self.Image_ModHover:SetVisibility(UE.ESlateVisibility.Hidden)
end

local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(1, 0.300544, 0.029557, 1.0)
}

function WBP_LobbyModViewInfo_C:InitModInfo(bIsLegend, ModIDList, ChooseType, ModType)
  self.ModIDList = ModIDList
  local modLength = #ModIDList
  if modLength > 0 then
    self.ModID = ModIDList[1]
  end
  self.ChooseType = ChooseType
  self.ModType = ModType
  self.Image_Mod:SetOpacity(1)
  local linearColor = UE.FLinearColor()
  if bIsLegend then
    linearColor = CostTextColor.Yellow
  else
    linearColor = CostTextColor.White
  end
  self.Image_Mod:SetColorAndOpacity(linearColor)
  self.OutSaveData = GetLuaInscription(self.ModID)
  if self.OutSaveData then
    SetImageBrushByPath(self.Image_Mod, self.OutSaveData.Icon)
  else
    print("OutSaveData is null.")
  end
  self.modMaxLevel = modLength
  self.HorizontalBox_ModLevel:ClearChildren()
  local widget
  local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModView/WBP_ModViewLevel.WBP_ModViewLevel_C")
  local margin = UE.FMargin()
  margin.Left = 2.5
  margin.right = 2.5
  local slot
  for i = 1, self.modMaxLevel do
    widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
    if widget then
      widget:InitInfo(bIsLegend)
      slot = self.HorizontalBox_ModLevel:AddChild(widget)
      if slot then
        slot:SetPadding(margin)
      end
    end
  end
  self:UpdateModInfo()
end

function WBP_LobbyModViewInfo_C:UpdateModInfo()
  if self.modComponent then
    self.modLevel = self.modComponent:GetMODLevel(self.ModID, self.ChooseType, self.ModType) + 1
    print("ModID :" .. self.ModID .. "//" .. "ChooseType" .. self.ChooseType .. "//" .. "ModType" .. self.ModType .. "//" .. "CurrentModLevel" .. "\239\188\154" .. tostring(self.modLevel - 1))
    if self.modLevel < 1 then
      self.Image_Mod:SetOpacity(0.3)
      return
    else
      self.Image_Mod:SetOpacity(1)
    end
    for key, value in iterator(self.HorizontalBox_ModLevel:GetAllChildren()) do
      value:UpdateActiveInfo(false)
    end
    local widget
    local levelWidgets = self.HorizontalBox_ModLevel:GetAllChildren()
    for i = 1, self.modLevel do
      if levelWidgets:IsValidIndex(i) then
        widget = self.HorizontalBox_ModLevel:GetChildAt(i - 1)
        widget:UpdateActiveInfo(true)
      end
    end
  end
end

function WBP_LobbyModViewInfo_C:GetToolTipWidget()
  if self.ModID > 0 then
    local widgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/LobbyRole/Mod/WBP_LobbyModViewTip.WBP_LobbyModViewTip_C")
    local toolTipWidget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
    if toolTipWidget then
      local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
      if logicCommandDataSubsystem then
        local OutSaveData = GetLuaInscription(self.ModID)
        if OutSaveData then
          toolTipWidget:InitModTipInfo(OutSaveData, self.ModIDList)
          return toolTipWidget
        end
      end
    end
  else
    return nil
  end
end

return WBP_LobbyModViewInfo_C
