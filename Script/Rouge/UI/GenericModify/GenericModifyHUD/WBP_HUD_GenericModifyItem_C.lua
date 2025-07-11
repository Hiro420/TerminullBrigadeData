local WBP_HUD_GenericModifyItem_C = UnLua.Class()
local GenericModifyConfig = require("GameConfig.GenericModify.GenericModifyConfig")
function WBP_HUD_GenericModifyItem_C:Construct()
  if self.BP_ButtonWithSoundSelect then
    self.BP_ButtonWithSoundSelect.OnClicked:Add(self, self.SelectClick)
  end
  self.RemainTime = -1
  self.TotalTime = -1
  self.GenericModifyFXWidgetList = {}
  EventSystem.AddListener(self, EventDef.Inscription.OnTriggerCD, self.BindOnClientUpdateInscriptionCD)
end
function WBP_HUD_GenericModifyItem_C:BindOnClientUpdateInscriptionCD(InscriptionId, RemainTime)
  local DataAssest = GetLuaInscription(InscriptionId)
  if not DataAssest then
    return
  end
  if not DataAssest.InscriptionCDData.bIsShowCD then
    print(InscriptionId, "\228\184\141\230\152\190\231\164\186")
    return
  end
  local ModifyInscriptionId = self:GetInscriptionId(self.ModifyData)
  if self.ModifyData and ModifyInscriptionId == InscriptionId then
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    local InscriptionDA = RGLogicCommandDataSubsystem:GetInscriptionDAByID(InscriptionId)
    if IsValidObj(InscriptionDA) and InscriptionDA.InscriptionDataAry:IsValidIndex(1) then
      self.CoolDownTag = UE.UBlueprintGameplayTagLibrary.MakeGameplayTagContainerFromArray({
        InscriptionDA.InscriptionDataAry:GetRef(1).CoolDownTag
      })
    end
    self:StartCD(RemainTime, RemainTime)
  end
end
function WBP_HUD_GenericModifyItem_C:UpdateCD(InDeltaTime)
  local bGetRemainTimeImmediately = false
  if self.CoolDownTag then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if Character then
      local result, remainTime, duration = UE.URGBlueprintLibrary.Lib_GetCooldownRemainingForTag(Character, self.CoolDownTag, nil, nil)
      if result then
        self.RemainTime = remainTime
        bGetRemainTimeImmediately = true
      end
    end
  end
  if self.RemainTime > 0 then
    if not self.bIsVolatile then
      self:ForceVolatile(true)
    end
    if not bGetRemainTimeImmediately then
      self.RemainTime = self.RemainTime - InDeltaTime
    end
    self.URGImageCD:SetClippingValue(self.RemainTime / self.TotalTime)
  else
    if self.bIsVolatile then
      self:ForceVolatile(false)
    end
    self.RemainTime = -1
    self.TotalTime = 0
    self.URGImageCD:SetClippingValue(0)
    self.CoolDownTag = nil
  end
  if self.GenericModifySlot and self.GenericModifySlot == UE.ERGGenericModifySlot.SLOT_Assistance then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if Character then
      local Result, TimeRemaining, Cooldownduration = UE.URGBlueprintLibrary.GetCooldownRemainingForTag(Character, self.CooldownTagContainer, nil, nil)
      if Result then
        local Percent = 0
        if Cooldownduration > 0 then
          if not self.bIsVolatile then
            self:ForceVolatile(true)
          end
          Percent = 1 - (Cooldownduration - TimeRemaining) / Cooldownduration
          self.URGImageCD:SetClippingValue(Percent)
        elseif self.bIsVolatile then
          self:ForceVolatile(false)
        end
      end
    end
  end
end
function WBP_HUD_GenericModifyItem_C:StartCD(RemainTime, TotalTime)
  self.URGImageCD:SetClippingValue(RemainTime / TotalTime)
  self.RemainTime = RemainTime
  self.TotalTime = TotalTime
end
function WBP_HUD_GenericModifyItem_C:StopCD()
  self.URGImageCD:SetClippingValue(0)
  self.RemainTime = -1
  self.TotalTime = -1
