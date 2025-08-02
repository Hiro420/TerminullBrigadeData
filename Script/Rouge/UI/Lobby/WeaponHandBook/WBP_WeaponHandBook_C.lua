local WBP_WeaponHandBook_C = UnLua.Class()
local WeaponWorldItemClsPath = "/Game/Rouge/UI/Lobby/WeaponHandBook/WBP_WeaponWorldItem.WBP_WeaponWorldItem_C"
local WeaponHandBookItemDataPath = "/Game/Rouge/UI/Lobby/WeaponHandBook/WeaponHandBookItemData.WeaponHandBookItemData_C"
local AccessaryItemNameFormat = "WBP_WeaponHandBookParts"
local MaxAccessoryNum = 8

function WBP_WeaponHandBook_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.LobbyPanelChanged, WBP_WeaponHandBook_C.BindOnLobbyActivePanelChanged)
  self.BP_ButtonWithSoundTipsMask.OnClicked:Add(self, WBP_WeaponHandBook_C.BindOnTipsMaskButtonClicked)
  self.RGToggleGroupWorld.OnCheckStateChanged:Add(self, WBP_WeaponHandBook_C.BindOnWorldCheckChanged)
  self.RGToggleGroupAccessory.OnCheckStateChanged:Add(self, WBP_WeaponHandBook_C.BindOnAccessoryCheckChanged)
  self.UsedDataList:Clear()
  self.DataPool:Clear()
  LogicWeaponHandBook:InitWeaponData()
end

function WBP_WeaponHandBook_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.LobbyPanelChanged, WBP_WeaponHandBook_C.BindOnLobbyActivePanelChanged)
  self.BP_ButtonWithSoundTipsMask.OnClicked:Remove(self, WBP_WeaponHandBook_C.BindOnTipsMaskButtonClicked)
  self.RGToggleGroupWorld.OnCheckStateChanged:Remove(self, WBP_WeaponHandBook_C.BindOnWorldCheckChanged)
  self.RGToggleGroupAccessory.OnCheckStateChanged:Remove(self, WBP_WeaponHandBook_C.BindOnAccessoryCheckChanged)
  self.UsedDataList:Clear()
  self.DataPool:Clear()
end

function WBP_WeaponHandBook_C:BindOnLobbyActivePanelChanged(LastActiveWidget, CurActiveWidget)
  if LastActiveWidget == CurActiveWidget then
    if CurActiveWidget == self then
    end
    return
  end
  if CurActiveWidget == self then
    EventSystem.AddListener(self, EventDef.Lobby.ExpChanged, WBP_WeaponHandBook_C.BindOnLobbyExpChanged)
    self:UpdateWorldList()
  end
  if LastActiveWidget == self then
    EventSystem.RemoveListener(self, EventDef.Lobby.ExpChanged, WBP_WeaponHandBook_C.BindOnLobbyExpChanged)
    self:ShowTips(false)
  end
end

function WBP_WeaponHandBook_C:BindOnLobbyExpChanged()
  self:BindOnWorldCheckChanged(self.RGToggleGroupWorld.CurSelectId)
end

function WBP_WeaponHandBook_C:BindOnChangeRoleItemClicked(CharacterId)
end

function WBP_WeaponHandBook_C:InitInfo()
end

function WBP_WeaponHandBook_C:BindOnUpgradeButtonClicked()
end

function WBP_WeaponHandBook_C:BindOnTipsMaskButtonClicked()
  self:ShowTips(false)
end

function WBP_WeaponHandBook_C:BindOnWorldCheckChanged(SelectIdex)
  self.ListViewWeaponList:ClearListItems()
  self:RecyleDataObj()
  local Index = 1
  local SelectIndex = 0
  local WeaponList = LogicWeaponHandBook:GetWeaponListByWorldId(SelectIdex)
  if WeaponList then
    for i, v in ipairs(WeaponList) do
      local DataObj = self:GetOrCreateData()
      DataObj.WeaponBarrelId = v
      if not DataObj.Select:IsBound() then
        DataObj.Select = {
          self,
          self.Select
        }
      end
      if self.CurSelectWeaponBarrelid == v then
        SelectIndex = Index - 1
      end
      Index = Index + 1
    end
  end
  self.ListViewWeaponList:BP_SetListItems(self.UsedDataList)
  self.ListViewWeaponList:RegenerateAllEntries()
  self.ListViewWeaponList:SetSelectedIndex(SelectIndex)
