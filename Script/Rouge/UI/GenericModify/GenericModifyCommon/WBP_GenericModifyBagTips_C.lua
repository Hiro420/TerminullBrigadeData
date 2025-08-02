local WBP_GenericModifyBagTips_C = UnLua.Class()

function WBP_GenericModifyBagTips_C:InitGenericModifyTips(GenericModifyId, bIsUpgrade, Slot, bHideAdditionTips, GenericModifyData)
  self.bHideAdditionTips = bHideAdditionTips
  self.GenericModifyId = GenericModifyId
  self.bIsUpgrade = bIsUpgrade
  if bIsUpgrade then
    self.ModifyChooseType = ModifyChooseType.UpgradeModify
  else
    self.ModifyChooseType = ModifyChooseType.GenericModify
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  self:FadeIn()
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(GenericModifyId), nil)
  if ResultGenericModify then
    UpdateVisibility(self.WBP_GenericModifyItemOld, false)
    UpdateVisibility(self.HorizontalBoxChange, false)
    UpdateVisibility(self.RGTextChangeDesc, false)
    UpdateVisibility(self.OverlayExchangeOrUpBg, false)
    local bIsChanged = false
    GenericModifyData = GenericModifyData or LogicGenericModify:GetGenericModifyData(GenericModifyId)
    if not GenericModifyData then
      GenericModifyData = LogicGenericModify:GetModifyBySlot(GenericModifyRow.Slot)
      if GenericModifyData then
        self:InitName(GenericModifyData.ModifyId, self.RGTextOldName)
        self.WBP_GenericModifyItemOld:InitGenericModifyItem(GenericModifyData.ModifyId, false)
        UpdateVisibility(self.WBP_GenericModifyItemOld, true)
        UpdateVisibility(self.HorizontalBoxChange, true)
        UpdateVisibility(self.RGTextChangeDesc, true)
        bIsChanged = true
      end
    end
    local Level = 1
    if GenericModifyData then
      Level = GenericModifyData.Level
    end
    local LevelDesc = string.format("LV.%d", Level)
    self.RGTextBaseValueUpgrade:SetText(LevelDesc)
    if bIsUpgrade then
      local NextLevelDesc = string.format("LV.%d", Level + 1)
      self.RGTextNextValue:SetText(NextLevelDesc)
    end
    self:UpdateModifyItemPos(bIsUpgrade)
    UpdateVisibility(self.HorizontalBoxUpgrade, true)
    UpdateVisibility(self.URGImageUpgradeTag, bIsUpgrade)
    UpdateVisibility(self.SpacerUpgradeLv1, bIsUpgrade)
    UpdateVisibility(self.SpacerUpgradeLv2, bIsUpgrade)
    UpdateVisibility(self.RGTextNextValue, bIsUpgrade)
    UpdateVisibility(self.URGImageArrow, bIsUpgrade)
    self.WBP_GenericModifyItem:InitGenericModifyItem(GenericModifyId, false)
    UpdateVisibility(self.WBP_GenericModifyItem, true)
    local OutSaveData = GetLuaInscription(GenericModifyRow.Inscription)
    if OutSaveData then
      local Desc = GetLuaInscriptionDesc(GenericModifyRow.Inscription)
      local curSceneStatus = GetCurSceneStatus()
      if curSceneStatus == UE.ESceneStatus.EBattle and OutSaveData.ModifyLevelDescShowMode == UE.EModifyLevelDescShowMode.InDesc and (Level > 1 or not OutSaveData.bIsUseDescWhenNotActived) then
        local descFmt = GetLuaInsModifyLevelDescFmt(GenericModifyRow.Inscription)
        local descList = {}
        for i, v in ipairs(OutSaveData.InscriptionDataAry) do
          if v.GenericModifyLevelId ~= "None" and v.GenericModifyLevelId ~= "" and v.bIsShowGenericModifyLevelDescInUI then
            local descItem = LogicGenericModify:GetLevelValue(v.GenericModifyLevelId, GenericModifyId, Level, v.ModifyLevelDescShowType)
            table.insert(descList, descItem)
          end
        end
        if 0 == #descList then
          UnLua.LogWarn("descList is empty. \230\163\128\230\159\165InscriptionDataAry\233\133\141\231\189\174\228\184\173\231\154\132bIsShowGenericModifyLevelDescInUI\229\173\151\230\174\181\230\152\175\229\144\166\233\131\189\228\184\186false")
          descList = {""}
        end
        Desc = UE.FTextFormat(descFmt, table.unpack(descList))
      end
      self.RichTextBlockDesc:SetText(Desc)
      self:InitName(GenericModifyId, self.RGTextBlockName)
      self:UpdateTagList(OutSaveData)
      self:UpdateDescList(OutSaveData)
      self:UpdateAdditionNotes(GenericModifyRow.Inscription)
    else
      print("OutSaveData is null.")
    end
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(GenericModifyRow.Rarity)
    if ItemRarityResult then
      SetImageBrushBySoftObject(self.URGImageBg, ItemRarityData.GenericModifyTipsRareBg)
    end
    self:RefresVideohInfo(Slot, false)
  end
