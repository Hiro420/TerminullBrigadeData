local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local rapidjson = require("rapidjson")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RankData = require("UI.View.Rank.RankData")
require("Rouge.UI.Battle.Logic.Logic_Scroll")
require("Rouge.UI.Battle.Logic.Logic_GenericModify")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
local MainPanelLeftSwitchName = "MainPanelLeftSwitch"
local MainPanelRightSwitchName = "MainPanelRightSwitch"
local GRInfoView = Class(ViewBase)
function GRInfoView:BindClickHandler()
end
function GRInfoView:UnBindClickHandler()
end
function GRInfoView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function GRInfoView:OnDestroy()
  self:UnBindClickHandler()
end
function GRInfoView:OnShow(UniqueId, WorldId, GameModeId, Score, bTeam, HeroId, SeasonId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    GRInfoView.PauseGame
  })
  if not IsListeningForInputAction(self, MainPanelLeftSwitchName) then
    ListenForInputAction(MainPanelLeftSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      GRInfoView.ListenForLeftInputAction
    })
  end
  if not IsListeningForInputAction(self, MainPanelRightSwitchName) then
    ListenForInputAction(MainPanelRightSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      GRInfoView.ListenForRightInputAction
    })
  end
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, GRInfoView.PauseGame)
  EventSystem.AddListener(self, EventDef.Rank.OnRequestServerElementDataSuccess, GRInfoView.OnRequestServerElementDataSuccess)
  self.Btn_Rule.OnClicked:Add(self, self.OnBtnRule)
  self.Btn_Model.OnClicked:Add(self, self.OnBtnModel)
  self.RGToggleGroupPlayerInfoTitle.OnCheckStateChanged:Add(self, self.OnToggleCheckStateChanged)
  self.WorldId = WorldId
  self.GameModeId = GameModeId
  self.SeasonId = SeasonId
  self.UniqueId = UniqueId
  self.Score = Score
  self.bTeam = bTeam
  self.HeroId = HeroId
  self.SelRule = true
  self:InitToggleGroup(UniqueId)
  self:RequestServerElementData()
  self:OnBtnRule()
end
function GRInfoView:ListenForLeftInputAction()
  local SelectId = self.RGToggleGroupPlayerInfoTitle.CurSelectId
  local LastSelectId = self.RGToggleGroupPlayerInfoTitle.CurSelectId
  for index, value in ipairs(self.RoleIdTable) do
    if value == tostring(SelectId) then
      SelectId = LastSelectId
    end
    LastSelectId = tonumber(value)
  end
  if SelectId ~= self.RGToggleGroupPlayerInfoTitle.CurSelectId then
    self.RGToggleGroupPlayerInfoTitle:SelectId(SelectId)
  end
end
function GRInfoView:ListenForRightInputAction()
  local SelectId = self.RGToggleGroupPlayerInfoTitle.CurSelectId
  for index, value in ipairs(self.RoleIdTable) do
    if value == tostring(SelectId) and self.RoleIdTable[index + 1] then
      SelectId = tonumber(self.RoleIdTable[index + 1])
      break
    end
  end
  if SelectId ~= self.RGToggleGroupPlayerInfoTitle.CurSelectId then
    self.RGToggleGroupPlayerInfoTitle:SelectId(SelectId)
  end
end
function GRInfoView:OnRequestServerElementDataSuccess(Data)
  self.Data = RankData.ElementData[tostring(self.SelId)]
  self:InitTitle()
  self:UpdateGenericList()
  self:UpdateScrollList()
  self:UpdateScrollSetList()
  local JsonTable = rapidjson.decode(self.Data.playerinfos)
  if JsonTable.hero.puzzles == nil then
    JsonTable.hero.puzzles = {}
  end
  self.Data.gems = JsonTable.gems
  self.WBP_PuzzleSpecifiedBoard:Show(self.Data.heroId, self.Data.puzzleslots, JsonTable.hero.puzzleslotsinfo, self.Data.puzzles, JsonTable.gems)
  self:RefreshEquipAttr()
  UpdateVisibility(self.Pnl_Rule, self.SelRule)
end
function GRInfoView:OnBtnRule()
  UpdateVisibility(self.Pnl_Rule, true)
  UpdateVisibility(self.Pnl_Model, false)
  UpdateVisibility(self.Btn_Rule_Select, true)
  UpdateVisibility(self.Btn_Rule_Normal, false)
  UpdateVisibility(self.Btn_Model_Select, false)
  UpdateVisibility(self.Btn_Model_Normal, true)
  self.SelRule = true
