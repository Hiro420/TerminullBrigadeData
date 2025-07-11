local ChipData = require("Modules.Chip.ChipData")
local ChipHandler = require("Protocol.Chip.ChipHandler")
local RedDotData = require("Modules.RedDot.RedDotData")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
local rapidjson = require("rapidjson")
local ChipViewModel = CreateDefaultViewModel()
ChipViewModel.propertyBindings = {}
ChipViewModel.subViewModels = {}
local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
local tbChipLevelUp = LuaTableMgr.GetLuaTableByName(TableNames.TBChipLevelUp)
local tbMainAttrLvUp = LuaTableMgr.GetLuaTableByName(TableNames.TBMainAttrLvUp)
local SeasonName = NSLOCTEXT("ChipViewModel", "SeasonName", "\231\137\185\230\174\138")
function ChipViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListenerNew(EventDef.Chip.GetHeroChipBag, self, self.OnGetHeroChipBag)
  EventSystem.AddListenerNew(EventDef.Chip.AddChip, self, self.OnGetHeroChipBag)
  EventSystem.AddListenerNew(EventDef.Chip.CancelOrDiscard, self, self.OnCancelOrDiscard)
  EventSystem.AddListenerNew(EventDef.Chip.DiscardChip, self, self.OnDiscardChip)
  EventSystem.AddListenerNew(EventDef.Chip.EquipChip, self, self.OnEquipChip)
  EventSystem.AddListenerNew(EventDef.Chip.LockChip, self, self.OnLockChip)
  EventSystem.AddListenerNew(EventDef.Chip.MigrateChip, self, self.OnMigrateChip)
  EventSystem.AddListenerNew(EventDef.Chip.UnEquipChip, self, self.OnUnEquipChip)
  EventSystem.AddListenerNew(EventDef.Chip.UpgradeChip, self, self.OnUpgradeChip)
  EventSystem.AddListenerNew(EventDef.Chip.UpdateChipEquipSlot, self, self.OnUpdateChipEquipSlot)
  EventSystem.AddListenerNew(EventDef.Chip.UpdateEquipedChipDetail, self, self.OnUpdateEquipedChipDetail)
  EventSystem.AddListenerNew(EventDef.WSMessage.pushNewChip, self, self.OnResourceUpdate)
  self.bCanRefreshChipAttrTips = true
end
function ChipViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.Chip.GetHeroChipBag, self, self.OnGetHeroChipBag)
  EventSystem.RemoveListenerNew(EventDef.Chip.AddChip, self, self.OnGetHeroChipBag)
  EventSystem.RemoveListenerNew(EventDef.Chip.CancelOrDiscard, self, self.OnCancelOrDiscard)
  EventSystem.RemoveListenerNew(EventDef.Chip.DiscardChip, self, self.OnDiscardChip)
  EventSystem.RemoveListenerNew(EventDef.Chip.EquipChip, self, self.OnEquipChip)
  EventSystem.RemoveListenerNew(EventDef.Chip.LockChip, self, self.OnLockChip)
  EventSystem.RemoveListenerNew(EventDef.Chip.MigrateChip, self, self.OnMigrateChip)
  EventSystem.RemoveListenerNew(EventDef.Chip.UnEquipChip, self, self.OnUnEquipChip)
  EventSystem.RemoveListenerNew(EventDef.Chip.UpgradeChip, self, self.OnUpgradeChip)
  EventSystem.RemoveListenerNew(EventDef.Chip.UpdateChipEquipSlot, self, self.OnUpdateChipEquipSlot)
  EventSystem.RemoveListenerNew(EventDef.Chip.UpdateEquipedChipDetail, self, self.OnUpdateEquipedChipDetail)
  EventSystem.RemoveListenerNew(EventDef.WSMessage.pushNewChip, self, self.OnResourceUpdate)
  self.Super.OnShutdown(self)
end
function ChipViewModel:UpdateCurHeroId(HeroId)
  self.CurHeroId = HeroId
end
function ChipViewModel:SelectSlot(Slot)
  if self.CurSelectModeIdx == Slot then
    return
  end
  if Slot < 1 then
    return
  end
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  local num = 0
  if tbChipSlot then
    num = #tbChipSlot
  end
  if Slot > num then
    return
  end
  self.CurSelectModeIdx = Slot
  if self:GetFirstView() then
    self:GetFirstView():UpdateSlotInfo(Slot)
  end
  self:OnGetHeroChipBag()
  self:OnUpdateLeftAndRightRedDot()
end
function ChipViewModel:RequestGetHeroChipBag()
  ChipHandler.RequestGetHeroChipBag()
end
function ChipViewModel:RequestGetChipDetail(ChipIDList, Callback, bIsShowLoading)
  ChipHandler.RequestGetChipDetail(ChipIDList, Callback, bIsShowLoading)
end
function ChipViewModel:RequestGetChipListByAttrIDs(MainAttrIDs, SubAttrIDs, Callback)
  return ChipHandler.RequestGetChipListByAttrIDs(MainAttrIDs, SubAttrIDs, Callback)
