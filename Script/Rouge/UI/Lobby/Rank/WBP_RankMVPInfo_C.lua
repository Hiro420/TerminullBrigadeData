local RankData = require("UI.View.Rank.RankData")
local PlayerInfoConfig = require("GameConfig.PlayerInfo.PlayerInfoConfig")
local rapidjson = require("rapidjson")
local WBP_RankMVPInfo_C = UnLua.Class()

function WBP_RankMVPInfo_C:Construct()
  EventSystem.AddListener(self, EventDef.Rank.OnRefreshMVP, self.OnRefreshMVP)
end

function WBP_RankMVPInfo_C:OnRefreshMVP()
end

function WBP_RankMVPInfo_C:SetMVPInfo(RoleId)
  print("SetMVPInfo", RoleId)
  self.RoleId = RoleId
  if RankData.ElementData[RoleId] == nil then
    return
  end
  if nil == RankData.ElementData[RoleId].totalDamage then
    return
  end
  local path = string.format("hero/getplayeroneheroinfo?heroID=%d&roleID=%s&weaponID=%d", RankData.ElementData[RoleId].heroId, RoleId, RankData.ElementData[RoleId].weaponId)
  HttpCommunication.RequestByGet(path, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
      LogicRole.ChangeRoleMainTransform("PlayerInfo")
      if LogicRole.GetRoleMainActor() then
        LogicRole.GetRoleMainActor():SetActorHiddenInGame(false)
        local CharacterRow = LogicRole.GetCharacterTableRow(RankData.ElementData[RoleId].heroId)
        if CharacterRow then
          LogicRole.GetRoleMainActor().ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
        end
        LogicRole.GetRoleMainActor():ChangeBodyMesh(RankData.ElementData[RoleId].heroId, JsonTable.hero.skinId, nil, nil, true)
        LogicRole.GetRoleMainActor():ChangeChildActorDefaultRotation(RankData.ElementData[RoleId].heroId)
        LogicRole.GetRoleMainActor():ChangeWeaponMeshBySkinId(JsonTable.weapon.skin)
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
  local TotalDamage = RankData.ElementData[RoleId].totalDamage
  local Data = {
    Name = self.TotalDamageText,
    Value = TotalDamage
  }
  self.WBP_SettlementBattleInfoItem:InitBattleRoleInfoData(Data)
  UpdateVisibility(self.CanvasPanelMvp, RankData.ElementData[RoleId].mvp)
  if RankData.GetPlayerInfo(RoleId) then
    if nil ~= RankData.GetPlayerInfo(RoleId).rankInvisible and 1 == RankData.GetPlayerInfo(RoleId).rankInvisible and RoleId ~= DataMgr.GetUserId() then
      self.RGTextName:SetText(self.InvisibleName)
    else
      self.RGTextName:SetText(RankData.GetPlayerInfo(RoleId).nickname)
    end
    local BannerId = RankData.GetPlayerInfo(RoleId).banner
    local BannerData = PlayerInfoConfig.DefaultBannerInfo
    local tbBanner = LuaTableMgr.GetLuaTableByName(TableNames.TBBanner)
    for key, RowInfo in pairs(tbBanner) do
      if RowInfo.bannerID == BannerId then
        BannerData = RowInfo
      end
    end
    self.ComBannerItem:InitComBannerItem(BannerData.bannerIconPathInInfo, BannerData.EffectPath)
  end
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_RankMVPInfo_C RoleId: %s", tostring(RoleId)))
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(RoleId)
  end
end

return WBP_RankMVPInfo_C
