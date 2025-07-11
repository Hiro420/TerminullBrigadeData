local WBP_Shop_ItemList_C = UnLua.Class()
WBP_Shop_ItemList_C.RowTable = {}
function WBP_Shop_ItemList_C:Construct()
  self.ItemWidgets = {}
end
function WBP_Shop_ItemList_C:RefreshItemList(ItemArray)
  self.SelRow = nil
  self.SelLine = nil
  self.ItemArray = ItemArray
  self:SetListColumns()
  self.ItemWidgets = {}
  self.PowerUp:ClearChildren()
  self.DigitalCollection:ClearChildren()
  self.RecoveryProps:ClearChildren()
  for index, value in ipairs(ItemArray:ToTable()) do
    local ItemInfo = value
    local Widget = self:LoadChildWidget(ItemInfo)
    if 1 == index then
      LogicShop.OnPreselectionItem(ItemInfo, Widget)
    end
    table.insert(self.ItemWidgets, Widget)
  end
  self.RowTable = {}
  for i = 0, self.PowerUp:GetChildrenCount() do
    local Widget = self.PowerUp:GetChildAt(i)
    if Widget and Widget.Slot then
      local Row = Widget.Slot.Row + 1
      local Column = Widget.Slot.Column + 1
      if nil == self.RowTable[Row] then
        self.RowTable[Row] = {}
      end
      self.RowTable[Row][Column] = Widget
    end
  end
  local RowTableNum = table.count(self.RowTable)
  for i = 0, self.DigitalCollection:GetChildrenCount() do
    local Widget = self.DigitalCollection:GetChildAt(i)
    if Widget and Widget.Slot then
      local Row = Widget.Slot.Row + RowTableNum + 1
      local Column = Widget.Slot.Column + 1
      if nil == self.RowTable[Row] then
        self.RowTable[Row] = {}
      end
      self.RowTable[Row][Column] = Widget
    end
  end
  RowTableNum = table.count(self.RowTable)
  for i = 0, self.RecoveryProps:GetChildrenCount() do
    local Widget = self.RecoveryProps:GetChildAt(i)
    if Widget and Widget.Slot then
      local Row = Widget.Slot.Row + RowTableNum + 1
      local Column = Widget.Slot.Column + 1
      if nil == self.RowTable[Row] then
        self.RowTable[Row] = {}
      end
      self.RowTable[Row][Column] = Widget
    end
  end
end
function WBP_Shop_ItemList_C:LoadChildWidget(ItemInfo)
  local WidgetPath = "/Game/Rouge/UI/Shop/Item/WBP_Shop_Item.WBP_Shop_Item_C"
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, UE.UClass.Load(WidgetPath))
  Widget:InitItemInfo(ItemInfo)
  Widget.Btn_Main:SetNavigationRuleCustom(UE.EUINavigation.Left, {
    self,
    self.DoCustomNavigation
  })
  Widget.Btn_Main:SetNavigationRuleCustom(UE.EUINavigation.Right, {
    self,
    self.DoCustomNavigation
  })
  Widget.Btn_Main:SetNavigationRuleCustom(UE.EUINavigation.Up, {
    self,
    self.DoCustomNavigation
  })
  Widget.Btn_Main:SetNavigationRuleCustom(UE.EUINavigation.Down, {
    self,
    self.DoCustomNavigation
  })
  local ItemType = LogicShop.GetCategoryByInstanceId(ItemInfo.InstanceId)
  local ChildNum = 0
  if 1 == ItemType then
    self.PowerUp:AddChild(Widget)
    ChildNum = self.PowerUp:GetAllChildren():Num()
    local ShopWidget = RGUIMgr:GetUI("WBP_Shop_C")
    if 1 == ChildNum and ShopWidget and ShopWidget.WBP_Shop_Item_Details and ShopWidget.WBP_Shop_Item_Details.ItemInfo == nil then
      LogicShop.OnPreselectionItem(ItemInfo, Widget)
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
      if CommonInputSubsystem then
        local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
        if CurrentInputType == UE.ECommonInputType.Gamepad then
          self:SetKeyboardFocus()
          Widget.Btn_Main:SetKeyboardFocus()
        end
      end
    end
  elseif 2 == ItemType then
    self.DigitalCollection:AddChild(Widget)
    ChildNum = self.DigitalCollection:GetAllChildren():Num()
  elseif 3 == ItemType then
    self.RecoveryProps:AddChild(Widget)
    ChildNum = self.RecoveryProps:GetAllChildren():Num()
  end
  local Row = math.floor(ChildNum / self.Columns)
  local Colume = ChildNum % self.Columns - 1
  if 0 == ChildNum % self.Columns then
    Row = Row - 1
    Colume = self.Columns - 1
  end
  Widget.Slot:SetRow(Row)
  Widget.Slot:SetColumn(Colume)
  return Widget
