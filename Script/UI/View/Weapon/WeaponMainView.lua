local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local EscName = "PauseGame"
local WeaponMainView = Class(ViewBase)
function WeaponMainView:BindClickHandler()
end
function WeaponMainView:UnBindClickHandler()
end
function WeaponMainView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("WeaponMainViewModel")
  self:BindClickHandler()
end
function WeaponMainView:OnDestroy()
  self:UnBindClickHandler()
end
function WeaponMainView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  local param = {
    ...
  }
  local heroId = param[1]
  local bIsShowWeaponSub = param[2]
  local resStoneSlot = param[3] or 1
  local weaponResId = param[4] or -1
  self:UpdateViewByHeroId(heroId, bIsShowWeaponSub, resStoneSlot, weaponResId)
  local closeCallback = param[5]
  self.viewModel:SetCloseCallback(closeCallback)
  self:PushInputAction()
end
function WeaponMainView:OnHide()
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  ChangeLobbyCamera(self, "Role")
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function WeaponMainView:UpdateViewByHeroId(HeroId, bIsShowWeaponSubParam, resStoneSlot, weaponResId)
  local bIsShowWeaponSub = bIsShowWeaponSubParam
  bIsShowWeaponSub = bIsShowWeaponSub or true
  self.viewModel:UpdateCurHeroId(HeroId)
  local curHeroId = HeroId
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if CharacterTable and CharacterTable[curHeroId] then
    self.RGTextBlock_Name:SetText(CharacterTable[curHeroId].Name)
  end
  local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(curHeroId)
  if EquippedWeaponInfo and EquippedWeaponInfo[1] then
  else
    LogicOutsideWeapon.RequestEquippedWeaponInfo(curHeroId)
  end
  EventSystem.Invoke(EventDef.Lobby.WeaponListChanged)
end
function WeaponMainView:HideViewByViewSet()
  UIMgr:Hide(ViewID.UI_WeaponSub)
  UIMgr:Hide(ViewID.UI_WeaponMain, true)
end
return WeaponMainView