end
function ChipViewModel:RequestEquipChip(ChipBagsItemData, equipChipData, bRightMouseBtnClick)
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  local heroName = ""
  if tbHeroMonster and tbHeroMonster[ChipBagsItemData.Chip.bindHeroID] and tbHeroMonster[ChipBagsItemData.Chip.bindHeroID].Name then
    heroName = tbHeroMonster[ChipBagsItemData.Chip.bindHeroID].Name
  end
  if equipChipData then
    if ChipBagsItemData.Chip.equipHeroID > 0 then
      if ChipBagsItemData.Chip.equipHeroID == self.CurHeroId and ChipBagsItemData.Chip.id == equipChipData.Chip.id then
        if bRightMouseBtnClick then
          ChipHandler.RequestUnEquipChip(self.CurHeroId, equipChipData.TbChipData.Slot)
        end
      elseif ChipBagsItemData.Chip.equipHeroID ~= self.CurHeroId and not bRightMouseBtnClick then
        if ChipBagsItemData.Chip.bindHeroID > 0 and ChipBagsItemData.Chip.bindHeroID ~= self.CurHeroId then
          ShowWaveWindow(1183, {heroName})
          return
        end
        local bIsMutex, mutexChipTbData, mutexInscription = self:CheckInscriptionMutex(ChipBagsItemData, equipChipData)
        if bIsMutex then
          local desc = self:GetInscriptionDesc(mutexInscription)
          local slotName = self:GetSlotName(mutexChipTbData.Slot)
          local waveWindowParam = UE.FWaveWindowParam()
          waveWindowParam.StringParam0 = desc
          ShowWaveWindowWithDelegate(1187, {slotName}, nil, nil, waveWindowParam)
          return
        end
        if ChipBagsItemData.Chip.equipHeroID > 0 then
          local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
          local heroName = ""
          if tbHeroMonster and tbHeroMonster[ChipBagsItemData.Chip.equipHeroID] then
            heroName = tbHeroMonster[ChipBagsItemData.Chip.equipHeroID].Name
          end
          local waveWindowParam = UE.FWaveWindowParam()
          waveWindowParam.StringParam0 = ChipBagsItemData.Chip.id
          local obj = self
          ShowWaveWindowWithDelegate(1184, {heroName}, {
            GameInstance,
            function()
              if not obj then
                return
              end
              local bNeedConfirmOnlyInscription = obj:CheckConfirmOnlyInscription(ChipBagsItemData, equipChipData)
              if bNeedConfirmOnlyInscription then
                ShowWaveWindowWithDelegate(1186, {}, {
                  GameInstance,
                  function()
                    ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, obj.CurHeroId, equipChipData.TbChipData.Slot)
                  end
                }, nil)
              else
                ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, obj.CurHeroId, equipChipData.TbChipData.Slot)
              end
            end
          }, nil, waveWindowParam)
          return
        end
        local bNeedConfirmOnlyInscription = self:CheckConfirmOnlyInscription(ChipBagsItemData, equipChipData)
        if bNeedConfirmOnlyInscription then
          ShowWaveWindowWithDelegate(1186, {}, {
            GameInstance,
            function()
              ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, self.CurHeroId, equipChipData.TbChipData.Slot)
            end
          }, nil)
          return
        end
        ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, self.CurHeroId, equipChipData.TbChipData.Slot)
      end
    elseif not bRightMouseBtnClick then
      if ChipBagsItemData.Chip.bindHeroID > 0 and ChipBagsItemData.Chip.bindHeroID ~= self.CurHeroId then
        ShowWaveWindow(1183, {heroName})
        return
      end
      local bIsMutex, mutexChipTbData, mutexInscription = self:CheckInscriptionMutex(ChipBagsItemData, equipChipData)
      if bIsMutex then
        local desc = self:GetInscriptionDesc(mutexInscription)
        local slotName = self:GetSlotName(mutexChipTbData.Slot)
        local waveWindowParam = UE.FWaveWindowParam()
        waveWindowParam.StringParam0 = desc
        ShowWaveWindowWithDelegate(1187, {slotName}, nil, nil, waveWindowParam)
        return
      end
      local bNeedConfirmOnlyInscription = self:CheckConfirmOnlyInscription(ChipBagsItemData, equipChipData)
      if bNeedConfirmOnlyInscription then
        ShowWaveWindowWithDelegate(1186, {}, {
          GameInstance,
          function()
            ChipHandler.RequestEquipChip(ChipBagsItemData.Chip.id, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
          end
        }, nil)
        return
      end
      ChipHandler.RequestEquipChip(ChipBagsItemData.Chip.id, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
    end
  elseif not bRightMouseBtnClick then
    if ChipBagsItemData.Chip.bindHeroID > 0 and ChipBagsItemData.Chip.bindHeroID ~= self.CurHeroId then
      ShowWaveWindow(1183, {heroName})
      return
    end
    local bIsMutex, mutexChipTbData, mutexInscription = self:CheckInscriptionMutex(ChipBagsItemData, equipChipData)
    if bIsMutex then
      local desc = self:GetInscriptionDesc(mutexInscription)
      local slotName = self:GetSlotName(mutexChipTbData.Slot)
      local waveWindowParam = UE.FWaveWindowParam()
      waveWindowParam.StringParam0 = desc
      ShowWaveWindowWithDelegate(1187, {slotName}, nil, nil, waveWindowParam)
      return
    end
    if ChipBagsItemData.Chip.equipHeroID > 0 then
      if ChipBagsItemData.Chip.equipHeroID > 0 then
        local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
        local heroName = ""
        if tbHeroMonster and tbHeroMonster[ChipBagsItemData.Chip.equipHeroID] then
          heroName = tbHeroMonster[ChipBagsItemData.Chip.equipHeroID].Name
        end
        local waveWindowParam = UE.FWaveWindowParam()
        waveWindowParam.StringParam0 = ChipBagsItemData.Chip.id
        ShowWaveWindowWithDelegate(1184, {heroName}, {
          GameInstance,
          function()
            local bNeedConfirmOnlyInscription = self:CheckConfirmOnlyInscription(ChipBagsItemData)
            if bNeedConfirmOnlyInscription then
              ShowWaveWindowWithDelegate(1186, {}, {
                GameInstance,
                function()
                  ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
                end
              }, nil)
            else
              ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
            end
          end
        }, nil, waveWindowParam)
        return
      end
      local bNeedConfirmOnlyInscription = self:CheckConfirmOnlyInscription(ChipBagsItemData)
      if bNeedConfirmOnlyInscription then
        ShowWaveWindowWithDelegate(1186, {}, {
          GameInstance,
          function()
            ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
          end
        }, nil)
        return
      end
      ChipHandler.RequestMigrateChip(ChipBagsItemData.Chip.equipHeroID, ChipBagsItemData.TbChipData.Slot, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
    else
      local bIsMutex, mutexChipTbData, mutexInscription = self:CheckInscriptionMutex(ChipBagsItemData, equipChipData)
      if bIsMutex then
        local desc = self:GetInscriptionDesc(mutexInscription)
        local slotName = self:GetSlotName(mutexChipTbData.Slot)
        local waveWindowParam = UE.FWaveWindowParam()
        waveWindowParam.StringParam0 = desc
        ShowWaveWindowWithDelegate(1187, {slotName}, nil, nil, waveWindowParam)
        return
      end
      local bNeedConfirmOnlyInscription = self:CheckConfirmOnlyInscription(ChipBagsItemData)
      if bNeedConfirmOnlyInscription then
        ShowWaveWindowWithDelegate(1186, {}, {
          GameInstance,
          function()
            ChipHandler.RequestEquipChip(ChipBagsItemData.Chip.id, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
          end
        }, nil)
        return
      end
      ChipHandler.RequestEquipChip(ChipBagsItemData.Chip.id, self.CurHeroId, ChipBagsItemData.TbChipData.Slot)
    end
  end
end
function ChipViewModel:RequestUpgradeChip(EatList, UUID, EatChipUpgradeMatList)
  ChipHandler.RequestUpgradeChip(EatList, UUID, EatChipUpgradeMatList)
end
function ChipViewModel:RequestLockChip(ChipBagItemData)
  if ChipBagItemData.Chip.state == EChipState.Normal then
    self.bCanRefreshChipAttrTips = false
    ChipHandler.RequestLockChip(ChipBagItemData.Chip.id, function()
      self.bCanRefreshChipAttrTips = true
    end, function()
      self.bCanRefreshChipAttrTips = true
    end)
  elseif ChipBagItemData.Chip.state == EChipState.Lock then
    self.bCanRefreshChipAttrTips = false
    ChipHandler.RequestCancelOrDiscard(ChipBagItemData.Chip.id, function()
      self.bCanRefreshChipAttrTips = true
    end, function()
      self.bCanRefreshChipAttrTips = true
    end)
  end
end
function ChipViewModel:RequestDiscardChip(ChipBagItemData)
  if ChipBagItemData.Chip.state == EChipState.Normal then
    if ChipBagItemData.Chip.equipHeroID > 0 then
      ShowWaveWindow(1185)
      return
    end
    self.bCanRefreshChipAttrTips = false
    ChipHandler.RequestDiscardChip(ChipBagItemData.Chip.id, function()
      self.bCanRefreshChipAttrTips = true
    end, function()
      self.bCanRefreshChipAttrTips = true
    end)
  elseif ChipBagItemData.Chip.state == EChipState.Discard then
    self.bCanRefreshChipAttrTips = false
    ChipHandler.RequestCancelOrDiscard(ChipBagItemData.Chip.id, function()
      self.bCanRefreshChipAttrTips = true
    end, function()
      self.bCanRefreshChipAttrTips = true
    end)
  end
end
function ChipViewModel:ConfirmNormalFilter(CurFilterData)
  ChipData.NormalFilterData = DeepCopy(CurFilterData)
  if self:GetFirstView() then
    self:GetFirstView():UpdateFilterStatus()
  end
  self:OnGetHeroChipBag()
end
function ChipViewModel:ResetNormalFilter(bNotRefreshBag)
  ChipData.NormalFilterData = DeepCopy(ChipData.DefaultNormalFilterData)
  if self:GetFirstView() then
    self:GetFirstView():UpdateFilterStatus()
  end
  if not bNotRefreshBag then
    self:OnGetHeroChipBag()
  end
end
function ChipViewModel:ConfirmStrengthFilter(CurFilterData)
  ChipData.StrengthFilterData = DeepCopy(CurFilterData)
  if self:GetFirstView() then
    self:GetFirstView():UpdateStrengthFilterStatus()
  end
  self:OnGetHeroChipBag()
end
function ChipViewModel:ResetStrengthFilter(bNotRefreshBag)
  ChipData.StrengthFilterData = DeepCopy(ChipData.DefaultStrengthFilterData)
  if self:GetFirstView() then
    self:GetFirstView():UpdateStrengthFilterStatus()
  end
  if not bNotRefreshBag then
    self:OnGetHeroChipBag()
  end
end
function ChipViewModel:OnlyCheckDiscard(bIsCheck, bDontRefreshBagList)
  ChipData.StrengthOnlyCheckDiscard = bIsCheck
  if self:GetFirstView() and not bDontRefreshBagList then
    self:GetFirstView():UpdateStrengthBagList()
  end
end
function ChipViewModel:OnGetHeroChipBag()
  if self:GetFirstView() then
    self:GetFirstView():UpdateChipBagList(self.CurSelectModeIdx)
    self:GetFirstView():UpdateSlotInfo(self.CurSelectModeIdx)
    self:UpdateChipAttrTips()
  end
end
function ChipViewModel:OnCancelOrDiscard()
  if self:GetFirstView() then
    self:GetFirstView():UpdateChipListKeepSort(self.CurSelectModeIdx)
  end
end
function ChipViewModel:OnDiscardChip(Id)
  if self:GetFirstView() then
    self:GetFirstView():UpdateChipListKeepSort(self.CurSelectModeIdx, true)
  end
end
function ChipViewModel:OnEquipChip(ChipId, HeroId, Slot, UnEquipedChipId)
  if self:GetFirstView() then
    self:GetFirstView():UpdateChipBagList(self.CurSelectModeIdx)
    self:UpdateChipAttrTips(nil, nil, HeroId, Slot, UnEquipedChipId)
  end
  ShowWaveWindow(1180)
end
function ChipViewModel:OnLockChip(Id)
  if self:GetFirstView() then
    self:GetFirstView():UpdateStrength(Id)
    self:GetFirstView():UpdateChipListKeepSort(self.CurSelectModeIdx)
  end
end
function ChipViewModel:OnMigrateChip(HeroId, Slot, TargetHeroId, TargetSlot, UnEquipedChipId)
  if self:GetFirstView() then
    self:GetFirstView():UpdateChipBagList(self.CurSelectModeIdx)
    self:UpdateChipAttrTips(nil, nil, TargetHeroId, TargetSlot, UnEquipedChipId)
  end
  ShowWaveWindow(1180)
end
function ChipViewModel:OnUnEquipChip()
  if self:GetFirstView() then
    self:GetFirstView():UpdateChipBagList(self.CurSelectModeIdx)
    self:UpdateChipAttrTips()
  end
end
function ChipViewModel:OnUpgradeChip(ChipId, oldMainAttrGrowth, oldSubAttr, OldLv)
  if self:GetFirstView() then
    local chipBagData = self:GetChipBagDataByUUIDRef(ChipId)
    self:GetFirstView():UpdateChipBagList(self.CurSelectModeIdx)
    self:GetFirstView():UpdateStrength(nil, oldSubAttr)
    self:GetFirstView():OnUpgradeChip(OldLv, chipBagData.Chip.level)
    local bNeddShowUpgrade = false
    if #chipBagData.Chip.subAttr > #oldSubAttr then
      bNeddShowUpgrade = true
    else
      for i, v in ipairs(chipBagData.Chip.subAttr) do
        for iOld, vOld in ipairs(oldSubAttr) do
          if vOld.attrID == v.attrID and v.value > vOld.value then
            bNeddShowUpgrade = true
            break
          end
        end
        if bNeddShowUpgrade then
          break
        end
      end
    end
    if bNeddShowUpgrade then
      local wnd = ShowWaveWindowWithDelegate(1161, {}, nil, nil)
      if wnd then
        wnd:InitUpgradeSuccConfirm(oldMainAttrGrowth, oldSubAttr, ChipId)
      end
    end
    self:UpdateChipAttrTips()
  end
end
function ChipViewModel:OnUpdateChipEquipSlot(HeroId, EquipSlot)
  if HeroId and self.CurHeroId ~= HeroId then
    return
  end
  if self:GetFirstView() then
    self:GetFirstView():UpdateEquipChipList(ChipData:GetEquipedChipListByHeroId(self.CurHeroId), EquipSlot)
  end
end
function ChipViewModel:OnUpdateEquipedChipDetail(equipedChipIDs)
  ChipHandler.RequestGetChipDetail(equipedChipIDs, nil, true)
end
function ChipViewModel:OnResourceUpdate(JsonStr)
  local bNeedRequest = false
  local JsonTable = rapidjson.decode(JsonStr)
  for i, v in ipairs(JsonTable.chips) do
    local chipBagData = ChipData:CreateChipBagItemData(tostring(v.resourceid), {}, {}, v.bindheroID, 0, v.inscription, nil, v.level, v.exp, v.state, v.uniqueid)
    ChipData.ChipBags[v.uniqueid] = chipBagData
    ChipData.ChipBags[v.uniqueid].Chip.id = tostring(v.uniqueid)
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResChip, tonumber(v.resourceid))
    if result then
      ChipData.ChipBags[v.uniqueid].TbChipData = row
    else
      error("ChipViewModel:OnResourceUpdate() error, can't find chip resource id: " .. v.resourceid)
    end
  end
  EventSystem.Invoke(EventDef.Chip.AddChip)
  EventSystem.Invoke(EventDef.Chip.UpdateChipEquipSlot)
end
function ChipViewModel:UpdateChipAttrTips(EquipChipBagsItemData, UnEquipCompareChipBagsItemData, HeroId, Slot, UnEquipedChipId)
  if not self.bCanRefreshChipAttrTips then
    return
  end
  if not self:GetFirstView() then
    return
  end
  local chipOrderedMap = OrderedMap.New()
  local chipList = self:GetEquipedChipListByHeroId(self.CurHeroId)
  for k, v in pairs(chipList) do
    local attrId, mainAttrValue = self:GetMainAttrValueByChipBagItemData(v)
    if chipOrderedMap[attrId] then
      chipOrderedMap[attrId].Value = chipOrderedMap[attrId].Value + mainAttrValue
      if HeroId and HeroId == self.CurHeroId and v.TbChipData.Slot == Slot then
        if chipOrderedMap[attrId].ChangeAniState == EChipAttrAniChange.Normal then
          chipOrderedMap[attrId].ChangeAniState = EChipAttrAniChange.Add
        end
      elseif chipOrderedMap[attrId].ChangeAniState == EChipAttrAniChange.New then
        chipOrderedMap[attrId].ChangeAniState = EChipAttrAniChange.Add
      end
    else
      chipOrderedMap[attrId] = {
        Value = mainAttrValue,
        ChangeState = EChipAttrChange.Normal,
        attrID = attrId
      }
      if HeroId and HeroId == self.CurHeroId and v.TbChipData.Slot == Slot then
        chipOrderedMap[attrId].ChangeAniState = EChipAttrAniChange.New
      else
        chipOrderedMap[attrId].ChangeAniState = EChipAttrAniChange.Normal
      end
    end
    for i, vSubAttr in ipairs(v.Chip.subAttr) do
      if chipOrderedMap[vSubAttr.attrID] then
        chipOrderedMap[vSubAttr.attrID].Value = chipOrderedMap[vSubAttr.attrID].Value + vSubAttr.value
        if HeroId and HeroId == self.CurHeroId and v.TbChipData.Slot == Slot then
          if chipOrderedMap[vSubAttr.attrID].ChangeAniState == EChipAttrAniChange.Normal then
            chipOrderedMap[vSubAttr.attrID].ChangeAniState = EChipAttrAniChange.Add
          end
        elseif chipOrderedMap[vSubAttr.attrID].ChangeAniState == EChipAttrAniChange.New then
          chipOrderedMap[vSubAttr.attrID].ChangeAniState = EChipAttrAniChange.Add
        end
      else
        chipOrderedMap[vSubAttr.attrID] = {
          Value = vSubAttr.value,
          ChangeState = EChipAttrChange.Normal,
          attrID = vSubAttr.attrID
        }
        if HeroId and HeroId == self.CurHeroId and v.TbChipData.Slot == Slot then
          chipOrderedMap[vSubAttr.attrID].ChangeAniState = EChipAttrAniChange.New
        else
          chipOrderedMap[vSubAttr.attrID].ChangeAniState = EChipAttrAniChange.Normal
        end
      end
    end
  end
  if UnEquipedChipId then
    local unEquipedChipData = self:GetChipBagDataByUUIDRef(UnEquipedChipId)
    if unEquipedChipData then
      local attrId, mainAttrValue = self:GetMainAttrValueByChipBagItemData(unEquipedChipData)
      if chipOrderedMap[attrId] and chipOrderedMap[attrId].ChangeAniState == EChipAttrAniChange.New then
        chipOrderedMap[attrId].ChangeAniState = EChipAttrAniChange.Add
      end
      for i, vSubAttr in ipairs(unEquipedChipData.Chip.subAttr) do
        if chipOrderedMap[vSubAttr.attrID] and chipOrderedMap[vSubAttr.attrID].ChangeAniState == EChipAttrAniChange.New then
          chipOrderedMap[vSubAttr.attrID].ChangeAniState = EChipAttrAniChange.Add
        end
      end
    end
  end
  local compareChipOrderMap = OrderedMap.New()
  if EquipChipBagsItemData then
    local attrId, mainAttrValue = self:GetMainAttrValueByChipBagItemData(EquipChipBagsItemData)
    if compareChipOrderMap[attrId] then
      compareChipOrderMap[attrId].Value = compareChipOrderMap[attrId].Value + mainAttrValue
      compareChipOrderMap[attrId].ChangeState = EChipAttrChange.Add
    else
      compareChipOrderMap[attrId] = {
        Value = mainAttrValue,
        ChangeState = EChipAttrChange.Add,
        attrID = attrId
      }
    end
    for i, vSubAttr in ipairs(EquipChipBagsItemData.Chip.subAttr) do
      if compareChipOrderMap[vSubAttr.attrID] then
        local oldValue = 0
        if compareChipOrderMap[vSubAttr.attrID] then
          oldValue = compareChipOrderMap[vSubAttr.attrID].Value
        end
        compareChipOrderMap[vSubAttr.attrID].Value = oldValue + vSubAttr.value
      else
        compareChipOrderMap[vSubAttr.attrID] = {
          Value = vSubAttr.value,
          ChangeState = EChipAttrChange.Add,
          attrID = vSubAttr.attrID
        }
      end
    end
    if UnEquipCompareChipBagsItemData then
      local attrId, mainAttrValue = self:GetMainAttrValueByChipBagItemData(UnEquipCompareChipBagsItemData)
      if compareChipOrderMap[attrId] then
        compareChipOrderMap[attrId].Value = compareChipOrderMap[attrId].Value - mainAttrValue
        compareChipOrderMap[attrId].ChangeState = EChipAttrChange.Minus
      else
        compareChipOrderMap[attrId] = {
          Value = -mainAttrValue,
          ChangeState = EChipAttrChange.Minus,
          attrID = attrId
        }
      end
      for i, vSubAttr in ipairs(UnEquipCompareChipBagsItemData.Chip.subAttr) do
        if compareChipOrderMap[vSubAttr.attrID] then
          local oldValue = 0
          if compareChipOrderMap[vSubAttr.attrID] then
            oldValue = compareChipOrderMap[vSubAttr.attrID].Value
          end
          compareChipOrderMap[vSubAttr.attrID].Value = oldValue - vSubAttr.value
        else
          compareChipOrderMap[vSubAttr.attrID] = {
            Value = -vSubAttr.value,
            ChangeState = EChipAttrChange.Minus,
            attrID = vSubAttr.attrID
          }
        end
      end
    end
  end
  for k, v in pairs(compareChipOrderMap) do
    if v.Value < 0 then
      v.ChangeState = EChipAttrChange.Minus
    elseif v.Value > 0 then
      v.ChangeState = EChipAttrChange.Add
    else
      v.ChangeState = EChipAttrChange.Normal
    end
    if chipOrderedMap[k] then
      chipOrderedMap[k].Value = chipOrderedMap[k].Value + v.Value
      chipOrderedMap[k].ChangeState = v.ChangeState
    else
      chipOrderedMap[k] = {
        Value = v.Value,
        ChangeState = v.ChangeState,
        attrID = k
      }
    end
  end
  chipOrderedMap:Sort(function(A, B)
    return A.attrID > B.attrID
  end)
  self:GetFirstView():UpdateAttrTips(chipOrderedMap)
end
function ChipViewModel:GetNormalFilterDataRef()
  return ChipData.NormalFilterData
end
function ChipViewModel:GetStrengthFilterDataRef()
  return ChipData.StrengthFilterData
end
function ChipViewModel:CheckSlotIsUnLock(Slot)
  return ChipData:CheckSlotIsUnLock(Slot)
end
function ChipViewModel:GetEquipedChipListByHeroId(HeroId)
  return ChipData:GetEquipedChipListByHeroId(HeroId)
end
function ChipViewModel:GetEquipedSlotToChipByHeroId(HeroId)
  return ChipData:GetEquipedSlotToChipByHeroId(HeroId)
end
function ChipViewModel:GetMaxMainAttrFilterNum()
  return ChipData.MaxMainAttrFilterNum
end
function ChipViewModel:FilterNormalChipBagList(bGetFromCache, Callback)
  if self.CacheChipList and bGetFromCache then
    return self.CacheChipList
  end
  local filterMainAttrIds = {}
  local filterSubAttrIds = {}
  local bMainAttrFilter = not table.IsEmpty(ChipData.NormalFilterData.MainAttrFilter)
  local bSubAttrFilter = not table.IsEmpty(ChipData.NormalFilterData.SubAttrFilter)
  local filterFunc = function()
    local chipList = {}
    local chipBags = ChipData.ChipBags
    for k, v in pairs(chipBags) do
      if v.TbChipData.Slot == self.CurSelectModeIdx and self:CheckContainMainAttr(v) and self:CheckContainSubAttr(v) then
        table.insert(chipList, v)
      end
    end
    local sortSubAttrIdList = {}
    if bSubAttrFilter then
      for k, v in pairs(ChipData.NormalFilterData.SubAttrFilter) do
        sortSubAttrIdList[v] = k
      end
    end
    table.sort(chipList, function(A, B)
      if (A.Chip.state == EChipState.Discard or B.Chip.state == EChipState.Discard) and A.Chip.state ~= B.Chip.state then
        return B.Chip.state == EChipState.Discard
      end
      if bMainAttrFilter then
        local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
        local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
        if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
          return bBNotFit
        end
        if A.TbChipData.AttrID == B.TbChipData.AttrID then
          local AMainAttrValue = self:GetMainAttrValueByChipBagItemData(A)
          local BMainAttrValue = self:GetMainAttrValueByChipBagItemData(B)
          if AMainAttrValue ~= BMainAttrValue then
            local resultAttrOp, rowAttrOp = GetRowData(DT.DT_AttributeModifyOp, tostring(v))
            if resultAttrOp and rowAttrOp.IsInverseRatio then
              return AMainAttrValue < BMainAttrValue
            else
              return AMainAttrValue > BMainAttrValue
            end
          end
        end
        local ARare = self:GetChipRare(A)
        local BRare = self:GetChipRare(B)
        if ARare ~= BRare then
          return ARare > BRare
        end
        local AAttrIdx = self:CheckMainAttrIdx(A)
        local BAttrIdx = self:CheckMainAttrIdx(B)
        if AAttrIdx ~= BAttrIdx then
          return AAttrIdx < BAttrIdx
        end
      end
      if bSubAttrFilter then
        local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
        local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
        if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
          return bBNotFit
        end
        for i, v in ipairs(sortSubAttrIdList) do
          local ASubAttrValue = self:GetSubValueByAttrId(A, v)
          local BSubAttrValue = self:GetSubValueByAttrId(B, v)
          if ASubAttrValue ~= BSubAttrValue then
            local resultAttrOp, rowAttrOp = GetRowData(DT.DT_AttributeModifyOp, tostring(v))
            if resultAttrOp and rowAttrOp.IsInverseRatio then
              return ASubAttrValue < BSubAttrValue
            else
              return ASubAttrValue > BSubAttrValue
            end
          end
        end
        local ARare = self:GetChipRare(A)
        local BRare = self:GetChipRare(B)
        if ARare ~= BRare then
          return ARare > BRare
        end
        if A.Chip.level ~= B.Chip.level then
          return A.Chip.level > B.Chip.level
        end
      end
      if ChipData.NormalFilterData.RuleFilter == EChipFilterRule.Acquisition then
        if ChipData.NormalFilterData.TypeFilter == EChipFilterType.Ascend then
          return tonumber(A.Chip.id) < tonumber(B.Chip.id)
        elseif ChipData.NormalFilterData.TypeFilter == EChipFilterType.Descend then
          return tonumber(A.Chip.id) > tonumber(B.Chip.id)
        end
      elseif ChipData.NormalFilterData.RuleFilter == EChipFilterRule.Level then
        local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
        local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
        if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
          return bBNotFit
        end
        if A.Chip.level ~= B.Chip.level then
          if ChipData.NormalFilterData.TypeFilter == EChipFilterType.Ascend then
            return A.Chip.level < B.Chip.level
          elseif ChipData.NormalFilterData.TypeFilter == EChipFilterType.Descend then
            return A.Chip.level > B.Chip.level
          end
        end
        local bAIsNew = self:GetIsNewByUUID(A.Chip.id)
        local bBIsNew = self:GetIsNewByUUID(B.Chip.id)
        if bAIsNew ~= bBIsNew then
          return bAIsNew
        end
        local ARare = self:GetChipRare(A)
        local BRare = self:GetChipRare(B)
        if ARare ~= BRare then
          return ARare > BRare
        end
        if (A.Chip.state == EChipState.Lock or B.Chip.state == EChipState.Lock) and A.Chip.state ~= B.Chip.state then
          return A.Chip.state == EChipState.Lock
        end
        return tonumber(A.Chip.id) > tonumber(B.Chip.id)
      elseif ChipData.NormalFilterData.RuleFilter == EChipFilterRule.Rarity then
        local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
        local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
        if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
          return bBNotFit
        end
        if tbGeneral and tbGeneral[tonumber(A.Chip.resourceID)] and tbGeneral[tonumber(B.Chip.resourceID)] then
          local AtbGeneralRare = tbGeneral[tonumber(A.Chip.resourceID)].Rare
          local BtbGeneralRare = tbGeneral[tonumber(B.Chip.resourceID)].Rare
          if not BtbGeneralRare or not AtbGeneralRare then
            print("FilterNormalChipBagList", tbGeneral[tonumber(A.Chip.resourceID)].Rare, tbGeneral[tonumber(B.Chip.resourceID)].Rare)
          end
          if AtbGeneralRare ~= BtbGeneralRare then
            if ChipData.NormalFilterData.TypeFilter == EChipFilterType.Ascend then
              return AtbGeneralRare < BtbGeneralRare
            elseif ChipData.NormalFilterData.TypeFilter == EChipFilterType.Descend then
              return AtbGeneralRare > BtbGeneralRare
            end
          end
        end
        local bAIsNew = self:GetIsNewByUUID(A.Chip.id)
        local bBIsNew = self:GetIsNewByUUID(B.Chip.id)
        if bAIsNew ~= bBIsNew then
          return bAIsNew
        end
        if A.Chip.level ~= B.Chip.level then
          return A.Chip.level > B.Chip.level
        end
        if (A.Chip.state == EChipState.Lock or B.Chip.state == EChipState.Lock) and A.Chip.state ~= B.Chip.state then
          return A.Chip.state == EChipState.Lock
        end
        return tonumber(A.Chip.id) > tonumber(B.Chip.id)
      end
      if tonumber(A.Chip.resourceID) ~= tonumber(B.Chip.resourceID) then
        return tonumber(A.Chip.resourceID) > tonumber(B.Chip.resourceID)
      end
      return tonumber(A.Chip.id) > tonumber(B.Chip.id)
    end)
    self.CacheChipList = chipList
    return chipList
  end
  if bMainAttrFilter then
    for k, v in pairs(ChipData.NormalFilterData.MainAttrFilter) do
      table.insert(filterMainAttrIds, tonumber(v))
    end
  end
  if bSubAttrFilter then
    for k, v in pairs(ChipData.NormalFilterData.SubAttrFilter) do
      table.insert(filterSubAttrIds, tonumber(v))
    end
  end
  if bMainAttrFilter or bSubAttrFilter then
    ChipHandler.RequestGetChipListByAttrIDs(filterMainAttrIds, filterSubAttrIds, function(ChipIDs)
      local chipList = filterFunc()
      if Callback then
        Callback(chipList)
      end
    end)
  else
    local chipList = filterFunc()
    if Callback then
      Callback(chipList)
    end
    return chipList
  end
end
function ChipViewModel:FilterStrengthChipBagOrderedMap(ChipBagItemData, Callback)
  local chipOrderedMap = OrderedMap.New()
  if not ChipBagItemData then
    return chipOrderedMap
  end
  local bMainAttrFilter = not table.IsEmpty(ChipData.StrengthFilterData.MainAttrFilter)
  local bSubAttrFilter = not table.IsEmpty(ChipData.StrengthFilterData.SubAttrFilter)
  local filterFunc = function()
    local chipBags = ChipData.ChipBags
    for k, v in pairs(chipBags) do
      if v.Chip.id ~= ChipBagItemData.Chip.id and self:CheckStrengthContainMainAttr(v) and self:CheckStrengthContainSubAttr(v) then
        if ChipData.StrengthOnlyCheckDiscard and v.Chip.state == EChipState.Discard then
          chipOrderedMap:Add(v.Chip.id, v)
        elseif not ChipData.StrengthOnlyCheckDiscard then
          chipOrderedMap:Add(v.Chip.id, v)
        end
      end
    end
    for i, v in ipairs(ChipData.ChipUpgradeMatList) do
      local chipBagItemData = ChipData:CreateChipBagItemDataByUpgradeMat(v.id, v.amount)
      chipOrderedMap:Add(v.id, chipBagItemData)
    end
    local sortSubAttrIdList = {}
    if bSubAttrFilter then
      for k, v in pairs(ChipData.StrengthFilterData.SubAttrFilter) do
        sortSubAttrIdList[v] = k
      end
    end
    chipOrderedMap:Sort(function(A, B)
      if A.Chip and B.Chip and (A.Chip.state == EChipState.Discard or B.Chip.state == EChipState.Discard) and A.Chip.state ~= B.Chip.state then
        return A.Chip.state == EChipState.Discard
      end
      local bCanEatA = self:CheckCanEatByChipBagData(A, ChipBagItemData)
      local bCanEatB = self:CheckCanEatByChipBagData(B, ChipBagItemData)
      if bCanEatA ~= bCanEatB then
        return bCanEatA
      end
      if (A.ChipUpgradeMat or B.ChipUpgradeMat) and A.ChipUpgradeMat ~= B.ChipUpgradeMat then
        return A.ChipUpgradeMat
      end
      if bMainAttrFilter and A.Chip and B.Chip then
        local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
        local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
        if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
          return bBNotFit
        end
        if A.TbChipData.AttrID == B.TbChipData.AttrID then
          local AMainAttrValue = self:GetMainAttrValueByChipBagItemData(A)
          local BMainAttrValue = self:GetMainAttrValueByChipBagItemData(B)
          if AMainAttrValue ~= BMainAttrValue then
            local resultAttrOp, rowAttrOp = GetRowData(DT.DT_AttributeModifyOp, tostring(A.TbChipData.AttrID))
            if resultAttrOp and rowAttrOp.IsInverseRatio then
              return AMainAttrValue < BMainAttrValue
            else
              return AMainAttrValue > BMainAttrValue
            end
          end
        end
        local ARare = self:GetChipRare(A)
        local BRare = self:GetChipRare(B)
        if ARare ~= BRare then
          return ARare < BRare
        end
        local AAttrIdx = self:CheckStrengthMainAttrIdx(A)
        local BAttrIdx = self:CheckStrengthMainAttrIdx(B)
        if AAttrIdx ~= BAttrIdx then
          return AAttrIdx < BAttrIdx
        end
      end
      if bSubAttrFilter and A.Chip and B.Chip then
        local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
        local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
        if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
          return bBNotFit
        end
        for i, v in ipairs(sortSubAttrIdList) do
          local ASubAttrValue = self:GetSubValueByAttrId(A, v)
          local BSubAttrValue = self:GetSubValueByAttrId(B, v)
          if ASubAttrValue ~= BSubAttrValue then
            local resultAttrOp, rowAttrOp = GetRowData(DT.DT_AttributeModifyOp, tostring(v))
            if resultAttrOp and rowAttrOp.IsInverseRatio then
              return ASubAttrValue < BSubAttrValue
            else
              return ASubAttrValue > BSubAttrValue
            end
          end
        end
        local ARare = self:GetChipRare(A)
        local BRare = self:GetChipRare(B)
        if ARare ~= BRare then
          return ARare < BRare
        end
        if A.Chip.level ~= B.Chip.level then
          return A.Chip.level < B.Chip.level
        end
      end
      if ChipData.StrengthFilterData.RuleFilter == EChipFilterRule.Exp then
        local AEatExp = self:GetEatExpByChipBagData(A)
        local BEatExp = self:GetEatExpByChipBagData(B)
        if AEatExp ~= BEatExp then
          if ChipData.StrengthFilterData.TypeFilter == EChipFilterType.Ascend then
            return AEatExp < BEatExp
          elseif ChipData.StrengthFilterData.TypeFilter == EChipFilterType.Descend then
            return AEatExp > BEatExp
          end
        end
        if A.Chip and B.Chip then
          local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
          local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
          if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
            return bANotFit
          end
          return tonumber(A.Chip.id) < tonumber(B.Chip.id)
        elseif A.ChipUpgradeMat and B.ChipUpgradeMat then
          local ARare = self:GetChipRare(A)
          local BRare = self:GetChipRare(B)
          if ARare ~= BRare then
            return ARare < BRare
          end
        end
      elseif ChipData.StrengthFilterData.RuleFilter == EChipFilterRule.Level then
        if A.Chip.level ~= B.Chip.level then
          if ChipData.StrengthFilterData.TypeFilter == EChipFilterType.Ascend then
            return A.Chip.level < B.Chip.level
          elseif ChipData.StrengthFilterData.TypeFilter == EChipFilterType.Descend then
            return A.Chip.level > B.Chip.level
          end
        end
        local ARare = self:GetChipRare(A)
        local BRare = self:GetChipRare(B)
        if ARare ~= BRare then
          return ARare < BRare
        end
        if A.Chip and B.Chip then
          local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
          local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
          if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
            return bANotFit
          end
          return tonumber(A.Chip.id) < tonumber(B.Chip.id)
        end
      elseif ChipData.StrengthFilterData.RuleFilter == EChipFilterRule.Rarity then
        if A.Chip and B.Chip and A.Chip.level ~= B.Chip.level then
          return A.Chip.level < B.Chip.level
        end
        local AtbGeneralRare = self:GetChipRare(A)
        local BtbGeneralRare = self:GetChipRare(B)
        if AtbGeneralRare ~= BtbGeneralRare then
          if ChipData.StrengthFilterData.TypeFilter == EChipFilterType.Ascend then
            return AtbGeneralRare < BtbGeneralRare
          elseif ChipData.StrengthFilterData.TypeFilter == EChipFilterType.Descend then
            return AtbGeneralRare > BtbGeneralRare
          end
        end
        if A.Chip and B.Chip then
          local bANotFit = A.Chip.bindHeroID > 0 and A.Chip.bindHeroID ~= self.CurHeroId
          local bBNotFit = B.Chip.bindHeroID > 0 and B.Chip.bindHeroID ~= self.CurHeroId
          if (bANotFit or bBNotFit) and bANotFit ~= bBNotFit then
            return bANotFit
          end
          return tonumber(A.Chip.id) < tonumber(B.Chip.id)
        end
      end
      if A.Chip and B.Chip then
        if tonumber(A.Chip.resourceID) ~= tonumber(B.Chip.resourceID) then
          return tonumber(A.Chip.resourceID) > tonumber(B.Chip.resourceID)
        end
        return tonumber(A.Chip.id) < tonumber(B.Chip.id)
      elseif A.ChipUpgradeMat and B.ChipUpgradeMat then
        if tonumber(A.ChipUpgradeMat.ResID) ~= tonumber(B.ChipUpgradeMat.ResID) then
          return tonumber(A.ChipUpgradeMat.ResID) > tonumber(B.ChipUpgradeMat.ResID)
        end
        if A.ChipUpgradeMat.amount ~= B.ChipUpgradeMat.amount then
          return A.ChipUpgradeMat.amount < B.ChipUpgradeMat.amount
        end
      end
      return false
    end)
    return chipOrderedMap
  end
  local filterMainAttrIds = {}
  local filterSubAttrIds = {}
  if bMainAttrFilter then
    for k, v in pairs(ChipData.NormalFilterData.MainAttrFilter) do
      table.insert(filterMainAttrIds, tonumber(v))
    end
  end
  if bSubAttrFilter then
    for k, v in pairs(ChipData.NormalFilterData.SubAttrFilter) do
      table.insert(filterSubAttrIds, tonumber(v))
    end
  end
  if bMainAttrFilter or bSubAttrFilter then
    ChipHandler.RequestGetChipListByAttrIDs(filterMainAttrIds, filterSubAttrIds, function(ChipIDs)
      if table.IsEmpty(ChipIDs) then
        local chipList = filterFunc()
        if Callback then
          Callback(chipList)
        end
        return
      end
      ChipHandler.RequestGetChipDetail(ChipIDs, function(ChipDetailList)
        local chipList = filterFunc()
        if Callback then
          Callback(chipList)
        end
      end, true)
    end)
  else
    local chipList = filterFunc()
    if Callback then
      Callback(chipList)
    end
    return chipList
  end
end
function ChipViewModel:CheckCanEatByChipBagData(beEatedChipBagData, ChipBagData)
  if not beEatedChipBagData then
    print("CheckCanEatByChipBagData beEatedChipBagData is nil")
    return false
  end
  if beEatedChipBagData.Chip then
    print("CheckCanEatByChipBagData beEatedChipBagData.Chip.state", beEatedChipBagData.Chip.state)
    return beEatedChipBagData.Chip.state ~= EChipState.Lock
  end
  if not ChipBagData or not ChipBagData.Chip then
    print("CheckCanEatByChipBagData ChipBagData or ChipBagData.Chip is nil")
    return false
  end
  if not beEatedChipBagData.ChipUpgradeMat then
    print("CheckCanEatByChipBagData ChipUpgradeMat is nil")
    return false
  end
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceChipUpgradeMaterial, tonumber(beEatedChipBagData.ChipUpgradeMat.ResID))
  if not result then
    print("CheckCanEatByChipBagData TBResourceChipUpgradeMaterial is no ResID", beEatedChipBagData.ChipUpgradeMat.ResID)
    return false
  end
  for i, v in ipairs(row.CanEatByChipType) do
    if v - 1 == self:GetTypeByChipBagItem(ChipBagData) then
      return true
    end
  end
  return false
end
function ChipViewModel:GetTypeByChipBagItem(ChipBagItemData)
  if not ChipBagItemData then
    return -1
  end
  if ChipBagItemData.TbChipData then
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBChipSlots, ChipBagItemData.TbChipData.Slot)
    if result then
      return row.Type
    end
  end
  return -1
end
function ChipViewModel:GetChipBagDataByUUIDRef(UUID)
  return ChipData.ChipBags[UUID]
end
function ChipViewModel:GetEatExpByChipBagData(ChipBagData, LevelOffset, UseMatNum)
  if not ChipBagData then
    return 0
  end
  local rare = UE.ERGItemRarity.EIR_Excellent
  local eatExp = 0
  local resID = -1
  if ChipBagData.Chip then
    resID = ChipBagData.Chip.resourceID
    if tbGeneral and tbGeneral[tonumber(resID)] then
      rare = tbGeneral[tonumber(resID)].Rare
    end
    local levelOffset = LevelOffset or 0
    levelOffset = math.clamp(levelOffset, 0, ChipData:GetChipMaxLvByRarity(rare) - ChipBagData.Chip.level)
    if tbChipLevelUp and tbChipLevelUp[ChipBagData.Chip.level + levelOffset] and tbChipLevelUp[ChipBagData.Chip.level + levelOffset].eatExp then
      for i, v in ipairs(tbChipLevelUp[ChipBagData.Chip.level + levelOffset].eatExp) do
        if v.key == rare then
          eatExp = v.value
          break
        end
      end
    end
  elseif ChipBagData.ChipUpgradeMat then
    resID = ChipBagData.ChipUpgradeMat.ResID
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceChipUpgradeMaterial, tonumber(resID))
    if result then
      local useMatNum = UseMatNum or 1
      eatExp = row.Exp * useMatNum
    end
  end
  print("ChipViewModel:GetEatExpByChipBagData", resID, eatExp)
  return eatExp
