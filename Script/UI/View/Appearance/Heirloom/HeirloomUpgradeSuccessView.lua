local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local EscName = "PauseGame"
local HeirloomUpgradeSuccessView = Class(ViewBase)
function HeirloomUpgradeSuccessView:BindClickHandler()
end
function HeirloomUpgradeSuccessView:UnBindClickHandler()
end
function HeirloomUpgradeSuccessView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function HeirloomUpgradeSuccessView:OnDestroy()
  self:UnBindClickHandler()
end
function HeirloomUpgradeSuccessView:OnShow(HeirloomId, Level, HeroId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  self:SetEnhancedInputActionBlocking(true)
  self.HeirloomId = HeirloomId
  self.HeirloomLevel = Level
  self.HeroId = HeroId
  local IconSoftObjList = self.IconSoftObj:ToTable()
  local IconSoftObj = IconSoftObjList[self.HeirloomLevel]
  if IconSoftObj then
    SetImageBrushBySoftObject(self.Img_Icon, IconSoftObj)
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, HeirloomData:GetHeirloomResourceId(HeirloomId))
  if Result then
    self.Txt_Name:SetText(RowInfo.Name)
  end
  self:PlayAnimationForward(self.Ani_upgrade)
end
function HeirloomUpgradeSuccessView:ListenForEscInputAction()
end
function HeirloomUpgradeSuccessView:OnAnimationFinished(Animation)
  if Animation == self.Ani_upgrade then
    local HeirloomRowInfo = HeirloomData:GetHeirloomInfoByLevel(self.HeirloomId, self.HeirloomLevel)
    local AllResourceIds = HeirloomData:GetAllResourceIdByGiftId(HeirloomRowInfo.GiftID)
    UIMgr:Show(ViewID.UI_AwardPanel, nil, AllResourceIds, self.HeroId)
    UIMgr:Hide(ViewID.UI_HeirloomUpgradeSuccess)
  end
end
function HeirloomUpgradeSuccessView:OnHide()
  self:SetEnhancedInputActionBlocking(false)
  if IsListeningForInputAction(self, EscName) then
    StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  end
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function HeirloomUpgradeSuccessView:Destruct()
  self:OnHide()
end
return HeirloomUpgradeSuccessView
