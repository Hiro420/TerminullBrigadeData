local InitialRoleSelectionHandler = require("Protocol.InitialRoleSelection.InitialRoleSelectionHandler")
local InitialRoleSelectionViewModel = CreateDefaultViewModel()
InitialRoleSelectionViewModel.propertyBindings = {}
InitialRoleSelectionViewModel.subViewModels = {}
function InitialRoleSelectionViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListenerNew(EventDef.InitialRoleSelection.OnSelectRoleSucc, self, self.OnSelectRoleSucc)
end
function InitialRoleSelectionViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.InitialRoleSelection.OnSelectRoleSucc, self, self.OnSelectRoleSucc)
  self.Super.OnShutdown(self)
end
function InitialRoleSelectionViewModel:OnSelectRoleSucc()
  if self:GetFirstView() then
    UIMgr:Hide(ViewID.UI_InitialRoleSelection, true)
  end
end
function InitialRoleSelectionViewModel:SelectHero(HeroId)
  InitialRoleSelectionHandler.RequestSelectHero(HeroId)
end
return InitialRoleSelectionViewModel
