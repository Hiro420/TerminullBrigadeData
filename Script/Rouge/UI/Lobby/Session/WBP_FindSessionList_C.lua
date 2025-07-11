local WBP_FindSessionList_C = UnLua.Class()
function WBP_FindSessionList_C:AddSession(Session)
  local Margin = UE.FMargin()
  Margin.Top = 10
  Session:SetPadding(Margin)
  self.ScrollBox_SessionList:AddChild(Session)
end
return WBP_FindSessionList_C
