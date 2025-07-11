local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local AppearanceMovieList = Class()
local EscName = "PauseGame"
function AppearanceMovieList:Construct()
  self.Overridden.Construct(self)
  self.BP_ButtonWithSoundMask.OnClicked:Add(self, self.Hide)
  self.RGToggleGroupMovie.OnCheckStateChanged:Add(self, self.OnToggleGroupMovieChanged)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.Hide)
end
function AppearanceMovieList:Destruct()
  self.BP_ButtonWithSoundMask.OnClicked:Remove(self, self.Hide)
  self.RGToggleGroupMovie.OnCheckStateChanged:Remove(self, self.OnToggleGroupMovieChanged)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.Hide)
  self.Overridden.Destruct(self)
end
function AppearanceMovieList:InitMovieList(SkinId)
  UpdateVisibility(self, true)
  self.CurSkinId = SkinId
  self.RGToggleGroupMovie:ClearGroup()
  local result, row = GetRowData(DT.DT_HeirloomSkin, tostring(SkinId))
  local resultWeapon, rowWeapon = GetRowData(DT.DT_HeirloomWeaponSkin, tostring(SkinId))
  local heirloomMediaDataAry
  if result then
    heirloomMediaDataAry = row.HeirloomMediaDataAry
  elseif resultWeapon then
    heirloomMediaDataAry = rowWeapon.HeirloomMediaDataAry
  end
  if heirloomMediaDataAry then
    for i, v in iterator(heirloomMediaDataAry) do
      local item = GetOrCreateItem(self.ScrollBoxMoveList, i, self.WBP_AppearanceMovieToggle:GetClass())
      item:InitMoiveToggle(v)
      self.RGToggleGroupMovie:AddToGroup(i, item)
    end
    HideOtherItem(self.ScrollBoxMoveList, heirloomMediaDataAry:Length())
  end
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.Hide
    })
  end
  self.RGToggleGroupMovie:SelectId(1)
end
function AppearanceMovieList:OnToggleGroupMovieChanged(SelectIdParam)
  if not self.CurSkinId then
    return
  end
  local result, row = GetRowData(DT.DT_HeirloomSkin, tostring(self.CurSkinId))
  local resultWeapon, rowWeapon = GetRowData(DT.DT_HeirloomWeaponSkin, tostring(self.CurSkinId))
  local heirloogMediaData
  if result and row.HeirloomMediaDataAry:IsValidIndex(SelectIdParam) then
    heirloogMediaData = row.HeirloomMediaDataAry:Get(SelectIdParam)
  elseif resultWeapon and rowWeapon.HeirloomMediaDataAry:IsValidIndex(SelectIdParam) then
    heirloogMediaData = rowWeapon.HeirloomMediaDataAry:Get(SelectIdParam)
  end
  if heirloogMediaData then
    self.RGTextTitle:SetText(heirloogMediaData.Title)
    self.RGTextDesc:SetText(heirloogMediaData.Desc)
    local MovieSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
    if MovieSubSys then
      local mediaSrc = MovieSubSys:GetMediaSource(heirloogMediaData.MediaId)
      print("OnToggleGroupMovieChanged", self.AkEventName)
      if self.AkEventName ~= nil or self.AkEventName ~= "" then
        UE.UAudioManager.StopWwiseEventByName(self.AkEventName)
      end
      self.AkEventName = MovieSubSys:GetAkEventName(heirloogMediaData.MediaId)
      if mediaSrc then
        self.MediaPlayer:SetLooping(true)
        UE.UAudioManager.PlaySound2DByName(self.AkEventName, "OnToggleGroupMovieChanged")
        self.MediaPlayer:OpenSource(mediaSrc)
        self.MediaPlayer:Rewind()
      end
    end
  end
end
function AppearanceMovieList:Hide()
  UpdateVisibility(self, false)
  if self.AkEventName then
    UE.UAudioManager.StopWwiseEventByName(self.AkEventName)
  end
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
end
return AppearanceMovieList
