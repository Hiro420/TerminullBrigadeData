local M = {
  GenericModifyChoosePath = "/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyChoosePanel.WBP_GenericModifyChoosePanel_C",
  HeartModifyFX = "/Game/Rouge/Effect/Niagara/NiagaraSystem/Character/Common/Buff/NS_FX_Character_Buff_TokenBuff_001.NS_FX_Character_Buff_TokenBuff_001",
  LastSelectWidget = nil
}
_G.LogicShop = _G.LogicShop or M

function LogicShop.Init()
  LogicShop.RecoveryProps = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Item.Category.RecoveryProps", nil)
  LogicShop.PowerUp = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Item.Category.PowerUp", nil)
  LogicShop.DigitalCollection = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Item.Category.DigitalCollection", nil)
  LogicShop.ShopNPC = nil
  LogicShop.ItemList = {}
  LogicShop.OpenTimes = 0
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    return
  end
  InteractHandle.OnFinishInteract:Add(GameInstance, LogicShop.BindOnBeginInteract)
end

function LogicShop:BindOnBeginInteract(Target)
  if not Target then
    return
  end
  local ShopInteractComp = Target:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return
  end
  local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
  if RGGlobalSettings and RGGlobalSettings.ShopOpenCondition then
    local LevelSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
    if LevelSystem and not LevelSystem:IsLevelPass() and not LevelSystem:IsReadyLevel() then
      local RGWaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if RGWaveManager then
        RGWaveManager:ShowWaveWindow(2001)
        return
      end
    end
  end
  LogicShop.InitNPC(Target)
  RGUIMgr:OpenUI("WBP_Shop_C", true, UE.EUILayer.EUILayer_High)
  LogicShop:BindOnItemArrayUpdated(nil)
end

function LogicShop.InitNPC(Target)
  if LogicShop.ShopNPC == Target then
    return
  end
  LogicShop.ShopNPC = Target
  LogicShop.ShopNPCRef = UnLua.Ref(LogicShop.ShopNPC)
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  ShopInteractComp.OnRefreshed:Add(GameInstance, LogicShop.BindOnRefreshCountChanged)
  ShopInteractComp.OnRefreshFailed:Add(GameInstance, LogicShop.BindOnNotifyRefreshResult)
  ShopInteractComp.OnItemPurchased:Add(GameInstance, LogicShop.BindOnNotifyItemPurchaseResult)
  ShopInteractComp.OnItemArrayUpdated:Add(GameInstance, LogicShop.BindOnItemArrayUpdated)
  ShopInteractComp.OnPreviewModifyListChanged:Add(GameInstance, LogicShop.BindOnPreviewModifyListChanged)
end

function LogicShop:BindOnRefreshCountChanged(RefreshCount)
  local TargetWidget = RGUIMgr:GetUI("WBP_Shop_C")
  if TargetWidget then
    TargetWidget:RefreshRefreshCountInfo()
  end
end

