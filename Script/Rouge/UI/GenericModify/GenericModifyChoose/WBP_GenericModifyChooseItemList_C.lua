local WBP_GenericModifyChooseItemList = UnLua.Class()
function WBP_GenericModifyChooseItemList:UpdatePanel(PreviewModifyListParam, InteractComp, HoverFuncParam, ParentView, bRefresh)
  UpdateVisibility(self, true)
  local PreviewModifyList = {}
  if InteractComp and InteractComp.PreviewModifyList then
    PreviewModifyList = InteractComp.PreviewModifyList
  end
  if InteractComp and InteractComp.PreviewGenericModifyAry then
    PreviewModifyList = InteractComp.PreviewGenericModifyAry
  end
  if InteractComp and InteractComp.RarityUpModifyPayloadList then
    PreviewModifyList = InteractComp.RarityUpModifyPayloadList
  end
  if InteractComp then
    local ModifyNum = PreviewModifyList:Length()
    self:InitData(ParentView, ModifyNum)
    if PreviewModifyList:Length() <= 0 then
      for i = 1, 3 do
        local Name = string.format("WBP_GenericModifyChooseItem%d", i)
        UpdateVisibility(self[Name], false)
      end
    else
      local ModifyChooseTypeTemp = LogicGenericModify:GetModifyTypeByComp(InteractComp)
      local CycleTimes = 3
      if InteractComp.PreviewModifyData and InteractComp.PreviewModifyData.PreviewModifyParam_Count then
        CycleTimes = InteractComp.PreviewModifyData.PreviewModifyParam_Count
      end
      for i = 1, CycleTimes do
        if i > PreviewModifyList:Length() then
          break
        end
        local v = PreviewModifyList:Get(i)
        local Name = string.format("WBP_GenericModifyChooseItem%d", i)
        print("WBP_GenericModifyChooseItemList :UpdatePanel PreviewModifyList Item Name:", Name)
        if self[Name] then
          if ModifyChooseTypeTemp == ModifyChooseType.SpecificModify or ModifyChooseTypeTemp == ModifyChooseType.SpecificModifyReplace then
            self[Name]:InitSpecificModifyChooseItem(v.ModifyId, ModifyChooseTypeTemp, HoverFuncParam, ParentView, bRefresh)
          else
            self[Name]:InitGenericModifyChooseItem(v, ModifyChooseTypeTemp, HoverFuncParam, ParentView, false)
          end
          UpdateVisibility(self[Name], true)
          self[Name].WBP_GenericModifyTips:FadeIn(bRefresh)
          if not bRefresh then
            self[Name]:FadeIn()
          else
            self[Name].bCanSelect = true
          end
        end
      end
    end
    if InteractComp.PreviewModifyData then
      print("WBP_GenericModifyChooseItem InteractComp.PreviewModifyData", InteractComp.PreviewModifyData.PreviewModifyParam_Count, ModifyNum)
    end
    if InteractComp.PreviewModifyData and 3 ~= InteractComp.PreviewModifyData.PreviewModifyParam_Count and 3 == InteractComp.PreviewModifyData.PreviewModifyList:Num() then
      for i = InteractComp.PreviewModifyData.PreviewModifyParam_Count + 1, 3 do
        local Name = string.format("WBP_GenericModifyChooseItem%d", i)
        self[Name]:ShowGold(ParentView)
        UpdateVisibility(self[Name], true)
      end
      self:UpdataLocation(3)
    else
      for i = PreviewModifyList:Length() + 1, 3 do
        local Name = string.format("WBP_GenericModifyChooseItem%d", i)
        UpdateVisibility(self[Name], false)
      end
      self:UpdataLocation(ModifyNum)
    end
  end
