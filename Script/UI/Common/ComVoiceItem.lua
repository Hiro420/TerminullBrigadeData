local UnLua = _G.UnLua
local ComVoiceItem = UnLua.Class()

function ComVoiceItem:Construct()
  self.Overridden.Construct(self)
end

function ComVoiceItem:Destruct()
  self.Overridden.Destruct(self)
end

function ComVoiceItem:ShowItem(ResourcesID)
  local CommunicationTb = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  local VoiceRowData = CommunicationTb and CommunicationTb[ResourcesID]
  if VoiceRowData then
    SetImageBrushByPath(self.VoiceIcon, VoiceRowData.BigIcon)
  end
end

return ComVoiceItem
