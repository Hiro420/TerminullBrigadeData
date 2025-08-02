local WBP_LobbyWeaponSlotItem_C = UnLua.Class()

function WBP_LobbyWeaponSlotItem_C:Construct()
  self.Btn_Main.OnHovered:Add(self, WBP_LobbyWeaponSlotItem_C.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, WBP_LobbyWeaponSlotItem_C.BindOnMainButtonUnHovered)
  self.Btn_Main.OnClicked:Add(self, WBP_LobbyWeaponSlotItem_C.BindOnMainButtonClicked)
  EventSystem.AddListener(self, EventDef.Lobby.WeaponSlotSelected, WBP_LobbyWeaponSlotItem_C.BindOnWeaponSlotSelected)
end

function WBP_LobbyWeaponSlotItem_C:OnBindUIInput()
  self.WBP_InteractTipWidgetChangeWeapon:BindInteractAndClickEvent(self, WBP_LobbyWeaponSlotItem_C.BindOnMainButtonClicked)
end

function WBP_LobbyWeaponSlotItem_C:OnUnBindUIInput()
  self.WBP_InteractTipWidgetChangeWeapon:UnBindInteractAndClickEvent(self, WBP_LobbyWeaponSlotItem_C.BindOnMainButtonClicked)
end

function WBP_LobbyWeaponSlotItem_C:BindOnMainButtonHovered()
  UpdateVisibility(self.Img_Hovered, true)
  if not self.WeaponInfo or 0 == tonumber(self.WeaponInfo.resourceId) then
    return
  end
  EventSystem.Invoke(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, true, self.WeaponInfo)
end

function WBP_LobbyWeaponSlotItem_C:BindOnMainButtonUnHovered()
  UpdateVisibility(self.Img_Hovered, false)
  EventSystem.Invoke(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, false)
end

function WBP_LobbyWeaponSlotItem_C:BindOnMainButtonClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.WEAPON) then
    return
  end
  EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, true, self.SlotId)
end

function WBP_LobbyWeaponSlotItem_C:BindOnWeaponSlotSelected(IsSelect, SlotId)
  self.CurSelectSlotId = SlotId
  if IsSelect then
    if SlotId == self.SlotId then
      self.Img_Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CurSelectSlotId = -1
  end
end

function WBP_LobbyWeaponSlotItem_C:RefreshInfo(WeaponInfo, IsNotSlot)
  self.WeaponInfo = WeaponInfo
  self.IsSlot = IsNotSlot
  if not self.WeaponInfo or 0 == tonumber(self.WeaponInfo.resourceId) then
    UpdateVisibility(self.Btn_Main, false)
    self.Img_Weapon:SetVisibility(UE.ESlateVisibility.Hidden)
    self.Txt_Name:SetVisibility(UE.ESlateVisibility.Hidden)
    return
  end
  UpdateVisibility(self.Img_Hovered, false)
  self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Weapon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  UpdateVisibility(self.Btn_Main, true, true)
  local BResult, ItemInfo = GetRowData(DT.DT_Item, tostring(self:GetWeaponBodyId()))
  local resultWeapon, rowWeapon = GetRowData(DT.DT_Weapon, tostring(self:GetWeaponBodyId()))
  if BResult and resultWeapon then
    SetImageBrushBySoftObject(self.Img_Weapon, rowWeapon.Icon, self.WeaponIconSize)
    self.Txt_Name:SetText(ItemInfo.Name)
  end
  self.Txt_SlotIndex:SetText(tostring(self.SlotId + 1))
  local expireAt = WeaponInfo.expireAt
  if nil ~= expireAt and "" ~= expireAt and "0" ~= expireAt then
    local currentTime = os.time()
    UpdateVisibility(self.URGImage_38, true)
    if tonumber(expireAt) - currentTime < 90000 then
      self.URGImage_38:SetColorAndOpacity(self.ErrorColor)
    else
      self.URGImage_38:SetColorAndOpacity(self.DefColor)
    end
  else
    UpdateVisibility(self.URGImage_38, false)
    self.URGImage_38:SetColorAndOpacity(self.DefColor)
  end
end

function WBP_LobbyWeaponSlotItem_C:PlayAniInAnimation()
  self:PlayAnimationForward(self.Ani_in)
end

function WBP_LobbyWeaponSlotItem_C:GetWeaponBodyId()
  return tonumber(self.WeaponInfo.resourceId)
end

function WBP_LobbyWeaponSlotItem_C:GetInfoToolTipWidget()
  if not self.WeaponInfo or 0 == tonumber(self.WeaponInfo.resourceId) then
    return
  end
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Weapon/WBP_LobbyWeaponDisplayInfo.WBP_LobbyWeaponDisplayInfo_C")
  if WidgetClass and (not self.WeaponToolTipWidget or not self.WeaponToolTipWidget:IsValid()) then
    self.WeaponToolTipWidget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
  end
  if self.WeaponToolTipWidget then
    local AccessoryList = {}
    for i, SingleAccessoryInfo in ipairs(self.WeaponInfo.acc) do
      table.insert(AccessoryList, SingleAccessoryInfo.resourceId)
    end
    self.WeaponToolTipWidget:InitInfo(self.WeaponInfo.resourceId, AccessoryList)
    self.WeaponToolTipWidget:ShowTipPanel(string.format(self.ReplaceSlotTipText, self.SlotId + 1), true)
  end
  return self.WeaponToolTipWidget
end

function WBP_LobbyWeaponSlotItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.WeaponSlotSelected, WBP_LobbyWeaponSlotItem_C.BindOnWeaponSlotSelected, self)
end

return WBP_LobbyWeaponSlotItem_C
