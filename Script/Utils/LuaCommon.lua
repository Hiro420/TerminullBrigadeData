require("Utils.DateTimeLibrary")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local NumToTxtTb = {
  [0] = NSLOCTEXT("LuaCommon", "NumToTxtTb0", "\233\155\182"),
  [1] = NSLOCTEXT("LuaCommon", "NumToTxtTb1", "\228\184\128"),
  [2] = NSLOCTEXT("LuaCommon", "NumToTxtTb2", "\228\186\140"),
  [3] = NSLOCTEXT("LuaCommon", "NumToTxtTb3", "\228\184\137"),
  [4] = NSLOCTEXT("LuaCommon", "NumToTxtTb4", "\229\155\155"),
  [5] = NSLOCTEXT("LuaCommon", "NumToTxtTb5", "\228\186\148"),
  [6] = NSLOCTEXT("LuaCommon", "NumToTxtTb6", "\229\133\173"),
  [7] = NSLOCTEXT("LuaCommon", "NumToTxtTb7", "\228\184\131"),
  [8] = NSLOCTEXT("LuaCommon", "NumToTxtTb8", "\229\133\171"),
  [9] = NSLOCTEXT("LuaCommon", "NumToTxtTb9", "\228\185\157"),
  [10] = NSLOCTEXT("LuaCommon", "NumToTxtTb10", "\229\141\129")
}
local NumToRomanTb = {
  [1] = "\226\133\160",
  [2] = "\226\133\161",
  [3] = "\226\133\162",
  [4] = "\226\133\163",
  [5] = "\226\133\164",
  [6] = "\226\133\165",
  [7] = "\226\133\166",
  [8] = "\226\133\167",
  [9] = "\226\133\168"
}
local DateTxtFmt = NSLOCTEXT("LuaCommon", "DateTxtFmt", "%Y\229\185\180%m\230\156\136%d\230\151\165")
local DateTxtFmtWithTime = NSLOCTEXT("LuaCommon", "DateTxtFmtWithTime", "%Y\229\185\180%m\230\156\136%d\230\151\165%H\230\151\182%M\229\136\134%S\231\167\146")

function iterator(Array)
  local i = 0
  local Length = Array:Length()
  return function()
    i = i + 1
    if i > Length then
      return nil
    end
    return i, Array:Get(i)
  end
end

local OrderMapipairs = function(tb)
  local k, v
  return function()
    repeat
      k, v = next(tb.keys, k)
    until v and tb.map[v] or not v and not tb.map[v]
    return v, tb.map[v]
  end
end
local Custom_ipairs = ipairs

function ipairs(tb)
  if tb and tb.__ContainerName == "OrderedMap" then
    return OrderMapipairs(tb)
  elseif tb and tb.__ContainerName == "ProrityQueue" then
    return tb.PairsFunc(tb)
  else
    return Custom_ipairs(tb)
  end
end

function table.count(t)
  local Count = 0
  for key, value in pairs(t) do
    Count = Count + 1
  end
  return Count
end

function table.RemoveItem(t, Item)
  local RemoveIndex = 0
  for index, value in ipairs(t) do
    if value == Item then
      RemoveIndex = index
    end
  end
  if t[RemoveIndex] then
    table.remove(t, RemoveIndex)
  end
end

function table.Contain(t, value)
  if not t then
    return false
  end
  for k, v in pairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

function table.IsEmpty(t)
  if not t then
    return true
  end
  return not next(t)
end

function table.IndexOf(t, value)
  for i, v in ipairs(t) do
    if v == value then
      return i
    end
  end
  return nil
end

function table.Print(t)
  local print_r_cache = {}
  
  local function sub_print_r(t, indent)
    if print_r_cache[tostring(t)] then
      print(indent .. "*" .. tostring(t))
    else
      print_r_cache[tostring(t)] = true
      if type(t) == "table" then
        for pos, val in pairs(t) do
          if type(val) == "table" then
            print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
            sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
            print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
          elseif type(val) == "string" then
            print(indent .. "[" .. pos .. "] => \"" .. val .. "\"")
          else
            print(indent .. "[" .. pos .. "] => " .. tostring(val))
          end
        end
      else
        print(indent .. tostring(t))
      end
    end
  end
  
  if type(t) == "table" then
    print(tostring(t) .. " {")
    sub_print_r(t, "  ")
    print("}")
  else
    sub_print_r(t, "  ")
  end
  print()
end

function math.clamp(v, minValue, maxValue)
  if v < minValue then
    return minValue
  end
  if maxValue < v then
    return maxValue
  end
  return v
end

function GetTips(ItemId, TipsClass)
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    return nil
  end
  local Widget = UE.UWidgetBlueprintLibrary.Create(GameInstance, TipsClass)
  if Widget then
    if Widget.ShowTips then
      local Result, OptionalGiftRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBOptionalGift, ItemId)
      if Result and OptionalGiftRowInfo.isShow then
        local Items = {}
        for index, value in ipairs(OptionalGiftRowInfo.Resources) do
          local Item = {
            ItemID = value.key,
            Count = value.value
          }
          table.insert(Items, Item)
        end
        Widget:ShowTips(ResourceRowInfo.Name, ResourceRowInfo.Desc, ResourceRowInfo.Rare, ResourceRowInfo.TypeDesc, nil, Items, ResourceRowInfo.ProEffType)
      else
        Widget:ShowTips(ResourceRowInfo.Name, ResourceRowInfo.Desc, ResourceRowInfo.Rare, ResourceRowInfo.TypeDesc, nil, nil, ResourceRowInfo.ProEffType)
      end
    end
    return Widget
  end
  return nil
end

function ShowOptionalGiftQueueWindow(OptionalGiftIdTable, SourceId, Type, OnConfirmClick, ...)
end

function ShowOptionalGiftWindow(OptionalGiftIdTable, SourceId, Type, OnConfirmClick, ...)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  for OptionalGiftId, Num in pairs(OptionalGiftIdTable) do
    if TBGeneral[OptionalGiftId] and TBGeneral[OptionalGiftId].Type == TableEnums.ENUMResourceType.OptionalGift then
      local Widget = ShowWaveWindowWithDelegate(306002, {}, {})
      Widget:InitOptionalGift(OptionalGiftId, SourceId, Type, Num, ...)
      Widget:BindOnConfirmClick(OnConfirmClick)
    end
  end
end

function ShowWaveWindowWithConsoleCheck(WaveId, Params, ErrorCode)
  if 30009 == ErrorCode or 11000 == ErrorCode or 500 == ErrorCode then
    return
  end
  ShowWaveWindow(WaveId, Params)
end

function ShowWaveWindow(WaveId, Params)
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  local WaveWindow
  if WaveManager then
    WaveWindow = WaveManager:ShowWaveWindow(WaveId, Params, nil)
  end
  return WaveWindow
end

function ShowWaveWindowWithDelegate(WaveId, Params, SuccCallback, FailedCallback, WaveWindowParam)
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveManager then
    return nil
  end
  return WaveManager:ShowWaveWindowWithWaveParam(WaveId, Params, nil, SuccCallback, FailedCallback, WaveWindowParam)
end

function CloseWaveWindow(Wnd)
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager then
    WaveManager:CloseWaveWindow(Wnd)
  end
end

function GetItemWidget(ItemId, Num, bShowName, HoveredFun, UnHoveredFun)
  local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonItem.WBP_CommonItem_C"
  local WidgetClass = UE.UClass.Load(WidgetClassPath)
  if WidgetClass then
    local Widget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    Widget:InitCommonItem(ItemId, Num, bShowName, HoveredFun, UnHoveredFun)
    return Widget
  end
  return nil
end

function GetItemDetailWidget(ItemId)
  local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonItemDetail.WBP_CommonItemDetail_C"
  local WidgetClass = UE.UClass.Load(WidgetClassPath)
  if WidgetClass then
    local Widget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    Widget:InitCommonItemDetail(ItemId)
    return Widget
  end
  return nil
