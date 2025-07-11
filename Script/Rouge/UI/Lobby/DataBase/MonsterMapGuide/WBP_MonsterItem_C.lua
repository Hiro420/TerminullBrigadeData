local WBP_MonsterItem_C = UnLua.Class()
function WBP_MonsterItem_C:OnListItemObjectSet(ListItemObj)
  self.ResourceId = ListItemObj.ResourceId
  self.Index = ListItemObj.Index
  self.SelectCallback = ListItemObj.Select
  self.Id = ListItemObj.Id
  self.WBP_CharacterItem:Init(self.ResourceId, self.Id)
  local bIsUnLock = LogicRole.CheckCharacterUnlock(self.Id)
  if bIsUnLock then
    self:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE.ESlateVisibility.Visible)
  end
end
function WBP_MonsterItem_C:BP_OnEntryReleased()
  print("WBP_SoulCoreItem_C:BP_OnEntryReleased")
  self.SelectCallback = nil
  self.WBP_CharacterItem:UnInit()
end
function WBP_MonsterItem_C:BP_OnItemSelectionChanged(bIsSelected)
  self.WBP_CharacterItem:UpdateSelect(bIsSelected)
  if bIsSelected and self.SelectCallback then
    self.SelectCallback:Broadcast(self.Index, self.Id, self.ResourceId)
  end
end
return WBP_MonsterItem_C
