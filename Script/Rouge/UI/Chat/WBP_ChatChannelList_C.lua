local WBP_ChatChannelList_C = UnLua.Class()
function WBP_ChatChannelList_C:Construct()
  self.Overridden.Construct(self)
  self.RGToggleGroupChannel.OnCheckStateChanged:Add(self, self.OnToggleCheckStateChanged)
end
function WBP_ChatChannelList_C:ShowChannelList(ParentView)
  self.ParentView = ParentView
  local Index = 1
  local ChannelItemComposite = GetOrCreateItem(self.HorizontalBoxChannelList, Index, self.WBP_ChatChannelItem:GetClass())
  ChannelItemComposite:Init(UE.EChatChannel.Composite)
  self.RGToggleGroupChannel:AddToGroup(UE.EChatChannel.Composite, ChannelItemComposite)
  Index = Index + 1
  for i = 0, UE.EChatChannel.Composite - 1 do
    local result, row = GetRowData(DT.DT_ChatChannel, i)
    if result then
      local ChannelItem = GetOrCreateItem(self.HorizontalBoxChannelList, Index, self.WBP_ChatChannelItem:GetClass())
      ChannelItem:Init(i)
      self.RGToggleGroupChannel:AddToGroup(i, ChannelItem)
      Index = Index + 1
    end
  end
  HideOtherItem(self.HorizontalBoxChannelList, Index)
  self.RGToggleGroupChannel:SelectId(LogicChat.CurSelectChannel)
end
function WBP_ChatChannelList_C:OnToggleCheckStateChanged(SelectIndex)
  if self.ParentView then
    self.ParentView:SetCurSelectChannel(SelectIndex)
  end
end
function WBP_ChatChannelList_C:Destruct()
  self.Overridden.Destruct(self)
  self.ParentView = nil
  self.RGToggleGroupChannel.OnCheckStateChanged:Remove(self, self.OnToggleCheckStateChanged)
end
return WBP_ChatChannelList_C
