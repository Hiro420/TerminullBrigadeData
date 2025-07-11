local ViewBase = require("Framework.UIMgr.ViewBase")
local WBP_InitialRoleSelectionMask = UnLua.Class(ViewBase)
function WBP_InitialRoleSelectionMask:Construct()
end
function WBP_InitialRoleSelectionMask:OnInit()
  self.DataBindTable = {}
end
function WBP_InitialRoleSelectionMask:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_InitialRoleSelectionMask:BindClickHandler()
end
function WBP_InitialRoleSelectionMask:UnBindClickHandler()
end
function WBP_InitialRoleSelectionMask:OnShow()
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_InitialRoleSelectionMask:OnHide()
  self:UnBindClickHandler()
  self:SetEnhancedInputActionBlocking(false)
end
function WBP_InitialRoleSelectionMask:OnHideByOther()
  self:UnBindClickHandler()
end
return WBP_InitialRoleSelectionMask
