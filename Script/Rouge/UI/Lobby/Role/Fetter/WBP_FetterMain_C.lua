local ListContainer = require("Rouge.UI.Common.ListContainer")
local WBP_FetterMain_C = UnLua.Class()

function WBP_FetterMain_C:Construct()
  self.ListContainer = ListContainer.New(UE.UGameplayStatics.GetObjectClass(self.FetterHeroItemTemplate))
  table.insert(self.ListContainer.AllWidgets, self.FetterHeroItemTemplate)
  self.FetterSlotListContainer = ListContainer.New(UE.UGameplayStatics.GetObjectClass(self.SlotItemTemplate))
  table.insert(self.FetterSlotListContainer.AllWidgets, self.SlotItemTemplate)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroItemLeftClicked, WBP_FetterMain_C.BindOnFetterHeroItemLeftMouseDown)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroDragCompare, WBP_FetterMain_C.BindOnFetterHeroDragCompare)
end

function WBP_FetterMain_C:InitInfo(HeroId)
  self.CurHeroId = HeroId
  self:InitFetterHeroList()
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_FetterMain_C.InitFetterSlotList
  }, 0.01, false)
  LogicRole.InitMainFetterHeroMesh(self.CurHeroId)
  LogicRole.InitFetterHeroesMesh(self.CurHeroId)
end

function WBP_FetterMain_C:InitFetterHeroList()
  local HeroList = DataMgr.GetMyHeroInfo()
  self.ListContainer:ClearAllUseWidgets()
  local AllFetterHeroList = {}
  for index, SingleHeroInfo in ipairs(HeroList.heros) do
    table.insert(AllFetterHeroList, SingleHeroInfo.id)
  end
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
  for i, SingleHeroId in ipairs(AllFetterHeroList) do
    if self.CurHeroId ~= SingleHeroId then
      local Item = self.ListContainer:GetOrCreateItem()
      self.FetterHeroList:AddChild(Item)
      self.ListContainer:ShowItem(Item, SingleHeroId, self.CurHeroId)
    end
  end
end

function WBP_FetterMain_C:InitFetterSlotList()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local TargetActor
  self.FetterSlotListContainer:ClearAllUseWidgets()
  local AllFetterSlotIds = LogicRole.GetAllFetterSlotIds()
  for i, SingleSlotId in ipairs(AllFetterSlotIds) do
    local Item = self.FetterSlotListContainer:GetOrCreateItem()
    if Item:GetParent() ~= self.SlotPanel then
      self.SlotPanel:AddChild(Item)
    end
    local ItemSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    ItemSlot:SetAlignment(UE.FVector2D(0.5, 1.0))
    TargetActor = LogicRole.FetterList[SingleSlotId]
    if TargetActor then
      local Location = TargetActor:K2_GetActorLocation()
      local bResult, ViewportPos = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PC, Location, nil, false)
      ViewportPos.Y = ViewportPos.Y - 300
      ItemSlot:SetAutoSize(true)
      ItemSlot:SetPosition(ViewportPos)
    end
    self.FetterSlotListContainer:ShowItem(Item, SingleSlotId, self.CurHeroId)
  end
end

function WBP_FetterMain_C:BindOnFetterHeroItemLeftMouseDown(HeroId)
end

function WBP_FetterMain_C:BindOnFetterHeroDragCompare(IsDrag, CompareHeroId)
end

function WBP_FetterMain_C:Destruct()
  self.ListContainer:ClearAllWidgets()
  self.ListContainer = nil
  self.FetterSlotListContainer:ClearAllWidgets()
  self.FetterSlotListContainer = nil
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroItemLeftClicked, WBP_FetterMain_C.BindOnFetterHeroItemLeftMouseDown)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroDragCompare, WBP_FetterMain_C.BindOnFetterHeroDragCompare)
end

return WBP_FetterMain_C