end
function GRInfoView:OnBtnModel()
  UpdateVisibility(self.Pnl_Rule, false)
  UpdateVisibility(self.Pnl_Model, true)
  UpdateVisibility(self.Btn_Model_Select, true)
  UpdateVisibility(self.Btn_Model_Normal, false)
  UpdateVisibility(self.Btn_Rule_Select, false)
  UpdateVisibility(self.Btn_Rule_Normal, true)
  self.SelRule = false
end
function GRInfoView:InitToggleGroup(UniqueId)
  local RoleIdTable = Split(UniqueId, "_")
  self.RoleIdTable = RoleIdTable
  self.RGToggleGroupPlayerInfoTitle:ClearGroup()
  for index, value in ipairs(RoleIdTable) do
    local item = GetOrCreateItem(self.HorizontalBoxPlayerInfoTitle, index, self.WBP_SettlementPlayerInfoTitle_Rank:GetClass())
    if RankData.GetPlayerInfo(value) then
      if RankData.GetPlayerInfo(value).rankInvisible ~= nil and 1 == RankData.GetPlayerInfo(value).rankInvisible and value ~= DataMgr.GetUserId() then
        item:InitRankPlayerInfoTitle(self.InvisibleName)
      else
        item:InitRankPlayerInfoTitle(RankData.GetPlayerName(value))
      end
    end
    self.RGToggleGroupPlayerInfoTitle:AddToGroup(tonumber(value), item)
  end
  HideOtherItem(self.HorizontalBoxPlayerInfoTitle, table.count(RoleIdTable) + 1)
  self.RGToggleGroupPlayerInfoTitle:SelectId(tonumber(RoleIdTable[1]))
  self:OnToggleCheckStateChanged(tonumber(RoleIdTable[1]))
end
function GRInfoView:OnToggleCheckStateChanged(SelId)
  self.SelId = SelId
  self.Data = RankData.ElementData[tostring(SelId)]
  if self.Data == nil then
    return
  end
  local JsonTable = rapidjson.decode(self.Data.playerinfos)
  self:InitTitle()
  self:UpdateGenericList()
  self:UpdateScrollList()
  self:UpdateScrollSetList()
  if nil == JsonTable.hero.puzzles then
    JsonTable.hero.puzzles = {}
  end
  self.Data.gems = JsonTable.gems
  self.WBP_PuzzleSpecifiedBoard:Show(self.Data.heroId, self.Data.puzzleslots, JsonTable.hero.puzzleslotsinfo, self.Data.puzzles, JsonTable.gems)
  self:RefreshEquipAttr()
end
function GRInfoView:InitTitle()
  UpdateVisibility(self.CanvasPanelLeft, table.count(self.Data) > 1)
  UpdateVisibility(self.CanvasPanelRight, table.count(self.Data) > 1)
  local TBWeapon = LuaTableMgr.GetLuaTableByName(TableNames.TBWeapon)
  if TBWeapon[self.Data.weaponId] then
    self.WBP_Item:InitItem(TBWeapon[self.Data.weaponId].SkinID + 10000000)
    local TBWeaponSkin = LuaTableMgr.GetLuaTableByName(TableNames.TBWeaponSkin)
    if TBWeaponSkin[TBWeapon[self.Data.weaponId].SkinID + 10000000] then
      self.Text_WeaponName:SetText(TBWeaponSkin[TBWeapon[self.Data.weaponId].SkinID + 10000000].SkinName)
    end
  end
  local TBHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  local bResult, HerpData = GetRowData(DT.DT_Hero, self.Data.heroId)
  if bResult then
    SetImageBrushBySoftObject(self.HeroIcon, HerpData.RoleIcon)
    self.Txt_HeroName:SetText(TBHeroMonster[self.Data.heroId].Name)
  end
  local TBRankModeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRankMode)
  for key, value in pairs(TBRankModeTable) do
    if value.WorldId == self.WorldId then
      self.RGTextWorld:SetText(value.WorldName)
    end
    if value.ModeId == self.GameModeId then
      self.RGTextModel:SetText(value.ModeName)
    end
  end
  local scoreNumber = tonumber(self.Score)
  local gameHardNumber = scoreNumber >> 44
  local result, row = GetRowData(DT.DT_DifficultyMode, gameHardNumber)
  if result then
    self.RGTextDiffculty:SetText(row.Difficulty)
  else
    self.RGTextDiffculty:SetText(gameHardNumber)
  end
  local seconds = 65535 - (scoreNumber - (gameHardNumber << 44) >> 28)
  self.Text_TotalDamage_Value:SetText(self.Data.totalDamage)
  self.Text_TotalKill_Value:SetText(self.Data.killCount)
  self.RGTextTime:SetText(Format(seconds, "hh:mm:ss"))
  UpdateVisibility(self.Text_Mvp, self.Data.mvp)
