local WBP_LobbyWeaponDisplayInfo_C = UnLua.Class()
function WBP_LobbyWeaponDisplayInfo_C:Construct()
  self:SetIsSelected(false)
end
function WBP_LobbyWeaponDisplayInfo_C:BindOnViewFullAttributeListNamePressed()
  if not self:IsVisible() then
    return
  end
  self.bIsExpand = true
  self:SetAttributeInfo()
end
function WBP_LobbyWeaponDisplayInfo_C:BindOnViewFullAttributeListNameReleased()
  if not self:IsVisible() then
    return
  end
  self.bIsExpand = false
  self:SetAttributeInfo()
end
function WBP_LobbyWeaponDisplayInfo_C:InitInfo(BarrelId, AccessoryIdList, IsBattle, WeaponInfo)
  print("WBP_LobbyWeaponDisplayInfo_C:InitInfo", BarrelId)
  self.MainBodyId = tonumber(BarrelId)
  self.HasBarrel = false
  self.IsBattle = IsBattle
  self.bIsExpand = true
  self:SetAttributeInfo()
  self:SetBasicInfo()
  self:RefreshWeaponSkill()
  self.TipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CurrentEquipTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  if WeaponInfo then
    local expireAt = WeaponInfo.expireAt
    if nil ~= expireAt and "" ~= expireAt and "0" ~= expireAt then
      UpdateVisibility(self.WBP_CommonExpireAt, true)
      self.WBP_CommonExpireAt:InitCommonExpireAt(expireAt)
    else
      UpdateVisibility(self.WBP_CommonExpireAt, false)
    end
  end
end
function WBP_LobbyWeaponDisplayInfo_C:ShowCurrentEquipTipPanel()
  self.CurrentEquipTipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_LobbyWeaponDisplayInfo_C:ShowTipPanel(TipText, IsShowOperateIcon)
  if TipText then
    self.TipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_OperateTip:SetText(TipText)
    if IsShowOperateIcon then
      self.Img_OperateIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Img_OperateIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end
function WBP_LobbyWeaponDisplayInfo_C:SetIsSelected(IsSelected)
  UpdateVisibility(self.SelectedPanel, IsSelected)
end
function WBP_LobbyWeaponDisplayInfo_C:SetAttributeInfo()
  self.MainAttributeInfoTable = {}
  local AccessoryTable = LuaTableMgr.GetLuaTableByName(TableNames.TBAccessory)
  if not AccessoryTable then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local TotalInscriptionList = {}
  local AllChildren = self.ScrollBoxAttr:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local AllChildren2 = self.VerticalBoxComAttr:GetAllChildren()
  for i, SingleItem in pairs(AllChildren2) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local MainAttributeIndex = 0
  local CommonAttributeIndex = 0
  local AllMainAttributeList = UE.URGBlueprintLibrary.GetOutsideWeaponAttributeList(self, self.HasBarrel, self.MainBodyId, TotalInscriptionList)
  local AllMainAttributeListTable = AllMainAttributeList:ToTable()
  table.sort(AllMainAttributeListTable, function(A, B)
    local AAttributeName = UE.URGBlueprintLibrary.GetAttributeName(A)
    local AAttributeFullName = UE.URGBlueprintLibrary.GetAttributeFullName(A)
    local ResultA, SingleARowData = GetRowData(DT.DT_EquipAttribute, AAttributeFullName)
    local BAttributeName = UE.URGBlueprintLibrary.GetAttributeName(B)
    local BAttributeFullName = UE.URGBlueprintLibrary.GetAttributeFullName(B)
    local BResultB, SingleBRowData = GetRowData(DT.DT_EquipAttribute, BAttributeFullName)
    if ResultA and BResultB and SingleARowData.PriorityLevel ~= SingleBRowData.PriorityLevel then
      return SingleARowData.PriorityLevel > SingleBRowData.PriorityLevel
    else
      return AAttributeName > BAttributeName
    end
  end)
  local MainAttributeItemClass = self.WeaponAttrItem_StyleOne:GetClass()
  local count = 1
  for i, SingleAttributeConfig in ipairs(AllMainAttributeListTable) do
    local AttributeName = UE.URGBlueprintLibrary.GetAttributeName(SingleAttributeConfig)
    local AttributeFullName = UE.URGBlueprintLibrary.GetAttributeFullName(SingleAttributeConfig)
    SingleAttributeConfig.Value = self:GetWeaponAttributeValue(AttributeName, SingleAttributeConfig, AllMainAttributeListTable)
    local Result, SingleRowData = GetRowData(DT.DT_EquipAttribute, AttributeFullName)
    if Result then
      if SingleRowData.DisplayInUI == UE.EAttributeDisplayPos.Detail and (self.bIsExpand or count <= LogicOutsideWeapon.WeaponDetailsAttrPreviewNum) then
        count = count + 1
        local Item = self.ScrollBoxAttr:GetChildAt(MainAttributeIndex)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, MainAttributeItemClass)
          self.ScrollBoxAttr:AddChild(Item)
        end
        Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        Item:InitAttributeInfo(SingleRowData.DisplayNameInUI, UE.URGBlueprintLibrary.GetAttributeDisplayText(SingleAttributeConfig.Value, SingleRowData.AttributeDisplayType, "", SingleRowData.DisplayValueRatioInUI), SingleRowData.DisplayUnitInUI)
        MainAttributeIndex = MainAttributeIndex + 1
        local TempTable = {
          Value = SingleAttributeConfig.Value,
          Widget = Item,
          IsInverseRatio = SingleRowData.IsInverseRation,
          AttributeDisplayType = SingleRowData.AttributeDisplayType,
          DisplayUnitInUI = SingleRowData.DisplayUnitInUI,
          DisplayValueRatioInUI = SingleRowData.DisplayValueRatioInUI
        }
        self.MainAttributeInfoTable[AttributeName] = TempTable
      end
      if SingleRowData.DisplayInUI == UE.EAttributeDisplayPos.Main then
        local Item = self.VerticalBoxComAttr:GetChildAt(CommonAttributeIndex)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, self.ComAttributeItemTemplate:GetClass())
          self.VerticalBoxComAttr:AddChild(Item)
        end
        Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        Item:InitAttributeInfo(SingleRowData.DisplayNameInUI, UE.URGBlueprintLibrary.GetAttributeDisplayText(SingleAttributeConfig.Value, SingleRowData.AttributeDisplayType, "", SingleRowData.DisplayValueRatioInUI), SingleRowData.DisplayUnitInUI)
        CommonAttributeIndex = CommonAttributeIndex + 1
        local TempTable = {
          Value = SingleAttributeConfig.Value,
          Widget = Item,
          IsInverseRatio = SingleRowData.IsInverseRation,
          AttributeDisplayType = SingleRowData.AttributeDisplayType,
          DisplayUnitInUI = SingleRowData.DisplayUnitInUI,
          DisplayValueRatioInUI = SingleRowData.DisplayValueRatioInUI
        }
        self.MainAttributeInfoTable[AttributeName] = TempTable
      end
    end
  end
