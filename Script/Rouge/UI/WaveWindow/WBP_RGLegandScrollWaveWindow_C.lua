local WBP_RGLegandScrollWaveWindow_C = UnLua.Class()
function WBP_RGLegandScrollWaveWindow_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_RGLegandScrollWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
  self:Show(WaveWindowParamParam.IntParam0)
end
function WBP_RGLegandScrollWaveWindow_C:Show(AttributeModifyId)
  self.WBP_ScrollLegandTips:InitScrollLegandItem(AttributeModifyId, self.Info.Duration)
end
function WBP_RGLegandScrollWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
end
function WBP_RGLegandScrollWaveWindow_C:Hide()
end
return WBP_RGLegandScrollWaveWindow_C