end
function WBP_HUD_GenericModifyItem_C:InitHudGenericModifyItem(ModifyData, GenericModifySlot, UpdateGenericModifyTipsFunc, ParentView, bIsFromHud, PassiveModifyNum, SelectClick, IsShowAll)
  UpdateVisibility(self, true, true)
  if self.ModifyData ~= nil and nil ~= ModifyData and self.ModifyData.Inscription ~= ModifyData.Inscription then
    self:StopCD()
  end
  self.GenericModifySlot = GenericModifySlot
  self.UpdateGenericModifyTipsFunc = UpdateGenericModifyTipsFunc
  self.ParentView = ParentView
  self.ModifyData = ModifyData
  self.SpecificModifyData = nil
  self.ModData = nil
  self.SelectClickFunc = nil
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if ModifyData then
    self.WBP_GenericModifyItem:InitGenericModifyItem(ModifyData.ModifyId, false)
    local LevelStr = string.format("%d", ModifyData.Level)
    if bIsFromHud then
      self.RGTextLv:SetText(LevelStr)
      UpdateVisibility(self.RGTextLv, ModifyData.Level > 1)
      UpdateVisibility(self.ImageLvBg, ModifyData.Level > 1)
    else
      UpdateVisibility(self.RGTextLv, false)
      UpdateVisibility(self.ImageLvBg, false)
    end
    if GenericModifySlot == UE.ERGGenericModifySlot.SLOT_Assistance then
    else
      local ModifyInscriptionId = self:GetInscriptionId(ModifyData)
      if LogicGenericModify.InscriptionCDDatas and LogicGenericModify.InscriptionCDDatas[ModifyInscriptionId] then
        local StartTime = LogicGenericModify.InscriptionCDDatas[ModifyInscriptionId].StartTime
        local RemainTime = LogicGenericModify.InscriptionCDDatas[ModifyInscriptionId].RemainTime
        local GS = UE.UGameplayStatics.GetGameState(self)
        local NowTime = GS:GetServerWorldTimeSeconds()
        if NowTime < StartTime + RemainTime then
          self:StartCD(RemainTime - NowTime + StartTime, RemainTime)
        end
      end
    end
  else
    self.WBP_GenericModifyItem:InitGenericModifyItem(-1, false)
    print("WBP_HUD_GenericModifyItem_C:InitHudGenericModifyItem() GenericModifySlot:", GenericModifySlot)
    local SpriteIconPath = GenericModifyConfig.GenericModifySlotToSpritePath[GenericModifySlot]
    if SpriteIconPath then
      SetImageBrushByPath(self.URGImageNullIcon, SpriteIconPath)
    end
    UpdateVisibility(self.RGTextLv, false)
    UpdateVisibility(self.ImageLvBg, false)
  end
  self.RGTextName:SetText(GenericModifySlotDesc[GenericModifySlot]())
  UpdateVisibility(self.WBP_GenericModifyItem, ModifyData)
  UpdateVisibility(self.RGTextName, not IsShowAll)
  UpdateVisibility(self.URGImageNullBg, not ModifyData)
  UpdateVisibility(self.URGImageNullIcon, not ModifyData)
  if GenericModifySlot == UE.ERGGenericModifySlot.None then
    if PassiveModifyNum and PassiveModifyNum > 1 then
      local TextDes = "+" .. PassiveModifyNum
      if ModifyData then
        self.RGTextNumHaveModify:SetText(TextDes)
        UpdateVisibility(self.RGTextNum, false)
        UpdateVisibility(self.RGTextNumHaveModify, bIsFromHud)
      else
        self.RGTextNum:SetText(TextDes)
        UpdateVisibility(self.RGTextNum, bIsFromHud)
        UpdateVisibility(self.RGTextNumHaveModify, false)
      end
      self.SelectClickFunc = SelectClick
    else
      UpdateVisibility(self.RGTextNum, false)
      UpdateVisibility(self.RGTextNumHaveModify, false)
    end
  else
    UpdateVisibility(self.RGTextNum, false)
    UpdateVisibility(self.RGTextNumHaveModify, false)
  end
