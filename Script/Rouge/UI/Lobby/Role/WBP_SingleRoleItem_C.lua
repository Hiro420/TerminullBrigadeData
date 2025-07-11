local WBP_SingleRoleItem_C = UnLua.Class()
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
function WBP_SingleRoleItem_C:Construct()
  self.MainButton.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.MainButton.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.MainButton.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function WBP_SingleRoleItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.RoleItemClicked, self.CharacterId)
  NotifyObjectMessage(nil, "Hero.LobbySelect", self.CharacterId)
  self.WBP_RedDotView:BindOnClick()
  self.WBP_RedDotView_Lock:SetNum(0)
end
function WBP_SingleRoleItem_C:BindOnMainButtonHovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end
function WBP_SingleRoleItem_C:BindOnMainButtonUnhovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_SingleRoleItem_C:BindOnChangeRoleItemClicked(CharacterId)
  self:SetSelectStatus(self.CharacterId == CharacterId)
  self.LastSelectCharacterId = CharacterId
end
function WBP_SingleRoleItem_C:RefreshProfyData()
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
function WBP_SingleRoleItem_C:SetSelectStatus(IsSelect)
  if self.Select == IsSelect then
    return
  end
  self.Select = IsSelect
  self:StopAllAnimations()
  local EndTime = self.Ani_click_out:GetEndTime()
  self:PlayAnimationTimeRange(self.Ani_click_out, EndTime, EndTime, 1, UE.EUMGSequencePlayMode.Forward, 1.0)
  if IsSelect then
    UpdateVisibility(self.Img_SelectMark, true)
    self:SetRenderScale(self.SelectedMagnification)
    self.ClickedIconPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimationForward(self.Ani_click_in)
    self.SizeBoxRoot:SetWidthOverride(self.SelectSizeX)
  else
    self.Img_SelectMark:SetVisibility(UE.ESlateVisibility.Hidden)
    self:SetRenderScale(UE.FVector2D(1.0, 1.0))
    self.ClickedIconPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    if self.LastSelectCharacterId ~= nil and self.LastSelectCharacterId == self.CharacterId then
      self:PlayAnimationForward(self.Ani_click_out)
      self.SizeBoxRoot:SetWidthOverride(self.UnSelectSizeX)
    end
  end
end
function WBP_SingleRoleItem_C:Show(HeroId, bIsShowEquiped)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.CharacterId = HeroId
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:UpdatePlayerImage(HeroId)
  self:UpdateLockStatus()
  self:UpdateSelectStatus(bIsShowEquiped)
  self:UpdateEquipedStatus(bIsShowEquiped)
  self:UpdateExpireAt()
  EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, self.BindOnChangeRoleItemClicked)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.RefreshProfyData)
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if tbHeroMonster and tbHeroMonster[HeroId] and tbHeroMonster[HeroId].TagIcon then
    SetImageBrushByPath(self.URGImageTag, tbHeroMonster[HeroId].TagIcon)
  end
  self:RefreshProfyData()
end
function WBP_SingleRoleItem_C:UpdateExpireAt()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  for index, value in ipairs(HeroInfo.heros) do
    if self.CharacterId == value.id and value.expireAt ~= nil and value.expireAt ~= "0" and value.expireAt ~= "" and value.expireAt ~= "1" then
      self.RGStateControllerLock:ChangeStatus("ForALimitedTime", true)
      self.WBP_CommonExpireAt:InitCommonExpireAt(value.expireAt)
      self.WBP_CommonCountdown:SetTargetTimestamp(value.expireAt)
    end
  end
end
function WBP_SingleRoleItem_C:InitRedDotInfo()
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.CharacterId)
  self.WBP_RedDotView_Lock:ChangeRedDotIdByTag(self.CharacterId)
end
function WBP_SingleRoleItem_C:UpdatePlayerImage(HeroId)
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
function WBP_SingleRoleItem_C:UpdateLockStatus()
  if DataMgr.IsOwnHero(self.CharacterId) then
    self.LockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_kuang:SetRenderOpacity(1.0)
    self.Img_HeadIcon:SetRenderOpacity(1.0)
    self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
  else
    self.LockPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Image_kuang:SetRenderOpacity(self.LockOpacity)
    self.Img_HeadIcon:SetRenderOpacity(self.HeadIconLockOpacity)
    self.RGStateControllerLock:ChangeStatus(ELock.Lock)
  end
end
function WBP_SingleRoleItem_C:UpdateSelectStatus(bIsShowEquiped)
  if not bIsShowEquiped then
    local HeroInfo = DataMgr.GetMyHeroInfo()
    if HeroInfo.equipHero == self.CharacterId then
      self.SelectPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SelectPanel:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end
function WBP_SingleRoleItem_C:UpdateSelectStatusToTargetHero(HeroId)
  if self.CharacterId == HeroId then
    self.SelectPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SelectPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_SingleRoleItem_C:UpdateEquipedStatus(bIsShowEquiped)
  if bIsShowEquiped then
    self.SelectPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.EquipedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    if LogicSoulCore:CheckCantEquipSoulCore(self.CharacterId) then
      self:SetIsEnabled(false)
      self.TextBlockEquiped:SetText("\228\184\141\229\143\175\230\144\173\232\189\189")
      self.EquipedPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetIsEnabled(true)
      local AllFetterSlotIds = LogicRole.GetAllFetterSlotIds()
      for i, v in ipairs(AllFetterSlotIds) do
        local SlotHeroId = LogicRole.GetCurSlotHeroId(self.CharacterId, v)
        if SlotHeroId > 0 and LogicSoulCore.CurSelectSoulCoreId == SlotHeroId then
          self.TextBlockEquiped:SetText("\229\183\178\230\144\173\232\189\189")
          self.EquipedPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
          break
        end
      end
    end
  end
end
function WBP_SingleRoleItem_C:Hide()
  self.WBP_RedDotView:ChangeRedDotIdByTag(-1)
  self.WBP_RedDotView_Lock:ChangeRedDotIdByTag(-1)
  self.CharacterId = 0
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, WBP_SingleRoleItem_C.BindOnChangeRoleItemClicked, self)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.RefreshProfyData)
end
return WBP_SingleRoleItem_C
