local AttributeModityData = require("Modules.AttributeModity.AttributeModityData")
local WBP_ScrollPickUpTipsView_C = UnLua.Class()
local ScrollSetTipsItemPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetPickupTipsItem.WBP_ScrollSetPickupTipsItem_C"
local InteractDuration = 0.4
local InteractTimerRate = 0.02
local NormalSizeY = 212
local ExpandName = "ViewFullAttributeList"
local bIsSetExpand = false
function WBP_ScrollPickUpTipsView_C:Construct()
  self.Overridden.Construct(self)
  self.BenchMark = "BenchMark"
  bIsSetExpand = false
  UpdateVisibility(self.WBP_InteractTipWidgetShare, false)
  UpdateVisibility(self.WBP_InteractTipWidgetDiscard, false)
  UpdateVisibility(self.WBP_InteractTipWidgetShareAndMark, false)
end
function WBP_ScrollPickUpTipsView_C:ListenForBenchInputAction()
  if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBag or self.ScrollTipsOpenType == EScrollTipsOpenType.EFromPickup or self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBagPickupList then
    self:ListenForBenchInputActionReleased()
    self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.RefreshProgress
    }, InteractTimerRate, true)
    self.StartTime = 0
    self:UpdateProgress(-1)
  end
end
function WBP_ScrollPickUpTipsView_C:ListenForExpandInputAction()
  self.bIsShowComplete = true
  local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.VerticalBoxScrollSet)
  if not slotCanvas then
    return
  end
  slotCanvas:SetAutoSize(true)
  self:UpdateTipsItemList(true)
end
function WBP_ScrollPickUpTipsView_C:ListenForRetractInputAction()
  self.bIsShowComplete = false
  local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.VerticalBoxScrollSet)
  if not slotCanvas then
    return
  end
  slotCanvas:SetAutoSize(true)
  self:UpdateTipsItemList(false)
end
function WBP_ScrollPickUpTipsView_C:ShareAndMarkModify()
  if self:CheckPickUpCanShare() then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if not Character or not Character.AttributeModifyComponent then
      return
    end
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return
    end
    local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
    if not PlayerMiscComp then
      return
    end
    PlayerMiscComp:SharePickupAttributeModify(Logic_Scroll.PreOptimalTarget, Character)
    UpdateVisibility(self.WBP_InteractTipWidgetShareAndMark, false)
    local MarkHandle = PC:GetComponentByClass(UE.URGMarkHandle:StaticClass())
    if not MarkHandle then
      return
    end
    local MarkInfo = UE.FMarkInfo()
    MarkInfo.TargetActor = Logic_Scroll.PreOptimalTarget
    MarkInfo.HitLocation = Logic_Scroll.PreOptimalTarget:K2_GetActorLocation()
    MarkInfo.Owner = Character
    MarkHandle:ServerAddMark(MarkInfo)
  end
end
function WBP_ScrollPickUpTipsView_C:RefreshProgress()
  if self.StartTime >= InteractDuration then
    if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBag or self.ScrollTipsOpenType == EScrollTipsOpenType.EFromShop then
      local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
      if Character and Character.AttributeModifyComponent then
        print("WBP_ScrollPickUpTipsView_C:RefreshProgress", self.AttributeModifyId)
        LogicAudio.OnDropReel()
        Character.AttributeModifyComponent:ShareModify(self.AttributeModifyId)
      end
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromPickup then
      if not self:CheckPickUpCanShare() then
        return
      end
      self:ShareAndMarkModify()
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBagPickupList then
      if self.TargetScrollPickupItem == nil or nil == self.TargetScrollPickupItem.Target then
        return
      end
      local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
      if not Character or not Character.AttributeModifyComponent then
        return
      end
      local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
      if not PC then
        return
      end
      local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
      if not PlayerMiscComp then
        return
      end
      Logic_Scroll.ShareModify(self.TargetScrollPickupItem.ScrollId)
      local MarkHandle = PC:GetComponentByClass(UE.URGMarkHandle:StaticClass())
      if not MarkHandle then
        return
      end
    end
    self:ListenForBenchInputActionReleased()
  else
    self.StartTime = self.StartTime + InteractTimerRate
    self:UpdateProgress(self.StartTime / InteractDuration)
  end
