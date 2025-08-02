local GenericModifyConfig = require("GameConfig.GenericModify.GenericModifyConfig")
local WBP_GenericModifyTips_C = UnLua.Class()
local EModifyLvUpStatus = {
  Normal = 1,
  LvUp = 2,
  Specific = 3
}

function WBP_GenericModifyTips_C:Construct()
  self.BP_ButtonWithSoundChangeShowModify.OnHovered:Add(self, self.OnShowModifyChange)
  self.BP_ButtonWithSoundChangeShowModify.OnUnhovered:Add(self, self.OnHideModifyChange)
  self.BP_ButtonWithSoundReplaceShowModify.OnHovered:Add(self, self.OnShowModifyChange)
  self.BP_ButtonWithSoundReplaceShowModify.OnUnhovered:Add(self, self.OnHideModifyChange)
end

function WBP_GenericModifyTips_C:Destruct()
  self.BP_ButtonWithSoundChangeShowModify.OnHovered:Remove(self, self.OnShowModifyChange)
  self.BP_ButtonWithSoundChangeShowModify.OnUnhovered:Remove(self, self.OnHideModifyChange)
  self.BP_ButtonWithSoundReplaceShowModify.OnHovered:Remove(self, self.OnShowModifyChange)
  self.BP_ButtonWithSoundReplaceShowModify.OnUnhovered:Remove(self, self.OnHideModifyChange)
end

function WBP_GenericModifyTips_C:InitGenericModifyTipsBySell(GenericModifyId, bIsUpgrade, ParentView)
  self.bSell = true
  self:InitGenericModifyTips(GenericModifyId, bIsUpgrade, ParentView)
  UpdateVisibility(self.HorizontalBoxSell, true)
end

function WBP_GenericModifyTips_C:InitGenericModifyTips(GenericModifyId, bIsUpgrade, ParentView, ModifyChooseTypeParam)
  self.GenericModifyId = GenericModifyId
  self.bIsUpgrade = bIsUpgrade
  self.ParentView = ParentView
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(GenericModifyId), nil)
  if ResultGenericModify then
    local FollowStatu = self.WBP_FocusOnMarkWidget:Init(GenericModifyId)
    UpdateVisibility(self.xx_chuxian, 0 ~= FollowStatu)
    if 0 ~= FollowStatu then
      self:PlayAnimation(self.ani_GenericModifyTips_in)
    end
    local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if logicCommandDataSubsystem then
      UpdateVisibility(self.WBP_GenericModifyItemOld, false)
      UpdateVisibility(self.HorizontalBoxChange, false)
      self:StopAnimation(self.Ani_Replace_loop)
      UpdateVisibility(self.CanvasPanelUpOrChangeBg, false)
      UpdateVisibility(self.RGTextChangeDesc, false)
      if bIsUpgrade then
        self.RGStateControllerLvUp:ChangeStatus(EModifyLvUpStatus.LvUp)
      else
        self.RGStateControllerLvUp:ChangeStatus(EModifyLvUpStatus.Normal)
      end
      local bIsChanged = false
      local GenericModifyData = LogicGenericModify:GetGenericModifyData(GenericModifyId)
      if not GenericModifyData then
        GenericModifyData = LogicGenericModify:GetModifyBySlot(GenericModifyRow.Slot)
        if GenericModifyData then
          self:InitNameAndImg(GenericModifyData.ModifyId, self.RGTextOldName, self.URGImageChangeBg)
          self.WBP_GenericModifyItemOld:InitGenericModifyItem(GenericModifyData.ModifyId, false)
          UpdateVisibility(self.WBP_GenericModifyItemOld, true)
          if ModifyChooseTypeParam and ModifyChooseTypeParam == ModifyChooseType.RarityUpModify then
            UpdateVisibility(self.HorizontalBoxChange, false)
            UpdateVisibility(self.CanvasPanelUpOrChangeBg, false)
          else
            UpdateVisibility(self.HorizontalBoxChange, true)
            UpdateVisibility(self.CanvasPanelUpOrChangeBg, true)
            self:PlayAnimation(self.Ani_Replace_loop, 0, 0)
            UpdateVisibility(self.RGTextChangeDesc, true)
          end
          bIsChanged = true
        end
      end
      local Level = 1
      if GenericModifyData then
        Level = GenericModifyData.Level
      end
      self.RGTextBaseValueUpgrade:SetText(Level)
      local upgradeLevel = LogicGenericModify:GetModifyUpgradeLevelByModifyId(GenericModifyId)
      if bIsUpgrade then
        self.RGTextNextValue:SetText(Level + upgradeLevel)
      end
      self:UpdateModifyItemPos(bIsUpgrade)
      UpdateVisibility(self.HorizontalBoxUpgrade, bIsUpgrade or Level > 1)
      UpdateVisibility(self.URGImageUpgradeTag, bIsUpgrade)
      UpdateVisibility(self.SpacerUpgradeLv1, bIsUpgrade)
      UpdateVisibility(self.SpacerUpgradeLv2, bIsUpgrade)
      UpdateVisibility(self.RGTextNextValue, bIsUpgrade)
      UpdateVisibility(self.RGTextNextValue_1, bIsUpgrade)
      UpdateVisibility(self.URGImageArrow, bIsUpgrade)
      self.WBP_GenericModifyItem:InitGenericModifyItem(GenericModifyId, false)
      UpdateVisibility(self.WBP_GenericModifyItem, true)
      local OutSaveData = GetLuaInscription(GenericModifyRow.Inscription)
      if OutSaveData then
        local Desc = GetLuaInscriptionDesc(GenericModifyRow.Inscription, 1)
        local curSceneStatus = GetCurSceneStatus()
        if curSceneStatus == UE.ESceneStatus.EBattle and OutSaveData.ModifyLevelDescShowMode == UE.EModifyLevelDescShowMode.InDesc and not bIsUpgrade and not OutSaveData.bIsUseDescWhenNotActived then
          local descFmt = GetLuaInsModifyLevelDescFmt(GenericModifyRow.Inscription)
          local descList = {}
          for i, v in ipairs(OutSaveData.InscriptionDataAry) do
            if v.GenericModifyLevelId ~= "None" and v.bIsShowGenericModifyLevelDescInUI then
              local descItem = LogicGenericModify:GetLevelValue(v.GenericModifyLevelId, GenericModifyId, Level, v.ModifyLevelDescShowType)
              table.insert(descList, descItem)
            end
          end
          Desc = UE.FTextFormat(descFmt, table.unpack(descList))
        end
        self.RichTextBlockDesc:SetText(Desc)
        self:InitNameAndImg(GenericModifyId, self.RGTextBlockName)
        self:UpdateTagList(OutSaveData)
        self:UpdateDescList(OutSaveData)
      else
        print("OutSaveData is null.")
      end
    end
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(GenericModifyRow.Rarity)
    if ItemRarityResult then
      SetImageBrushBySoftObject(self.URGImageBg, ItemRarityData.GenericModifyRareBg)
    end
  end
