local WBP_FetterPanel_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")
function WBP_FetterPanel_C:Construct()
  self.ListContainer = ListContainer.New(self.ItemTemplate:StaticClass())
  table.insert(self.ListContainer.AllWidgets, self.ItemTemplate)
  self.Btn_Esc.OnClicked:Add(self, WBP_FetterPanel_C.BindOnEscButtonClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroItemLeftClicked, WBP_FetterPanel_C.BindOnFetterHeroItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, WBP_FetterPanel_C.BindOnFetterHeroInfoUpdate)
end
function WBP_FetterPanel_C:BindOnEscButtonClicked()
  if self.OnEscButtonClicked then
    self:OnEscButtonClicked()
  end
end
function WBP_FetterPanel_C:BindOnFetterHeroItemClicked(HeroId)
  if 0 == HeroId then
    self.FetterTips:HidePanel()
    return
  end
  self.CurFetterItemId = HeroId
  local SkillGroupId = LogicRole.GetFetterSkillGroupIdByHeroId(HeroId)
  self.FetterTips:RefreshInfo(SkillGroupId, HeroId, self.CurHeroId)
end
function WBP_FetterPanel_C:RefreshInfo(CurHeroId)
  self.CurHeroId = CurHeroId
  self:RefreshHeroList()
  EventSystem.Invoke(EventDef.Lobby.FetterHeroItemLeftClicked, 0)
end
function WBP_FetterPanel_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  EventSystem.Invoke(EventDef.Lobby.FetterHeroItemLeftClicked, 0)
  return UE.FEventReply()
end
function WBP_FetterPanel_C:RefreshHeroList()
  local HeroList = DataMgr.GetMyHeroInfo()
  self.ListContainer:ClearAllUseWidgets()
  local AllFetterHeroList = {}
  for index, SingleHeroInfo in ipairs(HeroList.heros) do
    local CharacterRow = LogicRole.GetCharacterTableRow(SingleHeroInfo.id)
    if CharacterRow and CharacterRow.CanChoose then
      table.insert(AllFetterHeroList, SingleHeroInfo.id)
    end
  end
  local AllFetterIds = {}
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(self.CurHeroId)
  if FetterHeroInfo then
    for i, SingleFetterInfo in ipairs(FetterHeroInfo) do
      if table.Contain(AllFetterHeroList, SingleFetterInfo.id) then
        table.insert(AllFetterIds, SingleFetterInfo.id)
      end
    end
  end
  table.sort(AllFetterIds, function(AHeroId, BHeroId)
    local AHeroStar = DataMgr.GetHeroLevelByHeroId(AHeroId)
    local BHeroStar = DataMgr.GetHeroLevelByHeroId(BHeroId)
    if AHeroStar == BHeroStar then
      local AFetterSkillGroupId = LogicRole.GetFetterSkillGroupIdByHeroId(AHeroId)
      local BFetterSkillGroupId = LogicRole.GetFetterSkillGroupIdByHeroId(BHeroId)
      local ASkillInfo = LogicRole.GetSkillTableRow(AFetterSkillGroupId)
      local BSkillInfo = LogicRole.GetSkillTableRow(BFetterSkillGroupId)
      if ASkillInfo and BSkillInfo and ASkillInfo[AHeroStar] and BSkillInfo[BHeroStar] then
        return ASkillInfo[AHeroStar].Quality > BSkillInfo[BHeroStar].Quality
      else
        return BHeroId < AHeroId
      end
    else
      return AHeroStar > BHeroStar
    end
  end)
  table.sort(AllFetterHeroList, function(AHeroId, BHeroId)
    local AHeroStar = DataMgr.GetHeroLevelByHeroId(AHeroId)
    local BHeroStar = DataMgr.GetHeroLevelByHeroId(BHeroId)
    if AHeroStar == BHeroStar then
      local AFetterSkillGroupId = LogicRole.GetFetterSkillGroupIdByHeroId(AHeroId)
      local BFetterSkillGroupId = LogicRole.GetFetterSkillGroupIdByHeroId(BHeroId)
      local ASkillInfo = LogicRole.GetSkillTableRow(AFetterSkillGroupId)
      local BSkillInfo = LogicRole.GetSkillTableRow(BFetterSkillGroupId)
      if ASkillInfo and BSkillInfo and ASkillInfo[AHeroStar] and BSkillInfo[BHeroStar] then
        return ASkillInfo[AHeroStar].Quality > BSkillInfo[BHeroStar].Quality
      else
        return BHeroId < AHeroId
      end
    else
      return AHeroStar > BHeroStar
    end
  end)
  for i, SingleHeroId in ipairs(AllFetterIds) do
    local Item = self.ListContainer:GetOrCreateItem()
    self.FetterHeroList:AddChild(Item)
    self.ListContainer:ShowItem(Item, SingleHeroId, self.CurHeroId)
  end
  for i, SingleHeroId in ipairs(AllFetterHeroList) do
    if not table.Contain(AllFetterIds, SingleHeroId) then
      local Item = self.ListContainer:GetOrCreateItem()
      self.FetterHeroList:AddChild(Item)
      self.ListContainer:ShowItem(Item, SingleHeroId, self.CurHeroId)
    end
  end
end
function WBP_FetterPanel_C:BindOnFetterHeroInfoUpdate()
  self:UpdateHeroListPos()
end
function WBP_FetterPanel_C:UpdateHeroListPos()
  if self.CurHeroId then
    self:RefreshHeroList()
  end
  EventSystem.Invoke(EventDef.Lobby.FetterHeroItemLeftClicked, self.CurFetterItemId)
end
function WBP_FetterPanel_C:HidePanel()
  self.ListContainer:ClearAllUseWidgets()
end
function WBP_FetterPanel_C:Destruct()
  self.ListContainer:ClearAllWidgets()
  self.ListContainer = nil
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroItemLeftClicked, WBP_FetterPanel_C.BindOnFetterHeroItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_FetterPanel_C.BindOnFetterHeroInfoUpdate, self)
end
return WBP_FetterPanel_C
