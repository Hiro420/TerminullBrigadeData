local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BattlePassGetAwardItem = Class(ViewBase)
function BattlePassGetAwardItem:BindClickHandler()
end
function BattlePassGetAwardItem:UnBindClickHandler()
end
function BattlePassGetAwardItem:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function BattlePassGetAwardItem:OnDestroy()
  self:UnBindClickHandler()
end
function BattlePassGetAwardItem:OnShow(...)
end
function BattlePassGetAwardItem:OnHide()
end
function BattlePassGetAwardItem:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    self.PropId = ListItemObj.ItemID
    self.PropNum = ListItemObj.Num
    self.WBP_Item:InitItem(self.PropId, ListItemObj.Num)
  end
end
return BattlePassGetAwardItem