end

function GetCommonTipsWidget()
  local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonTips.WBP_CommonTips_C"
  local WidgetClass = UE.UClass.Load(WidgetClassPath)
  if WidgetClass then
    local Widget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    return Widget
  end
  return nil
end

function ShowTipsAndInitPos(HoveredTipWidget, TipsParent, HoverItem, TipsOffset)
  UpdateVisibility(HoveredTipWidget, true)
  local tipsOffset = TipsOffset or UE.FVector2D(0)
  local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(HoveredTipWidget)
  local GeometryItem = HoverItem:GetCachedGeometry()
  local GeometryTipsParent = TipsParent:GetCachedGeometry()
  local scale = UE.UWidgetLayoutLibrary.GetViewportScale(UE.RGUtil.GetWorld())
  local screenSize = UE.UWidgetLayoutLibrary.GetViewportSize(UE.RGUtil.GetWorld()) / scale
  local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryTipsParent, GeometryItem)
  local TipsSize = HoveredTipWidget:GetDesiredSize()
  Pos = Pos + tipsOffset
  if Pos.Y + TipsSize.Y > screenSize.Y then
    Pos.Y = screenSize.Y - TipsSize.Y
  end
  if Pos.X + TipsSize.X > screenSize.X then
    Pos.X = screenSize.X - TipsSize.X
  end
  slotCanvas:SetPosition(Pos)
end

function ShowCommonTips(TipsParent, HoverItem, HoverTips, ClassPath, TipsClass, UseRelativePosition, Offset, CusPosType, Scale)
  local RootCanvas
  local SceneStatus = GetCurSceneStatus()
  if SceneStatus == UE.ESceneStatus.ELobby then
    RootCanvas = UIMgr:GetUIRoot().CommonTips
  elseif SceneStatus == UE.ESceneStatus.EBattle or SceneStatus == UE.ESceneStatus.ESettlement then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if UIManager then
      RootCanvas = UIManager:GetRootWidget().CommonTipsPanel
    end
  end
  if not RootCanvas then
    return
  end
  TipsParent = TipsParent or RootCanvas
  local TipsWidget = HoverTips
  TipsWidget = TipsWidget or LogicCommonTips.CreateTipsWidget(TipsParent, ClassPath, TipsClass)
  if TipsWidget then
    local scale = UE.UWidgetLayoutLibrary.GetViewportScale(TipsParent)
    local GeometryItem = HoverItem:GetCachedGeometry()
    local GeometryTipsParent = TipsParent:GetCachedGeometry()
    local HoverItemPos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryTipsParent, GeometryItem)
    TipsWidget:SetRenderOpacity(0)
    SetHitTestInvisible(TipsWidget)
    print("ShowCommonTips: HoverItemPos  " .. tostring(HoverItemPos))
    local delayTimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        if not Scale then
          Scale = 1
        end
        local TipsSize = TipsWidget:GetDesiredSize() * Scale
        print("ShowCommonTips: TipsSize  " .. tostring(TipsSize))
        local HoverItemSize
        if UseRelativePosition then
          HoverItemSize = UE.USlateBlueprintLibrary.GetLocalSize(GeometryItem)
        else
          HoverItemSize = HoverItem:GetDesiredSize()
        end
        local PosType = CusPosType
        if not PosType then
          PosType = LogicCommonTips.GetCommonTipsType(RootCanvas, GeometryItem, TipsWidget, TipsSize)
          print("ShowCommonTips: PosType  " .. tostring(PosType))
        end
        if UseRelativePosition then
          LogicCommonTips.SetCommonTipsRelativePosition(HoverItem, TipsWidget, PosType, TipsSize, Offset)
        else
          LogicCommonTips.SetCommonTipsAbsolutePosition(HoverItemPos, HoverItemSize, TipsWidget, PosType, TipsSize, Offset)
        end
        TipsWidget:SetRenderOpacity(1)
        return TipsWidget
      end
    }, 0.02, false)
    return TipsWidget
  end
end

function ShowCommonTipsForPos(TipsParent, HoverTips, ClassPath, TipsClass, Pos, Offset)
  local RootCanvas
  local SceneStatus = GetCurSceneStatus()
  if SceneStatus == UE.ESceneStatus.ELobby then
    RootCanvas = UIMgr:GetUIRoot().CommonTips
  elseif SceneStatus == UE.ESceneStatus.EBattle or SceneStatus == UE.ESceneStatus.ESettlement then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if UIManager then
      RootCanvas = UIManager:GetRootWidget().CommonTipsPanel
    end
  end
  if not RootCanvas then
    return
  end
  TipsParent = TipsParent or RootCanvas
  local TipsWidget = HoverTips
  TipsWidget = TipsWidget or LogicCommonTips.CreateTipsWidget(TipsParent, ClassPath, TipsClass)
  if TipsWidget then
    local HoverItemPos
    if Pos then
      HoverItemPos = Pos
    else
      HoverItemPos = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(TipsParent)
    end
    SetHitTestInvisible(TipsWidget)
    local TipsSize = TipsWidget:GetDesiredSize()
    local PosType = LogicCommonTips.GetCommonTipsTypeForPos(RootCanvas, HoverItemPos, TipsWidget, TipsSize)
    LogicCommonTips.SetCommonTipsAbsolutePosition(HoverItemPos, {X = 0, Y = 0}, TipsWidget, PosType, TipsSize, Offset)
    return TipsWidget
  end
end

function SwitchUI(UIClass, HideOther)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    return UIManager:Switch(UIClass, HideOther)
  end
end

function PlaySound2DByName(Name, SourceDesc)
  return UE.UAudioManager.PlaySound2DByName(Name, SourceDesc)
end

function BreakSoundByName(EventName, Emitter, PlayingID)
  return UE.UAudioManager.BreakSoundByName(EventName, Emitter, PlayingID)
end

function PlaySound2DEffect(Id, SourceDesc)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if RGSoundSubsystem then
    RGSoundSubsystem:PlaySound2D(Id, SourceDesc)
  end
end

function PlaySound3DEffect(Id, TargetActor)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if RGSoundSubsystem then
    RGSoundSubsystem:PlaySound3D(Id, TargetActor)
  end
end

function PlayHeroSkillHitSound3D(Skill, DamageType, SourceActor, TargetActor, bKill)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if RGSoundSubsystem then
    RGSoundSubsystem:PlayHeroSkillHitSound3D(Skill, DamageType, SourceActor, TargetActor, bKill)
  end
end

function PlayHeroNormalHitSound3D(SourceActor, TargetActor, bKill)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if RGSoundSubsystem then
    RGSoundSubsystem:PlayHeroNormalHitSound3D(SourceActor, TargetActor, bKill)
  end
end

function PlayVoiceByRowName(RowName, SpeakerActor, SkinId)
  local RGVoiceSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGVoiceSubsystem:StaticClass())
  if RGVoiceSubsystem then
    return RGVoiceSubsystem:PlayVoiceByRowName(RowName, SpeakerActor, SkinId)
  end
  return 0
end

function PlayVoice(MessageTag, SpeakerActor, TargetActor)
  local RGVoiceSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGVoiceSubsystem:StaticClass())
  if RGVoiceSubsystem then
    return RGVoiceSubsystem:PlayVoice(MessageTag, SpeakerActor, TargetActor)
  end
  return 0
end

function StopSound2DEffect(Id)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if RGSoundSubsystem then
    RGSoundSubsystem:StopSound2D(Id)
  end
end

function MakeStringToSoftObjectReference(Path)
  local Result = UE.URGBlueprintLibrary.IsShortPackageName(Path)
  if Result then
    return
  end
  local SoftObjectPath = UE.UKismetSystemLibrary.MakeSoftObjectPath(Path)
  local SoftObjectReference = UE.UKismetSystemLibrary.Conv_SoftObjPathToSoftObjRef(SoftObjectPath)
  return SoftObjectReference
