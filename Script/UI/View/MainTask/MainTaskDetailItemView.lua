local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local MainTaskDetailItemView = Class(ViewBase)

function MainTaskDetailItemView:BindClickHandler()
end

function MainTaskDetailItemView:UnBindClickHandler()
end

function MainTaskDetailItemView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function MainTaskDetailItemView:OnDestroy()
  self:UnBindClickHandler()
end

function MainTaskDetailItemView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function MainTaskDetailItemView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function MainTaskDetailItemView:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    UpdateVisibility(self.Overlay_Finish, ListItemObj.Finish)
    UpdateVisibility(self.TextTitle_Sel_Finish, ListItemObj.Finish)
    UpdateVisibility(self.Overlay_Normal, not ListItemObj.Finish)
    self.ActiveOverlay = self.Overlay_Normal
    if ListItemObj.Finish then
      self.ActiveOverlay = self.Overlay_Finish
    end
    local TaskGroupData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
    local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
    self.TextContent:SetText(TaskData[tonumber(ListItemObj.TaskId)].title)
    self.TextContent_Sel:SetText(TaskData[tonumber(ListItemObj.TaskId)].title)
    self.TextContent_Finish:SetText(TaskData[tonumber(ListItemObj.TaskId)].title)
    self.TextTitle:SetText(TaskData[tonumber(ListItemObj.TaskId)].name)
    self.TextTitle_Sel:SetText(TaskData[tonumber(ListItemObj.TaskId)].name)
    self.TextTitle_Finish:SetText(TaskData[tonumber(ListItemObj.TaskId)].name)
  end
end

function MainTaskDetailItemView:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hov, true)
  PlaySound2DEffect(2, "MainTaskDetailItemView_Hov")
end

function MainTaskDetailItemView:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hov, false)
end

function MainTaskDetailItemView:BP_OnItemSelectionChanged(bSelect)
  UpdateVisibility(self.Overlay_Sel, bSelect)
  UpdateVisibility(self.ActiveOverlay, not bSelect)
  if bSelect then
    PlaySound2DEffect(1, "MainTaskDetailItemView_Selection")
  end
end

function MainTaskDetailItemView:BP_OnEntryReleased()
  UpdateVisibility(self.Overlay_Sel, false)
end

return MainTaskDetailItemView
