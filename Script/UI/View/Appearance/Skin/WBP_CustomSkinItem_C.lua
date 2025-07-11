local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RedDotData = require("Modules.RedDot.RedDotData")
local WBP_CustomSkinItem_C = UnLua.Class()
function WBP_CustomSkinItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.Btn_Main_OnClicked)
end
function WBP_CustomSkinItem_C:Destruct()
end
function WBP_CustomSkinItem_C:InitInfo(SkinID, ParentView, IsDefault)
  self.SkinID = SkinID
  self.ResID = GetTbSkinRowNameBySkinID(SkinID)
  self.ParentView = ParentView
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, self.ResID)
  self.SkinData = RowInfo
  if Result and not IsDefault then
    UpdateVisibility(self.Img_Icon, true)
    UpdateVisibility(self.Icon_Normal, true)
    UpdateVisibility(self.Dec_Colour, true)
    if RowInfo.IconColor then
      local Color = HexToFLinearColor(RowInfo.IconColor)
      self.Img_Icon:SetColorAndOpacity(Color)
    end
  else
    UpdateVisibility(self.Img_Icon, false)
    UpdateVisibility(self.Icon_Normal, false)
    UpdateVisibility(self.Dec_Colour, false)
    UpdateVisibility(self.Img_Default, true)
  end
end
function WBP_CustomSkinItem_C:Btn_Main_OnClicked()
  if self.ParentView then
    self.ParentView:SelectHeroSkin(self.SkinID, true)
    self.ParentView:UpdateCustomSkinItemSelct(self.SkinID)
  end
end
function WBP_CustomSkinItem_C:SetUnLock(IsUnLock)
  UpdateVisibility(self.Overlay_Lock, not IsUnLock)
end
function WBP_CustomSkinItem_C:SetSel(IsSel)
  UpdateVisibility(self.Overlay_Sel, IsSel)
end
function WBP_CustomSkinItem_C:SetEquip(IsEquip)
  UpdateVisibility(self.Overlay_Equip, IsEquip)
end
return WBP_CustomSkinItem_C
