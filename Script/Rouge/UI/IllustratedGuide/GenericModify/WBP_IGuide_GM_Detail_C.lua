local WBP_IGuide_GM_Detail_C = UnLua.Class()

function WBP_IGuide_GM_Detail_C:RefreshDetailPanel(GenericModifyInfo, bCamShowTip, bIsFromIGuideSpecificModify)
  if nil == GenericModifyInfo then
    return
  end
  local bShowMovie = false
  local bHaveModAdditional = false
  self.Info = GenericModifyInfo.ModifieConfig
  self.bCamShowTip = bCamShowTip
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if nil == logicCommandDataSubsystem then
    return
  end
  bShowMovie = nil ~= self.Info.MediaSoftPtr and UE.UKismetSystemLibrary.IsValidSoftObjectReference(self.Info.MediaSoftPtr)
  local OutSaveData = GetLuaInscription(self.Info.Inscription)
  if OutSaveData then
    if bIsFromIGuideSpecificModify or nil == OutSaveData.ModAdditionalNoteMap then
      bHaveModAdditional = false
    else
      bHaveModAdditional = table.count(OutSaveData.ModAdditionalNoteMap) >= 1
    end
    local Desc = GetLuaInscriptionDesc(self.Info.Inscription, 1)
    self.RichTextBlockDesc:SetText(Desc)
    UpdateVisibility(self.Image_fENGE, false)
    if self.VerticalBoxEffectDesc then
      self.VerticalBoxEffectDesc:ClearChildren()
      local DescItemCls = UE.UClass.Load("/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyDescItem.WBP_GenericModifyDescItem_C")
      if not bCamShowTip then
        DescItemCls = UE.UClass.Load("/Game/Rouge/UI/IllustratedGuide/GenericModify/WBP_IllustratedGuideItem.WBP_IllustratedGuideItem_C")
      end
      local Index = 1
      for i, v in ipairs(OutSaveData.InscriptionDataAry) do
        if v.GenericModifyLevelId ~= "None" and v.bIsShowGenericModifyLevelDescInUI then
          local DescItem = GetOrCreateItem(self.VerticalBoxEffectDesc, Index, DescItemCls)
          DescItem:InitGenericModifyDescItem(v.GenericModifyLevelId, self.Info.ModifyId, not bCamShowTip, v.ModifyLevelDescShowType, v.bIsShowHelpInUI)
          if not bCamShowTip then
          end
          UpdateVisibility(self.Image_fENGE, true)
          Index = Index + 1
        end
      end
    end
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if not DTSubsystem then
      return
    end
    if bCamShowTip then
      self.HorizontalBox_Tag:ClearChildren()
      local Index = 1
      local TagItemCls = UE.UClass.Load("/Game/Rouge/UI/IllustratedGuide/GenericModify/WBP_IGuide_GM_God_Tag.WBP_IGuide_GM_God_Tag_C")
      local Result, GenreRoutineRow = DTSubsystem:GetModGenreRoutineTableRow(tonumber(OutSaveData.ModGenreRoutineRowName), nil)
      UpdateVisibility(self.HorizontalBox_Tag, false)
      if Result then
        for k, v in iterator(GenreRoutineRow.ModAdditionalTagAry) do
          UpdateVisibility(self.HorizontalBox_Tag, true)
          local TagItem = GetOrCreateItem(self.HorizontalBox_Tag, Index, TagItemCls)
          TagItem.RGTextDesc:Settext(v)
          Index = Index + 1
        end
      end
    end
    if nil == OutSaveData.Icon or OutSaveData.Icon == "" then
      print("\232\175\141\230\157\161", self.Info.Inscription, "\230\178\161\230\156\137\233\133\141\231\189\174\229\155\190\230\160\135")
    end
    SetImageBrushByPath(self.Icon, OutSaveData.Icon)
    if self.RGStateController_Tag then
      self.RGStateController_Tag:ChangeStatus("None", true)
    end
    if self.Info.GenericModifyType == UE.ERGGenericModifyType.Normal then
      GetStringById(1, self.Txt_Desc)
    elseif self.Info.GenericModifyType == UE.ERGGenericModifyType.Hero then
      GetStringById(2, self.Txt_Desc)
    elseif self.Info.GenericModifyType == UE.ERGGenericModifyType.Dual then
      GetStringById(3, self.Txt_Desc)
    elseif self.Info.GenericModifyType == UE.ERGGenericModifyType.ShareWin then
      GetStringById(18, self.Txt_Desc)
      if self.RGStateController_Tag then
        self.RGStateController_Tag:ChangeStatus("ShareWin", true)
      end
    elseif self.Info.GenericModifyType == UE.ERGGenericModifyType.Legend then
      if self.RGStateController_Tag then
        self.RGStateController_Tag:ChangeStatus("Legend", true)
      end
      GetStringById(17, self.Txt_Desc)
    end
    local name = GetInscriptionName(self.Info.Inscription)
    self.Txt_Name:SetText(name)
    UpdateVisibility(self.Image_221, bHaveModAdditional or bShowMovie, true)
    local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(UE.ERGItemRarity.EIR_Legend, nil)
    if ResultItemRarity and self.Img_Rarity then
      UpdateVisibility(self.Img_Rarity, bIsFromIGuideSpecificModify)
      self.Img_Rarity:SetColorAndOpacity(ItemRarityRow.GenericModifyRareBgColor)
    end
  end
  if self.Info.UnlockMethodDesc then
    UpdateVisibility(self.Canvas_UnlockMethodDesc, true)
    local curCount = 0
    local targetCount = 0
    if self.Info.UnlockTaskId > 0 then
      curCount = Logic_MainTask.GetFirstCountValueByTaskId(self.Info.UnlockTaskId)
      targetCount = Logic_MainTask.GetFirstTargetValueByTaskId(self.Info.UnlockTaskId)
    end
    local desc = UE.FTextFormat(self.Info.UnlockMethodDesc, curCount, targetCount)
    self.Txt_UnlockMethodDesc:SetText(desc)
  else
    UpdateVisibility(self.Canvas_UnlockMethodDesc, false)
  end
end

function WBP_IGuide_GM_Detail_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.bCamShowTip and self.Info ~= nil then
    EventSystem.Invoke(EventDef.IllustratedGuide.OnShowSkillTips, true, self.Info)
  end
  PlaySound2DByName(self.OnMouseEnterSoundName, "WBP_IGuide_GM_Detail_C")
end

function WBP_IGuide_GM_Detail_C:OnMouseLeave(MyGeometry, MouseEvent)
  EventSystem.Invoke(EventDef.IllustratedGuide.OnShowSkillTips, false, self.Info)
end

return WBP_IGuide_GM_Detail_C
