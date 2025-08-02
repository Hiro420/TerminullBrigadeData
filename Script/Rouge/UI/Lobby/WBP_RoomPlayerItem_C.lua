local WBP_RoomPlayerItem_C = UnLua.Class()

function WBP_RoomPlayerItem_C:Construct()
  self.PlayerId = {}
end

function WBP_RoomPlayerItem_C:UpdateInfo(PlayerInfo)
  self.PlayerInfo = PlayerInfo
  local RoomInfo = DataMgr.GetRoomInfo()
  self.Txt_PlayerInfo:SetText("\231\142\169\229\174\182\229\144\141:" .. self.PlayerInfo.nickname .. ", \231\142\169\229\174\182ID:" .. self.PlayerInfo.roleid .. ", \230\136\191\228\184\187" .. tostring(RoomInfo.ownerPlayer == self.PlayerInfo.roleid))
end

return WBP_RoomPlayerItem_C
