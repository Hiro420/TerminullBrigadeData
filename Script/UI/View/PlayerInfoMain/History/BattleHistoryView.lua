local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local EscName = "PauseGame"
local DetailsCommonlyUsedWeaponDesc = NSLOCTEXT("BattleHistoryView", "CommonlyUsedWeapon", "\229\184\184\231\148\168\230\173\166\229\153\168")
local DetailsCommonlyUsedHeroDesc = NSLOCTEXT("BattleHistoryView", "CommonlyUsedHero", "\229\184\184\231\148\168\232\139\177\233\155\132")
local AllHeroInfoTxt = NSLOCTEXT("BattleHistoryView", "AllHeroInfoTxt", "\229\133\168\233\131\168")
local BattleHistoryView = Class(ViewBase)
local TableIDList = {}
function BattleHistoryView:OnBindUIInput()
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.OnSelectPrevHero)
  self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.OnSelectNextHero)
end
function BattleHistoryView:OnUnBindUIInput()
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.OnSelectPrevHero)
  self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.OnSelectNextHero)
end
function BattleHistoryView:BindClickHandler()
  self.RGToggleGroupHistoryRole.OnCheckStateChanged:Add(self, self.OnCheckStateChanged)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.ListenForEscInputAction)
end
function BattleHistoryView:UnBindClickHandler()
  self.RGToggleGroupHistoryRole.OnCheckStateChanged:Remove(self, self.OnCheckStateChanged)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.ListenForEscInputAction)
end
function BattleHistoryView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("BattleHistoryViewModel")
  self:BindClickHandler()
end
function BattleHistoryView:OnDestroy()
  self:UnBindClickHandler()
end
function BattleHistoryView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.AllHeroSelectId = self.viewModel:GetAllHeroSelectId()
  self:SetBattleHistoryViewEmpty()
  local playerInfoMainViewModel = UIModelMgr:Get("PlayerInfoMainViewModel")
  if playerInfoMainViewModel and not playerInfoMainViewModel:CheckIsOwnerInfo(playerInfoMainViewModel:GetCurRoleID()) then
    DataMgr.GetOrQueryPlayerInfo({
      playerInfoMainViewModel:GetCurRoleID()
    }, false, function(playerInfoList)
      self.viewModel:RequestGetBattleHistory()
    end)
  else
    self.viewModel:RequestGetBattleHistory()
  end
  LogicRole.ShowOrLoadLevel(-1)
  LogicRole.ShowOrHideRoleMainHero(false)
  self:UpdateRoleList()
end
function BattleHistoryView:OnShowLink(LinkParams)
end
function BattleHistoryView:SetBattleHistoryViewEmpty()
  HideOtherItem(self.ScrollBoxHistoryList, 1)
  UpdateVisibility(self.CanvasPanelBasic, false)
  UpdateVisibility(self.CanvasPanelDetails, false)
  UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem, false)
  UpdateVisibility(self.RGTextHeroName_1, false)
  UpdateVisibility(self.CanvasPanelHistory, false)
end
function BattleHistoryView:OnRollback()
  LogicRole.ShowOrLoadLevel(-1)
  LogicRole.ShowOrHideRoleMainHero(false)
end
function BattleHistoryView:OnPreHide()
  self.HistoryItemTb = {}
  self.HistoryIdx = 1
  self.PreTimeStamp = nil
  self.viewModel:ResetCurSelectHero()
  LogicRole.ShowOrHideRoleMainHero(false)
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function BattleHistoryView:OnHide()
end
function BattleHistoryView:ListenForEscInputAction()
  local playerInfoMainViewModel = UIModelMgr:Get("PlayerInfoMainViewModel")
  playerInfoMainViewModel:HidePlayerMainView()
end
function BattleHistoryView:OnSelectPrevHero()
  local CurSelectBattleHistoryHeroId = self.viewModel:GetCurSelectBattleHistoryHeroId()
  local CurrentSelectIndex
  for Index, ID in ipairs(TableIDList) do
    if CurSelectBattleHistoryHeroId == ID then
      CurrentSelectIndex = Index
      break
    end
  end
  CurrentSelectIndex = CurrentSelectIndex - 1
  if CurrentSelectIndex < 1 then
    CurrentSelectIndex = #TableIDList
  end
  self.RGToggleGroupHistoryRole:SelectId(TableIDList[CurrentSelectIndex])
