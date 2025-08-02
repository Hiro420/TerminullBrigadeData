local WBP_LobbySecondMenuButton_C = UnLua.Class()

function WBP_LobbySecondMenuButton_C:Construct()
  self.Button_Clicked.OnClicked:Add(self, WBP_LobbySecondMenuButton_C.OnClicked_Menu)
  self.Button_Clicked.OnHovered:Add(self, self.BindOnClickButtonHovered)
  self.Button_Clicked.OnUnhovered:Add(self, self.BindOnClickButtonUnhovered)
  self.Button_Clicked:SetAnimWidget(self)
end

function WBP_LobbySecondMenuButton_C:Show(LabelTagName, ChildLabelList)
  print("-----------------------------", LabelTagName)
  self.LabelTagName = LabelTagName
  self.ChildLabelList = ChildLabelList
  local Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, LabelTagName)
  if Result then
    self.Txt_MenuName:SetText(RowInfo.Name)
    self.Txt_MenuNameSelected:SetText(RowInfo.Name)
    if RowInfo.bSupportRedDot then
      self.WBP_RedDotView:ChangeRedDotId(LabelTagName, LabelTagName)
    end
    self.WBP_SystemUnlock:InitSysId(RowInfo.SystemId)
  end
  EventSystem.AddListener(self, EventDef.Lobby.OnLobbyLabelSelected, self.BindOnLobbyLabelSelected)
end

function WBP_LobbySecondMenuButton_C:BindOnLobbyLabelSelected(LabelTagName)
  self:SetActivateState(LogicLobby.GetCurSelectedLabelName() == self.LabelTagName)
end

function WBP_LobbySecondMenuButton_C:Destruct()
  self.Button_Clicked.OnClicked:Remove(self, WBP_LobbySecondMenuButton_C.OnClicked_Menu)
  EventSystem.RemoveListener(EventDef.Lobby.OnLobbyLabelSelected, self.BindOnLobbyLabelSelected, self)
end

function WBP_LobbySecondMenuButton_C:BindOnClickButtonHovered()
  self:UpdateMenumNameStyleByStatus()
end

function WBP_LobbySecondMenuButton_C:BindOnClickButtonUnhovered()
  self:UpdateMenumNameStyleByStatus()
end

function WBP_LobbySecondMenuButton_C:SetActivateState(Activate)
  self.IsActivate = Activate
  self:UpdateMenumNameStyleByStatus()
  if self.IsActivate then
    self.Image_Back:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Back:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_LobbySecondMenuButton_C:UpdateMenumNameStyleByStatus()
  local SlateColor = UE.FSlateColor()
  if self.IsActivate then
    SlateColor = self.SelectedTextColor
    self.Txt_MenuNameSelected:SetColorAndOpacity(SlateColor)
    self.Txt_MenuNameSelected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_MenuName:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Txt_MenuNameSelected:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_MenuName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self.Button_Clicked:IsHovered() then
      SlateColor = self.HoveredTextColor
    else
      SlateColor = self.NormalTextColor
    end
    self.Txt_MenuName:SetColorAndOpacity(SlateColor)
  end
end

function WBP_LobbySecondMenuButton_C:OnClicked_Menu()
  LogicLobby.ChangeLobbyPanelLabelSelected(self.LabelTagName)
end

return WBP_LobbySecondMenuButton_C
