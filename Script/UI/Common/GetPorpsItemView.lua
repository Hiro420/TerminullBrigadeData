local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local GetPorpsItemView = Class(ViewBase)

function GetPorpsItemView:BindClickHandler()
end

function GetPorpsItemView:UnBindClickHandler()
end

function GetPorpsItemView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function GetPorpsItemView:OnDestroy()
  self:UnBindClickHandler()
end

function GetPorpsItemView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function GetPorpsItemView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function GetPorpsItemView:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    self.ListItemData = ListItemObj
    self.PropId = ListItemObj.PropId
    self.PropNum = ListItemObj.PropNum
    self.IsInscription = ListItemObj.IsInscription
    self.ExchangedAmount = ListItemObj.ExchangedAmount
    self.TimeLimitedGiftId = ListItemObj.TimeLimitedGiftId
    self.extra = ListItemObj.extra
    self.WBP_Item:InitItem(self.PropId, self.PropNum, self.IsInscription)
    self.WBP_Item.WBP_CommonCountdown.bUpdateCountdownText = false
    self.WBP_Item:SetTargetTimestampById(self.TimeLimitedGiftId, self.PropId)
    self.WBP_Item:ShowSpecialTag(self.PropId, ListItemObj.expireAt)
    UpdateVisibility(self.Canvas_Decompose, false)
    self.ExchangedResources = ListItemObj.ExchangedResources
    UpdateVisibility(self.WBP_Item.Canvas_Decompose, false)
    if self.ExchangedResources and #self.ExchangedResources > 0 then
      UpdateVisibility(self.WBP_Item.Canvas_Decompose, true)
      self.WBP_Item.WBP_Price_Decompose:SetPrice(self.ExchangedResources[1].amount, self.ExchangedResources[1].amount, self.ExchangedResources[1].resourceID)
    end
    self.WBP_Item:BindOnMainButtonHovered(function()
      self:HoveredFunc()
    end)
    self.WBP_Item:BindOnMainButtonUnHovered(function()
      self:UnHoveredFunc()
    end)
  end
end

function GetPorpsItemView:BP_OnEntryReleased()
  self.ListItemData = nil
  self.PropId = 0
  self.PropNum = 0
  self.IsInscription = false
  self.extra = {}
end

function GetPorpsItemView:HoveredFunc()
  if self.ListItemData and UE.RGUtil.IsUObjectValid(self.ListItemData.ParentView) then
    self.ListItemData.ParentView:HoveredFunc(self, self.ListItemData)
  end
end

function GetPorpsItemView:UnHoveredFunc()
  if self.ListItemData and UE.RGUtil.IsUObjectValid(self.ListItemData.ParentView) then
    self.ListItemData.ParentView:UnHoveredFunc()
  end
end

function GetPorpsItemView:GetTipsClsByResID(ResID)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResID)
  if not result then
    return nil
  end
  local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonItemDetail.WBP_CommonItemDetail_C"
  if row.Type == TableEnums.ENUMResourceType.Puzzle then
    WidgetClassPath = "/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleItemTip.WBP_PuzzleItemTip_C"
  else
    WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonItemDetail.WBP_CommonItemDetail_C"
  end
  local WidgetClass = UE.UClass.Load(WidgetClassPath)
  return WidgetClass
end

return GetPorpsItemView
