local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RedDotData = require("Modules.RedDot.RedDotData")
local WeaponSkinItem = UnLua.Class()

function WeaponSkinItem:Construct()
  self.OnRGToggleStateChanged:Bind(self, self.OnSelectToggle)
  self.WBP_Item.OnClicked:Add(self, self.OnItemClick)
end

function WeaponSkinItem:Destruct()
  self.OnRGToggleStateChanged:Unbind()
end

function WeaponSkinItem:OnSelectToggle(bIsChecked, ToggleIdx)
  if bIsChecked and self.WeaponSkinInfo and self.WeaponSkinInfo.bUnlocked then
    self.WBP_RedDotView:SetNum(0)
  end
  self.WBP_Item:SetSel(bIsChecked)
end

function WeaponSkinItem:OnItemClick()
  self.TopView:OnWeaponSkinGroupCheckStateChanged(self.SkinID)
  self.WBP_Item:SetSel(true)
end

function WeaponSkinItem:InitWeaponSkinItem(WeaponSkinInfo, EquipedSkinId, HeroId, SkinID, TopView)
  self.TopView = TopView
  self.SkinID = SkinID
  if not self.bInited then
    self.bInited = true
  end
  self.WeaponSkinInfo = WeaponSkinInfo
  if WeaponSkinInfo.bUnlocked then
    if self.WBP_RedDotView then
      self.WBP_RedDotView:ChangeRedDotIdByTag(HeroId .. self.WeaponSkinInfo.WeaponSkinTb.SkinID)
    end
  elseif self.WBP_RedDotView then
    self.WBP_RedDotView:ChangeRedDotIdByTag(-1)
  end
  self.WBP_Item:InitItem(WeaponSkinInfo.WeaponSkinTb.ID)
  self.WBP_Item:SetTargetExpirationTime(WeaponSkinInfo.expireAt)
  UpdateVisibility(self, true, true)
  UpdateVisibility(self.URGImageEquiped, WeaponSkinInfo.WeaponSkinTb.SkinID == EquipedSkinId and WeaponSkinInfo.bUnlocked)
  UpdateVisibility(self.Image_jiao, WeaponSkinInfo.WeaponSkinTb.SkinID == EquipedSkinId and WeaponSkinInfo.bUnlocked)
  UpdateVisibility(self.CanvasPanelLock, not WeaponSkinInfo.bUnlocked)
  self.WBP_Item:SetLock(not WeaponSkinInfo.bUnlocked)
  local skinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
  self.MovieObjPtr = nil
  if skinView then
    self.MovieObjPtr = skinView.SkinMovieData.SkinMovieData:Find(WeaponSkinInfo.WeaponSkinTb.SkinID)
  end
  UpdateVisibility(self.URGImageMovieTag, self.MovieObjPtr)
end

function WeaponSkinItem:OnMouseEnter(MyGeometry, MouseEvent)
end

function WeaponSkinItem:Hide()
  UpdateVisibility(self, false)
  self.WeaponSkinInfo = nil
end

return WeaponSkinItem
