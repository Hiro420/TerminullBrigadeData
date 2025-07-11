local GenericModifyConfig = require("GameConfig.GenericModify.GenericModifyConfig")
local WBP_Generic_Pack_ChooseItem = UnLua.Class()
local GetGenericGroupId = function(self, Idx)
  if not self then
    return 0
  end
  local packItemAry = self:GetGenericModifyPackItemAry()
  if table.IsEmpty(packItemAry) then
    return 0
  end
  if not packItemAry[Idx] then
    return 0
  end
  local result, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(packItemAry[Idx].ModifyId))
  if not result then
    return 0
  end
  return GenericModifyRow.GroupId
end
function WBP_Generic_Pack_ChooseItem:GetGenericModifyPackItemAry()
  local packAryLua = {}
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return packAryLua
  end
  local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
  if not GenericPackComp then
    return packAryLua
  end
  if GenericPackComp.PreviewModifyData.PreviewModifyList:IsValidIndex(self.Idx) then
    local PackData = GenericPackComp.PreviewModifyData.PreviewModifyList:Get(self.Idx)
    for i, v in pairs(PackData.Items) do
      local packItem = {
        ModifyId = v.ModifyId,
        bActive = v.bActive
      }
      table.insert(packAryLua, packItem)
    end
    return packAryLua
  end
  return packAryLua
end
function WBP_Generic_Pack_ChooseItem:GetGenericModifyPackData()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return -1, -1
  end
  local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
  if not GenericPackComp then
    return -1, -1
  end
  if GenericPackComp.PreviewModifyData.PreviewModifyList:IsValidIndex(self.Idx) then
    local PackData = GenericPackComp.PreviewModifyData.PreviewModifyList:Get(self.Idx)
    return PackData.RowId, PackData.GroupId
  end
  return -1, -1
end
function WBP_Generic_Pack_ChooseItem:Construct()
  self.Btn_Select.OnClicked:Add(self, self.OnBtnSelectClicked)
  self.Btn_Select.OnHovered:Add(self, self.OnHovered)
  self.Btn_Select.OnUnhovered:Add(self, self.OnUnhovered)
end
function WBP_Generic_Pack_ChooseItem:Destruct()
  self.Btn_Select.OnClicked:Remove(self, self.OnBtnSelectClicked)
  self.Btn_Select.OnHovered:Remove(self, self.OnHovered)
  self.Btn_Select.OnUnhovered:Remove(self, self.OnUnhovered)
end
function WBP_Generic_Pack_ChooseItem:OnBtnSelectClicked()
  if not LogicGenericModify.bCanOperator then
    print("WBP_Generic_Pack_ChooseItem:Select LogicGenericModify.bCanOperator false")
    return
  end
  if self.bCanSelect == false then
    print("WBP_Generic_Pack_ChooseItem:Select bCanSelect false")
    return
  end
  if self.ParentView then
    self.ParentView:SelectModifyIdx(self.Idx)
  else
    print("WBP_Generic_Pack_ChooseItem:Select ParentView is nil")
  end
  local PC = self:GetOwningPlayer()
  LogicGenericModify:AddGenericModifyPack(PC, self.Idx)
end
function WBP_Generic_Pack_ChooseItem:FadeIn()
  print("WBP_Generic_Pack_ChooseItem:FadeIn()")
  self.CanvasPanelAdditionNote:SetRenderOpacity(0)
  self.URGImageSelect:SetRenderOpacity(0)
  self.select_glow:SetRenderOpacity(0)
  self.URGImageSelect_1:SetRenderOpacity(0)
  self.CanvasPanelRoot:SetRenderOpacity(1)
  self:PlayAnimation(self.AniFadeIn)
end
function WBP_Generic_Pack_ChooseItem:FadeInFinished()
  print("WBP_Generic_Pack_ChooseItem:FadeInFinished()")
  self.bCanSelect = true
  self.CanvasPanelRoot:SetRenderOpacity(1)
end
function WBP_Generic_Pack_ChooseItem:FadeOut(Idx)
  local bIsShowEff = self.Idx == Idx
  self:PlayAnimation(self.ani_click, 0, 1, UE.EUMGSequencePlayMode.Forward, 2, true)
  local groupId = GetGenericGroupId(self, Idx)
  if bIsShowEff then
    self.StateCtrl_ClickEff_Group:ChangeStatus(tostring(groupId))
  else
    self.StateCtrl_ClickEff_Group:ChangeStatus("None")
  end
