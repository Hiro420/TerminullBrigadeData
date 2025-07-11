local WBP_ProficiencyAwardResStoneSlotTips = UnLua.Class()
function WBP_ProficiencyAwardResStoneSlotTips:Construct()
end
function WBP_ProficiencyAwardResStoneSlotTips:Destruct()
end
function WBP_ProficiencyAwardResStoneSlotTips:InitProficiencyAwardResStoneSlotTips(ItemId, GearLv, bIsUnlock, SlotNum, bShowTips)
  UpdateVisibility(self, true)
  self:SetRenderOpacity(1)
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if tbGeneral and tbGeneral[ItemId] then
    self.RGRichTextName:SetText(tbGeneral[ItemId].Name)
    self.RGTextDesc:SetText(tbGeneral[ItemId].Desc)
  end
  if bShowTips then
    UpdateVisibility(self.WBP_ProficiencyUnlockPrompt, not bIsUnlock)
    if not bIsUnlock then
      local strFmt = NSLOCTEXT("WBP_ProficiencyAwardResStoneSlotTips", "strFmt", "\232\190\190\229\136\176\231\134\159\231\187\131\229\186\166\231\173\137\231\186\167%d\232\167\163\233\148\129\229\165\150\229\138\177")
      local str = UE.FTextFormat(strFmt(), GearLv)
      self.WBP_ProficiencyUnlockPrompt.RGRichTextBlockUnlock:SetText(str)
    end
  else
    UpdateVisibility(self.WBP_ProficiencyUnlockPrompt, false)
  end
  self.RGTextLeftNum:SetText(SlotNum - 1)
  self.RGTextRightNum:SetText(SlotNum)
end
return WBP_ProficiencyAwardResStoneSlotTips
