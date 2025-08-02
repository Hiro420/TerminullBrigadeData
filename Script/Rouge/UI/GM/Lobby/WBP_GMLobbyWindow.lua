local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_GMLobbyWindow = Class(ViewBase)

function WBP_GMLobbyWindow:BindClickHandler()
  self.CloseBtn.OnClicked:Add(self, self.CloseClick)
end

function WBP_GMLobbyWindow:UnBindClickHandler()
end

function WBP_GMLobbyWindow:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_GMLobbyWindow:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_GMLobbyWindow:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function WBP_GMLobbyWindow:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function WBP_GMLobbyWindow:CloseClick()
  UIMgr:Hide(ViewID.UI_LobbyGM)
end

return WBP_GMLobbyWindow
