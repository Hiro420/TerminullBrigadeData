local WBP_TotalAttrTips_C = UnLua.Class()
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local OpenSettingsKeyName = "OpenSettings"
local TxtWeaponAttrTitle = NSLOCTEXT("WBP_TotalAttrTips_C", "TxtWeaponAttrTitle", "\230\173\166\229\153\168\229\177\158\230\128\167")
local TxtBasicAttrTitle = NSLOCTEXT("WBP_TotalAttrTips_C", "TxtBasicAttrTitle", "\229\159\186\231\161\128\229\177\158\230\128\167")
local TxtDetailAttrTitle = NSLOCTEXT("WBP_TotalAttrTips_C", "TxtDetailAttrTitle", "\232\191\155\233\152\182\229\177\158\230\128\167")
local TxtModifyAttrTitle = NSLOCTEXT("WBP_TotalAttrTips_C", "TxtModifyAttrTitle", "\230\157\131\233\153\144\229\177\158\230\128\167")
function WBP_TotalAttrTips_C:Construct()
  self.BP_ButtonHideTotalAttrTips.OnClicked:Add(self, self.Hide)
  self.BP_ButtonCloseAttrTips.OnClicked:Add(self, self.Hide)
  EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, self.BindOnChangeRoleItemClicked)
end
function WBP_TotalAttrTips_C:BindOnChangeRoleItemClicked(HeroId)
  if self:IsVisible() then
    UpdateVisibility(self, false)
  end
