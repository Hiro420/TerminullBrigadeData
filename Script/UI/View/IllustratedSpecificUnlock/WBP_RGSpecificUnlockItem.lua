local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_RGSpecificUnlockItem = UnLua.Class()
function WBP_RGSpecificUnlockItem:Construct()
  self.Btn_OpenSpecificView.OnClicked:Add(self, self.BindOnOpenSpecificView)
end
function WBP_RGSpecificUnlockItem:Destruct()
  self.Btn_OpenSpecificView.OnClicked:Remove(self, self.BindOnOpenSpecificView)
end
function WBP_RGSpecificUnlockItem:InitSpecificUnlockItem(SpecificData, ItemDelayHide, Idx, ParentView)
  self.Idx = Idx
  self.ParentView = ParentView
  UpdateVisibility(self, true)
  self:PlayAnimation(self.Ani_in)
  local specificId = SpecificData.SpecificId
  self.WBP_GenericModifyItem:InitSpecificModifyItem(specificId, false, true)
  local specificName = GetInscriptionName(specificId)
  self.Txt_SpecificName:SetText(specificName)
  local taskId = SpecificData.TaskID
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskData, taskId)
  if result then
    self.Txt_TaskDesc:SetText(row.content)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:StopAnimation(self.Ani_in)
      self:PlayAnimation(self.Ani_out)
    end
  }, ItemDelayHide, false)
end
function WBP_RGSpecificUnlockItem:OnAnimationFinished(Ani)
  if Ani == self.Ani_out then
    if self.ParentView then
      self.ParentView:BindCloseSelf(self.Idx)
    end
    self:Hide()
  end
end
function WBP_RGSpecificUnlockItem:BindOnOpenSpecificView()
  if not UIMgr:IsShow(UIDef.UI_IllustratedGuideSpecificModify) then
    local label = LogicLobby.GetLabelTagNameByUIName("UI_IllustratedGuideMenu")
    LogicLobby.ChangeLobbyPanelLabelSelected(label)
    UIMgr:Show(ViewID.UI_IllustratedGuideSpecificModify)
  end
end
function WBP_RGSpecificUnlockItem:Hide()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  UpdateVisibility(self, false)
end
return WBP_RGSpecificUnlockItem