end
function GRInfoView:UpdateGenericList()
  for index, value in ipairs(self.WrapBoxGenericModify:GetAllChildren():ToTable()) do
    value:InitBagRoleGenericItem(nil, UE.ERGGenericModifySlot.None)
  end
  local passiveModifyAry = {}
  local activatedModifies = {}
  local slotModifyMap = {}
  for i, v in ipairs(self.Data.genericModifyList) do
    local resultGeneric, rowGeneric = GetRowData(DT.DT_GenericModify, tostring(v.ModifyId))
    if resultGeneric then
      if rowGeneric.Slot == UE.ERGGenericModifySlot.None then
        table.insert(passiveModifyAry, v)
      else
        slotModifyMap[rowGeneric.Slot] = v
      end
    else
      local specificModify = UE.FRGSpecificModify()
      specificModify.ModifyId = v.ModifyId
      table.insert(activatedModifies, specificModify)
    end
  end
  for i, v in ipairs(self.Data.specificModifyList) do
    local specificModify = UE.FRGSpecificModify()
    specificModify.ModifyId = v.ModifyId
    table.insert(activatedModifies, specificModify)
  end
  local index = 1
  for i, v in ipairs(passiveModifyAry) do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitBagRoleGenericItem(v, -1, self.UpdateGenericModifyTipsFunc, self)
    index = index + 1
  end
  for i, v in ipairs(activatedModifies) do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitSpecificModifyItem(v, -1, self.UpdateGenericModifyTipsFunc, self)
    index = index + 1
  end
  for i, v in iterator(self.SlotList) do
    local RGGenericModifyData = slotModifyMap[v]
    local GenericModifyItem = GetOrCreateItem(self.CanvasPanelSlotModifyList, i, self.WBP_BagRoleGenericItem_SettlementSlot:GetClass())
    if RGGenericModifyData then
      GenericModifyItem:InitBagRoleGenericItem(RGGenericModifyData, v, self.UpdateGenericModifyTipsFunc, self)
    else
      GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
    end
  end
end
function GRInfoView:UpdateScrollSetList()
  local scrollSetList = self.Data.attributeModifySet
  for i, v in ipairs(scrollSetList) do
    local item = GetOrCreateItem(self.WrapBoxScrollSetList, i, self.WBP_SettlementScrollSetItem:GetClass())
    item:InitScrollSetItem(v, self.UpdateScrollSetTips, self, i)
  end
  HideOtherItem(self.WrapBoxScrollSetList, #scrollSetList + 1)
end
function GRInfoView:UpdateScrollList()
  for i = 1, Logic_Scroll.MaxScrollNum do
    local v
    local scrollList = self.Data.attributeModifyList
    if scrollList and scrollList[i] then
      v = scrollList[i]
    end
    local item = GetOrCreateItem(self.WrapBoxScrollList, i, self.WBP_ScrollItemSlot_Settlement:GetClass())
    item:UpdateScrollData(v, self.UpdateShowPickupTipsView, self, i)
  end
  HideOtherItem(self.WrapBoxScrollList, Logic_Scroll.MaxScrollNum + 1)
end
function GRInfoView:PauseGame()
  UIMgr:Hide(ViewID.UI_GRInfoView)
end
function GRInfoView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  EventSystem.RemoveListener(EventDef.Rank.OnRequestServerElementDataSuccess, GRInfoView.OnRequestServerElementDataSuccess, self)
  StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, GRInfoView.PauseGame)
end
function GRInfoView:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTips(Data.ModifyId, false, Slot, false, Data)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    UpdateVisibility(self.WBP_GenericModifyBagTips, true)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end
function GRInfoView:UpdateShowPickupTipsView(bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  if ScrollId and ScrollId > 0 then
    self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ScrollId, ScrollTipsOpenType, TargetItem, bIsNeedInit)
    UpdateVisibility(self.WBP_ScrollPickUpTipsView, true)
    self.WBP_ScrollPickUpTipsView:Show(true)
  else
    UpdateVisibility(self.WBP_ScrollPickUpTipsView, false)
  end
  UpdateVisibility(self.WBP_ScrollPickUpTipsView.TipsPanel, false)
end
function GRInfoView:UpdateScrollSetTips(bIsShow, ActivatedSetData, ScrollSetItem)
  UpdateVisibility(self.WBP_ScrollSetTips, bIsShow)
  if bIsShow then
    self.WBP_ScrollSetTips:InitScrollSetTips(ActivatedSetData)
    local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
    if TipsCanvasSlot then
      local GeometryScrollSetItem = ScrollSetItem:GetCachedGeometry()
      local GeometryCanvasPanelScroll = self.CanvasPanelScroll:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelScroll, GeometryScrollSetItem)
      TipsCanvasSlot:SetPosition(UE.FVector2D(TipsCanvasSlot:GetPosition().X, Pos.Y))
    end
  end
