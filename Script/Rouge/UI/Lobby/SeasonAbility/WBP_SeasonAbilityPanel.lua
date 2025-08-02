local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
local SeasonAbilityModule = require("Modules.SeasonAbility.SeasonAbilityModule")
local WBP_SeasonAbilityPanel = Class(ViewBase)

function WBP_SeasonAbilityPanel:BindClickHandler()
  self.Btn_ChangeHero.OnMainButtonClicked:Add(self, self.BindOnChangeHeroButtonClicked)
  self.Btn_SchemeList.OnClicked:Add(self, self.BindOnSchemeListButtonClicked)
  self.Btn_ChangeSchemeName.OnClicked:Add(self, self.BindOnChangeSchemeNameButtonClicked)
  self.Btn_Save.OnMainButtonClicked:Add(self, self.BindOnSaveButtonClicked)
  self.Btn_SpecialAbility.OnClicked:Add(self, self.BindOnSpecialAbilityButtonClicked)
  self.Btn_ExchangeAbilityPoint.OnClicked:Add(self, self.BindOnExchangeAbilityPointButtonClicked)
  self.Btn_Reset.OnClicked:Add(self, self.BindOnResetButtonClicked)
end

function WBP_SeasonAbilityPanel:UnBindClickHandler()
  self.Btn_ChangeHero.OnMainButtonClicked:Remove(self, self.BindOnChangeHeroButtonClicked)
  self.Btn_SchemeList.OnClicked:Remove(self, self.BindOnSchemeListButtonClicked)
  self.Btn_ChangeSchemeName.OnClicked:Remove(self, self.BindOnChangeSchemeNameButtonClicked)
  self.Btn_Save.OnMainButtonClicked:Remove(self, self.BindOnSaveButtonClicked)
  self.Btn_SpecialAbility.OnClicked:Remove(self, self.BindOnSpecialAbilityButtonClicked)
  self.Btn_ExchangeAbilityPoint.OnClicked:Remove(self, self.BindOnExchangeAbilityPointButtonClicked)
  self.Btn_Reset.OnClicked:Remove(self, self.BindOnResetButtonClicked)
end

function WBP_SeasonAbilityPanel:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("SeasonAbilityViewModel")
  self:BindClickHandler()
end

