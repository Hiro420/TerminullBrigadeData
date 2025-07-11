local rapidjson = require("rapidjson")
local WBP_WeaponHandBookItem_C = UnLua.Class()
function WBP_WeaponHandBookItem_C:Construct()
end
function WBP_WeaponHandBookItem_C:Destruct()
  self.SelectCallback = nil
end
function WBP_WeaponHandBookItem_C:OnListItemObjectSet(ListItemObj)
  self.DataObj = ListItemObj
  self.WeaponBarrelId = ListItemObj.WeaponBarrelId
  local Item = LogicWeaponHandBook:GetItemDataByRowName(tostring(self.WeaponBarrelId))
  if Item then
    self.RGTextSelectName:SetText(Item.Name)
  end
  self.URGImageUnSelectBg:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.URGImageSelectBg:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.RGTextSelectName:SetColorAndOpacity(self.UnSelectColor)
  local Result, WeaponHandBook = LogicWeaponHandBook:GetWeaponHandBookDataByRowName(self.WeaponBarrelId)
  if WeaponHandBook then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WeaponHandBook.WeaponBarrelImg)
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.URGImageIcon:SetBrush(Brush)
    if LogicWeaponHandBook:CheckWeaponUnLock(WeaponHandBook) then
      self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function WBP_WeaponHandBookItem_C:BP_OnEntryReleased()
  self.DataObj = nil
end
function WBP_WeaponHandBookItem_C:BP_OnItemSelectionChanged(bIsSelected)
  print("WBP_WeaponHandBookItem_C:BP_OnItemSelectionChanged", bIsSelected)
  if bIsSelected then
    if self.DataObj and self.DataObj.Select then
      self.DataObj.Select:Broadcast(self.WeaponBarrelId)
    end
    self.RGTextSelectName:SetColorAndOpacity(self.SelectColor)
    self.URGImageUnSelectBg:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.URGImageSelectBg:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.URGImageUnSelectBg:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.URGImageSelectBg:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.RGTextSelectName:SetColorAndOpacity(self.UnSelectColor)
  end
end
return WBP_WeaponHandBookItem_C
