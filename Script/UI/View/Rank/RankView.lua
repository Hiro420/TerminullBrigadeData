local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RankData = require("UI.View.Rank.RankData")
local RankView = Class(ViewBase)

function RankView:BindClickHandler()
end

function RankView:UnBindClickHandler()
end

function RankView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function RankView:OnDestroy()
  self:UnBindClickHandler()
end

function RankView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function RankView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

return RankView
