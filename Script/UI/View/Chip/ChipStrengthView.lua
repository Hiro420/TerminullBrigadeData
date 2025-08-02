local Orderedmap = require("Framework.DataStruct.OrderedMap")
local chipseasonslotitem = require("UI.View.Chip.ChipSeasonSlotItem")
local chipstrengthattritem = require("UI.View.Chip.ChipStrengthAttrItem")
local ChipStrengthView = UnLua.Class()
local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
local tbChipLevelUp = LuaTableMgr.GetLuaTableByName(TableNames.TBChipLevelUp)

function ChipStrengthView:Construct()
  self.viewModel = UIModelMgr:Get("ChipViewModel")
  self.BP_ButtonWithSoundFilter.OnClicked:Add(self, self.OnFilterClick)
  self.CheckBoxDiscard.OnCheckStateChanged:Add(self, self.OnOnlyCheckDiscard)
  self.BP_ButtonWithSoundStrength.OnClicked:Add(self, self.OnStrengthClick)
  self.RGToggleGroupStrengthLv.OnCheckStateChanged:Add(self, self.ToggleGroupStrengthLvChanged)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.HideStrengthView)
  self.Btn_Left.OnClicked:Add(self, self.OnSwitchLeftRareLimit)
  self.Btn_Right.OnClicked:Add(self, self.OnSwitchRightRareLimit)
end

function ChipStrengthView:Destruct()
  self.viewModel = nil
  self.BP_ButtonWithSoundFilter.OnClicked:Remove(self, self.OnFilterClick)
  self.CheckBoxDiscard.OnCheckStateChanged:Remove(self, self.OnOnlyCheckDiscard)
  self.BP_ButtonWithSoundStrength.OnClicked:Remove(self, self.OnStrengthClick)
  self.RGToggleGroupStrengthLv.OnCheckStateChanged:Remove(self, self.ToggleGroupStrengthLvChanged)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.HideStrengthView)
  self.Btn_Left.OnClicked:Remove(self, self.OnSwitchLeftRareLimit)
  self.Btn_Right.OnClicked:Remove(self, self.OnSwitchRightRareLimit)
end

function ChipStrengthView:HideStrengthView()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:HideViewByViewSet()
  end
end

function ChipStrengthView:OnSwitchLeftRareLimit()
  if self.viewModel:GetCurRareLimit() <= UE.ERGItemRarity.EIR_Excellent then
    self.viewModel:SetCurRareLimit(UE.ERGItemRarity.EIR_Excellent)
  else
    self.viewModel:SetCurRareLimit(self.viewModel:GetCurRareLimit() - 1)
  end
  self.StateCtrl_RareLimit:ChangeStatus(tostring(self.viewModel:GetCurRareLimit()))
end

function ChipStrengthView:OnSwitchRightRareLimit()
  if self.viewModel:GetCurRareLimit() >= UE.ERGItemRarity.EIR_Immortal then
    self.viewModel:SetCurRareLimit(UE.ERGItemRarity.EIR_Immortal)
  else
    self.viewModel:SetCurRareLimit(self.viewModel:GetCurRareLimit() + 1)
  end
  self.StateCtrl_RareLimit:ChangeStatus(tostring(self.viewModel:GetCurRareLimit()))
end

function ChipStrengthView:InitChipStrengthView(ParentView, ChipBagItemData)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_icon_loop, 0, 0)
  UpdateVisibility(self, true)
  UpdateVisibility(self.AutoLoadPanel, true)
  EventSystem.Invoke(EventDef.Develop.UpdateViewSetVisible, false)
  self.viewModel = UIModelMgr:Get("ChipViewModel")
  self.ParentView = ParentView
  self.ChipBagItemData = ChipBagItemData
  self.SelectChipEatTb = {}
  self.SelectChipUpgradeMatEatTb = {}
  self.StateCtrl_RareLimit:ChangeStatus(tostring(self.viewModel:GetCurRareLimit()))
  self.WBP_ChipStrengthPanelItem:InitChipStrengthPanelItem(ChipBagItemData)
  self.WBP_ChipIconItem:InitChipIconItem(ChipBagItemData)
  self.CheckBoxDiscard:SetIsChecked(self.viewModel:GetIsOnlyCheckDiscard())
  self:UpdateChipItemList()
  self:UpdateStrengthLv()
  self:UpdateDetailsView()
  self:UpdateStrengthFilterStatus()
