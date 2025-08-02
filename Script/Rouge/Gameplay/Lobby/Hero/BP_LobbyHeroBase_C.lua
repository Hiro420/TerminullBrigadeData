local BP_LobbyHeroBase_C = UnLua.Class()

function BP_LobbyHeroBase_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  self.NameComponent:SetWidgetLocationMarkComponent(self.Mesh, "Socket_Head")
end

function BP_LobbyHeroBase_C:UpdateNickName(InName)
  local Widget = self.NameComponent:GetUserWidgetObject()
  if Widget then
    Widget:SetName(InName)
  end
end

return BP_LobbyHeroBase_C