function WBP_SeasonAbilityPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_SeasonAbilityPanel:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local ItemStyleList = self.ItemStyleList:ToTable()
  SeasonAbilityModule:InitItemStyle(ItemStyleList)
  SeasonAbilityModule:InitLineColorList(self.ItemLineColorList:ToTable())
  SeasonAbilityModule:InitAnimLineColorList(self.ItemAnimLineColorList:ToTable())
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnHeroesSeasonAbilityPointNumUpdated, self.BindOnHeroedSeasonAbilityPointNumUpdated)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated, self.BindOnSeasonAbilityInfoUpdated)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnSpecialAbilityInfoUpdated, self.BindOnSpecialAbilityInfoUpdated)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnUpdateSeasonAbilityTipVis, self.BindOnUpdateSeasonAbilityTipVis)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnUpdateSpecialAbilityPanelVis, self.BindOnUpdateSpecialAbilityPanelVis)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnChangeEquipScheme, self.BindOnChangeEquipScheme)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnAddSpecialAbilityPoint, self.BindOnAddSpecialAbilityPoint)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnAddAbilityPoint, self.BindOnAddAbilityPoint)
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnResetSeasonAbilitySuccess, self.BindOnResetSeasonAbilitySuccess)
  SeasonAbilityHandler:RequestGetSpecialAbilityInfoToServer()
  self:InitHeroList()
  self:SelectHeroId(DataMgr.GetMyHeroInfo().equipHero)
  self:InitAbilityPointNumInfo()
  self:RefreshSpecialAbilityInfo()
  self:SetExpandSchemeListStatus(false)
  SetLobbyPanelCurrencyList(true, {99003})
  self:PlayAnimation(self.Ani_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

function WBP_SeasonAbilityPanel:InitAbilityPointNumInfo(...)
  local MaxAbilityPointNum = SeasonAbilityData:GetMaxExchangeAbilityPointNum()
  self.Txt_MaxAbilityPointTip:SetText(UE.FTextFormat(self.MaxAbilityPointTipText, MaxAbilityPointNum))
end

function WBP_SeasonAbilityPanel:RefreshAbilityPointNumInfo(...)
  local CurRemainAbilityPointNum = SeasonAbilityData:GetCurRemainAbilityPointNum(self:GetCurShowHeroId())
  self.Txt_UseableAbilityPointNum:SetText(CurRemainAbilityPointNum)
  local TotalExchangeAbilityPointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(self:GetCurShowHeroId())
  self.Txt_TotalExchangeAbilityPointNum:SetText(TotalExchangeAbilityPointNum)
  local Color
  if CurRemainAbilityPointNum > 0 then
    Color = self.UsePointNumTextColor
  else
    Color = self.UnUsePointNumTextColor
  end
  self.Txt_UseableAbilityPointNum:SetColorAndOpacity(Color)
  self.Txt_UseableAbilityPointNumInterval:SetColorAndOpacity(Color)
  self.Txt_TotalExchangeAbilityPointNum:SetColorAndOpacity(Color)
end

function WBP_SeasonAbilityPanel:RefreshSpecialAbilityInfo(...)
  self.Txt_CurSpecialAbilityPoint:SetText(SeasonAbilityData:GetSpecialAbilityCurrentMaxPointNum())
  local SpecialAbilityTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSpecialAbility)
  local LastRowInfo = SpecialAbilityTable[#SpecialAbilityTable]
  self.Txt_MaxSpecialAbilityPoint:SetText(LastRowInfo.SpecialAbilityPointNum)
end

function WBP_SeasonAbilityPanel:SelectHeroId(HeroId)
  self.CurSelectHeroId = HeroId
  self.ViewModel:SetCurHeroId(HeroId)
  SeasonAbilityData:ResetPreAbilityInfo()
  local SeasonAbilityInfo = SeasonAbilityData:GetSeasonAbilityInfo(self:GetCurShowHeroId())
  if not SeasonAbilityInfo then
    SeasonAbilityHandler:RequestGetSeasonAbilityInfoToServer(self:GetCurShowHeroId())
  end
  self:RefreshHeroInfo()
end

function WBP_SeasonAbilityPanel:RefreshHeroInfo()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, self:GetCurShowHeroId())
  if Result then
    self.Txt_HeroName:SetText(RowInfo.Name)
  end
  self:PlayAnimation(self.Ani_role_switch, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self:InitItemPanel()
  self:RefreshAbilityPointNumInfo()
  self:RefreshSchemeInfo()
  self:UpdateSaveButtonStatus()
end

function WBP_SeasonAbilityPanel:RefreshSchemeInfo(...)
  local SeasonAbilityInfo = SeasonAbilityData:GetSeasonAbilityInfo(self:GetCurShowHeroId())
  if SeasonAbilityInfo and SeasonAbilityInfo.seasonAbilities then
    local CurEquipSchemeInfo = SeasonAbilityData:GetSeasonAbilityInfoBySchemeId(self:GetCurShowHeroId(), SeasonAbilityInfo.equipedSchemeID)
    local CurEquipSchemeName = CurEquipSchemeInfo and CurEquipSchemeInfo.schemeName or ""
    if UE.UKismetStringLibrary.IsEmpty(CurEquipSchemeName) then
      local SchemeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSeasonAbilityPresentScheme)
      for i, SingleSchemeRowInfo in ipairs(SchemeTable) do
        if SingleSchemeRowInfo.PresentSchemeID == SeasonAbilityInfo.equipedSchemeID then
          CurEquipSchemeName = SingleSchemeRowInfo.Name
          break
        end
      end
    end
    self.Txt_SchemeName:SetText(CurEquipSchemeName)
  end
  self:InitSchemeList()
