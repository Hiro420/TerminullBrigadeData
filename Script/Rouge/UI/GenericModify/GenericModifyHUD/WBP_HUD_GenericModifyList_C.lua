local WBP_HUD_GenericModifyList_C = UnLua.Class()
local Rate = 0.1
local ShowStatus = {
  Normal = 1,
  ShowAll = 2,
  ShowAllNoMask = 3
}
function WBP_HUD_GenericModifyList_C:Construct()
  self.BP_ButtonWithSoundHideMask.OnClicked:Add(self, self.HideMask)
  self.CanPlayAnim = false
  self.LastSlotModifyList = {}
  self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_HUD_GenericModifyList_C.UpdateCD
  }, Rate, true)
  ListenObjectMessage(nil, GMP.MSG_World_GenericModify_OnUpdateTeamSpirit, self, self.OnUpdateTeamSpirit)
  self:InitHudGenericModifyList(self.bIsShowAll)
end
function WBP_HUD_GenericModifyList_C:UpdateCD()
  local Index = UE.ERGGenericModifySlot.None + 1
  for i = UE.ERGGenericModifySlot.None + 1, UE.ERGGenericModifySlot.Count - 1 do
    local Item = self.VerticalBoxGenericModifyList:GetChildAt(Index - 1)
    if Item then
      Item:UpdateCD(Rate)
    end
    Index = Index + 1
  end
end
function WBP_HUD_GenericModifyList_C:RefreshPassiveSlotSource(bIsFromMod)
  if bIsFromMod then
    LogicGenericModify:UpdateLastPassiveSlotStatus(ELastPassiveSlotStatus.bIsFromMod)
  else
    LogicGenericModify:UpdateLastPassiveSlotStatus(ELastPassiveSlotStatus.bIsFromGenericModify)
  end
end
function WBP_HUD_GenericModifyList_C:RefreshPassiveSlotWhenChangeLevel()
  LogicGenericModify:UpdateLastPassiveSlotStatus(ELastPassiveSlotStatus.bIsChangeLevel)
end
function WBP_HUD_GenericModifyList_C:OnUpdateTeamSpirit(UserID)
  if UserID == tonumber(DataMgr.GetUserId()) then
    return
  end
  self:InitHudGenericModifyList(self.bIsShowAll)