end
function WBP_LobbyWeaponDisplayInfo_C:RefreshWeaponSkill()
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(self.MainBodyId))
  local index = 1
  if Result and RowData.WeaponSkillDataAry:Num() > 0 then
    for i, v in iterator(RowData.WeaponSkillDataAry) do
      local item = GetOrCreateItem(self.VerticalBoxSkill, i, self.WBP_WeaponTipsSkillItem:GetClass())
      UpdateVisibility(item, true)
      item:RefreshWeaponTipsSkillItemInfo(v, i)
      index = index + 1
    end
  end
  HideOtherItem(self.VerticalBoxSkill, index)
  UpdateVisibility(self.Image_Line_2, index > 1)
end
function WBP_LobbyWeaponDisplayInfo_C:GetRarity(Id, IsBarrel)
  if IsBarrel then
    local WeaponTable = LuaTableMgr.GetLuaTableByName(TableNames.TBWeapon)
    local TargetWeaponInfo = WeaponTable[Id]
    return TargetWeaponInfo and TargetWeaponInfo.BarrelRarity or UE.ERGItemRarity.EIR_Legend
  else
    local AccessoryTable = LuaTableMgr.GetLuaTableByName(TableNames.TBAccessory)
    local TargetAccessoryInfo = AccessoryTable[Id]
    return TargetAccessoryInfo and TargetAccessoryInfo.AccessoryRarity or UE.ERGItemRarity.EIR_Legend
  end
end
function WBP_LobbyWeaponDisplayInfo_C:SetBasicInfo()
  local LogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandDataSubsystem then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if self.HasBarrel then
    local AResult, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(self.MainBodyId, nil)
    if AResult then
      local Result, IDToTxtData = DTSubsystem:GetIDToTxtTableRow(AccessoryRowInfo.DescId)
      if Result then
        self.Txt_GunName:SetText(IDToTxtData.Text)
      end
    end
  else
    local ItemData = DTSubsystem:K2_GetItemTableRow(tostring(self.MainBodyId))
    self.Txt_GunName:SetText(ItemData.Name)
  end
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(self.MainBodyId))
  if Result then
    self.RGTextWeaponType:SetText(RowData.WeaponTypeText)
  else
    self.RGTextWeaponType:SetText("")
  end
end
function WBP_LobbyWeaponDisplayInfo_C:GetWeaponAttributeValue(TempString, AttributeConfig, AllMainAttributeListTable)
  return LogicOutsideWeapon.GetWeaponAttributeValue(TempString, AttributeConfig, AllMainAttributeListTable, self.IsBattle)
end
function WBP_LobbyWeaponDisplayInfo_C:PopSelfInputAction()
  self:PopInputAction()
end
return WBP_LobbyWeaponDisplayInfo_C
