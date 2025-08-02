local WBP_ModScrollView_C = UnLua.Class()
local UGameplayStatics = UE.UGameplayStatics
local ScrollSetItemPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetItem.WBP_ScrollSetItem_C"
local ScrollItemPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollItem.WBP_ScrollItem_C"
local BattleRoleInfoActorPath = "/Game/Rouge/UI/Lobby/Role/BP_BattleRoleInfoActor.BP_BattleRoleInfoActor_C"
local TickRate = 0.02
local RefreshPickupListInterval = 0.2
local PickupArySort = function(A, B)
  if A.IsShared ~= B.IsShared then
    return B.IsShared
  elseif A.IsShine ~= B.IsShine then
    return A.IsShine
  else
    local ResultA, RowDataA = GetRowData(DT.DT_AttributeModify, tostring(A.ModifyId))
    local ResultB, RowDataB = GetRowData(DT.DT_AttributeModify, tostring(B.ModifyId))
    if ResultA and ResultB then
      if RowDataA.Rarity ~= RowDataB.Rarity then
        return RowDataA.Rarity > RowDataB.Rarity
      else
        return A.ModifyId < B.ModifyId
      end
    else
      return false
    end
  end
end

function WBP_ModScrollView_C:Construct()
  self.Overridden.Construct(self)
  EventSystem.AddListener(self, EventDef.Battle.OnControlledPawnChanged, WBP_ModScrollView_C.BindOnControlledPawnChanged)
  EventSystem.AddListener(self, EventDef.MainPanel.MainPanelChanged, WBP_ModScrollView_C.BindOnMainPanelChanged)
  ListenObjectMessage(nil, GMP.MSG_Level_AttributeStore_AddItem, self, self.AttributeStore_AddItem)
  ListenObjectMessage(nil, GMP.MSG_Level_AttributeStore_RemoveItem, self, self.AttributeStore_RemoveItem)
  self.ShowAttributeModifyItems = {}
  self:UpdateScrollSetList()
  self:UpdateScrollList()
  for i = 1, Logic_Scroll.MaxScrollNum do
    local SlotName = string.format("WBP_ScrollItemBg%d", i)
    self[SlotName]:InitScrollItemSlot()
  end
  self.WBP_ScrollIRemoveDropBg:InitScrollRemoveDropBg()
  self.ActorSubSys = UE.URGActorSubsystem.GetSubsystem(self)
  self.BP_ButtonMakeAllPublic.OnClicked:Add(self, self.OnMakeAllPublicClick)
  self.BP_ButtonPickupAll.OnClicked:Add(self, self.OnPickupAllClick)
  self.WBP_OperatingHintsFour.Btn_Main.OnClicked:Add(self, self.OnEscClick)
end

function WBP_ModScrollView_C:OnOpen(MainPanel)
  self.PickupIdx = -1
  self.MainPanel = MainPanel
  if self:IsAnimationPlaying(self.Ani_in_switch) then
    self:StopAnimation(self.Ani_in_switch)
  end
  self:PlayAnimation(self.Ani_in)
  self:UpdateScrollSetList()
  self:UpdateScrollList()
  self.WBP_ScrollItemBg1:SetFocus()
end

function WBP_ModScrollView_C:GamePadFocus()
  self.WBP_ScrollItemBg1:SetFocus()
end

function WBP_ModScrollView_C:UpdateUICaptureBgActor(bIsShow)
  self.bIsShow = bIsShow
  if self.Capture then
    self.Capture.SceneCaptureComponent2D.bCaptureEveryFrame = bIsShow
  else
    local CameraList = UE.TArray(UE.AActor)
    UE.UGameplayStatics.GetAllActorsWithTag(self, "RoleMainCapture", CameraList)
    if CameraList:IsValidIndex(1) then
      self.Capture = CameraList:Get(1)
      self.Capture.SceneCaptureComponent2D.bCaptureEveryFrame = bIsShow
    end
  end
  self:OnResizeCapture()
end

function WBP_ModScrollView_C:OnResizeCapture()
  if not self.bIsShow or UE.RGUtil.IsUObjectValid(self.Capture) then
  end
end

