local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RedDotData = require("Modules.RedDot.RedDotData")
local WBP_RoleSkinList_C = UnLua.Class()

function WBP_RoleSkinList_C:Construct()
end

function WBP_RoleSkinList_C:Destruct()
end

function WBP_RoleSkinList_C:InitList(Parent)
  self.Parent = Parent
end

function WBP_RoleSkinList_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.Parent then
    self.Parent.EnterList = true
  end
end

function WBP_RoleSkinList_C:OnMouseLeave(MouseEvent)
  if self.Parent then
    self.Parent.EnterList = false
  end
end

return WBP_RoleSkinList_C
