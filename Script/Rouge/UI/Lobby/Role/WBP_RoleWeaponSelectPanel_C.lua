local WBP_RoleWeaponSelectPanel_C = UnLua.Class()
function WBP_RoleWeaponSelectPanel_C:InitInfo(CurHeroId, CurSelectWeaponSlotId)
  self.CurHeroId = CurHeroId
  self.CurSelectWeaponSlotId = CurSelectWeaponSlotId
  self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RefreshWeaponSelectList()
  EventSystem.AddListener(self, EventDef.Lobby.WeaponListChanged, WBP_RoleWeaponSelectPanel_C.BindOnWeaponListChanged)
  EventSystem.AddListener(self, EventDef.Lobby.WeaponSlotSelected, self.BindOnWeaponSlotSelected)
end
function WBP_RoleWeaponSelectPanel_C:BindOnWeaponListChanged()
  self:RefreshWeaponSelectList()
end
function WBP_RoleWeaponSelectPanel_C:WeaponSelectClick(WeaponInfo)
  local WeaponInfo = WeaponInfo.WeaponData
  self:HidePanel()
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  local TargetWeaponInfo = EquippedWeaponList[self.CurSelectWeaponSlotId + 1]
  if TargetWeaponInfo.uuid == WeaponInfo.uuid then
    print("\228\184\142\229\189\147\229\137\141\230\173\166\229\153\168\233\128\137\230\139\169\228\184\128\230\160\183")
    return
  end
  local AllCanEquipWeaponList = LogicOutsideWeapon.GetAllCanEquipWeaponList(self.CurHeroId)
  if table.Contain(AllCanEquipWeaponList, tonumber(WeaponInfo.resourceId)) then
    LogicOutsideWeapon.RequestEquipWeapon(self.CurHeroId, WeaponInfo.uuid, self.CurSelectWeaponSlotId, WeaponInfo.resourceId)
  end
end
function WBP_RoleWeaponSelectPanel_C:Hover(IsHover, WeaponInfo, IsEquipped)
  local WeaponInfo = WeaponInfo.WeaponData
  if IsHover then
    local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    if WeaponInfo.uuid == EquippedWeaponInfo[1].uuid then
      self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:RefreshWeaponDisplayInfoTip(self.WeaponItemDisplayInfo, WeaponInfo, IsEquipped)
    end
    self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CurWeaponItemDisplayInfo:SetIsSelected(true)
    self:RefreshWeaponDisplayInfoTip(self.CurWeaponItemDisplayInfo, EquippedWeaponInfo[1], true)
  else
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_RoleWeaponSelectPanel_C:BindOnWeaponSlotSelected(IsSelected)
  if not IsSelected then
    self:HidePanel()
  end
end
function WBP_RoleWeaponSelectPanel_C:RefreshWeaponDisplayInfoTip(TargetTipWidget, WeaponInfo, IsEquipped)
  local AccessoryList = {}
  local TipText
  local IsShowOperateIcon = false
  if IsEquipped then
    TipText = nil
  else
    TipText = self.NotEquippedText
    IsShowOperateIcon = true
  end
  TargetTipWidget:InitInfo(WeaponInfo.resourceId, AccessoryList, false, WeaponInfo)
  if TipText then
    TargetTipWidget:ShowTipPanel(TipText, IsShowOperateIcon)
  end
end
function WBP_RoleWeaponSelectPanel_C:RefreshWeaponSelectList()
  local AllChildren = self.LobbyWeaponList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local AllCanEquipWeaponList = LogicOutsideWeapon.GetCurCanEquipWeaponList(self.CurHeroId)
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if not EquippedWeaponList then
    return
  end
  local TargetWeaponInfo
  for i, SingleEquippedInfo in ipairs(EquippedWeaponList) do
    if i ~= self.CurSelectWeaponSlotId + 1 then
      TargetWeaponInfo = SingleEquippedInfo
      break
    end
  end
  table.sort(AllCanEquipWeaponList, function(a, b)
    return a.uuid < b.uuid
  end)
  local CurWeaponInfo = EquippedWeaponList[self.CurSelectWeaponSlotId + 1]
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Index = 0
  for i, SingleWeaponInfo in ipairs(AllCanEquipWeaponList) do
    local Item = self.LobbyWeaponList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.WeaponItemTemplate:StaticClass())
      self.LobbyWeaponList:AddChild(Item)
    end
    local WeaponInfo = {
      WeaponData = SingleWeaponInfo,
      resourceId = SingleWeaponInfo.resourceId,
      uuid = SingleWeaponInfo.uuid
    }
    Item:InitUnEquipedWeaponItem(WeaponInfo, false, self, CurWeaponInfo.uuid == SingleWeaponInfo.uuid)
    Index = Index + 1
  end
end
function WBP_RoleWeaponSelectPanel_C:OnWeaponSelectBGClicked()
  EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false)
end
function WBP_RoleWeaponSelectPanel_C:HidePanel()
  UIMgr:Hide(ViewID.UI_RoleWeaponSelectPanel)
end
function WBP_RoleWeaponSelectPanel_C:OnHide(...)
  self:RemoveAllListener()
end
function WBP_RoleWeaponSelectPanel_C:RemoveAllListener()
  EventSystem.RemoveListener(EventDef.Lobby.WeaponListChanged, WBP_RoleWeaponSelectPanel_C.BindOnWeaponListChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.LobbyWeaponItemHoverStatusChanged, WBP_RoleWeaponSelectPanel_C.BindOnLobbyWeaponItemHovered, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponItemSelected, WBP_RoleWeaponSelectPanel_C.BindOnLobbyWeaponItemSelected, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponSlotSelected, self.BindOnWeaponSlotSelected, self)
end
function WBP_RoleWeaponSelectPanel_C:Destruct()
  self:RemoveAllListener()
end
return WBP_RoleWeaponSelectPanel_C