function WBP_ModScrollView_C:BindOnMainPanelChanged(LastActiveWidget, CurActiveWidget, MainPanel)
  self.MainPanel = MainPanel
  if CurActiveWidget == self then
    if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PickupTimer) then
      self.PickupTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        self.TickScroll
      }, TickRate, true)
    end
    self.PickupTargetItem = nil
    self.RefreshPickuplistTime = 0
    UpdateVisibility(self.URGImageSceneCapture, false)
    UpdateVisibility(self.URGImageBg, true)
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if Character then
    end
    self:UpdatePickupList()
    UE.URGBlueprintLibrary.DisablePostProcessMaterial()
    self:PlayAnimation(self.Ani_in_switch)
    self.WBP_ScrollDetailTipsView:PlayAnimation(self.WBP_ScrollDetailTipsView.Ani_in)
    self:BindOnControlledPawnChanged()
    self:UpdateScrollSetList()
    self:UpdateScrollList()
    self.WBP_ScrollItemBg1:SetFocus()
    self.PickupIdx = -1
    self:RegisterScrollRecipient(self.WBP_ScrollDetailTipsView.ScrollBoxDetails)
  elseif LastActiveWidget == self and CurActiveWidget ~= self then
    self:Reset()
    self:UnBindOnControlledPawnChanged()
    UE.UWidgetBlueprintLibrary.CancelDragDrop()
    UE.URGBlueprintLibrary.EnablePostProcessMaterial()
    UpdateVisibility(self.URGImageSceneCapture, false)
    self.PickupIdx = -1
  end
end

function WBP_ModScrollView_C:BindOnControlledPawnChanged()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  print("WBP_ModScrollView_C:BindOnControlledPawnChanged", Character)
  if UE.RGUtil.IsUObjectValid(Character) and Character.AttributeModifyComponent then
    print("WBP_ModScrollView_C:BindOnControlledPawnChanged111111", Character)
    Character.AttributeModifyComponent.OnAddModify:Remove(self, self.OnAddModify)
    Character.AttributeModifyComponent.OnRemoveModify:Remove(self, self.OnRemoveModify)
    Character.AttributeModifyComponent.OnAddSet:Remove(self, self.OnAddSet)
    Character.AttributeModifyComponent.OnRemoveSet:Remove(self, self.OnRemoveSet)
    Character.AttributeModifyComponent.OnChangeSet:Remove(self, self.OnChangeSet)
    Character.AttributeModifyComponent.OnAddModify:Add(self, self.OnAddModify)
    Character.AttributeModifyComponent.OnRemoveModify:Add(self, self.OnRemoveModify)
    Character.AttributeModifyComponent.OnAddSet:Add(self, self.OnAddSet)
    Character.AttributeModifyComponent.OnRemoveSet:Add(self, self.OnRemoveSet)
    Character.AttributeModifyComponent.OnChangeSet:Add(self, self.OnChangeSet)
  end
end

function WBP_ModScrollView_C:UnBindOnControlledPawnChanged()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  print("WBP_ModScrollView_C:UnBindOnControlledPawnChanged", Character)
  if UE.RGUtil.IsUObjectValid(Character) and Character.AttributeModifyComponent then
    print("WBP_ModScrollView_C:UnBindOnControlledPawnChanged111111", Character)
    Character.AttributeModifyComponent.OnAddModify:Remove(self, self.OnAddModify)
    Character.AttributeModifyComponent.OnRemoveModify:Remove(self, self.OnRemoveModify)
    Character.AttributeModifyComponent.OnAddSet:Remove(self, self.OnAddSet)
    Character.AttributeModifyComponent.OnRemoveSet:Remove(self, self.OnRemoveSet)
    Character.AttributeModifyComponent.OnChangeSet:Remove(self, self.OnChangeSet)
  end
end

function WBP_ModScrollView_C:TickScroll()
end

function WBP_ModScrollView_C:AttributeStore_AddItem()
  print("WBP_ModScrollView_C  AttributeStore_AddItem")
  self:UpdatePickupList()
end

function WBP_ModScrollView_C:AttributeStore_RemoveItem()
  print("WBP_ModScrollView_C  AttributeStore_RemoveItem")
  self:UpdatePickupList()
end