end

function WBP_WeaponHandBook_C:GetOrCreateData()
  local DataObjCls = UE.UClass.Load(WeaponHandBookItemDataPath)
  local DataObj
  if self.DataPool:Num() > 0 then
    local DataObj = self.DataPool:GetRef(self.DataPool:Num())
    self.DataPool:Remove(self.DataPool:Num())
    self.UsedDataList:Add(DataObj)
    return DataObj
  end
  DataObj = UE.NewObject(DataObjCls, self, nil)
  self.UsedDataList:Add(DataObj)
  return DataObj
end

function WBP_WeaponHandBook_C:RecyleDataObj()
  for i, v in iterator(self.UsedDataList) do
    self.DataPool:Add(v)
  end
  self.UsedDataList:Clear()
end

function WBP_WeaponHandBook_C:BindOnAccessoryCheckChanged(SelectIdex)
  if -1 == SelectIdex then
    self:ShowTips(false, true)
    return
  end
  local Toggle = self.RGToggleGroupAccessory:GetToggleById(SelectIdex)
  if not Toggle or -1 == Toggle.AccessoryId then
    self:ShowTips(false, true)
    return
  end
  self:ShowTips(true)
  local bIsAdditionalDescTipsLeft = self.LeftAccessorySlotIndex:Contains(SelectIdex)
  self.WBP_WeaponHandBookAccessoryTips:InitInfo(Toggle.AccessoryId, bIsAdditionalDescTipsLeft)
  local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_WeaponHandBookAccessoryTips)
  if TipsCanvasSlot then
    local GeometryPart = Toggle:GetCachedGeometry()
    local GeometryAccessoryRoot = self.CanvasPanelAccessory:GetCachedGeometry()
    local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryAccessoryRoot, GeometryPart) + self.TipsOffset
    TipsCanvasSlot:SetPosition(Pos)
  end
end

function WBP_WeaponHandBook_C:ShowTips(bIsShow, bIsNotReSelectToggleGroup)
  UpdateVisibility(self.BP_ButtonWithSoundTipsMask, bIsShow, true)
  UpdateVisibility(self.WBP_WeaponHandBookAccessoryTips, bIsShow)
  if bIsShow then
    UpdateVisibility(self.WBP_WeaponHandBookAccessoryHoverTips, false)
  end
  if not bIsShow and not bIsNotReSelectToggleGroup then
    self.RGToggleGroupAccessory:SelectId(-1)
  end
end

function WBP_WeaponHandBook_C:UpdateWorldList()
  local WeaponWorldItemCls = UE.UClass.Load(WeaponWorldItemClsPath)
  local Index = 1
  local FirstId = self.RGToggleGroupWorld.CurSelectId
  for i, v in pairs(LogicWeaponHandBook.WeaponMap) do
    local WorldItem = GetOrCreateItem(self.ScrollBoxWorld, Index, WeaponWorldItemCls)
    if not self.RGToggleGroupWorld:Contains(i) then
      self.RGToggleGroupWorld:AddToGroup(i, WorldItem)
    end
    if 1 == Index and -1 == FirstId then
      FirstId = i
    end
    local Result, WorldInfo = LogicWeaponHandBook:GetWorldInfoByWorldId(i)
    WorldItem:Show(WorldInfo.WorldDisplayName, WorldInfo.WeaponHandBookSpriteIcon, i)
    Index = Index + 1
  end
  if FirstId > 0 then
    self.RGToggleGroupWorld:SelectId(FirstId)
  end
end

