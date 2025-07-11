local WBP_GRTypeButton_C = UnLua.Class()
function WBP_GRTypeButton_C:Construct()
  self.Button_GRType.OnClicked:Add(self, WBP_GRTypeButton_C.OnClicked_Button)
  self.Button_GRType.OnHovered:Add(self, WBP_GRTypeButton_C.OnClicked_Hovered)
  self.Button_GRType.OnUnHovered:Add(self, WBP_GRTypeButton_C.OnClicked_UnHovered)
end
function WBP_GRTypeButton_C:Destruct()
  self.Button_GRType.OnClicked:Remove(self, WBP_GRTypeButton_C.OnClicked_Button)
  self.Button_GRType.OnHovered:Remove(self, WBP_GRTypeButton_C.OnClicked_Hovered)
  self.Button_GRType.OnUnHovered:Remove(self, WBP_GRTypeButton_C.OnClicked_UnHovered)
end
function WBP_GRTypeButton_C:SetActivateState(Activate)
  if self.TabConfig and self.TabConfig:IsValid() then
    local IconObj
    if Activate then
      IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.TabConfig.ChooseTypeIcon)
      self.Image_GRType:SetColorAndOpacity(UE.FLinearColor(0.005605, 0.008568, 0.015996, 1.0))
      self.Image_GRTypeSelect:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.TabConfig.NormalTypeIcon)
      self.Image_GRType:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 1.0))
      self.Image_GRTypeSelect:SetVisibility(UE.ESlateVisibility.Hidden)
    end
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Image_GRType:SetBrush(Brush)
  end
end
function WBP_GRTypeButton_C:OnClicked_Button()
  self:ActivateTabWidget()
end
function WBP_GRTypeButton_C:OnClicked_Hovered()
  self.Image_GRTypeHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_GRTypeButton_C:OnClicked_UnHovered()
  self.Image_GRTypeHover:SetVisibility(UE.ESlateVisibility.Hidden)
end
return WBP_GRTypeButton_C