function LogicShop:BindOnNotifyItemPurchaseResult(InstanceId, Result)
  local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not RGWaveWindowManager then
    return
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return
  end
  local TargetWaveId = ShopInteractComp.WaveErrorCodeList:Find(Result)
  local ExtraTip = ""
  if not TargetWaveId then
    TargetWaveId = 100001
    ExtraTip = "\232\175\183\230\163\128\230\159\165\233\148\153\232\175\175\231\160\129\229\188\185\231\170\151\233\133\141\231\189\174"
    print("LogicShop:BindOnNotifyItemPurchaseResult \230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\233\148\153\232\175\175\230\143\144\231\164\186\231\160\129", Result)
  end
  local Info = LogicShop.GetItemInfoByInstanceId(InstanceId)
  local Param = ""
  if Info then
    Param = Info.Name
  end
  if Result == UE.ERGShopPurchaseResult.Succeed and 1 == LogicShop.GetCategoryByInstanceId(InstanceId) then
    local HeartModifyWaveId = -1
    local ShieldTagName = "Item.Category.PowerUp.Shield"
    local BloodTagName = "Item.Category.PowerUp.Blood"
    LogicShop.ShieldTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(ShieldTagName, nil)
    LogicShop.BloodTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(BloodTagName, nil)
    if UE.UBlueprintGameplayTagLibrary.MatchesTag(Info.ItemAsset.ItemCategory, LogicShop.BloodTag, true) then
      HeartModifyWaveId = 1125
    end
    if UE.UBlueprintGameplayTagLibrary.MatchesTag(Info.ItemAsset.ItemCategory, LogicShop.ShieldTag, true) then
      HeartModifyWaveId = 1113
    end
    if -1 ~= HeartModifyWaveId then
      ShowWaveWindow(HeartModifyWaveId, {
        Info.Desc
      })
    end
    print("Shop : Info", Info.ID, Info.Name)
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if Character and Info.ItemAsset and Info.ItemAsset.ApplyUIFXToPlayer then
      UE.URGFXSimulationComponent_UIFX.CreateUIFXSimulationTimeline(Character, Info.ItemAsset.ApplyUIFXToPlayer, Character, 0)
    end
    EventSystem.Invoke(EventDef.Shop.OnPlayHeartModifyAnim)
  else
    RGWaveWindowManager:ShowWaveWindow(TargetWaveId, {
      tostring(Param) .. ExtraTip
    })
  end
end

function LogicShop.GetShopPreviewModifyList()
  if not IsValidObj(LogicShop.ShopNPC) then
    return nil
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return nil
  end
  return ShopInteractComp.PreviewModifyList
end

function LogicShop.GetShopUpgradeModifyUpgradeLevel()
  if LogicShop.ShopNPC == nil then
    return 1
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return 1
  end
  return ShopInteractComp.PreviewModifyList.UpgradeModify_UpgradeLevel
end