end
function WBP_Generic_Pack_ChooseItem:OnHovered()
  self.bIsHovered = true
  local screenX = UE.UWidgetLayoutLibrary.GetViewportSize(self).X
  local screenY = UE.UWidgetLayoutLibrary.GetViewportSize(self).Y
  local screenRate = screenX / screenY
  if NearlyEquals(screenRate, self.ScreenRate, 1.0E-6) then
    self.VerticalBoxAdditionNote:SetRenderScale(self.NoteScaleDPIAdapt)
  else
    self.VerticalBoxAdditionNote:SetRenderScale(UE.FVector2D(1, 1))
  end
  self:HoverItem()
  self:SetRenderScale(UE.FVector2D(1.01, 1.01) * self.ScaleOffset)
  self:PlayAnimation(self.ani_hover)
end
function WBP_Generic_Pack_ChooseItem:HoverItem()
  if not self.bIsHovered then
    return
  end
  local rowId, groupId = self:GetGenericModifyPackData()
  self.StateCtrl_HoverEff_Group:ChangeStatus(tostring(groupId))
  UpdateVisibility(self.URGImageSelect, true)
  UpdateVisibility(self.select_glow, true)
  UpdateVisibility(self.URGImageSelect_1, true)
  UpdateVisibility(self.GenericModifyChooseItemHover, true)
  local result, modifyRow = GetRowData(DT.DT_GenericModify, tostring(self.CurModifyId))
  if result then
    local bIsShowTips = self:UpdateAdditionNotes(modifyRow.Inscription, self.CurModifyId)
    UpdateVisibility(self.CanvasPanelAdditionNote, bIsShowTips)
  else
    UpdateVisibility(self.CanvasPanelAdditionNote, false)
  end
  if self.ParentView then
    self.ParentView:HoverItem(self.CurModifyId, true)
  end
end
function WBP_Generic_Pack_ChooseItem:OnUnhovered()
  if self.ParentView then
    self.ParentView:HoverItem(-1, false)
  end
  self.bIsHovered = false
  self:SetRenderScale(UE.FVector2D(1, 1) * self.ScaleOffset)
  UpdateVisibility(self.URGImageSelect, false)
  UpdateVisibility(self.select_glow, false)
  UpdateVisibility(self.CanvasPanelAdditionNote, false)
  UpdateVisibility(self.URGImageSelect_1, false)
  UpdateVisibility(self.GenericModifyChooseItemHover, false)
  self:StopAnimation(self.ani_hover)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if self.HoverSlot then
    self.HoverFunc(self.ParentView, self.HoverSlot, false)
    self.HoverSlot = nil
  else
    local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(self.CurModifyId), nil)
    if ResultGenericModify and self.HoverFunc and GenericModifyRow.Slot ~= UE.ERGGenericModifySlot.None then
      self.HoverFunc(self.ParentView, GenericModifyRow.Slot, false)
    end
  end
  if self.MediaPlayer then
    self.MediaPlayer:Close()
  end
end
function WBP_Generic_Pack_ChooseItem:InitGenericModifyPackChooseItem(GenericPackItemAry, Idx, HoverFunc, ParentView)
  self.bIsHovered = false
  self.StateCtrl_ClickEff_Group:ChangeStatus("None")
  UpdateVisibility(self, true)
  self:FadeIn()
  self.ParentView = ParentView
  self.HoverFunc = HoverFunc
  self.Idx = Idx
  local GenericPackItemAry = self:GetGenericModifyPackItemAry()
  for i, v in pairs(GenericPackItemAry) do
    local itemName = "WBP_GenericModify_Pack_Item_" .. i
    if self[itemName] then
      self[itemName]:InitGenericModifyPackItem(v, self)
    end
  end
  self:UpdateChooseItem()
end
function WBP_Generic_Pack_ChooseItem:UpdateChooseItem()
  self.CurModifyId = -1
  local rowId, groupId = self:GetGenericModifyPackData()
  local resultPack, rowPack = GetRowData(DT.DT_GenericModifyPack, tostring(rowId))
  if resultPack then
    self.RichTextBlockDesc:SetText(rowPack.Desc)
  end
  local resultGroup, rowGroup = GetRowData(DT.DT_GenericModifyGroup, tostring(groupId))
  if resultGroup then
    self.RGTextBlockName:SetText(rowGroup.Name)
    self.RGTextBlockName:SetColorAndOpacity(self.DefaultTxtColor)
  end
  UpdateVisibility(self.CanvasPanelAdditionNote, false)
  self:UpdateTagList(nil)
  self:UpdateDescList(nil)
  local genericPackItemAry = self:GetGenericModifyPackItemAry()
  local modifyId = -1
  if genericPackItemAry[1] then
    modifyId = genericPackItemAry[1].ModifyId
  end
  self:UpdateHoverStyle(modifyId)
  if self.ParentView then
    self.ParentView:HoverItem(-1, false)
  end