end

function ChipStrengthView:UpdateChipItemList(ChipOrderedMap)
  self.viewModel = UIModelMgr:Get("ChipViewModel")
  local UpdateChipItemListFunc = function(chipOrderedMap)
    self.ChipOrderedMap = chipOrderedMap
    self.RGTileViewChipItemRoot:RecyleAllData()
    local ChatDataObjList = UE.TArray(UE.UObject)
    ChatDataObjList:Reserve(#chipOrderedMap)
    for i, v in pairs(chipOrderedMap) do
      if v.Chip and self.ChipBagItemData.Chip.id ~= v.Chip.id or v.ChipUpgradeMat then
        local dataObj = self.RGTileViewChipItemRoot:GetOrCreateDataObj()
        dataObj:Reset()
        dataObj.ChipItemData = v
        dataObj.ParentView = self
        dataObj.ChipFilterTipsFrom = EChipViewState.Strength
        local bSelect = false
        if v.Chip then
          bSelect = self.SelectChipEatTb[v.Chip.id]
        elseif self.SelectChipUpgradeMatEatTb[v.ChipUpgradeMat.ResID] then
          bSelect = self.SelectChipUpgradeMatEatTb[v.ChipUpgradeMat.ResID].amount > 0
          dataObj.ChipItemData.ChipUpgradeMat.SelectAmount = self.SelectChipUpgradeMatEatTb[v.ChipUpgradeMat.ResID].amount
        else
          bSelect = false
          dataObj.ChipItemData.ChipUpgradeMat.SelectAmount = 0
        end
        dataObj.bSelect = bSelect
        dataObj.bFirst = 1 == i
        ChatDataObjList:Add(dataObj)
      end
    end
    self.RGTileViewChipItemRoot:SetRGListItems(ChatDataObjList, true, true)
    self:UpdateFullStatus()
  end
  if ChipOrderedMap then
    UpdateChipItemListFunc(ChipOrderedMap)
  else
    self.viewModel:FilterStrengthChipBagOrderedMap(self.ChipBagItemData, UpdateChipItemListFunc)
  end
end

function ChipStrengthView:UpdateChipItemListKeepSort()
  local chipItemList = self.RGTileViewChipItemRoot:GetListItems():ToTable()
  local ChatDataObjList = UE.TArray(UE.UObject)
  ChatDataObjList:Reserve(#chipItemList)
  for i, v in ipairs(chipItemList) do
    local dataObj = self.RGTileViewChipItemRoot:GetOrCreateDataObj()
    dataObj:Reset()
    dataObj.ChipItemData = v.ChipItemData
    dataObj.ParentView = self
    dataObj.ChipFilterTipsFrom = EChipViewState.Strength
    local bSelect = false
    if v.ChipItemData.Chip then
      bSelect = self.SelectChipEatTb[v.ChipItemData.Chip.id]
    else
      bSelect = self.SelectChipUpgradeMatEatTb[v.ChipItemData.ChipUpgradeMat.ResID].amount > 0
    end
    dataObj.bSelect = bSelect
    dataObj.bFirst = 1 == i
    ChatDataObjList:Add(dataObj)
  end
  self.RGTileViewChipItemRoot:SetRGListItems(ChatDataObjList, true, true)
  self:UpdateFullStatus()
end

function ChipStrengthView:UpdateFullStatus()
  self.viewModel = UIModelMgr:Get("ChipViewModel")
  local num = self.viewModel:GetChipsTotalNum()
  local maxNum = self.viewModel:GetMaxChipNum()
  local str = string.format("%d/%d", num, maxNum)
  self.RGTextChipNum:SetText(str)
  if num >= maxNum then
    self.StateCtrl_Full:ChangeStatus("Full")
  else
    self.StateCtrl_Full:ChangeStatus("NotFull")
  end
end

function ChipStrengthView:UpdateStrengthLv()
  self.RGToggleGroupStrengthLv:ClearGroup()
  local idx = 1
  local maxLv = self.viewModel:GetMaxLvByChipBagItem(self.ChipBagItemData)
  for i, v in iterator(self.StrengthLvList) do
    if v <= maxLv then
      local item = GetOrCreateItem(self.ScrollBoxStrengthLv, idx, self.WBP_ChipStrengthLvItem:GetClass())
      item:InitChipStrengthLvItem(v, v > self.ChipBagItemData.Chip.level)
      self.RGToggleGroupStrengthLv:AddToGroup(i, item)
      idx = idx + 1
    end
  end
  HideOtherItem(self.ScrollBoxStrengthLv, idx)
  self.RGToggleGroupStrengthLv:SelectId(-1)
end

function ChipStrengthView:UpdateStrength(Id, OldSubAttr)
  if nil == Id then
    self.SelectChipEatTb = {}
    self.SelectChipUpgradeMatEatTb = {}
    self:UpdateDetailsView(true, OldSubAttr)
    self:UpdateStrengthLv()
  elseif self.SelectChipEatTb and self.SelectChipEatTb[Id] then
    self.SelectChipEatTb[Id] = nil
    self:UpdateDetailsView()
  end
end

function ChipStrengthView:UpdateDetailsView(bIsUpgrade, OldSubAttr)
  self.RGTextChipName:SetText(self.viewModel:GetChipName(self.ChipBagItemData))
  local rare = self.viewModel:GetChipRare(self.ChipBagItemData)
  local result, itemRarity = GetRowData(DT.DT_ItemRarity, tostring(rare))
  if result then
    self.RGTextChipName:SetColorAndOpacity(itemRarity.DisplayNameColor)
  end
  local tbChipSlots = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if tbChipSlots and tbChipSlots[self.ChipBagItemData.TbChipData.Slot] then
    self.RGTextChipSlotName:SetText(tbChipSlots[self.ChipBagItemData.TbChipData.Slot].name)
  end
  local oldExp = self.ChipBagItemData.Chip.exp
  local oldLevel = self.ChipBagItemData.Chip.level
  local newExp = oldExp
  for k, v in pairs(self.SelectChipEatTb) do
    if v then
      local chipBagDataRef = self.viewModel:GetChipBagDataByUUIDRef(k)
      local expAdd = self.viewModel:GetEatExpByChipBagData(chipBagDataRef)
      newExp = newExp + expAdd
    end
  end
  for i, v in pairs(self.SelectChipUpgradeMatEatTb) do
    local chipBagDataTemp = self.viewModel:CreateChipBagItemDataByUpgradeMat(v.id, v.amount)
    local expAdd = self.viewModel:GetEatExpByChipBagData(chipBagDataTemp, 0, v.amount)
    newExp = newExp + expAdd
  end
  if oldLevel >= self.viewModel:GetMaxLv(rare) then
    local lvUpExp = self.viewModel:GetCurLvUpExpByChipBagData(self.ChipBagItemData, 1)
    newExp = lvUpExp
    local expStr = string.format("%d/%d", lvUpExp, lvUpExp)
    self.RGTextExpProgress:SetText(expStr)
    self.URGImageExpBar:SetClippingValue(1)
    self.URGImageExpBar_2:SetClippingValue(1)
    self.RGStateControllerMaxLv:ChangeStatus("MaxLv")
  else
    local lvUpExp = self.viewModel:GetCurLvUpExpByChipBagData(self.ChipBagItemData, 1)
    local preLvUpExp = self.viewModel:GetCurLvUpExpByChipBagData(self.ChipBagItemData)
    local curLvUpExpDiff = lvUpExp - preLvUpExp
    local curLvUpExpAdd = newExp - preLvUpExp
    local expStr = string.format("%d/%d", curLvUpExpAdd, curLvUpExpDiff)
    self.RGTextExpProgress:SetText(expStr)
    local percent = math.clamp(curLvUpExpAdd / curLvUpExpDiff, 0, 1)
    local expAdd = oldExp - preLvUpExp
    self.URGImageExpBar:SetClippingValue(percent)
    self.URGImageExpBar_2:SetClippingValue(expAdd / curLvUpExpDiff)
    self.RGStateControllerMaxLv:ChangeStatus("NotMaxLv")
    UpdateVisibility(self.CanvasPanelArrow, curLvUpExpAdd - expAdd > 0)
    UpdateVisibility(self.HorizontalBoxNewLv, curLvUpExpAdd - expAdd > 0)
  end
  local newLv = self.viewModel:GetNewLvByChipBagData(self.ChipBagItemData, newExp)
  local maxLv = self.viewModel:GetMaxLvByChipBagItem(self.ChipBagItemData)
  UpdateVisibility(self.Canvas_Max, newLv >= maxLv)
  self.RGTextNewLv:SetText(newLv)
  self.RGTextOldLv:SetText(oldLevel)
  local levelUPMainAttrGrowth = self.viewModel:GetLevelUPMainAttrGrowthByChipBagData(self.ChipBagItemData)
  self.WBP_ChipStrengthCoreAttrItem:InitChipStrengthAttrItem(levelUPMainAttrGrowth, self.ChipBagItemData, oldLevel, newLv, bIsUpgrade)
  local bHaveRandAttrChange = false
  local randSubAttrLvGap = self.viewModel:GetRandSubAttrLvGap()
  for i = oldLevel + 1, newLv do
    if 0 == i % randSubAttrLvGap then
      bHaveRandAttrChange = true
      break
    end
  end
  local idxOffset = 0
  if bHaveRandAttrChange then
    self.WBP_ChipStrengthRandomAttrItem:InitChipStrengthSubAttrItem(nil, true)
    idxOffset = 1
  end
  local subAttrList = {}
  for i, v in ipairs(self.ChipBagItemData.Chip.subAttr) do
    table.insert(subAttrList, v)
  end
  table.sort(subAttrList, function(A, B)
    return A.attrID > B.attrID
  end)
  UpdateVisibility(self.RGTextRandomAttr, #subAttrList + idxOffset > 0)
  for i, v in ipairs(subAttrList) do
    local bIsNew = bIsUpgrade
    if OldSubAttr then
      for iOld, vOld in ipairs(OldSubAttr) do
        if vOld.attrID == v.attrID then
          bIsNew = false
          break
        end
      end
    else
      bIsNew = false
    end
    local item = GetOrCreateItem(self.VerticalBoxRandomAttrList, i + idxOffset, self.WBP_ChipStrengthRandomAttrItem:GetClass())
    item:InitChipStrengthSubAttrItem(v, false, bIsNew)
  end
  HideOtherItem(self.VerticalBoxRandomAttrList, #subAttrList + 1 + idxOffset)
  local LogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if LogicCommandDataSubsystem then
    local specialAttrDesc = GetLuaInscriptionDesc(self.ChipBagItemData.Chip.inscription, 0, nil)
    self.RGRichTextBlockSpecialDesc:SetText(specialAttrDesc)
  end
  UpdateVisibility(self.RGRichTextBlockSpecialDesc, self.ChipBagItemData.Chip.inscription > 0)
  UpdateVisibility(self.RGTextSpecialAttr, self.ChipBagItemData.Chip.inscription > 0)
end

function ChipStrengthView:ShowChipAttrListTip(bShow, ChipBagsItemData, bSelect)
  if bShow then
    if not self.viewModel:CheckIsChipUpgradeMat(ChipBagsItemData) then
      UpdateVisibility(self.RGAutoLoadPanelCompareChipAttrListTips, true)
      self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:InitChipAttrListTip(ChipBagsItemData, not bSelect, EChipAttrListTipSComparetate.Compare, EChipViewState.Strength)
    else
      local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, tonumber(ChipBagsItemData.ChipUpgradeMat.ResID))
      if result then
        self.WBP_CommonTips:ShowTips(row.Name, row.Desc)
        UpdateVisibility(self.WBP_CommonTips, true)
      end
    end
    self.ParentView:UpdateCurHoverChipBagsItemData(ChipBagsItemData)
  else
    if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget) then
      self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:Hide()
    end
    UpdateVisibility(self.WBP_CommonTips, false)
    self.ParentView:UpdateCurHoverChipBagsItemData(nil)
  end
end

function ChipStrengthView:UpdateChipAttrListTip(ChipBagsItemData, bSelect)
  if self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget then
    self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:InitChipAttrListTip(ChipBagsItemData, not bSelect, EChipAttrListTipSComparetate.Compare, EChipViewState.Strength)
    self.ParentView:UpdateCurHoverChipBagsItemData(ChipBagsItemData)
  end
end

function ChipStrengthView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
    UpdateVisibility(self.AutoLoadPanel, false)
  end
end

function ChipStrengthView:Hide()
  UpdateVisibility(self, true)
  UpdateVisibility(self.AutoLoadPanel, true)
  self:StopAnimation(self.Ani_in)
  self:StopAnimation(self.Ani_icon_loop)
  self:PlayAnimation(self.Ani_out)
  self.viewModel = UIModelMgr:Get("ChipViewModel")
  self.viewModel:OnlyCheckDiscard(false, true)
  self.ParentView:HideFilterTips()
  EventSystem.Invoke(EventDef.Develop.UpdateViewSetVisible, true)
  self.SelectChipEatTb = {}
  self.SelectChipUpgradeMatEatTb = {}
  self.viewModel = nil
end

function ChipStrengthView:OnFilterClick()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:OnFilterClick(EChipViewState.Strength)
  end
end

function ChipStrengthView:OnOnlyCheckDiscard(bIsCheck)
  if self.viewModel then
    self.viewModel:OnlyCheckDiscard(bIsCheck)
  end
end

function ChipStrengthView:OnStrengthClick()
  local eatList = {}
  local eatChipUpgradeList = {}
  local bNeedConfirm = false
  for k, v in pairs(self.SelectChipEatTb) do
    if v then
      local chipBagItemData = self.viewModel:GetChipBagDataByUUIDRef(k)
      if self.viewModel:GetChipRare(chipBagItemData) >= UE.ERGItemRarity.EIR_Legend then
        bNeedConfirm = true
      end
      table.insert(eatList, k)
    end
  end
  for i, v in pairs(self.SelectChipUpgradeMatEatTb) do
    if v.amount > 0 then
      table.insert(eatChipUpgradeList, v)
    end
  end
  if table.IsEmpty(eatList) and table.IsEmpty(eatChipUpgradeList) then
    ShowWaveWindow(1163)
    return
  end
  if bNeedConfirm then
    ShowWaveWindowWithDelegate(1160, {}, {
      GameInstance,
      function()
        self.viewModel:RequestUpgradeChip(eatList, self.ChipBagItemData.Chip.id, eatChipUpgradeList)
      end
    })
    return
  end
  self.viewModel:RequestUpgradeChip(eatList, self.ChipBagItemData.Chip.id, eatChipUpgradeList)
end

function ChipStrengthView:OnUpgradeChip(OldLv, NewLv)
  self:PlayAnimation(self.Ani_icon_strengthen_effect)
  self.StateCtrl_Slot:ChangeStatus(self.ChipBagItemData.TbChipData.Slot)
  if OldLv < NewLv then
    self:PlayAnimation(self.Ani_grade_hoist)
  end
end

function ChipStrengthView:UpdateStrengthFilterStatus()
  local bIsDefaultFilter = self.viewModel:CheckStrengthIsDefaultFilter()
  if bIsDefaultFilter then
    self.StateCtrl_Filter:ChangeStatus(EChipFilter.Normal)
  else
    self.StateCtrl_Filter:ChangeStatus(EChipFilter.Filter)
  end
end

function ChipStrengthView:ToggleGroupStrengthLvChanged(SelectId)
  if -1 == SelectId then
    self.SelectChipEatTb = {}
    self.SelectChipUpgradeMatEatTb = {}
  elseif self.StrengthLvList:IsValidIndex(SelectId) then
    self.SelectChipEatTb = {}
    self.SelectChipUpgradeMatEatTb = {}
    local lv = self.StrengthLvList:Get(SelectId)
    local eatChipList, eatChipUpgradeMatList = self.viewModel:CheckOutEatListToTargetLv(self.ChipOrderedMap, self.ChipBagItemData, lv - self.ChipBagItemData.Chip.level)
    for i, v in ipairs(eatChipList) do
      self.SelectChipEatTb[v] = true
    end
    for i, v in ipairs(eatChipUpgradeMatList) do
      self.SelectChipUpgradeMatEatTb[v.id] = {
        id = v.id,
        amount = v.amount
      }
    end
  end
  self:UpdateChipItemList(self.ChipOrderedMap)
  self:UpdateDetailsView()
end

function ChipStrengthView:SelectEatChip(ChipBagItemData, bSelect, Callback)
  if ChipBagItemData.Chip and ChipBagItemData.Chip.state == EChipState.Lock then
    ShowWaveWindow(1162)
    return
  end
  if not self.viewModel:CheckCanEatByChipBagData(ChipBagItemData, self.ChipBagItemData) then
    ShowWaveWindow(1200)
    return
  end
  if bSelect then
    local maxLv = self.viewModel:GetMaxLvByChipBagItem(self.ChipBagItemData)
    if maxLv <= self.ChipBagItemData.Chip.level then
      ShowWaveWindow(1201)
      print("\229\141\135\231\186\167\232\138\175\231\137\135\229\183\178\230\187\161\231\186\167\228\184\141\229\143\175\231\187\167\231\187\173\229\141\135\231\186\167", self.ChipBagItemData.Chip.level, maxLv, self.ChipBagItemData.TbChipData.ID)
      return
    end
    local newExp = self.ChipBagItemData.Chip.exp
    for k, v in pairs(self.SelectChipEatTb) do
      if v then
        local chipBagDataRef = self.viewModel:GetChipBagDataByUUIDRef(k)
        local expAdd = self.viewModel:GetEatExpByChipBagData(chipBagDataRef)
        newExp = newExp + expAdd
      end
    end
    for i, v in pairs(self.SelectChipUpgradeMatEatTb) do
      local chipBagDataTemp = self.viewModel:CreateChipBagItemDataByUpgradeMat(v.id, v.amount)
      local expAdd = self.viewModel:GetEatExpByChipBagData(chipBagDataTemp, 0, v.amount)
      newExp = newExp + expAdd
    end
    local lvDiff = maxLv - self.ChipBagItemData.Chip.level
    local maxExp = self.viewModel:GetCurLvUpExpByChipBagData(self.ChipBagItemData, lvDiff)
    if newExp >= maxExp then
      ShowWaveWindow(1201)
      print("\229\141\135\231\186\167\232\138\175\231\137\135\231\187\143\233\170\140\229\183\178\230\187\161\228\184\141\229\143\175\231\187\167\231\187\173\229\141\135\231\186\167", newExp, maxExp, self.ChipBagItemData.TbChipData.ID)
      return
    end
  end
  if bSelect and ChipBagItemData.Chip and ChipBagItemData.Chip.equipHeroID > 0 then
    local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
    local heroName = ""
    if tbHeroMonster and tbHeroMonster[ChipBagItemData.Chip.equipHeroID] then
      heroName = tbHeroMonster[ChipBagItemData.Chip.equipHeroID].Name
    end
    local waveWindowParam = UE.FWaveWindowParam()
    waveWindowParam.StringParam0 = ChipBagItemData.Chip.id
    ShowWaveWindowWithDelegate(1159, {heroName}, {
      GameInstance,
      function()
        if ChipBagItemData.Chip then
          self.SelectChipEatTb[ChipBagItemData.Chip.id] = bSelect
        end
        self:UpdateChipAttrListTip(ChipBagItemData, bSelect)
        self:UpdateChipItemList(self.ChipOrderedMap)
        self:UpdateDetailsView()
      end
    }, nil, waveWindowParam)
    return
  end
  if ChipBagItemData.Chip then
    self.SelectChipEatTb[ChipBagItemData.Chip.id] = bSelect
  elseif ChipBagItemData.ChipUpgradeMat then
    if bSelect then
      if not ChipBagItemData.ChipUpgradeMat.SelectAmount then
        ChipBagItemData.ChipUpgradeMat.SelectAmount = 0
      end
      ChipBagItemData.ChipUpgradeMat.SelectAmount = ChipBagItemData.ChipUpgradeMat.SelectAmount + 1
      if not self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID] then
        self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID] = {
          id = ChipBagItemData.ChipUpgradeMat.ResID,
          amount = ChipBagItemData.ChipUpgradeMat.SelectAmount
        }
      else
        self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID].amount = self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID].amount + 1
      end
    else
      if not ChipBagItemData.ChipUpgradeMat.SelectAmount then
        ChipBagItemData.ChipUpgradeMat.SelectAmount = 0
      end
      ChipBagItemData.ChipUpgradeMat.SelectAmount = math.clamp(ChipBagItemData.ChipUpgradeMat.SelectAmount, 0, ChipBagItemData.ChipUpgradeMat.SelectAmount - 1)
      self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID].amount = self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID].amount - 1
    end
  end
  self:UpdateChipAttrListTip(ChipBagItemData, bSelect)
  if Callback then
    Callback(ChipBagItemData)
  else
    self:UpdateChipItemList(self.ChipOrderedMap)
  end
  self:UpdateDetailsView()
