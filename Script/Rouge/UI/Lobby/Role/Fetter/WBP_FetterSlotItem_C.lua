local WBP_FetterSlotItem_C = UnLua.Class()
function WBP_FetterSlotItem_C:Construct()
  self.Btn_UnLock.OnClicked:Add(self, WBP_FetterSlotItem_C.BindOnUnLockButtonClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotItemClicked, WBP_FetterSlotItem_C.BindOnFetterSlotItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotStatusUpdate, WBP_FetterSlotItem_C.BindOnFetterSlotStatusUpdate)
end
function WBP_FetterSlotItem_C:BindOnUnLockButtonClicked()
  if self.CanNotClick then
    return
  end
  if DataMgr.IsOwnHero(self.MainHeroId) then
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    EventSystem.Invoke(EventDef.Lobby.FetterSlotItemClicked, self.SlotId)
  end
  if self:IsSlotUnlock() then
  else
    EventSystem.Invoke(EventDef.Lobby.FetterSlotItemClicked, self.SlotId, true)
  end
end
function WBP_FetterSlotItem_C:Show(SlotId, MainHeroId, CanNotClick)
  self.SlotId = SlotId
  self.MainHeroId = MainHeroId
  self.CanNotClick = CanNotClick
  self:RefreshStatus()
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.Img_Hover:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, WBP_FetterSlotItem_C.BindOnFetterHeroInfoUpdate)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroBeginOrEndDrag, WBP_FetterSlotItem_C.BindOnFetterHeroBeginOrEndDrag)
end
function WBP_FetterSlotItem_C:RefreshStatus()
  local SpriteImg = self.UnlockImg
  self.Img_HeroIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Lock:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Txt_Name:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.LobbyStarWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Txt_Name:SetText(tostring(self.SlotId))
  local BottomColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
  local LineColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
  self.Img_AnimBlue:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Img_FX:SetVisibility(UE.ESlateVisibility.Hidden)
  if self:IsSlotUnlock() then
    local SlotHeroId = self:GetCurSlotHeroId()
    if 0 ~= SlotHeroId then
      self.Img_AnimBlue:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      self.Img_FX:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      SpriteImg = nil
      self.Img_HeroIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      local CharacterRow = LogicRole.GetCharacterTableRow(SlotHeroId)
      if CharacterRow then
        self.Txt_Name:SetText(CharacterRow.Name)
        SetImageBrushByPath(self.Img_HeroIcon, CharacterRow.HalfPaintingPath)
        local ResourceInfo
        local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
        if ResourceTable then
          ResourceInfo = ResourceTable[CharacterRow.ResourceId]
        end
        local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
        if DTSubsystem and ResourceInfo then
          local Result, RowInfo = DTSubsystem:GetItemRarityTableRow(ResourceInfo.Rare)
          if Result then
            BottomColor = RowInfo.DisplayNameColor.SpecifiedColor
            LineColor = RowInfo.DisplayNameColor.SpecifiedColor
          end
        end
      end
      self.Txt_Name:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.LobbyStarWidget.MaxStar = LogicRole.GetMaxHeroStar(SlotHeroId)
      self.LobbyStarWidget:UpdateStar(DataMgr.GetHeroLevelByHeroId(SlotHeroId))
      self.LobbyStarWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      SpriteImg = self.UnEquipImg
      BottomColor = UE.FLinearColor(0.147027, 0.184475, 0.198069, 1.0)
    end
  else
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    BottomColor = UE.FLinearColor(0.019382, 0.024158, 0.028426, 1.0)
  end
  if SpriteImg then
    self.Img_Status:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SpriteImg)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Status:SetBrush(Brush)
    end
  else
    self.Img_Status:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.Img_LineQuality:SetColorAndOpacity(LineColor)
  self.Img_BottomQuality:SetColorAndOpacity(BottomColor)
