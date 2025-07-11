local SurvivorData = {
  LocalSaveData = {IsGuide = false}
}
function SurvivorData.IsGuide()
  return SurvivorData.LocalSaveData.IsGuide
end
function SurvivorData.SetGuide(IsGuide)
  SurvivorData.LocalSaveData.IsGuide = IsGuide
end
return SurvivorData
