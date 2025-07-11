local ViewBase = require("Framework.UIMgr.ViewBase")
local UnlockNameFmt = NSLOCTEXT("ChipSeasonSlotUnlockView", "UnlockDesc", "\232\167\163\233\148\129{0}\232\167\130\230\181\139\228\189\141")
local UnlockDescFmt = NSLOCTEXT("ChipSeasonSlotUnlockView", "UnlockDesc", "\229\143\175\229\174\137\232\163\133\231\172\172{0}\232\167\130\230\181\139\228\189\141\228\184\150\231\149\140\231\162\142\231\137\135")
local ChipSeasonSlotUnlockView = Class(ViewBase)
function ChipSeasonSlotUnlockView:BindClickHandler()
  self.Btn_Link.OnClicked:Add(self, self.OnLink)
end
function ChipSeasonSlotUnlockView:UnBindClickHandler()
  self.Btn_Link.OnClicked:Remove(self, self.OnLink)
end
function ChipSeasonSlotUnlockView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("ChipSeasonSlotUnlockViewModel")
  self:BindClickHandler()
end
function ChipSeasonSlotUnlockView:OnDestroy()
  self:UnBindClickHandler()
end
function ChipSeasonSlotUnlockView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.OnExitView)
  local params = {
    ...
  }
  local unlockSlot = params[1]
  self.UnlockSlot = unlockSlot
  self:UpdateUnSlotStatus(unlockSlot)
end
function ChipSeasonSlotUnlockView:OnHide()
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.OnExitView)
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function ChipSeasonSlotUnlockView:UpdateUnSlotStatus(unlockSlot)
  print("ChipSeasonSlotUnlockView:UpdateUnSlotStatus Slot", unlockSlot)
  local chipViewModel = UIModelMgr:Get("ChipViewModel")
  local bUnlock = chipViewModel:CheckSlotIsUnLock(i)
  self.WBP_ChipSeasonSlotUnlockItem:InitChipSeasonSlotUnlockItem(bUnlock, unlockSlot)
end
function ChipSeasonSlotUnlockView:OnExitView()
  UIMgr:Hide(ViewID.UI_ChipSeasonSlotUnlockView)
end
function ChipSeasonSlotUnlockView:OnLink()
  if ComLink(tostring(1009), nil, self.UnlockSlot) then
    self:OnExitView()
  end
end
return ChipSeasonSlotUnlockView
