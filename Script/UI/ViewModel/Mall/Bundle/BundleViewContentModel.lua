local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local BundleViewContentModel = CreateDefaultViewModel()

function BundleViewContentModel:OnInit()
  self.Super.OnInit(self)
end

function BundleViewContentModel:OnShutdown()
  self.Super.OnShutdown(self)
end

function BundleViewContentModel:ShowBundleContent(GiftId, GoodsId, Item)
  self.GoodsId = GoodsId
  if nil == GiftId then
    self.BundleInfo = nil
    return
  end
  self.GiftId = GiftId
  local TBRandomGift = LuaTableMgr.GetLuaTableByName(TableNames.TBGift)
  self.BundleInfo = TBRandomGift[self.GiftId]
  local Widgte = UIMgr:GetLuaFromActiveView(ViewID.UI_Mall_Bundle_Content)
  Widgte = Widgte or UIMgr:Show(ViewID.UI_Mall_Bundle_Content, true)
  local BundleContentView = Widgte
  if BundleContentView and self.GiftId then
    BundleContentView:UpDateList(GoodsId, self.BundleInfo, Item)
  end
end

return BundleViewContentModel