end
function WBP_TotalAttrTips_C:Show(AttrNameList, WeaponResId, ModifyAttrList, ParentView)
  UpdateVisibility(self, true)
  self.ParentView = ParentView
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      if self then
        self.WBP_InteractTipWidget:SetFocus()
      end
    end
  })
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.Hide)
  self:PushInputAction()
  local weaponResId = tonumber(WeaponResId) or -1
  local Index = 1
  local ItemIndex = 1
  local filterChildClsToList = {}
  local titleIdx = 1
  local AllMainAttributeList = UE.URGBlueprintLibrary.GetOutsideWeaponAttributeList(self, false, weaponResId, {})
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
  local attrTitleItem = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, titleIdx, self.WBP_AttrTitleItem:GetClass(), filterChildClsToList)
  attrTitleItem.Txt_AttrTitle:SetText(TxtWeaponAttrTitle())
  self:SetTitlePadding(titleIdx, attrTitleItem)
  titleIdx = titleIdx + 1
  for i, SingleAttributeConfig in ipairs(AllMainAttributeListTable) do
    local AttributeName = UE.URGBlueprintLibrary.GetAttributeName(SingleAttributeConfig)
    local AttributeFullName = UE.URGBlueprintLibrary.GetAttributeFullName(SingleAttributeConfig)
    SingleAttributeConfig.Value = LogicOutsideWeapon.GetWeaponAttributeValue(AttributeName, SingleAttributeConfig, AllMainAttributeListTable, true)
    local Result, SingleRowData = GetRowData(DT.DT_EquipAttribute, AttributeFullName)
    if Result and (SingleRowData.DisplayInUI == UE.EAttributeDisplayPos.Detail or SingleRowData.DisplayInUI == UE.EAttributeDisplayPos.Main) then
      local Item = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass(), filterChildClsToList)
      local weaponAttrValue = UE.URGBlueprintLibrary.GetAttributeDisplayText(SingleAttributeConfig.Value, SingleRowData.AttributeDisplayType, "", SingleRowData.DisplayValueRatioInUI)
      Item:InitAttrItemByWeapon(SingleRowData, weaponAttrValue, SingleRowData.DisplayUnitInUI)
      Item:PlayShowAni(Index)
      Item:InitAttrItemBgByIndex(ItemIndex)
      Index = Index + 1
      ItemIndex = ItemIndex + 1
    end
  end
  local attrTitleItem = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, titleIdx, self.WBP_AttrTitleItem:GetClass(), filterChildClsToList)
  attrTitleItem.Txt_AttrTitle:SetText(TxtBasicAttrTitle())
  self:SetTitlePadding(titleIdx, attrTitleItem)
  titleIdx = titleIdx + 1
  ItemIndex = 1
  for i, v in ipairs(AttrNameList) do
    local Result, RowData = GetRowData(DT.DT_HeroBasicAttribute, v)
    if Result and RowData.DisplayInUI == UE.EAttributeDisplayPos.Main and RowData.bShowInBattle then
      local Item = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass(), filterChildClsToList)
      Item:InitAttrItem(RowData, v)
      Item:InitAttrItemBgByIndex(ItemIndex)
      Item:PlayShowAni(Index)
      Index = Index + 1
      ItemIndex = ItemIndex + 1
    end
  end
  local attrTitleItem = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, titleIdx, self.WBP_AttrTitleItem:GetClass(), filterChildClsToList)
  attrTitleItem.Txt_AttrTitle:SetText(TxtDetailAttrTitle())
  self:SetTitlePadding(titleIdx, attrTitleItem)
  titleIdx = titleIdx + 1
  ItemIndex = 1
  for i, v in ipairs(AttrNameList) do
    local Result, RowData = GetRowData(DT.DT_HeroBasicAttribute, v)
    if Result and RowData.DisplayInUI == UE.EAttributeDisplayPos.Detail and RowData.bShowInBattle then
      local Item = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass(), filterChildClsToList)
      Item:InitAttrItem(RowData, v)
      Item:InitAttrItemBgByIndex(ItemIndex)
      Item:PlayShowAni(Index)
      Index = Index + 1
      ItemIndex = ItemIndex + 1
    end
  end
  local ModifyAttrDataList = {}
  for i, v in ipairs(ModifyAttrList) do
    local resultHeroModifyAttr, rowHeroModifyAttr = GetRowData(DT.DT_HeroModifyAttribute, v)
    if resultHeroModifyAttr then
      local value = 0
      for iModifyId, vModifyId in iterator(rowHeroModifyAttr.GenericModifyIds) do
        local GenericModifyData = LogicGenericModify:GetGenericModifyData(vModifyId)
        local Level = 0
        local bNeedBreak = false
        if GenericModifyData then
          Level = GenericModifyData.Level
        end
        local inscriptionData = GetLuaInscription(vModifyId)
        if Level > 0 and inscriptionData then
          local Ratio = 1
          local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(vModifyId))
          if ResultGenericModify then
            do
              local GroupId = GenericModifyRow.GroupId
              local Slot = GenericModifyRow.Slot
              local HeroId = LogicRole.GetCurUseHeroId()
              local WeaponId = LogicRole:GetCurWeaponId()
              local RowName = string.format("%s_%s_%s_%s", tostring(GroupId), tostring(Slot), tostring(HeroId), tostring(WeaponId))
              local ResultGenericModifyLevelRatio, GenericModifyLevelRatioRow = GetRowData(DT.DT_GenericModifyLevelRatio, RowName)
              if ResultGenericModifyLevelRatio then
                Ratio = GenericModifyLevelRatioRow.FallbackRatio
                for i, v in pairs(GenericModifyLevelRatioRow.RatioDataArray) do
                  if v.Key == rowHeroModifyAttr.ParamName then
                    Ratio = v.Ratio
                    break
                  end
                end
              end
            end
          end
          for iInscriptionData, vInscriptionData in ipairs(inscriptionData.InscriptionDataAry) do
            local result, GenericModifyLevelRow = GetRowData(DT.DT_GenericModifyLevel, vInscriptionData.GenericModifyLevelId)
            if result and vInscriptionData.bIsShowGenericModifyLevelDescInUI then
              if vInscriptionData.ModifyLevelDescShowType == UE.EModifyLevelDesc.FinalValue then
                local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
                value = UE.URGGenericModifyComponent.GetGenericModifyBaseDamageFormActor(Character, vModifyId, Level)
                bNeedBreak = true
                break
              elseif vInscriptionData.ModifyLevelDescShowType == UE.EModifyLevelDesc.Addition then
                for idxLv, vLv in iterator(GenericModifyLevelRow.LevelDataAry) do
                  if vLv.Key == rowHeroModifyAttr.ParamName then
                    value = value + vLv.Level2DataMap:FindRef(Level).Param * Ratio
                    break
                  end
                end
              end
            end
          end
        end
        if bNeedBreak then
          break
        end
      end
      if value > 0 then
        table.insert(ModifyAttrDataList, {Key = v, Value = value})
      end
    end
  end
  if not table.IsEmpty(ModifyAttrDataList) then
    local attrTitleItem = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, titleIdx, self.WBP_AttrTitleItem:GetClass(), filterChildClsToList)
    self:SetTitlePadding(titleIdx, attrTitleItem)
    attrTitleItem.Txt_AttrTitle:SetText(TxtModifyAttrTitle())
    UpdateVisibility(attrTitleItem, true)
    titleIdx = titleIdx + 1
  end
  for i, v in ipairs(ModifyAttrDataList) do
    local result, rowData = GetRowData(DT.DT_HeroModifyAttribute, v.Key)
    if result then
      local Item = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass(), filterChildClsToList)
      Item:InitAttrItemByValue(rowData, v.Value)
      Item:PlayShowAni(Index)
      Item:InitAttrItemBgByIndex(Index)
      Index = Index + 1
    end
  end
  HideOtherItemByClass(self.VerticalBoxAttrRoot, titleIdx, self.WBP_AttrTitleItem:GetClass(), filterChildClsToList)
  HideOtherItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass(), filterChildClsToList)
  self:PlayAnimation(self.FadeIn)
  if not IsListeningForInputAction(self, self.EscKeyName) then
    ListenForInputAction(self.EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
  if not IsListeningForInputAction(self, OpenSettingsKeyName) then
    ListenForInputAction(OpenSettingsKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnOpenSettingsKeyName
    })
  end