end
function WBP_HUD_GenericModifyItem_C:PlayAcquireAnim(IsFirst)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local TargetItem
  local WidgetPath = UE.FSoftClassPath()
  if self.SpecificModifyData then
    if IsFirst then
      WidgetPath = self.SpecificModifyFirstFXWidgetPath
    else
      WidgetPath = self.SpecificModifyNonFirstFXWidgetPath
    end
  elseif self.ModData then
    if IsFirst then
      WidgetPath = self.UpgradeFirstFXWidgetPath
    else
      WidgetPath = self.UpgradeNonFirstFXWidgetPath
    end
  else
    local Result, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(self.ModifyData.ModifyId), nil)
    if not Result then
      return
    end
    local BResult, GroupRowInfo = GetRowData(DT.DT_GenericModifyGroup, GenericModifyRow.GroupId)
    if not BResult then
      print("WBP_HUD_GenericModifyItem_C:PlayAcquireAnim not found ModifyGroup RowInfo, ", GenericModifyRow.GroupId)
      return
    end
    if IsFirst then
      WidgetPath = GroupRowInfo.FirstAcquireFXWidgetPath
    else
      WidgetPath = GroupRowInfo.NonFirstAcquireFXWidgetPath
    end
  end
  TargetItem = self:GetAcquireFXItemByPath(WidgetPath)
  if TargetItem and TargetItem.ani_HUD_GenericModifyItem then
    TargetItem:PlayAnimationForward(TargetItem.ani_HUD_GenericModifyItem)
  end
end
function WBP_HUD_GenericModifyItem_C:GetAcquireFXItemByPath(Path)
  if self.GenericModifyFXWidgetList == nil then
    self.GenericModifyFXWidgetList = {}
  end
  local TargetWidgetClassPath = Path
  local WidgetClassStr = UE.UKismetSystemLibrary.BreakSoftClassPath(TargetWidgetClassPath)
  local TargetItem = self.GenericModifyFXWidgetList[WidgetClassStr]
  if not TargetItem and UE.URGBlueprintLibrary.IsValidSoftObjectPath(TargetWidgetClassPath) then
    local WidgetClass = UE.URGAssetManager.GetAssetByPath(TargetWidgetClassPath, true)
    TargetItem = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
    local Slot = self.AcquireFXPanel:AddChild(TargetItem)
    Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
    Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
    self.GenericModifyFXWidgetList[WidgetClassStr] = TargetItem
  end
  return TargetItem
end
function WBP_HUD_GenericModifyItem_C:GetInscriptionId(ModifyData)
  if not ModifyData then
    return -1
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return -1
  end
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(ModifyData.ModifyId), nil)
  if ResultGenericModify then
    return GenericModifyRow.Inscription
  end
  return -1
end
function WBP_HUD_GenericModifyItem_C:InitHudSpecificModifyItem(SpecificModifyData, GenericModifySlot, UpdateGenericModifyTipsFunc, ParentView, bIsFromHud, PassiveModifyNum, SelectClick, IsShowAll)
  UpdateVisibility(self, true, true)
  self.UpdateGenericModifyTipsFunc = UpdateGenericModifyTipsFunc
  self.ParentView = ParentView
  self.SpecificModifyData = SpecificModifyData
  self.ModifyData = nil
  self.ModData = nil
  self.SelectClickFunc = nil
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if SpecificModifyData then
    self.WBP_GenericModifyItem:InitSpecificModifyItem(SpecificModifyData.ModifyId, false)
  else
    self.WBP_GenericModifyItem:InitSpecificModifyItem(-1, false)
    local SpriteIcon = GenericModifyConfig.GenericModifySlotToSpritePath[GenericModifySlot]
    if SpriteIcon then
      SetImageBrushByPath(self.URGImageNullIcon, SpriteIcon)
    end
  end
  self.RGTextName:SetText(GenericModifySlotDesc[GenericModifySlot]())
  UpdateVisibility(self.RGTextLv, false)
  UpdateVisibility(self.ImageLvBg, false)
  UpdateVisibility(self.WBP_GenericModifyItem, SpecificModifyData)
  UpdateVisibility(self.RGTextName, not IsShowAll)
  UpdateVisibility(self.URGImageNullBg, not SpecificModifyData)
  UpdateVisibility(self.URGImageNullIcon, not SpecificModifyData)
  if GenericModifySlot == UE.ERGGenericModifySlot.None then
    if PassiveModifyNum and PassiveModifyNum > 1 then
      local TextDes = "+" .. PassiveModifyNum
      UpdateVisibility(self.RGTextNum, bIsFromHud)
      UpdateVisibility(self.RGTextNumHaveModify, false)
      self.RGTextNum:SetText(TextDes)
      self.SelectClickFunc = SelectClick
    else
      UpdateVisibility(self.RGTextNum, false)
      UpdateVisibility(self.RGTextNumHaveModify, false)
    end
  else
    UpdateVisibility(self.RGTextNum, false)
    UpdateVisibility(self.RGTextNumHaveModify, false)
  end
