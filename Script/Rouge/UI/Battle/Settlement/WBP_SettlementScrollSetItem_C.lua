local WBP_SettlementScrollSetItem_C = UnLua.Class()
local ScrollSetLvListItemClsPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetLvListItem.WBP_ScrollSetLvListItem_C"
function WBP_SettlementScrollSetItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_SettlementScrollSetItem_C:InitScrollSetItem(ActivatedSetData, UpdateScrollSetTipsFunc, ParentView)
  UpdateVisibility(self, true, true)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_SettlementScrollSetItem_C:InitScrollSetItem not DTSubsystem")
    return nil
  end
  self.UpdateScrollSetTipsFunc = UpdateScrollSetTipsFunc
  self.ParentView = ParentView
  self.ActivatedSetData = ActivatedSetData
  if not ActivatedSetData then
    UpdateVisibility(self.CanvasPanelNull, true)
    UpdateVisibility(self.CanvasPanelNormal, false)
    self.URGImageIcon:SetIsEnabled(true)
    return
  end
  UpdateVisibility(self.CanvasPanelNull, false)
  UpdateVisibility(self.CanvasPanelNormal, true)
  if ActivatedSetData.Level <= 0 then
    self:UpdateHighlight(false)
  end
  local MinLv = -1
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(ActivatedSetData.SetId, nil)
  if ResultModifySet then
    SetImageBrushBySoftObject(self.URGImageIcon, AttributeModifySetRow.SetIconWithBg)
    self.RGTextScrollSetName:SetText(AttributeModifySetRow.SetName)
    local ScrollSetLvListItemCls = UE.UClass.Load(ScrollSetLvListItemClsPath)
    local MaxLevel = Logic_Scroll:GetModifySetMaxLevel(ActivatedSetData)
    local IndexLvList = 1
    for i = 1, MaxLevel do
      local InscriptionIdPtr = Logic_Scroll:GetInscriptionBySetLv(i, ActivatedSetData.SetId)
      local setLvItemName = "Image_schedule" .. IndexLvList
      if InscriptionIdPtr then
        UpdateVisibility(self[setLvItemName], i <= ActivatedSetData.Level)
        IndexLvList = IndexLvList + 1
        if -1 == MinLv then
          MinLv = i
        end
      end
    end
    if MinLv > 0 and MinLv <= ActivatedSetData.Level then
      self.URGImageIcon:SetIsEnabled(true)
    else
      self.URGImageIcon:SetIsEnabled(false)
    end
  end
end
function WBP_SettlementScrollSetItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.UpdateScrollSetTipsFunc and self.ActivatedSetData then
    self:UpdateHighlight(true)
    self.UpdateScrollSetTipsFunc(self.ParentView, true, self.ActivatedSetData, self)
  end
end
function WBP_SettlementScrollSetItem_C:OnMouseLeave(MouseEvent)
  if self.UpdateScrollSetTipsFunc and self.ActivatedSetData then
    self:UpdateHighlight(false)
    self.UpdateScrollSetTipsFunc(self.ParentView, false, self.ActivatedSetData, self)
  end
end
function WBP_SettlementScrollSetItem_C:UpdateHighlight(bIsHighlight)
  UpdateVisibility(self.Image_Select, bIsHighlight)
end
function WBP_SettlementScrollSetItem_C:Hide()
  UpdateVisibility(self, false)
  self:UpdateHighlight(false)
end
function WBP_SettlementScrollSetItem_C:Destruct()
  self.Overridden.Destruct(self)
  self.UpdateScrollSetTipsFunc = nil
  self.ParentView = nil
  self.ActivatedSetData = nil
end
return WBP_SettlementScrollSetItem_C
