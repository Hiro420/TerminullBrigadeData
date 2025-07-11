local rapidjson = require("rapidjson")
local WBP_LobbyStarItem_C = UnLua.Class()
function WBP_LobbyStarItem_C:Construct()
end
function WBP_LobbyStarItem_C:Destruct()
end
function WBP_LobbyStarItem_C:Show()
  self.URGImageStarBg:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.URGImageStar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_LobbyStarItem_C:Hide()
  self.URGImageStarBg:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.URGImageStar:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_LobbyStarItem_C