end
function WBP_FetterSlotItem_C:GetCurSlotHeroId()
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(self.MainHeroId)
  local SlotHeroId = 0
  if FetterHeroInfo then
    for i, SingleFetterHeroInfo in ipairs(FetterHeroInfo) do
      if SingleFetterHeroInfo.slot == self.SlotId then
        SlotHeroId = SingleFetterHeroInfo.id
      end
    end
  end
  return SlotHeroId
end
function WBP_FetterSlotItem_C:IsSlotUnlock()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  local SlotStatus = HeroInfo.slots[self.SlotId]
  return SlotStatus and SlotStatus == TableEnums.ENUMSlotStatus.Open or false
end
function WBP_FetterSlotItem_C:BindOnFetterHeroInfoUpdate()
  self:RefreshStatus()
end
function WBP_FetterSlotItem_C:BindOnFetterHeroBeginOrEndDrag(IsBegin)
  if not self:IsSlotUnlock() or 0 == self:GetCurSlotHeroId() then
    return
  end
  if IsBegin then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.ChangeImg)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Status:SetBrush(Brush)
    end
    self.Img_Status:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.Img_Status:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_FetterSlotItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_FetterSlotItem_C.BindOnFetterHeroInfoUpdate, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroBeginOrEndDrag, WBP_FetterSlotItem_C.BindOnFetterHeroBeginOrEndDrag, self)
end
function WBP_FetterSlotItem_C:OnDragEnter(MyGeometry, PointerEvent, Operation)
  if not self:IsSlotUnlock() then
    return
  end
  self:ChangeHoverImgVisibility(true)
  EventSystem.Invoke(EventDef.Lobby.FetterHeroDragCompare, true, self:GetCurSlotHeroId())
end
function WBP_FetterSlotItem_C:OnDragLeave(PointerEvent, Operation)
  if not self:IsSlotUnlock() then
    return
  end
  self:ChangeHoverImgVisibility(false)
  local CurDragId = Operation.Payload.HeroId
  EventSystem.Invoke(EventDef.Lobby.FetterHeroDragCompare, false, 0)
end
function WBP_FetterSlotItem_C:OnDrop(MyGeometry, PointerEvent, Operation)
  Operation.Payload:UpdateDragStatusVis(false)
  if not self:IsSlotUnlock() then
    return true
  end
  local CurHeroId = self:GetCurSlotHeroId()
  if Operation.Payload.HeroId == CurHeroId then
    return true
  end
  Operation.Payload:EquipFetterHeroByPos(self.SlotId)
  return true
end
function WBP_FetterSlotItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.IsHover = true
  self:ChangeHoverImgVisibility(true)
  if self:IsSlotUnlock() then
    local SlotHeroId = self:GetCurSlotHeroId()
    if 0 ~= SlotHeroId then
      EventSystem.Invoke(EventDef.Lobby.RoleFetterSkillTip, true, LogicRole.GetFetterSkillGroupIdByHeroId(SlotHeroId), SlotHeroId)
    end
  end
end
function WBP_FetterSlotItem_C:OnMouseLeave(MouseEvent)
  self.IsHover = false
  self:ChangeHoverImgVisibility(false)
  if self:IsSlotUnlock() then
    local SlotHeroId = self:GetCurSlotHeroId()
    if 0 ~= SlotHeroId then
      EventSystem.Invoke(EventDef.Lobby.RoleFetterSkillTip, false)
    end
  end
end
function WBP_FetterSlotItem_C:ChangeHoverImgVisibility(IsVis)
  if IsVis then
    self.Img_Hover:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.Img_Hover:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_FetterSlotItem_C:BindOnFetterSlotItemClicked(SlotId)
  if self.SlotId == SlotId then
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_FetterSlotItem_C:BindOnFetterSlotStatusUpdate()
  self:RefreshStatus()
end
function WBP_FetterSlotItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotItemClicked, WBP_FetterSlotItem_C.BindOnFetterSlotItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotStatusUpdate, WBP_FetterSlotItem_C.BindOnFetterSlotStatusUpdate, self)
  self:Hide()
end
return WBP_FetterSlotItem_C
