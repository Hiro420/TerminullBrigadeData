local WBP_AttributeModify_HoveredTip_C = UnLua.Class()
function WBP_AttributeModify_HoveredTip_C:Construct()
  EventSystem.AddListener(self, EventDef.IllustratedGuide.AttributeModifyHoveredTip, WBP_AttributeModify_HoveredTip_C.InitInfo)
end
function WBP_AttributeModify_HoveredTip_C:Destruct()
end
function WBP_AttributeModify_HoveredTip_C:InitInfo(ItemWidget, Id, bShow)
  self.HoveredId = Id
  self.Name:SetHighlightText(Logic_IllustratedGuide.SearchKeyword)
  UpdateVisibility(self.RGTextBlock_2, false)
  UpdateVisibility(self.RGTextBlock_4, false)
  UpdateVisibility(self.RGTextBlock_6, false)
  self.Name:SetHighlightText(Logic_IllustratedGuide.SearchKeyword)
  self.RGTextBlock_2:SetHighlightText(Logic_IllustratedGuide.SearchKeyword)
  self.RGTextBlock_4:SetHighlightText(Logic_IllustratedGuide.SearchKeyword)
  self.RGTextBlock_6:SetHighlightText(Logic_IllustratedGuide.SearchKeyword)
  local Result = false
  local RowInfo = UE.FRGAttributeModifySetTableRow
  Result, RowInfo = GetRowData(DT.DT_AttributeModifySet, Id)
  if Result then
    self.Name:Settext(RowInfo.SetName)
    SetImageBrushBySoftObject(self.WBP_AttributeModifySet_Item.Img_Icon, RowInfo.SetIcon)
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if not RGLogicCommandDataSubsystem then
      return
    end
    local BaseInscriptionId = RowInfo.BaseInscription.BaseInscriptionId
    if 2 == RowInfo.BaseInscription.Level then
      do
        local InscriptionDesc = GetLuaInscriptionDesc(BaseInscriptionId, 1)
        UpdateVisibility(self.RGTextBlock_2, true)
        self.RGTextBlock_2:Settext("2" .. ":" .. InscriptionDesc)
      end
    end
    for key, value in pairs(RowInfo.LevelInscriptionMap) do
      local InscriptionDesc = GetLuaInscriptionDesc(value, 1)
      if 2 == key then
        UpdateVisibility(self.RGTextBlock_2, true)
        self.RGTextBlock_2:Settext("2" .. ":" .. InscriptionDesc)
      end
      if 4 == key then
        UpdateVisibility(self.RGTextBlock_4, true)
        self.RGTextBlock_4:Settext("4" .. ":" .. InscriptionDesc)
      end
      if 6 == key then
        UpdateVisibility(self.RGTextBlock_6, true)
        self.RGTextBlock_6:Settext("6" .. ":" .. InscriptionDesc)
      end
    end
  end
end
function WBP_AttributeModify_HoveredTip_C:SetSelected(bSelected)
  UpdateVisibility(self.Image_Selected, bSelected)
end
return WBP_AttributeModify_HoveredTip_C
