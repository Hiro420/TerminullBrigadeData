local WBP_ScrollSetPickupTipsItem_C = UnLua.Class()
local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")

function WBP_ScrollSetPickupTipsItem_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ScrollSetPickupTipsItem_C:InitScrollSetTipsItem(AttributeModifySetId, AttributeModifyId, bIsComplete, ScrollTipsOpenTypeParam, UserId)
  self.UserId = UserId
  UpdateVisibility(self, true)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollSetPickupTipsItem_C:InitScrollItem not DTSubsystem")
    return nil
  end
  local Result, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(AttributeModifySetId, nil)
  if Result then
    SetImageBrushBySoftObject(self.URGImageScrollSetIcon, AttributeModifySetRow.SetIconWithBg)
    self.RGTextName:SetText(AttributeModifySetRow.SetName)
    local AttributeModifySetData = self:GetAttributeModifySetDataBySetId(AttributeModifySetId)
    UpdateVisibility(self.RGTextCurNum, false)
    local HaveScroll = self:CheckHaveScroll(AttributeModifyId)
    UpdateVisibility(self.RGTextNextNum, not HaveScroll)
    UpdateVisibility(self.RGTextCurNum, not HaveScroll)
    local ShowLv = 1
    local IsOwner = nil ~= UserId and tostring(UserId) == DataMgr:GetUserId()
    if ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromPickup or ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromBagPickupList or ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromTeamDamage and not IsOwner then
      if AttributeModifySetData then
        ShowLv = AttributeModifySetData.Level + 1
      end
      UpdateVisibility(self.URGImageArrow, true)
      UpdateVisibility(self.RGTextCurNum, true)
      UpdateVisibility(self.RGTextNextNum, true)
      self.RGTextCurNum:SetText(string.format("x%d", ShowLv - 1))
      self.RGTextNextNum:SetText(string.format("x%d", ShowLv))
    elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromScrollSlot or ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromShop or ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromTeamDamage and IsOwner then
      ShowLv = 1
      if AttributeModifySetData then
        ShowLv = AttributeModifySetData.Level
      end
      self.RGTextCurNum:SetText(string.format("x%d", ShowLv))
      self.RGTextNextNum:SetText(string.format("x%d", ShowLv + 1))
      UpdateVisibility(self.URGImageArrow, false)
      UpdateVisibility(self.RGTextCurNum, true)
      UpdateVisibility(self.RGTextNextNum, false)
    elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromScrollSlotSettlement then
      ShowLv = 0
      if GetCurSceneStatus() == UE.ESceneStatus.ESettlement then
        AttributeModifySetData = self:GetAttributeSetDataBySetIdFromSettle(AttributeModifySetId)
      else
        local battleHistoryVM = UIModelMgr:Get("BattleHistoryViewModel")
        local historyData = battleHistoryVM:GetHistoryDataByRoleId(self.UserId)
        for i, v in ipairs(historyData.Collections) do
          local resultScroll, rowScroll = GetRowData(DT.DT_AttributeModify, tostring(v))
          if resultScroll then
            for iSet, vSet in iterator(rowScroll.SetArray) do
              if vSet == AttributeModifySetId then
                ShowLv = ShowLv + 1
              end
            end
          end
        end
      end
      if AttributeModifySetData then
        ShowLv = AttributeModifySetData.Level
      end
      self.RGTextCurNum:SetText(string.format("x%d", ShowLv))
      self.RGTextNextNum:SetText(string.format("x%d", ShowLv + 1))
      UpdateVisibility(self.URGImageArrow, false)
      UpdateVisibility(self.RGTextCurNum, true)
      UpdateVisibility(self.RGTextNextNum, false)
    elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromSaveGrowthSnap then
      local snapData = SaveGrowthSnapData.SaveGrowthSnapMap[SaveGrowthSnapData.CurSelectTogglePos].GrowthSnapShot
      if snapData and snapData.attribute_modify_set then
        for idxSet = 1, #snapData.attribute_modify_set, 2 do
          if snapData.attribute_modify_set[idxSet] == AttributeModifySetId then
            ShowLv = snapData.attribute_modify_set[idxSet + 1]
          end
        end
      end
      self.RGTextCurNum:SetText(string.format("x%d", ShowLv))
      self.RGTextNextNum:SetText(string.format("x%d", ShowLv + 1))
      UpdateVisibility(self.URGImageArrow, false)
      UpdateVisibility(self.RGTextCurNum, true)
      UpdateVisibility(self.RGTextNextNum, false)
    end
    UpdateVisibility(self.URGImageBg, true)
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    local Index = 1
    local MaxLv = 1
    local baseLv = AttributeModifySetRow.BaseInscription.Level
    local InscriptionDesc = GetLuaInscriptionDesc(AttributeModifySetRow.BaseInscription.BaseInscriptionId)
    if bIsComplete or ShowLv <= baseLv and 1 == Index then
      local ScrollSetTipsDescItemTemp = GetOrCreateItem(self.VerticalBoxDesc, Index, self.WBP_ScrollSetTipsDescItem:GetClass())
      ScrollSetTipsDescItemTemp:InitScrollSetTipsDescItem(ShowLv >= baseLv, InscriptionDesc, baseLv)
      Index = Index + 1
    end
    if MaxLv < baseLv then
      MaxLv = baseLv
    end
    for k, v in pairs(AttributeModifySetRow.LevelInscriptionMap) do
      if RGLogicCommandDataSubsystem then
        local InscriptionDesc = GetLuaInscriptionDesc(v, 1)
        if bIsComplete or ShowLv <= k and 1 == Index then
          local ScrollSetTipsDescItemTemp = GetOrCreateItem(self.VerticalBoxDesc, Index, self.WBP_ScrollSetTipsDescItem:GetClass())
          local bIsActivated = ShowLv >= k
          if ShowLv >= 6 and 4 == k then
            bIsActivated = false
          end
          ScrollSetTipsDescItemTemp:InitScrollSetTipsDescItem(bIsActivated, InscriptionDesc, k)
          Index = Index + 1
        end
        if k > MaxLv then
          MaxLv = k
        end
      end
    end
    if 1 == Index and not bIsComplete then
      local v = Logic_Scroll:GetInscriptionBySetLv(MaxLv, AttributeModifySetId)
      if v and RGLogicCommandDataSubsystem then
        local InscriptionDesc = GetLuaInscriptionDesc(v, 1)
        local ScrollSetTipsDescItemTemp = GetOrCreateItem(self.VerticalBoxDesc, Index, self.WBP_ScrollSetTipsDescItem:GetClass())
        ScrollSetTipsDescItemTemp:InitScrollSetTipsDescItem(true, InscriptionDesc, MaxLv)
        Index = Index + 1
      end
    end
    HideOtherItem(self.VerticalBoxDesc, Index)
  end
end

function WBP_ScrollSetPickupTipsItem_C:GetAttributeModifySetDataBySetId(SetId)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    for i, v in iterator(Character.AttributeModifyComponent.ActivatedSets) do
      if v.SetId == SetId then
        return v
      end
    end
  end
  return nil
end

function WBP_ScrollSetPickupTipsItem_C:GetAttributeSetDataBySetIdFromSettle(SetId)
  local ActivatedSets = LogicSettlement:GetScrollSetListByPlayerId(self.UserId)
  for i, v in ipairs(ActivatedSets) do
    if v.SetId == SetId then
      return v
    end
  end
  return nil
end

function WBP_ScrollSetPickupTipsItem_C:CheckHaveScroll(AttributeModifId)
  return false
end

function WBP_ScrollSetPickupTipsItem_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_ScrollSetPickupTipsItem_C:Destruct()
end

return WBP_ScrollSetPickupTipsItem_C