end
function WBP_TotalAttrTips_C:LobbyShow(HeroId)
  self.HeroId = HeroId
  self:RefreshLobbyHeroAttribtueInfo()
  UpdateVisibility(self, true, true)
  self:PlayAnimation(self.FadeIn)
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Add(self, self.BindOnEscKeyPressed)
  if not IsListeningForInputAction(self, self.EscKeyName) then
    ListenForInputAction(self.EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
  self:PushInputAction()
  if not IsListeningForInputAction(self, OpenSettingsKeyName) then
    ListenForInputAction(OpenSettingsKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnOpenSettingsKeyName
    })
  end
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_TotalAttrTips_C:BindOnEscKeyPressed()
  self:Hide()
end
function WBP_TotalAttrTips_C:BindOnOpenSettingsKeyName()
  print("WBP_TotalAttrTips_C:BindOnOpenSettingsKeyName not OpenSettings")
end
function WBP_TotalAttrTips_C:RefreshLobbyHeroAttribtueInfo()
  local TargetModifyAttributeList, SpecialAttrTb = LogicRole.GetAttributeListNew(self.HeroId, UE.EAttributeDisplayPos.Detail)
  local realIdx = 1
  local Index = 1
  local titleIdx = 1
  local tbAdvancedAttrList = {}
  local filterChildClsToList = {}
  local attrTitleItem = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, titleIdx, self.WBP_AttrTitleItem:GetClass(), filterChildClsToList)
  attrTitleItem.Txt_AttrTitle:SetText(TxtBasicAttrTitle())
  for idx, SingleModifyAttributeConfig in ipairs(TargetModifyAttributeList) do
    local RowName = SingleModifyAttributeConfig.FullAttrName
    local value = SingleModifyAttributeConfig.Value
    if SpecialAttrTb[realIdx] then
      value = SpecialAttrTb[realIdx].Value
      RowName = SpecialAttrTb[realIdx].RowName
    end
    local resultHeroBasicAttr, rowDataHeroBasicAttr = GetRowData(DT.DT_HeroBasicAttribute, RowName)
    if resultHeroBasicAttr and rowDataHeroBasicAttr.DisplayInUI == UE.EAttributeDisplayPos.Main and rowDataHeroBasicAttr.bShowInLobby then
      local Item = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass(), filterChildClsToList)
      Item:InitLobbyAttrItem(rowDataHeroBasicAttr, value)
      Item:InitAttrItemBgByIndex(Index)
      Index = Index + 1
    elseif resultHeroBasicAttr and rowDataHeroBasicAttr.DisplayInUI == UE.EAttributeDisplayPos.Detail and rowDataHeroBasicAttr.bShowInLobby then
      table.insert(tbAdvancedAttrList, {IndexCfg = idx, Config = SingleModifyAttributeConfig})
    end
    realIdx = realIdx + 1
  end
  HideOtherItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass())
  if #tbAdvancedAttrList > 0 then
    titleIdx = titleIdx + 1
    attrTitleItem = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, titleIdx, self.WBP_AttrTitleItem:GetClass(), filterChildClsToList)
    attrTitleItem.Txt_AttrTitle:SetText(TxtDetailAttrTitle())
  end
  for idx, tbAdvancedAttrValue in ipairs(tbAdvancedAttrList) do
    realIdx = tbAdvancedAttrValue.IndexCfg
    local RowName = tbAdvancedAttrValue.Config.FullAttrName
    local value = tbAdvancedAttrValue.Config.Value
    if SpecialAttrTb[realIdx] then
      value = SpecialAttrTb[realIdx].Value
      RowName = SpecialAttrTb[realIdx].RowName
    end
    local resultHeroBasicAttr, rowDataHeroBasicAttr = GetRowData(DT.DT_HeroBasicAttribute, RowName)
    if resultHeroBasicAttr and rowDataHeroBasicAttr.DisplayInUI == UE.EAttributeDisplayPos.Detail and rowDataHeroBasicAttr.bShowInLobby then
      local Item = GetOrCreateItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass(), filterChildClsToList)
      Item:InitLobbyAttrItem(rowDataHeroBasicAttr, value)
      Item:InitAttrItemBgByIndex(Index)
      Index = Index + 1
    end
  end
  HideOtherItemByClass(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass())