end
function WBP_ScrollPickUpTipsView_C:ShowBuyTipPanel()
  local AllChildren = self.TipsPanel:GetAllChildren()
  for index, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_ScrollPickUpTipsView_C:CheckPickUpCanShare()
  if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBagPickupList then
    if self.TargetScrollPickupItem and self.TargetScrollPickupItem.Target then
      return not self.TargetScrollPickupItem.Target.IsShared
    end
    return false
  else
    if not Logic_Scroll.PreOptimalTarget then
      print(" WBP_ScrollPickUpTipsView_C:CheckCanShare PreOptimalTarget IsNull")
      return false
    end
    if not Logic_Scroll.PreOptimalTarget.ModifyId then
      print(" WBP_ScrollPickUpTipsView_C:CheckCanShare PreOptimalTarget ModifyId IsNull")
      return false
    end
    return not Logic_Scroll.PreOptimalTarget:IsShared()
  end
end
function WBP_ScrollPickUpTipsView_C:UpdateProgress(Percent)
end
function WBP_ScrollPickUpTipsView_C:ListenForBenchInputActionReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  self:UpdateProgress(-1)
  self.StartTime = 0
end
function WBP_ScrollPickUpTipsView_C:InitScrollTipsView(ScrollId, ScrollTipsOpenTypeParam, TargetScrollPickupItem, bIsNeedInitParam, UserId)
  self.UserId = UserId
  print("WBP_ScrollPickUpTipsView_C:InitScrollTipsView", ScrollId, ScrollTipsOpenTypeParam, TargetScrollPickupItem, bIsNeedInitParam)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollPickUpTipsView_C:InitScrollSetTips not DTSubsystem")
    return nil
  end
  local bIsNeedInit = bIsNeedInitParam
  if nil == bIsNeedInitParam then
    bIsNeedInit = true
  end
  if bIsNeedInit then
    self:Reset()
    self.TargetScrollPickupItem = TargetScrollPickupItem
    if ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromBag then
      if IsListeningForInputAction(self, self.BenchMark) then
        StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Pressed)
        StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Released)
      end
      if IsListeningForInputAction(self, ExpandName) then
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Pressed)
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Released)
      end
      if not IsListeningForInputAction(self, ExpandName) then
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Pressed, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForExpandInputAction
        })
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Released, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForRetractInputAction
        })
      end
    elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromPickup or ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromBagPickupList then
      if IsListeningForInputAction(self, ExpandName) then
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Pressed)
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Released)
      end
      if not IsListeningForInputAction(self, ExpandName) then
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Pressed, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForExpandInputAction
        })
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Released, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForRetractInputAction
        })
      end
      if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PickupTimer) then
        self.PickupTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
          self,
          self.TickRefreshPickupTips
        }, 0.2, true)
      end
    elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromShop then
      if not IsListeningForInputAction(self, ExpandName) then
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Pressed, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForExpandInputAction
        })
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Released, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForRetractInputAction
        })
      end
    elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromTeamDamage then
      if IsListeningForInputAction(self, ExpandName) then
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Pressed)
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Released)
      end
      if not IsListeningForInputAction(self, ExpandName) then
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Pressed, true, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForExpandInputAction
        })
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Released, true, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForRetractInputAction
        })
      end
    else
      if IsListeningForInputAction(self, ExpandName) then
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Pressed)
        StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Released)
      end
      if not IsListeningForInputAction(self, ExpandName) then
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Pressed, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForExpandInputAction
        })
        ListenForInputAction(ExpandName, UE.EInputEvent.IE_Released, false, {
          self,
          WBP_ScrollPickUpTipsView_C.ListenForRetractInputAction
        })
      end
    end
    self:ListenForRetractInputAction()
  end
  self.AttributeModifyId = ScrollId
  self.ScrollTipsOpenType = ScrollTipsOpenTypeParam
  self:UpdateScrollTipsView(ScrollTipsOpenTypeParam, ScrollId)