end
function ChipViewModel:GetCurLvUpExpByChipBagData(ChipBagData, LevelOffset)
  if not ChipBagData then
    return 0
  end
  local rare = UE.ERGItemRarity.EIR_Excellent
  local upgradeExp = 0
  if tbGeneral and tbGeneral[tonumber(ChipBagData.Chip.resourceID)] then
    rare = tbGeneral[tonumber(ChipBagData.Chip.resourceID)].Rare
  end
  local levelOffset = LevelOffset or 0
  levelOffset = math.clamp(levelOffset, 0, ChipData:GetChipMaxLvByRarity(rare) - ChipBagData.Chip.level)
  if tbChipLevelUp and tbChipLevelUp[ChipBagData.Chip.level + levelOffset] and tbChipLevelUp[ChipBagData.Chip.level + levelOffset].upgradeExp then
    for i, v in ipairs(tbChipLevelUp[ChipBagData.Chip.level + levelOffset].upgradeExp) do
      if v.key == rare then
        upgradeExp = v.value
        break
      end
    end
  end
  return upgradeExp
end
function ChipViewModel:GetNewLvByChipBagData(ChipBagData, NewExp)
  local oldLevel = ChipBagData.Chip.level
  local newLevel = oldLevel
  for i = 1, #tbChipLevelUp - oldLevel do
    local upgradeExp = self:GetCurLvUpExpByChipBagData(ChipBagData, i)
    if NewExp < upgradeExp then
      break
    end
    newLevel = oldLevel + i
  end
  local rare = UE.ERGItemRarity.EIR_Excellent
  if tbGeneral and tbGeneral[tonumber(ChipBagData.Chip.resourceID)] then
    rare = tbGeneral[tonumber(ChipBagData.Chip.resourceID)].Rare
  end
  local newLevel = math.clamp(newLevel, 0, ChipData:GetChipMaxLvByRarity(rare))
  return newLevel