end
function BattleHistoryView:OnSelectNextHero()
  local CurSelectBattleHistoryHeroId = self.viewModel:GetCurSelectBattleHistoryHeroId()
  local CurrentSelectIndex
  for Index, ID in ipairs(TableIDList) do
    if CurSelectBattleHistoryHeroId == ID then
      CurrentSelectIndex = Index
      break
    end
  end
  CurrentSelectIndex = CurrentSelectIndex + 1
  if CurrentSelectIndex > #TableIDList then
    CurrentSelectIndex = 1
  end
  self.RGToggleGroupHistoryRole:SelectId(TableIDList[CurrentSelectIndex])
end
function BattleHistoryView:LuaTick(InDeltaTime)
  if table.IsEmpty(self.HistoryItemTb) then
    return
  end
  if self.HistoryIdx > #self.HistoryItemTb then
    return
  end
  if not self.PreTimeStamp then
    return
  end
  if 1 == self.HistoryIdx then
    if self.PreTimeStamp > self.FirstHistoryItemAniDelay then
      self.HistoryItemTb[1]:PlayAnimation(self.HistoryItemTb[1].Ani_in)
      self.PreTimeStamp = 0
      self.HistoryIdx = self.HistoryIdx + 1
    else
      self.PreTimeStamp = self.PreTimeStamp + InDeltaTime
    end
  elseif self.PreTimeStamp > self.HistoryItemAniInterval then
    self.HistoryItemTb[self.HistoryIdx]:PlayAnimation(self.HistoryItemTb[1].Ani_in)
    self.PreTimeStamp = 0
    self.HistoryIdx = self.HistoryIdx + 1
  else
    self.PreTimeStamp = self.PreTimeStamp + InDeltaTime
  end
