local AttributeModityModule = ModuleManager:Get("AttributeModityModule") or LuaClass()
local AttributeModityData = require("Modules.AttributeModity.AttributeModityData")
function AttributeModityModule:Ctor()
end
function AttributeModityModule:OnInit()
  if UE.RGUtil and not UE.RGUtil.IsEditor() and UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("AttributeModityModule:OnInit...........")
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_HasInProgressRequest, GameInstance, AttributeModityModule.BindOnHasInProgressRequest)
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_HadRequest, GameInstance, AttributeModityModule.BindOnHadRequest)
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_Request, GameInstance, AttributeModityModule.BindOnRequest)
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_RefuseRequest, GameInstance, AttributeModityModule.BindOnRefuseRequest)
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_BroadcastConfirmRequest, GameInstance, AttributeModityModule.BindOnBroadcastConfirmRequest)
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_NotifyNoItem, GameInstance, AttributeModityModule.BindOnNotifyNoItem)
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_AlreadyHasItem, GameInstance, AttributeModityModule.BindOnAlreadyHasItem)
  ListenObjectMessage(nil, GMP.MSG_Level_ItemShare_BagFull, GameInstance, AttributeModityModule.BindOnBagFull)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelEnd, GameInstance, AttributeModityModule.BindOnLevelEnd)
end
function AttributeModityModule:OnShutdown()
  if UE.RGUtil and not UE.RGUtil.IsEditor() and UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("AttributeModityModule:OnShutdown...........")
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_HasInProgressRequest)
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_HadRequest)
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_Request)
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_RefuseRequest)
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_BroadcastConfirmRequest)
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_NotifyNoItem)
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_AlreadyHasItem)
  UnListenObjectMessage(GMP.MSG_Level_ItemShare_BagFull)
  UnListenObjectMessage(GMP.MSG_Level_LevelEnd)
end
function AttributeModityModule.BindOnBagFull(RequestData)
  print("AttributeModityModule.BindOnBagFull")
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindow(1211)
  if RequestData.FromUserId == tonumber(DataMgr.GetUserId()) then
    AttributeModityData:RemoveRequesting(RequestData.TargetUserId, RequestData.Id)
  end
end
function AttributeModityModule.BindOnHasInProgressRequest(RequestData)
  print("AttributeModityModule.BindOnHasInProgressRequest")
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindow(1212)
end
function AttributeModityModule.BindOnHadRequest(RequestData)
  print("AttributeModityModule.BindOnHadRequest")
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindow(1209)
  if RequestData.FromUserId == tonumber(DataMgr.GetUserId()) then
    AttributeModityData:RemoveRequesting(RequestData.TargetUserId, RequestData.Id)
  end
