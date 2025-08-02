local enum = _G.enum
local EAppearanceToggleStatus = {
  None = 0,
  Skin = 1,
  Display = 2,
  Communication = 3,
  Heirloom = 4
}
_G.EAppearanceToggleStatus = _G.EAppearanceToggleStatus or EAppearanceToggleStatus
local AppearanceData = {
  EquipedStoneList = {},
  StoneList = {},
  CurHeroId = -1
}

function AppearanceData:SetCurHeroId(InHeroId)
  AppearanceData.CurHeroId = InHeroId
end

return AppearanceData