end
function WBP_HUD_GenericModifyList_C:InitHudGenericModifyList(bIsShowAll)
  self.bIsShowAll = bIsShowAll
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  if not self.LastSlotModifyList then
    self.LastSlotModifyList = {}
  end
  self.SlotToGenericModifyItem = {}
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  local RGSpecificModifyComponent = Character:GetComponentByClass(UE.URGSpecificModifyComponent:StaticClass())
  if RGGenericModifyComponent and RGSpecificModifyComponent then
    local HUD_GenericModifyItemCls = self.WBP_HUD_GenericModifyItem:StaticClass()
    local Index = 1
    for i = UE.ERGGenericModifySlot.None + 1, UE.ERGGenericModifySlot.Count - 1 do
      local Result, RGGenericModifyData = RGGenericModifyComponent:TryGetModifyBySlot(i)
      local GenericModifyItem = GetOrCreateItem(self.VerticalBoxGenericModifyList, Index, HUD_GenericModifyItemCls)
      self.SlotToGenericModifyItem[i] = GenericModifyItem
      if bIsShowAll then
        if Result then
          GenericModifyItem:InitHudGenericModifyItem(RGGenericModifyData, i, self.UpdateGenericModifyTipsFunc, self, true, nil, nil, bIsShowAll)
        else
          GenericModifyItem:InitHudGenericModifyItem(nil, i, self.UpdateGenericModifyTipsFunc, self, true, nil, nil, bIsShowAll)
        end
      elseif Result then
        if self.bIsCanShowTips then
          GenericModifyItem:InitHudGenericModifyItem(RGGenericModifyData, i, self.UpdateGenericModifyTipsFunc, self, true, 0, self.SelectClick, bIsShowAll)
        else
          GenericModifyItem:InitHudGenericModifyItem(RGGenericModifyData, i, nil, self, true, 0, self.SelectClick, bIsShowAll)
        end
      else
        GenericModifyItem:InitHudGenericModifyItem(nil, i, nil, self, true, 0, self.SelectClick, bIsShowAll)
      end
      if Result then
        if not self.LastSlotModifyList then
          self.LastSlotModifyList = {}
        end
        if not self.LastSlotModifyList[i] or self.LastSlotModifyList[i] ~= RGGenericModifyData.ModifyId then
          if self.CanPlayAnim then
            GenericModifyItem:PlayAcquireAnim(false)
            self:PlayAcquireTipAnim()
          end
          self.LastSlotModifyList[i] = RGGenericModifyData.ModifyId
        end
      elseif self.LastSlotModifyList and self.LastSlotModifyList[i] then
        self.LastSlotModifyList[i] = nil
      end
      Index = Index + 1
      if i == UE.ERGGenericModifySlot.SLOT_Assistance or i == UE.ERGGenericModifySlot.SLOT_Q then
        UpdateVisibility(GenericModifyItem, false)
      end
    end
    HideOtherItem(self.VerticalBoxGenericModifyList, Index)
    local AllPassiveModifies = LogicGenericModify:GetAllPassiveModifies()
    local AllSpecificModifies = RGSpecificModifyComponent:GetActivatedModifies()
    if bIsShowAll then
      Index = 1
      for i, v in iterator(AllPassiveModifies) do
        local GenericModifyItem = GetOrCreateItem(self.WrapBoxGenericModifyList, Index, HUD_GenericModifyItemCls)
        GenericModifyItem:InitHudGenericModifyItem(v, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self, true, 0, nil, bIsShowAll)
        Index = Index + 1
      end
      for i, v in iterator(AllSpecificModifies) do
        local GenericModifyItem = GetOrCreateItem(self.WrapBoxGenericModifyList, Index, HUD_GenericModifyItemCls)
        GenericModifyItem:InitHudSpecificModifyItem(v, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self, true, 0, nil, bIsShowAll)
        Index = Index + 1
      end
    else
      local TotalNum = AllPassiveModifies:Length() + AllSpecificModifies:Length()
      local ModifyData
      if AllPassiveModifies:IsValidIndex(AllPassiveModifies:Length()) then
        ModifyData = AllPassiveModifies:Get(AllPassiveModifies:Length())
      end
      local SpecificModifyData
      if AllSpecificModifies:IsValidIndex(AllSpecificModifies:Length()) then
        SpecificModifyData = AllSpecificModifies:Get(AllSpecificModifies:Length())
      end
      local IsPlayFirstAnim = false
      local Item = self.VerticalBoxGenericModifyList:GetChildAt(Index - 1)
      if not Item then
        IsPlayFirstAnim = true
      end
      if LogicGenericModify.LastPassiveSlotStatus == ELastPassiveSlotStatus.bIsFromSpecific then
        if SpecificModifyData then
          local GenericModifyItem = GetOrCreateItem(self.VerticalBoxGenericModifyList, Index, HUD_GenericModifyItemCls)
          self.SlotToGenericModifyItem[UE.ERGGenericModifySlot.None] = GenericModifyItem
          if self.bIsCanShowTips then
            GenericModifyItem:InitHudSpecificModifyItem(SpecificModifyData, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self, true, TotalNum, self.SelectClick, bIsShowAll)
          else
            GenericModifyItem:InitHudSpecificModifyItem(SpecificModifyData, UE.ERGGenericModifySlot.None, nil, self, true, TotalNum, self.SelectClick, bIsShowAll)
          end
          if not (self.LastSlotModifyList and self.LastSlotModifyList[Index]) or self.LastSlotModifyList[Index] ~= SpecificModifyData.ModifyId then
            if self.CanPlayAnim then
              GenericModifyItem:PlayAcquireAnim(IsPlayFirstAnim)
              self:PlayAcquireTipAnim()
            end
            self.LastSlotModifyList[Index] = SpecificModifyData.ModifyId
          end
        elseif ModifyData then
          local GenericModifyItem = GetOrCreateItem(self.VerticalBoxGenericModifyList, Index, HUD_GenericModifyItemCls)
          self.SlotToGenericModifyItem[UE.ERGGenericModifySlot.None] = GenericModifyItem
          if self.bIsCanShowTips then
            GenericModifyItem:InitHudGenericModifyItem(ModifyData, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self, true, TotalNum, self.SelectClick, bIsShowAll)
          else
            GenericModifyItem:InitHudGenericModifyItem(ModifyData, UE.ERGGenericModifySlot.None, nil, self, true, TotalNum, self.SelectClick, bIsShowAll)
          end
          if not (self.LastSlotModifyList and self.LastSlotModifyList[Index]) or self.LastSlotModifyList[Index] ~= ModifyData.ModifyId then
            if self.CanPlayAnim then
              GenericModifyItem:PlayAcquireAnim(IsPlayFirstAnim)
              self:PlayAcquireTipAnim()
            end
            self.LastSlotModifyList[Index] = ModifyData.ModifyId
          end
        end
      elseif LogicGenericModify.LastPassiveSlotStatus == ELastPassiveSlotStatus.bIsFromGenericModify then
        if ModifyData then
          local GenericModifyItem = GetOrCreateItem(self.VerticalBoxGenericModifyList, Index, HUD_GenericModifyItemCls)
          self.SlotToGenericModifyItem[UE.ERGGenericModifySlot.None] = GenericModifyItem
          if self.bIsCanShowTips then
            GenericModifyItem:InitHudGenericModifyItem(ModifyData, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self, true, TotalNum, self.SelectClick, bIsShowAll)
          else
            GenericModifyItem:InitHudGenericModifyItem(ModifyData, UE.ERGGenericModifySlot.None, nil, self, true, TotalNum, self.SelectClick, bIsShowAll)
          end
          if not (self.LastSlotModifyList and self.LastSlotModifyList[Index]) or self.LastSlotModifyList[Index] ~= ModifyData.ModifyId then
            if self.CanPlayAnim then
              GenericModifyItem:PlayAcquireAnim(IsPlayFirstAnim)
              self:PlayAcquireTipAnim()
            end
            self.LastSlotModifyList[Index] = ModifyData.ModifyId
          end
        elseif SpecificModifyData then
          local GenericModifyItem = GetOrCreateItem(self.VerticalBoxGenericModifyList, Index, HUD_GenericModifyItemCls)
          self.SlotToGenericModifyItem[UE.ERGGenericModifySlot.None] = GenericModifyItem
          if self.bIsCanShowTips then
            GenericModifyItem:InitHudSpecificModifyItem(SpecificModifyData, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self, true, TotalNum, self.SelectClick, bIsShowAll)
          else
            GenericModifyItem:InitHudSpecificModifyItem(SpecificModifyData, UE.ERGGenericModifySlot.None, nil, self, true, TotalNum, self.SelectClick, bIsShowAll)
          end
          if not (self.LastSlotModifyList and self.LastSlotModifyList[Index]) or self.LastSlotModifyList[Index] ~= SpecificModifyData.ModifyId then
            if self.CanPlayAnim then
              GenericModifyItem:PlayAcquireAnim(IsPlayFirstAnim)
              self:PlayAcquireTipAnim()
            end
            self.LastSlotModifyList[Index] = SpecificModifyData.ModifyId
          end
        end
      end
      Index = 1
    end
    self.CanPlayAnim = false
    HideOtherItem(self.WrapBoxGenericModifyList, Index)
  end
