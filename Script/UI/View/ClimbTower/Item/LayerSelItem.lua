local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local LayerSelItem = UnLua.Class()

function LayerSelItem:Construct()
  self.MainButton.OnClicked:Add(self, self.SelLayer)
  self.MainButton.OnHovered:Add(self, self.OnHovered)
  self.MainButton.OnUnhovered:Add(self, self.OnUnhovered)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnLayerChange, self.OnLayerChange)
end

function LayerSelItem:OnHovered()
  UpdateVisibility(self.CanvasPanel_Hover, true)
  if self.SelIndex == self.Index then
    self:PlayAnimation(self.Ani_Sel_hover_in)
  else
    self:PlayAnimation(self.Ani_hover_in)
  end
end

function LayerSelItem:OnUnhovered()
  UpdateVisibility(self.CanvasPanel_Hover, false)
  if self.SelIndex == self.Index then
    self:PlayAnimation(self.Ani_Sel_hover_out)
  else
    self:PlayAnimation(self.Ani_hover_out)
  end
end

function LayerSelItem:Init(Index)
  self.RGStateController_Main:ChangeStatus("Normal", true)
  self.RGStateController_Lock:ChangeStatus("UnLock", true)
  self.Index = Index
  self.Txt_Layer_2:SetText(Index)
  self.Txt_Layer_3:SetText(Index)
  if ClimbTowerData:GetFloor() == self.Index then
    self.RGStateController_Main:ChangeStatus("Select", true)
  end
  local UnLockIndex = DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode)
  if UnLockIndex < self.Index then
    self.RGStateController_Lock:ChangeStatus("Lock", true)
  end
end

function LayerSelItem:SelLayer()
  if DataMgr.IsInTeam() and LogicTeam.IsCaptain() then
    local TeamInfo = DataMgr.GetTeamInfo()
    for i, SinglePlayerInfo in ipairs(TeamInfo.players) do
      if SinglePlayerInfo.id ~= DataMgr.GetUserId() then
        local Floor = DataMgr.GetTeamMemberGameFloorByModeAndWorld(SinglePlayerInfo.id, ClimbTowerData.GameMode, ClimbTowerData.WorldId)
        if Floor < self.Index then
          print("\233\152\159\229\145\152\230\178\161\230\156\137\233\154\190\229\186\166\230\178\161\230\156\137\232\167\163\233\148\129")
          ShowWaveWindow(304011)
          return
        end
      end
    end
  end
  if self.Index > DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode) then
    print("\233\154\190\229\186\166\230\178\161\230\156\137\232\167\163\233\148\129")
    ShowWaveWindow(15008)
    return
  end
  ClimbTowerData.Floor = self.Index
  self.SelIndex = self.Index
  EventSystem.Invoke(EventDef.ClimbTowerView.OnLayerChange, self.Index)
end

function LayerSelItem:OnLayerChange(Index)
  if Index == self.Index then
    self.RGStateController_Main:ChangeStatus("Select", true)
    self:PlayAnimation(self.Ani_click)
  end
  self.SelIndex = Index
end

return LayerSelItem
