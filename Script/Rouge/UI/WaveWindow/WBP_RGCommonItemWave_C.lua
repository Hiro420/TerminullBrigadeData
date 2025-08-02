local WBP_RGCommonItemWave_C = UnLua.Class()

function WBP_RGCommonItemWave_C:SetWaveWindowParam(WaveWindowParamParam)
  if WaveWindowParamParam and WaveWindowParamParam.StringParam0 then
    local Result, LeftS, RightS = UE.UKismetStringLibrary.Split(WaveWindowParamParam.StringParam0, ",", nil, nil, UE.ESearchCase.IgnoreCase, UE.ESearchDir.FromStart)
    if Result and LeftS then
      self.WBP_Item:InitItem(tonumber(LeftS))
    end
  end
end

return WBP_RGCommonItemWave_C
