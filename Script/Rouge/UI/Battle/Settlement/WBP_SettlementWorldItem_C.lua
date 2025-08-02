local WBP_SettlementWorldItem_C = UnLua.Class()

function WBP_SettlementWorldItem_C:Construct()
end

function WBP_SettlementWorldItem_C:Destruct()
end

function WBP_SettlementWorldItem_C:Init(WorldInfo)
  UpdateVisibility(self, true)
  self:PlayAnimation(self.Ani_in)
  print("WBP_SettlementWorldItem_C:Init chj", WorldInfo.bIsFinish, WorldInfo.bIsFirst, WorldInfo.WorldIcon, WorldInfo.Name, WorldInfo.bUnKnow)
  if WorldInfo.bIsFinish then
    self.URGImageLineUnFinish:SetVisibility(UE.ESlateVisibility.Collapsed)
    if WorldInfo.bIsFirst then
      self.URGImageLineFinish:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.URGImageLineFinish:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    self.RGTextClear:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.RGTextMiss:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.CanvasPanelUnKnow, false)
    UpdateVisibility(self.CanvasPanelAchievement, true)
    UpdateVisibility(self.URGImageLineFinish, true)
  else
    if WorldInfo.bIsFirst then
      self.URGImageLineUnFinish:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.URGImageLineUnFinish:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    self.URGImageLineFinish:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.RGTextClear:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.RGTextMiss:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UpdateVisibility(self.CanvasPanelUnKnow, WorldInfo.bUnKnow)
    UpdateVisibility(self.CanvasPanelAchievement, not WorldInfo.bUnKnow)
    UpdateVisibility(self.URGImageLineFinish, false)
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldInfo.WorldIcon)
  local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
  self.URGImageIcon:SetBrush(Brush)
  self.URGImageIconBg_1:SetBrush(Brush)
  self.URGImageIconBg:SetBrush(Brush)
  SetImageBrushBySoftObject(self.URGImageIcon, WorldInfo.WorldIcon)
  SetImageBrushBySoftObject(self.URGImageIconBg_1, WorldInfo.WorldIcon)
  SetImageBrushBySoftObject(self.URGImageIconBg, WorldInfo.WorldIcon)
  SetImageBrushBySoftObject(self.URGImageUnFinish, WorldInfo.WorldBg)
  self.RGTextWorldName:SetText(WorldInfo.Name)
end

function WBP_SettlementWorldItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SettlementWorldItem_C
