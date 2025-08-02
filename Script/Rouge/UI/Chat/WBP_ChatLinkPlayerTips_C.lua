local WBP_ChatLinkPlayerTips_C = UnLua.Class()

function WBP_ChatLinkPlayerTips_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ChatLinkPlayerTips_C:Init(UserId, ParentView)
  self.ParentView = ParentView
  local Desc = NSLOCTEXT("WBP_ChatLinkPlayerTips_C", "SheildPlayer", "\229\177\143\232\148\189\231\142\169\229\174\182")
  if ChatDataMgr.CheckPlayerIsBeSheilded(UserId) then
    Desc = NSLOCTEXT("WBP_ChatLinkPlayerTips_C", "UnSheildPlayer", "\229\143\150\230\182\136\229\177\143\232\148\189")
  end
  self.WBP_ChatLinkPlayerItem:Init(Desc, UserId, self, self.SheildPlayerMsg)
end

function WBP_ChatLinkPlayerTips_C:SheildPlayerMsg(UserId)
  local bIsSheilded = ChatDataMgr.CheckPlayerIsBeSheilded(UserId)
  LogicChat:SheildPlayerMsg(UserId, not bIsSheilded)
  if self.ParentView and self.ParentView.ShowLinkPlayerTips then
    self.ParentView:ShowLinkPlayerTips(false)
  end
end

function WBP_ChatLinkPlayerTips_C:Destruct()
  self.Overridden.Destruct(self)
  self.ParentView = nil
end

return WBP_ChatLinkPlayerTips_C
