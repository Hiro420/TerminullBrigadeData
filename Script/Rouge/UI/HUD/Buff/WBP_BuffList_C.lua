local WBP_BuffList_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")

function WBP_BuffList_C:Construct()
  if not self:GetOwningPlayerPawn() then
    return
  end
  local BuffComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.UBuffComponent)
  if not BuffComp then
    print("BuffComp is nil")
    return
  end
  self.AllBuffInfos = {}
  self.AllNormalBuffIds = {}
  self.AllImportantBuffIds = {}
  self:InitBuffInfo()
  self:RefreshBuffList()
  self:RefreshImportantBuffList()
  BuffComp.OnBuffAdded:Add(self, WBP_BuffList_C.BindOnBuffAdded)
  BuffComp.OnBuffRemove:Add(self, WBP_BuffList_C.BindOnBuffRemoved)
  BuffComp.OnBuffChanged:Add(self, WBP_BuffList_C.BindOnBuffChanged)
  local InscriptionComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGInscriptionComponent:StaticClass())
  if InscriptionComp then
    InscriptionComp.OnClientUpdateInscriptionCD:Add(self, WBP_BuffList_C.BindOnClientUpdateInscriptionCD)
  end
  local InscriptionCompV2 = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGInscriptionComponentV2:StaticClass())
  if InscriptionCompV2 then
    InscriptionCompV2.OnInscriptionCooldown:Add(self, WBP_BuffList_C.BindOnClientUpdateInscriptionCD)
  end
  EventSystem.AddListener(self, EventDef.Battle.RemoveInscriptionItem, WBP_BuffList_C.BindOnRemoveInscriptionItem)
end

function WBP_BuffList_C:InitBuffInfo()
  local BuffComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.UBuffComponent)
  if not BuffComp then
    return
  end
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  for i, SingleBuffInfo in iterator(BuffComp.AllBuffInfo.AllBuffInfo) do
    local BuffData = BuffDataSubsystem:GetDataFormID(SingleBuffInfo.ID)
    if BuffData and BuffData.IsNeedShowOnHUD then
      local BuffInfo = {}
      BuffInfo.ID = SingleBuffInfo.ID
      BuffInfo.CurrentCount = SingleBuffInfo.CurrentCount
      BuffInfo.BuffData = BuffData
      BuffInfo.Target = Character
      self.AllBuffInfos[SingleBuffInfo.ID] = BuffInfo
      if BuffData.IsImportantBuff then
        table.insert(self.AllImportantBuffIds, SingleBuffInfo.ID)
      else
        table.insert(self.AllNormalBuffIds, SingleBuffInfo.ID)
      end
    end
  end
end

function WBP_BuffList_C:InitInfo(OwingCharacter, IconSize)
end