function WBP_ModScrollView_C:UpdatePickupList()
  if not UE.RGUtil.IsUObjectValid(self.ActorSubSys) then
    self.ActorSubSys = UE.URGActorSubsystem.GetSubsystem(self)
    print("WBP_ModScrollView_C:UpdatePickupList Re Find ActorSubSys!!!")
  end
  if UE.RGUtil.IsUObjectValid(self.ActorSubSys) then
    local Character = UGameplayStatics.GetPlayerCharacter(self, 0)
    if Character then
      local OutTargetAry = UE.TArray(UE.AActor)
      self.ActorSubSys:GetActorsOfClassAndRange(UE.ARGPickup_AttributeModify:StaticClass(), Character:K2_GetActorLocation(), self.ScrollPickupRadius, OutTargetAry)
      local GS = UE.UGameplayStatics.GetGameState(self)
      if not GS then
        print("WBP_ModScrollView_C:UpdatePickupList GS is Null")
        return
      end
      self.ShowAttributeModifyDatas = {}
      self.ShowAttributeModifyItems = {}
      local AttributeModifyStore = GS:GetComponentByClass(UE.URGAttributeModifyStore:StaticClass())
      local PublicModifyItems = AttributeModifyStore:GetPublicModifyItems()
      local TBPublicModifyItems = {}
      TBPublicModifyItems = PublicModifyItems:ToTable()
      for i, v in ipairs(TBPublicModifyItems) do
        if -1 ~= v.ModifyId and 0 ~= v.Count then
          table.insert(self.ShowAttributeModifyDatas, {
            Target = v,
            IsShared = true,
            IsShine = false,
            ModifyId = v.ModifyId
          })
        end
      end
      local SelfModifyItems = AttributeModifyStore:GetUserModifyItems(tonumber(DataMgr.GetUserId()))
      local TBSelfModifyItems = {}
      TBSelfModifyItems = SelfModifyItems:ToTable()
      for i, v in ipairs(TBSelfModifyItems) do
        if -1 ~= v.ModifyId and 0 ~= v.Count then
          table.insert(self.ShowAttributeModifyDatas, {
            Target = v,
            IsShared = false,
            IsShine = false,
            ModifyId = v.ModifyId
          })
        end
      end
      print("UpdatePickupList   TBPublicModifyItems: ", #TBPublicModifyItems, "       TBSelfModifyItems:  ", #TBSelfModifyItems, "ShowAttributeModifyDatas", #self.ShowAttributeModifyDatas)
      self:CheckActivatedSets()
      table.sort(self.ShowAttributeModifyDatas, PickupArySort)
      local PrivateNum = 0
      for i, v in ipairs(self.ShowAttributeModifyDatas) do
        local Item = GetOrCreateItem(self.ScrollBoxPickupScrollList, i, self.WBP_ScrollPickupItem:GetClass(), true)
        Item:UpdateScrollData(v, self.UpdateShowPickupTipsView, self, i)
        table.insert(self.ShowAttributeModifyItems, Item)
        if not v.IsShared then
          PrivateNum = PrivateNum + 1
        end
      end
      print("UpdatePickupList", #self.ShowAttributeModifyDatas)
      HideOtherItem(self.ScrollBoxPickupScrollList, #self.ShowAttributeModifyDatas + 1)
      UpdateVisibility(self.RGTextPickupNull, #self.ShowAttributeModifyDatas <= 0)
      if not self.PickupIdx then
        self.PickupIdx = -1
      end
      if #self.ShowAttributeModifyDatas > 0 then
        if self.PickupIdx > #self.ShowAttributeModifyDatas then
          self.PickupIdx = #self.ShowAttributeModifyDatas
        end
        if self.PickupIdx > 0 then
          local Item = GetOrCreateItem(self.ScrollBoxPickupScrollList, self.PickupIdx, self.WBP_ScrollPickupItem:GetClass(), true)
          Item:SetFocus()
        end
      elseif self.PickupIdx > 0 then
        self.PickupIdx = -1
        self.WBP_ScrollItemBg1:SetFocus()
      end
    end
  else
    self.ActorSubSys = UE.URGActorSubsystem.GetSubsystem(self)
    print("Re Find ActorSubSys!!!")
  end
end

function WBP_ModScrollView_C:UpdateShowPickupTipsView(bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit, Item)
  print("WBP_ModScrollView_C:UpdateShowPickupTipsView", bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  if ScrollId and ScrollId > 0 then
    self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ScrollId, ScrollTipsOpenType, TargetItem, bIsNeedInit, DataMgr.GetUserId())
    ShowCommonTips(nil, TargetItem, self.WBP_ScrollPickUpTipsView)
  end
  if ScrollTipsOpenType == EScrollTipsOpenType.EFromScrollSlot or ScrollTipsOpenType == EScrollTipsOpenType.EFromBagPickupList then
    self:HighLightSetList(ScrollId, bIsShowTipsView)
  end
  if bIsShowTipsView then
    self.PickupTargetItem = TargetItem
    self.ScrollTipsOpenType = ScrollTipsOpenType
  elseif self.ScrollTipsOpenType == ScrollTipsOpenType then
    self.PickupTargetItem = nil
    self.WBP_ScrollPickUpTipsView:Hide()
  end
end

function WBP_ModScrollView_C:HighLightSetList(ScrollId, bIsHighlight)
  if bIsHighlight then
    local Result, RowData = GetRowData(DT.DT_AttributeModify, tostring(ScrollId))
    if Result then
      for i, v in pairs(RowData.SetArray) do
        if self.ScrollSetMap[v] then
          self.ScrollSetMap[v]:UpdateHighlight(true)
        end
      end
    end
  else
    self:DisSelectSet()
  end
end

function WBP_ModScrollView_C:HighLightDropSlot(bIsHightLight)
  for i = 1, Logic_Scroll.MaxScrollNum do
    local SlotName = string.format("WBP_ScrollItemBg%d", i)
    if bIsHightLight then
      if self[SlotName]:IsEmptySlot() then
        self[SlotName]:UpdateHighlight(true)
        break
      end
    else
      self[SlotName]:UpdateHighlight(false)
    end
  end
end

function WBP_ModScrollView_C:UpdateScrollSetList()
  print("WBP_ModScrollView_C:UpdateScrollSetList")
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if UE.RGUtil.IsUObjectValid(Character) and Character.AttributeModifyComponent then
    local ScrollSetItemCls = UE.UClass.Load(ScrollSetItemPath)
    print("WBP_ModScrollView_C:UpdateScrollSetList", ScrollSetItemCls, Character.AttributeModifyComponent.ActivatedSets:Length())
    self.ScrollSetMap = {}
    local Index = 1
    local MinNum = 0
    local Num = MinNum
    if Num < Character.AttributeModifyComponent.ActivatedSets:Length() then
      Num = Character.AttributeModifyComponent.ActivatedSets:Length()
    end
    for i = 1, Num do
      local v = Character.AttributeModifyComponent.ActivatedSets:Get(i)
      if v and Logic_Scroll:CheckSetIsActived(v) then
        local ScrollSetItem = GetOrCreateItem(self.ScrollBoxScrollSet, Index, ScrollSetItemCls, true)
        if ScrollSetItem then
          ScrollSetItem:InitScrollSetItem(v, self.UpdateScrollSetTips, self)
          self.ScrollSetMap[v.SetId] = ScrollSetItem
          Index = Index + 1
        end
      end
    end
    for i = 1, Num do
      local v = Character.AttributeModifyComponent.ActivatedSets:Get(i)
      if v and not Logic_Scroll:CheckSetIsActived(v) then
        local ScrollSetItem = GetOrCreateItem(self.ScrollBoxScrollSet, Index, ScrollSetItemCls, true)
        if ScrollSetItem then
          ScrollSetItem:InitScrollSetItem(v, self.UpdateScrollSetTips, self)
          self.ScrollSetMap[v.SetId] = ScrollSetItem
          Index = Index + 1
        end
      end
    end
    HideOtherItem(self.ScrollBoxScrollSet, Index)
    UpdateVisibility(self.RGTextSetNull, 1 == Index)
    self.WBP_ScrollDetailTipsView:UpdateScrollSetList(Character.AttributeModifyComponent.ActivatedSets)
  end
end

function WBP_ModScrollView_C.ActivatedSetsSort(FistSet, SecondSet)
  if Logic_Scroll:CheckSetIsActived(FistSet) and not Logic_Scroll:CheckSetIsActived(SecondSet) then
    return true
  end
  if not Logic_Scroll:CheckSetIsActived(FistSet) and Logic_Scroll:CheckSetIsActived(SecondSet) then
    return false
  end
  return false
end

function WBP_ModScrollView_C:UpdateScrollList()
  print("WBP_ModScrollView_C:UpdateScrollList")
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local attrCom
  if UE.RGUtil.IsUObjectValid(Character) then
    attrCom = Character:GetComponentByClass(UE.URGAttributeModifyComponent:StaticClass())
  end
  if UE.RGUtil.IsUObjectValid(attrCom) then
    local ScrollItemCls = UE.UClass.Load(ScrollItemPath)
    local activatedModifyies = attrCom:GetAllActivatedModifies()
    print("WBP_ModScrollView_C:UpdateScrollList", ScrollItemCls, activatedModifyies:Length())
    self.ScrollMap = {}
    local Index = 1
    for i = 1, Logic_Scroll.MaxScrollNum do
      local v
      if activatedModifyies:IsValidIndex(i) then
        v = activatedModifyies:Get(i)
        Index = Index + 1
      end
      local SlotName = string.format("WBP_ScrollItemBg%d", i)
      self[SlotName]:UpdateScrollData(v, self.UpdateShowPickupTipsView, self, i)
      if v then
        if not self.ScrollMap[v] then
          self.ScrollMap[v] = {}
        end
        table.insert(self.ScrollMap[v], self[SlotName])
      end
    end
    if 1 == Index then
      self:UpdateShowPickupTipsView(false, -1, nil, EScrollTipsOpenType.EFromScrollSlot)
    end
    local Ok, Error = pcall(self.WBP_ScrollDetailTipsView.UpdateScrollDescList, self.WBP_ScrollDetailTipsView, activatedModifyies)
    if not Ok then
      UnLua.LogError("WBP_ModScrollView_C:UpdateScrollList Error:", Error)
    end
    self:RefreshModifyShine()
  end
end

function WBP_ModScrollView_C:UpdateRemoveDropBg(bIsShow)
  UpdateVisibility(self.WBP_ScrollIRemoveDropBg, bIsShow)
end

function WBP_ModScrollView_C:UpdateScrollSetTips(bIsShow, ActivatedSetData, ScrollSetItem)
  if bIsShow then
    self:PlayAnimation(self.AniScrollSetTipsShow)
  else
  end
  UpdateVisibility(self.WBP_ScrollSetTips, bIsShow)
  if bIsShow then
    self.WBP_ScrollSetTips:InitScrollSetTips(ActivatedSetData)
    ShowCommonTips(nil, ScrollSetItem, self.WBP_ScrollSetTips)
    local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
    if TipsCanvasSlot then
      local GeometryScrollSetItem = ScrollSetItem:GetCachedGeometry()
      local GeometryCanvasPanelScroll = self.CanvasPanelScroll:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelScroll, GeometryScrollSetItem)
      TipsCanvasSlot:SetPosition(UE.FVector2D(TipsCanvasSlot:GetPosition().X, Pos.Y))
    end
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    local ModifyIds = Character.AttributeModifyComponent:GetAllRelatedActivatedModifies(ActivatedSetData.SetId)
    for i, v in iterator(ModifyIds) do
      if self.ScrollMap and self.ScrollMap[v] then
        for IndexScrollItem, ValueScrollItem in ipairs(self.ScrollMap[v]) do
          ValueScrollItem:UpdateHighlight(bIsShow)
        end
      end
    end
  end
end

function WBP_ModScrollView_C:CheckActivatedSets()
  local AttributeModifySet = {}
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local MinNum = 0
  local Num = MinNum
  local ActivatedSet = {}
  if Num < Character.AttributeModifyComponent.ActivatedSets:Length() then
    Num = Character.AttributeModifyComponent.ActivatedSets:Length()
  end
  for i = 1, Num do
    local v = Character.AttributeModifyComponent.ActivatedSets:Get(i)
    if v and Logic_Scroll:CheckSetIsActived(v) then
      ActivatedSet[v.SetId] = v
    end
  end
  for i, v in ipairs(self.ShowAttributeModifyDatas) do
    local Result, RowData = GetRowData(DT.DT_AttributeModify, tostring(v.ModifyId))
    if Result then
      for index, SetId in ipairs(RowData.SetArray:ToTable()) do
        local ModifySetResult, ModifySetRowData = GetRowData(DT.DT_AttributeModifySet, tostring(SetId))
        if ModifySetResult then
          local ActivatedSetData = ActivatedSet[SetId]
          if ActivatedSet[SetId] then
            v.IsShine = ActivatedSetData.Level >= 3 and ActivatedSetData.Level < Logic_Scroll:GetModifySetMaxLevel(ActivatedSetData)
          end
          if v.IsShine then
            break
          end
        end
      end
    end
  end
end

function WBP_ModScrollView_C:RefreshModifyShine()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local MinNum = 0
  local Num = MinNum
  local ActivatedSet = {}
  if Num < Character.AttributeModifyComponent.ActivatedSets:Length() then
    Num = Character.AttributeModifyComponent.ActivatedSets:Length()
  end
  for i = 1, Num do
    local v = Character.AttributeModifyComponent.ActivatedSets:Get(i)
    if v and Logic_Scroll:CheckSetIsActived(v) then
      ActivatedSet[v.SetId] = v
    end
  end
  for i, v in ipairs(self.ShowAttributeModifyItems) do
    local Result, RowData = GetRowData(DT.DT_AttributeModify, tostring(v.ScrollId))
    if Result then
      for index, SetId in ipairs(RowData.SetArray:ToTable()) do
        local ModifySetResult, ModifySetRowData = GetRowData(DT.DT_AttributeModifySet, tostring(SetId))
        if ModifySetResult then
          local ActivatedSetData = ActivatedSet[SetId]
          if ActivatedSetData then
            v.IsShine = ActivatedSetData.Level >= 3 and ActivatedSetData.Level < Logic_Scroll:GetModifySetMaxLevel(ActivatedSetData)
          end
          if v.IsShine then
            break
          end
        end
      end
    end
    v:RefreshShine(v.IsShine)
  end
end

function WBP_ModScrollView_C:GetAttributeModifySetMinCount(LevelInscriptionMap)
  local minNeedCount = 10
  local LevelInscriptionTable = LevelInscriptionMap:ToTable()
  for Count, Set in pairs(LevelInscriptionTable) do
    if Count < minNeedCount then
      minNeedCount = Count
    end
  end
  return minNeedCount
end

function WBP_ModScrollView_C:DisSelectSet()
  if self.ScrollSetMap then
    for k, v in pairs(self.ScrollSetMap) do
      v:UpdateHighlight(false)
    end
  end
end

function WBP_ModScrollView_C:OnAddModify()
  self:UpdateScrollList()
end

function WBP_ModScrollView_C:OnRemoveModify()
  self:UpdateScrollList()
end

function WBP_ModScrollView_C:OnAddSet()
  self:UpdateScrollSetList()
end

function WBP_ModScrollView_C:OnRemoveSet()
  self:UpdateScrollSetList()
end

function WBP_ModScrollView_C:OnChangeSet()
  self:UpdateScrollList()
  self:UpdateScrollSetList()
end

function WBP_ModScrollView_C:OnMakeAllPublicClick()
  if not self.ShowAttributeModifyDatas then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character or not Character.AttributeModifyComponent then
    return
  end
  for i, v in ipairs(self.ShowAttributeModifyDatas) do
    if not v.IsShared then
      local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
      if not PlayerMiscComp then
        return
      end
      if not v.IsShared then
        for i, actor in iterator(v.Target.ModifyActors) do
          PlayerMiscComp:SharePickupAttributeModify(actor, Character)
        end
      end
    end
  end
end

function WBP_ModScrollView_C:OnPickupAllClick()
  if not self.ShowAttributeModifyDatas then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local MiscHelper = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not MiscHelper then
    return
  end
  local ModifyCount = Character.AttributeModifyComponent.ActivatedModifies:Num()
  for i, v in pairs(self.ShowAttributeModifyDatas) do
    if ModifyCount + i <= Logic_Scroll.MaxScrollNum then
      Logic_Scroll.PickupScroll(v)
    end
  end
  if ModifyCount + #self.ShowAttributeModifyDatas > Logic_Scroll.MaxScrollNum then
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if WaveWindowManager then
      local Param = {}
      WaveWindowManager:ShowWaveWindow(1124, Param)
    end
  end
end

function WBP_ModScrollView_C:OnEscClick()
  if UE.RGUtil.IsUObjectValid(self.MainPanel) then
    self.MainPanel:ExitMainPanel()
  end
end

function WBP_ModScrollView_C:OnExitPanel()
  self:PlayAnimation(self.Ani_out)
end

function WBP_ModScrollView_C:OnClose()
  LogicRole.HideAllHeroLight()
  LogicRole.ChangeRoleSkyLight(false)
  UE.UWidgetBlueprintLibrary.CancelDragDrop()
  UpdateVisibility(self.URGImageSceneCapture, false)
  self:UnBindOnControlledPawnChanged()
  self:Reset()
end

function WBP_ModScrollView_C:Reset()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PickupTimer) then
    print("WBP_ModScrollView_C:ClearPickupTimer")
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PickupTimer)
    self.PickupTimer = nil
  end
  for i = 1, Logic_Scroll.MaxScrollNum do
    local SlotName = string.format("WBP_ScrollItemBg%d", i)
    self[SlotName]:Reset()
  end
  self:UnregisterScrollRecipient(self.WBP_ScrollDetailTipsView.ScrollBoxDetails)
  self.WBP_ScrollPickUpTipsView:Hide()
  self:DisSelectSet()
  self.PickupTargetItem = nil
end

function WBP_ModScrollView_C:Destruct()
  self.Overridden.Destruct(self)
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, WBP_ModScrollView_C.BindOnControlledPawnChanged, self)
  EventSystem.RemoveListener(EventDef.MainPanel.MainPanelChanged, WBP_ModScrollView_C.BindOnMainPanelChanged, self)
  UnListenObjectMessage(GMP.MSG_Level_AttributeStore_AddItem, self)
  UnListenObjectMessage(GMP.MSG_Level_AttributeStore_RemoveItem, self)
  UpdateVisibility(self.URGImageSceneCapture, false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PickupTimer) then
    print("WBP_ModScrollView_C:ClearPickupTimer")
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PickupTimer)
    self.PickupTimer = nil
  end
  self.ActorSubSys = nil
  self:UnBindOnControlledPawnChanged()
  self.BP_ButtonMakeAllPublic.OnClicked:Remove(self, self.OnMakeAllPublicClick)
  self.BP_ButtonPickupAll.OnClicked:Remove(self, self.OnPickupAllClick)
  self.RowInfoList = nil
  self.ScrollSetMap = nil
  self.ScrollMap = nil