end
function WBP_ScrollPickUpTipsView_C:UpdateScrollTipsView(ScrollTipsOpenTypeParam, ScrollId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollPickUpTipsView_C:UpdateScrollTipsView not DTSubsystem")
    return nil
  end
  local bIsShowFull = false
  local bIsDuplicated = false
  if ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromPickup or ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromBagPickupList then
    bIsShowFull = Logic_Scroll:CheckScrollIsFull()
    bIsDuplicated = Logic_Scroll:CheckScrollIsDuplicated(ScrollId)
  end
  UpdateVisibility(self.CanvasPanelFull, bIsShowFull)
  UpdateVisibility(self.CanvasPanelScrollDuplicated, bIsDuplicated)
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(ScrollId, nil)
  if ResultModify then
    self.RGTextTitle:SetText(AttributeModifyRow.Name)
    UE.URGBlueprintLibrary.SetImageBrushFromAssetPath(self.URGImageScrollIcon, UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(AttributeModifyRow.SpriteIcon))
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if RGLogicCommandDataSubsystem then
      local InscriptionDesc = GetLuaInscriptionDesc(AttributeModifyRow.Inscription, 1)
      self.RichTextBlockDesc:SetText(InscriptionDesc)
    end
    self:UpdateTipsItemList(self.bIsShowComplete)
    local ResultRarity, RarityRow = GetRowData(DT.DT_ItemRarity, tostring(tonumber(AttributeModifyRow.Rarity)))
    if ResultRarity then
      UE.URGBlueprintLibrary.SetImageBrushFromAssetPath(self.ImageRarity, UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(RarityRow.AttributeModifyTipsRareBg))
    end
    local color = self.RarityToColor:Find(AttributeModifyRow.Rarity)
    if color then
      self.glow_di:SetColorAndOpacity(color)
    end
    if AttributeModifyRow.Rarity == UE.ERGItemRarity.EIR_Legend then
      UpdateVisibility(self.effect_yellow, true)
      UpdateVisibility(self.effect_blue, false)
    else
      UpdateVisibility(self.effect_yellow, false)
      UpdateVisibility(self.effect_blue, true)
    end
    HideOtherItem(self.VerticalBoxScrollSet, AttributeModifyRow.SetArray:Length() + 1)
    UpdateVisibility(self.OverlayRoot, AttributeModifyRow.SetArray:Num() > 0)
    UpdateVisibility(self.PublicTag, not self:CheckPickUpCanShare())
    UpdateVisibility(self.PrivateTag, self:CheckPickUpCanShare())
    UpdateVisibility(self.WBP_InteractTipWidgetLike, false)
    UpdateVisibility(self.CanvasPanelLikePlayer, false)
    if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBag then
      UpdateVisibility(self.WBP_ScrollInteractItem_common, false)
      UpdateVisibility(self.CanvasPanelMouseOperator_Common, false)
      UpdateVisibility(self.CanvasPanelMouseOperatorEquip_Common, false)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromPickup then
      UpdateVisibility(self.WBP_ScrollInteractItem_common, true)
      UpdateVisibility(self.CanvasPanelMouseOperator_Common, false)
      UpdateVisibility(self.CanvasPanelMouseOperatorEquip_Common, false)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromTeamDamage then
      UpdateVisibility(self.WBP_ScrollInteractItem_common, false)
      UpdateVisibility(self.CanvasPanelMouseOperator_Common, false)
      UpdateVisibility(self.CanvasPanelMouseOperatorEquip_Common, false)
      local bIsRequsingAttributeModity = AttributeModityData:GetRequesing(self.UserId) == ScrollId
      local bIsRequsingUser = AttributeModityData:GetRequesing(self.UserId) ~= nil
      local bIsRefuseUser = nil ~= AttributeModityData:GetRefused(self.UserId)
      UpdateVisibility(self.CanvasPanelRequesting, bIsRequsingAttributeModity)
      UpdateVisibility(self.CanvasPanelRequestDenied, bIsRefuseUser)
      UpdateVisibility(self.WBP_InteractTipWidgetLike, not bIsRequsingUser and not bIsRefuseUser)
      self:UpdateLikePlayer(ScrollId)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromScrollSlot then
      UpdateVisibility(self.WBP_ScrollInteractItem_common, false)
      UpdateVisibility(self.CanvasPanelMouseOperator_Common, true)
      UpdateVisibility(self.CanvasPanelMouseOperatorEquip_Common, false)
      UpdateVisibility(self.PublicTag, false)
      UpdateVisibility(self.PrivateTag, false)
      self:UpdateLikePlayer(ScrollId)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromScrollSlotSettlement or self.ScrollTipsOpenType == EScrollTipsOpenType.EFromSaveGrowthSnap then
      UpdateVisibility(self.WBP_ScrollInteractItem_common, false)
      UpdateVisibility(self.CanvasPanelMouseOperator_Common, false)
      UpdateVisibility(self.CanvasPanelMouseOperatorEquip_Common, false)
      UpdateVisibility(self.PublicTag, false)
      UpdateVisibility(self.PrivateTag, false)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBagPickupList then
      UpdateVisibility(self.WBP_ScrollInteractItem_common, false)
      UpdateVisibility(self.CanvasPanelMouseOperator_Common, false)
      UpdateVisibility(self.CanvasPanelMouseOperatorEquip_Common, true)
      self:UpdateLikePlayer(ScrollId)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromShop then
      UpdateVisibility(self.WBP_ScrollInteractItem_common, false)
      UpdateVisibility(self.CanvasPanelMouseOperator_Common, true)
      UpdateVisibility(self.CanvasPanelMouseOperatorEquip_Common, false)
      UpdateVisibility(self.PublicTag, false)
      UpdateVisibility(self.PrivateTag, false)
    end
  end
end
function WBP_ScrollPickUpTipsView_C:TickRefreshPickupTips()
  UpdateVisibility(self.PublicTag, not self:CheckPickUpCanShare())
  UpdateVisibility(self.PrivateTag, self:CheckPickUpCanShare())
  local bIsShowFull = false
  local bIsDuplicated = false
  if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromPickup or self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBagPickupList then
    bIsShowFull = Logic_Scroll:CheckScrollIsFull()
    bIsDuplicated = Logic_Scroll:CheckScrollIsDuplicated(self.AttributeModifyId)
  elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromScrollSlot or self.ScrollTipsOpenType == EScrollTipsOpenType.EFromShop or self.ScrollTipsOpenType == EScrollTipsOpenType.EFromScrollSlotSettlement then
    UpdateVisibility(self.PublicTag, false)
    UpdateVisibility(self.PrivateTag, false)
  end
  UpdateVisibility(self.CanvasPanelFull, bIsShowFull)
  UpdateVisibility(self.CanvasPanelScrollDuplicated, bIsDuplicated)
end
function WBP_ScrollPickUpTipsView_C:UpdateTipsItemList(bIsComplete)
  bIsComplete = true
  local ResultModify, AttributeModifyRow = GetRowData(DT.DT_AttributeModify, tostring(self.AttributeModifyId))
  if ResultModify then
    local ScrollSetTipsItemCls = UE.UClass.Load(ScrollSetTipsItemPath)
    for i, v in iterator(AttributeModifyRow.SetArray) do
      local ScrollSetTipsItem = GetOrCreateItem(self.VerticalBoxScrollSet, i, ScrollSetTipsItemCls)
      ScrollSetTipsItem:InitScrollSetTipsItem(v, self.AttributeModifyId, bIsComplete, self.ScrollTipsOpenType, self.UserId)
    end
  end
end
function WBP_ScrollPickUpTipsView_C:Show(bIsFlip)
  local TipsSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.VerticalBoxTips)
  local SetRootSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.OverlayRoot)
  if bIsFlip then
    TipsSlot:SetPosition(self.FlipTipSlotPosXOffset)
    SetRootSlot:SetPosition(self.FlipRootSlotPosXOffset)
  else
    TipsSlot:SetPosition(self.TipSlotPosXOffset)
    SetRootSlot:SetPosition(self.RootPosXOffset)
  end
  UpdateVisibility(self, true)
