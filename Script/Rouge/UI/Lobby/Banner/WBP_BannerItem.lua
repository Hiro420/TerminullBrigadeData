local WBP_BannerItem = UnLua.Class()

function WBP_BannerItem:Construct()
  SetImageBrushBySoftObject(self.Img_Bottom, self.BottomIcon)
  self.WBP_RedDotView:ChangeRedDotId(self.RedDotClassName, self.RedDotClassName)
  self.Btn_Main.OnClicked:Add(self, self.OnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.OnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.OnMainButtonUnhovered)
end

function WBP_BannerItem:OnMainButtonClicked(...)
  self.OnClicked:Broadcast()
end

function WBP_BannerItem:OnMainButtonHovered(...)
  self.OnHovered:Broadcast()
end

function WBP_BannerItem:OnMainButtonUnhovered(...)
  self.OnUnhovered:Broadcast()
end

function WBP_BannerItem:Destruct(...)
  self.Btn_Main.OnClicked:Remove(self, self.OnMainButtonClicked)
  self.Btn_Main.OnHovered:Remove(self, self.OnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.OnMainButtonUnhovered)
end

return WBP_BannerItem
