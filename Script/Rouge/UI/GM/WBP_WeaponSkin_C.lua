local WBP_WeaponSkin_C = UnLua.Class()
local TypeTitleList = UE.TArray(UE.FString)
local IdList = UE.TArray(0)
function WBP_WeaponSkin_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_WeaponSkin_C:InitWidget()
  self.Overridden.InitWidget(self)
end
function WBP_WeaponSkin_C:OnOpen()
  self.Overridden.OnOpen(self)
  local SkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBWeaponSkin)
  if not SkinTable then
    print("not TableNames.TBWeaponSkin")
    return
  end
  TypeTitleList:Clear()
  IdList:Clear()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local Weapon = Character:GetCurrentWeapon()
  local CurWeaponId = Weapon:GetItemId()
  print("weaponId = " .. CurWeaponId)
  for ID, WeaponSkin in pairs(SkinTable) do
    if CurWeaponId == WeaponSkin.WeaponID then
      TypeTitleList:Add(WeaponSkin.WeaponID .. " - " .. WeaponSkin.SkinRarity .. " - " .. tostring(WeaponSkin.SkinName))
      IdList:Add(ID)
    end
  end
  self:CreateTypeButtonList(TypeTitleList)
end
function WBP_WeaponSkin_C:OnTypeButtonClick(Button, ItemData)
  self.Overridden.OnTypeButtonClick(self, Button)
  local index = ItemData.Index + 1
  local SkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBWeaponSkin)
  if not SkinTable then
    UE4.UKismetSystemLibrary.PrintString(self, "not ResourceTable")
    return
  end
  local Info = SkinTable[IdList:Get(index)]
  self.Overridden.ShowCustomPanel(self, Info.SkinID, Info.WeaponID, Info.SkinRarity, Info.SkinName, Info.Desc)
end
return WBP_WeaponSkin_C
