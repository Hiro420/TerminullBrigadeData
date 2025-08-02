local MarqueeModule = LuaClass()
local rapidjson = require("rapidjson")

function MarqueeModule:Ctor()
end

function MarqueeModule:OnInit()
  print("MarqueeModule:OnInit...........")
  EventSystem.AddListenerNew(EventDef.WSMessage.GlobalMarquee, self, self.BindOnGlobalMarquee)
end

function MarqueeModule:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.WSMessage.GlobalMarquee, self, self.BindOnGlobalMarquee)
end

function MarqueeModule:BindOnGlobalMarquee(Json)
  print("BindOnSocialAskAgreeFriend", Json)
  local JsonTable = rapidjson.decode(Json)
  local MarqueeData = UE.FMarqueeData()
  MarqueeData = UE.URGBlueprintLibrary.InitMarqueeData(nil, JsonTable.content, JsonTable.interval, JsonTable["repeat"], JsonTable.priorityLevel)
  UE.URGMarqueeSubsystem.Get(GameInstance):AddMarqueeData(MarqueeData)
  if GetCurSceneStatus() == UE.ESceneStatus.ELobby then
    local luaInst = UIMgr.ActiveViews:Get(ViewID.UI_Marquee)
    print("MarqueeModule:BindOnGlobalMarquee - Get UI_Marquee from UIMgr.ActiveViews", luaInst)
    if luaInst then
      luaInst:InitMarquee()
    end
  elseif GetCurSceneStatus() == UE.ESceneStatus.EBattle or GetCurSceneStatus() == UE.ESceneStatus.ESettlement then
    local luaInst = RGUIMgr:GetUI(UIConfig.WBP_Marquee.UIName)
    print("MarqueeModule:BindOnGlobalMarquee - Get WBP_Marquee from RGUIMgr", luaInst)
    if luaInst then
      luaInst:InitMarquee()
    end
  else
    return
  end
end

return MarqueeModule
