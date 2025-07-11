local rapidjson = require("rapidjson")
local WBP_LobbyStarWidget_C = UnLua.Class()
function WBP_LobbyStarWidget_C:Construct()
end
function WBP_LobbyStarWidget_C:Destruct()
end
function WBP_LobbyStarWidget_C:UpdateStar(StarLv)
  local AllChildren = self.HorizontalBoxStar:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  for i = 1, self.MaxStar do
    local StarItem = GetOrCreateItem(self.HorizontalBoxStar, i, self.WBP_SoulCoreStarItem:GetClass())
    StarItem:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if StarLv >= i then
      StarItem:Show()
    else
      StarItem:Hide()
    end
  end
end
return WBP_LobbyStarWidget_C
