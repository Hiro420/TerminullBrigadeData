local HeirloomInfoPanelView = UnLua.Class()
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local HeirloomHandler = require("Protocol.Appearance.Heirloom.HeirloomHandler")

function HeirloomInfoPanelView:Show(HeirloomId)
  if not HeirloomId or -1 == HeirloomId then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  if HeirloomData:IsUnLockHeirloomDataEmpty() then
    HeirloomHandler:RequestGetFamilytreasureToServer()
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.TargetHeirloomId = HeirloomId
  EventSystem.AddListener(self, EventDef.Heirloom.OnChangeHeirloomLevelSelected, self.BindOnChangeHeirloomLevelSelected)
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.BindOnHeirloomSelectedItemChanged)
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomInfoChanged, self.BindOnHeirloomInfoChanged)
  self:RefreshHeirloomLevelList()
end

function HeirloomInfoPanelView:BindOnHeirloomInfoChanged()
  self:RefreshHeirloomLevelItemLockStatus()
end

function HeirloomInfoPanelView:RefreshHeirloomLevelList()
  local MaxHeirloomLevel = HeirloomData:GetHeirloomMaxLevel(self.TargetHeirloomId)
  if 0 == MaxHeirloomLevel then
    print("HeirloomInfoPanelView:RefreshHeirloomLevelList MaxLevel is 0!, HeirloomId:", self.TargetHeirloomId)
    self.HeirloomLevelList:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self.HeirloomLevelList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local Item
  for i = 1, MaxHeirloomLevel do
    Item = GetOrCreateItem(self.HeirloomLevelList, i, self.HeirloomLevelItemTemplate:StaticClass())
    Item:Show(self.TargetHeirloomId, i)
  end
  HideOtherItem(self.HeirloomLevelList, MaxHeirloomLevel + 1)
  local MaxUnLockLevel = HeirloomData:GetMaxUnLockHeirloomLevel(self.TargetHeirloomId)
  if 0 == MaxUnLockLevel then
    MaxUnLockLevel = 1
  end
  EventSystem.Invoke(EventDef.Heirloom.OnChangeHeirloomLevelSelected, self.TargetHeirloomId, MaxUnLockLevel)
end

function HeirloomInfoPanelView:BindOnChangeHeirloomLevelSelected(HeirloomId, Level)
  if HeirloomId == HeirloomData:GetCurSelectHeirloomId() and Level == HeirloomData:GetCurSelectLevel() then
    print("HeirloomInfoPanelView:BindOnChangeHeirloomLevelSelected \229\144\140\230\160\183\231\154\132\233\128\137\230\139\169")
    return
  end
  HeirloomData:SetCurSelectHeirloomIdAndLevel(HeirloomId, Level)
  local AllChildren = self.HeirloomLevelList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshSelectedStatus()
  end
  self:RefreshHeirloomChildItemList(HeirloomId, Level)
  EventSystem.Invoke(EventDef.Heirloom.OnAfterChangeHeirloomLevelSelected, HeirloomId, Level)
end

function HeirloomInfoPanelView:BindOnHeirloomSelectedItemChanged(ResourceId)
  local AllChildren = self.ChildItemList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshSelectedStatus(ResourceId)
  end
end

function HeirloomInfoPanelView:RefreshHeirloomChildItemList(HeirloomId, Level)
  local HeirloomInfo = HeirloomData:GetHeirloomInfoByLevel(HeirloomId, Level)
  if not HeirloomInfo then
    print("HeirloomInfoPanelView:RefreshHeirloomChildItemList not found Row Info", HeirloomId, Level)
    self.ChildItemPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self.ChildItemPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local AllResourceIds = HeirloomData:GetAllResourceIdByGiftId(HeirloomInfo.GiftID)
  local Item
  local TargetResourceId = -1
  for i, SingleResourceId in ipairs(AllResourceIds) do
    Item = GetOrCreateItem(self.ChildItemList, i, self.HeirloomChildItemTemplate:StaticClass())
    Item:Show(SingleResourceId)
    if -1 == TargetResourceId then
      TargetResourceId = SingleResourceId
    end
  end
  HideOtherItem(self.ChildItemList, table.count(AllResourceIds) + 1)
  EventSystem.Invoke(EventDef.Heirloom.OnHeirloomSelectedItemChanged, TargetResourceId)
end

function HeirloomInfoPanelView:RefreshHeirloomLevelItemLockStatus()
  local AllChildren = self.HeirloomLevelList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshLockStatus()
  end
end

function HeirloomInfoPanelView:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  HeirloomData:SetCurSelectHeirloomIdAndLevel(-1, -1)
  self:RemoveEventListener()
end

function HeirloomInfoPanelView:RemoveEventListener()
  EventSystem.RemoveListener(EventDef.Heirloom.OnChangeHeirloomLevelSelected, self.BindOnChangeHeirloomLevelSelected, self)
  EventSystem.RemoveListener(EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.BindOnHeirloomSelectedItemChanged, self)
  EventSystem.RemoveListener(EventDef.Heirloom.OnHeirloomInfoChanged, self.BindOnHeirloomInfoChanged, self)
end

function HeirloomInfoPanelView:Destruct()
  self:RemoveEventListener()
end

return HeirloomInfoPanelView