end
function ChipViewModel:GetLevelUPMainAttrGrowthByChipBagData(ChipBagData)
  if not ChipBagData then
    return {
      x = 0,
      y = 0,
      z = 0
    }
  end
  local rare = UE.ERGItemRarity.EIR_Excellent
  if tbGeneral and tbGeneral[tonumber(ChipBagData.Chip.resourceID)] then
    rare = tbGeneral[tonumber(ChipBagData.Chip.resourceID)].Rare
  end
  local levelUPMainAttrGrowth = {
    x = 0,
    y = 0,
    z = 0
  }
  if tbMainAttrLvUp and tbMainAttrLvUp[rare] and tbMainAttrLvUp[rare].LevelUPMainAttrGrowth then
    for i, v in ipairs(tbMainAttrLvUp[rare].LevelUPMainAttrGrowth) do
      if ChipBagData.TbChipData and v.x == tonumber(ChipBagData.TbChipData.AttrID) then
        levelUPMainAttrGrowth = v
        break
      end
    end
  end
  return levelUPMainAttrGrowth
end
function ChipViewModel:GetShowAttrValue(Value, RowOp)
  local valueTxt = UE.URGBlueprintLibrary.GetAttributeDisplayText(Value, RowOp.AttributeDisplayType, RowOp.Unit)
  return valueTxt
