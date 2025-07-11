local RGChipMutexComMsgWaveWindow = UnLua.Class()
function RGChipMutexComMsgWaveWindow:SetWaveWindowParam(WaveWindowParamParam)
  self.Overridden.SetWaveWindowParam(self, WaveWindowParamParam)
  local desc = UE.FTextFormat(self.TxtFmtChipDesc, WaveWindowParamParam.StringParam0)
  self.Txt_InfoChipDesc:SetText(desc)
end
return RGChipMutexComMsgWaveWindow