end
function WBP_HUD_GenericModifyList_C:PlayAcquireTipAnim()
  self.CanvasPanelInteract:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  self:PlayAnimationForward(self.ani_buttonB_in)
end
function WBP_HUD_GenericModifyList_C:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTips(Data.ModifyId, false)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    UpdateVisibility(self.WBP_GenericModifyBagTips, true)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end
function WBP_HUD_GenericModifyList_C:HideMask()
  self:SelectClick(false)
end
function WBP_HUD_GenericModifyList_C:SelectClick(bIsShow, CanPlayAnim)
  if bIsShow then
    self.ShowStatus = ShowStatus.ShowAll
  else
    self.ShowStatus = ShowStatus.Normal
  end
  UpdateVisibility(self.CanvasPanelMask, bIsShow)
  self.CanPlayAnim = CanPlayAnim
  self:InitHudGenericModifyList(bIsShow)
end
function WBP_HUD_GenericModifyList_C:ShowAllNoMask()
  self.ShowStatus = ShowStatus.ShowAllNoMask
  UpdateVisibility(self.CanvasPanelMask, false)
  self:InitHudGenericModifyList(true)
end
function WBP_HUD_GenericModifyList_C:HighLightModifyItem(Slot, bIsHighlight)
  for k, v in pairs(self.SlotToGenericModifyItem) do
    v:HightLight(false)
  end
  if self.SlotToGenericModifyItem[Slot] then
    self.SlotToGenericModifyItem[Slot]:HightLight(bIsHighlight)
  end
end
function WBP_HUD_GenericModifyList_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_HUD_GenericModifyList_C:Destruct()
  self.Overridden.Destruct(self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
  end
  UnListenObjectMessage(GMP.MSG_World_GenericModify_OnUpdateTeamSpirit, self)
end
function WBP_HUD_GenericModifyList_C:InitFirstItemLeftNavTargetWidget(Widget)
  self.ItemDownNavWidget = Widget
end
function WBP_HUD_GenericModifyList_C:ItemDownNav()
  if self.ShowStatus == ShowStatus.ShowAll then
    return self.WBP_HUD_GenericModifyItem
  elseif UE.RGUtil.IsUObjectValid(self.ItemDownNavWidget) then
    return self.ItemDownNavWidget
  end
  return nil
end
function WBP_HUD_GenericModifyList_C:ItemFirst_1_LeftNav()
  if CheckIsVisility(self.WBP_HUD_GenericModifyItem_First_8) then
    return self.WBP_HUD_GenericModifyItem_First_8
  end
  return self.WBP_HUD_GenericModifyItem_First_5
end
function WBP_HUD_GenericModifyList_C:ItemFirst_5_RightNav()
  if CheckIsVisility(self.WBP_HUD_GenericModifyItem_First_8) then
    return self.WBP_HUD_GenericModifyItem_First_8
  end
  return self.WBP_HUD_GenericModifyItem_First_1
end
return WBP_HUD_GenericModifyList_C