end

function ChipStrengthView:CheckInEatTb(ChipBagItemData)
  if not ChipBagItemData then
    return false
  end
  if ChipBagItemData.Chip then
    return self.SelectChipEatTb[ChipBagItemData.Chip.id]
  end
  if ChipBagItemData.ChipUpgradeMat then
    if not self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID] then
      return false
    end
    return self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID].amount > 0
  end
  return false
end

function ChipStrengthView:CheckCanSelect(ChipBagItemData)
  if not ChipBagItemData then
    return false
  end
  if ChipBagItemData.Chip then
    return not self.SelectChipEatTb[ChipBagItemData.Chip.id]
  end
  if ChipBagItemData.ChipUpgradeMat then
    if not self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID] then
      return true
    end
    return self.SelectChipUpgradeMatEatTb[ChipBagItemData.ChipUpgradeMat.ResID].amount < ChipBagItemData.ChipUpgradeMat.amount
  end
  return true
end

function ChipStrengthView:CheckCanEatByChipBagData(beEatedChipBagData)
  if not beEatedChipBagData then
    return false
  end
  if not self.ChipBagItemData then
    return false
  end
  local viewModel = UIModelMgr:Get("ChipViewModel")
  return viewModel:CheckCanEatByChipBagData(beEatedChipBagData, self.ChipBagItemData)
end

return ChipStrengthView
