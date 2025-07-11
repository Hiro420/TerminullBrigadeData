local rapidjson = require("rapidjson")
local WBP_CharacterItem_C = UnLua.Class()
function WBP_CharacterItem_C:Construct()
end
function WBP_CharacterItem_C:Destruct()
  self:UnInit()
end
function WBP_CharacterItem_C:Init(ResourceId, CharacterId)
  self.ResourceId = ResourceId
  self.CharacterId = CharacterId
  self.WBP_SoulCoreStarWidget.MaxStar = LogicRole.GetMaxHeroStar(self.CharacterId)
  self:UpdateStar()
  self:UpdateItem()
  self:UpdateLock()
  self:UpdateSelect(false)
end
function WBP_CharacterItem_C:UnInit()
  self.ResourceId = -1
  self.CharacterId = -1
end
function WBP_CharacterItem_C:UpdateStar()
  local Level = DataMgr.GetHeroLevelByHeroId(self.CharacterId)
  self.WBP_SoulCoreStarWidget:UpdateStar(Level)
end
function WBP_CharacterItem_C:UpdateItem()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local CharacterRow = LogicRole.GetCharacterTableRow(self.CharacterId)
  local IconPath = ""
  local RareFrame = ""
  if CharacterRow then
    IconPath = CharacterRow.ActorIcon
  end
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TotalResourceTable and TotalResourceTable[self.ResourceId] then
    local itemRarityResult, itemRarityData = DTSubsystem:GetItemRarityTableRow(TotalResourceTable[self.ResourceId].Rare)
    if itemRarityData then
      self.URGImageRareLace:SetColorAndOpacity(itemRarityData.DisplayNameColor.SpecifiedColor)
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(itemRarityData.RoleRareFrame):Cast(UE.UPaperSprite)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.URGImageRareBg:SetBrush(Brush)
      end
    end
  end
  SetImageBrushByPath(self.URGImageIcon, IconPath)
end
function WBP_CharacterItem_C:UpdateUnLockOpacity(Opacity)
  self.CanvasPanelRoot:SetRenderOpacity(Opacity)
  self.CanvasPanelLock:SetRenderOpacity(Opacity)
end
function WBP_CharacterItem_C:UpdateLock()
  local bIsUnLock = LogicRole.CheckCharacterUnlock(self.CharacterId)
  if bIsUnLock then
    self:SetVisibility(UE.ESlateVisibility.Visible)
    self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_CharacterItem_C:UpdateSelect(bIsSelected)
  if bIsSelected then
    self.URGImageSelect:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.URGImageSelect:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
return WBP_CharacterItem_C
