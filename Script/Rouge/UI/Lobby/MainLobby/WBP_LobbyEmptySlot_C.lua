local WBP_LobbyEmptySlot_C = UnLua.Class()
function WBP_LobbyEmptySlot_C:Construct()
  self.Btn_EmptySlot.OnClicked:Add(self, self.BindOnEmptySlotButtonClicked)
end
function WBP_LobbyEmptySlot_C:BindOnEmptySlotButtonClicked()
end
return WBP_LobbyEmptySlot_C