function WBP_WeaponHandBook_C:Select(WeaponBarrelIdParam)
  self.CurSelectWeaponBarrelid = WeaponBarrelIdParam
  self.CanvasPanelWeapon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:ShowTips(false)
  local Result, WeaponHandBook = LogicWeaponHandBook:GetWeaponHandBookDataByRowName(WeaponBarrelIdParam)
  if not WeaponHandBook then
    return
  end
  if LogicWeaponHandBook:CheckWeaponUnLock(WeaponHandBook) then
    self.CanvasPanelAccessory:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    local Lv = tonumber(DataMgr.GetRoleLevel())
    local Str = string.format("\232\190\190\229\136\176<Blue>%d</>\231\186\167\229\144\142\232\167\163\233\148\129\230\173\166\229\153\168\239\188\136%d/%d\239\188\137", WeaponHandBook.UnLockLv, Lv, WeaponHandBook.UnLockLv)
    self.RichTextBlockUnlockDesc:SetText(Str)
    local Percent = 0
    if WeaponHandBook.UnLockLv > 0 then
      Percent = Lv / WeaponHandBook.UnLockLv
    end
    self.URGImageProgress:SetClippingValue(Percent)
    self.CanvasPanelAccessory:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WeaponHandBook.WeaponBarrelImg)
  local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
  self.URGImageWeaponImg:SetBrush(Brush)
  for i = 1, MaxAccessoryNum do
    local AccessaryItemName = AccessaryItemNameFormat .. i
    if WeaponHandBook.AccessoryList:IsValidIndex(i) then
      if self[AccessaryItemName] then
        local AccessoryId = WeaponHandBook.AccessoryList:GetRef(i)
        self[AccessaryItemName]:Init(AccessoryId, UE.ERGItemRarity.EIR_Excellent, self.HoverAccessoryItemFunc, self)
      end
    elseif self[AccessaryItemName] then
      self[AccessaryItemName]:Init(-1, UE.ERGItemRarity.EIR_Normal)
    end
  end
  local ItemData = LogicWeaponHandBook:GetItemDataByRowName(tostring(WeaponBarrelIdParam))
  if ItemData then
    self.RGTextBlockWeaponName:SetText(ItemData.Name)
  end
  self.RGTextBlockWeaponDesc:SetVisibility(UE.ESlateVisibility.Collapsed)
  local Result, AccessoryData = LogicWeaponHandBook:GetAccessoryById(WeaponBarrelIdParam)
  if AccessoryData then
    local AccessoryInscription = AccessoryData.InscriptionMap:FindRef(UE.ERGItemRarity.EIR_Excellent)
    if AccessoryInscription and AccessoryInscription.Inscriptions:IsValidIndex(1) then
      local AccessoryInscriptionData = AccessoryInscription.Inscriptions:GetRef(1)
      if AccessoryInscriptionData and AccessoryInscriptionData.bIsShowInUI then
        local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
        if RGLogicCommandDataSubsystem then
          local OutString = GetLuaInscriptionDesc(AccessoryInscriptionData.InscriptionId, 0)
          self.RGTextBlockWeaponDesc:SetText(OutString)
          self.RGTextBlockWeaponDesc:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
end

function WBP_WeaponHandBook_C:HoverAccessoryItemFunc(HoverItem, AccessoryId, bIsEnter)
  local Toggle = self.RGToggleGroupAccessory:GetToggleById(self.RGToggleGroupAccessory.CurSelectId)
  if Toggle and Toggle.AccessoryId == AccessoryId then
    return
  end
  UpdateVisibility(self.WBP_WeaponHandBookAccessoryHoverTips, bIsEnter)
  if bIsEnter then
    self.WBP_WeaponHandBookAccessoryHoverTips:InitInfo(AccessoryId, UE.ERGItemRarity.EIR_Excellent)
    local HoverTipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_WeaponHandBookAccessoryHoverTips)
    if HoverTipsCanvasSlot then
      local GeometryPart = HoverItem:GetCachedGeometry()
      local GeometryAccessoryRoot = self.CanvasPanelAccessory:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryAccessoryRoot, GeometryPart) + self.HoverTipsOffset
      HoverTipsCanvasSlot:SetPosition(Pos)
    end
  end
end

return WBP_WeaponHandBook_C
