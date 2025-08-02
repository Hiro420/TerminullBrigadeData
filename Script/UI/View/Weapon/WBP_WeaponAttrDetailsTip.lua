local WBP_WeaponAttrDetailsTip = UnLua.Class()

function WBP_WeaponAttrDetailsTip:Construct()
  self.Overridden.Construct(self)
  self.ButtonAttrExpandOrRetract.OnClicked:Add(self, self.OnAttrExpandOrRetract)
  self.ButtonAttrExpandOrRetract_1.OnClicked:Add(self, self.OnAttrExpandOrRetract)
end

function WBP_WeaponAttrDetailsTip:Destruct()
  self.ButtonAttrExpandOrRetract.OnClicked:Remove(self, self.OnAttrExpandOrRetract)
  self.ButtonAttrExpandOrRetract_1.OnClicked:Remove(self, self.OnAttrExpandOrRetract)
end

function WBP_WeaponAttrDetailsTip:InitWeaponAttrDetailsTip(BarrelId, AccessoryIdList, ParentView, IsNewType, TipsItemIsNewType)
  self.AccessoryIdList = AccessoryIdList
  self.MainBodyId = tonumber(BarrelId)
  self.HasBarrel = false
  self.ParentView = ParentView
  self.IsNewType = IsNewType
  self.TipsItemIsNewType = TipsItemIsNewType
  self:SetBasicInfo()
  self:RefreshWeaponSkill()
  self.bIsExpand = false
  self:OnAttrExpandOrRetract()
  UpdateVisibility(self.VerticalBox_Old, not IsNewType)
  UpdateVisibility(self.VerticalBox_New, IsNewType)
end