end

function WBP_SeasonAbilityPanel:InitSchemeList(...)
  local SchemeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSeasonAbilityPresentScheme)
  local Index = 1
  for i, SingleSchemeInfo in ipairs(SchemeTable) do
    local Item = GetOrCreateItem(self.ScrollBox_Scheme, Index, self.SchemeItemTemplate:StaticClass())
    Item:Show(SingleSchemeInfo.PresentSchemeID, self:GetCurShowHeroId())
    Index = Index + 1
  end
  HideOtherItem(self.ScrollBox_Scheme, Index)
end

function WBP_SeasonAbilityPanel:InitItemPanel()
  local CurHeroId = self.ViewModel:GetCurHeroId()
  local TargetRowInfo = self.ViewModel:GetHeroSeasonAbilityRowInfo(CurHeroId)
  if not TargetRowInfo then
    UpdateVisibility(self.SeasonAbilityItemPanel, false)
    return
  end
  SetImageBrushByPath(self.URGImage_Role, TargetRowInfo.RoleBG)
  UpdateVisibility(self.SeasonAbilityItemPanel, true)
  local AbilityIdList = {}
  for i, SingleAbilityId in ipairs(TargetRowInfo.TalentGroupIDS) do
    local SeasonAbilityRowInfo = SeasonAbilityData:GetAbilityTableRow(SingleAbilityId)
    if SeasonAbilityRowInfo and SeasonAbilityRowInfo[1] then
      local TargetTypeAbilityIdList = AbilityIdList[SeasonAbilityRowInfo[1].Type]
      if not TargetTypeAbilityIdList then
        TargetTypeAbilityIdList = {}
        AbilityIdList[SeasonAbilityRowInfo[1].Type] = TargetTypeAbilityIdList
      end
      table.insert(TargetTypeAbilityIdList, SingleAbilityId)
    end
  end
  self:InitAbilityItemId(self.CanvasPanel_WeaponItemPanel, self.CanvasPanel_WeaponLinePanel, TableEnums.ENUMAbilityType.Weapon, AbilityIdList)
  self:InitAbilityItemId(self.CanvasPanel_SkillItemPanel, self.CanvasPanel_SkillLinePanel, TableEnums.ENUMAbilityType.Skill, AbilityIdList)
  self:InitAbilityItemId(self.CanvasPanel_SurvivalItemPanel, self.CanvasPanel_SurvivalLinePanel, TableEnums.ENUMAbilityType.Survival, AbilityIdList)
end

function WBP_SeasonAbilityPanel:InitAbilityItemId(ItemPanel, LinePanel, Type, AbilityIdList)
  local AllChildren = ItemPanel:GetAllChildren()
  local TargetTypeAbilityIdList = AbilityIdList[Type] and AbilityIdList[Type] or {}
  for k, SingleItem in pairs(AllChildren) do
    local TargetAbilityId = TargetTypeAbilityIdList[SingleItem.Index + 1]
    TargetAbilityId = TargetAbilityId or 0
    SingleItem:Show(TargetAbilityId, Type, self:GetCurShowHeroId())
  end
  if LinePanel then
    local AllLineChildren = LinePanel:GetAllChildren()
    for k, SingleItem in pairs(AllLineChildren) do
      local TargetAbilityId = TargetTypeAbilityIdList[SingleItem.Index + 1]
      TargetAbilityId = TargetAbilityId or 0
      SingleItem:Show(TargetAbilityId, Type, self:GetCurShowHeroId())
    end
  end
end

function WBP_SeasonAbilityPanel:InitHeroList()
  local AllCharacterList = LogicRole.GetAllCanSelectCharacterList()
  table.sort(AllCharacterList, function(A, B)
    return A < B
  end)
  self.HeroToIdxOrderMap = OrderedMap.New()
  for i, v in ipairs(AllCharacterList) do
    self.HeroToIdxOrderMap:Add(v, i)
  end