end

function MakeStringToSoftClassReference(Path)
  local SoftClassPath = UE.UKismetSystemLibrary.MakeSoftClassPath(Path)
  local SoftClassReference = UE.UKismetSystemLibrary.Conv_SoftClassPathToSoftClassRef(SoftClassPath)
  return SoftClassReference
end

function MakeBrushBySoftObj(SoftObj, Size)
  if not SoftObj then
    return UE.FSlateBrush()
  end
  local IconObj = GetAssetBySoftObjectPtr(SoftObj, true)
  if IconObj then
    local x = 0
    local y = 0
    if Size then
      x = math.ceil(Size.X)
      y = math.ceil(Size.Y)
    end
    local Brush = UE.FSlateBrush()
    if IconObj:IsA(UE.UPaperSprite.StaticClass()) then
      Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, x, y)
      print("MakeBrushBySoftObj IconObj Is UPaperSprite", IconObj)
    elseif IconObj:IsA(UE.UTexture2D.StaticClass()) then
      Brush = UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(IconObj, x, y)
      print("MakeBrushBySoftObj IconObj Is Texture2D", IconObj)
    else
      print("MakeBrushBySoftObj IconObj Is InValidType", IconObj)
    end
    return Brush
  end
  return UE.FSlateBrush()
end

function SetImageBrushByPath(Img, Path, IconSize)
  if not Path then
    return
  end
  local ImgObjRef = MakeStringToSoftObjectReference(Path)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(ImgObjRef) then
    local IconObj = GetAssetBySoftObjectPtr(ImgObjRef, true)
    if IconObj then
      local x = 0
      local y = 0
      if IconSize then
        x = math.ceil(IconSize.X)
        y = math.ceil(IconSize.Y)
      end
      local Brush
      if IconObj:IsA(UE.UPaperSprite.StaticClass()) then
        Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, x, y)
      elseif IconObj:IsA(UE.UTexture2D.StaticClass()) then
        Brush = UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(IconObj, x, y)
      else
        print("SetImageBrushBySoftObject IconObj Is InValidType", IconObj)
      end
      if Brush then
        Img:SetBrush(Brush)
      end
    end
  end
end

function SetImageBrushBySoftObjectPath(Img, SoftObjectPath, Size, bReserveBrush)
  local IconObj = GetAssetByPath(SoftObjectPath, true)
  if IconObj then
    local x = 0
    local y = 0
    if Size then
      x = math.ceil(Size.X)
      y = math.ceil(Size.Y)
    end
    local Brush
    if IconObj:IsA(UE.UPaperSprite.StaticClass()) then
      Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, x, y)
      if bReserveBrush then
        Brush.ImageSize = Img.Brush.ImageSize
        Brush.Margin = Img.Brush.Margin
        Brush.TintColor = Img.Brush.TintColor
        Brush.DrawAs = Img.Brush.DrawAs
        Brush.Tiling = Img.Brush.Tiling
        Brush.Mirroring = Img.Brush.Mirroring
      end
    elseif IconObj:IsA(UE.UTexture2D.StaticClass()) then
      if bReserveBrush then
        UE.URGBlueprintLibrary.SetImageBrushFromAsset(Img, IconObj)
      else
        Brush = UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(IconObj, x, y)
      end
    else
      print("SetImageBrushBySoftObjectPath IconObj Is InValidType", IconObj)
    end
    if Brush then
      Img:SetBrush(Brush)
    end
  end
end

function SetImageBrushBySoftObject(Img, SoftObj, Size, bReserveBrush)
  if not SoftObj then
    return
  end
  local IconObj = GetAssetBySoftObjectPtr(SoftObj, true)
  if IconObj then
    local x = 0
    local y = 0
    if Size then
      x = math.ceil(Size.X)
      y = math.ceil(Size.Y)
    end
    local Brush
    if IconObj:IsA(UE.UPaperSprite.StaticClass()) then
      if bReserveBrush then
        Brush = Img.Brush
        Brush.ResourceObject = IconObj
      else
        Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, x, y)
      end
    elseif IconObj:IsA(UE.UTexture2D.StaticClass()) then
      if bReserveBrush then
        UE.URGBlueprintLibrary.SetImageBrushFromAsset(Img, IconObj)
      else
        Brush = UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(IconObj, x, y)
      end
    else
      print("SetImageBrushBySoftObject IconObj Is InValidType", IconObj)
    end
    if Brush then
      Img:SetBrush(Brush)
    end
  end
end

function SetImageBrushByTexture2DSoftObject(Img, SoftObj, Size)
  if not SoftObj then
    return
  end
  local IconObj = GetAssetBySoftObjectPtr(SoftObj, true)
  if IconObj then
    local x = 0
    local y = 0
    if Size then
      x = math.ceil(Size.X)
      y = math.ceil(Size.Y)
    end
    local Brush = UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(IconObj, x, y)
    if Brush then
      Img:SetBrush(Brush)
    end
  end
end

function GetAssetByPath(InPath, IsForced)
  local TargetSoftObjPath
  if type(InPath) == "string" then
    TargetSoftObjPath = UE.UKismetSystemLibrary.MakeSoftObjectPath(InPath)
  else
    TargetSoftObjPath = InPath
  end
  return UE.URGAssetManager.GetAssetByPath(TargetSoftObjPath, IsForced)
end

function GetAssetBySoftObjectPtr(InObjectPtr, IsForced)
  local Path = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(InObjectPtr)
  return GetAssetByPath(Path, IsForced)
end

function GetDataLibraryObj()
  local DataLibraryPath = "/Game/Rouge/UI/BP_RGDataLibrary.BP_RGDataLibrary_C"
  local Obj = UE.UObject.Load(DataLibraryPath)
  return Obj
end

function Format(sec, fmt, useShort)
  fmt = string.lower(fmt)
  local fmtSecInfo = {}
  fmtSecInfo.d = 86400
  fmtSecInfo.h = 3600
  fmtSecInfo.m = 60
  fmtSecInfo.s = 0
  local startIdx = 1
  local parttern = "%l+"
  local i, j = string.find(fmt, parttern, startIdx)
  local fmtChar = string.match(fmt, parttern, startIdx)
  local retFmt = string.sub(fmt, 1, i - 1)
  while j and fmtChar do
    startIdx = j + 1
    local k, m = string.find(fmt, parttern, startIdx)
    local nextStart = k and k - 1 or #fmt
    local f = string.sub(fmtChar, 1, 1)
    local fmtSec = fmtSecInfo[f]
    if not fmtSec then
      return "\230\151\182\233\151\180\230\160\188\229\188\143=" .. fmt .. " \230\151\160\230\149\136"
    end
    local val
    if fmtSec > 0 then
      val = math.floor(sec / fmtSec)
      sec = sec % fmtSec
    else
      val = sec
    end
    if val > 0 or not useShort then
      local valStr = tostring(val)
      if 2 == #fmtChar and val < 10 then
        valStr = "0" .. val
      end
      local tempFmtStr = string.sub(fmt, i, nextStart)
      retFmt = retFmt .. string.gsub(tempFmtStr, parttern, valStr)
    end
    fmtChar = string.match(fmt, parttern, startIdx)
    i, j = k, m
  end
  return retFmt
end

function TimestampToDateTimeText(Timestamp)
  local DateTxtFmtStr = tostring(DateTxtFmtWithTime)
  return os.date(DateTxtFmtStr, Timestamp)
end

function TimestampToDateText(Timestamp)
  local DateTxtFmtStr = tostring(DateTxtFmt)
  return os.date(DateTxtFmtStr, Timestamp)
end

function Timezone()
  local now = os.time()
  local difftime = os.difftime(now, os.time(os.date("!*t", now)))
  return tonumber(difftime) / 3600
end

