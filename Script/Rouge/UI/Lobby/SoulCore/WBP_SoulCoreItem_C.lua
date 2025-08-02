local rapidjson = require("rapidjson")
local WBP_SoulCoreItem_C = UnLua.Class()

function WBP_SoulCoreItem_C:Construct()
end

function WBP_SoulCoreItem_C:Destruct()
  self.ParentView = nil
  self.SelectCallback = nil
end

function WBP_SoulCoreItem_C:OnListItemObjectSet(ListItemObj)
  self.ResourceId = ListItemObj.ResourceId
  self.Index = ListItemObj.Index
  self.SelectCallback = ListItemObj.Select
  self.ParentView = ListItemObj.ParentView
  self.CharacterId = ListItemObj.CharacterId
  self.WBP_CharacterItem:Init(self.ResourceId, self.CharacterId)
  local bIsUnLock = LogicRole.CheckCharacterUnlock(self.CharacterId)
  if bIsUnLock then
    self:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE.ESlateVisibility.Visible)
  end
end

function WBP_SoulCoreItem_C:BP_OnEntryReleased()
  print("WBP_SoulCoreItem_C:BP_OnEntryReleased")
  self.ParentView = nil
  self.SelectCallback = nil
  self.WBP_CharacterItem:UnInit()
end

function WBP_SoulCoreItem_C:BP_OnItemSelectionChanged(bIsSelected)
  self.WBP_CharacterItem:UpdateSelect(bIsSelected)
  if bIsSelected and self.SelectCallback then
    self.SelectCallback:Broadcast(self.Index, self.CharacterId, self.ResourceId)
  end
end

return WBP_SoulCoreItem_C
