local WBP_SingleQuickFetterItem_C = UnLua.Class()
function WBP_SingleQuickFetterItem_C:Construct()
  self.Btn_Main.OnHovered:Add(self, WBP_SingleQuickFetterItem_C.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, WBP_SingleQuickFetterItem_C.BindOnMainButtonUnHovered)
  self.Btn_Main.OnClicked:Add(self, WBP_SingleQuickFetterItem_C.BindOnMainButtonClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotItemClicked, WBP_SingleQuickFetterItem_C.BindOnFetterSlotItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotStatusUpdate, WBP_SingleQuickFetterItem_C.BindOnFetterSlotStatusUpdate)
end
function WBP_SingleQuickFetterItem_C:BindOnMainButtonHovered()
  if LogicRole.IsSlotUnlock(self.SlotIndex) then
    local SlotHeroId = LogicRole.GetCurSlotHeroId(self.MainHeroId, self.SlotIndex)
    if 0 ~= SlotHeroId then
      EventSystem.Invoke(EventDef.Lobby.RoleFetterSkillTip, true, LogicRole.GetFetterSkillGroupIdByHeroId(SlotHeroId), SlotHeroId)
    end
  end
  self.Img_Hover:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end
function WBP_SingleQuickFetterItem_C:BindOnMainButtonUnHovered()
  if LogicRole.IsSlotUnlock(self.SlotIndex) then
    local SlotHeroId = LogicRole.GetCurSlotHeroId(self.MainHeroId, self.SlotIndex)
    if 0 ~= SlotHeroId then
      EventSystem.Invoke(EventDef.Lobby.RoleFetterSkillTip, false)
    end
  end
  self.Img_Hover:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_SingleQuickFetterItem_C:BindOnMainButtonClicked()
  if not DataMgr.IsOwnHero(self.MainHeroId) then
    return
  end
  if self:IsSlotUnlock() then
    EventSystem.Invoke(EventDef.Lobby.FetterSlotItemClicked, self.SlotIndex)
  else
    EventSystem.Invoke(EventDef.Lobby.FetterSlotItemClicked, self.SlotIndex, true)
  end
end
function WBP_SingleQuickFetterItem_C:BindOnFetterSlotStatusUpdate()
  self:RefreshStatus()
end
function WBP_SingleQuickFetterItem_C:BindOnFetterHeroInfoUpdate()
  self:RefreshStatus()
end
function WBP_SingleQuickFetterItem_C:BindOnFetterSlotItemClicked(SlotId)
end
function WBP_SingleQuickFetterItem_C:Show(SlotIndex, HeroId, CanNotClick)
  self.MainHeroId = HeroId
  self.SlotIndex = SlotIndex
  self.CanNotClick = CanNotClick
  self:RefreshStatus()
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotItemClicked, WBP_SingleQuickFetterItem_C.BindOnFetterSlotItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotStatusUpdate, WBP_SingleQuickFetterItem_C.BindOnFetterSlotStatusUpdate)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, WBP_SingleQuickFetterItem_C.BindOnFetterHeroInfoUpdate)
end
function WBP_SingleQuickFetterItem_C:RefreshStatus()
  self.MainItem:SetVisibility(UE.ESlateVisibility.Hidden)
  self.EmptyPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  self.LockPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  if not LogicRole.IsSlotUnlock(self.SlotIndex) then
    self.LockPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    local SlotHeroId = LogicRole.GetCurSlotHeroId(self.MainHeroId, self.SlotIndex)
    if 0 == SlotHeroId then
      self.EmptyPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.MainItem:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      local CharacterRow = LogicRole.GetCharacterTableRow(SlotHeroId)
      self.MainItem:Init(CharacterRow.ResourceId, SlotHeroId)
    end
  end
end
function WBP_SingleQuickFetterItem_C:IsSlotUnlock()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  local SlotStatus = HeroInfo.slots[self.SlotIndex]
  return SlotStatus and SlotStatus == TableEnums.ENUMSlotStatus.Open or false
end
function WBP_SingleQuickFetterItem_C:Hide()
  self.HeroId = 0
  self.CanNotClick = false
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotItemClicked, WBP_SingleQuickFetterItem_C.BindOnFetterSlotItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotStatusUpdate, WBP_SingleQuickFetterItem_C.BindOnFetterSlotStatusUpdate, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_SingleQuickFetterItem_C.BindOnFetterHeroInfoUpdate, self)
end
function WBP_SingleQuickFetterItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotItemClicked, WBP_SingleQuickFetterItem_C.BindOnFetterSlotItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotStatusUpdate, WBP_SingleQuickFetterItem_C.BindOnFetterSlotStatusUpdate, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_SingleQuickFetterItem_C.BindOnFetterHeroInfoUpdate, self)
end
return WBP_SingleQuickFetterItem_C
