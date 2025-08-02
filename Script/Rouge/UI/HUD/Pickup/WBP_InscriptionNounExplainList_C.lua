local WBP_InscriptionNounExplainList_C = UnLua.Class()

function WBP_InscriptionNounExplainList_C:InitInfo(CurCompareWeapon, IsWeapon, WeaponOrAccessoryId)
  self.CurCompareWeapon = CurCompareWeapon
  self.IsWeapon = IsWeapon
  if self.IsWeapon then
    self.TargetCompareWeapon = WeaponOrAccessoryId
  else
    self.AccessoryId = WeaponOrAccessoryId
  end
  self:RefreshInscriptionNounExplainList()
end

function WBP_InscriptionNounExplainList_C:RefreshInscriptionNounExplainList()
  local AllChildren = self.InscriptionNounExplainList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Hidden)
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
  local OwnedAccessories = CompareAccessoryComp:GetOwnedAccessories(nil)
  for i, SingleAccessoryId in pairs(OwnedAccessories) do
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
    local OwnedAccessories = PickupCompareAccessoryComp:GetOwnedAccessories(nil)
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
  local AllInscriptionIds = {}
  for i, SingleInscriptionId in ipairs(CompareWeaponInscriptionIds) do
    if not table.Contain(AllInscriptionIds, SingleInscriptionId) then
      table.insert(AllInscriptionIds, SingleInscriptionId)
    end
  end
  for i, SingleInscriptionId in ipairs(PickUpInscriptionIds) do
    if not table.Contain(AllInscriptionIds, SingleInscriptionId) then
      table.insert(AllInscriptionIds, SingleInscriptionId)
    end
  end
  for i, SingleInscriptionId in ipairs(ReplaceInscriptionIds) do
    if not table.Contain(AllInscriptionIds, SingleInscriptionId) then
      table.insert(AllInscriptionIds, SingleInscriptionId)
    end
  end
  local LogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandDataSubsystem then
    return
  end
  local InscriptionExplainItemIndex = 0
  for i, SingleInscriptionId in ipairs(AllInscriptionIds) do
    local InscriptionDA = GetLuaInscription(SingleInscriptionId)
    if InscriptionDA and InscriptionDA.ModAdditionalNoteMap then
      for ModNoteId, v in pairs(InscriptionDA.ModAdditionalNoteMap) do
        local Result, RowInfo = DTSubsystem:GetModAdditionalNoteTableRow(ModNoteId, nil)
        if not table.Contain(ModAdditionalNoteIds, ModNoteId) and Result then
          local ExtraItem = self.InscriptionNounExplainList:GetChildAt(InscriptionExplainItemIndex)
          if not ExtraItem then
            ExtraItem = UE.UWidgetBlueprintLibrary.Create(self, self.InscriptionNounExplainTemplate:StaticClass())
            self.InscriptionNounExplainList:AddChild(ExtraItem)
          end
          ExtraItem:InitInfo(RowInfo)
          InscriptionExplainItemIndex = InscriptionExplainItemIndex + 1
          ExtraItem:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
          table.insert(ModAdditionalNoteIds, ModNoteId)
        end
      end
    end
  end
end

return WBP_InscriptionNounExplainList_C
