local WBP_LobbyTaskPanel_C = UnLua.Class()

function WBP_LobbyTaskPanel_C:Construct()
  self.ButtonOpenMall.OnClicked:Add(self, self.OpenMall)
end

function WBP_LobbyTaskPanel_C:Destruct()
  self.ButtonOpenMall.OnClicked:Remove(self, self.OpenMall)
end

function WBP_LobbyTaskPanel_C:PlayInAnimation()
  self:PlayAnimation(self.ani_lobbytaskpanl_in)
end

function WBP_LobbyTaskPanel_C:PlayOutAnimation()
  self:PlayAnimation(self.ani_lobbytaskpanl_out)
end

function WBP_LobbyTaskPanel_C:OpenMall()
  UIMgr:Show(ViewID.UI_DrawCard, true)
end

return WBP_LobbyTaskPanel_C