end
function AttributeModityModule.BindOnRequest(RequestData)
  print("AttributeModityModule.BindOnRequest")
  if RequestData.TargetUserId == tonumber(DataMgr.GetUserId()) then
    if not RGUIMgr:IsShown(UIConfig.WBP_LikeAttributeModifyWindow_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_LikeAttributeModifyWindow_C.UIName)
    end
    local LikeAttributeModifyWindow = RGUIMgr:GetUI(UIConfig.WBP_LikeAttributeModifyWindow_C.UIName)
    LikeAttributeModifyWindow:InitByRequestData(RequestData)
  end
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  local FromPlayerInfo = RGTeamSubsystem:GetPlayerInfo(RequestData.FromUserId)
  local TargetPlayerInfo = RGTeamSubsystem:GetPlayerInfo(RequestData.TargetUserId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(RequestData.Id, nil)
  if not ResultModify then
    return
  end
  local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
  if not ResultItemRarity then
    return
  end
  local Param = {
    FromPlayerInfo.name,
    TargetPlayerInfo.name,
    ItemRarityRow.AttributeModifyRichTextStyleName,
    AttributeModifyRow.Name
  }
  ShowWaveWindow(1216, Param)
end
function AttributeModityModule.BindOnRefuseRequest(RequestData)
  print("AttributeModityModule.BindOnRefuseRequest")
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  local FromPlayerInfo = RGTeamSubsystem:GetPlayerInfo(RequestData.FromUserId)
  local TargetPlayerInfo = RGTeamSubsystem:GetPlayerInfo(RequestData.TargetUserId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(RequestData.Id, nil)
  if not ResultModify then
    return
  end
  local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
  if not ResultItemRarity then
    return
  end
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local Param = {
    TargetPlayerInfo.name,
    ItemRarityRow.AttributeModifyRichTextStyleName,
    AttributeModifyRow.Name,
    FromPlayerInfo.name
  }
  WaveWindowManager:ShowWaveWindow(1207, Param)
  if RequestData.FromUserId == tonumber(DataMgr.GetUserId()) then
    AttributeModityData:RemoveRequesting(RequestData.TargetUserId, RequestData.Id)
    AttributeModityData:AddRefused(RequestData.TargetUserId, RequestData.Id)
  end
end
function AttributeModityModule.BindOnBroadcastConfirmRequest(RequestData)
  print("AttributeModityModule.BindOnBroadcastConfirmRequest")
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  local FromPlayerInfo = RGTeamSubsystem:GetPlayerInfo(RequestData.FromUserId)
  local TargetPlayerInfo = RGTeamSubsystem:GetPlayerInfo(RequestData.TargetUserId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(RequestData.Id, nil)
  if not ResultModify then
    return
  end
  local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
  if not ResultItemRarity then
    return
  end
  if RequestData.bIsGiveSuccess then
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if not WaveWindowManager then
      return
    end
    local Param = {
      TargetPlayerInfo.name,
      ItemRarityRow.AttributeModifyRichTextStyleName,
      AttributeModifyRow.Name,
      FromPlayerInfo.name
    }
    WaveWindowManager:ShowWaveWindow(1208, Param)
    if RequestData.FromUserId == tonumber(DataMgr.GetUserId()) then
      PlayVoice("Voice.Attributemodify.Thanks", UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0))
    end
  end
  if RequestData.FromUserId == tonumber(DataMgr.GetUserId()) then
    AttributeModityData:RemoveRequesting(RequestData.TargetUserId, RequestData.Id)
  end
  if RequestData.TargetUserId == tonumber(DataMgr.GetUserId()) then
    PlayVoice("Voice.Attributemodify.Agree", UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0))
  end
end
function AttributeModityModule.BindOnNotifyNoItem(RequestData)
  print("AttributeModityModule.BindOnNotifyNoItem")
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindow(1214)
end
function AttributeModityModule.BindOnAlreadyHasItem(RequestData)
  print("AttributeModityModule.BindOnAlreadyHasItem")
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindow(1215)
  if RequestData.TargetUserId == tonumber(DataMgr.GetUserId()) then
    AttributeModityData:RemoveRequesting(RequestData.FromUserId, RequestData.Id)
  end
end
function AttributeModityModule.BindOnLevelEnd()
  print("AttributeModityModule.BindOnLevelEnd")
  AttributeModityData:Reset()
end
function AttributeModityModule.GetPlayerStateByUserId(UserId)
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return nil
  end
  for i, SinglePS in iterator(GS.PlayerArray) do
    if SinglePS:GetUserId() == UserId then
      return SinglePS
    end
  end
  return nil
end
function AttributeModityModule.GetPlayerControllerByUserId(UserId)
  local PC
  local PS = AttributeModityModule.GetPlayerStateByUserId(UserId)
  local HeroCharacterCls = UE.ARGHeroCharacterBase:StaticClass()
  local AllHeroCharacter = UE.UGameplayStatics.GetAllActorsOfClass(GameInstance, HeroCharacterCls, nil)
  for i, SinglePlayerCharacter in iterator(AllHeroCharacter) do
    if SinglePlayerCharacter and SinglePlayerCharacter.PlayerState == PS then
      PC = SinglePlayerCharacter
    end
  end
  return PC
end
return AttributeModityModule