end

function WBP_GenericModifyBagTips_C:InitGenericModifyTipsBySettlement(GenericModifyData, Slot, bHideAdditionTips)
  self.bHideAdditionTips = bHideAdditionTips
  local GenericModifyId = GenericModifyData.ModifyId
  self.GenericModifyId = GenericModifyData.ModifyId
  local bIsUpgrade = false
  self.bIsUpgrade = bIsUpgrade
  if bIsUpgrade then
    self.ModifyChooseType = ModifyChooseType.UpgradeModify
  else
    self.ModifyChooseType = ModifyChooseType.GenericModify
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  self:FadeIn()
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(GenericModifyId), nil)
  if ResultGenericModify then
    UpdateVisibility(self.WBP_GenericModifyItemOld, false)
    UpdateVisibility(self.HorizontalBoxChange, false)
    UpdateVisibility(self.RGTextChangeDesc, false)
    UpdateVisibility(self.OverlayExchangeOrUpBg, false)
    local Level = 1
    if GenericModifyData then
      Level = GenericModifyData.Level
    end
    local LevelDesc = string.format("LV.%d", Level)
    self.RGTextBaseValueUpgrade:SetText(LevelDesc)
    self:UpdateModifyItemPos(bIsUpgrade)
    UpdateVisibility(self.HorizontalBoxUpgrade, true)
    UpdateVisibility(self.URGImageUpgradeTag, bIsUpgrade)
    UpdateVisibility(self.SpacerUpgradeLv1, bIsUpgrade)
    UpdateVisibility(self.SpacerUpgradeLv2, bIsUpgrade)
    UpdateVisibility(self.RGTextNextValue, bIsUpgrade)
    UpdateVisibility(self.URGImageArrow, bIsUpgrade)
    self.WBP_GenericModifyItem:InitGenericModifyItem(GenericModifyId, false)
    UpdateVisibility(self.WBP_GenericModifyItem, true)
    local OutSaveData = GetLuaInscription(GenericModifyRow.Inscription)
    if OutSaveData then
      local Desc = GetLuaInscriptionDesc(GenericModifyRow.Inscription)
      self.RichTextBlockDesc:SetText(Desc)
      self:InitName(GenericModifyId, self.RGTextBlockName)
      self:UpdateTagList(OutSaveData)
      self:UpdateDescList(OutSaveData)
      self:UpdateAdditionNotes(GenericModifyRow.Inscription)
    else
      print("OutSaveData is null.")
    end
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(GenericModifyRow.Rarity)
    if ItemRarityResult then
      SetImageBrushBySoftObject(self.URGImageBg, ItemRarityData.GenericModifyTipsRareBg)
    end
    self:RefresVideohInfo(Slot, false)
  end
