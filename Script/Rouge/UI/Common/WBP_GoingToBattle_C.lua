local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_GoingToBattle_C = Class(ViewBase)

function WBP_GoingToBattle_C:BindClickHandler()
end

function WBP_GoingToBattle_C:UnBindClickHandler()
end

function WBP_GoingToBattle_C:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_GoingToBattle_C:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_GoingToBattle_C:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function WBP_GoingToBattle_C:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

return WBP_GoingToBattle_C
