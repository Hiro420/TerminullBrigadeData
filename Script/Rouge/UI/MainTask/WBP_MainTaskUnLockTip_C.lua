local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_MainTaskUnLockTip_C = Class(ViewBase)

function WBP_MainTaskUnLockTip_C:BindClickHandler()
end

function WBP_MainTaskUnLockTip_C:UnBindClickHandler()
end

function WBP_MainTaskUnLockTip_C:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_MainTaskUnLockTip_C:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_MainTaskUnLockTip_C:OnShow(GroupId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local TaskGroupData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  if TaskGroupData[GroupId] then
    self.Name:SetText(TaskGroupData[GroupId].title)
    self.Theme:SetText(TaskGroupData[GroupId].content)
    SetImageBrushByPath(self.URGImage_1, TaskGroupData[GroupId].icon)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.AutoCloseTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.AutoCloseTimer)
  end
  self.AutoCloseTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      UIMgr:Hide(ViewID.UI_MainTaskUnLockTip)
    end
  }, 3, true)
end

function WBP_MainTaskUnLockTip_C:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

return WBP_MainTaskUnLockTip_C