end
function BattleHistoryView:UpdateRoleList()
  TableIDList = {}
  local allCharacterList = LogicRole.GetAllCanSelectCharacterList()
  table.sort(allCharacterList, function(A, B)
    return A < B
  end)
  local curSelectBattleHistoryHeroId = self.viewModel:GetCurSelectBattleHistoryHeroId()
  self.RGToggleGroupHistoryRole:ClearGroup()
  self.RGToggleGroupHistoryRole:AddToGroup(self.AllHeroSelectId, self.WBP_BattleHistoryRoleItemAll)
  local bAllHeroSelect = curSelectBattleHistoryHeroId == self.AllHeroSelectId
  table.insert(TableIDList, self.AllHeroSelectId)
  self.WBP_BattleHistoryRoleItemAll:InitBattleHistoryRoleItem(self.AllHeroSelectId, bAllHeroSelect, true)
  for i, v in ipairs(allCharacterList) do
    table.insert(TableIDList, v)
    local item = GetOrCreateItem(self.HorizontalBoxRoleList, i, self.WBP_BattleHistoryRoleItem:GetClass())
    local bSelect = curSelectBattleHistoryHeroId == v
    item:InitBattleHistoryRoleItem(v, bSelect)
    self.RGToggleGroupHistoryRole:AddToGroup(v, item)
  end
  HideOtherItem(self.HorizontalBoxRoleList, #allCharacterList + 1)
  self.RGToggleGroupHistoryRole:SelectId(curSelectBattleHistoryHeroId)
end
function BattleHistoryView:OnGetBattleHistory(HistoryDatas, HeroId)
  self:OnUpdateBattleHistory(HistoryDatas, HeroId)
end
function BattleHistoryView:OnUpdateBattleHistory(HistoryDatas, HeroId)
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  if HeroId ~= self.viewModel:GetAllHeroSelectId() then
    local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
    if tbHeroMonster and tbHeroMonster[HeroId] then
      self.RGTextHeroName_1:SetText(tbHeroMonster[HeroId].Name)
    end
  else
    self.RGTextHeroName_1:SetText(AllHeroInfoTxt())
  end
  UpdateVisibility(self.RGTextHeroName_1, true)
  table.sort(HistoryDatas, function(A, B)
    return A.battleHistoryData[1].GameStartTime > B.battleHistoryData[1].GameStartTime
  end)
  local num = #HistoryDatas
  if -1 == HeroId then
    if num > self.MaxHistoryItemNum then
      num = self.MaxHistoryItemNum
    end
  elseif num > self.MaxHeroHistoryItemNum then
    num = self.MaxHeroHistoryItemNum
  end
  self.HistoryItemTb = {}
  self.HistoryIdx = 1
  self.PreTimeStamp = 0
  local left = self.BattleHistoryItemPaddingLeft
  local i = 1
  for idx = 1, num do
    local v = HistoryDatas[i]
    local ownerData
    local battleHistoryData = v.battleHistoryData
    for iData, vData in ipairs(battleHistoryData) do
      if vData.roleID == playerInfoMainVM:GetCurRoleID() then
        ownerData = vData
        break
      end
    end
    if ownerData and 41 ~= ownerData.worldID then
      local item = GetOrCreateItem(self.ScrollBoxHistoryList, i, self.WBP_BattleHistoryItem:GetClass())
      item:SetRenderShear(self.BattleHistoryItemShear)
      if i > 1 then
        self.BattleHistoryItemPadding.Left = (i - 1) * left
        local scrollBoxBoxSlot = UE.UWidgetLayoutLibrary.SlotAsScrollBoxSlot(item)
        scrollBoxBoxSlot:SetPadding(self.BattleHistoryItemPadding)
      end
      item:InitBattleHistoryItem(v, HeroId, self, i)
      table.insert(self.HistoryItemTb, item)
      i = i + 1
    end
  end
  HideOtherItem(self.ScrollBoxHistoryList, i)
  local roleID = playerInfoMainVM:GetCurRoleID()
  local battleHistoryInvisible = DataMgr.GetPlayerInvisibleById(playerInfoMainVM:GetCurRoleID(), 1)
  if playerInfoMainVM:CheckIsOwnerInfo(roleID) or 0 == battleHistoryInvisible then
    if i > 1 then
      self.RGStateControllerHistoryEmpty:ChangeStatus("NoEmpty")
    else
      self.RGStateControllerHistoryEmpty:ChangeStatus("Empty")
    end
  else
    self.RGStateControllerHistoryEmpty:ChangeStatus("Invisible")
  end
  UpdateVisibility(self.CanvasPanelHistory, true)
end
function BattleHistoryView:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot, HoverItem)
  if bIsShow then
    ShowCommonTips(nil, HoverItem, self.WBP_GenericModifyBagTips)
    self.WBP_GenericModifyBagTips:InitGenericModifyTipsBySettlement(Data, Slot, true)
  else
    UpdateVisibility(self.WBP_GenericModifyBagTips, false, true, true)
  end