end
function ChipViewModel:CheckOutEatListToTargetLv(ChipOrderedMap, ChipBagData, LevelDiff)
  if not self:GetFirstView() then
    return {}
  end
  if not ChipBagData.Chip then
    return {}
  end
  local levelDiff = LevelDiff or 0
  if levelDiff <= 0 then
    return {}
  end
  local rare = UE.ERGItemRarity.EIR_Excellent
  if tbGeneral and tbGeneral[tonumber(ChipBagData.Chip.resourceID)] then
    rare = tbGeneral[tonumber(ChipBagData.Chip.resourceID)].Rare
  end
  levelDiff = math.clamp(levelDiff, 0, ChipData:GetChipMaxLvByRarity(rare) - ChipBagData.Chip.level)
  local eatChipList = {}
  local eatChipUpgradeMatList = {}
  local targetLvExp = self:GetCurLvUpExpByChipBagData(ChipBagData, levelDiff)
  local curExp = ChipBagData.Chip.exp
  local expDiff = targetLvExp - curExp
  local totalEatExp = 0
  for i, v in pairs(ChipOrderedMap) do
    if expDiff <= 0 then
      break
    end
    print("ChipViewModel:CheckOutEatListToTargetLv", self:GetChipRare(v), ChipData.CurRareLimit)
    if v.Chip then
      if not (v.Chip.state ~= EChipState.Lock and 0 == v.Chip.equipHeroID and self:GetChipRare(v) <= ChipData.CurRareLimit) then
        goto lbl_177
      end
      local eatExp = self:GetEatExpByChipBagData(v)
      totalEatExp = totalEatExp + eatExp
      table.insert(eatChipList, v.Chip.id)
      if expDiff <= totalEatExp then
        break
      end
    elseif v.ChipUpgradeMat then
      if self:CheckCanEatByChipBagData(v, ChipBagData) and self:GetChipRare(v) <= ChipData.CurRareLimit then
        local eatExp = self:GetEatExpByChipBagData(v)
        local needExp = expDiff - totalEatExp
        local useMatNum = 0
        if needExp % eatExp > 0 then
          useMatNum = math.floor(needExp / eatExp) + 1
          useMatNum = math.clamp(useMatNum, 1, v.ChipUpgradeMat.amount)
          eatExp = eatExp * useMatNum
        end
        totalEatExp = totalEatExp + eatExp
        table.insert(eatChipUpgradeMatList, {
          id = v.ChipUpgradeMat.ResID,
          amount = useMatNum
        })
        if expDiff <= totalEatExp then
          break
        end
      end
      print("ChipViewModel:CheckOutEatListToTargetLv", v.ChipUpgradeMat.ResID)
    end
    ::lbl_177::
  end
  return eatChipList, eatChipUpgradeMatList