end
function WBP_HUD_GenericModifyItem_C:InitHudModItem(ModData, GenericModifySlot, UpdateGenericModifyTipsFunc, ParentView, bIsFromHud, PassiveModifyNum, SelectClick, IsShowAll)
  UpdateVisibility(self, true, true)
  self.UpdateGenericModifyTipsFunc = UpdateGenericModifyTipsFunc
  self.ParentView = ParentView
  self.ModifyData = nil
  self.SpecificModifyData = nil
  self.ModData = ModData
  self.SelectClickFunc = nil
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if ModData then
    self.WBP_GenericModifyItem:InitGenericModifyItemByMod(ModData.ModId, false)
    local LevelStr = string.format("%d", ModData.Level)
    if bIsFromHud then
      self.RGTextLv:SetText(LevelStr)
      UpdateVisibility(self.RGTextLv, ModData.Level > 1)
      UpdateVisibility(self.ImageLvBg, ModData.Level > 1)
    else
      UpdateVisibility(self.RGTextLv, false)
      UpdateVisibility(self.ImageLvBg, false)
    end
  else
    self.WBP_GenericModifyItem:InitGenericModifyItemByMod(-1, false)
    local SpriteIcon = GenericModifyConfig.GenericModifySlotToSpritePath[GenericModifySlot]
    if SpriteIcon then
      SetImageBrushByPath(self.URGImageNullIcon, SpriteIcon)
    end
    UpdateVisibility(self.RGTextLv, false)
    UpdateVisibility(self.ImageLvBg, false)
  end
  self.RGTextName:SetText(GenericModifySlotDesc[GenericModifySlot]())
  UpdateVisibility(self.WBP_GenericModifyItem, ModData)
  UpdateVisibility(self.RGTextName, not IsShowAll)
  UpdateVisibility(self.URGImageNullBg, not ModData)
  UpdateVisibility(self.URGImageNullIcon, not ModData)
  if GenericModifySlot == UE.ERGGenericModifySlot.None then
    if PassiveModifyNum and PassiveModifyNum > 1 then
      local TextDes = "+" .. PassiveModifyNum
      UpdateVisibility(self.RGTextNum, bIsFromHud)
      UpdateVisibility(self.RGTextNumHaveModify, false)
      self.RGTextNum:SetText(TextDes)
      self.SelectClickFunc = SelectClick
    else
      UpdateVisibility(self.RGTextNum, false)
      UpdateVisibility(self.RGTextNumHaveModify, false)
    end
  else
    UpdateVisibility(self.RGTextNum, false)
    UpdateVisibility(self.RGTextNumHaveModify, false)
  end
end
function WBP_HUD_GenericModifyItem_C:SelectClick()
  if self.SelectClickFunc then
    self.SelectClickFunc(self.ParentView, true)
  end
end
function WBP_HUD_GenericModifyItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self:HightLight(true)
  if self.UpdateGenericModifyTipsFunc then
    if self.ModifyData then
      self.UpdateGenericModifyTipsFunc(self.ParentView, true, self.ModifyData, ModifyChooseType.GenericModify)
    elseif self.SpecificModifyData then
      self.UpdateGenericModifyTipsFunc(self.ParentView, true, self.SpecificModifyData, ModifyChooseType.SpecificModify)
    elseif self.ModData then
      self.UpdateGenericModifyTipsFunc(self.ParentView, true, self.ModData, ModifyChooseType.Mod)
    end
  end
end
function WBP_HUD_GenericModifyItem_C:OnMouseLeave(MouseEvent)
  self:HightLight(false)
  if self.UpdateGenericModifyTipsFunc then
    self.UpdateGenericModifyTipsFunc(self.ParentView, false, self.ModifyData)
  end
end
function WBP_HUD_GenericModifyItem_C:HightLight(bIsHighlight)
  UpdateVisibility(self.URGImageHighlight, bIsHighlight)
end
function WBP_HUD_GenericModifyItem_C:Hide()
  UpdateVisibility(self, false)
  self.UpdateGenericModifyTipsFunc = nil
  self.ParnentView = nil
  self.ModifyData = nil
  self.SelectClickFunc = nil
end
function WBP_HUD_GenericModifyItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Inscription.OnTriggerCD, self.BindOnClientUpdateInscriptionCD, self)
  self.UpdateGenericModifyTipsFunc = nil
  self.ParnentView = nil
  self.ModifyData = nil
  self.SelectClickFunc = nil
  self.GenericModifyFXWidgetList = {}
end
return WBP_HUD_GenericModifyItem_C