end

function WBP_GenericModifyBagTips_C:InitSpecificModifyTips(SpecificModifyId, bHideAdditionTips)
  self.bHideAdditionTips = bHideAdditionTips
  self.SpecificModifyId = SpecificModifyId
  local bIsUpgrade = false
  self.bIsUpgrade = bIsUpgrade
  self.ModifyChooseType = ModifyChooseType.SpecificModify
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  self:FadeIn()
  UpdateVisibility(self.WBP_GenericModifyItemOld, false)
  UpdateVisibility(self.HorizontalBoxChange, false)
  UpdateVisibility(self.RGTextChangeDesc, false)
  UpdateVisibility(self.HorizontalBoxUpgrade, false)
  UpdateVisibility(self.OverlayExchangeOrUpBg, false)
  self:UpdateModifyItemPos(bIsUpgrade)
  UpdateVisibility(self.URGImageUpgradeTag, bIsUpgrade)
  self.WBP_GenericModifyItem:InitSpecificModifyItem(self.SpecificModifyId, false)
  UpdateVisibility(self.WBP_GenericModifyItem, true)
  local OutSaveData = GetLuaInscription(self.SpecificModifyId)
  if OutSaveData then
    local Desc = GetLuaInscriptionDesc(self.SpecificModifyId)
    local name = GetInscriptionName(self.SpecificModifyId)
    self.RichTextBlockDesc:SetText(Desc)
    self.RGTextBlockName:SetText(name)
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(UE.ERGItemRarity.EIR_Legend)
    if ItemRarityResult then
      self.RGTextBlockName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
    end
    self:UpdateTagList(OutSaveData)
    self:UpdateDescList(OutSaveData)
    self:UpdateAdditionNotes(self.SpecificModifyId)
  else
    print("OutSaveData is null.")
  end
  local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(UE.ERGItemRarity.EIR_Legend)
  if ItemRarityResult then
    SetImageBrushBySoftObject(self.URGImageBg, ItemRarityData.GenericModifyTipsRareBg)
  end
  self:RefresVideohInfo(UE.ERGGenericModifySlot.None, true)
end

function WBP_GenericModifyBagTips_C:FadeIn()
  self:PlayAnimation(self.ani_GenericModifyTips_in)
end

function WBP_GenericModifyBagTips_C:UpdateAdditionNotes(Inscription)
  if self.bHideAdditionTips then
    UpdateVisibility(self.CanvasPanelAdditionNote, false)
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local bIsShowTips = false
  local OutSaveData = GetLuaInscription(Inscription)
  if OutSaveData then
    local Index = 1
    if OutSaveData.ModAdditionalNoteMap then
      for k, v in pairs(OutSaveData.ModAdditionalNoteMap) do
        local Result, ModAdditionalNoteRow = DTSubsystem:GetModAdditionalNoteTableRow(k, nil)
        if Result then
          local NoteItem = GetOrCreateItem(self.VerticalBoxAdditionalItemList, Index, self.WBP_GenericModifyBagAdditionNoteItem:GetClass())
          NoteItem:InitGenericModifyAdditionNote(ModAdditionalNoteRow)
          Index = Index + 1
          bIsShowTips = true
        end
      end
    end
    HideOtherItem(self.VerticalBoxAdditionalItemList, Index)
  end
  UpdateVisibility(self.CanvasPanelAdditionNote, bIsShowTips)
end

function WBP_GenericModifyBagTips_C:UpdateModifyItemPos(bIsUpgrade)
  local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyItem)
  if bIsUpgrade then
    CanvasPanelSlot:SetPosition(self.UpgradeItemPos)
  else
    CanvasPanelSlot:SetPosition(self.NormalItemPos)
  end
end

