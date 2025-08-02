local SpaceName = "Space"
local EscName = "PauseGame"
local WBP_ProficiencyLvUp = UnLua.Class()

function WBP_ProficiencyLvUp:Construct()
end

function WBP_ProficiencyLvUp:Destruct()
end

function WBP_ProficiencyLvUp:InitProfyLvUp(ProfyData, ParentView, AwardList)
  self.ParentView = ParentView
  self.ProfyData = ProfyData
  self.AwardList = AwardList
  if not IsListeningForInputAction(self, SpaceName) then
    ListenForInputAction(SpaceName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.Hide
    })
  end
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.OnEscPress
    })
  end
  self.viewModel = UIModelMgr:Get("ProficiencyViewModel")
  self.RGTextLv:SetText(ProfyData.ProfyTaskTb.Level)
  local tbProfy = LuaTableMgr.GetLuaTableByName(TableNames.TBProfy)
  if tbProfy and tbProfy[ProfyData.ProfyTaskTb.Level] then
    self.RGTextName:SetText(tbProfy[ProfyData.ProfyTaskTb.Level].Name)
  end
  self:PlayAnimation(self.ANi_IN)
end

function WBP_ProficiencyLvUp:OnrShowProfyLvUpByOpacity()
  self:SetRenderOpacity(1)
  self:PlayAnimation(self.ANi_IN)
end

function WBP_ProficiencyLvUp:Hide()
  self:StopAnimation(self.ANi_IN)
  self:PlayAnimation(self.ANi_OUT, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
  StopListeningForInputAction(self, SpaceName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
end

function WBP_ProficiencyLvUp:OnAnimationFinished(Animation)
  if Animation == self.ANi_OUT then
    UpdateVisibility(self, false)
    if UE.RGUtil.IsUObjectValid(self.ParentView) then
    end
  end
end

function WBP_ProficiencyLvUp:OnEscPress()
end

return WBP_ProficiencyLvUp
