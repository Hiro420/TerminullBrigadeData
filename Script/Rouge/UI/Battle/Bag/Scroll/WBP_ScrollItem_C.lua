local WBP_ScrollItem_C = UnLua.Class()
local ScrollSetTagPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetTag.WBP_ScrollSetTag_C"
function WBP_ScrollItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_ScrollItem_C:InitScrollItem(AttributeModifyId, UpdateScrollTips, ParentView, Index, bIsFromMarkTips, bIsNotShowName)
  self.UpdateScrollTips = UpdateScrollTips
  self.ParentView = ParentView
  self.AttributeModifyId = AttributeModifyId
  self.Index = Index
  UpdateVisibility(self, true, true)
  if not AttributeModifyId then
    UpdateVisibility(self.CanvasPanelItem, false)
    self:UpdateHighlight(false)
    return
  end
  UpdateVisibility(self.CanvasPanelItem, true)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollItem_C:InitScrollItem not DTSubsystem")
    return nil
  end
  local Result, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(AttributeModifyId, nil)
  if Result then
    SetImageBrushBySoftObject(self.URGImageIcon, AttributeModifyRow.SpriteIcon)
    local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
    if ResultItemRarity then
      UpdateVisibility(self.URGImageRarityBg, bIsFromMarkTips)
      UpdateVisibility(self.URGImageRarityBg1, not bIsFromMarkTips)
      UpdateVisibility(self.URGImageRarityBg2, not bIsFromMarkTips)
      UpdateVisibility(self.URGImageRarityBg3, not bIsFromMarkTips)
      self.URGImageRarityBg:SetColorAndOpacity(ItemRarityRow.AttributeModifyRareBgColor)
      self.URGImageRarityBg1:SetColorAndOpacity(ItemRarityRow.AttributeModifyRareBgColor)
      self.URGImageRarityBg2:SetColorAndOpacity(ItemRarityRow.AttributeModifyRareBgColor)
      self.URGImageRarityBg3:SetColorAndOpacity(ItemRarityRow.AttributeModifyRareBgColor)
    end
    UpdateVisibility(self.RGTextScrollName, not bIsNotShowName)
    self.RGTextScrollName:SetText(AttributeModifyRow.Name)
    local ScrollSetTagCls = UE.UClass.Load(ScrollSetTagPath)
    local Index = 1
    for i, v in iterator(AttributeModifyRow.SetArray) do
      local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(v, nil)
      if ResultModifySet then
        local SetTagItem = GetOrCreateItem(self.ScrollBoxScrollSetTag, Index, ScrollSetTagCls)
        SetTagItem:InitSetTag(AttributeModifySetRow)
        Index = Index + 1
      end
    end
    HideOtherItem(self.ScrollBoxScrollSetTag, Index)
  end
end
function WBP_ScrollItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.UpdateScrollTips then
    self:UpdateHighlight(true)
    self.UpdateScrollTips(self.ParentView, true, self.AttributeModifyId, self.Index, self)
  end
end
function WBP_ScrollItem_C:OnMouseLeave(MouseEvent)
  if self.UpdateScrollTips then
    self:UpdateHighlight(false)
    self.UpdateScrollTips(self.ParentView, false, self.AttributeModifyId, self.Index, self)
  end
end
function WBP_ScrollItem_C:UpdateHighlight(bIsHighlight)
  UpdateVisibility(self.URGImageHighlight, bIsHighlight)
end
function WBP_ScrollItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_ScrollItem_C:Destruct()
  self.Overridden.Destruct(self)
  self.UpdateScrollTips = nil
  self.ParentView = nil
end
return WBP_ScrollItem_C