end

function WBP_GenericModifyTips_C:InitSpecificModifyTips(SpecificModifyId)
  self.SpecificModifyId = SpecificModifyId
  local bIsUpgrade = false
  self.bIsUpgrade = bIsUpgrade
  UpdateVisibility(self.xx_chuxian, false)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if bIsUpgrade then
    self.RGStateControllerLvUp:ChangeStatus(EModifyLvUpStatus.LvUp)
  else
    self.RGStateControllerLvUp:ChangeStatus(EModifyLvUpStatus.Specific)
  end
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if logicCommandDataSubsystem then
    UpdateVisibility(self.WBP_GenericModifyItemOld, false)
    UpdateVisibility(self.HorizontalBoxChange, false)
    self:StopAnimation(self.Ani_Replace_loop)
    UpdateVisibility(self.CanvasPanelUpOrChangeBg, false)
    UpdateVisibility(self.RGTextChangeDesc, false)
    UpdateVisibility(self.HorizontalBoxUpgrade, false)
    UpdateVisibility(self.URGImage_up, false)
    self:UpdateModifyItemPos(bIsUpgrade)
    UpdateVisibility(self.URGImageUpgradeTag, bIsUpgrade)
    self.WBP_GenericModifyItem:InitSpecificModifyItem(SpecificModifyId, false)
    UpdateVisibility(self.WBP_GenericModifyItem, true)
    local OutSaveData = GetLuaInscription(SpecificModifyId)
    if OutSaveData then
      local Desc = GetLuaInscriptionDesc(SpecificModifyId)
      local name = GetInscriptionName(SpecificModifyId)
      self.RichTextBlockDesc:SetText(Desc)
      self.RGTextBlockName:SetText(name)
      local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(UE.ERGItemRarity.EIR_Legend)
      if ItemRarityResult then
        self.RGTextBlockName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
      end
      self:UpdateTagList(OutSaveData)
      self:UpdateDescList(OutSaveData)
    else
      print("OutSaveData is null.")
    end
  end
  local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(UE.ERGItemRarity.EIR_Legend)
  if ItemRarityResult then
    SetImageBrushBySoftObject(self.URGImageBg, ItemRarityData.GenericModifyRareBg)
  end
end

