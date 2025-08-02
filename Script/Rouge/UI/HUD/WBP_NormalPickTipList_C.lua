local ListContainer = require("Rouge.UI.Common.ListContainer")
local WBP_NormalPickTipList_C = UnLua.Class()
local FilterItemTypeTb = {
  [TableEnums.ENUMResourceType.Chip] = true
}

function WBP_NormalPickTipList_C:Construct()
  self.AllWidgets:Clear()
  self.TipList:ClearChildren()
  self.SumDeltaTime = 0
  self.NeedRefreshPos = false
  self.ItemIndex = 0
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.PostItemChanged:Add(self, WBP_NormalPickTipList_C.BindOnPostItemChanged)
  end
  ListenObjectMessage(nil, GMP.MSG_Interact_ClientPickup, self, self.BindOnClientPickupNotice)
  EventSystem.AddListener(self, EventDef.PickTipList.OnAddPickTipList, self.BindOnAddPickTipList)
  EventSystem.AddListener(self, EventDef.PickTipList.HidePickTipItem, self.BindOnHidePickTipItem)
end

function WBP_NormalPickTipList_C:FocusInput()
end

function WBP_NormalPickTipList_C:CheckFilterPickTip(ItemId)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if result and FilterItemTypeTb[row.Type] then
    return true
  end
  return false
end

function WBP_NormalPickTipList_C:BindOnPostItemChanged(ArticleId, OldStack, NewStack)
  if NewStack - OldStack <= 0 then
    print("\231\137\169\229\147\129\229\135\143\229\176\145")
    return
  end
  local itemID = UE.URGArticleStatics.GetConfigId(ArticleId)
  if self:CheckFilterPickTip(itemID) then
    return
  end
  self:CreateItemTip(itemID, NewStack - OldStack)
end

function WBP_NormalPickTipList_C:BindOnAddPickTipList(Widget)
  print("BindOnAddPickTipList")
  self:AddWidgetToPanel(Widget)
end

function WBP_NormalPickTipList_C:BindOnHidePickTipItem(ItemWidget)
  local WidgetLifeTimer = self.LifeTimerHandleList:Find(ItemWidget)
  if WidgetLifeTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(WidgetLifeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, WidgetLifeTimer)
    self.LifeTimerHandleList:Remove(ItemWidget)
  end
  local WidgetFadeInTimer = self.FadeInTimerHandleList:Find(ItemWidget)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(WidgetFadeInTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, WidgetFadeInTimer)
    self.FadeInTimerHandleList:Remove(ItemWidget)
  end
  ItemWidget:RemoveFromParent()
  self.AllWidgets:RemoveItem(ItemWidget)
  self.NeedRefreshPos = true
  for i, SingleWidget in pairs(self.AllWidgets) do
    if not SingleWidget.IsFadeIn then
      self:RefreshOrAddFadeInTime(SingleWidget)
    end
  end
end

function WBP_NormalPickTipList_C:AddWidgetToPanel(Widget)
  local CurCount = self.AllWidgets:Length()
  local RemoveWidget
  if CurCount + 1 > self.MaxNum then
    RemoveWidget = self.AllWidgets:Get(1)
    EventSystem.Invoke(EventDef.PickTipList.HidePickTipItem, RemoveWidget)
  end
  self.SumDeltaTime = 0
  self.NeedRefreshPos = true
  local Slot = self.TipList:AddChild(Widget)
  self.AllWidgets:Add(Widget)
  local Anchors = UE.FAnchors()
  Anchors.Minimum = UE.FVector2D(0.0, 0.0)
  Anchors.Maximum = UE.FVector2D(0.0, 0.0)
  Slot:SetAnchors(Anchors)
  Slot:SetPosition(UE.FVector2D(0.0, 0.0))
  Slot:SetAlignment(UE.FVector2D(0.0, 0.0))
  Slot:SetAutoSize(true)
  Widget.ItemIndex = self.ItemIndex
  self.ItemIndex = self.ItemIndex + 1
  Widget:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RefreshOrAddWidgetLifeTime(Widget)
  self:RefreshOrAddFadeInTime(Widget)
end

function WBP_NormalPickTipList_C:RefreshOrAddWidgetLifeTime(Widget)
  local WidgetLifeTimer = self.LifeTimerHandleList:Find(Widget)
  if WidgetLifeTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(WidgetLifeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, WidgetLifeTimer)
    self.LifeTimerHandleList:Remove(Widget)
  end
  local ItemIndex = 0
  local Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    Widget,
    function(Widget)
      if Widget.PlayRemoveWidgetAnim then
        Widget:PlayRemoveWidgetAnim()
      else
        EventSystem.Invoke(EventDef.PickTipList.HidePickTipItem, Widget)
      end
    end
  }, self.Duration + ItemIndex * self.TipInterval, false)
  self.LifeTimerHandleList:Add(Widget, Timer)