end
function BattleHistoryView:OnUpdateStatistics(HeroStatistic, HeroId)
  UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem, true)
  UpdateVisibility(self.WBP_BattleHistoryDetailsItemSkillCount, true)
  UpdateVisibility(self.CanvasPanelBasic, true)
  UpdateVisibility(self.CanvasPanelDetails, true)
  if not HeroStatistic then
    self.WBP_BattleHistoryBasicItemTotalDuration.RGTextValue:SetText(0)
    self.WBP_BattleHistoryBasicItemDiffcult.RGTextValue:SetText("--")
    self.WBP_BattleHistoryBasicItemWinCount.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemAvgDamage.RGTextValue:SetText("--")
    self.WBP_BattleHistoryDetailsItemTotalKills.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemBattleCount.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemSkillCount.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemAvgHelp.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemMostHelp.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemAttribute.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemDoubleModify.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextDesc:SetText(DetailsCommonlyUsedWeaponDesc())
    self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextValue:SetText("--")
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageIcon, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.WBP_RGMaskWidget, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_DiHero, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_KuangHero, false)
    return
  end
  if HeroId ~= self.viewModel:GetAllHeroSelectId() then
    local str = tostring(math.ceil(tonumber(HeroStatistic.totalBattleDuration) / 3600)) .. "H"
    self.WBP_BattleHistoryBasicItemTotalDuration.RGTextValue:SetText(str)
    local winHardestStr = HeroStatistic.winHardest
    if 0 == HeroStatistic then
      winHardestStr = "--"
    end
    self.WBP_BattleHistoryBasicItemDiffcult.RGTextValue:SetText(winHardestStr)
    self.WBP_BattleHistoryBasicItemWinCount.RGTextValue:SetText(HeroStatistic.totalWinCount)
    local totalHarm = HeroStatistic.totalHarm or 0
    local totalBattleDuration = HeroStatistic.totalBattleDuration or 1
    if "0" == totalBattleDuration then
      totalBattleDuration = 1
    end
    local avgDamage = tonumber(totalHarm) / tonumber(totalBattleDuration) * 60
    local avgStr = math.floor(avgDamage)
    if 0 == avgDamage then
      avgStr = "--"
    end
    self.WBP_BattleHistoryDetailsItemAvgDamage.RGTextValue:SetText(avgStr)
    self.WBP_BattleHistoryDetailsItemTotalKills.RGTextValue:SetText(HeroStatistic.totalKills)
    self.WBP_BattleHistoryDetailsItemBattleCount.RGTextValue:SetText(HeroStatistic.totalBattleCount)
    self.WBP_BattleHistoryDetailsItemSkillCount.RGTextValue:SetText(HeroStatistic.totalSkillSuccCount)
    local avgHelp = HeroStatistic.totalHelpCount / HeroStatistic.totalBattleCount
    if not IsInterger(avgHelp) then
      self.WBP_BattleHistoryDetailsItemAvgHelp.RGTextValue:SetText(string.format("%.2f", avgHelp))
    else
      self.WBP_BattleHistoryDetailsItemAvgHelp.RGTextValue:SetText(math.floor(avgHelp))
    end
    self.WBP_BattleHistoryDetailsItemMostHelp.RGTextValue:SetText(HeroStatistic.maxHelp)
    self.WBP_BattleHistoryDetailsItemAttribute.RGTextValue:SetText(HeroStatistic.totalCollectionCount)
    self.WBP_BattleHistoryDetailsItemDoubleModify.RGTextValue:SetText(HeroStatistic.totalDoubleBlessCount)
    local weaponId, count = self.viewModel:GetMostUsedWeaponIdByHeroId(HeroId)
    self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextDesc:SetText(DetailsCommonlyUsedWeaponDesc())
    if -1 == weaponId then
      self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextValue:SetText("--")
      UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageIcon, false)
      UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.WBP_RGMaskWidget, false)
      UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_DiHero, false)
      UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_KuangHero, false)
    else
      local bResult, ItemData = GetRowData(DT.DT_Item, tostring(weaponId))
      if bResult then
        self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextValue:SetText(ItemData.Name)
        SetImageBrushBySoftObject(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageIcon, ItemData.CompleteGunIcon)
        UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.WBP_RGMaskWidget, false)
        UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_DiHero, false)
        UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_KuangHero, false)
        UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageIcon, true)
      end
    end
  end
