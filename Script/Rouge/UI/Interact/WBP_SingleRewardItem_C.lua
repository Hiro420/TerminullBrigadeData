local WBP_SingleRewardItem_C = UnLua.Class()

function WBP_SingleRewardItem_C:Show(Info)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local RowInfo = DTSubsystem:K2_GetItemTableRow(Info.ItemId)
  self:UpdateInfo(Info.Count, RowInfo.SpriteIcon, RowInfo.Name)
end

function WBP_SingleRewardItem_C:UpdateInfo(Num, SpriteIcon, Name)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if Name and not UE.UKismetStringLibrary.IsEmpty(Name) then
    self.Txt_Num:SetText(tostring(Name) .. "X" .. Num)
  else
    self.Txt_Num:SetText(Num)
  end
  if not SpriteIcon then
    return
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SpriteIcon)
  if IconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, math.floor(self.IconSize.X), math.floor(self.IconSize.Y))
    if Brush then
      self.Img_Icon:SetBrush(Brush)
    end
  end
end

function WBP_SingleRewardItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SingleRewardItem_C