end
function ChipViewModel:GetRandSubAttrLvGap()
  return ChipData.RandSubAttrLvGap
end
function ChipViewModel:GetChipRare(ChipBagsItemData)
  if not ChipBagsItemData then
    return UE.ERGItemRarity.EIR_Excellent
  end
  local resID = -1
  if ChipBagsItemData.Chip then
    resID = tonumber(ChipBagsItemData.Chip.resourceID)
  elseif ChipBagsItemData.ChipUpgradeMat then
    resID = tonumber(ChipBagsItemData.ChipUpgradeMat.ResID)
  end
  if tbGeneral and tbGeneral[resID] then
    print("GetChipRare", tbGeneral[resID].Rare)
    return tbGeneral[resID].Rare
  end
  return UE.ERGItemRarity.EIR_Excellent
end
function ChipViewModel:GetChipName(ChipBagItemData)
  if not ChipBagItemData then
    return ""
  end
  local result, row = GetRowData(DT.DT_Item, tostring(ChipBagItemData.TbChipData.ID))
  if result then
    return row.Name
  end
  return ""
end
function ChipViewModel:GetModIdBySlot(Slot)
  local modIdx = -1
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if tbChipSlot and tbChipSlot[Slot] then
    modIdx = tbChipSlot[Slot].WorldID
  end
  return modIdx