end
function GRInfoView:RequestServerElementData()
  local GameMode, GameWorld, HeroId, UniqueID = self.GameModeId, self.WorldId, self.HeroId, self.UniqueId
  RankData.RequestServerElementData(self.SeasonId, GameMode, GameWorld, HeroId, UniqueID)
end
function GRInfoView:RefreshEquipAttr()
  local AttrList = {}
  for key, PuzzleInfo in pairs(self.Data.puzzles) do
    local DetailInfo = PuzzleInfo.detail
    local Result, PuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, PuzzleInfo.Base.resourceid)
    for i, SingleCoreAttributeInfo in ipairs(PuzzleResRowInfo.MainAttr) do
      if not AttrList[SingleCoreAttributeInfo.key] then
        AttrList[SingleCoreAttributeInfo.key] = SingleCoreAttributeInfo.value
      else
        AttrList[SingleCoreAttributeInfo.key] = AttrList[SingleCoreAttributeInfo.key] + SingleCoreAttributeInfo.value
      end
    end
    for AttrId, AttrValue in pairs(DetailInfo.mainattrgrowth) do
      if not AttrList[AttrId] then
        AttrList[AttrId] = AttrValue
      else
        AttrList[AttrId] = AttrList[AttrId] + AttrValue
      end
    end
    for AttrId, AttrValue in pairs(DetailInfo.subattrgrowth) do
      if not AttrList[AttrId] then
        AttrList[AttrId] = AttrValue
      else
        AttrList[AttrId] = AttrList[AttrId] + AttrValue
      end
    end
    if DetailInfo.SubAttrInitV2 == nil then
      DetailInfo.SubAttrInitV2 = {}
    end
    for i, AttrInfo in pairs(DetailInfo.SubAttrInitV2) do
      local AttrId = AttrInfo.AttrID
      local AttrValue = AttrInfo.value or AttrInfo.Value
      if not AttrList[AttrId] then
        AttrList[AttrId] = AttrValue
      else
        AttrList[AttrId] = AttrList[AttrId] + AttrValue
      end
    end
    local GemSlotInfo = DetailInfo.gemslotinfo
    for SlotIndex, GemId in pairs(GemSlotInfo) do
      local GemPackageInfo = self.Data.gems[GemId]
      if GemPackageInfo then
        local MutationInfo = GemPackageInfo.mutation and GemPackageInfo.mutationAttr[1]
        local MainAttrValueList = {}
        local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, GemPackageInfo.resourceID)
        local Result, GemResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, GemPackageInfo.resourceID)
        for index, SingleAttrInfo in ipairs(GemResRowInfo.Attr) do
          MainAttrValueList[SingleAttrInfo.key] = SingleAttrInfo.value
        end
        local MainAttrGrowthValueList = {}
        local Result, CoreAttrLvUpRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGemLevelUpAttr, ResourceRowInfo.Rare)
        for i, SingleAttrInfo in ipairs(CoreAttrLvUpRowInfo.LevelUpAttr) do
          MainAttrGrowthValueList[SingleAttrInfo.key] = SingleAttrInfo.value
        end
        for i, SingleCoreAttributeId in ipairs(GemPackageInfo.mainAttrIDs) do
          local Value = MainAttrValueList[SingleCoreAttributeId] + MainAttrGrowthValueList[SingleCoreAttributeId] * GemPackageInfo.level or 0
          local MutationType
          if MutationInfo and MutationInfo.attrID == SingleCoreAttributeId and MutationInfo.mutationType == EMutationType.NegaMutation then
            Value = Value * MutationInfo.mutationValue
            MutationType = MutationInfo.mutationType
          end
          AttrList[SingleCoreAttributeId] = AttrList[SingleCoreAttributeId] and AttrList[SingleCoreAttributeId] + Value or Value
        end
        if MutationInfo and MutationInfo.mutationType == EMutationType.PosMutation then
          if not AttrList[MutationInfo.attrID] then
            AttrList[MutationInfo.attrID] = MutationInfo.mutationValue
          else
            AttrList[MutationInfo.attrID] = AttrList[MutationInfo.attrID] + MutationInfo.mutationValue
          end
        end
      end
    end
  end
  local Index = 1
  for AttrIdStr, AttrValue in pairs(AttrList) do
    local Item = GetOrCreateItem(self.ScrollBoxAttrRoot, Index, self.WBP_PuzzleViewAttrItem:StaticClass())
    Item:Show(AttrIdStr, AttrValue)
    Index = Index + 1
  end
  HideOtherItem(self.ScrollBoxAttrRoot, Index, true)
end
return GRInfoView