function WBP_GenericModifyTips_C:InitGenericModifyTipsByChanged(GenericModifyId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(GenericModifyId), nil)
  if ResultGenericModify then
    local FollowStatu = self.WBP_FocusOnMarkWidget:Init(GenericModifyId)
    UpdateVisibility(self.xx_chuxian, 0 ~= FollowStatu)
    if 0 ~= FollowStatu then
      self:PlayAnimation(self.ani_GenericModifyTips_in)
    end
    local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    local GenericModifyData = LogicGenericModify:GetGenericModifyData(GenericModifyId)
    if logicCommandDataSubsystem and GenericModifyData then
      local Level = 1
      if GenericModifyData then
        Level = GenericModifyData.Level
      end
      self.RGTextBaseValueUpgrade:SetText(Level)
      self:UpdateModifyItemPos(false)
      self.WBP_GenericModifyItem:InitGenericModifyItem(GenericModifyId, false)
      UpdateVisibility(self.WBP_GenericModifyItem, true)
      local OutSaveData = GetLuaInscription(GenericModifyRow.Inscription)
      if OutSaveData then
        local Desc = GetLuaInscriptionDesc(GenericModifyRow.Inscription)
        if OutSaveData.ModifyLevelDescShowMode == UE.EModifyLevelDescShowMode.InDesc and not OutSaveData.bIsUseDescWhenNotActived then
          local descFmt = GetLuaInsModifyLevelDescFmt(GenericModifyRow.Inscription)
          local descList = {}
          for i, v in ipairs(OutSaveData.InscriptionDataAry) do
            if v.GenericModifyLevelId ~= "None" and v.GenericModifyLevelId ~= "" and v.bIsShowGenericModifyLevelDescInUI then
              local descItem = LogicGenericModify:GetLevelValue(v.GenericModifyLevelId, GenericModifyId, Level, v.ModifyLevelDescShowType)
              table.insert(descList, descItem)
            end
          end
          Desc = UE.FTextFormat(descFmt, table.unpack(descList))
        end
        self.RichTextBlockDesc:SetText(Desc)
        self:InitNameAndImg(GenericModifyId, self.RGTextBlockName)
        self:UpdateTagList(OutSaveData)
        self:UpdateDescList(OutSaveData)
      else
        print("OutSaveData is null.")
      end
    end
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(GenericModifyRow.Rarity)
    if ItemRarityResult then
      SetImageBrushBySoftObject(self.URGImageBg, ItemRarityData.GenericModifyRareBg)
    end
  end
end

function WBP_GenericModifyTips_C:FadeIn(bRefresh)
  print("WBP_GenericModifyTips_C:FadeInFinished", bRefresh)
  if not bRefresh then
    self:PlayAnimation(self.ani_GenericModifyTips_in)
  else
  end
  for k, v in pairs(GenericModifyConfig.RarityToEffectWidget) do
    if self[v] then
      UpdateVisibility(self[v], false)
      self[v]:StopAnimation("ani_GenericModifyTips_in")
    end
  end
  if self.GenericModifyId then
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(self.GenericModifyId), nil)
      if ResultGenericModify then
        local Name = GenericModifyConfig.RarityToEffectWidget[GenericModifyRow.Rarity]
        if Name and self[Name] then
          UpdateVisibility(self[Name], true)
          if not bRefresh then
            self[Name]:PlayAnimation("ani_GenericModifyTips_in")
          end
        end
      end
    end
  elseif self.ModId then
    local Name = GenericModifyConfig.RarityToEffectWidget[UE.ERGItemRarity.EIR_Legend]
    if self[Name] then
      UpdateVisibility(self[Name], true)
      if not bRefresh then
        self[Name]:PlayAnimation("ani_GenericModifyTips_in")
      end
    end
  elseif self.SpecificModifyId then
    local Name = GenericModifyConfig.RarityToEffectWidget[UE.ERGItemRarity.EIR_Legend]
    if self[Name] then
      UpdateVisibility(self[Name], true)
      if not bRefresh then
        self[Name]:PlayAnimation("ani_GenericModifyTips_in")
      end
    end
  end
end

function WBP_GenericModifyTips_C:UpdateModifyItemPos(bIsUpgrade)
  local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyItem)
  if bIsUpgrade then
    CanvasPanelSlot:SetPosition(self.UpgradeItemPos)
  else
    CanvasPanelSlot:SetPosition(self.NormalItemPos)
  end
end

function WBP_GenericModifyTips_C:InitNameAndImg(GenericModifyId, Text, Img)
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
    if self.bSell then
      local ItemPriceResult, ItemPriceData = GetRowData(DT.DT_GenericModifyPrice, GenericModifyRow.Rarity + 1)
      if ItemPriceResult then
        local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChooseSell_C.UIName)
        if ChoosePanel then
          self.RGTextSellNum_1:SetText(math.floor(ItemPriceData.Price * ChoosePanel.InteractComp.SellRewardAddRatio + 0.5))
        end
      end
    end
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(GenericModifyRow.Rarity)
    if ItemRarityResult then
      Text:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
      if Img then
        Img:SetColorAndOpacity(ItemRarityData.GenericModifyRareBgColor)
      end
    end
  end
