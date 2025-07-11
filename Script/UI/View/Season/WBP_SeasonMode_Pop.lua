local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonData = require("Modules.Season.SeasonData")
local WBP_SeasonMode_Pop = Class(ViewBase)
function WBP_SeasonMode_Pop:BindClickHandler()
  self.ComBtn_Enter_Season_Mode.OnMainButtonClicked:Add(self, self.OnEnterSeasonMode)
  self.Btn_Enter_Normal_Mode.OnClicked:Add(self, self.OnEnterNormalMode)
end
function WBP_SeasonMode_Pop:UnBindClickHandler()
  self.ComBtn_Enter_Season_Mode.OnMainButtonClicked:Remove(self, self.OnEnterSeasonMode)
  self.Btn_Enter_Normal_Mode.OnClicked:Remove(self, self.OnEnterNormalMode)
end
function WBP_SeasonMode_Pop:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_SeasonMode_Pop:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_SeasonMode_Pop:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self, UE.EMouseLockMode.LockAlways, true)
  self:InitSeasonMode()
  ModuleManager:Get("SeasonModule"):SaveCurSeasonIDToFile()
  self:PlayAnimation(self.Ani_in)
end
function WBP_SeasonMode_Pop:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function WBP_SeasonMode_Pop:Destruct()
end
function WBP_SeasonMode_Pop:InitSeasonMode()
  local registerSeasonID = DataMgr.GetBasicInfo().registerSeasonID
  local curSeasonID = ModuleManager:Get("SeasonModule"):GetCurSeasonID()
  if registerSeasonID < curSeasonID then
    UpdateVisibility(self.ResidencyMode, true)
  else
    UpdateVisibility(self.ResidencyMode, false)
  end
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSeasonGeneral, curSeasonID)
  if result then
    SetImageBrushByPath(self.Img_Content, row.SeasonContentPath)
    self.Txt_Title:SetText(row.Title)
  end
end
function WBP_SeasonMode_Pop:OnEnterSeasonMode(withoutAnimation)
  local seasonModule = ModuleManager:Get("SeasonModule")
  seasonModule:SetSeasonMode(ESeasonMode.SeasonMode)
  UIMgr:Hide(ViewID.UI_SeasonMode_Pop, true, false, withoutAnimation)
end
function WBP_SeasonMode_Pop:OnEnterNormalMode()
  ShowWaveWindowWithDelegate(1453, {}, {
    GameInstance,
    function()
      local seasonModule = ModuleManager:Get("SeasonModule")
      seasonModule:SetSeasonMode(ESeasonMode.NormalMode)
      UIMgr:Hide(ViewID.UI_SeasonMode_Pop)
    end
  })
end
return WBP_SeasonMode_Pop
