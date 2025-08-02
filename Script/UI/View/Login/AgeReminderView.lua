local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local AgeReminderView = Class(ViewBase)

function AgeReminderView:BindClickHandler()
  self.Btn_Exit.OnClicked:Add(self, self.BindOnEscKeyPressed)
end

function AgeReminderView:UnBindClickHandler()
  self.Btn_Exit.OnClicked:Remove(self, self.BindOnEscKeyPressed)
end

function AgeReminderView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function AgeReminderView:OnDestroy()
  self:UnBindClickHandler()
end

function AgeReminderView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:SetFocus()
end

function AgeReminderView:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_AgeReminder)
end

function AgeReminderView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

return AgeReminderView
