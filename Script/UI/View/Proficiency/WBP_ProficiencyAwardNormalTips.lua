local WBP_ProficiencyAwardNormalTips = UnLua.Class()
function WBP_ProficiencyAwardNormalTips:Construct()
end
function WBP_ProficiencyAwardNormalTips:Destruct()
end
function WBP_ProficiencyAwardNormalTips:Show(RewardId, IsInscription, Level, IsUnlock)
  UpdateVisibility(self, true)
  local CanOperate = false
  if IsInscription then
    local DA = GetLuaInscription(RewardId)
    local name = GetInscriptionName(RewardId)
    self.Txt_Name:SetText(name)
    self.Txt_Desc:SetText(GetLuaInscriptionDesc(RewardId))
    local Result, ItemRareRowInfo = GetRowData(DT.DT_ItemRarity, tostring(DA.Rarity))
    if Result then
      self.Image_di_rarity:SetColorAndOpacity(ItemRareRowInfo.DisplayNameColor.SpecifiedColor)
    end
  else
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, RewardId)
    if Result then
      self.Txt_Name:SetText(RowInfo.Name)
      self.Txt_Desc:SetText(RowInfo.Desc)
      local Result, ItemRareRowInfo = GetRowData(DT.DT_ItemRarity, tostring(RowInfo.Rare))
      if Result then
        self.Image_di_rarity:SetColorAndOpacity(ItemRareRowInfo.DisplayNameColor.SpecifiedColor)
      end
      if RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin or RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
        CanOperate = true
      end
    else
      print("WBP_ProficiencyAwardNormalTips:Show not found TBGeneral RowInfo, RowId:", RewardId)
    end
  end
  UpdateVisibility(self.WBP_ProficiencyUnlockPrompt, not IsUnlock)
  if not IsUnlock then
    local str = UE.FTextFormat(self.LockTip, Level)
    self.WBP_ProficiencyUnlockPrompt.RGRichTextBlockUnlock:SetText(str)
  end
  UpdateVisibility(self.WBP_CustomKeyName, CanOperate)
end
function WBP_ProficiencyAwardNormalTips:Hide()
  UpdateVisibility(self, false)
end
function WBP_ProficiencyAwardNormalTips:ShowPreview()
end
return WBP_ProficiencyAwardNormalTips