end

function WBP_SeasonAbilityPanel:UpdateSaveButtonStatus(...)
  local PreAbilityList = SeasonAbilityData:GetPreAbilityLevelList()
  if table.count(PreAbilityList) > 0 then
    self.Btn_Save:SetStyleByBottomStyleRowName("Main")
    self:PlayAnimation(self.Ani_Btn_click, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  else
    self.Btn_Save:SetStyleByBottomStyleRowName("SeasonAbility_Save_Disabled")
  end
  UpdateVisibility(self.NS_FX_UI_Btn_loop, table.count(PreAbilityList) > 0)
end

function WBP_SeasonAbilityPanel:BindOnChangeHeroButtonClicked(...)
  UIMgr:Show(ViewID.UI_ViewSetChangeHeroTip, false, self, self.HeroToIdxOrderMap, nil, true)
end

function WBP_SeasonAbilityPanel:BindOnSchemeListButtonClicked(...)
  self:SetExpandSchemeListStatus(not self.IsExpand)
end

function WBP_SeasonAbilityPanel:SetExpandSchemeListStatus(IsExpand)
  self.IsExpand = IsExpand
  UpdateVisibility(self.Overlay_SchemeListPanel, self.IsExpand)
  UpdateVisibility(self.Panel_SchemeOutline, not self.IsExpand)
  UpdateVisibility(self.Panel_SchemeSelect, self.IsExpand)
  if self.IsExpand then
    self.Img_Arrow:SetRenderTransformAngle(180.0)
    self.Img_Arrow:SetColorAndOpacity(self.ExpandSchemeArrowColor)
  else
    self.Img_Arrow:SetRenderTransformAngle(0.0)
    self.Img_Arrow:SetColorAndOpacity(self.NotExpandSchemeArrowColor)
  end
end

function WBP_SeasonAbilityPanel:BindOnChangeSchemeNameButtonClicked(...)
  local CurEquipSchemeId = SeasonAbilityData:GetCurEquipSchemeId(self:GetCurShowHeroId())
  if 0 == CurEquipSchemeId then
    return
  end
  UIMgr:Show(ViewID.UI_ChangeSchemeNamePanel, false, self:GetCurShowHeroId(), CurEquipSchemeId)
end

function WBP_SeasonAbilityPanel:BindOnSaveButtonClicked(...)
  local PreAbilityList = SeasonAbilityData:GetPreAbilityLevelList()
  if 0 == table.count(PreAbilityList) then
    return
  end
  local PreNeedExchangePointNum = SeasonAbilityData:GetPreNeedExchangeAbilityPointNum()
  if PreNeedExchangePointNum > 0 and not SeasonAbilityModule:GetIsAutoExchangeAbilityPoint() then
    UIMgr:Show(ViewID.UI_AutoExchangeAbilityPointPanel, false, self:GetCurShowHeroId(), PreNeedExchangePointNum)
    return
  end
  local UpgradeFunction = function(self)
    local CurEquipSchemeId = SeasonAbilityData:GetCurEquipSchemeId(self:GetCurShowHeroId())
    SeasonAbilityHandler:RequestUpgradeSeasonAbilityToServer(self:GetCurShowHeroId(), CurEquipSchemeId, PreAbilityList)
  end
  if PreNeedExchangePointNum > 0 then
    SeasonAbilityHandler:RequestExchangeAbilityPointToServer(self:GetCurShowHeroId(), PreNeedExchangePointNum, {self, UpgradeFunction})
  else
    UpgradeFunction(self)
  end
  self:PlayAnimation(self.Ani_Btn_click, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

function WBP_SeasonAbilityPanel:BindOnSpecialAbilityButtonClicked()
  if self.IsShowSpecialAbilityPanel == nil then
    self.IsShowSpecialAbilityPanel = false
  end
  self.IsShowSpecialAbilityPanel = not self.IsShowSpecialAbilityPanel
  UpdateVisibility(self.RGAutoLoadPanelSpecialAbility, self.IsShowSpecialAbilityPanel)
  if self.RGAutoLoadPanelSpecialAbility.ChildWidget then
    if self.IsShowSpecialAbilityPanel then
      self.RGAutoLoadPanelSpecialAbility.ChildWidget:OnShow()
    else
      self.RGAutoLoadPanelSpecialAbility.ChildWidget:OnHide()
    end
  end
end

function WBP_SeasonAbilityPanel:BindOnExchangeAbilityPointButtonClicked(...)
  UIMgr:Show(ViewID.UI_ExchangeAbilityPointPanel, false, self:GetCurShowHeroId())
end

function WBP_SeasonAbilityPanel:BindOnResetButtonClicked(...)
  local MaxExchangePointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(self:GetCurShowHeroId())
  if MaxExchangePointNum > 0 then
    UIMgr:Show(ViewID.UI_ResetSeasonAbilityPanel, false, self:GetCurShowHeroId())
  end
end

function WBP_SeasonAbilityPanel:BindOnHeroedSeasonAbilityPointNumUpdated(...)
  self:RefreshAbilityPointNumInfo()
end

function WBP_SeasonAbilityPanel:BindOnSeasonAbilityInfoUpdated(...)
  self:RefreshAbilityPointNumInfo()
  self:RefreshSchemeInfo()
  self:UpdateSaveButtonStatus()
  if self.WBP_SeasonAbilityTip:IsVisible() then
    self.WBP_SeasonAbilityTip:Show(self:GetCurShowHeroId(), self.CurShowTipAbilityId)
  end
end

function WBP_SeasonAbilityPanel:BindOnSpecialAbilityInfoUpdated(...)
  self:RefreshSpecialAbilityInfo()
end

function WBP_SeasonAbilityPanel:BindOnUpdateSeasonAbilityTipVis(IsShow, AbilityId, Type)
  self.CurShowTipAbilityId = AbilityId
  if IsShow then
    self.WBP_SeasonAbilityTip:Show(self:GetCurShowHeroId(), AbilityId)
    local TargetPanel
    if Type == TableEnums.ENUMAbilityType.Weapon then
      TargetPanel = self.CanvasPanel_WeaponItemPanel
    elseif Type == TableEnums.ENUMAbilityType.Skill then
      TargetPanel = self.CanvasPanel_SkillItemPanel
    else
      TargetPanel = self.CanvasPanel_SurvivalItemPanel
    end
    local CachedGeometry = TargetPanel:GetCachedGeometry()
    local GeometryCanvasPanelTips = self.CanvasPanel_Tips:GetCachedGeometry()
    local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelTips, CachedGeometry)
    local PanelSize = UE.USlateBlueprintLibrary.GetLocalSize(CachedGeometry)
    Pos.X = Pos.X + PanelSize.X
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SeasonAbilityTip)
    Slot:SetPosition(Pos)
  else
    self.WBP_SeasonAbilityTip:Hide()
  end