end
function WBP_GenericModifyChooseItemList:UpdatePanelNew(ModifyIdList, ModifyChooseTypeTemp, HoverFuncParam, ParentView, bRefresh)
  UpdateVisibility(self, true)
  local ModifyNum = #ModifyIdList
  self:InitData(ParentView, ModifyNum)
  if ModifyNum <= 0 then
    for i = 1, 3 do
      local Name = string.format("WBP_GenericModifyChooseItem%d", i)
      UpdateVisibility(self[Name], false)
    end
  else
    local CycleTimes = 3
    for i = 1, #ModifyIdList do
      local ModifyId = ModifyIdList[i]
      local Name = string.format("WBP_GenericModifyChooseItem%d", i)
      print("WBP_GenericModifyChooseItemList :UpdatePanel ModifyIdList Item Name:", Name)
      if self[Name] then
        if ModifyChooseTypeTemp == ModifyChooseType.SpecificModify or ModifyChooseTypeTemp == ModifyChooseType.SpecificModifyReplace or ModifyChooseTypeTemp == ModifyChooseType.SurvivalSpecificModify then
          self[Name]:InitSpecificModifyChooseItem(ModifyId, ModifyChooseTypeTemp, HoverFuncParam, ParentView, bRefresh)
        else
          self[Name]:InitGenericModifyChooseItem(ModifyId, ModifyChooseTypeTemp, HoverFuncParam, ParentView, false)
        end
        UpdateVisibility(self[Name], true)
        self[Name].WBP_GenericModifyTips:FadeIn(bRefresh)
        if not bRefresh then
          self[Name]:FadeIn()
        else
          self[Name].bCanSelect = true
        end
      end
    end
    for i = #ModifyIdList + 1, 3 do
      local Name = string.format("WBP_GenericModifyChooseItem%d", i)
      UpdateVisibility(self[Name], false)
    end
    self:UpdataLocation(ModifyNum)
  end
end
function WBP_GenericModifyChooseItemList:UpdataLocation(ModifyNum)
  local V2D = UE.FVector2D()
  V2D.X = self.Spacing * -1
  V2D.Y = self.YPosition
  if 0 == ModifyNum or 1 == ModifyNum then
    UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyChooseItem1):SetPosition(V2D)
    return
  elseif 2 == ModifyNum then
    V2D.X = -1 * self.Spacing * 2
    UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyChooseItem1):SetPosition(V2D)
    V2D.X = 0
    UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyChooseItem2):SetPosition(V2D)
  elseif 3 == ModifyNum then
    V2D.X = -1 * self.Spacing * 3
    local Slot1 = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyChooseItem1):SetPosition(V2D)
    V2D.X = -1 * self.Spacing
    UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyChooseItem2):SetPosition(V2D)
    V2D.X = self.Spacing
    UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyChooseItem3):SetPosition(V2D)
  end
end
function WBP_GenericModifyChooseItemList:UpdateModifyListByShop(PreviewModifyList, HoverFuncParam, ParentView)
  UpdateVisibility(self, true)
  self:InitData(ParentView, PreviewModifyList.ModifyList:Num())
  for i = 1, 3 do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    UpdateVisibility(self[Name], false)
  end
  local ModifyChooseTypeTemp = ModifyChooseType.GenericModify
  if PreviewModifyList.NpcType == UE.ERGNpcType.NT_UpgradeModify then
    ModifyChooseTypeTemp = ModifyChooseType.UpgradeModify
  elseif PreviewModifyList.NpcType == UE.ERGNpcType.NT_RarityUpModify then
    ModifyChooseTypeTemp = ModifyChooseType.RarityUpModify
  end
  if ModifyChooseTypeTemp == ModifyChooseType.RarityUpModify then
    for i, v in iterator(PreviewModifyList.RarityUpModifyList) do
      local Name = string.format("WBP_GenericModifyChooseItem%d", i)
      if self[Name] then
        self[Name]:InitGenericModifyChooseItem(v, ModifyChooseTypeTemp, HoverFuncParam, ParentView, true)
        UpdateVisibility(self[Name], true)
        self[Name].WBP_GenericModifyTips:FadeIn()
        self[Name]:FadeIn()
      end
    end
  else
    for i, v in iterator(PreviewModifyList.ModifyList) do
      local Name = string.format("WBP_GenericModifyChooseItem%d", i)
      if self[Name] then
        self[Name]:InitGenericModifyChooseItem(v, ModifyChooseTypeTemp, HoverFuncParam, ParentView, true)
        UpdateVisibility(self[Name], true)
        self[Name].WBP_GenericModifyTips:FadeIn()
        self[Name]:FadeIn()
      end
    end
  end
  self:UpdataLocation(PreviewModifyList.ModifyList:Num())
