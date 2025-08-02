local WBP_LobbyRankPanel_C = UnLua.Class()

function WBP_LobbyRankPanel_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.LobbyPanelChanged, WBP_LobbyRankPanel_C.OnLobbyActivePanelChanged)
  EventSystem.AddListener(self, EventDef.LobbyRankPanel.OnEnterDetailedData, WBP_LobbyRankPanel_C.OnEnterDetailedData)
  EventSystem.AddListener(self, EventDef.LobbyRankPanel.OnExitDetailedData, WBP_LobbyRankPanel_C.OnExitDetailedData)
end

function WBP_LobbyRankPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.LobbyPanelChanged, WBP_LobbyRankPanel_C.OnLobbyActivePanelChanged, self)
  EventSystem.RemoveListener(EventDef.LobbyRankPanel.OnEnterDetailedData, WBP_LobbyRankPanel_C.OnEnterDetailedData, self)
  EventSystem.RemoveListener(EventDef.LobbyRankPanel.OnExitDetailedData, WBP_LobbyRankPanel_C.OnExitDetailedData, self)
end

function WBP_LobbyRankPanel_C:OnLobbyActivePanelChanged(LastActiveWidget, CurActiveWidget)
  if CurActiveWidget == self then
  end
end

function WBP_LobbyRankPanel_C:OnEnterDetailedData(GameRecordId)
  self.WBP_GRInformationPanel:RequestGRInformation(GameRecordId)
  self.WidgetSwitcher_Rank:SetActiveWidget(self.WBP_GRInformationPanel)
end

function WBP_LobbyRankPanel_C:OnExitDetailedData()
  self.WidgetSwitcher_Rank:SetActiveWidget(self.WBP_LobbyRank)
end

function WBP_LobbyRankPanel_C:OnExitDetailedDataPanel()
end

return WBP_LobbyRankPanel_C