function WBP_WeaponAttrDetailsTip:SetAttributeInfo()
  self.MainAttributeInfoTable = {}
  local ScrollBoxAttr = self.IsNewType and self.ScrollBoxAttr_1 or self.ScrollBoxAttr
  local VerticalBoxComAttr = self.IsNewType and self.VerticalBoxComAttr_1 or self.VerticalBoxComAttr
  local WeaponAttrItem_StyleOne = self.IsNewType and self.WeaponAttrItem_StyleOne_1 or self.WeaponAttrItem_StyleOne
  local ComAttributeItemTemplate = self.IsNewType and self.ComAttributeItemTemplate_1 or self.ComAttributeItemTemplate
  local CurInscriptionList = self.IsNewType and self.InscriptionList_1 or self.InscriptionList
  local InscriptionItemTemplate = self.IsNewType and self.InscriptionItemTemplate_1 or self.InscriptionItemTemplate
  local InscriptionPanel = self.IsNewType and self.InscriptionPanel_1 or self.InscriptionPanel
  local AccessoryTable = LuaTableMgr.GetLuaTableByName(TableNames.TBAccessory)
  if not AccessoryTable then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local TotalInscriptionList = {}
  local AccessoryInscriptionList = {}
  for i, SingleId in ipairs(self.AccessoryIdList) do
    local AccessoryTableInfo = AccessoryTable[tonumber(SingleId)]
    if AccessoryTableInfo and AccessoryTableInfo.AccessoryType == TableEnums.ENUMAccType.Accessory then
      local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(tonumber(SingleId), nil)
      if Result then
        local InscriptionList = AccessoryRowInfo.InscriptionMap:Find(AccessoryTableInfo.AccessoryRarity)
        if InscriptionList then
          for i, SingleInsctiptionData in pairs(InscriptionList.Inscriptions) do
            table.insert(TotalInscriptionList, SingleInsctiptionData.InscriptionId)
            table.insert(AccessoryInscriptionList, SingleInsctiptionData.InscriptionId)
          end
        end
      end
    end
  end
  local AllChildren = ScrollBoxAttr:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local AllChildren2 = VerticalBoxComAttr:GetAllChildren()
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
  local count = 1
  local MainAttributeItemClass = WeaponAttrItem_StyleOne:GetClass()
  for i, SingleAttributeConfig in ipairs(AllMainAttributeListTable) do
    local AttributeName = UE.URGBlueprintLibrary.GetAttributeName(SingleAttributeConfig)
    local AttributeFullName = UE.URGBlueprintLibrary.GetAttributeFullName(SingleAttributeConfig)
    SingleAttributeConfig.Value = self:GetWeaponAttributeValue(AttributeName, SingleAttributeConfig, AllMainAttributeListTable)
    local Result, SingleRowData = GetRowData(DT.DT_EquipAttribute, AttributeFullName)
    if Result then
      if SingleRowData.DisplayInUI == UE.EAttributeDisplayPos.Detail and (self.bIsExpand or count <= LogicOutsideWeapon.WeaponDetailsAttrPreviewNum) then
        count = count + 1
        local Item = ScrollBoxAttr:GetChildAt(MainAttributeIndex)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, MainAttributeItemClass)
          ScrollBoxAttr:AddChild(Item)
        end
        Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        Item:SetRenderShear(WeaponAttrItem_StyleOne.RenderTransform.Shear)
        Item:InitAttributeInfo(SingleRowData.DisplayNameInUI, UE.URGBlueprintLibrary.GetAttributeDisplayText(SingleAttributeConfig.Value, SingleRowData.AttributeDisplayType, "", SingleRowData.DisplayValueRatioInUI), SingleRowData.DisplayUnitInUI)
        MainAttributeIndex = MainAttributeIndex + 1
        local TempTable = {
          Value = SingleAttributeConfig.Value,
          Widget = Item,
          IsInverseRatio = SingleRowData.IsInverseRation,
          AttributeDisplayType = SingleRowData.AttributeDisplayType,
          DisplayUnitInUI = SingleRowData.DisplayUnitInUI,
          DisplayValueRatioInUI = SingleRowData.DisplayValueRatioInUI,
          IsInverseRation = SingleRowData.IsInverseRation
        }
        self.MainAttributeInfoTable[AttributeName] = TempTable
      end
      if SingleRowData.DisplayInUI == UE.EAttributeDisplayPos.Main then
        local Item = VerticalBoxComAttr:GetChildAt(CommonAttributeIndex)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, ComAttributeItemTemplate:GetClass())
          VerticalBoxComAttr:AddChild(Item)
        end
        Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        Item:SetRenderShear(ComAttributeItemTemplate.RenderTransform.Shear)
        Item:InitAttributeInfo(SingleRowData.DisplayNameInUI, UE.URGBlueprintLibrary.GetAttributeDisplayText(SingleAttributeConfig.Value, SingleRowData.AttributeDisplayType, "", SingleRowData.DisplayValueRatioInUI), SingleRowData.DisplayUnitInUI)
        CommonAttributeIndex = CommonAttributeIndex + 1
        local TempTable = {
          Value = SingleAttributeConfig.Value,
          Widget = Item,
          IsInverseRatio = SingleRowData.IsInverseRation,
          AttributeDisplayType = SingleRowData.AttributeDisplayType,
          DisplayUnitInUI = SingleRowData.DisplayUnitInUI,
          DisplayValueRatioInUI = SingleRowData.DisplayValueRatioInUI,
          IsInverseRation = SingleRowData.IsInverseRation
        }
        self.MainAttributeInfoTable[AttributeName] = TempTable
      end
    end
  end
  local AllChildren = CurInscriptionList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  if 0 == table.count(AccessoryInscriptionList) then
    InscriptionPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    InscriptionPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  for i, SingleInscriptionId in ipairs(AccessoryInscriptionList) do
    local Item = CurInscriptionList:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, InscriptionItemTemplate:StaticClass())
      CurInscriptionList:AddChild(Item)
    end
    Item:InitInfo(SingleInscriptionId, 0)
  end
end

function WBP_WeaponAttrDetailsTip:GetRarity(Id, IsBarrel)
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

function WBP_WeaponAttrDetailsTip:SetBasicInfo()
  local TextType = self.IsNewType and self.TextType_1 or self.TextType
  local Txt_Desc = self.IsNewType and self.Txt_Desc_1 or self.Txt_Desc
  local Txt_GunName = self.IsNewType and self.Txt_GunName_1 or self.Txt_GunName
  local LogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandDataSubsystem then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(self.MainBodyId))
  if Result then
    TextType:SetText(RowData.WeaponTypeText)
  else
    TextType:SetText("")
  end
  if self.HasBarrel then
    local AResult, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(self.MainBodyId, nil)
    if AResult then
      local Result, IDToTxtData = DTSubsystem:GetIDToTxtTableRow(AccessoryRowInfo.DescId)
      if Result then
        Txt_GunName:SetText(IDToTxtData.Text)
      end
      local InscriptionList = AccessoryRowInfo.InscriptionMap:Find(self:GetRarity(self.MainBodyId, true))
      if InscriptionList then
        for i, SingleInscriptionInfo in pairs(InscriptionList.Inscriptions) do
          local DescStr = GetLuaInscriptionDesc(SingleInscriptionInfo.InscriptionId, 0, nil)
          Txt_Desc:SetText(DescStr)
          Txt_Desc:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
          break
        end
      else
        print("WBP_WeaponAttrDetailsTip:SetBasicInfo \230\178\161\230\137\190\229\136\176\230\158\170\231\174\161\229\175\185\229\186\148\229\147\129\232\180\168\231\154\132\232\175\141\230\157\161", self.MainBodyId)
        Txt_Desc:SetVisibility(UE.ESlateVisibility.Hidden)
      end
    end
  else
    local ItemData = DTSubsystem:K2_GetItemTableRow(tostring(self.MainBodyId))
    Txt_GunName:SetText(ItemData.Name)
    local WeaponItemData = DTSubsystem:GetWeaponTableRowByID(self.MainBodyId)
    if WeaponItemData and WeaponItemData.AccessoryType == UE.ERGAccessoryType.EAT_Basic then
      Txt_Desc:SetText(WeaponItemData.Description)
      Txt_Desc:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      Txt_Desc:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end

