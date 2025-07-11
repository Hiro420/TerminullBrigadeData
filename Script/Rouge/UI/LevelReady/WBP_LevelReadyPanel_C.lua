local WBP_LevelReadyPanel_C = UnLua.Class()
function WBP_LevelReadyPanel_C:CreateAllReadyWidget()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return
  end
  local AllChildren = self.HorizontalBox_Ready:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local PSList = GS.PlayerArray:ToTable()
  table.sort(PSList, function(APS, BPS)
    return APS:GetTeamIndex() < BPS:GetTeamIndex()
  end)
  for i, SinglePS in ipairs(PSList) do
    local Item = self.HorizontalBox_Ready:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.SingleReadyTemplate:StaticClass())
      self.HorizontalBox_Ready:AddChild(Item)
    end
    Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    Item:InitInfo(SinglePS:BP_GetPawn(), SinglePS:GetTeamIndex())
  end
end
return WBP_LevelReadyPanel_C
