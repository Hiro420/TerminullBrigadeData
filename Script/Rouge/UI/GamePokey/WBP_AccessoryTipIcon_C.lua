local WBP_AccessoryTipIcon_C = UnLua.Class()
function WBP_AccessoryTipIcon_C:InitAccessoryInfo(ArticleId)
  self.ArticleId = ArticleId
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(self.ArticleId)
    local itemData = DTSubsystem:K2_GetItemTableRow(configId)
    self:LoadAccessoryImage(itemData.SpriteIcon)
    local outData = UE.URGAccessoryStatics.GetAccessoryData(self, self.ArticleId)
    local itemRarityResult, itemRarityData = DTSubsystem:GetItemRarityTableRow(outData.InnerData.ItemRarity)
    self:LoadRarityImage(itemRarityData.SpriteIcon)
  end
end
return WBP_AccessoryTipIcon_C