end
function ChipViewModel:GetMainAttrInitValue(ChipBagItemData)
  return ChipBagItemData.TbChipData.AttrValue
end
function ChipViewModel:CheckSlotIsEmpty()
  local chipList = {}
  local chipBags = ChipData.ChipBags
  for k, v in pairs(chipBags) do
    if v.TbChipData.Slot == self.CurSelectModeIdx and self:CheckContainMainAttr(v) and self:CheckContainSubAttr(v) then
      table.insert(chipList, v)
    end
  end
  return table.IsEmpty(chipList)
end
function ChipViewModel:GetMainAttrValueByChipBagItemData(ChipBagItemData)
  return ChipData:GetMainAttrValueByChipBagItemData(ChipBagItemData)
end
function ChipViewModel:GetMaxLv(Rare)
  return ChipData:GetChipMaxLvByRarity(Rare)
end
function ChipViewModel:GetMaxLvByChipBagItem(ChipBagItemData)
  if not ChipBagItemData then
    return 0
  end
  local rare = self:GetChipRare(ChipBagItemData)
  return ChipData:GetChipMaxLvByRarity(rare)
end
function ChipViewModel:GetIsOnlyCheckDiscard()
  return ChipData.StrengthOnlyCheckDiscard
end
function ChipViewModel:GetMaxChipNum()
  return ChipData.MaxChipNum
end
function ChipViewModel:GetChipsTotalNum()
  local num = 0
  for k, v in pairs(ChipData.ChipBags) do
    num = num + 1
  end
  return num
end
function ChipViewModel:ResetDataWhenHideView()
  self.CurSelectModeIdx = -1
