local WBP_LobbyRoleModPanel_C = UnLua.Class()
function WBP_LobbyRoleModPanel_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, WBP_LobbyRoleModPanel_C.OnChangeRoleItemClicked)
end
function WBP_LobbyRoleModPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, WBP_LobbyRoleModPanel_C.OnChangeRoleItemClicked)
end
function WBP_LobbyRoleModPanel_C:OnChangeRoleItemClicked(HeroId)
  self.WBP_LobbyModViewPanel:InitAllModInfo(HeroId)
end
return WBP_LobbyRoleModPanel_C
