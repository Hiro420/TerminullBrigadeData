local WBP_HeroTalent_C = UnLua.Class()
local TypeTitleList = UE.TArray(UE.FString)
local TypeIdList = UE.TArray(0)
local SecondIdList = UE.TArray(0)

function WBP_HeroTalent_C:Construct()
  self.Overridden.Construct(self)
  self:InitWidget()
  self:CreateTypeButtonList(TypeTitleList)
end

function WBP_HeroTalent_C:InitWidget()
  self.Overridden.InitWidget(self)
  local HeroTalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroTalent)
  if not HeroTalentTable then
    return
  end
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if not CharacterTable then
    return
  end
  for HeroId, TalentInfo in pairs(HeroTalentTable) do
    if CharacterTable[HeroId] then
      TypeTitleList:Add(CharacterTable[HeroId].Name)
    else
      print("CharacterTable no this HeroId")
      TypeTitleList:Add(HeroId)
    end
    TypeIdList:Add(HeroId)
  end
end

function WBP_HeroTalent_C:OnTypeButtonClick(Button)
  self.Overridden.OnTypeButtonClick(self, Button)
  local index = Button.ButtonIndex + 1
  local HeroTalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroTalent)
  if not HeroTalentTable then
    return
  end
  local TalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTalent)
  if not TalentTable then
    return
  end
  local IdGroup = HeroTalentTable[TypeIdList:Get(index)].TalentGroupIDS
  local HeroGroupLength = #IdGroup
  local IdInGroup = function(GroupId)
    print("cur find" .. GroupId)
    for i = 1, HeroGroupLength do
      if GroupId == IdGroup[i] then
        return true
      end
    end
    return false
  end
  SecondIdList:Clear()
  local SecondTypeTitleList = UE.TArray(UE.FString)
  for TalentId, TalentInfo in pairs(TalentTable) do
    if IdInGroup(TalentInfo.GroupID) then
      SecondTypeTitleList:Add(TalentInfo.Name)
      SecondIdList:Add(TalentId)
    end
  end
  self.HeroId = TypeIdList:Get(index)
  self:CreateSecondTypeButtonList(SecondTypeTitleList)
end

function WBP_HeroTalent_C:OnSecondTypeButtonClick(Button)
  self.Overridden.OnSecondTypeButtonClick(self, Button)
  local index = Button.ButtonIndex + 1
  local TalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTalent)
  if not TalentTable then
    return
  end
  local Info = TalentTable[SecondIdList:Get(index)]
  self.Overridden.ShowCustomPanel(self, Info.ID, Info.GroupID, Info.Name, Info.Desc, Info.Level)
end

return WBP_HeroTalent_C
