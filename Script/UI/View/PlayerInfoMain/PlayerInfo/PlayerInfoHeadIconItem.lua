local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local PlayerInfoHeadIconItem = Class()
function PlayerInfoHeadIconItem:Construct()
  self.Overridden.Construct(self)
end
function PlayerInfoHeadIconItem:InitPlayerInfoHeadIconItem(PortraitId, HeadIconState)
  local tbPortraitData = LogicLobby.GetPlayerPortraitTableRowInfo(PortraitId)
  if not tbPortraitData then
    error("tbPortraitData is nil, please check table TBPortraitData, portraitId is:", PortraitId)
    return
  end
  self.ComPortraitItem:InitComPortraitItem(tbPortraitData.portraitIconPath, tbPortraitData.EffectPath)
  local existsNum = DataMgr.GetPackbackNumById(tbPortraitData.ID)
  if HeadIconState == EPlayerInfoEquipedState.Lock then
    self.RGStateControllerLock:ChangeStatus(ELock.Lock)
  else
    self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
  end
  if HeadIconState == EPlayerInfoEquipedState.Equiped then
    self.RGStateControllerEquiped:ChangeStatus(EEquiped.Equiped)
  else
    self.RGStateControllerEquiped:ChangeStatus(EEquiped.UnEquiped)
  end
  if nil ~= HeadIconState then
    for index, value in ipairs(PlayerInfoData.PortraitData) do
      if value.rid == PortraitId then
        if nil ~= value.expireAt and value.expireAt ~= "0" and value.expireAt ~= "" and value.expireAt ~= "1" then
          self.RGStateControllerLock:ChangeStatus("ForALimitedTime", true)
          SetExpireAtColor(self.Icon_LimitedTime, value.expireAt)
        end
        break
      end
    end
  end
end
function PlayerInfoHeadIconItem:Hide()
  UpdateVisibility(self, false)
end
function PlayerInfoHeadIconItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end
function PlayerInfoHeadIconItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end
return PlayerInfoHeadIconItem
