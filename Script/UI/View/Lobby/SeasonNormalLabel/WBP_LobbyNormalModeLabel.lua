local SeasonData = require("Modules.Season.SeasonData")
local WBP_LobbyNormalModeLabel = UnLua.Class()

function WBP_LobbyNormalModeLabel:Construct()
  EventSystem.AddListenerNew(EventDef.Season.SeasonModeChanged, self, self.OnSeasonModeChanged)
  self:OnSeasonModeChanged(SeasonData.CurSelectSeasonMode)
  self.Btn_Select.OnClicked:Add(self, self.OnBtnSelectClicked)
end

function WBP_LobbyNormalModeLabel:Destruct()
  EventSystem.RemoveListenerNew(EventDef.Season.SeasonModeChanged, self, self.OnSeasonModeChanged)
  self.Btn_Select.OnClicked:Remove(self, self.OnBtnSelectClicked)
end

function WBP_LobbyNormalModeLabel:OnSeasonModeChanged(SeasonMode)
  if SeasonMode == ESeasonMode.NormalMode then
    self:Show()
  else
    self:Hide()
  end
end

function WBP_LobbyNormalModeLabel:OnBtnSelectClicked()
  if self.StateCtrl_Drop.DefaultKey == EDrop.Expand then
    self.StateCtrl_Drop:ChangeStatus(EDrop.Fold)
  else
    self.StateCtrl_Drop:ChangeStatus(EDrop.Expand)
    self.RGToggleCompGroup_SeasonItem:ClearGroup()
    local registerSeasonID = DataMgr.GetBasicInfo().registerSeasonID
    local curSeasonID = ModuleManager:Get("SeasonModule"):GetCurSeasonID()
    local idx = 1
    if registerSeasonID > 1 then
      local item = GetOrCreateItem(self.RGScrollBox_SeasonItem, idx, self.WBP_NormalDropDownItem:GetClass())
      item:InitNormalDropDownItem(0)
      local toggleComp = item:GetWidgetComp2DByName(UE.URGWidgetCom2D_Toggle.StaticClass():GetName(), false)
      if toggleComp then
        self.RGToggleCompGroup_SeasonItem:AddToGroup(1, toggleComp)
      end
      idx = idx + 1
    end
    for i = registerSeasonID, curSeasonID - 1 do
      local item = GetOrCreateItem(self.RGScrollBox_SeasonItem, idx, self.WBP_NormalDropDownItem:GetClass())
      item:InitNormalDropDownItem(i)
      local toggleComp = item:GetWidgetComp2DByName(UE.URGWidgetCom2D_Toggle.StaticClass():GetName(), false)
      if toggleComp then
        self.RGToggleCompGroup_SeasonItem:AddToGroup(i, toggleComp)
      end
      idx = idx + 1
    end
    HideOtherItem(self.RGScrollBox_SeasonItem, idx)
    self.RGToggleCompGroup_SeasonItem:SelectId(DataMgr.GetBasicInfo().selectedPastGrowthSeasonID, true)
  end
end

function WBP_LobbyNormalModeLabel:InitLobbyNormalModeLabel()
  self.StateCtrl_Drop:ChangeStatus(EDrop.Expand)
end

function WBP_LobbyNormalModeLabel:Show(...)
  UpdateVisibility(self, true)
  self.RGToggleCompGroup_SeasonItem.OnCheckStateChanged:Add(self, self.OnCheckStateChanged)
end

function WBP_LobbyNormalModeLabel:Hide()
  UpdateVisibility(self, false)
  self.StateCtrl_Drop:ChangeStatus(EDrop.Fold)
  self.RGToggleCompGroup_SeasonItem.OnCheckStateChanged:Remove(self, self.OnCheckStateChanged)
end

function WBP_LobbyNormalModeLabel:OnCheckStateChanged(SelectId)
  local SeasonModule = ModuleManager:Get("SeasonModule")
  SeasonModule:SelectPastSeasonID(tonumber(SelectId))
end

return WBP_LobbyNormalModeLabel
