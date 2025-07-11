local rapidjson = require("rapidjson")
local WBP_CardTitle_C = UnLua.Class()
function WBP_CardTitle_C:Construct()
end
function WBP_CardTitle_C:Destruct()
end
function WBP_CardTitle_C:UpdateCardTitle(CharacterId, ResourceId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local CharacterTb = LogicSoulCore:GetCharacterTableRow(CharacterId)
  if CharacterTb then
    self.RGTextName:SetText(CharacterTb.Name)
    local Lv = DataMgr.GetHeroLevelByHeroId(CharacterId)
    local bIsUnLock = LogicRole.CheckCharacterUnlock(CharacterId)
    if bIsUnLock then
      self.WBP_LobbyStarWidget.MaxStar = LogicRole.GetMaxHeroStar(CharacterId)
      self.WBP_LobbyStarWidget:UpdateStar(Lv)
      self.WBP_LobbyStarWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.WBP_LobbyStarWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if ResourceTable and ResourceTable[ResourceId] then
    local itemRarityResult, itemRarityData = DTSubsystem:GetItemRarityTableRow(ResourceTable[ResourceId].Rare)
    if itemRarityData then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(itemRarityData.RoleTitleRareBg):Cast(UE.UPaperSprite)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.URGImageTitleBg:SetBrush(Brush)
      end
    end
  end
end
return WBP_CardTitle_C
