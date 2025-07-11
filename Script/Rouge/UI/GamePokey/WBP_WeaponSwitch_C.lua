local WBP_WeaponSwitch_C = UnLua.Class()
function WBP_WeaponSwitch_C:InitPlayerPrimaryWeapon()
  self.TextBlock_Num:SetText("1")
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local weapon = self:GetWeaponByIndex(pawn, 1)
    if weapon then
      self:SetWeaponInfo(weapon)
    else
      self.Gun = nil
      self:InitChoose(self.Gun)
      self:SetEmpty()
    end
  end
end
function WBP_WeaponSwitch_C:InitPlayerSecondWeapon()
  self.TextBlock_Num:SetText("2")
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local weapon = self:GetWeaponByIndex(pawn, 2)
    if weapon then
      self:SetWeaponInfo(weapon)
    else
      self.Gun = nil
      self:InitChoose(self.Gun)
      self:SetEmpty()
    end
  end
end
function WBP_WeaponSwitch_C:InitCompanionPrimaryWeapon()
  self.TextBlock_Num:SetText("2")
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local companionComp = pawn:GetComponentByClass(UE.UCompanionComponent:StaticClass())
    if companionComp then
      local companionAI = companionComp:GetCompanionAI()
      if companionAI then
        local brush = UE.FSlateBrush()
        brush.ImageSize = self.Image_Companion.Brush.ImageSize
        brush.Margin = self.Image_Companion.Brush.Margin
        brush.TintColor = self.Image_Companion.Brush.TintColor
        brush.ResourceObject = self.InBrushImage
        brush.DrawAs = self.Image_Companion.Brush.DrawAs
        brush.Tiling = self.Image_Companion.Brush.Tiling
        brush.Mirroring = self.Image_Companion.Brush.Mirroring
        self.Image_Companion:SetBrush(brush)
        self:SetVisibility(UE.ESlateVisibility.Collapsed)
        local weapon = self:GetWeaponByIndex(companionAI, 2)
        if weapon then
          self:SetWeaponInfo(weapon)
        else
          self.Gun = nil
          self:InitChoose(self.Gun)
          self:SetEmpty()
        end
      else
        self:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
  end
end
function WBP_WeaponSwitch_C:InitChoose(Gun)
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local equipmentComponent = pawn:GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
    if equipmentComponent then
      local weapon = equipmentComponent:GetCurrentWeapon()
      if weapon == Gun then
        self:SetInUse()
      else
        self:UnsetInUse()
      end
    end
  end
end
function WBP_WeaponSwitch_C:InitInfo()
  if 1 == self.Index then
    self:InitPlayerPrimaryWeapon()
  end
  if 2 == self.Index then
    self:InitPlayerSecondWeapon()
  end
  if 3 == self.Index then
    self:InitCompanionPrimaryWeapon()
  end
  self:SetImageByWeaponType()
end
function WBP_WeaponSwitch_C:SetWeaponInfo(Gun)
  if Gun then
    self.Gun = Gun
    self:SetAmmo(Gun)
    self.HorizontalBox_Weapon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.HorizontalBox_Bullet:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_LockOne:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_LockTwo:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:InitChoose(Gun)
  end
end
function WBP_WeaponSwitch_C:SetAmmo(Gun)
  if Gun then
    self.TextBlock_CurrentBulletNum:SetText(tostring(self.Gun:GetClipAmmo()))
    if Gun:IsInfinite() then
      self.TextBlock_MaxBulletNum:SetText("\226\136\158")
    else
      self.TextBlock_MaxBulletNum:SetText(tostring(self.Gun:GetReserveAmmo()))
    end
  end
end
function WBP_WeaponSwitch_C:SetIndex(Index)
  self.Index = Index
end
function WBP_WeaponSwitch_C:SetEmpty()
  self.HorizontalBox_Weapon:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Image_LockOne:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Image_LockTwo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_WeaponSwitch_C:SetImageByWeaponType()
  if self.Gun then
    local accessoryComponent = self.Gun.AccessoryComponent
    if accessoryComponent then
      local hasBarrel = accessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel)
      local articleId = accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
      local tempItemId
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem then
        if hasBarrel then
          local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(articleId)
          tempItemId = configId
        else
          tempItemId = tostring(self.Gun:GetItemId())
        end
        local itemData = DTSubsystem:K2_GetItemTableRow(tempItemId)
        self:LoadGunIcon(itemData.CompleteGunIcon)
        local result, worldTypeData = DTSubsystem:GetWorldTypeTableRow(itemData.WorldTypeId)
        if result then
          self:LoadWorldIcon(worldTypeData.GunSpriteIcon)
        end
      end
    end
  end
end
function WBP_WeaponSwitch_C:SetInUse()
  self:PlayAnimationReverse(self.SelectedAnimation)
end
function WBP_WeaponSwitch_C:UnsetInUse()
  if self.ToRight then
    self.Overlay_Info:SetRenderTransformPivot(UE.FVector2D(1, 0.5))
  else
    self.Overlay_Info:SetRenderTransformPivot(UE.FVector2D(0, 0.5))
  end
  self:PlayAnimation(self.SelectedAnimation)
end
return WBP_WeaponSwitch_C