function GetOrCreateItem(Parent, Index, Cls, bCopyNav)
  local Item = Parent:GetChildAt(Index - 1)
  if not Item then
    Item = UE.UWidgetBlueprintLibrary.Create(Parent, Cls)
    Parent:AddChild(Item)
    if bCopyNav then
      local firstItem = Parent:GetChildAt(0)
      if firstItem then
        UE.URGBlueprintLibrary.CopyNavigation(firstItem, Item)
        Item.bIsFocusable = firstItem.bIsFocusable
      end
    end
  end
  if 1 == Index then
  end
  return Item
end

function GetOrCreateItemByClass(Parent, Index, Cls, FilterChildClsToList, bCopyNav)
  local clsName = Cls:GetName()
  print("GetOrCreateItemByClass", clsName)
  if table.IsEmpty(FilterChildClsToList) or table.IsEmpty(FilterChildClsToList[clsName]) then
    local ChildList = Parent:GetAllChildren()
    FilterChildClsToList = {
      [clsName] = {}
    }
    for i, v in iterator(ChildList) do
      if v:IsA(Cls) then
        table.insert(FilterChildClsToList[clsName], v)
      end
    end
  end
  if Index <= #FilterChildClsToList[clsName] then
    return FilterChildClsToList[clsName][Index]
  else
    local Item = UE.UWidgetBlueprintLibrary.Create(Parent, Cls)
    Parent:AddChild(Item)
    table.insert(FilterChildClsToList[clsName], Item)
    if bCopyNav then
      local firstItem = FilterChildClsToList[clsName][1]
      if firstItem then
        UE.URGBlueprintLibrary.CopyNavigation(firstItem, Item)
        Item.bIsFocusable = firstItem.bIsFocusable
      end
    end
    return Item
  end
end

function HideOtherItem(Parent, startIndex, IsForced)
  for i = startIndex, Parent:GetChildrenCount() do
    local Item = Parent:GetChildAt(i - 1)
    if Item and Item.Hide then
      Item:Hide()
    elseif Item and not Item.Hide and IsForced then
      UpdateVisibility(Item, false)
    end
  end
end

function HideOtherItemByClass(Parent, startIndex, Cls, FilterChildClsToList)
  local clsName = Cls:GetName()
  print("GetOrCreateItemByClass", clsName)
  if table.IsEmpty(FilterChildClsToList) or table.IsEmpty(FilterChildClsToList[clsName]) then
    local idx = 1
    local ChildList = Parent:GetAllChildren()
    for i, v in iterator(ChildList) do
      if v:IsA(Cls) then
        if startIndex <= idx then
          if v.Hide then
            v:Hide()
          else
            UpdateVisibility(v, false)
          end
        end
        idx = idx + 1
      end
    end
  else
    for i = startIndex, #FilterChildClsToList[clsName] do
      local v = FilterChildClsToList[clsName][i]
      if v:IsA(Cls) then
        if v.Hide then
          v:Hide()
        else
          UpdateVisibility(v, false)
        end
      end
    end
  end
end

function DeepCopy(tmp)
  if nil == tmp then
    return nil
  end
  local res = {}
  for key, val in pairs(tmp) do
    if type(val) == "table" then
      res[key] = DeepCopy(val)
    else
      res[key] = val
    end
  end
  return res
end

function UpdateWidgetContainer(WidgetContainer, WidgetNumber, WidgetPath, Padding, Self, PlayerController)
  local widgetClass = UE.UClass.Load(WidgetPath)
  return UpdateWidgetContainerByClass(WidgetContainer, WidgetNumber, widgetClass, Padding, Self, PlayerController)
end

function UpdateWidgetContainerByClass(WidgetContainer, WidgetNumber, WidgetClass, Padding, Self, PlayerController)
  local tempTable = {}
  local More
  local widgets = WidgetContainer:GetAllChildren()
  for key, value in pairs(widgets) do
    value.Slot:SetPadding(Padding)
  end
  local arrayLength = widgets:Length()
  if WidgetNumber > arrayLength then
    More = true
    local widget, slot
    for i = 1, WidgetNumber - arrayLength do
      widget = UE.UWidgetBlueprintLibrary.Create(Self, WidgetClass, PlayerController)
      if widget then
        table.insert(tempTable, widget)
        slot = WidgetContainer:AddChild(widget)
        if slot then
          slot:SetPadding(Padding)
        end
      end
    end
  end
  if WidgetNumber < arrayLength then
    More = false
    for i = 1, arrayLength - WidgetNumber do
      WidgetContainer:RemoveChildAt(arrayLength - i)
    end
  end
  return More, tempTable
end

function UpdateVisibility(Widget, bIsShow, bIsVisible, bIsHidden)
  if not Widget then
    return
  end
  if not Widget:IsValid() then
    print("UpdateVisibility Widget is not valid")
    return
  end
  if bIsShow then
    if bIsVisible then
      Widget:SetVisibility(UE.ESlateVisibility.Visible)
    else
      Widget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif bIsHidden then
    Widget:SetVisibility(UE.ESlateVisibility.Hidden)
  else
    Widget:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function IsValidObj(Obj)
  if not Obj then
    return false
  end
  if not Obj:IsValid() then
    return false
  end
  if not UE.RGUtil.IsUObjectValid(Obj) then
    return false
  end
  return true
end

function SetHitTestInvisible(Widget)
  if nil == Widget or IsValidObj(Widget) == false then
    return
  end
  Widget:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end

function CheckIsVisility(Widget, bIsVisible)
  if not Widget then
    return false
  end
  if bIsVisible then
    return Widget:GetVisibility() == UE.ESlateVisibility.Visible
  else
    return Widget:GetVisibility() ~= UE.ESlateVisibility.Hidden and Widget:GetVisibility() ~= UE.ESlateVisibility.Collapsed
  end
end

function CheckCost(CostItemMap, Success, Failed, bIsShowTips, ...)
  local CostItemMapTemp = {}
  for i, v in pairs(CostItemMap) do
    local key = v.key
    local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(key)
    local ResNum = v.value
    if CostItemMapTemp[key] then
      CostItemMapTemp[key] = CostItemMapTemp[key] + ResNum
    else
      CostItemMapTemp[key] = ResNum
    end
    local ExistsNum = 0
    if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
      ExistsNum = DataMgr.GetOutsideCurrencyNumById(key)
    else
      ExistsNum = DataMgr.GetPackbackNumById(key)
    end
    if ExistsNum < CostItemMapTemp[key] then
      if bIsShowTips then
      end
      if Failed then
        Failed(...)
      end
      return false
    end
  end
  if Success then
    Success(...)
  end
  return true
end

function CheckHasBarrel(AccessoryIdList)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  for key, value in pairs(AccessoryIdList) do
    local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(tonumber(value), nil)
    if Result and AccessoryRowInfo.AccessoryType == UE.ERGAccessoryType.EAT_Barrel then
      return true, value
    end
  end
end

function GetAccessoryNumber(AccessoryIdList, ExceptBarrel)
  local Number = #AccessoryIdList
  if ExceptBarrel then
    local has, barrelId = CheckHasBarrel(AccessoryIdList)
    if has then
      return Number - 1
    end
  end
  return Number
end

function GetAccessoryRarity(AccessoryId, AccessoryList)
  for key, value in pairs(AccessoryList) do
    if AccessoryId == key then
      return value
    end
  end
end

function GetAccessoryIdTable(AccessoryList)
  local AccessoryIdTable = {}
  for key, value in pairs(AccessoryList) do
    table.insert(AccessoryIdTable, key)
  end
  return AccessoryIdTable
end

function GetInscriptionIdTable(AccessoryId, ItemRarity)
  local inscriptionIdList = {}
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(AccessoryId))
    if result then
      local findValue = accessoryData.InscriptionMap:Find(ItemRarity)
      if findValue then
        for key, value in pairs(findValue.Inscriptions) do
          table.insert(inscriptionIdList, value.InscriptionId)
        end
        return inscriptionIdList
      end
    end
  end
  return inscriptionIdList
