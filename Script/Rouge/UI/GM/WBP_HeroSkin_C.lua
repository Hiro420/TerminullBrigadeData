local WBP_HeroSkin_C = UnLua.Class()
local TypeTitleList = UE.TArray(UE.FString)
local IdList = UE.TArray(0)

function WBP_HeroSkin_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_HeroSkin_C:InitWidget()
  self.Overridden.InitWidget(self)
end

function WBP_HeroSkin_C:OnOpen()
  self.Overridden.OnOpen(self)
  TypeTitleList:Clear()
  IdList:Clear()
  local SkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  if not SkinTable then
    UE4.UKismetSystemLibrary.PrintString(self, "not ResourceTable")
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local CurCharacterId = Character:GetTypeID()
  print("CharacterId = " .. CurCharacterId)
  for ID, CharacterSkin in pairs(SkinTable) do
    if CurCharacterId == CharacterSkin.CharacterID then
      TypeTitleList:Add(CharacterSkin.CharacterID .. " - " .. CharacterSkin.SkinRarity .. " - " .. tostring(CharacterSkin.SkinName))
      IdList:Add(ID)
    end
  end
  self:CreateTypeButtonList(TypeTitleList)
end

function WBP_HeroSkin_C:OnTypeButtonClick(Button, ItemData)
  self.Overridden.OnTypeButtonClick(self, Button)
  local index = ItemData.Index + 1
  local SkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  if not SkinTable then
    UE4.UKismetSystemLibrary.PrintString(self, "not ResourceTable")
    return
  end
  local Info = SkinTable[IdList:Get(index)]
  self.Overridden.ShowCustomPanel(self, Info.SkinID, Info.CharacterID, Info.SkinRarity, Info.SkinName, Info.Desc)
end

return WBP_HeroSkin_C
