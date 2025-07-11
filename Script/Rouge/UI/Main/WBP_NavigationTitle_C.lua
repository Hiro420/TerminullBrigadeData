local WBP_NavigationTitle_C = UnLua.Class()
function WBP_NavigationTitle_C:Construct()
  self.Button_Title.OnClicked:Add(self, WBP_NavigationTitle_C.BindOnTitleButtonClicked)
  self.RGTextName_Normal:SetText(self.TitleText)
  self.RGTextName_Selected:SetText(self.TitleText)
  print("WBP_NavigationTitle_C:Construct", self.TitleText)
end
function WBP_NavigationTitle_C:BindOnTitleButtonClicked()
  self.ButtonClicked:Broadcast(self.TitleNum)
end
function WBP_NavigationTitle_C:ActivatePageTitle(Activate)
  if Activate then
    self.Overlay_Normal:SetVisibility(UE.ESlateVisibility.Hidden)
    self.Overlay_Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Overlay_Normal:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Overlay_Selected:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
return WBP_NavigationTitle_C