function WBP_BuffList_C:BindOnBuffAdded(AddedBuff)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if BuffData and BuffData.IsNeedShowOnHUD then
    local BuffInfo = {}
    BuffInfo.ID = AddedBuff.ID
    BuffInfo.CurrentCount = AddedBuff.CurrentCount
    BuffInfo.BuffData = BuffData
    BuffInfo.IsElement = false
    BuffInfo.Target = Character
    self.AllBuffInfos[AddedBuff.ID] = BuffInfo
    if BuffData.IsImportantBuff then
      table.insert(self.AllImportantBuffIds, 1, AddedBuff.ID)
      if #self.AllImportantBuffIds > self.MaxImportantBuffNum then
        local TargetRemoveBuffId = self.AllImportantBuffIds[#self.AllImportantBuffIds]
        local TargetItem = self.AllImportantBuffWidgets[TargetRemoveBuffId]
        if TargetItem then
          LogicBuffList.ListContainer:HideItem(TargetItem)
          self.AllImportantBuffWidgets[TargetRemoveBuffId] = nil
        end
        table.remove(self.AllImportantBuffIds, #self.AllImportantBuffIds)
      end
      self:RefreshImportantBuffList()
      self:ShowSimpleDesc(AddedBuff.ID, BuffData.SimpleDesc)
    else
      if not table.Contain(self.AllNormalBuffIds, AddedBuff.ID) then
        table.insert(self.AllNormalBuffIds, AddedBuff.ID)
      end
      self:RefreshBuffList()
    end
  end
end

function WBP_BuffList_C:BindOnBuffChanged(ChangedBuff)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local BuffData = BuffDataSubsystem:GetDataFormID(ChangedBuff.ID)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if BuffData and BuffData.IsNeedShowOnHUD then
    local BuffInfo = {}
    BuffInfo.ID = ChangedBuff.ID
    BuffInfo.CurrentCount = ChangedBuff.CurrentCount
    BuffInfo.BuffData = BuffData
    BuffInfo.IsElement = false
    BuffInfo.Target = Character
    self.AllBuffInfos[ChangedBuff.ID] = BuffInfo
    if BuffData.IsImportantBuff then
      local Item = self.AllImportantBuffWidgets[ChangedBuff.ID]
      if Item then
        Item:RefreshBuffInfo(BuffInfo)
      else
        if not table.Contain(self.AllImportantBuffIds, ChangedBuff.ID) then
          table.insert(self.AllImportantBuffIds, ChangedBuff.ID)
        end
        self:RefreshImportantBuffList()
      end
      self:ShowSimpleDesc(ChangedBuff.ID, BuffData.SimpleDesc)
    else
      if not table.Contain(self.AllNormalBuffIds, ChangedBuff.ID) then
        table.insert(self.AllNormalBuffIds, ChangedBuff.ID)
      end
      self:RefreshBuffList()
    end
  end
end

function WBP_BuffList_C:BindOnBuffRemoved(RemovedBuff)
  local TargetBuffInfo = self.AllBuffInfos[RemovedBuff.ID]
  if not TargetBuffInfo then
    return
  end
  local IsImportantBuff = TargetBuffInfo.BuffData and TargetBuffInfo.BuffData.IsImportantBuff
  self.AllBuffInfos[RemovedBuff.ID] = nil
  if IsImportantBuff then
    table.RemoveItem(self.AllImportantBuffIds, RemovedBuff.ID)
    local TargetItem = self.AllImportantBuffWidgets[RemovedBuff.ID]
    if TargetItem then
      LogicBuffList.ListContainer:HideItem(TargetItem)
      self.AllImportantBuffWidgets[RemovedBuff.ID] = nil
    end
    if self.CurShowImportantBuffId == RemovedBuff.ID then
      self:HideSimpleDesc()
    end
  else
    table.RemoveItem(self.AllNormalBuffIds, RemovedBuff.ID)
    self:RefreshBuffList()
  end
end

function WBP_BuffList_C:BindOnClientUpdateInscriptionCD(InscriptionId, RemainTime)
  local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandSubsystem then
    return
  end
  local DataAssest = GetLuaInscription(InscriptionId)
  if not DataAssest then
    return
  end
  if not DataAssest.InscriptionCDData.bIsShowCD then
    print(InscriptionId, "\228\184\141\230\152\190\231\164\186")
    return
  end
  if not DataAssest.InscriptionCDData.bIsShowCDInBuff then
    print(InscriptionId, "\228\184\141\230\152\190\231\164\186")
    return
  end
  if RemainTime > 0 then
    local BuffInfo = {}
    BuffInfo.ID = InscriptionId
    BuffInfo.IsElement = false
    BuffInfo.IsInscription = true
    local GS = UE.UGameplayStatics.GetGameState(self)
    BuffInfo.StartTime = GS:GetServerWorldTimeSeconds()
    BuffInfo.RemainTime = RemainTime
    if not table.Contain(self.AllNormalBuffIds, InscriptionId) then
      BuffInfo.Duration = RemainTime
      table.insert(self.AllNormalBuffIds, InscriptionId)
      self.AllBuffInfos[InscriptionId] = BuffInfo
    else
      local TempInfo = self.AllBuffInfos[InscriptionId]
      TempInfo.StartTime = GS:GetServerWorldTimeSeconds()
      TempInfo.RemainTime = RemainTime
    end
  else
    self.AllBuffInfos[InscriptionId] = nil
    table.RemoveItem(self.AllNormalBuffIds, InscriptionId)
  end
  self:RefreshBuffList()
end

function WBP_BuffList_C:BindOnRemoveInscriptionItem(InscriptionId)
  self.AllBuffInfos[InscriptionId] = nil
  table.RemoveItem(self.AllNormalBuffIds, InscriptionId)
  self:RefreshBuffList()
end

function WBP_BuffList_C:RefreshBuffList()
  local BuffIndex = 0
  for i, SingleWidget in iterator(self.BuffList:GetAllChildren()) do
    LogicBuffList.ListContainer:HideItem(SingleWidget)
  end
  local BuffIconSizeX = self.WBP_BuffIcon.MainSizeBox.WidthOverride
  for i, SingleBuffId in ipairs(self.AllNormalBuffIds) do
    if BuffIndex > self.MaxBuffNum - 1 then
      break
    end
    local BuffInfo = self.AllBuffInfos[SingleBuffId]
    local List
    local IsShowOmitIcon = false
    List = self.BuffList
    BuffIndex = BuffIndex + 1
    if BuffIndex == self.MaxBuffNum then
      IsShowOmitIcon = true
    end
    local Item = self.BuffList:GetChildAt(BuffIndex - 1)
    if List then
      if not Item then
        Item = LogicBuffList.ListContainer:GetOrCreateItem()
        List:AddChild(Item)
      end
      if Item then
        if self.HorizontalBox then
          Item:SetIconRenderShear(self.HorizontalBox.RenderTransform.Shear * -1)
        end
        local ItemSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
        if ItemSlot then
          local X = (BuffIndex - 1) * (Item.RenderTransform.Scale.X * BuffIconSizeX + self.NormalBuffInterval)
          local Y = 0
          ItemSlot:SetPosition(UE.FVector2D(X, Y))
          ItemSlot:SetAutoSize(true)
          ItemSlot:SetAlignment(UE.FVector2D(1.0, 0.5))
          ItemSlot:SetAnchors(UE.FAnchors(UE.FVector2D(1.0, 0.5), UE.FVector2D(1.0, 0.5)))
        end
        LogicBuffList.ListContainer:ShowItem(Item, self.AllBuffInfos[SingleBuffId], IsShowOmitIcon, self:GetOwningPlayerPawn())
      end
    end
  end
end

function WBP_BuffList_C:RefreshImportantBuffList(...)
  if not self.AllImportantBuffWidgets then
    self.AllImportantBuffWidgets = {}
  end
  for i, SingleBuffId in ipairs(self.AllImportantBuffIds) do
    if not self.AllImportantBuffWidgets[SingleBuffId] then
      local IsShowOmitIcon = false
      local Item = LogicBuffList.ListContainer:GetOrCreateItem()
      self.ImportantBuffList:AddChild(Item)
      if Item then
        LogicBuffList.ListContainer:ShowItem(Item, self.AllBuffInfos[SingleBuffId], IsShowOmitIcon, self:GetOwningPlayerPawn())
        self.AllImportantBuffWidgets[SingleBuffId] = Item
      end
    end
  end
end

function WBP_BuffList_C:ShowSimpleDesc(BuffId, Desc)
  self.Txt_SimpleDesc:SetText(Desc)
  self:HideSimpleDesc()
  self.CurShowImportantBuffId = BuffId
  UpdateVisibility(self.Txt_SimpleDesc, true)
  self.ShowSimpleDescTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.HideSimpleDesc
  }, self.SimpleDescDuration, false)
