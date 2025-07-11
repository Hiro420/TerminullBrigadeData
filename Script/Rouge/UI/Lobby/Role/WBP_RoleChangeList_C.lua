local WBP_RoleChangeList_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")
local rapidjson = require("rapidjson")
function WBP_RoleChangeList_C:Construct()
  self.ListContainer = ListContainer.New(self.ItemTemplate:StaticClass())
  table.insert(self.ListContainer.AllWidgets, self.ItemTemplate)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, WBP_RoleChangeList_C.BindOnUpdateMyHeroInfo)
  self:RefreshRoleList(-1)
end
function WBP_RoleChangeList_C:RefreshRoleList(SelectIndex)
  self.RoleList:ClearChildren()
  self.ListContainer:ClearAllUseWidgets()
  local AllCharacterList = LogicRole.GetAllCanSelectCharacterList()
  if self.CustomSortHeroList then
    table.sort(AllCharacterList, self.CustomSortHeroList)
  else
    table.sort(AllCharacterList, function(A, B)
      return A < B
    end)
  end
  local SelectHeroId = -1
  for i, SingleHeroId in ipairs(AllCharacterList) do
    if self.EliminateFunc and self.EliminateFunc(SingleHeroId) then
      local Item = self.ListContainer:GetOrCreateItem()
      self.ListContainer:HideItem(Item)
    else
      local Item = self.ListContainer:GetOrCreateItem()
      self.ListContainer:ShowItem(Item, SingleHeroId, self.bIsShowItemEquiped)
      self.RoleList:AddChild(Item)
      Item:InitRedDotInfo()
      local scrollBoxBoxSlot = UE.UWidgetLayoutLibrary.SlotAsScrollBoxSlot(Item)
      scrollBoxBoxSlot:SetPadding(self.RoleItemPadding)
      if SelectIndex == i then
        SelectHeroId = SingleHeroId
      end
    end
  end
  if SelectHeroId > 0 then
    EventSystem.Invoke(EventDef.Lobby.RoleItemClicked, SelectHeroId)
  end
end
function WBP_RoleChangeList_C:UnfocusInput()
end
function WBP_RoleChangeList_C:ShowPanel(HeroId)
  self:PlayInAnimation()
  if HeroId > 0 then
    EventSystem.Invoke(EventDef.Lobby.RoleItemClicked, HeroId, nil, true)
  end
end
function WBP_RoleChangeList_C:ShowPanelByIndex(Index, EliminateFunc, SortHeroListFunc, bIsShowItemEquiped)
  self.EliminateFunc = EliminateFunc
  self.CustomSortHeroList = SortHeroListFunc
  self.bIsShowItemEquiped = bIsShowItemEquiped
  self:RefreshRoleList(Index)
end
function WBP_RoleChangeList_C:BindOnUpdateMyHeroInfo()
  self:UpdateRoleItemStatus()
end
function WBP_RoleChangeList_C:BindOnUpgradeButtonClicked()
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Role/WBP_RoleUpgradePanel.WBP_RoleUpgradePanel_C")
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:Switch(WidgetClass, true)
  local Widget = UIManager:K2_GetUI(WidgetClass)
  if Widget then
    Widget:InitInfo(self.CurSelectHeroId)
  end
end
function WBP_RoleChangeList_C:UpdateRoleItemStatus()
  local ItemList = self.ListContainer:GetAllUseWidgetsList()
  for i, SingleItem in ipairs(ItemList) do
    SingleItem:UpdateLockStatus()
    SingleItem:UpdateSelectStatus()
    SingleItem:UpdateExpireAt()
  end
end
function WBP_RoleChangeList_C:UpdateSelectStatusToTargetHero(HeroId)
  local ItemList = self.ListContainer:GetAllUseWidgetsList()
  for i, SingleItem in ipairs(ItemList) do
    SingleItem:UpdateSelectStatusToTargetHero(HeroId)
  end
end
function WBP_RoleChangeList_C:Destruct()
  print("RoleChangeListDestruct")
  self.ListContainer:ClearAllWidgets()
  self.ListContainer = nil
  self.EliminateFunc = nil
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_RoleChangeList_C.BindOnUpdateMyHeroInfo, self)
end
return WBP_RoleChangeList_C