end

function WBP_GenericModifyTips_C:UpdateTagList(InscriptionDataAsset)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Index = 1
  local TagItemCls = UE.UClass.Load("/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyTag.WBP_GenericModifyTag_C")
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

function WBP_GenericModifyTips_C:UpdateDescList(InscriptionDataAsset)
  local DescItemCls = UE.UClass.Load("/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyDescItem.WBP_GenericModifyDescItem_C")
  local Index = 1
  if InscriptionDataAsset.ModifyLevelDescShowMode == UE.EModifyLevelDescShowMode.InAttrItem or self.bIsUpgrade then
    for i, v in ipairs(InscriptionDataAsset.InscriptionDataAry) do
      if v.GenericModifyLevelId ~= "None" and v.GenericModifyLevelId ~= "" and v.bIsShowGenericModifyLevelDescInUI then
        local DescItem = GetOrCreateItem(self.VerticalBoxEffectDesc, Index, DescItemCls)
        print("UpdateDescList", v.ModifyLevelDescShowType)
        DescItem:InitGenericModifyDescItem(v.GenericModifyLevelId, self.GenericModifyId, self.bIsUpgrade, v.ModifyLevelDescShowType, v.bIsShowHelpInUI)
        Index = Index + 1
      end
    end
  end
  HideOtherItem(self.VerticalBoxEffectDesc, Index)
end

function WBP_GenericModifyTips_C:Hide()
  UpdateVisibility(self, false)
  self.GenericModifyId = nil
  self.SpecificModifyId = nil
  self.ModId = nil
  self.modComponent = nil
end

function WBP_GenericModifyTips_C:OnShowModifyChange()
  if not LogicGenericModify.bCanOperator then
    print("WBP_GenericModifyTips_C:OnShowModifyChange LogicGenericModify.bCanOperator false")
    return
  end
  if self.ParentView and self.ParentView.bCanSelect == false then
    print("WBP_GenericModifyTips_C:OnShowModifyChange bCanSelect false")
    return
  end
  if not self.GenericModifyId then
    return
  end
  local resultGenericModify, genericModifyRow = GetRowData(DT.DT_GenericModify, tostring(self.GenericModifyId))
  if not resultGenericModify then
    return
  end
  local genericModifyData = LogicGenericModify:GetModifyBySlot(genericModifyRow.Slot)
  if genericModifyData then
    self:InitGenericModifyTipsByChanged(genericModifyData.ModifyId)
    if self.ParentView then
      self.ParentView:OnShowModifyChange(genericModifyData.ModifyId)
    end
  end
  self:PlayAnimation(self.Ani_flushed)
  self.RGStateControllerChange:ChangeStatus(EHover.Hover)
end

function WBP_GenericModifyTips_C:OnHideModifyChange()
  if not LogicGenericModify.bCanOperator then
    print("WBP_GenericModifyTips_C:OnHideModifyChange LogicGenericModify.bCanOperator false")
    return
  end
  if self.ParentView and self.ParentView.bCanSelect == false then
    print("WBP_GenericModifyTips_C:OnHideModifyChange bCanSelect false")
    return
  end
  if not self.GenericModifyId then
    return
  end
  local resultGenericModify, genericModifyRow = GetRowData(DT.DT_GenericModify, tostring(self.GenericModifyId))
  if not resultGenericModify then
    return
  end
  self:InitGenericModifyTips(self.GenericModifyId, false, self.ParentView)
  if self.ParentView then
    self.ParentView:OnHideModifyChange(self.GenericModifyId)
  end
  self:PlayAnimation(self.Ani_flushed)
  self.RGStateControllerChange:ChangeStatus(EHover.UnHover)
end

function WBP_GenericModifyTips_C:ModifyTips_Nav_Up()
  if IsValidObj(self.ParentView) then
    return self.ParentView
  end
end

function WBP_GenericModifyTips_C:ModifyTips_Nav_Down()
  if IsValidObj(self.ParentView) and IsValidObj(self.ParentView.ParentView) then
    if CheckIsVisility(self.ParentView.ParentView.CanvasPanelAbandoned) then
      return self.ParentView.ParentView.BP_ButtonWithSoundAbandoned
    end
    if CheckIsVisility(self.ParentView.ParentView.BP_ButtonWithSoundRefresh) then
      return self.ParentView.ParentView.BP_ButtonWithSoundRefresh
    end
  end
end

return WBP_GenericModifyTips_C
