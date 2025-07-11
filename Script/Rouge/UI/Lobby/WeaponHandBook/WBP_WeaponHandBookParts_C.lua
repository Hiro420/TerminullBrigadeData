local rapidjson = require("rapidjson")
local WBP_WeaponHandBookParts_C = UnLua.Class()
function WBP_WeaponHandBookParts_C:Construct()
end
function WBP_WeaponHandBookParts_C:Destruct()
  self.MouseEnterFunc = nil
  self.ParentView = nil
end
function WBP_WeaponHandBookParts_C:Init(AccessoryId, Rare, MouseEnterFunc, ParentView)
  UpdateVisibility(self, true)
  self.MouseEnterFunc = MouseEnterFunc
  self.ParentView = ParentView
  self.AccessoryId = AccessoryId
  if AccessoryId < 0 then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(nil, 0, 0)
    self.URGImagePartsIcon:SetBrush(Brush)
  else
    local ItemData = LogicWeaponHandBook:GetItemDataByRowName(tostring(AccessoryId))
    if ItemData then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.SpriteIcon)
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.URGImagePartsIcon:SetBrush(Brush)
    end
  end
  local _, RareData = LogicWeaponHandBook:GetItemRarityByRare(Rare)
  if RareData then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(RareData.AccessoryRareBg)
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.URGImageRareBg:SetBrush(Brush)
  end
  self.URGImageSelect:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_WeaponHandBookParts_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_WeaponHandBookParts_C:OnMouseEnter(MyGeometry, MouseEvent)
  if -1 == self.AccessoryId then
    return
  end
  if self.MouseEnterFunc then
    self.MouseEnterFunc(self.ParentView, self, self.AccessoryId, true)
  end
end
function WBP_WeaponHandBookParts_C:OnMouseLeave(MouseEvent)
  if self.MouseEnterFunc then
    self.MouseEnterFunc(self.ParentView, self, self.AccessoryId, false)
  end
end
return WBP_WeaponHandBookParts_C