end
function BattleHistoryView:OnUpdateAllHeroStatistics(HeroStatistic, HeroId)
  UpdateVisibility(self.WBP_BattleHistoryDetailsItemSkillCount, false)
  UpdateVisibility(self.CanvasPanelBasic, true)
  UpdateVisibility(self.CanvasPanelDetails, true)
  UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem, true)
  if not HeroStatistic then
    self.WBP_BattleHistoryBasicItemTotalDuration.RGTextValue:SetText(0)
    self.WBP_BattleHistoryBasicItemDiffcult.RGTextValue:SetText("--")
    self.WBP_BattleHistoryBasicItemWinCount.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemAvgDamage.RGTextValue:SetText("--")
    self.WBP_BattleHistoryDetailsItemTotalKills.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemBattleCount.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemSkillCount.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemAvgHelp.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemMostHelp.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemAttribute.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsItemDoubleModify.RGTextValue:SetText(0)
    self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextValue:SetText("--")
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageIcon, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.WBP_RGMaskWidget, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_DiHero, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_KuangHero, false)
    return
  end
  local str = tostring(math.ceil(tonumber(HeroStatistic.totalBattleDuration) / 3600)) .. "H"
  self.WBP_BattleHistoryBasicItemTotalDuration.RGTextValue:SetText(str)
  local winHardestStr = HeroStatistic.winHardest
  if 0 == HeroStatistic then
    winHardestStr = "--"
  end
  self.WBP_BattleHistoryBasicItemDiffcult.RGTextValue:SetText(winHardestStr)
  self.WBP_BattleHistoryBasicItemWinCount.RGTextValue:SetText(HeroStatistic.totalWinCount)
  local totalHarm = HeroStatistic.totalHarm or 0
  local totalBattleDuration = HeroStatistic.totalBattleDuration or 1
  if "0" == totalBattleDuration then
    totalBattleDuration = 1
  end
  local avgDamage = tonumber(totalHarm) / tonumber(totalBattleDuration) * 60
  local avgStr = math.floor(avgDamage)
  if 0 == avgDamage then
    avgStr = "--"
  end
  self.WBP_BattleHistoryDetailsItemAvgDamage.RGTextValue:SetText(avgStr)
  self.WBP_BattleHistoryDetailsItemTotalKills.RGTextValue:SetText(HeroStatistic.totalKills)
  self.WBP_BattleHistoryDetailsItemBattleCount.RGTextValue:SetText(HeroStatistic.totalBattleCount)
  self.WBP_BattleHistoryDetailsItemSkillCount.RGTextValue:SetText(HeroStatistic.totalSkillSuccCount)
  local totalHelpCount = HeroStatistic.totalHelpCount or 0
  local totalBattleCount = HeroStatistic.totalBattleCount
  totalBattleCount = 0 ~= totalBattleCount and totalBattleCount or 1
  local avgHelp = totalHelpCount / totalBattleCount
  if not IsInterger(avgHelp) then
    self.WBP_BattleHistoryDetailsItemAvgHelp.RGTextValue:SetText(string.format("%.2f", avgHelp))
  else
    self.WBP_BattleHistoryDetailsItemAvgHelp.RGTextValue:SetText(math.floor(avgHelp))
  end
  self.WBP_BattleHistoryDetailsItemMostHelp.RGTextValue:SetText(HeroStatistic.maxHelp)
  self.WBP_BattleHistoryDetailsItemAttribute.RGTextValue:SetText(HeroStatistic.totalCollectionCount)
  self.WBP_BattleHistoryDetailsItemDoubleModify.RGTextValue:SetText(HeroStatistic.totalDoubleBlessCount)
  local heroId, count = self.viewModel:GetMostUsedHeroInfo()
  self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextDesc:SetText(DetailsCommonlyUsedHeroDesc())
  if -1 == heroId then
    self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextValue:SetText("--")
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageIcon, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.WBP_RGMaskWidget, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_DiHero, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_KuangHero, false)
  else
    local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
    if tbHeroMonster and tbHeroMonster[heroId] then
      self.WBP_BattleHistoryDetailsCommonlyUsedItem.RGTextValue:SetText(tbHeroMonster[heroId].Name)
      SetImageBrushByPath(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageHeroIcon, tbHeroMonster[heroId].ActorIcon)
    end
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.URGImageIcon, false)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.WBP_RGMaskWidget, true)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_DiHero, true)
    UpdateVisibility(self.WBP_BattleHistoryDetailsCommonlyUsedItem.ScaleBox_KuangHero, true)
  end
end
function BattleHistoryView:OnCheckStateChanged(SelectId)
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  print("BattleHistoryView:OnCheckStateChanged", SelectId)
  self.viewModel:SelectHeroId(SelectId, roleID)
end
function BattleHistoryView:ShowBattleHistoryPlayerInfo(HistoryData)
  self.viewModel:SetCurHistoryData(HistoryData)
  local PlayerInfoMainViewModel = UIModelMgr:Get("PlayerInfoMainViewModel")
  self.WBP_SettlementPlayerInfoView:InitBattleHistoryPlayerInfo(PlayerInfoMainViewModel:GetCurRoleID(), HistoryData)
  UpdateVisibility(self.WBP_SettlementPlayerInfoView, true)
end
return BattleHistoryView
