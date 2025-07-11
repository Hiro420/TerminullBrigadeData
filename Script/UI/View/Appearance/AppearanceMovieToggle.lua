local AppearanceMovieToggle = UnLua.Class()
function AppearanceMovieToggle:OnMouseEnter(MyGeometry, MouseEvent)
end
function AppearanceMovieToggle:OnMouseLeave(MyGeometry, MouseEvent)
end
function AppearanceMovieToggle:InitMoiveToggle(FHeirloomMediaData)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(FHeirloomMediaData.CoverImg) then
    local IconObj = GetAssetBySoftObjectPtr(FHeirloomMediaData.CoverImg, true)
    if IconObj:Cast(UE.UPaperSprite) then
      SetImageBrushBySoftObject(self.URGImageCoverUnselect, FHeirloomMediaData.CoverImg)
      SetImageBrushBySoftObject(self.URGImageCoverSelect, FHeirloomMediaData.CoverImg)
    elseif IconObj:Cast(UE.UTexture2D) then
      self.URGImageCoverUnselect:SetBrushFromSoftTexture(FHeirloomMediaData.CoverImg)
      self.URGImageCoverSelect:SetBrushFromSoftTexture(FHeirloomMediaData.CoverImg)
    end
  end
  self.RGTextTitleSelect:SetText(FHeirloomMediaData.Title)
  self.RGTextTitleUnSelect:SetText(FHeirloomMediaData.Title)
end
return AppearanceMovieToggle
