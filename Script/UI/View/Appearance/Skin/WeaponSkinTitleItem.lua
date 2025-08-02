local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WeaponSkinTitleItem = UnLua.Class()

function WeaponSkinTitleItem:Construct()
  self.BP_ButtonWithSoundSelect.Onclicked:Add(self, self.OnSelectClick)
end

function WeaponSkinTitleItem:Destruct()
  self.BP_ButtonWithSoundSelect.Onclicked:Remove(self, self.OnSelectClick)
end

function WeaponSkinTitleItem:InitWeaponSkinTitleItem(WeaponResId, ParentView, Idx, HeroId)
  if not self.bInited then
    self.bInited = true
  end
  if self.WBP_RedDotView then
    self.WBP_RedDotView:ChangeRedDotIdByTag(HeroId .. WeaponResId)
  end
  self.WeaponResId = WeaponResId
  self.ParentView = ParentView
  self.Idx = Idx
  local bResult, itemData = GetRowData(DT.DT_Item, WeaponResId)
  if not bResult then
    return
  end
  self.RGTextWeaponName:SetText(itemData.Name)
end

function WeaponSkinTitleItem:Hide()
  UpdateVisibility(self, false, true, false)
  self.WeaponResId = -1
  self.ParentView = nil
  self.Idx = -1
end

function WeaponSkinTitleItem:OnSelectClick()
  if UE.RGUtil.IsUObjectValid(self.ParentView) and self.WeaponResId and self.WeaponResId > 0 then
    self.ParentView:OnSkinTitleSelect(self.WeaponResId)
  end
end

return WeaponSkinTitleItem