end
function WBP_Generic_Pack_ChooseItem:UpdateChooseItemByModifyId(ModifyId)
  self.CurModifyId = ModifyId
  local FollowStatu = self.WBP_FocusOnMarkWidget:Init(ModifyId)
  UpdateVisibility(self.xx_chuxian, 0 ~= FollowStatu)
  if 0 ~= FollowStatu then
  end
  self:HoverItem()
  self:InitNameAndImg(ModifyId, self.RGTextBlockName)
  local OutSaveData = GetLuaInscription(ModifyId)
  if OutSaveData then
    local Desc = GetLuaInscriptionDesc(ModifyId, 1)
    if OutSaveData.ModifyLevelDescShowMode == UE.EModifyLevelDescShowMode.InDesc and not OutSaveData.bIsUseDescWhenNotActived then
      local descFmt = GetLuaInsModifyLevelDescFmt(ModifyId)
      local descList = {}
      for i, v in ipairs(OutSaveData.InscriptionDataAry) do
        if v.GenericModifyLevelId ~= "None" and v.bIsShowGenericModifyLevelDescInUI then
          local descItem = LogicGenericModify:GetLevelValue(v.GenericModifyLevelId, ModifyId, 1, v.ModifyLevelDescShowType)
          table.insert(descList, descItem)
        end
      end
      Desc = UE.FTextFormat(descFmt, table.unpack(descList))
    end
    self.RichTextBlockDesc:SetText(Desc)
    self:UpdateTagList(OutSaveData)
    self:UpdateDescList(OutSaveData)
    self:UpdateHoverStyle(ModifyId)
  end
end
function WBP_Generic_Pack_ChooseItem:UpdateHoverStyle(ModifyId)
  local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if ResultGenericModify then
    local color = GenericModifyConfig.GroupIdToHoverColor[tostring(GenericModifyRow.GroupId)]
    self:UpdateHoverColor(color)
    local ItemRarityResult, ItemRarityData = GetRowData(DT.DT_ItemRarity, GenericModifyRow.Rarity)
    if ItemRarityResult then
      SetImageBrushBySoftObject(self.URGImageBg, ItemRarityData.GenericModifyRareBg)
    end
  end
end
function WBP_Generic_Pack_ChooseItem:InitNameAndImg(GenericModifyId, Text)
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
function WBP_Generic_Pack_ChooseItem:UpdateDescList(InscriptionDataAsset)
  local DescItemCls = UE.UClass.Load("/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyDescItem.WBP_GenericModifyDescItem_C")
  local Index = 1
  if InscriptionDataAsset and InscriptionDataAsset.ModifyLevelDescShowMode == UE.EModifyLevelDescShowMode.InAttrItem then
    for i, v in ipairs(InscriptionDataAsset.InscriptionDataAry) do
      if v.GenericModifyLevelId ~= "None" and v.GenericModifyLevelId ~= "" and v.bIsShowGenericModifyLevelDescInUI then
        local DescItem = GetOrCreateItem(self.VerticalBoxEffectDesc, Index, DescItemCls)
        print("UpdateDescList", v.ModifyLevelDescShowType)
        DescItem:InitGenericModifyDescItem(v.GenericModifyLevelId, self.GenericModifyId, false, v.ModifyLevelDescShowType, v.bIsShowHelpInUI)
        Index = Index + 1
      end
    end
  end
  HideOtherItem(self.VerticalBoxEffectDesc, Index)
end
function WBP_Generic_Pack_ChooseItem:UpdateTagList(InscriptionDataAsset)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Index = 1
  if InscriptionDataAsset then
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
  end
  HideOtherItem(self.HorizontalBoxTag, Index)
end
function WBP_Generic_Pack_ChooseItem:UpdateHoverColor(Color, GlowColor)
  local glowColor = GlowColor or Color
  local matSelect1 = self.URGImageSelect_1:GetDynamicMaterial()
  if matSelect1 then
    matSelect1:SetVectorParameterValue("color", Color)
    matSelect1:SetScalarParameterValue("alpha", Color.A)
  end
  local mat = self.select_glow:GetDynamicMaterial()
  if mat then
    mat:SetVectorParameterValue("color", glowColor)
    mat:SetScalarParameterValue("alpha", glowColor.A)
  end
