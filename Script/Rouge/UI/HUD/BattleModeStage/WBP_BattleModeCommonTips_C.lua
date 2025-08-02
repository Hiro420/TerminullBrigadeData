local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_BattleModeCommonTips_C = UnLua.Class()

function WBP_BattleModeCommonTips_C:Construct()
end

function WBP_BattleModeCommonTips_C:OnDisplay(Param)
  self.Overridden.OnDisplay(self)
  self:PlayAnimation(self.Ani_CanvasPanelGameStart_start)
  if Param then
    self:RefreshInfo(Param.title, Param.content)
    if Param.time then
      GlobalTimer.DelayCallback(Param.time, function()
        self:PlayAnimation(self.Ani_CanvasPanelGameStart_end)
      end)
    end
  else
    UIMgr:Hide(ViewID.UI_BattleModeCommonTips)
  end
end

function WBP_BattleModeCommonTips_C:RefreshInfo(title, content)
  self.Txt_Title:SetText(title)
  self.Txt_Content:SetText(content)
end

function WBP_BattleModeCommonTips_C:OnHide()
end

function WBP_BattleModeCommonTips_C:OnAnimationFinished(anim)
  if anim == self.Ani_CanvasPanelGameStart_start then
  elseif anim == self.Ani_CanvasPanelGameStart_end then
    UIMgr:Hide(ViewID.UI_BattleModeCommonTips)
  end
end

return WBP_BattleModeCommonTips_C