end

function WBP_ModScrollView_C:UpatePickupIdx(Idx)
  print("WBP_ModScrollView_C:UpatePickupIdx", self.PickupIdx, Idx)
  self.PickupIdx = Idx
end

function WBP_ModScrollView_C:ScrollPickUpItemRightNav()
  self.PickupIdx = -1
  return self.WBP_ScrollItemBg1
end

function WBP_ModScrollView_C:ScollPickUpItemUpNav()
  local ChildCount = self.ScrollBoxPickupScrollList:GetChildrenCount()
  for i = 1, ChildCount do
    local Item = self.ScrollBoxPickupScrollList:GetChildAt(i - 1)
    if Item and Item:HasKeyboardFocus() then
      if i > 1 then
        local UpItem = self.ScrollBoxPickupScrollList:GetChildAt(i - 2)
        if UpItem then
          UpItem:SetFocus()
          return UpItem
        end
      end
      break
    end
  end
  return nil
end

function WBP_ModScrollView_C:ScollPickUpItemDownNav()
  local ChildCount = self.ScrollBoxPickupScrollList:GetChildrenCount()
  for i = 1, ChildCount do
    local Item = self.ScrollBoxPickupScrollList:GetChildAt(i - 1)
    if Item and Item:HasKeyboardFocus() then
      if i < ChildCount then
        local UpItem = self.ScrollBoxPickupScrollList:GetChildAt(i)
        if UpItem then
          UpItem:SetFocus()
          return UpItem
        end
      end
      break
    end
  end
  return nil
end

function WBP_ModScrollView_C:ScrollItemSlotLeftNav()
  if CheckIsVisility(self.WBP_ScrollPickupItem) then
    self.PickupIdx = 1
    return self.WBP_ScrollPickupItem
  end
  return nil
end

return WBP_ModScrollView_C