function WBP_WeaponAttrDetailsTip:SetElementInfo()
  local Txt_Desc = self.IsNewType and self.Txt_Desc_1 or self.Txt_Desc
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ElementEffectList = {}
  if self.HasBarrel then
    local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(self.MainBodyId, nil)
    if Result then
      ElementEffectList = AccessoryRowInfo.ElementEffectList
    end
  else
    local WeaponRowInfo = DTSubsystem:GetWeaponTableRowByID(self.MainBodyId, nil)
    ElementEffectList = WeaponRowInfo.ElementEffectList
  end
  local TargetElementEffectId
  for i, SingleElementEffectId in pairs(ElementEffectList) do
    TargetElementEffectId = SingleElementEffectId
    break
  end
  local ElementType = 0
  local ElementValue = 0
  if TargetElementEffectId then
    local Result, EffectRowInfo = self:GetElementEffectRowInfo(tostring(TargetElementEffectId))
    if Result then
      ElementType = EffectRowInfo.ElementType
      ElementValue = EffectRowInfo.ElementEffectChance
    end
  end
  local ElementTextColor = self.ElementTextColor:Find(ElementType)
  if ElementTextColor then
    Txt_Desc:SetDefaultColorAndOpacity(ElementTextColor)
  end
end

function WBP_WeaponAttrDetailsTip:GetWeaponAttributeValue(TempString, AttributeConfig, AllMainAttributeListTable)
  return LogicOutsideWeapon.GetWeaponAttributeValue(TempString, AttributeConfig, AllMainAttributeListTable, false)
end

function WBP_WeaponAttrDetailsTip:OnAnimationFinished(Animation)
end

function WBP_WeaponAttrDetailsTip:OnAttrExpandOrRetract()
  local RGTextAttr = self.IsNewType and self.RGTextAttr_1 or self.RGTextAttr
  if self.bIsExpand then
    self.bIsExpand = false
    RGTextAttr:SetText(self.ExpandText)
  else
    self.bIsExpand = true
    RGTextAttr:SetText(self.RetractText)
  end
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:AttrExpandOrRetract(self.bIsExpand)
  end
  self:SetAttributeInfo()
end

function WBP_WeaponAttrDetailsTip:AttrRetract()
  self.bIsExpand = true
  self:OnAttrExpandOrRetract()
end

function WBP_WeaponAttrDetailsTip:AttrExpand()
  self.bIsExpand = false
  self:OnAttrExpandOrRetract()
end

function WBP_WeaponAttrDetailsTip:RefreshWeaponSkill()
  local WBP_WeaponTipsSkillItem = self.IsNewType and self.WBP_WeaponTipsSkillItem_1 or self.WBP_WeaponTipsSkillItem
  local VerticalBoxSkill = self.IsNewType and self.VerticalBoxSkill_1 or self.VerticalBoxSkill
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(self.MainBodyId))
  local index = 1
  if Result and RowData.WeaponSkillDataAry:Num() > 0 then
    for i, v in iterator(RowData.WeaponSkillDataAry) do
      local item = GetOrCreateItem(VerticalBoxSkill, i, WBP_WeaponTipsSkillItem:GetClass())
      UpdateVisibility(item, true)
      item:RefreshWeaponTipsSkillItemInfo(v, i, self.TipsItemIsNewType)
      index = index + 1
    end
  end
  HideOtherItem(VerticalBoxSkill, index)
end

function WBP_WeaponAttrDetailsTip:SwitchToWeapon()
  self.CurShowModel = EWeaponShowModel.WeaponModel
end

return WBP_WeaponAttrDetailsTip