end
function WBP_Shop_ItemList_C:DoCustomNavigation(Navigation)
  local SelLine, SelRow = 1, 1
  if not self.SelLine then
    self.SelLine = 1
  end
  if not self.SelRow then
    self.SelRow = 1
  end
  if Navigation == UE.EUINavigation.Left then
    self.SelLine = self.SelLine - 1
  elseif Navigation == UE.EUINavigation.Right then
    self.SelLine = self.SelLine + 1
  elseif Navigation == UE.EUINavigation.Up then
    self.SelRow = self.SelRow - 1
  elseif Navigation == UE.EUINavigation.Down then
    self.SelRow = self.SelRow + 1
  end
  self.MaxRow = table.count(self.RowTable)
  self.MaxLine = 1
  if self.RowTable[self.SelRow] then
    self.MaxLine = table.count(self.RowTable[self.SelRow])
  end
  if self.SelLine > self.MaxLine then
    self.SelLine = self.MaxLine
  end
  if self.SelRow <= 0 then
    self.SelRow = 1
  end
  if self.SelLine <= 0 then
    self.SelLine = 1
  end
  if self.SelRow > self.MaxRow then
    local ShopWidget = RGUIMgr:GetUI("WBP_Shop_C")
    if ShopWidget then
      self.SelRow = self.MaxRow
      local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
      if ShopInteractComp and ShopInteractComp.ShopType == UE.ERGShopType.Super then
        ShopWidget.WBP_Shop_Equipment_Props.WBP_ScrollItemBg1:SetKeyboardFocus()
        return ShopWidget.WBP_Shop_Equipment_Props.WBP_ScrollItemBg1
      else
        ShopWidget.Btn_Refresh:SetKeyboardFocus()
        return ShopWidget.Btn_Refresh
      end
    end
  end
  if self.RowTable[self.SelRow][self.SelLine] and self.RowTable[self.SelRow][self.SelLine].Btn_Main then
    self.RowTable[self.SelRow][self.SelLine].Btn_Main:SetKeyboardFocus()
    return self.RowTable[self.SelRow][self.SelLine].Btn_Main
  end
end
function WBP_Shop_ItemList_C:SetListColumns()
  self.RecoveryPropsNum = 0
  self.PowerUpNum = 0
  self.DigitalCollectionNum = 0
  self.Columns = 2
  for index, value in ipairs(self.ItemArray:ToTable()) do
    local ItemInfo = value
    local ItemType = LogicShop.GetCategoryByInstanceId(ItemInfo.InstanceId)
    if 1 == ItemType then
      self.PowerUpNum = self.PowerUpNum + 1
    elseif 2 == ItemType then
      self.DigitalCollectionNum = self.DigitalCollectionNum + 1
    elseif 3 == ItemType then
      self.RecoveryPropsNum = self.RecoveryPropsNum + 1
    end
  end
  if self.PowerUpNum > 2 or self.DigitalCollectionNum > 2 or self.RecoveryPropsNum > 2 then
    self.Columns = 3
  end
end
function WBP_Shop_ItemList_C:GamePadUpdateFocus()
  if not self.SelRow or not self.SelLine then
    return
  end
  if self.RowTable[self.SelRow][self.SelLine] and self.RowTable[self.SelRow][self.SelLine].Btn_Main then
    self.RowTable[self.SelRow][self.SelLine].Btn_Main:SetKeyboardFocus()
  end
end
return WBP_Shop_ItemList_C
