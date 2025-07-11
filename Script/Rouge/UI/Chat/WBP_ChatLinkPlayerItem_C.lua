local WBP_ChatLinkPlayerItem_C = UnLua.Class()
function WBP_ChatLinkPlayerItem_C:Construct()
  self.Overridden.Construct(self)
  self.BP_ButtonWithSound.OnClicked:Add(self, self.OnBtnClick)
end
function WBP_ChatLinkPlayerItem_C:Init(Desc, UserId, ParentView, ClickCallback)
  self.UserId = UserId
  self.ParentView = ParentView
  self.ClickCallback = ClickCallback
  self.RGTextDesc:SetText(Desc())
end
function WBP_ChatLinkPlayerItem_C:OnBtnClick()
  if self.ParentView and self.ClickCallback then
    self.ClickCallback(self.ParentView, self.UserId)
  end
end
function WBP_ChatLinkPlayerItem_C:Destruct()
  self.Overridden.Destruct(self)
  self.BP_ButtonWithSound.OnClicked:Remove(self, self.OnBtnClick)
  self.UserId = nil
  self.ParentView = nil
  self.ClickCallback = nil
end
return WBP_ChatLinkPlayerItem_C
