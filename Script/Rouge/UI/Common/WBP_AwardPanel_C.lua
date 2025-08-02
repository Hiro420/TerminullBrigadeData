local WBP_AwardPanel_C = UnLua.Class()
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local EscKeyName = "PauseGame"

function WBP_AwardPanel_C:Construct()
  self.Btn_Confirm.OnClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Confirm.OnHovered:Add(self, self.BindOnConfirmButtonHovered)
  self.Btn_Confirm.OnUnhovered:Add(self, self.BindOnConfirmButtonUnhovered)
  self.Btn_Equip.OnClicked:Add(self, self.BindOnEquipButtonClicked)
  self.Btn_Equip.OnHovered:Add(self, self.BindOnEquipButtonHovered)
  self.Btn_Equip.OnUnhovered:Add(self, self.BindOnEquipButtonUnhovered)
end

function WBP_AwardPanel_C:OnShow(ResourceIdList, HeroId)
  self.ResourceIdList = ResourceIdList
  self.HeroId = HeroId
  if not IsListeningForInputAction(self, EscKeyName) then
    ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscKeyNamePressed
    })
  end
  local Item
  local Result, ResourceRowInfo = false
  local IsShowChangeWeaponPanel = false
  local WeaponName = ""
  for i, SingleResourceId in ipairs(ResourceIdList) do
    Item = GetOrCreateItem(self.AwardItemList, i, self.AwardItemTemplate:StaticClass())
    Item:Show(SingleResourceId)
    Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, SingleResourceId)
    if Result and (ResourceRowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin or ResourceRowInfo.Type == TableEnums.ENUMResourceType.Weapon) then
      IsShowChangeWeaponPanel = true
      WeaponName = ResourceRowInfo.Name
    end
  end
  HideOtherItem(self.AwardItemList, table.count(ResourceIdList) + 1)
  if IsShowChangeWeaponPanel then
    self.ChangeWeaponPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_EquipDesc:SetText(string.format(self.EquipWeaponTipText, WeaponName))
  else
    self.ChangeWeaponPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self:BindOnConfirmButtonUnhovered()
  self:BindOnEquipButtonUnhovered()
end

function WBP_AwardPanel_C:ListenForEscKeyNamePressed()
  UIMgr:Hide(ViewID.UI_AwardPanel)
end

function WBP_AwardPanel_C:BindOnConfirmButtonClicked()
  UIMgr:Hide(ViewID.UI_AwardPanel)
end

function WBP_AwardPanel_C:BindOnConfirmButtonHovered()
  self.ConfirmHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_AwardPanel_C:BindOnConfirmButtonUnhovered()
  self.ConfirmHoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_AwardPanel_C:BindOnEquipButtonClicked()
  local AResult, ResourceRowInfo = false
  local BResult, SkinRowInfo = false
  for index, SingleResourceId in ipairs(self.ResourceIdList) do
    AResult, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, SingleResourceId)
    if AResult then
      if ResourceRowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
        BResult, SkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, SingleResourceId)
        if BResult then
          SkinHandler.SendEquipHeroSkinReq(SkinRowInfo.CharacterID, SkinRowInfo.SkinID)
        end
      elseif ResourceRowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
        BResult, SkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, SingleResourceId)
        if BResult then
          local WeaponList = LogicOutsideWeapon.GetCurCanEquipWeaponList(self.HeroId)
          local TargetWeaponUUid
          if WeaponList then
            for index, SingleWeaponInfo in ipairs(WeaponList) do
              if tonumber(SingleWeaponInfo.resourceId) == SkinRowInfo.WeaponID then
                TargetWeaponUUid = SingleWeaponInfo.uuid
                break
              end
            end
          end
          if TargetWeaponUUid then
            if self.CheckBox_ChangeWeapon:IsChecked() then
              local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.HeroId)
              if EquippedWeaponInfo and EquippedWeaponInfo[1] and EquippedWeaponInfo[1].resourceId ~= SkinRowInfo.WeaponID then
                LogicOutsideWeapon.RequestEquipWeapon(self.HeroId, TargetWeaponUUid, 0, SkinRowInfo.WeaponID)
              end
            end
            SkinHandler.SendEquipWeaponSkinReq(SkinRowInfo.SkinID, TargetWeaponUUid)
          else
            print("WBP_AwardPanel_C:BindOnEquipButtonClicked \230\141\162\230\158\170\231\154\174\232\130\164\230\151\182\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\230\158\170", SkinRowInfo.WeaponID)
          end
        end
      elseif ResourceRowInfo.Type == TableEnums.ENUMResourceType.Weapon and self.CheckBox_ChangeWeapon:IsChecked() then
        local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.HeroId)
        if EquippedWeaponInfo and EquippedWeaponInfo[1] and EquippedWeaponInfo[1].resourceId ~= SingleResourceId then
          local WeaponList = LogicOutsideWeapon.GetCurCanEquipWeaponList(self.HeroId)
          local TargetWeaponUUid
          for index, SingleWeaponInfo in ipairs(WeaponList) do
            if SingleWeaponInfo.resourceId == SingleResourceId then
              TargetWeaponUUid = SingleWeaponInfo.uuid
              break
            end
          end
          if TargetWeaponUUid then
            LogicOutsideWeapon.RequestEquipWeapon(self.HeroId, TargetWeaponUUid, 0, SkinRowInfo.WeaponID)
          else
            print("WBP_AwardPanel_C:BindOnEquipButtonClicked \230\141\162\230\158\170\230\151\182\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\230\158\170", SkinRowInfo.WeaponID)
          end
        end
      end
    end
  end
  UIMgr:Hide(ViewID.UI_AwardPanel)
end

function WBP_AwardPanel_C:BindOnEquipButtonHovered()
  self.EquipHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_AwardPanel_C:BindOnEquipButtonUnhovered()
  self.EquipHoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_AwardPanel_C:OnHide()
  self.ResourceIdList = {}
  if IsListeningForInputAction(self, EscKeyName) then
    StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  end
end

return WBP_AwardPanel_C
