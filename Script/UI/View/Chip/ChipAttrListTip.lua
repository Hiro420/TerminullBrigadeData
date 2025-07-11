local ChipAttrListTip = UnLua.Class()
function ChipAttrListTip:Construct()
end
function ChipAttrListTip:Destruct()
end
function ChipAttrListTip:InitEmpty()
  UpdateVisibility(self.CanvasPanel_Root, false)
end
function ChipAttrListTip:InitChipAttrListTip(ChipBagsItemData, bEquiped, ChipCompareState, ChipViewState, bForceShowFit)
  UpdateVisibility(self.CanvasPanel_Root, true)
  local viewModel = UIModelMgr:Get("ChipViewModel")
  if viewModel:CheckIsChipUpgradeMat(ChipBagsItemData) then
    return
  end
  UpdateVisibility(self, true)
  if ChipViewState == EChipViewState.Normal then
    if bEquiped then
      self.RGStateControllerEquip:ChangeStatus(EEquiped.UnEquiped)
    else
      self.RGStateControllerEquip:ChangeStatus(EEquiped.Equiped)
    end
    local rare = viewModel:GetChipRare(ChipBagsItemData)
    if ChipBagsItemData.Chip.level >= viewModel:GetMaxLv(rare) then
      self.StateCtrl_MaxLv:ChangeStatus(EMaxLv.MaxLv)
    else
      self.StateCtrl_MaxLv:ChangeStatus(EMaxLv.Normal)
    end
  elseif ChipViewState == EChipViewState.Strength then
    if bEquiped then
      self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
    else
      self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
    end
  end
  self.RGStateControllerCompare:ChangeStatus(ChipCompareState)
  local curHeroId = viewModel:GetCurHeroId()
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  local heroName = ""
  if tbHeroMonster and tbHeroMonster[ChipBagsItemData.Chip.bindHeroID] and tbHeroMonster[ChipBagsItemData.Chip.bindHeroID].Name then
    heroName = tbHeroMonster[ChipBagsItemData.Chip.bindHeroID].Name
  end
  if 0 == ChipBagsItemData.Chip.bindHeroID then
    self.StateCtrl_RoleLimit:ChangeStatus(ERoleLimit.Normal)
  elseif bForceShowFit then
    self.StateCtrl_RoleLimit:ChangeStatus(ERoleLimit.RoleFit)
    self.Txt_HeroFit:SetText(UE.FTextFormat(self.TxtFmtRoleFit, heroName))
  elseif ChipBagsItemData.Chip.bindHeroID ~= curHeroId then
    self.StateCtrl_RoleLimit:ChangeStatus(ERoleLimit.RoleLimit)
    self.Txt_HeroLimit:SetText(UE.FTextFormat(self.TxtFmtRoleLimit, heroName))
  else
    self.StateCtrl_RoleLimit:ChangeStatus(ERoleLimit.RoleFit)
    self.Txt_HeroFit:SetText(UE.FTextFormat(self.TxtFmtRoleFit, heroName))
  end
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if tbGeneral and tbGeneral[ChipBagsItemData.TbChipData.ID] then
    local tbGeneralData = tbGeneral[ChipBagsItemData.TbChipData.ID]
    self.RGTextName:SetText(viewModel:GetChipName(ChipBagsItemData))
    local rare = viewModel:GetChipRare(ChipBagsItemData)
    self.StateCtrl_Rare:ChangeStatus(tostring(rare))
  end
  local tbChipSlots = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if tbChipSlots and tbChipSlots[ChipBagsItemData.TbChipData.Slot] then
    self.RGTextSlotName:SetText(tbChipSlots[ChipBagsItemData.TbChipData.Slot].name)
  end
  self.RGTextSlotStrengthLv:SetText(ChipBagsItemData.Chip.level)
  UpdateVisibility(self.CanvasPanelCoreAttr, true)
  local resultCore, rowCore = GetRowData(DT.DT_AttributeModifyOp, tostring(ChipBagsItemData.TbChipData.AttrID))
  local descCore = ""
  if resultCore then
    descCore = rowCore.Desc
    local attrID, attrValue = viewModel:GetMainAttrValueByChipBagItemData(ChipBagsItemData)
    self.WBP_ChipAttrListTipItem:InitChipAttrListTipItem(attrValue, descCore, rowCore, EChipAttrType.CoreAttr)
  end
  local subAttrList = {}
  for i, v in ipairs(ChipBagsItemData.Chip.subAttr) do
    table.insert(subAttrList, v)
  end
  table.sort(subAttrList, function(A, B)
    return A.attrID > B.attrID
  end)
  UpdateVisibility(self.CanvasPanelRandomAttr, #subAttrList > 0)
  for i, v in ipairs(subAttrList) do
    local randAttrItem = GetOrCreateItem(self.VerticalBoxRandomAttrList, i, self.WBP_ChipAttrListTipItemRandom:GetClass())
    local result, row = GetRowData(DT.DT_AttributeModifyOp, tostring(v.attrID))
    local desc = ""
    if result then
      desc = row.Desc
      randAttrItem:InitChipAttrListTipItem(v.value, desc, row, EChipAttrType.RandomAttr)
    end
  end
  HideOtherItem(self.VerticalBoxRandomAttrList, #subAttrList + 1)
  UpdateVisibility(self.CanvasPanelSpecialAttr, ChipBagsItemData.Chip.inscription > 0)
  local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if RGLogicCommandDataSubsystem and ChipBagsItemData.Chip.inscription > 0 then
    local inscriptionDesc = GetLuaInscriptionDesc(ChipBagsItemData.Chip.inscription, 1)
    self.RGRichTextBlockSpecialDesc:SetText(inscriptionDesc)
  end
  self.RGStateControllerOperator:ChangeStatus(tostring(ChipBagsItemData.Chip.state))
end
function ChipAttrListTip:Hide()
  UpdateVisibility(self, false)
end
return ChipAttrListTip
