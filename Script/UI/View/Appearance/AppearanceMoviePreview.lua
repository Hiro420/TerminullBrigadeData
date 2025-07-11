local AppearanceMoviePreview = UnLua.Class()
function AppearanceMoviePreview:Construct()
  self.Overridden.Construct(self)
  self.BP_ButtonShowMovie.OnClicked:Add(self, self.ShowMovie)
end
function AppearanceMoviePreview:Destruct()
  self.BP_ButtonShowMovie.OnClicked:Remove(self, self.ShowMovie)
  self.Overridden.Destruct(self)
end
function AppearanceMoviePreview:UpdateMoviePreview(SkinId, AppearanceMovieList)
  self.CurSkinId = SkinId
  self.AppearanceMovieList = AppearanceMovieList
  local heirloomMediaData
  local resultHeroSkin, rowHeroSkin = GetRowData(DT.DT_HeirloomSkin, tostring(SkinId))
  if not resultHeroSkin then
    local resultWeaponSkin, rowWeaponSkin = GetRowData(DT.DT_HeirloomWeaponSkin, tostring(SkinId))
    if resultWeaponSkin and rowWeaponSkin.HeirloomMediaDataAry:IsValidIndex(1) then
      heirloomMediaData = rowWeaponSkin.HeirloomMediaDataAry:Get(1)
    end
  elseif rowHeroSkin.HeirloomMediaDataAry:IsValidIndex(1) then
    heirloomMediaData = rowHeroSkin.HeirloomMediaDataAry:Get(1)
  end
  if not heirloomMediaData then
    UpdateVisibility(self, false)
    return false
  end
  UpdateVisibility(self, true, true)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(heirloomMediaData.CoverImg) then
    local IconObj = GetAssetBySoftObjectPtr(heirloomMediaData.CoverImg, true)
    if IconObj:Cast(UE.UPaperSprite) then
      SetImageBrushBySoftObject(self.URGImageCover, heirloomMediaData.CoverImg)
    elseif IconObj:Cast(UE.UTexture2D) then
      self.URGImageCover:SetBrushFromSoftTexture(heirloomMediaData.CoverImg)
    end
  end
  self.RGTextTitle:SetText(heirloomMediaData.Title)
  return true
end
function AppearanceMoviePreview:ShowMovie()
  local skinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
  if UE.RGUtil.IsUObjectValid(skinView) and skinView.SequencePlayer then
    skinView:LevelSequenceFinish(true)
  end
  if UE.RGUtil.IsUObjectValid(self.AppearanceMovieList) then
    self.AppearanceMovieList:InitMovieList(self.CurSkinId)
  end
end
return AppearanceMoviePreview
