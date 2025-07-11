local WBP_GRFetterItem_C = UnLua.Class()
function WBP_GRFetterItem_C:UpdateGRFetterItem(FetterInfo)
  local tbHeroSkillTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroSkill)
  local fetterData
  if tbHeroSkillTable then
    for key, value in pairs(tbHeroSkillTable) do
      if value.ID == FetterInfo.SkillId then
        fetterData = value
        break
      end
    end
  end
  local tbHeroMonsterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if tbHeroMonsterTable then
    for key, value in pairs(tbHeroMonsterTable) do
      if value.ID == FetterInfo.HeroId then
        SetImageBrushByPath(self.Image_RoleIcon, value.FetterHeadIcon)
        break
      end
    end
  end
  self.TextBlock_Describe:SetText(fetterData.SimpleDesc)
  self.WBP_GRFetterIcon:UpdateGRFetterIcon(fetterData.IconPath, fetterData.Star)
  self.WBP_LobbyStarWidget:UpdateStar(fetterData.Star)
  self.WBP_GRFetterTypeBox:UpdateSkillTag(fetterData.SkillTags)
end
return WBP_GRFetterItem_C
