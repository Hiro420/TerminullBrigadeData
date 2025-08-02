local rapidjson = require("rapidjson")
local DebuffPanel = UnLua.Class()

function DebuffPanel:Destruct()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.CloseWidget, "PauseGame")
end

function DebuffPanel:Construct()
end

function DebuffPanel:CloseWidget()
  UpdateVisibility(self, false)
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.CloseWidget, "PauseGame")
end

function DebuffPanel:Init(ShowPlayerList, DebuffListShowType)
  local Index = 1
  for i, UserId in pairs(ShowPlayerList) do
    local Item = GetOrCreateItem(self.DebuffList, Index, self.WBP_ClimbTower_DebufInfofList_1:GetClass())
    if not UserId then
      Item:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      Item.WBP_ClimbTower_DebuffList:SetPlayerDebuffInfo(UserId, DebuffListShowType, function(DebuffList)
        local TowerDebuff = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDebuff)
        local FaultScore = 0
        for DebuffId, Lv in pairs(DebuffList) do
          if TowerDebuff[tonumber(DebuffId)] then
            local DebuffValues = TowerDebuff[tonumber(DebuffId)].DebuffValues
            if DebuffValues[Lv] then
              FaultScore = DebuffValues[Lv] + FaultScore
            end
          end
        end
        Item.Txt_Num:SetText(FaultScore)
      end)
      Index = Index + 1
      self:SetPlayerInfo(UserId, Item)
      Item:SetVisibility(UE.ESlateVisibility.Visible)
    end
  end
  HideOtherItem(self.DebuffList, Index, true)
  if 3 == DebuffListShowType then
    return
  end
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.CloseWidget, "PauseGame")
end

function DebuffPanel:SetPlayerInfo(UserId, Item)
  DataMgr.GetOrQueryPlayerInfo({UserId}, false, function(PlayerCacheInfoList)
    local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
    for index, value in ipairs(PlayerInfoList) do
      Item.Txt_Name:SetText(value.nickname)
      local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(value.portrait)
      if PortraitRowInfo then
        SetImageBrushByPath(Item.Img_Head, PortraitRowInfo.portraitIconPath)
      end
    end
    local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
    local OnlineState = RGTeamSubsystem:GetPlayerOnlineState(tonumber(UserId))
    if OnlineState == UE.ERGPlayerOnlineState.Disconnected then
      UpdateVisibility(Item.Canvas_Offline, true)
      UpdateVisibility(Item.Canvas_LeaveBattle, false)
      UpdateVisibility(Item.Canvas_Online, false)
    elseif OnlineState == UE.ERGPlayerOnlineState.LeaveBattle then
      UpdateVisibility(Item.Canvas_Offline, false)
      UpdateVisibility(Item.Canvas_LeaveBattle, true)
      UpdateVisibility(Item.Canvas_Online, false)
    else
      UpdateVisibility(Item.Canvas_Offline, false)
      UpdateVisibility(Item.Canvas_LeaveBattle, false)
      UpdateVisibility(Item.Canvas_Online, true)
    end
  end)
end

return DebuffPanel
