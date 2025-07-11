local ViewBase = require("Framework.UIMgr.ViewBase")
local WBP_LevelView_C = UnLua.Class(ViewBase)
local TotalLevelAniDuration = 2
local LevelNumFormat = "<Img id=\"%s\" width=\"70\" height=\"90\" stretch=\"ScaleToFitY\"/>"
local ProgressHuangOffset = 0.05
function WBP_LevelView_C:Construct()
end
function WBP_LevelView_C:OnShow(...)
  local params = {
    ...
  }
  if params then
    local oldLv = params[1]
    local newLv = params[2]
    local oldExp = params[3]
    local newExp = params[4]
    self:InitInfo(oldLv, newLv, oldExp, newExp)
  end
end
function WBP_LevelView_C:InitInfo(OldLevel, TargetLevel, OldExp, NewExp)
  self.bNeedHideSelf = false
  self:StopAllAnimations()
  self.bNeedHideSelf = true
  if not self.Inited then
    self:BindToAnimationFinished(self.ani_grage_in, {
      self,
      WBP_LevelView_C.BindFadeOutFinished
    })
    self.Inited = true
  end
  self.RichTextBlockTotalLevel:SetText(self:GetLevelStr(TargetLevel))
  self.RichTextBlockTotalLevel_1:SetText(self:GetLevelStr(TargetLevel))
  self.RichTextBlockTotalLevel_2:SetText(self:GetLevelStr(TargetLevel))
  print("WBP_LevelView_C:InitInfo", OldLevel, TargetLevel, OldExp, NewExp)
  self:PlayAnimation(self.ani_grage_in)
  LogicAudio.OnLevelUpAppear()
end
function WBP_LevelView_C:BindFadeOutFinished()
  if self.bNeedHideSelf then
    Logic_Level.HideSelf()
  end
end
function WBP_LevelView_C:GetLevelStr(Level)
  local LevelStr = tostring(Level)
  local LevelText = ""
  for i = 1, #LevelStr do
    LevelText = LevelText .. string.format(LevelNumFormat, string.sub(LevelStr, i, i))
  end
  return LevelText
end
return WBP_LevelView_C
