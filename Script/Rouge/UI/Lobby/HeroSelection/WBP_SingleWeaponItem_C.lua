local WBP_SingleWeaponItem_C = UnLua.Class()

function WBP_SingleWeaponItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end

function WBP_SingleWeaponItem_C:Show(WeaponInfo, HeroId)
  self.WeaponInfo = WeaponInfo
  self.HeroId = HeroId
  local Result, RowInfo = GetRowData(DT.DT_Item, self.WeaponInfo.resourceId)
  if not Result then
    print("WBP_SingleWeaponItem_C:Show not found ItemRowInfo, RowName:", self.WeaponInfo.resourceId)
    return
  end
  self:SetVisibility(UE.ESlateVisibility.Visible)
  SetImageBrushBySoftObject(self.Img_WeaponIcon, RowInfo.CompleteGunIcon, self.IconSize)
  self:RefreshSelectStatus()
  EventSystem.AddListener(self, EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged)
end

function WBP_SingleWeaponItem_C:BindOnEquippedWeaponInfoChanged(HeroId)
  if HeroId ~= self.HeroId then
    return
  end
  self:RefreshSelectStatus()
end

function WBP_SingleWeaponItem_C:BindOnMainButtonClicked()
  if self.IsSelect then
    return
  end
  LogicOutsideWeapon.RequestEquipWeapon(self.HeroId, self.WeaponInfo.uuid, 0, self.WeaponInfo.resourceId)
end

function WBP_SingleWeaponItem_C:BindOnMainButtonHovered()
  EventSystem.Invoke(EventDef.HeroSelect.OnWeaponItemHoveredStateChanged, true, self.WeaponInfo)
end

function WBP_SingleWeaponItem_C:BindOnMainButtonUnhovered()
  EventSystem.Invoke(EventDef.HeroSelect.OnWeaponItemHoveredStateChanged, false, nil)
end

function WBP_SingleWeaponItem_C:RefreshSelectStatus()
  self.Img_Select:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.IsSelect = false
  local EquippedInfo = DataMgr.GetEquippedWeaponList(self.HeroId)
  if not EquippedInfo then
    return
  end
  for i, SingleEquippedInfo in ipairs(EquippedInfo) do
    if SingleEquippedInfo.uuid == self.WeaponInfo.uuid then
      self.Img_Select:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.IsSelect = true
      break
    end
  end
end

function WBP_SingleWeaponItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WeaponInfo = nil
  self.HeroId = nil
  EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged, self)
end

function WBP_SingleWeaponItem_C:Destruct()
  self:Hide()
end

return WBP_SingleWeaponItem_C
