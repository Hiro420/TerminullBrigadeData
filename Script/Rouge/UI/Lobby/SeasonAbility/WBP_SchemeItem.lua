local WBP_SchemeItem = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")

function WBP_SchemeItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  self.Btn_ChangeSchemeName.OnClicked:Add(self, self.BindOnChangeSchemeNameButtonClicked)
end

function WBP_SchemeItem:Show(SchemeId, HeroId)
  self.SchemeId = SchemeId
  self.CurHeroId = HeroId
  UpdateVisibility(self, true)
  self:RefreshSchemeInfo()
end

function WBP_SchemeItem:RefreshSchemeInfo(...)
  local SeasonAbilityInfo = SeasonAbilityData:GetSeasonAbilityInfo(self.CurHeroId)
  if not SeasonAbilityInfo then
    return
  end
  local CurSelectSchemeId = SeasonAbilityInfo.equipedSchemeID
  local CurSchemeInfo = SeasonAbilityData:GetSeasonAbilityInfoBySchemeId(self.CurHeroId, self.SchemeId)
  local TotalUnlockSchemeNum = SeasonAbilityData:GetUnlockedSchemeNum()
  local IsLock = not CurSchemeInfo and TotalUnlockSchemeNum < self.SchemeId
  UpdateVisibility(self.Overlay_UnlockScheme, IsLock, true)
  UpdateVisibility(self.Btn_ChangeSchemeName, not IsLock, true)
  local SchemeName = ""
  if IsLock then
    self.Txt_SchemeName:SetColorAndOpacity(self.LockNameColor)
  else
    if CurSchemeInfo then
      SchemeName = CurSchemeInfo.schemeName
    end
    if self.SchemeId == CurSelectSchemeId then
      self.Txt_SchemeName:SetColorAndOpacity(self.SelectedNameColor)
    else
      self.Txt_SchemeName:SetColorAndOpacity(self.UnlockNameColor)
    end
  end
  if UE.UKismetStringLibrary.IsEmpty(SchemeName) then
    local SchemeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSeasonAbilityPresentScheme)
    for i, SingleSchemeRowInfo in ipairs(SchemeTable) do
      if SingleSchemeRowInfo.PresentSchemeID == self.SchemeId then
        SchemeName = SingleSchemeRowInfo.Name
        break
      end
    end
  end
  self.Txt_SchemeName:SetText(SchemeName)
  UpdateVisibility(self.CanvasPanel_Select, self.SchemeId == CurSelectSchemeId)
end

function WBP_SchemeItem:BindOnMainButtonClicked(...)
  local CurSelectSchemeId = SeasonAbilityData:GetCurEquipSchemeId(self.CurHeroId)
  local CurSchemeInfo = SeasonAbilityData:GetSeasonAbilityInfoBySchemeId(self.CurHeroId, self.SchemeId)
  local TotalUnlockSchemeNum = SeasonAbilityData:GetUnlockedSchemeNum()
  local IsLock = not CurSchemeInfo and TotalUnlockSchemeNum < self.SchemeId
  if IsLock then
    UIMgr:Show(ViewID.UI_UnlockSchemePanel, false, self.CurHeroId)
  elseif self.SchemeId ~= CurSelectSchemeId then
    SeasonAbilityHandler:RequestEquipSchemeToServer(self.CurHeroId, self.SchemeId)
  end
end

function WBP_SchemeItem:BindOnMainButtonHovered(...)
  UpdateVisibility(self.CanvasPanel_Hover, true)
end

function WBP_SchemeItem:BindOnMainButtonUnhovered(...)
  UpdateVisibility(self.CanvasPanel_Hover, false)
end

function WBP_SchemeItem:BindOnChangeSchemeNameButtonClicked(...)
  UIMgr:Show(ViewID.UI_ChangeSchemeNamePanel, false, self.CurHeroId, self.SchemeId)
end

function WBP_SchemeItem:Hide()
  UpdateVisibility(self, false)
end

return WBP_SchemeItem