end
function WBP_GenericModifyChooseItemList:UpdateSurvivalModifyList(ChooseType, PreviewModifyList, HoverFuncParam, ParentView)
  for i = 1, 3 do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    UpdateVisibility(self[Name], false)
  end
  local Num = 0
  for i, v in iterator(PreviewModifyList) do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    if self[Name] then
      self[Name]:InitGenericModifyChooseItem(v, ChooseType, HoverFuncParam, ParentView, false)
      UpdateVisibility(self[Name], true)
      self[Name].WBP_GenericModifyTips:FadeIn()
      self[Name]:FadeIn()
      Num = Num + 1
    end
  end
  self:UpdataLocation(Num)
end
function WBP_GenericModifyChooseItemList:UpdateModifyListByPushPreview(PreviewModifyList, HoverFuncParam, ParentView)
  UpdateVisibility(self, true)
  for i = 1, 3 do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    UpdateVisibility(self[Name], false)
  end
  local ModifyChooseTypeTemp = ModifyChooseType.DoubleGenericModifyUpgrade
  for i, v in ipairs(PreviewModifyList) do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    if self[Name] then
      self[Name]:InitGenericModifyChooseItem(v, ModifyChooseTypeTemp, HoverFuncParam, ParentView, false)
      UpdateVisibility(self[Name], true)
      self[Name].WBP_GenericModifyTips:FadeIn()
      self[Name]:FadeIn()
    end
  end
  self:UpdataLocation(#PreviewModifyList)
end
function WBP_GenericModifyChooseItemList:UpdatePanelByBattleLagacy(BattleLagacyIDs, ParentView)
  UpdateVisibility(self, true)
  self:InitData(ParentView, #BattleLagacyIDs)
  for i, v in ipairs(BattleLagacyIDs) do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    print("WBP_GenericModifyChooseItemList :UpdatePanel PreviewModifyList Item Name:", Name)
    if self[Name] then
      self[Name]:InitGenericModifyChooseItemByBattleLagacy(v, ParentView, i)
      UpdateVisibility(self[Name], true)
      self[Name].WBP_GenericModifyTips:FadeIn()
      self[Name]:FadeIn()
    end
  end
  for i = #BattleLagacyIDs + 1, 3 do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    UpdateVisibility(self[Name], false)
  end
  self:UpdataLocation(#BattleLagacyIDs)
end
function WBP_GenericModifyChooseItemList:OnUnDisplay()
  UpdateVisibility(self, true)
  self.ParentView = nil
  self.TotalModifyNum = 0
  for i = 1, 3 do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    if self[Name] then
      self[Name]:OnMouseLeave()
      self[Name]:StopAllAnimations()
      self[Name]:OnUnDisplay()
    end
    UpdateVisibility(self[Name], false)
  end
  self:StopAllAnimations()
end
function WBP_GenericModifyChooseItemList:SetItemCantSelect()
  for i = 1, 3 do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    if self[Name] then
      self[Name].bCanSelect = false
    end
  end
end
function WBP_GenericModifyChooseItemList:FadeOut(RGGenericModifyParam, GroupId)
  local selectIdx = 1
  for i = 1, 3 do
    local Name = string.format("WBP_GenericModifyChooseItem%d", i)
    if self[Name] then
      if self[Name].ModifyId and self[Name].ModifyId == RGGenericModifyParam or self[Name].ModId and self[Name].ModId == RGGenericModifyParam then
        selectIdx = i
        self[Name]:FadeOut(GroupId, true)
      else
        self[Name]:FadeOut(GroupId)
      end
    end
  end
  if UE.RGUtil.IsUObjectValid(self.ParentView) and self.ParentView.ModifyChooseType == ModifyChooseType.RarityUpModify and self.TotalModifyNum then
    local keyName = string.format("Ani_%d_%d", self.TotalModifyNum, selectIdx)
    self.StateCtrl_ClickAni:ChangeStatus(keyName)
  end
end
function WBP_GenericModifyChooseItemList:InitData(ParentView, TotalModifyNum)
  self.ParentView = ParentView
  self.TotalModifyNum = TotalModifyNum
end
function WBP_GenericModifyChooseItemList:Destruct()
  UpdateVisibility(self, true)
  self.ParentView = nil
  self.TotalModifyNum = 0
  self.Overridden.Destruct(self)
end
function WBP_GenericModifyChooseItemList:ChooseItemUpNav()
  if self.ParentView then
    local Passive_ItemName = string.format("WBP_HUD_GenericModifyItem_First_%d", UE.ERGGenericModifySlot.Count)
    local E_ItemName = string.format("WBP_HUD_GenericModifyItem_First_%d", UE.ERGGenericModifySlot.SLOT_E)
    if CheckIsVisility(self.ParentView.WBP_HUD_GenericModifyList[Passive_ItemName]) then
      return self.ParentView.WBP_HUD_GenericModifyList[Passive_ItemName]
    end
    if CheckIsVisility(self.ParentView.WBP_HUD_GenericModifyList[E_ItemName]) then
      return self.ParentView.WBP_HUD_GenericModifyList[E_ItemName]
    end
  end
  return nil
end
function WBP_GenericModifyChooseItemList:ChooseItem_1_DownNav()
  if CheckIsVisility(self.WBP_GenericModifyChooseItem1.WBP_GenericModifyTips.HorizontalBoxChange) then
    return self.WBP_GenericModifyChooseItem1.WBP_GenericModifyTips.BP_ButtonWithSoundChangeShowModify
  end
  if self.ParentView then
    if CheckIsVisility(self.ParentView.CanvasPanelAbandoned) then
      return self.ParentView.BP_ButtonWithSoundAbandoned
    end
    if CheckIsVisility(self.ParentView.BP_ButtonWithSoundRefresh) then
      return self.ParentView.BP_ButtonWithSoundRefresh
    end
  end
  return nil
end
function WBP_GenericModifyChooseItemList:ChooseItem_2_DownNav()
  if CheckIsVisility(self.WBP_GenericModifyChooseItem2.WBP_GenericModifyTips.HorizontalBoxChange) then
    return self.WBP_GenericModifyChooseItem2.WBP_GenericModifyTips.BP_ButtonWithSoundChangeShowModify
  end
  if self.ParentView then
    if CheckIsVisility(self.ParentView.CanvasPanelAbandoned) then
      return self.ParentView.BP_ButtonWithSoundAbandoned
    end
    if CheckIsVisility(self.ParentView.BP_ButtonWithSoundRefresh) then
      return self.ParentView.BP_ButtonWithSoundRefresh
    end
  end
  return nil
end
function WBP_GenericModifyChooseItemList:ChooseItem_3_DownNav()
  if CheckIsVisility(self.WBP_GenericModifyChooseItem3.WBP_GenericModifyTips.HorizontalBoxChange) then
    return self.WBP_GenericModifyChooseItem3.WBP_GenericModifyTips.BP_ButtonWithSoundChangeShowModify
  end
  if self.ParentView then
    if CheckIsVisility(self.ParentView.BP_ButtonWithSoundRefresh) then
      return self.ParentView.BP_ButtonWithSoundRefresh
    end
    if CheckIsVisility(self.ParentView.CanvasPanelAbandoned) then
      return self.ParentView.BP_ButtonWithSoundAbandoned
    end
  end
  return nil
end
function WBP_GenericModifyChooseItemList:ChooseItem_1_LeftNav()
  if self.ParentView and CheckIsVisility(self.ParentView.WBP_GenericModifySpecificExchangeOld) then
    return self.ParentView.WBP_GenericModifySpecificExchangeOld
  end
  if CheckIsVisility(self.WBP_GenericModifyChooseItem3) then
    return self.WBP_GenericModifyChooseItem3
  end
  return self.WBP_GenericModifyChooseItem2
end
function WBP_GenericModifyChooseItemList:ChooseItem_3_RightNav()
  if self.ParentView and CheckIsVisility(self.ParentView.WBP_GenericModifySpecificExchangeOld) then
    return self.ParentView.WBP_GenericModifySpecificExchangeOld
  end
  return self.WBP_GenericModifyChooseItem1
end
return WBP_GenericModifyChooseItemList