function LogicShop.GetItemInfoByInstanceId(InstanceId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("[LJS]:\230\178\161\230\156\137DTSubsystem")
    return nil
  end
  local TargetInstanceInfo = LogicShop.ItemList[InstanceId]
  if not TargetInstanceInfo then
    print("[LJS]:\230\178\161\230\156\137\229\174\158\228\190\139")
    return nil
  end
  if TargetInstanceInfo.ItemType == UE.ERGShopItemType.Base then
    local ItemRowInfo = DTSubsystem:K2_GetItemTableRow(tostring(TargetInstanceInfo.BaseInfo.ItemId), nil)
    return ItemRowInfo
  end
  if TargetInstanceInfo.ItemType == UE.ERGShopItemType.AttributeModify then
    local Result, ModifyRowInfo = DTSubsystem:GetAttributeModifyDataById(TargetInstanceInfo.AttributeInfo.ModifyId, nil)
    if not Result then
      print("[LJS]:\228\184\141\230\152\175ModifyRowInfo")
      return
    end
    return ModifyRowInfo
  end
  return nil
end

function LogicShop.GetCategoryByInstanceId(InstanceId)
  local ItemRowInfo = LogicShop.GetItemInfoByInstanceId(InstanceId)
  if ItemRowInfo then
    if ItemRowInfo.ItemAsset then
      if ItemRowInfo.ItemAsset.ItemCategory == nil then
        print(ItemRowInfo.ID .. "\230\178\161\230\156\137\233\133\141\231\189\174ItemCategory")
        return 1
      end
      if UE.UBlueprintGameplayTagLibrary.MatchesTag(ItemRowInfo.ItemAsset.ItemCategory, LogicShop.PowerUp, false) then
        return 1
      end
      if UE.UBlueprintGameplayTagLibrary.MatchesTag(ItemRowInfo.ItemAsset.ItemCategory, LogicShop.DigitalCollection, false) then
        return 2
      end
      if UE.UBlueprintGameplayTagLibrary.MatchesTag(ItemRowInfo.ItemAsset.ItemCategory, LogicShop.RecoveryProps, false) then
        return 3
      end
    end
    local TargetInstanceInfo = LogicShop.ItemList[InstanceId]
    if not TargetInstanceInfo then
      print("[LJS]:\230\178\161\230\156\137\229\174\158\228\190\139")
      return nil
    end
    if TargetInstanceInfo.ItemType == UE.ERGShopItemType.AttributeModify then
      return 2
    end
  end
  print("[LJS]", InstanceId, "\228\184\141\231\159\165\233\129\147\230\152\175\228\187\128\228\185\136\229\136\134\231\177\187")
  return 0
end

function LogicShop:BindOnNotifyRefreshResult(Result)
  local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not RGWaveWindowManager then
    return
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return
  end
  local TargetWaveId = ShopInteractComp.WaveErrorCodeList:Find(Result)
  local ExtraTip = ""
  if not TargetWaveId then
    TargetWaveId = 100001
    ExtraTip = "\232\175\183\230\163\128\230\159\165\233\148\153\232\175\175\231\160\129\229\188\185\231\170\151\233\133\141\231\189\174"
    print("LogicShop:BindOnNotifyRefreshResult \230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\233\148\153\232\175\175\230\143\144\231\164\186\231\160\129", Result)
  end
  RGWaveWindowManager:ShowWaveWindow(TargetWaveId, {ExtraTip})
end

function LogicShop:BindOnItemArrayUpdated(OldArray)
  if not LogicShop.ShopNPC then
    return
  end
  local ShopView = RGUIMgr:GetUI("WBP_Shop_C")
  if ShopView then
    local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
    if not ShopInteractComp then
      return
    end
    for key, SingelItem in pairs(ShopInteractComp.ItemArray) do
      LogicShop.ItemList[SingelItem.InstanceId] = SingelItem
    end
    local bPlayAnim = nil == OldArray
    ShopView:OnOpen(bPlayAnim)
  end
end

function LogicShop:BindOnPreviewModifyListChanged(PreviewModifyList)
  LogicShop:BindOnItemArrayUpdated(LogicShop.GetAllItemInfo())
  if PreviewModifyList.bSelected then
    print("LogicShop:BindOnPreviewModifyListChanged Had be Selected")
    return
  end
  if PreviewModifyList.bAbandoned then
    if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
      RGUIMgr:HideUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    end
    print("LogicShop:BindOnPreviewModifyListChanged Had be Abandoned")
    return
  end
  LogicShop:OpenGenericModifyChoosePanel(PreviewModifyList)
end

function LogicShop:RefreshModifyList(PC)
  if PC and PC.MiscHelper then
    PC.MiscHelper:RefreshSelectPreviewModifyList(LogicShop.ShopNPC.RGInteractComponent_Shop)
  end
end

function LogicShop:OpenGenericModifyChoosePanel(PreviewModifyList)
  local WidgetClass = UE.UClass.Load(LogicShop.GenericModifyChoosePath)
  if not WidgetClass then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager:IsShown(WidgetClass) then
    UIManager:OpenUI(WidgetClass, true)
  end
  local TargetWidget = UIManager:K2_GetUI(WidgetClass)
  if TargetWidget then
    LogicShop.ModifyInstanceId = PreviewModifyList.InstanceId
    print("LogicShop:BindOnPreviewModifyListChanged InstanceId", PreviewModifyList.InstanceId)
    TargetWidget:UpdateModifyListByShop(PreviewModifyList, LogicShop.ShopNPC)
    LogicGenericModify.bCanOperator = true
    LogicGenericModify.bCanFinish = true
    TargetWidget.IsInShop = true
  end
end

function LogicShop:ShopAbandonPreviewModifyList(ShopNPCParam)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not PlayerMiscComp then
    return
  end
  local ShopNPC = ShopNPCParam
  if not UE.RGUtil.IsUObjectValid(ShopNPC) then
    print("ShopNPCParam is invalid")
    ShopNPC = LogicShop.ShopNPC
  end
  if not UE.RGUtil.IsUObjectValid(ShopNPC) then
    print("LogicShop.ShopNPC is invalid")
    return
  end
  local ShopInteractComp = ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not UE.RGUtil.IsUObjectValid(ShopInteractComp) then
    return
  end
  if LogicGenericModify.bCanOperator then
    PlayerMiscComp:ShopAbandonPreviewModifyList(ShopInteractComp, LogicShop.ModifyInstanceId)
    LogicGenericModify.bCanOperator = false
    print("LogicShop:ShopAbandonPreviewModifyList InstanceId", LogicShop.ModifyInstanceId)
  else
    print("LogicShop:ShopAbandonPreviewModifyList LogicGenericModify.bCanOperator is false", LogicShop.ModifyInstanceId)
  end
end

function LogicShop:ShopSelectPreviewModifyList(ModifyId, bIsUpgrade)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not PlayerMiscComp then
    return
  end
  if not UE.RGUtil.IsUObjectValid(LogicShop.ShopNPC) then
    return
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not UE.RGUtil.IsUObjectValid(ShopInteractComp) then
    return
  end
  if LogicGenericModify.bCanOperator then
    PlayerMiscComp:ShopSelectPreviewModifyList(ShopInteractComp, LogicShop.ModifyInstanceId, ModifyId, bIsUpgrade)
    LogicGenericModify.bCanOperator = false
    print("LogicShop:ShopSelectPreviewModifyList", LogicShop.ModifyInstanceId, ModifyId, bIsUpgrade)
  else
    print("LogicShop:ShopSelectPreviewModifyList LogicGenericModify.bCanOperator is false", LogicShop.ModifyInstanceId, ModifyId, bIsUpgrade)
  end
end

function LogicShop:ShopSelectPreviewModifyListEx(ModifyId, ModifyChooseType, ShopNPCParam)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not PlayerMiscComp then
    return
  end
  local ShopNPC = ShopNPCParam
  if not UE.RGUtil.IsUObjectValid(ShopNPC) then
    print("ShopNPCParam is invalid")
    ShopNPC = LogicShop.ShopNPC
  end
  if not UE.RGUtil.IsUObjectValid(ShopNPC) then
    print("LogicShop.ShopNPC is invalid")
    return
  end
  local ShopInteractComp = ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not UE.RGUtil.IsUObjectValid(ShopInteractComp) then
    return
  end
  local RGNpcType = LogicShop:ChangeModifyChooseTypeToNpcType(ModifyChooseType)
  if LogicGenericModify.bCanOperator then
    PlayerMiscComp:ShopSelectPreviewModifyListEx(ShopInteractComp, LogicShop.ModifyInstanceId, ModifyId, RGNpcType)
    LogicGenericModify.bCanOperator = false
    print("LogicShop:ShopSelectPreviewModifyListEx", LogicShop.ModifyInstanceId, ModifyId, RGNpcType, ModifyChooseType)
  else
    print("LogicShop:ShopSelectPreviewModifyListEx LogicGenericModify.bCanOperator is false", LogicShop.ModifyInstanceId, ModifyId, RGNpcType, ModifyChooseType)
  end
end

function LogicShop:ChangeModifyChooseTypeToNpcType(ModifyChooseTypeParam)
  if ModifyChooseTypeParam == ModifyChooseType.UpgradeModify then
    return UE.ERGNpcType.NT_UpgradeModify
  end
  if ModifyChooseTypeParam == ModifyChooseType.RarityUpModify then
    return UE.ERGNpcType.NT_RarityUpModify
  end
  if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
    return UE.ERGNpcType.NT_GenericModify
  end
  if ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
    return UE.ERGNpcType.NT_SpecificModify
  end
  if ModifyChooseTypeParam == ModifyChooseType.GenericModifySell then
    return UE.ERGNpcType.NT_GenericModifySell
  end
  return UE.ERGNpcType.NT_GenericModify
end

function LogicShop.ClearNPC()
  if not LogicShop.ShopNPC or not LogicShop.ShopNPC:IsValid() then
    LogicShop.ShopNPC = nil
    return
  end
  UnLua.Unref(LogicShop.ShopNPC)
  LogicShop.ShopNPCRef = nil
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  ShopInteractComp.OnRefreshed:Remove(GameInstance, LogicShop.BindOnRefreshCountChanged)
  ShopInteractComp.OnRefreshFailed:Remove(GameInstance, LogicShop.BindOnNotifyRefreshResult)
  ShopInteractComp.OnItemPurchased:Remove(GameInstance, LogicShop.BindOnNotifyItemPurchaseResult)
  ShopInteractComp.OnItemArrayUpdated:Remove(GameInstance, LogicShop.BindOnItemArrayUpdated)
  ShopInteractComp.OnPreviewModifyListChanged:Remove(GameInstance, LogicShop.BindOnPreviewModifyListChanged)
  LogicShop.ShopNPC = nil
end

function LogicShop.BuyShopItem(InstanceId)
  if not LogicShop.ShopNPC or not LogicShop.ShopNPC:IsValid() then
    print("\229\149\134\229\186\151NPC\230\151\160\230\149\136")
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not PlayerMiscComp then
    return
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  PlayerMiscComp:BuyShopItem(ShopInteractComp, InstanceId)
end

function LogicShop.RefreshShopItem()
  if not LogicShop.ShopNPC or not LogicShop.ShopNPC:IsValid() then
    print("\229\149\134\229\186\151NPC\230\151\160\230\149\136")
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not PlayerMiscComp then
    return
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  PlayerMiscComp:RefreshShopItem(ShopInteractComp)
end

function LogicShop.GetCurRefreshCount()
  if LogicShop.ShopNPC == nil or UE.RGUtil.IsUObjectValid(LogicShop.ShopNPC) == false then
    return 0
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return 0
  end
  return ShopInteractComp.RefreshCount
end

function LogicShop.GetCurRefreshCountForPriceCalc()
  if LogicShop.ShopNPC == nil then
    return 0
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return 0
  end
  local FreeRefreshCount = LogicShop.GetFreeRefreshCount()
  return ShopInteractComp.RefreshCount - FreeRefreshCount
end

function LogicShop.GetFreeRefreshCount()
  if LogicShop.ShopNPC == nil then
    return 0
  end
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return 0
  end
  return ShopInteractComp.FreeRefreshCount
end

function LogicShop.GetMaxRefreshCount()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicShop.GetMaxRefreshCount Character is nil")
    return 0
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return 0
  end
  local FreeCount = LogicShop.GetFreeRefreshCount()
  return string.format("%d", CoreComp:GetShopRefreshCount() + FreeCount)
end

function LogicShop.CanRefreshForFree()
  local RefreshCount = LogicShop.GetCurRefreshCount()
  local FreeRefreshCount = LogicShop.GetFreeRefreshCount()
  return RefreshCount < FreeRefreshCount
end

function LogicShop.GetAllItemInfo()
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if not ShopInteractComp then
    return nil
  end
  return ShopInteractComp.ItemArray
end

function LogicShop.Clear()
  LogicShop.ClearNPC()
  LogicShop.ItemList = {}
  LogicShop.ModifyInstanceId = nil
  LogicShop.OpenTimes = 0
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    return
  end
  InteractHandle.OnBeginInteract:Remove(GameInstance, LogicShop.BindOnBeginInteract)
end

function LogicShop.OnPreselectionItem(ItemInfo, Widget)
  RGUIMgr:GetUI("WBP_Shop_C"):RefreshItemDetails(ItemInfo)
  RGUIMgr:GetUI("WBP_Shop_C"):RefreshItemPreview(ItemInfo)
  if LogicShop.LastSelectWidget ~= nil then
    LogicShop.LastSelectWidget:SetHovered(false)
  end
  if nil ~= Widget then
    Widget:SetHovered(true)
    LogicShop.LastSelectWidget = Widget
  end
end