end

function ChSize(Char)
  if not Char then
    return 0
  elseif Char > 240 then
    return 4
  elseif Char > 223 then
    return 3
  elseif Char > 192 then
    return 2
  else
    return 1
  end
end

function HaveChineseChar(Str)
  if type(Str) == "userdata" then
    Str = tostring(Str)
  end
  if Str then
    return #Str > UTF8Len(Str)
  end
  return false
end

function UTF8Len(Str)
  local Len = 0
  local CurrentIndex = 1
  while CurrentIndex <= #Str do
    local Char = string.byte(Str, CurrentIndex)
    CurrentIndex = CurrentIndex + ChSize(Char)
    Len = Len + 1
  end
  return Len
end

function ipairsUTF8(Str)
  local StartIndex = 1
  local Key = 0
  local StrTemp = Str
  return function()
    if nil == Str or 0 == #Str then
      return nil
    end
    local Char = string.byte(Str, StartIndex)
    local Len = ChSize(Char)
    if 0 == Len then
      return nil
    end
    local CurrentIndex = StartIndex + Len
    local Value = StrTemp:sub(StartIndex, CurrentIndex - 1)
    StartIndex = StartIndex + Len
    Key = Key + 1
    return Key, Value
  end
end

function Split(input, delimiter)
  if type(delimiter) == "userdata" then
    delimiter = tostring(delimiter)
  end
  if type(input) == "userdata" then
    input = tostring(input)
  end
  if type(delimiter) ~= "string" or #delimiter <= 0 then
    return
  end
  local start = 1
  local arr = {}
  while true do
    local pos = string.find(input, delimiter, start, true)
    if not pos then
      break
    end
    table.insert(arr, string.sub(input, start, pos - 1))
    start = pos + string.len(delimiter)
  end
  table.insert(arr, string.sub(input, start))
  return arr
end

function SetInputIgnore(Pawn, Ignored)
  if not Pawn then
    print("Pawn Is Null")
    return
  end
  local InputComp = Pawn:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
  if InputComp and InputComp:IsValid() then
    InputComp:ReleaseAllBindEvents()
    InputComp:SetAllInputIgnored(Ignored)
  end
end

function UpdateUICaptureBgActor(bIsShow)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    return UIManager:UpdateUICaptureBgActor(bIsShow)
  end
end

function IsInterger(n)
  return type(n) == "number" and math.floor(n) == n
end

function NearlyEquals(a, b, ThresholdParam)
  local Threshold = ThresholdParam or 1.0E-8
  local RelativeError = math.abs(a - b)
  return Threshold >= RelativeError
end

function GetVersionID()
  local VersionSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URGVersionSubsystem:StaticClass())
  if not VersionSubsystem then
    return 1
  end
  local LobbySettings = UE.URGLobbySettings.GetSettings()
  if UE.URGBlueprintLibrary.CheckWithEditor() and LobbySettings and LobbySettings.IsUseCustomVersion then
    print("UseCustomVersionId", LobbySettings.VersionId)
    return LobbySettings.VersionId
  end
  local VersionId = VersionSubsystem.BuildId
  if 0 == VersionId then
    VersionId = 1
  end
  return VersionId
end

function GetRowData(TableName, RowName)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("GetRowData not found DTSubsystem")
    return false, nil
  end
  local rowNameTemp = tostring(RowName)
  local tableNameTemp = tostring(TableName)
  local DataTableTemp = DTSubsystem:GetDataTable(tableNameTemp)
  if DataTableTemp then
    local DataRow = UE.UDataTableFunctionLibrary.GetRowDataStructure(DataTableTemp, rowNameTemp)
    if DataRow then
      return true, DataRow
    end
  else
    print("GetRowData not found Table, TableName:", tableNameTemp)
  end
  return false, nil
end

function GetAllRowNames(TableName)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local DataTableTemp = DTSubsystem:GetDataTable(TableName)
  if not DataTableTemp then
    return {}
  end
  local AllRowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(DataTableTemp, nil)
  return AllRowNames:ToTable()
end

function GetRowDataForCharacter(RowName)
  if tonumber(RowName) > 100000 then
    return GetRowData(DT.DT_Monster, RowName)
  else
    return GetRowData(DT.DT_Hero, RowName)
  end
end

function GetLuaInscription(InscriptionID)
  local Path = "GameConfig.Inscription.Ins_" .. InscriptionID
  if Path then
    local success, result = pcall(require, Path)
    if not success then
      print("GetLuaInscription Failed to load module: " .. result)
      return nil
    else
      return result
    end
  end
  return nil
end

function GetLuaInscriptionDesc(InscriptionID)
  local name = InscriptionID .. "_Desc"
  return UE.URGBlueprintLibrary.TextFromInsStringTable(name)
end

function GetLuaInsModifyLevelDescFmt(InscriptionID)
  local name = InscriptionID .. "_ModifyLevelDescFmt"
  return UE.URGBlueprintLibrary.TextFromInsStringTable(name)
end

function GetInscriptionName(InscriptionId)
  local name = InscriptionId .. "_Name"
  return UE.URGBlueprintLibrary.TextFromInsStringTable(name)
end

function ExtractStringsBetweenBraces(inputString)
  local result = {}
  local insideBraces = false
  local currentString = ""
  inputString = tostring(inputString)
  for char in inputString:gmatch(".") do
    if "{" == char then
      insideBraces = true
      currentString = ""
    elseif "}" == char and insideBraces then
      insideBraces = false
      table.insert(result, currentString)
    elseif insideBraces then
      currentString = currentString .. char
    end
  end
  return result
end

function StrReplace(inputString, target, replacement)
  local inputString = tostring(inputString)
  local target = tostring(target)
  local replacement = tostring(replacement)
  return inputString:gsub(target, replacement)
end

function LerpVector(Current, Target, rate)
  local x = (Target.X - Current.X) * rate + Current.X
  local y = (Target.Y - Current.Y) * rate + Current.Y
  local z = (Target.Z - Current.Z) * rate + Current.Z
  return UE.FVector(x, y, z)
end

function LerpRotation(Current, Target, rate)
  return Current + (Target - Current) * rate
end

function LerpTransform(Current, Target, rate)
  local translation = LerpVector(Current.Translation, Target.Translation, rate)
  local scale3D = LerpVector(Current.Scale3D, Target.Scale3D, rate)
  local rotation = LerpRotation(Current.Rotation, Target.Rotation, rate)
  return UE.FTransform(rotation, translation, scale3D)
end

function GetStringById(Id, TextWidget)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return false, nil
  end
  local DataRow = DTSubsystem:GetStringTableConfigById(Id, nil)
  if DataRow then
    if TextWidget then
      TextWidget:Settext(DataRow.Text)
    end
    return DataRow.Text
  end
  return Id
end

function ChangeToLobbyAnimCamera()
  local AllMainAnimCamera = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "MainAnimCamera", nil)
  local TargetAnimCamera
  for key, SingleAnimCamera in pairs(AllMainAnimCamera) do
    TargetAnimCamera = SingleAnimCamera
    break
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if PC then
    local CurViewTarget = PC:GetViewTarget()
    if TargetAnimCamera and CurViewTarget ~= TargetAnimCamera then
      print("ChangeToLobbyMainAnimaCamera")
      PC:SetViewTargetWithBlend(TargetAnimCamera)
      EventSystem.Invoke(EventDef.Lobby.OnCameraTargetChangedToLobbyAnimCamera)
    end
  end
end

function GetResourceConfig(ResourceId)
  local TableName = TableNames.TBGeneral
  local ResourceInfo = LuaTableMgr.GetLuaTableByName(TableName)
  if ResourceInfo[ResourceId] then
    return ResourceInfo[ResourceId]
  end
  print("GetResourceConfig ", ResourceId, ResourceInfo[ResourceId])
  return nil
end

function NumToTxt(num)
  return NumToTxtTb[num]() or ""
end

