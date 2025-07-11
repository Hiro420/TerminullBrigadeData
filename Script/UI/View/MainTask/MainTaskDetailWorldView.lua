local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local MainTaskDetailWorldView = Class(ViewBase)
function MainTaskDetailWorldView:BindClickHandler()
end
function MainTaskDetailWorldView:UnBindClickHandler()
end
function MainTaskDetailWorldView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function MainTaskDetailWorldView:OnDestroy()
  self:UnBindClickHandler()
end
function MainTaskDetailWorldView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function MainTaskDetailWorldView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function MainTaskDetailWorldView:InitWorldView(ClickedFunc)
  UpdateVisibility(self.Overlay_UnLock, not Logic_MainTask.IsGroupUnLock(self.MainTaskId))
  UpdateVisibility(self.Overlay_Normal, Logic_MainTask.IsGroupUnLock(self.MainTaskId))
  self.Btn.OnClicked:Clear()
  self.Btn.OnClicked:Add(self, function()
    if not Logic_MainTask.IsGroupUnLock(self.MainTaskId) then
      ShowWaveWindow(self.ErrorTipId)
      return
    end
    ClickedFunc(self.MainTaskId)
  end)
end
function MainTaskDetailWorldView:OnSelected(bSel)
  UpdateVisibility(self.Overlay_Sel, bSel)
  UpdateVisibility(self.Overlay_Normal, not bSel)
end
function MainTaskDetailWorldView:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hov, true)
end
function MainTaskDetailWorldView:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hov, false)
end
return MainTaskDetailWorldView
