local WBP_LobbyEsc_C = UnLua.Class()

function WBP_LobbyEsc_C:Construct()
  self.Button_Exit.OnClicked:Add(self, WBP_LobbyEsc_C.OnClickedEsc)
end

function WBP_LobbyEsc_C:Destruct()
  self.Button_Exit.OnClicked:Remove(self, WBP_LobbyEsc_C.OnClickedEsc)
  self.ParentView = nil
end

function WBP_LobbyEsc_C:OnClickedEsc()
  if self.ParentView and self.EscFunc then
    self.EscFunc(self.ParentView)
  end
end

function WBP_LobbyEsc_C:ListenForEscInputAction()
  self:OnClickedEsc()
end

function WBP_LobbyEsc_C:InitInfo(ParentView, EscFunc)
  self.ParentView = ParentView
  self.EscFunc = EscFunc
end

return WBP_LobbyEsc_C
