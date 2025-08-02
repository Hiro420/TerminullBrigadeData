local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonData = require("Modules.Season.SeasonData")
local WBP_SeasonMode = Class(ViewBase)

function WBP_SeasonMode:BindClickHandler()
  self.ComBtn_Aquire_Award1.OnMainButtonClicked:Add(self, self.OnLinkToAward1)
  self.ComBtn_Aquire_Award2.OnMainButtonClicked:Add(self, self.OnLinkToAward2)
end

function WBP_SeasonMode:UnBindClickHandler()
  self.ComBtn_Aquire_Award1.OnMainButtonClicked:Remove(self, self.OnLinkToAward1)
  self.ComBtn_Aquire_Award2.OnMainButtonClicked:Remove(self, self.OnLinkToAward2)
end

function WBP_SeasonMode:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_SeasonMode:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_SeasonMode:OnShow(...)
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self, UE.EMouseLockMode.LockAlways, true)
  self:InitSeasonMode()
end

function WBP_SeasonMode:OnHide()
end

function WBP_SeasonMode:Destruct()
end

function WBP_SeasonMode:InitSeasonMode()
  local seasonModule = ModuleManager:Get("SeasonModule")
  local curSeasonID = seasonModule:GetCurSeasonID()
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSeasonGeneral, curSeasonID)
  if result then
    SetImageBrushByPath(self.Img_Bg, row.SeasonBgPath)
    self.Txt_Title:SetText(row.Title)
    for i, v in ipairs(row.SeasonModeList) do
      local resultGameMode, rowGameMode = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, v)
      if resultGameMode then
        local seasonModItem = GetOrCreateItem(self.ScrollBox_Mode, i, self.WBP_SeasonModItem:GetClass())
        seasonModItem:InitSeasonModeItem(rowGameMode)
      end
    end
  end
end

function WBP_SeasonMode:OnLinkToAward1()
  local seasonModule = ModuleManager:Get("SeasonModule")
  local curSeasonID = seasonModule:GetCurSeasonID()
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSeasonGeneral, curSeasonID)
  if result and row.AwardLinkID1 and row.AwardLinkParam1 then
    ComLink(row.AwardLinkID1, nil, table.unpack(row.AwardLinkParam1))
  end
end

function WBP_SeasonMode:OnLinkToAward2()
  local seasonModule = ModuleManager:Get("SeasonModule")
  local curSeasonID = seasonModule:GetCurSeasonID()
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSeasonGeneral, curSeasonID)
  if result and row.AwardLinkID2 and row.AwardLinkParam2 then
    ComLink(row.AwardLinkID2, nil, table.unpack(row.AwardLinkParam2))
  end
end

return WBP_SeasonMode
