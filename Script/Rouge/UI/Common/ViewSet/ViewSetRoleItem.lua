local ViewSetRoleItem = UnLua.Class()
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
function ViewSetRoleItem:Construct()
  self.OnRGToggleStateChanged:Bind(self, self.BindOnChangeRoleItemClicked)
  self.MainButton.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.MainButton.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function ViewSetRoleItem:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.RoleItemClicked, self.CharacterId)
end
function ViewSetRoleItem:BindOnMainButtonHovered()
  UpdateVisibility(self.HoveredPanel, true)
end
function ViewSetRoleItem:BindOnMainButtonUnhovered()
  UpdateVisibility(self.HoveredPanel, false)
end
function ViewSetRoleItem:BindOnChangeRoleItemClicked(bIsChecked, CharacterId)
  if bIsChecked then
    self:SetSelectStatus(self.CharacterId == CharacterId)
    self.LastSelectCharacterId = CharacterId
  end
end
function ViewSetRoleItem:RefreshProfyData()
  if not self.CharacterId then
    return
  end
  local MaxUnLockLevel = ProficiencyData:GetMaxUnlockProfyLevel(self.CharacterId)
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(self.CharacterId)
  self.RGTextProfyLv:SetText(MaxUnLockLevel)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, MaxUnLockLevel)
  if Result and not UE.UKismetStringLibrary.IsEmpty(RowInfo.HeadFrameIconPath) then
    UpdateVisibility(self.Img_ProfyHeadFrame, true)
    SetImageBrushByPath(self.Img_ProfyHeadFrame, RowInfo.HeadFrameIconPath)
  else
    UpdateVisibility(self.Img_ProfyHeadFrame, false)
  end
  if MaxUnLockLevel == MaxLevel then
    UpdateVisibility(self.Bg_BigAward_Recieved, true)
    UpdateVisibility(self.URGImage_BigAward_Recieved, true)
  else
    UpdateVisibility(self.Bg_BigAward_Recieved, false)
    UpdateVisibility(self.URGImage_BigAward_Recieved, false)
  end
end
function ViewSetRoleItem:SetSelectStatus(IsSelect)
  self:StopAllAnimations()
  local EndTime = self.Ani_click_out:GetEndTime()
  self:PlayAnimationTimeRange(self.Ani_click_out, EndTime, EndTime, 1, UE.EUMGSequencePlayMode.Forward, 1.0)
  if IsSelect then
    UpdateVisibility(self.Img_SelectMark, true)
    self:SetRenderScale(self.SelectedMagnification)
    self.ClickedIconPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimationForward(self.Ani_click_in)
  else
    self.Img_SelectMark:SetVisibility(UE.ESlateVisibility.Hidden)
    self:SetRenderScale(UE.FVector2D(1.0, 1.0))
    self.ClickedIconPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    if self.LastSelectCharacterId ~= nil and self.LastSelectCharacterId == self.CharacterId then
      self:PlayAnimationForward(self.Ani_click_out)
    end
  end
end
function ViewSetRoleItem:InitViewSetRoleItem(HeroId, bIsShowEquiped, bIsSelect, RedDotClass)
  self:OnSelect(false)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.CharacterId = HeroId
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:UpdatePlayerImage(HeroId)
  self:UpdateLockStatus()
  self:UpdateEquipStatus(bIsShowEquiped)
  self:SetSelectStatus(bIsSelect)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.RefreshProfyData)
  self:RefreshProfyData()
  if RedDotClass then
    self.WBP_RedDotView.RedDotClass = RedDotClass
    self.WBP_RedDotView:ChangeRedDotIdByTag(self.CharacterId)
  end
end
function ViewSetRoleItem:InitRedDotInfo()
end
function ViewSetRoleItem:UpdatePlayerImage(HeroId)
  local CharacterInfo = LogicRole.GetCharacterTableRow(HeroId)
  if not CharacterInfo then
    return
  end
  local SoftObjRef = MakeStringToSoftObjectReference(CharacterInfo.ActorIcon)
  if not UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
    return
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef):Cast(UE.UPaperSprite)
  if IconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Img_HeadIcon:SetBrush(Brush)
  end
end
function ViewSetRoleItem:UpdateLockStatus()
  if DataMgr.IsOwnHero(self.CharacterId) then
    self.LockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_kuang:SetRenderOpacity(1.0)
    self.Img_HeadIcon:SetRenderOpacity(1.0)
    local ExpireAt = DataMgr.IsLimitedHeroe(self.CharacterId)
    if ExpireAt then
      self.RGStateControllerLock:ChangeStatus("ForALimitedTime", true)
      self.WBP_CommonCountdown:SetTargetTimestamp(ExpireAt)
    else
    end
  else
    self.LockPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Image_kuang:SetRenderOpacity(self.LockOpacity)
    self.Img_HeadIcon:SetRenderOpacity(self.HeadIconLockOpacity)
  end
end
function ViewSetRoleItem:UpdateEquipStatus(bIsShowEquiped)
  if not bIsShowEquiped then
    local HeroInfo = DataMgr.GetMyHeroInfo()
    if HeroInfo.equipHero == self.CharacterId then
      self.SelectPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SelectPanel:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end
function ViewSetRoleItem:Hide()
  self.CharacterId = 0
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.RefreshProfyData)
end
return ViewSetRoleItem