function NumToRoman(num)
  return NumToRomanTb[num] or ""
end

function CompareStringsIgnoreCase(str1, str2)
  return string.lower(str1) == string.lower(str2)
end

function CheckAndShowTipsSysUnlock(ViewName, bNotShowTips)
  local bShowTips = not bNotShowTips
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsViewUnlock(ViewName) then
    if bShowTips then
      ShowWaveWindow(1401)
    end
    return false
  end
  return true
end

function CheckAndShowTipsSysUnlockBySysId(SystemId, bNotShowTips)
  local bShowTips = not bNotShowTips
  if SystemId < 0 then
    return true
  end
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(SystemId) then
    if bShowTips then
      local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemUnlock, SystemId)
      if result and CheckNSLocTbIsValid(row.UnlockTips) then
        ShowWaveWindow(1407, {
          row.UnlockTips
        })
      else
        ShowWaveWindow(1401)
      end
    end
    return false
  end
  return true
end

function ComLinkForParam(ComLinkRowName, Callback, ParamList, ExtraData)
  if "1015" == ComLinkRowName then
    ComLink(ComLinkRowName, Callback, ExtraData.HeroId, ParamList)
  elseif "1016" == ComLinkRowName then
    ComLink(ComLinkRowName, Callback, ExtraData.HeroId, ParamList)
  elseif "1008" == ComLinkRowName then
    ComLink(ComLinkRowName, Callback, ParamList[1], ParamList[2], ParamList[3])
  elseif "9999" == ComLinkRowName then
    if Callback then
      Callback()
    end
    PandoraHandler.GoPandoraActivity(ParamList[1], "ComLinkSkip")
  else
    ComLink(ComLinkRowName, Callback, ParamList)
  end
end

function ComLink(ComLinkRowName, Callback, ...)
  local result, row = GetRowData(DT.DT_CommonLink, ComLinkRowName)
  if not result then
    print("ComLink ComLinkRowName Is InValid", ComLinkRowName)
    return
  end
  if not CheckAndShowTipsSysUnlockBySysId(row.SystemId) then
    return false
  end
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  local systemOpenID = SystemOpenID[row.SystemOpenID]
  if systemOpenID and SystemOpenMgr and SystemOpenMgr:IsSystemOpen(systemOpenID, true) == false then
    return false
  end
  if row.ComLinkType == UE.EComLink.LinkToView then
    if ViewID[row.UIName] then
      if not CheckAndShowTipsSysUnlock(row.UIName) then
        return false
      end
      if Callback then
        Callback()
      end
      UIMgr:ShowLink(ViewID[row.UIName], row.bHideOther, row.LinkParams, ...)
      return true
    else
      if not CheckAndShowTipsSysUnlock(row.UIName) then
        return false
      end
      if Callback then
        Callback()
      end
      RGUIMgr:OpenUILink(row.UIName, row.bHideOther, row.Layer, row.LinkParams, ...)
      return true
    end
  else
    if row.ComLinkType == UE.EComLink.LinkToLobbyToggle then
      if Callback then
        Callback()
      end
      LogicLobby.ChangeLobbyPanelLabelSelected(row.LabelName, row, ...)
      return true
    else
    end
  end
end

function CommonLinkEx(ViewId, ComLinkRowName, Callback, ...)
  local result, row = GetRowData(DT.DT_CommonLink, ComLinkRowName)
  if not result then
    print("ComLink ComLinkRowName Is InValid", ComLinkRowName)
    return
  end
  if not CheckAndShowTipsSysUnlockBySysId(row.SystemId) then
    return false
  end
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  local systemOpenID = SystemOpenID[row.SystemOpenID]
  if systemOpenID and SystemOpenMgr and SystemOpenMgr:IsSystemOpen(systemOpenID, true) == false then
    return false
  end
  if ViewId and row.ComLinkType == UE.EComLink.LinkToLobbyToggle then
    UIMgr:Hide(ViewId)
  end
  return ComLink(ComLinkRowName, Callback, ...)
end

function SetLobbyPanelCurrencyList(IsShow, CurrencyIds)
  local LobbyPanelObj = UIMgr:GetLuaFromActiveView(ViewID.UI_LobbyPanel)
  if not LobbyPanelObj then
    return
  end
  UpdateVisibility(LobbyPanelObj.WBP_LobbyCurrencyList, IsShow)
  if CurrencyIds and #CurrencyIds > 0 then
    LobbyPanelObj.WBP_LobbyCurrencyList:ClearListContainer()
    LobbyPanelObj.WBP_LobbyCurrencyList:SetCurrencyList(CurrencyIds)
  end
end

function GetCurrentUTCTimestamp()
  return UE.URGStatisticsLibrary.GetUTCTimestamp()
end

function GetCurrentTimestamp(IsUTC)
  if IsUTC then
    return UE.URGStatisticsLibrary.GetUTCTimestamp()
  else
    return UE.URGStatisticsLibrary.GetTimestamp()
  end
end

function ListenForInputAction(ActionName, EventType, bConsume, Callback, ...)
  local Suffix = "Press"
  if EventType == UE.EInputEvent.IE_Released then
    Suffix = "Release"
  end
  ActionName = "InputTag." .. ActionName .. "." .. Suffix
  local GameplayTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(ActionName, nil)
  if not UE.UBlueprintGameplayTagLibrary.IsGameplayTagValid(GameplayTag) then
    printWarn("ListenForInputAction Invalid GameplayTag, TagName:", ActionName)
    return
  end
  local Widget = Callback[1]
  if nil == Widget then
    print("ListenForInputAction : #1 Widget is nil")
    return
  end
  Widget:ListenForEnhancedInputActionTag(GameplayTag, UE.ETriggerEvent.Triggered, bConsume, Callback)
end

function IsListeningForInputAction(Widget, ActionName, EventType)
  if not ActionName then
    return false
  end
  local Suffix = "Press"
  if EventType and EventType == UE.EInputEvent.IE_Released then
    Suffix = "Release"
  end
  ActionName = "InputTag." .. ActionName .. "." .. Suffix
  local GameplayTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(ActionName, nil)
  if not UE.UBlueprintGameplayTagLibrary.IsGameplayTagValid(GameplayTag) then
    print("ListenForInputAction Invalid GameplayTag, TagName:", ActionName)
    return
  end
  return Widget:IsListeningForEnhancedInputActionTag(GameplayTag)
end

function StopListeningForInputAction(Widget, ActionName, EventType)
  if not ActionName then
    return false
  end
  local Suffix = "Press"
  if EventType and EventType == UE.EInputEvent.IE_Released then
    Suffix = "Release"
  end
  ActionName = "InputTag." .. ActionName .. "." .. Suffix
  local GameplayTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(ActionName, nil)
  if not UE.UBlueprintGameplayTagLibrary.IsGameplayTagValid(GameplayTag) then
    print("ListenForInputAction Invalid GameplayTag, TagName:", ActionName)
    return
  end
  Widget:StopListeningForEnhancedInputActionTag(GameplayTag, UE.ETriggerEvent.Triggered)
end

local str_format = string.format

function string.format(s, ...)
  local params = {}
  for i, v in ipairs({
    ...
  }) do
    if type(v) == "userdata" then
      table.insert(params, tostring(v))
    else
      table.insert(params, v)
    end
  end
  if type(s) == "userdata" then
    s = tostring(s)
  end
  local success, result = pcall(str_format, s, table.unpack(params))
  if success then
    return result
  else
    UnLua.LogError("string.format Failed: " .. result)
    return ""
  end
end

local print_custom = print

function print(...)
  local params = {}
  for i, v in ipairs({
    ...
  }) do
    if type(v) == "userdata" then
      table.insert(params, tostring(v))
    else
      table.insert(params, v)
    end
  end
  return print_custom(table.unpack(params))
end