end
function WBP_Generic_Pack_ChooseItem:UpdateAdditionNotes(Inscription, ModifyId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return false
  end
  local bIsShowTips = false
  if not Inscription then
    return false
  end
  local Result, RowData = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if Result then
    self:RefreshMedia(RowData.MediaSoftPtr)
    bIsShowTips = CheckIsVisility(self.Movie)
  end
  local OutSaveData = GetLuaInscription(Inscription)
  if OutSaveData then
    local Index = 2
    if self:FocusSelf() and #Logic_IllustratedGuide.CurFocusGenericModifySubGroup > 0 then
      UpdateVisibility(self.WBP_GenericModifyPrefix, true)
      local NoteItem = GetOrCreateItem(self.VerticalBoxAdditionNote, Index, self.WBP_GenericModifyPrefix:GetClass())
      if NoteItem then
        NoteItem:InitGenericModifyPrefix(ModifyId)
        bIsShowTips = true
      end
    else
      UpdateVisibility(self.WBP_GenericModifyPrefix, false)
    end
    Index = Index + 1
    if OutSaveData.ModAdditionalNoteMap then
      for k, v in pairs(OutSaveData.ModAdditionalNoteMap) do
        local Result, ModAdditionalNoteRow = DTSubsystem:GetModAdditionalNoteTableRow(k, nil)
        if Result then
          local NoteItem = GetOrCreateItem(self.VerticalBoxAdditionNote, Index, self.WBP_GenericModifyAdditionNoteItem:GetClass())
          NoteItem:InitGenericModifyAdditionNote(ModAdditionalNoteRow)
          Index = Index + 1
          bIsShowTips = true
        end
      end
    end
    HideOtherItem(self.VerticalBoxAdditionNote, Index)
  end
  return bIsShowTips
end
function WBP_Generic_Pack_ChooseItem:FocusSelf()
  local Result = false
  local RowInfo = UE.FRGGenericModifyTableRow
  Result, RowInfo = GetRowData(DT.DT_GenericModify, self.CurModifyId)
  if Result then
    for index, value in ipairs(Logic_IllustratedGuide.CurFocusGenericModifySubGroup) do
      if RowInfo.SubGroupId == value then
        return true
      end
      for k, v in pairs(Logic_IllustratedGuide.GenericModifySubGroup[value]) do
        local FocusResult = false
        local FocusRowInfo = UE.FRGGenericModifyTableRow
        FocusResult, FocusRowInfo = GetRowData(DT.DT_GenericModify, v)
        for key1, FrontConditions in pairs(FocusRowInfo.FrontConditions:ToTable()) do
          for index, SubGroupId in ipairs(FrontConditions.SubGroupIds:ToTable()) do
            if RowInfo.SubGroupId == SubGroupId then
              return true
            end
          end
        end
      end
    end
  end
  return false
end
function WBP_Generic_Pack_ChooseItem:RefreshMedia(ObjRef)
  self.MediaPlayer:SetLooping(true)
  if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
    UpdateVisibility(self.Movie, true)
    local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
    if Obj and Obj:Cast(UE.UFileMediaSource) then
      self.MediaPlayer:OpenSource(Obj)
      self.MediaPlayer:Rewind()
    end
  else
    UpdateVisibility(self.Movie, false)
  end
end
function WBP_Generic_Pack_ChooseItem:Item3_Nav_Right()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    local IdxTemp = self.Idx
    if 3 == self.Idx then
      IdxTemp = 1
    else
      IdxTemp = self.Idx + 1
    end
    local chooseItemStr = "WBP_GenericModify_Pack_ChooseItem_" .. IdxTemp
    local chooseItem = self.ParentView[chooseItemStr]
    return chooseItem
  end
  return nil
end
function WBP_Generic_Pack_ChooseItem:Item1_Nav_Left()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    local IdxTemp = self.Idx
    if 1 == self.Idx then
      IdxTemp = 3
    else
      IdxTemp = self.Idx - 1
    end
    local chooseItemStr = "WBP_GenericModify_Pack_ChooseItem_" .. IdxTemp
    local chooseItem = self.ParentView[chooseItemStr]
    return chooseItem
  end
  return nil
end
function WBP_Generic_Pack_ChooseItem:Item_Nav_Down()
  return self
end
return WBP_Generic_Pack_ChooseItem
