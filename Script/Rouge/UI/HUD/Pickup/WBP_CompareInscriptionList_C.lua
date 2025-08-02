local WBP_CompareInscriptionList_C = UnLua.Class()

function WBP_CompareInscriptionList_C:InitInfo(CurCompareWeapon, IsWeapon, WeaponOrAccessoryId)
  self.CurCompareWeapon = CurCompareWeapon
  self.IsWeapon = IsWeapon
  if IsWeapon then
    self.TargetCompareWeapon = WeaponOrAccessoryId
  else
    self.AccessoryId = WeaponOrAccessoryId
  end
  self:RefreshInscriptionList()
end

function WBP_CompareInscriptionList_C:RefreshInscriptionList()
  local AllChildren = self.InscriptionList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local TargetCompareWeapon = self.CurCompareWeapon
  if not TargetCompareWeapon then
    return
  end
  local CompareAccessoryComp = TargetCompareWeapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
  if not CompareAccessoryComp then
    return
  end
  local CompareWeaponInscriptionIds = {}
  local PickUpInscriptionIds = {}
  local ReplaceInscriptionIds = {}
  local ModAdditionalNoteIds = {}
  local CompareOwnedAccessories = CompareAccessoryComp:GetOwnedAccessoriesWithoutBarrel(nil)
  for i, SingleAccessoryId in pairs(CompareOwnedAccessories) do
    local ConfigId = UE.URGArticleStatics.GetConfigId(SingleAccessoryId)
    local AccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, SingleAccessoryId, nil)
    local ItemRarity = AccessoryData.InnerData.ItemRarity
    local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(ConfigId)
    if Result then
      local InscriptionList = AccessoryRowInfo.InscriptionMap:Find(ItemRarity)
      if InscriptionList then
        for i, SingleInscriptionInfo in pairs(InscriptionList.Inscriptions) do
          table.insert(CompareWeaponInscriptionIds, SingleInscriptionInfo.InscriptionId)
        end
      end
    end
  end
  if self.IsWeapon then
    local PickupCompareAccessoryComp = self.TargetCompareWeapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
    if not PickupCompareAccessoryComp then
      return
    end
    local OwnedAccessories = PickupCompareAccessoryComp:GetOwnedAccessoriesWithoutBarrel(nil)
    for i, SingleAccessoryId in pairs(CompareOwnedAccessories) do
      if PickupCompareAccessoryComp:CanEquipAccessory(SingleAccessoryId) then
        OwnedAccessories:AddUnique(SingleAccessoryId)
      end
    end
    for i, SingleAccessoryId in pairs(OwnedAccessories) do
      local ConfigId = UE.URGArticleStatics.GetConfigId(SingleAccessoryId)
      local AccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, SingleAccessoryId, nil)
      local ItemRarity = AccessoryData.InnerData.ItemRarity
      local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(ConfigId)
      if Result then
        local InscriptionList = AccessoryRowInfo.InscriptionMap:Find(ItemRarity)
        if InscriptionList then
          for i, SingleInscriptionInfo in pairs(InscriptionList.Inscriptions) do
            table.insert(PickUpInscriptionIds, SingleInscriptionInfo.InscriptionId)
          end
        end
      end
    end
  else
    local ConfigId = UE.URGArticleStatics.GetConfigId(self.AccessoryId)
    local AccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, self.AccessoryId, nil)
    local ItemRarity = AccessoryData.InnerData.ItemRarity
    local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(ConfigId)
    if Result then
      local InscriptionList = AccessoryRowInfo.InscriptionMap:Find(ItemRarity)
      if InscriptionList then
        for i, SingleInscriptionInfo in pairs(InscriptionList.Inscriptions) do
          table.insert(PickUpInscriptionIds, SingleInscriptionInfo.InscriptionId)
        end
      end
      local AccessoryType = AccessoryRowInfo.AccessoryType
      local ReplaceAccessoryId = CompareAccessoryComp:GetAccessoryByType(AccessoryType)
      local ReplaceAccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, ReplaceAccessoryId, nil)
      local ReplaceAccessoryRowInfo = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, ReplaceAccessoryId, nil)
      local ReplaceItemRarity = ReplaceAccessoryData.InnerData.ItemRarity
      local ReplaceInscriptionList = ReplaceAccessoryRowInfo.InscriptionMap:Find(ReplaceItemRarity)
      if ReplaceInscriptionList then
        for i, SingleInscriptionInfo in pairs(ReplaceInscriptionList.Inscriptions) do
          table.insert(ReplaceInscriptionIds, SingleInscriptionInfo.InscriptionId)
        end
      end
    end
  end
  local LogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandDataSubsystem then
    return
  end
  local InscriptionItemIndex = 0
  local AllInscriptionNum = table.count(CompareWeaponInscriptionIds) + table.count(PickUpInscriptionIds)
  if 0 == AllInscriptionNum then
    self.InscriptionPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.InscriptionPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    if self.IsWeapon then
      for i, SingleInscriptionId in ipairs(CompareWeaponInscriptionIds) do
        local Item = self.InscriptionList:GetChildAt(InscriptionItemIndex)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, self.InscriptionItemTemplate:StaticClass())
          self.InscriptionList:AddChild(Item)
        end
        if table.Contain(PickUpInscriptionIds, SingleInscriptionId) then
          Item:InitInfo(SingleInscriptionId, 0)
        else
          Item:InitInfo(SingleInscriptionId, 2)
        end
        InscriptionItemIndex = InscriptionItemIndex + 1
        Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      end
      for i, SingleInscriptionId in ipairs(PickUpInscriptionIds) do
        if not table.Contain(CompareWeaponInscriptionIds, SingleInscriptionId) then
          local Item = self.InscriptionList:GetChildAt(InscriptionItemIndex)
          if not Item then
            Item = UE.UWidgetBlueprintLibrary.Create(self, self.InscriptionItemTemplate:StaticClass())
            self.InscriptionList:AddChild(Item)
          end
          Item:InitInfo(SingleInscriptionId, 1)
          InscriptionItemIndex = InscriptionItemIndex + 1
          Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
        end
      end
    else
      for i, SingleInscriptionId in ipairs(CompareWeaponInscriptionIds) do
        local Item = self.InscriptionList:GetChildAt(InscriptionItemIndex)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, self.InscriptionItemTemplate:StaticClass())
          self.InscriptionList:AddChild(Item)
        end
        if table.Contain(ReplaceInscriptionIds, SingleInscriptionId) then
          Item:InitInfo(SingleInscriptionId, 2)
        else
          Item:InitInfo(SingleInscriptionId, 0)
        end
        InscriptionItemIndex = InscriptionItemIndex + 1
        Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      end
      for i, SingleInscriptionId in ipairs(PickUpInscriptionIds) do
        local Item = self.InscriptionList:GetChildAt(InscriptionItemIndex)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, self.InscriptionItemTemplate:StaticClass())
          self.InscriptionList:AddChild(Item)
        end
        Item:InitInfo(SingleInscriptionId, 1)
        InscriptionItemIndex = InscriptionItemIndex + 1
        Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      end
    end
  end
end

return WBP_CompareInscriptionList_C
