local ViewSetToggle = UnLua.Class()

function ViewSetToggle:Construct()
  self.Overridden.Construct(self)
  self.Btn_Check.OnClicked:Add(self, self.OnCheckClick)
end

function ViewSetToggle:Destruct()
  self.Overridden.Destruct(self)
  self.Btn_Check.OnClicked:Remove(self, self.OnCheckClick)
end

function ViewSetToggle:InitViewSetToggle(Name, ParentView, SystemId)
  self.WBP_SystemUnlock:InitSysId(SystemId)
  self.RGTextUnSelectName:SetText(Name)
  self.RGTextSelectName:SetText(Name)
  self.RGTextHoverName:SetText(Name)
  self.ParentView = ParentView
end

function ViewSetToggle:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end

function ViewSetToggle:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end

function ViewSetToggle:OnCheckClick()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
    if UserClickStatisticsMgr and self.ParentView.TbToggleIdToView[self.ToggleIndex] and self.ParentView.TbToggleIdToView[self.ToggleIndex].ClickStatistics ~= "none" then
      UserClickStatisticsMgr:AddClickStatistics(self.ParentView.TbToggleIdToView[self.ToggleIndex].ClickStatistics)
      print("ViewSetToggle:OnCheckClick", self.ParentView.TbToggleIdToView[self.ToggleIndex].ClickStatistics)
    end
  end
  if 4 == self.ToggleIndex then
    local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
    if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.MATRIX) then
      return
    end
  end
  local bIsCheck = self.ToggleGroup.CurSelectId == self.ToggleIndex
  self:CheckStateChanged(not bIsCheck)
end

return ViewSetToggle