function IteratorCorrectJsonParams(JsonParams)
  if type(JsonParams) ~= "table" then
    return JsonParams
  end
  local tb = {}
  for k, v in pairs(JsonParams) do
    if type(v) == "userdata" then
      tb[k] = tostring(v)
    elseif type(v) == "table" then
      tb[k] = IteratorCorrectJsonParams(v)
    else
      tb[k] = v
    end
  end
  return tb
end

function RapidJsonEncode(JsonParams)
  local JsonParamsCorrect = IteratorCorrectJsonParams(JsonParams)
  local rapidjson = require("rapidjson")
  return rapidjson.encode(JsonParamsCorrect)
end

local tonumber_custom = tonumber

function tonumber(target, Base)
  if type(target) == "userdata" then
    target = tostring(target)
  end
  return tonumber_custom(target, Base)
end

function LinkPurchaseConfirm(LinkId, ParamList)
  if tonumber(LinkId) ~= 1007 then
    return false
  end
  ComLink(LinkId, ParamList[2], ParamList[1], 1)
  return true
end

function ChangeLobbyCamera(Outer, RowName, BlendTimeParam, BlendExpParam)
  local BlendTime = BlendTimeParam or 0
  local BlendExp = BlendExpParam or 0
  UE.URGBlueprintLibrary.ChangeLobbyCamera(Outer, RowName, BlendTime, BlendExp)
  LogicRole.ChangeRoleMainTransform(RowName)
end

function GetCurSceneStatus()
  local world = GameInstance:GetWorld()
  local PC = UE.UGameplayStatics.GetPlayerController(world, 0)
  if PC and PC.GetCurSceneStatus then
    return PC:GetCurSceneStatus()
  end
  return UE.ESceneStatus.None
end

function GetViewNameByViewId(_ViewId)
  for k, v in pairs(ViewID) do
    if v == _ViewId then
      return k
    end
  end
  return nil
end

function GetLuaInscriptionByID(InscriptionID)
  local Path = "Ins_" .. InscriptionID
  if Path then
    return require(Path)
  end
  return nil
end

function CalcTartUnixTimeStamp(Hour)
  local current_time = os.time()
  local current_date = os.date("*t", current_time)
  local target_hour_today = {
    year = current_date.year,
    month = current_date.month,
    day = current_date.day,
    hour = Hour,
    min = 0,
    sec = 0
  }
  local target_hour_tomorrow = {
    year = current_date.year,
    month = current_date.month,
    day = current_date.day + 1,
    hour = 5,
    min = 0,
    sec = 0
  }
  local target_today_timestamp = os.time(target_hour_today)
  local result_timestamp
  if current_time < target_today_timestamp then
    result_timestamp = target_today_timestamp
  else
    result_timestamp = os.time(target_hour_tomorrow)
  end
  return result_timestamp
end

function GetNextWeeklyRefreshTimeStamp(Hour, WeekDay)
  local current_time = os.time()
  local current_date = os.date("*t", current_time)
  local next_monday = (8 + WeekDay - current_date.wday) % 7
  if 0 == next_monday then
    next_monday = 7
  end
  local target_hour_nextweekly = {
    year = current_date.year,
    month = current_date.month,
    day = current_date.day + next_monday,
    hour = Hour,
    min = 0,
    sec = 0
  }
  local result_timestamp = os.time(target_hour_nextweekly) - current_time
  if result_timestamp > 604800 then
    result_timestamp = result_timestamp - 604800
  end
  return result_timestamp
end

function GetNextMonthRefreshTimeStamp(Hour, MonthDay)
  if nil == Hour then
    Hour = 5
  end
  if nil == MonthDay then
    MonthDay = 1
  end
  local current_time = os.time()
  local current_date = os.date("*t", current_time)
  local nextMonth = current_date.month + 1
  local nextYear = current_date.year
  if nextMonth > 12 then
    nextMonth = 1
    nextYear = nextYear + 1
  end
  local nextMonthFirstDay = {
    year = nextYear,
    month = nextMonth,
    day = 1,
    hour = 5,
    min = 0,
    sec = 0,
    isdst = false
  }
  local result_timestamp = os.time(nextMonthFirstDay) - current_time
  return result_timestamp
end

local gammaToLinear = function(color)
  if color <= 0.04045 then
    return color / 12.92
  else
    return ((color + 0.055) / 1.055) ^ 2.4
  end
end

function HexToFLinearColor(hex)
  if type(hex) ~= "string" then
    error("Invalid hex color, must be a string.")
  end
  if hex:sub(1, 1) == "#" then
    hex = hex:sub(2)
  end
  if 6 ~= #hex and 8 ~= #hex then
    return UE.FLinearColor(1, 1, 1, 1)
  end
  local r = gammaToLinear(tonumber(hex:sub(1, 2), 16) / 255)
  local g = gammaToLinear(tonumber(hex:sub(3, 4), 16) / 255)
  local b = gammaToLinear(tonumber(hex:sub(5, 6), 16) / 255)
  local a = 1
  if 8 == #hex then
    a = tonumber(hex:sub(7, 8), 16) / 255
  end
  return UE.FLinearColor(r, g, b, a)
end

function DelayPlayAnimation(Target, AniName, DelayTime)
  if not Target then
    return nil
  end
  if not Target[AniName] then
    return nil
  end
  if DelayTime <= 0 then
    Target:PlayAnimation(Target[AniName], 0, 1)
    return nil
  end
  local delayTimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    Target,
    function()
      Target:PlayAnimation(Target[AniName], 0, 1)
    end
  }, DelayTime, false)
  return delayTimerHandle
end

function UrlEncode(str)
  if str then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

function GetTbSkinRowNameBySkinID(SkinID)
  return tonumber("10" .. tostring(SkinID))
end

function SetInputMode_GameAndUIEx(PC, InWidgetToFocus, InMouseLockMode, bHideCursorDuringCapture)
  local widgetName = ""
  if InWidgetToFocus then
    widgetName = InWidgetToFocus:GetName()
  end
  print("LuaCommon SetInputMode_GameAndUIEx", widgetName, InMouseLockMode, bHideCursorDuringCapture)
  UE.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(PC, InWidgetToFocus, InMouseLockMode, bHideCursorDuringCapture)
end

function GetCurInputType()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    return CommonInputSubsystem:GetCurrentInputType()
  end
  return nil
end