end
function WBP_TotalAttrTips_C:SetTitlePadding(TitleIndex, TitleItem)
  if 1 == TitleIndex then
    return
  end
  local Padding = UE.FMargin()
  Padding.Top = 31
  TitleItem.Slot:SetPadding(Padding)
end
function WBP_TotalAttrTips_C:Hide()
  if UE.RGUtil.IsUObjectValid(self.ParentView) and self.ParentView.BackToParentView then
    self.ParentView:BackToParentView()
  end
  self.ParentView = nil
  UpdateVisibility(self, false)
  if IsListeningForInputAction(self, self.EscKeyName) then
    StopListeningForInputAction(self, self.EscKeyName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, OpenSettingsKeyName) then
    StopListeningForInputAction(self, OpenSettingsKeyName, UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Remove(self, self.BindOnEscKeyPressed)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.Hide)
  if GetCurSceneStatus() == UE.ESceneStatus.ELobby then
    self:SetEnhancedInputActionBlocking(false)
  end
end
function WBP_TotalAttrTips_C:Destruct()
  self:Hide()
  self.BP_ButtonHideTotalAttrTips.OnClicked:Remove(self, self.Hide)
  self.BP_ButtonCloseAttrTips.OnClicked:Remove(self, self.Hide)
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, self.BindOnChangeRoleItemClicked, self)
end
return WBP_TotalAttrTips_C
