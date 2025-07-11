local WBP_RGEliteAISpawnWaveWindow_C = UnLua.Class()
function WBP_RGEliteAISpawnWaveWindow_C:Construct()
  self.EliteAIList = {}
end
function WBP_RGEliteAISpawnWaveWindow_C:GetTipInfo(AI)
  local CanAdd = true
  for index, EliteAI in ipairs(self.EliteAIList) do
    if EliteAI:StaticClass() == AI:StaticClass() then
      CanAdd = false
      break
    end
  end
  if CanAdd then
    table.insert(self.EliteAIList, AI)
  end
  local TargetInfo = ""
  local DescList = {}
  for i, EliteAI in ipairs(self.EliteAIList) do
    local Result, Config = GetRowDataForCharacter(EliteAI:GetActorId())
    if Result then
      if "" ~= TargetInfo then
        TargetInfo = TargetInfo .. ", "
      end
      TargetInfo = TargetInfo .. "{" .. i - 1 .. "}"
      table.insert(DescList, Config.Desc)
    end
  end
  local TargetText = UE.FTextFormat(TargetInfo, table.unpack(DescList))
  return TargetText
end
function WBP_RGEliteAISpawnWaveWindow_C:Destruct()
  self.EliteAIList = {}
end
return WBP_RGEliteAISpawnWaveWindow_C