function RandomListByWeight(Values, Weights)
  assert(#Values == #Weights)
  local tinsert = table.insert
  local Count = #Weights
  local Sum = 0
  for i, SingleWeight in ipairs(Weights) do
    Sum = Sum + SingleWeight
  end
  local Avg = Sum / Count
  local Aliases = {}
  for index, value in ipairs(Weights) do
    tinsert(Aliases, {1, false})
  end
  local Sidx = 1
  while Count >= Sidx and Avg <= Weights[Sidx] do
    Sidx = Sidx + 1
  end
  if Count >= Sidx then
    local Small = {
      Sidx,
      Weights[Sidx] / Avg
    }
    local Bidx = 1
    while Count >= Bidx and Avg > Weights[Bidx] do
      Bidx = Bidx + 1
    end
    local Big = {
      Bidx,
      Weights[Bidx] / Avg
    }
    while true do
      Aliases[Small[1]] = {
        Small[2],
        Big[1]
      }
      Big = {
        Big[1],
        Big[2] - (1 - Small[2])
      }
      if Big[2] < 1 then
        Small = Big
        Bidx = Bidx + 1
        while Count >= Bidx and Avg > Weights[Bidx] do
          Bidx = Bidx + 1
        end
        if Count < Bidx then
          break
        end
        Big = {
          Bidx,
          Weights[Bidx] / Avg
        }
      else
        Sidx = Sidx + 1
        while Count >= Sidx and Avg <= Weights[Sidx] do
          Sidx = Sidx + 1
        end
        if Count < Sidx then
          break
        end
        Small = {
          Sidx,
          Weights[Sidx] / Avg
        }
      end
    end
  end
  local n = math.random() * Count
  local i = math.floor(n)
  local odds, alias = Aliases[i + 1][1], Aliases[i + 1][2]
  local idx
  if odds < n - i then
    idx = alias
  else
    idx = i + 1
  end
  return Values[idx], Weights[idx]
end

function GetCustomZOrderByLayer(CustomLayerParam)
  if CustomLayerParam == UE.ECustomLayer.ELayer_None then
    return -1
  end
  return CustomLayerParam * 100000
end

function SetGroundLevelByViewID(ViewId)
  if 1 == LogicLobby.FliterShowGroundViewList[ViewId] then
    return
  end
  local result, row = GetRowData(DT.DT_GroundConfig, ViewId)
  if result and row.IsShowGround then
    LogicLobby.ShowOrHideGround(true)
  else
    LogicLobby.ShowOrHideGround(false)
  end
end

function LuaAddClickStatistics(EventName)
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    print("LuaAddClickStatistics", EventName)
    UserClickStatisticsMgr:AddClickStatistics(EventName)
  end
end

function GetTimeUntilTarget(Day, Hour)
  local nowTimeZone = GetLocalTimestampByServerTimeZone()
  local current = os.date("*t", nowTimeZone)
  local days_until_target = (Day - current.wday + 7) % 7
  if 0 == days_until_target and Hour <= current.hour then
    days_until_target = 7
  end
  local target = {
    year = current.year,
    month = current.month,
    day = current.day + days_until_target,
    hour = Hour,
    min = 0,
    sec = 0
  }
  local target_time = os.time(target)
  local diff = target_time - nowTimeZone
  if diff < 0 then
    return 0, 0
  end
  local days = math.floor(diff / 86400)
  local hours = math.floor(diff % 86400 / 3600)
  return days, hours
end

function CheckIsChannelCommunicateAllowed(ChannelUserID)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
  if PrivacySubSystem then
    ChannelUserID = ChannelUserID or DataMgr.GetChannelUserId()
    if "" ~= ChannelUserID then
      local IsAllowed = PrivacySubSystem:IsCommunicateUsingTextOrVoiceAllowed(ChannelUserID, false)
      if IsAllowed == UE.EPermissionsResult.denied then
        return false
      end
    end
  end
  return true
end

function CheckIsInNormal(ModeId)
  local SeasonModule = ModuleManager:Get("SeasonModule")
  if SeasonModule then
    return SeasonModule:CheckIsInNormal(ModeId)
  end
  return false
end

function GetCurNormalMode()
  local SeasonModule = ModuleManager:Get("SeasonModule")
  if SeasonModule then
    return SeasonModule:GetCurNormalMode()
  end
  return TableEnums.ENUMGameMode.NORMAL
end

function GetLuaConstValueByKey(Key)
  local constsTb = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  if constsTb then
    return constsTb[Key]
  end
  return nil
end

function CheckNSLocTbIsValid(NSLocTb)
  if not NSLocTb then
    return false
  end
  if tostring(NSLocTb) == "" then
    return false
  end
  return true
end

function MakeGameplayAttributeByName(InAttributeName)
  local Result, LeftName, RightName = UE.UKismetStringLibrary.Split(InAttributeName, ".", nil, nil)
  if Result then
    local clsName = "U" .. LeftName
    if UE[clsName] then
      local class = UE[clsName].StaticClass()
      return UE.URGBlueprintLibrary.MakeGameplayAttributeByNameFromUClass(InAttributeName, class)
    end
  end
  return nil
end

function LerpColor(startColor, endColor, alpha)
  local Result = UE.FLinearColor()
  Result.R = startColor.R + (endColor.R - startColor.R) * alpha
  Result.G = startColor.G + (endColor.G - startColor.G) * alpha
  Result.B = startColor.B + (endColor.B - startColor.B) * alpha
  Result.A = startColor.A + (endColor.A - startColor.A) * alpha
  return Result
end

function OpenPandorApp(AppId, Souce)
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  PandorSubsystem:OpenApp(AppId, Souce)
end

function ClosePandorApp(AppId)
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  if PandorSubsystem then
    PandorSubsystem:CloseApp(AppId)
  end
end

function FindAndShowActorList(TagName)
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, TagName, nil)
  if not AllActors then
    return
  end
  for _, ActorInst in pairs(AllActors) do
    if IsValidObj(ActorInst) and ActorInst.ActorAry then
      print("FindAndShowActorList ", ActorInst:GetName())
      for _, ActorRefInst in pairs(ActorInst.ActorAry) do
        if IsValidObj(ActorRefInst) then
          print("FindAndShowActorList ActorRef", ActorRefInst:GetName())
          ActorRefInst:SetActorHiddenInGame(false)
        end
      end
    end
  end
end

function FindAndHideActorList(TagName)
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, TagName, nil)
  if not AllActors then
    return
  end
  for _, ActorInst in pairs(AllActors) do
    if IsValidObj(ActorInst) and ActorInst.ActorAry then
      print("FindAndHideActorList ", ActorInst:GetName())
      for _, ActorRefInst in pairs(ActorInst.ActorAry) do
        if IsValidObj(ActorRefInst) then
          print("FindAndHideActorList ActorRef", ActorRefInst:GetName())
          ActorRefInst:SetActorHiddenInGame(true)
        end
      end
    end
  end
end

function IsNewMonth(InputTimestamp, CurTimestamp)
  local CurrentTimestamp = CurTimestamp or os.time()
  local InputData = os.date("*t", InputTimestamp)
  local CurrentData = os.date("*t", CurrentTimestamp)
  if InputData.year ~= CurrentData.year or InputData.month ~= CurrentData.month then
    return true
  else
    return false
  end
end

function GetRegionId()
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if RGAccountSubsystem then
    return RGAccountSubsystem:GetRegion()
  else
    return nil
  end
end

function GetAdultCheckStatus()
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if RGAccountSubsystem then
    return RGAccountSubsystem:GetAdultCheckStatus()
  else
    return nil
  end
end

function IsPlayerAdult()
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if not RGAccountSubsystem then
    return false
  end
  local AdultCheckStatus = RGAccountSubsystem:GetAdultCheckStatus()
  if UE.URGBlueprintLibrary.IsOfficialPackage() then
    return 3 == AdultCheckStatus
  else
    return 1 == AdultCheckStatus
  end
end

function SetExpireAtColor(Image, ExpireAt)
  if nil ~= ExpireAt and "" ~= ExpireAt and "0" ~= ExpireAt then
    local ErrorColor = UE.FLinearColor(0.772549, 0.239216, 0.290196, 1.0)
    local currentTime = os.time()
    if tonumber(ExpireAt) - currentTime < 90000 then
      Image:SetColorAndOpacity(ErrorColor)
    else
      Image:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 1))
    end
  else
    Image:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 1))
  end
  UpdateVisibility(Image, nil ~= ExpireAt and "" ~= ExpireAt and "0" ~= ExpireAt)
end

function ComInitProEff(ItemID, TargetWidget)
  if not IsValidObj(TargetWidget) then
    return
  end
  local ItemId = tonumber(ItemID)
  if not ItemId or ItemId <= 0 then
    print("ComInitProEff Invalid ItemId:", ItemId)
    return
  end
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    UpdateVisibility(TargetWidget, false)
    return
  end
  if Row.ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(TargetWidget, false)
    return
  end
  UpdateVisibility(TargetWidget, true)
  if IsValidObj(TargetWidget) and IsValidObj(TargetWidget.ChildWidget) and TargetWidget.ChildWidget.InitComProEff then
    TargetWidget.ChildWidget:InitComProEff(ItemId)
  elseif IsValidObj(TargetWidget) and TargetWidget.InitComProEff then
    TargetWidget:InitComProEff(ItemId)
  end
end

function ConvertISOCountryCodeToAlpha2Code(CountryCode)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBISOCountryCode, tonumber(CountryCode))
  return Result and RowInfo.Alpha_2 or ""
end
