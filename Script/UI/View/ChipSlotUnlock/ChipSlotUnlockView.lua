local ViewBase = require("Framework.UIMgr.ViewBase")
local UnlockNameFmt = NSLOCTEXT("ChipSlotUnlockView", "UnlockDesc", "\232\167\163\233\148\129{0}\232\167\130\230\181\139\228\189\141")
local UnlockDescFmt = NSLOCTEXT("ChipSlotUnlockView", "UnlockDesc", "\229\143\175\229\174\137\232\163\133\231\172\172{0}\232\167\130\230\181\139\228\189\141\228\184\150\231\149\140\231\162\142\231\137\135")
local ChipSlotUnlockView = Class(ViewBase)

function ChipSlotUnlockView:BindClickHandler()
  self.Btn_Link.OnClicked:Add(self, self.OnLink)
end

function ChipSlotUnlockView:UnBindClickHandler()
  self.Btn_Link.OnClicked:Remove(self, self.OnLink)
end

function ChipSlotUnlockView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("ChipSlotUnlockViewModel")
  self:BindClickHandler()
end

function ChipSlotUnlockView:OnDestroy()
  self:UnBindClickHandler()
end

function ChipSlotUnlockView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.OnExitView)
  local params = {
    ...
  }
  local unlockSlot = params[1]
  self.UnlockSlot = unlockSlot
  self:UpdateUnSlotStatus(unlockSlot)
end

function ChipSlotUnlockView:OnHide()
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.OnExitView)
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end

function ChipSlotUnlockView:UpdateUnSlotStatus(unlockSlot)
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  print("ChipSlotUnlockView:UpdateUnSlotStatus Slot", unlockSlot)
  if unlockSlot and tbChipSlot[unlockSlot] then
    local name = UE.FTextFormat(UnlockNameFmt(), tbChipSlot[unlockSlot].name)
    self.Txt_SlotName:SetText(name)
    local desc = UE.FTextFormat(UnlockDescFmt(), NumToTxt(unlockSlot))
    self.Txt_SlotNameDesc:SetText(desc)
  end
  local chipViewModel = UIModelMgr:Get("ChipViewModel")
  local slotStr = "WBP_ChipSlotUnlockItem"
  for i, v in ipairs(tbChipSlot) do
    local slotName = slotStr .. i
    local bUnlock = chipViewModel:CheckSlotIsUnLock(i)
    if self[slotName] then
      self[slotName]:InitChipSlotUnlockItem(bUnlock, i, i == unlockSlot)
    end
  end
end

function ChipSlotUnlockView:OnExitView()
  UIMgr:Hide(ViewID.UI_ChipSlotUnlockView)
end

function ChipSlotUnlockView:OnLink()
  if ComLink(tostring(1009), nil, self.UnlockSlot) then
    self:OnExitView()
  end
end

return ChipSlotUnlockView