end
function ChipViewModel:OnUpdateLeftAndRightRedDot()
  local LeftRedDotCount = 0
  local RightRedDotCount = 0
  local chipBags = ChipData.ChipBags
  for k, v in pairs(chipBags) do
    local ChipRedDotState = RedDotData:GetRedDotState("Chip_Item_" .. v.Chip.id)
    if ChipRedDotState and ChipRedDotState.Num > 0 then
      if v.TbChipData.Slot < self.CurSelectModeIdx then
        LeftRedDotCount = LeftRedDotCount + 1
      elseif v.TbChipData.Slot > self.CurSelectModeIdx then
        RightRedDotCount = RightRedDotCount + 1
      end
    end
  end
  if self:GetFirstView() then
    self:GetFirstView():UpdateLeftAndRightRedDot(LeftRedDotCount, RightRedDotCount)
  end
end
function ChipViewModel:GetCurHeroId()
  return self.CurHeroId
end
function ChipViewModel:GetIsNewByUUID(UUID)
  local chipRedDotId = "Chip_Item_" .. UUID
  local redDotState = RedDotData:GetRedDotState(chipRedDotId)
  local bIsNew = false
  if redDotState and redDotState.Num > 0 then
    bIsNew = true
  end
  return bIsNew
end
function ChipViewModel:CheckInscriptionMutex(ChipBagItemData, EquipedChipItemData)
  if not ChipBagItemData then
    return false, -1, -1
  end
  if ChipBagItemData.Chip.inscription <= 0 then
    return false, -1, -1
  end
  local tbMutexInscription = LuaTableMgr.GetLuaTableByName(TableNames.TBInscriptionMutex)
  if not tbMutexInscription then
    return false, -1, -1
  end
  local equipedChipList = self:GetEquipedChipListByHeroId(self.CurHeroId)
  for i, v in ipairs(equipedChipList) do
    if EquipedChipItemData and EquipedChipItemData.Chip.id ~= v.Chip.id or not EquipedChipItemData then
      if tbMutexInscription[v.Chip.inscription] and tbMutexInscription[v.Chip.inscription].InscriptionIDs then
        for iMutex, vMutex in ipairs(tbMutexInscription[v.Chip.inscription].InscriptionIDs) do
          if vMutex == ChipBagItemData.Chip.inscription then
            return true, v.TbChipData, vMutex
          end
        end
      end
      if tbMutexInscription[ChipBagItemData.Chip.inscription] and tbMutexInscription[ChipBagItemData.Chip.inscription].InscriptionIDs then
        for iMutex, vMutex in ipairs(tbMutexInscription[ChipBagItemData.Chip.inscription].InscriptionIDs) do
          if vMutex == v.Chip.inscription then
            return true, v.TbChipData, v.Chip.inscription
          end
        end
      end
    end
  end
  return false, -1, -1
end
function ChipViewModel:CheckConfirmOnlyInscription(ChipBagItemData, EquipedChipItemData)
  if not ChipBagItemData then
    return false
  end
  if ChipBagItemData.Chip.inscription <= 0 then
    return false
  end
  local bIsOlnlyInscription = false
  local tbMutexInscription = LuaTableMgr.GetLuaTableByName(TableNames.TBInscriptionMutex)
  if tbMutexInscription and tbMutexInscription[ChipBagItemData.Chip.inscription] then
    bIsOlnlyInscription = tbMutexInscription[ChipBagItemData.Chip.inscription].Unique
  end
  if not bIsOlnlyInscription then
    return false
  end
  local equipedChipList = self:GetEquipedChipListByHeroId(self.CurHeroId)
  for i, v in ipairs(equipedChipList) do
    if (EquipedChipItemData and EquipedChipItemData.Chip.id ~= v.Chip.id or not EquipedChipItemData) and v.Chip.inscription == ChipBagItemData.Chip.inscription then
      return true
    end
  end
  return false
end
function ChipViewModel:GetInscriptionDesc(Inscription)
  local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if RGLogicCommandDataSubsystem and Inscription > 0 then
    local inscriptionDesc = RGLogicCommandDataSubsystem:GetInscriptionDescribStr(Inscription, 1)
    return inscriptionDesc
  end
  return ""
end
function ChipViewModel:GetSlotName(Slot)
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if tbChipSlot and tbChipSlot[Slot] then
    return tbChipSlot[Slot].name
  end
  return ""
end
function ChipViewModel:GetSubValueByAttrId(ChipBagItemData, AttrId)
  if not ChipBagItemData then
    return 0
  end
  for i, v in ipairs(ChipBagItemData.Chip.subAttr) do
    if v.attrID == AttrId then
      return v.value
    end
  end
  return 0
end
function ChipViewModel:CheckMainAttrIdx(ChipBagItemData)
  if table.IsEmpty(ChipData.NormalFilterData.MainAttrFilter) then
    return -1
  end
  if not ChipBagItemData then
    return -1
  end
  return ChipData.NormalFilterData.MainAttrFilter[ChipBagItemData.TbChipData.AttrID] or -1
end
function ChipViewModel:CheckStrengthMainAttrIdx(ChipBagItemData)
  if table.IsEmpty(ChipData.StrengthFilterData.MainAttrFilter) then
    return -1
  end
  if not ChipBagItemData then
    return -1
  end
  return ChipData.StrengthFilterData[ChipBagItemData.TbChipData.AttrID] or -1
end
function ChipViewModel:CheckContainMainAttr(ChipBagItemData)
  if table.IsEmpty(ChipData.NormalFilterData.MainAttrFilter) then
    return true
  end
  if not ChipBagItemData then
    return false
  end
  return ChipData.NormalFilterData.MainAttrFilter[ChipBagItemData.TbChipData.AttrID]
end
function ChipViewModel:CheckContainSubAttr(ChipBagItemData)
  if table.IsEmpty(ChipData.NormalFilterData.SubAttrFilter) then
    return true
  end
  if not ChipBagItemData then
    return false
  end
  for kSub, vSub in pairs(ChipData.NormalFilterData.SubAttrFilter) do
    for i, v in ipairs(ChipBagItemData.Chip.subAttr) do
      if v.attrID == kSub then
        return true
      end
    end
  end
  return false
end
function ChipViewModel:CheckStrengthContainMainAttr(ChipBagItemData)
  if table.IsEmpty(ChipData.StrengthFilterData.MainAttrFilter) then
    return true
  end
  if not ChipBagItemData then
    return false
  end
  return ChipData.StrengthFilterData.MainAttrFilter[ChipBagItemData.TbChipData.AttrID]
end
function ChipViewModel:CheckStrengthContainSubAttr(ChipBagItemData)
  if table.IsEmpty(ChipData.StrengthFilterData.SubAttrFilter) then
    return true
  end
  if not ChipBagItemData then
    return false
  end
  for kSub, vSub in pairs(ChipData.StrengthFilterData.SubAttrFilter) do
    for i, v in ipairs(ChipBagItemData.Chip.subAttr) do
      if v.attrID == kSub then
        return true
      end
    end
  end
  return false
end
function ChipViewModel:GetCurRareLimit()
  return ChipData.CurRareLimit
end
function ChipViewModel:SetCurRareLimit(Rare)
  ChipData.CurRareLimit = Rare
end
function ChipViewModel:CheckNormalIsDefaultFilter()
  if not table.IsEmpty(ChipData.NormalFilterData.MainAttrFilter) then
    return false
  end
  if not table.IsEmpty(ChipData.NormalFilterData.SubAttrFilter) then
    return false
  end
  if ChipData.NormalFilterData.RuleFilter ~= ChipData.DefaultNormalFilterData.RuleFilter then
    return false
  end
  if ChipData.NormalFilterData.TypeFilter ~= ChipData.DefaultNormalFilterData.TypeFilter then
    return false
  end
  return true
end
function ChipViewModel:CheckStrengthIsDefaultFilter()
  if not table.IsEmpty(ChipData.StrengthFilterData.MainAttrFilter) then
    return false
  end
  if not table.IsEmpty(ChipData.StrengthFilterData.SubAttrFilter) then
    return false
  end
  if ChipData.StrengthFilterData.RuleFilter ~= ChipData.DefaultStrengthFilterData.RuleFilter then
    return false
  end
  if ChipData.StrengthFilterData.TypeFilter ~= ChipData.DefaultStrengthFilterData.TypeFilter then
    return false
  end
  return true
end
function ChipViewModel:CreateChipBagItemDataByUpgradeMat(id, amount)
  return ChipData:CreateChipBagItemDataByUpgradeMat(id, amount)
end
function ChipViewModel:CheckIsChipUpgradeMat(ChipBagItemData)
  if not ChipBagItemData then
    return false
  end
  return ChipBagItemData.ChipUpgradeMat
end
return ChipViewModel