end

function WBP_SeasonAbilityPanel:BindOnUpdateSpecialAbilityPanelVis(IsShow)
  if not IsShow then
    self:BindOnSpecialAbilityButtonClicked()
  end
end

function WBP_SeasonAbilityPanel:BindOnChangeEquipScheme()
  self:PlayAnimation(self.Ani_panel_switch, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

function WBP_SeasonAbilityPanel:BindOnAddSpecialAbilityPoint(PointNum)
  if PointNum > 0 then
    self.Txt_AddSpecialAbilityPoint_Anim:SetText(string.format("+%d", PointNum))
    self:PlayAnimation(self.Ani_add_SpecialAbility, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  end
end

function WBP_SeasonAbilityPanel:BindOnAddAbilityPoint(PointNum)
  self.Txt_ExchangeAbilityPoint_Anim:SetText(string.format("+%d", PointNum))
  self:PlayAnimation(self.Ani_invert_points, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

function WBP_SeasonAbilityPanel:BindOnResetSeasonAbilitySuccess(...)
  local TargetCurrencyItem = self.WBP_LobbyCurrencyList:GetCurrencyItemByCurrencyId(self.WBP_LobbyCurrencyList.CurrencyIDList[1])
  if TargetCurrencyItem then
    TargetCurrencyItem:PlayAddMoneyAnim()
  end
end

function WBP_SeasonAbilityPanel:PreChangeHero(Step)
  local step = Step or 1
  local curSelectId = self.ViewModel:GetCurHeroId()
  local idx = self.HeroToIdxOrderMap[curSelectId]
  idx = idx - step
  if idx <= 0 then
    idx = #self.HeroToIdxOrderMap + idx
  end
  local heroId = self.HeroToIdxOrderMap:GetKeyByIdx(idx)
  if heroId then
    self:SelectHeroId(heroId)
  end
end

function WBP_SeasonAbilityPanel:NextChangeHero(Step)
  local step = Step or 1
  local curSelectId = self.ViewModel:GetCurHeroId()
  local idx = self.HeroToIdxOrderMap[curSelectId]
  idx = idx + step
  if idx > #self.HeroToIdxOrderMap then
    idx = idx - #self.HeroToIdxOrderMap
  end
  local heroId = self.HeroToIdxOrderMap:GetKeyByIdx(idx)
  if heroId then
    self:SelectHeroId(heroId)
  end
end

function WBP_SeasonAbilityPanel:GetCurShowHeroId(...)
  return self.CurSelectHeroId
end

function WBP_SeasonAbilityPanel:HideItemPanel(ItemPanel, LinePanel)
  local AllChildren = ItemPanel:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  if LinePanel then
    local AllLineChildren = LinePanel:GetAllChildren()
    for k, SingleLineItem in pairs(AllLineChildren) do
      SingleLineItem:Hide()
    end
  end
end

function WBP_SeasonAbilityPanel:OnPreHide(...)
  SeasonAbilityData:ResetPreAbilityInfo()
  if UIMgr:IsShow(ViewID.UI_ViewSetChangeHeroTip) then
    UIMgr:Hide(ViewID.UI_ViewSetChangeHeroTip)
  end
  self:HideItemPanel(self.CanvasPanel_WeaponItemPanel, self.CanvasPanel_WeaponLinePanel)
  self:HideItemPanel(self.CanvasPanel_SkillItemPanel, self.CanvasPanel_SkillLinePanel)
  self:HideItemPanel(self.CanvasPanel_SurvivalItemPanel, self.CanvasPanel_SurvivalLinePanel)
  self.WBP_SeasonAbilityTip:Hide()
  self:StopAllAnimations()
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnHeroesSeasonAbilityPointNumUpdated, self.BindOnHeroedSeasonAbilityPointNumUpdated, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated, self.BindOnSeasonAbilityInfoUpdated, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnSpecialAbilityInfoUpdated, self.BindOnSpecialAbilityInfoUpdated, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnUpdateSeasonAbilityTipVis, self.BindOnUpdateSeasonAbilityTipVis, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnUpdateSpecialAbilityPanelVis, self.BindOnUpdateSpecialAbilityPanelVis, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnChangeEquipScheme, self.BindOnChangeEquipScheme, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnAddSpecialAbilityPoint, self.BindOnAddSpecialAbilityPoint, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnAddAbilityPoint, self.BindOnAddAbilityPoint, self)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnResetSeasonAbilitySuccess, self.BindOnResetSeasonAbilitySuccess, self)
end

function WBP_SeasonAbilityPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  SetLobbyPanelCurrencyList(false)
end

function WBP_SeasonAbilityPanel:Destruct(...)
  self:OnPreHide()
end

return WBP_SeasonAbilityPanel