end

function WBP_NormalPickTipList_C:RefreshOrAddFadeInTime(Widget)
  local WidgetFadeInTimer = self.FadeInTimerHandleList:Find(Widget)
  local TimerElapsedTime = 0
  if WidgetFadeInTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(WidgetFadeInTimer) then
    TimerElapsedTime = UE.UKismetSystemLibrary.K2_GetTimerElapsedTimeHandle(self, WidgetFadeInTimer)
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, WidgetFadeInTimer)
    self.FadeInTimerHandleList:Remove(Widget)
  end
  local ItemIndex = self.AllWidgets:Find(Widget)
  local TargetTime = ItemIndex * self.TipInterval - TimerElapsedTime
  if TargetTime >= 0.0 then
    local Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      Widget,
      function(Widget)
        Widget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        if Widget.PlayFadeInWidgetAnim then
          Widget:PlayFadeInWidgetAnim()
        end
        Widget.IsFadeIn = true
      end
    }, TargetTime, false)
    self.FadeInTimerHandleList:Add(Widget, Timer)
  else
    Widget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if Widget.PlayFadeInWidgetAnim then
      Widget:PlayFadeInWidgetAnim()
    end
    Widget.IsFadeIn = true
  end
end

function WBP_NormalPickTipList_C:CreateItemTip(ItemId, Num)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local ItemData = DTSubsystem:K2_GetItemTableRow(tostring(ItemId), nil)
  if self.ItemTypeList:Contains(ItemData.ArticleType) then
    local Item
    for key, SingleWidget in pairs(self.AllWidgets) do
      if SingleWidget.ItemId == ItemId then
        Item = SingleWidget
        break
      end
    end
    if Item then
      self:RefreshOrAddWidgetLifeTime(Item)
    else
      local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/WaveWindow/WBP_RGPickupItemWaveWindow.WBP_RGPickupItemWaveWindow_C")
      Item = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
      Item.ItemId = ItemId
      self:AddWidgetToPanel(Item)
    end
    Item:Show(ItemData, Num)
    if ItemData.ArticleType == UE.EArticleDataType.SkillResource then
      local Result, SkillResourceRowInfo = DTSubsystem:GetSkillResourceData(ItemId, Character:GetTypeId(), nil)
      if Result then
        Item:ChangeDisplayInfo(SkillResourceRowInfo.SkillResourceName, SkillResourceRowInfo.SkillResourceIcon)
      end
    end
    PlaySound2DEffect(10004, "WBP_NormalPickTipList_C:BindOnPostItemChanged")
  end
end

function WBP_NormalPickTipList_C:BindOnClientPickupNotice(ItemId)
  print("BindOnClientPickupNotice", ItemId)
  self:CreateItemTip(ItemId, 1)
end

function WBP_NormalPickTipList_C:LuaTick(InDeltaTime)
  if self.NeedRefreshPos then
    local Pos = UE.FVector2D(0.0, 0.0)
    self.SumDeltaTime = self.SumDeltaTime + InDeltaTime
    local WidgetLength = table.count(self.AllWidgets)
    for i, SingleWidget in pairs(self.AllWidgets) do
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(SingleWidget)
      if Slot then
        local TargetPosY = (WidgetLength - i + 1) * self.WidgetOffset
        Pos.Y = math.clamp(TargetPosY, 0, TargetPosY)
        Slot:SetPosition(Pos)
      end
    end
    if self.SumDeltaTime > 0.5 then
      self.NeedRefreshPos = false
      self.SumDeltaTime = 0
    end
  end
end

function WBP_NormalPickTipList_C:Destruct()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
    if BagComp then
      BagComp.PostItemChanged:Remove(self, WBP_NormalPickTipList_C.BindOnPostItemChanged)
    end
  end
  UnListenObjectMessage("Interact.ClientPickup")
  EventSystem.RemoveListener(EventDef.PickTipList.OnAddPickTipList, self.BindOnAddPickTipList, self)
  EventSystem.RemoveListener(EventDef.PickTipList.HidePickTipItem, self.BindOnHidePickTipItem, self)
end

return WBP_NormalPickTipList_C
