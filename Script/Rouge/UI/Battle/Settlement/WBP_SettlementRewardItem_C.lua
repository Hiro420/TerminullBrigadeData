local WBP_SettlementRewardItem_C = UnLua.Class()

function WBP_SettlementRewardItem_C:Construct()
  self.ResourceId = 0
end

function WBP_SettlementRewardItem_C:Init(PresetWeaponId, ParentView, ShowWeaponFunc)
  UpdateVisibility(self.Img_Selected, false)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local ItemData
    local ToralResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPresetWeaponRes)
    if ToralResourceTable and ToralResourceTable[PresetWeaponId] then
      local BarrelId = ToralResourceTable[PresetWeaponId].BarrelID
      local WeaponId = ToralResourceTable[PresetWeaponId].WeaponID
      if BarrelId and BarrelId > 0 then
        ItemData = DTSubsystem:K2_GetItemTableRow(tostring(BarrelId))
      elseif WeaponId and WeaponId > 0 then
        ItemData = DTSubsystem:K2_GetItemTableRow(tostring(WeaponId))
      end
    end
    if ItemData then
      self.ResourceId = tonumber(ItemData.ID)
      local GunIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.CompleteGunIcon)
      if GunIconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(GunIconObj, 0, 0)
        if Brush then
          self.URGImageIcon:SetBrush(Brush)
        end
      end
      self.RGTextWeaponName:SetText(ItemData.Name)
    end
    local Result, WorldRowInfo = DTSubsystem:GetWorldTypeTableRow(ItemData.WorldTypeId)
    if Result then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldRowInfo.GunSpriteIcon)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.Img_WorldType:SetBrush(Brush)
      end
      local WeaponSlotIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldRowInfo.WeaponSlotBackSpriteIcon)
      if WeaponSlotIconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(WeaponSlotIconObj, 0, 0)
        self.URGImageBg:SetBrush(Brush)
      end
    end
  end
  self.ParentView = ParentView
  self.ShowWeaponFunc = ShowWeaponFunc
  self.PresetWeaponId = PresetWeaponId
  self:SetElementInfo()
end

function WBP_SettlementRewardItem_C:SetElementInfo()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ElementEffectList = {}
  local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(self.ResourceId, nil)
  if Result then
    ElementEffectList = AccessoryRowInfo.ElementEffectList
  end
  local TargetElementEffectId
  for i, SingleElementEffectId in pairs(ElementEffectList) do
    TargetElementEffectId = SingleElementEffectId
    break
  end
  local ElementType = 0
  local ElementValue = 0
  if TargetElementEffectId then
    local Result, EffectRowInfo = self:GetElementEffectRowInfo(tostring(TargetElementEffectId))
    if Result then
      ElementType = EffectRowInfo.ElementType
      ElementValue = EffectRowInfo.ElementEffectChance
    end
  end
  if 0 == ElementType then
    self.Img_ElementIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Img_ElementIcon:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local Result, ElementData = DTSubsystem:GetElementInfoTableRow(ElementType)
    if Result then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ElementData.SpriteIcon)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.Img_ElementIcon:SetBrush(Brush)
      end
    end
  end
end

function WBP_SettlementRewardItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Img_Selected, true)
  self.ShowWeaponFunc(self.ParentView, true, self.PresetWeaponId, self)
end

function WBP_SettlementRewardItem_C:OnMouseLeave(MouseEvent)
  UpdateVisibility(self.Img_Selected, false)
  self.ShowWeaponFunc(self.ParentView, false, self.PresetWeaponId, self)
end

function WBP_SettlementRewardItem_C:UnInit()
end

function WBP_SettlementRewardItem_C:Destruct()
  self.ParentView = nil
  self.ShowWeaponFunc = nil
  self.PresetWeaponId = 0
end

return WBP_SettlementRewardItem_C