function WBP_GenericModifyBagTips_C:InitName(GenericModifyId, Text)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(GenericModifyId), nil)
  if ResultGenericModify then
    local OutSaveData = GetLuaInscription(GenericModifyRow.Inscription)
    if OutSaveData then
      local name = GetInscriptionName(GenericModifyRow.Inscription)
      Text:SetText(name)
    end
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(GenericModifyRow.Rarity)
    if ItemRarityResult then
      Text:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
    end
  end
end

function WBP_GenericModifyBagTips_C:UpdateTagList(InscriptionDataAsset)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Index = 1
  local TagItemCls = UE.UClass.Load("/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyBagTag.WBP_GenericModifyBagTag_C")
  local Result, GenreRoutineRow = DTSubsystem:GetModGenreRoutineTableRow(tonumber(InscriptionDataAsset.ModGenreRoutineRowName), nil)
  if Result then
    for k, v in iterator(GenreRoutineRow.ModAdditionalTagAry) do
      if Result then
        local TagItem = GetOrCreateItem(self.HorizontalBoxTag, Index, TagItemCls)
        TagItem:InitGenericModifyTag(v)
        Index = Index + 1
      end
    end
  end
  HideOtherItem(self.HorizontalBoxTag, Index)
end

function WBP_GenericModifyBagTips_C:UpdateDescList(InscriptionDataAsset)
  local Index = 1
  if InscriptionDataAsset.ModifyLevelDescShowMode == UE.EModifyLevelDescShowMode.InAttrItem or self.bIsUpgrade then
    local DescItemCls = UE.UClass.Load("/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyBagDescItem.WBP_GenericModifyBagDescItem_C")
    for i, v in ipairs(InscriptionDataAsset.InscriptionDataAry) do
      if v.GenericModifyLevelId ~= "None" and v.GenericModifyLevelId ~= "" and v.bIsShowGenericModifyLevelDescInUI then
        local DescItem = GetOrCreateItem(self.VerticalBoxEffectDesc, Index, DescItemCls)
        DescItem:InitGenericModifyDescItem(v.GenericModifyLevelId, self.GenericModifyId, self.bIsUpgrade, v.ModifyLevelDescShowType, v.bIsShowHelpInUI)
        Index = Index + 1
      end
    end
  end
  HideOtherItem(self.VerticalBoxEffectDesc, Index)
end

function WBP_GenericModifyBagTips_C:RefresVideohInfo(Slot, bIsSpecify)
  if self.ModifyChooseType == ModifyChooseType.GenericModify or self.ModifyChooseType == ModifyChooseType.UpgradeModify then
    local Result, RowData = GetRowData(DT.DT_GenericModify, tostring(self.GenericModifyId))
    if Result then
      self:RefreshMedia(RowData.MediaSoftPtr)
    end
  else
    local Result, RowData = GetRowData(DT.DT_ModRefresh, tostring(self.SpecificModifyId))
    local ResultGeneric, RowDataGeneric = GetRowData(DT.DT_GenericModify, tostring(self.GenericModifyId))
    if Result then
      self:RefreshMedia(RowData.MediaSoftPtr)
    elseif ResultGeneric then
      self:RefreshMedia(RowDataGeneric.MediaSoftPtr)
    end
  end
end

function WBP_GenericModifyBagTips_C:RefreshMedia(ObjRef)
  self.MediaPlayer:SetLooping(true)
  if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
    UpdateVisibility(self.WBP_RGMaskWidget, true)
    local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
    if Obj and Obj:Cast(UE.UFileMediaSource) then
      self.MediaPlayer:OpenSource(Obj)
      self.MediaPlayer:Rewind()
    end
  else
    UpdateVisibility(self.WBP_RGMaskWidget, false)
  end
end

function WBP_GenericModifyBagTips_C:Hide()
  UpdateVisibility(self, false)
  self.GenericModifyId = nil
  self.SpecificModifyId = nil
  self.ModId = nil
  self.modComponent = nil
  self.ModifyChooseType = nil
end

return WBP_GenericModifyBagTips_C
