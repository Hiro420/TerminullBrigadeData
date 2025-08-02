local WBP_CommonTalentLine_C = UnLua.Class()

function WBP_CommonTalentLine_C:Construct()
  self.LineInfos = {}
  self.LineColors = self.LineColorsConfig:ToTable()
end

function WBP_CommonTalentLine_C:SetLineInfos(InLineInfos)
  local LineInfos = {}
  for index, SingleLineInfo in ipairs(InLineInfos) do
    local TargetLineInfo = UE.FTalentLineInfo()
    TargetLineInfo.BeginItem = SingleLineInfo.BeginItem
    TargetLineInfo.EndItem = SingleLineInfo.EndItem
    TargetLineInfo.MovePanel = SingleLineInfo.ParentPanel
    table.insert(LineInfos, TargetLineInfo)
  end
  self.LineInfos = LineInfos
end

return WBP_CommonTalentLine_C