end

function WBP_BuffList_C:HideSimpleDesc(...)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ShowSimpleDescTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ShowSimpleDescTimer)
  end
  UpdateVisibility(self.Txt_SimpleDesc, false, true, true)
  self.CurShowImportantBuffId = 0
end

function WBP_BuffList_C:FocusInput()
end

function WBP_BuffList_C:Destruct()
  if not self:GetOwningPlayerPawn() then
    return
  end
  local BuffComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.UBuffComponent)
  if not BuffComp then
    print("BuffComp is nil")
    return
  end
  BuffComp.OnBuffAdded:Remove(self, WBP_BuffList_C.BindOnBuffChanged)
  BuffComp.OnBuffRemove:Remove(self, WBP_BuffList_C.BindOnBuffRemoved)
  BuffComp.OnBuffChanged:Remove(self, WBP_BuffList_C.BindOnBuffChanged)
  local AllBuffChildren = self.BuffList:GetAllChildren()
  if LogicBuffList.ListContainer then
    for i, SingleWidget in iterator(AllBuffChildren) do
      LogicBuffList.ListContainer:HideItem(SingleWidget)
    end
  end
  self.AllImportantBuffWidgets = {}
  local InscriptionComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGInscriptionComponent:StaticClass())
  if InscriptionComp then
    InscriptionComp.OnClientUpdateInscriptionCD:Remove(self, WBP_BuffList_C.BindOnClientUpdateInscriptionCD)
  end
  local InscriptionCompV2 = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGInscriptionComponentV2:StaticClass())
  if InscriptionCompV2 then
    InscriptionCompV2.OnInscriptionCooldown:Remove(self, WBP_BuffList_C.BindOnClientUpdateInscriptionCD)
  end
  EventSystem.RemoveListener(EventDef.Battle.RemoveInscriptionItem, WBP_BuffList_C.BindOnRemoveInscriptionItem, self)
  self:HideSimpleDesc()
end

return WBP_BuffList_C
