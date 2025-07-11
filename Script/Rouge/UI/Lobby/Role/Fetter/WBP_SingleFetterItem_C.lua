local WBP_SingleFetterItem_C = UnLua.Class()
function WBP_SingleFetterItem_C:Construct()
  self.MainBtn.OnClicked:Add(self, WBP_SingleFetterItem_C.BindOnMainButtonClicked)
end
function WBP_SingleFetterItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.FetterHeroItemLeftClicked, self.HeroId)
end
function WBP_SingleFetterItem_C:Show(HeroId, MainHeroId)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.HeroId = HeroId
  self.MainHeroId = MainHeroId
  local CharacterRow = LogicRole.GetCharacterTableRow(self.HeroId)
  self.MainItem:Init(CharacterRow.ResourceId, self.HeroId)
  self:RefreshStatus()
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroItemLeftClicked, WBP_SingleFetterItem_C.BindOnFetterHeroItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, WBP_SingleFetterItem_C.BindOnUpdateMyHeroInfo)
end
function WBP_SingleFetterItem_C:BindOnFetterHeroItemClicked(HeroId)
  self.MainItem:UpdateSelect(HeroId == self.HeroId)
end
function WBP_SingleFetterItem_C:BindOnUpdateMyHeroInfo()
  self.MainItem:UpdateStar()
end
function WBP_SingleFetterItem_C:RefreshStatus()
  self.EquippedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CanNotEquipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.MainItem:UpdateUnLockOpacity(1.0)
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(self.MainHeroId)
  if self.HeroId == self.MainHeroId then
    self.CanNotEquipPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.MainItem:UpdateUnLockOpacity(0.6)
  else
    for i, SingleFetterInfo in ipairs(FetterHeroInfo) do
      if SingleFetterInfo.id == self.HeroId then
        self.EquippedPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
        self.MainItem:UpdateUnLockOpacity(0.6)
        break
      end
    end
  end
end
function WBP_SingleFetterItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroItemLeftClicked, WBP_SingleFetterItem_C.BindOnFetterHeroItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_SingleFetterItem_C.BindOnUpdateMyHeroInfo, self)
end
function WBP_SingleFetterItem_C:Destruct()
  self:Hide()
end
return WBP_SingleFetterItem_C
