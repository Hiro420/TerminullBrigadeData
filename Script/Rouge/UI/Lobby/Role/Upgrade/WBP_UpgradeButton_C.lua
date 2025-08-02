local WBP_UpgradeButton_C = UnLua.Class()

function WBP_UpgradeButton_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_UpgradeButton_C.BindOnMainButtonClicked)
  EventSystem.AddListener(self, EventDef.Lobby.HeroStarUpgradeItemClicked, WBP_UpgradeButton_C.BindOnHeroStarUpgradeItemClicked)
end

function WBP_UpgradeButton_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.HeroStarUpgradeItemClicked, self.StarLevel)
end

function WBP_UpgradeButton_C:RefreshButtonStatus(CurHeroStar)
  self.CurHeroStar = CurHeroStar
  if CurHeroStar < self.StarLevel then
    self.Btn_Main:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Btn_Main:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  end
end

function WBP_UpgradeButton_C:BindOnHeroStarUpgradeItemClicked(CurStarLevel)
  local Color = UE.FSlateColor()
  Color.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  if CurStarLevel == self.StarLevel then
    self.Btn_Main:SetStyle(self.TargetUpgradeLevelStyle)
    Color.SpecifiedColor = UE.FLinearColor(0.208637, 0.991102, 1.0, 1.0)
    self.Txt_StarLevel:SetColorAndOpacity(Color)
  elseif self.StarLevel <= self.CurHeroStar then
    self.Btn_Main:SetStyle(self.UpgradedLevelStyle)
    Color.SpecifiedColor = UE.FLinearColor(0.0, 0.0, 0.0, 1.0)
    self.Txt_StarLevel:SetColorAndOpacity(Color)
  else
    self.Btn_Main:SetStyle(self.NotUpgradeLevelStyle)
    Color.SpecifiedColor = UE.FLinearColor(0.215861, 0.215861, 0.215861, 1.0)
    self.Txt_StarLevel:SetColorAndOpacity(Color)
  end
end

function WBP_UpgradeButton_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.HeroStarUpgradeItemClicked, WBP_UpgradeButton_C.BindOnHeroStarUpgradeItemClicked, self)
end

return WBP_UpgradeButton_C