end
function WBP_ScrollPickUpTipsView_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Hidden)
  self:Reset()
end
function WBP_ScrollPickUpTipsView_C:Reset()
  self:ListenForRetractInputAction()
  self:ListenForBenchInputActionReleased()
  StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Released)
  StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Released)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PickupTimer) then
    print("ScrollPckupTipsView:ClearPickupTimer")
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PickupTimer)
    self.PickupTimer = nil
  end
  self.TargetScrollPickupItem = nil
end
function WBP_ScrollPickUpTipsView_C:Destruct()
  self.Overridden.Destruct(self)
  self:Reset()
end
function WBP_ScrollPickUpTipsView_C:UpdateLikePlayer(AttributeModifyId)
  local IsOwner = tonumber(self.UserId) == tonumber(DataMgr.GetUserId())
  local LikeUserIdList = UE.URGGameplayLibrary.GetItemRequestUsers(self, tonumber(self.UserId), AttributeModifyId)
  local LikeUserIdTable = {}
  for i, UserId in iterator(LikeUserIdList) do
    if IsOwner and tonumber(UserId) ~= tonumber(DataMgr.GetUserId()) then
      table.insert(LikeUserIdTable, UserId)
    end
    if not IsOwner and tonumber(UserId) == tonumber(DataMgr.GetUserId()) then
      table.insert(LikeUserIdTable, UserId)
    end
  end
  if #LikeUserIdTable > 0 then
    UpdateVisibility(self.CanvasPanelLikePlayer, true)
    for Index, UserId in ipairs(LikeUserIdTable) do
      local LikeUserInfoWidget = GetOrCreateItem(self.HrzBox_LikeUserInfoList, Index, self.WBP_AttributeModifyLikeUserInfo:GetClass())
      LikeUserInfoWidget:InitInfo(UserId)
    end
    HideOtherItem(self.HrzBox_LikeUserInfoList, #LikeUserIdTable + 1)
  else
    UpdateVisibility(self.CanvasPanelLikePlayer, false)
  end
end
return WBP_ScrollPickUpTipsView_C
