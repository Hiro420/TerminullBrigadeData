local WBP_BagRoleGenericItem_C = UnLua.Class()
local GenericModifyConfig = require("GameConfig.GenericModify.GenericModifyConfig")

function WBP_BagRoleGenericItem_C:Construct()
  self.RemainTime = -1
  self.TotalTime = -1
  EventSystem.AddListener(self, EventDef.Inscription.OnTriggerCD, self.BindOnClientUpdateInscriptionCD)
end

function WBP_BagRoleGenericItem_C:BindOnClientUpdateInscriptionCD(InscriptionId, RemainTime)
  local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandSubsystem then
    return
  end
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
    self:StartCD(RemainTime, RemainTime)
  end
end

function WBP_BagRoleGenericItem_C:UpdateCD(InDeltaTime)
  if self.RemainTime > 0 then
    if not self.bIsVolatile then
      self:ForceVolatile(true)
    end
    self.RemainTime = self.RemainTime - InDeltaTime
    self.URGImageCD:SetClippingValue(self.RemainTime / self.TotalTime)
  else
    if self.bIsVolatile then
      self:ForceVolatile(false)
    end
    self.RemainTime = -1
    self.TotalTime = 0
    self.URGImageCD:SetClippingValue(0)
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

function WBP_BagRoleGenericItem_C:StartCD(RemainTime, TotalTime)
  self.URGImageCD:SetClippingValue(RemainTime / TotalTime)
  self.RemainTime = RemainTime
  self.TotalTime = TotalTime
end

function WBP_BagRoleGenericItem_C:StopCD()
  self.URGImageCD:SetClippingValue(0)
  self.RemainTime = -1
  self.TotalTime = -1
end

function WBP_BagRoleGenericItem_C:InitBagRoleGenericItem(ModifyData, GenericModifySlot, UpdateGenericModifyTipsFunc, ParentView, bIsLagacy, TargetItem)
  UpdateVisibility(self, true, true)
  UpdateVisibility(self.CanvasPanelLagacy, bIsLagacy)
  if self.ModifyData ~= nil and nil ~= ModifyData and self.ModifyData.Inscription ~= ModifyData.Inscription then
    self:StopCD()
  end
  self.GenericModifySlot = GenericModifySlot
  self.UpdateGenericModifyTipsFunc = UpdateGenericModifyTipsFunc
  self.ParentView = ParentView
  self.ModifyData = ModifyData
  self.SpecificModifyData = nil
  self.TargetItem = TargetItem
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if ModifyData then
    self.WBP_GenericModifyItem:InitGenericModifyItem(ModifyData.ModifyId, false)
    local LevelStr = string.format("%d", ModifyData.Level)
    self.RGTextLv:SetText(LevelStr)
    UpdateVisibility(self.RGTextLv, ModifyData.Level > 1)
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
    local SpriteIcon = GenericModifyConfig.GenericModifySlotToSpritePath[GenericModifySlot]
    if SpriteIcon then
      SetImageBrushByPath(self.URGImageNullIcon, SpriteIcon)
    end
    UpdateVisibility(self.RGTextLv, false)
  end
  if GenericModifySlot and GenericModifySlotDesc[GenericModifySlot] and GenericModifySlot ~= UE.ERGGenericModifySlot.None then
    self.RGTextSlotName:SetText(GenericModifySlotDesc[GenericModifySlot]())
    UpdateVisibility(self.RGTextSlotName, true)
  else
    UpdateVisibility(self.RGTextSlotName, false)
  end
  UpdateVisibility(self.ScaleBoxNullBg, GenericModifySlot == UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.URGImageNormalSlotBg, GenericModifySlot ~= UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.ScaleBoxNomalSlotBg, GenericModifySlot ~= UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.ScaleBoxNullSlotBg, GenericModifySlot ~= UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.URGImageNullIcon, GenericModifySlot ~= UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.URGImageNullSlotBg, GenericModifySlot ~= UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.URGImageNullBg, GenericModifySlot == UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.CanvasPanelNull, not ModifyData)
  UpdateVisibility(self.CanvasPanelNormal, ModifyData)
  if GenericModifySlot == UE.ERGGenericModifySlot.None then
    UpdateVisibility(self.RGTextNum, false)
    UpdateVisibility(self.RGTextNumHaveModify, false)
  else
    UpdateVisibility(self.RGTextNum, false)
    UpdateVisibility(self.RGTextNumHaveModify, false)
  end
end

function WBP_BagRoleGenericItem_C:GetInscriptionId(ModifyData)
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

function WBP_BagRoleGenericItem_C:InitSpecificModifyItem(SpecificModifyData, GenericModifySlot, UpdateGenericModifyTipsFunc, ParentView)
  UpdateVisibility(self, true, true)
  self.UpdateGenericModifyTipsFunc = UpdateGenericModifyTipsFunc
  self.ParentView = ParentView
  self.SpecificModifyData = SpecificModifyData
  self.ModifyData = nil
  self.GenericModifySlot = GenericModifySlot
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
  UpdateVisibility(self.RGTextLv, false)
  UpdateVisibility(self.RGTextSlotName, false)
  UpdateVisibility(self.URGImageNullIcon, GenericModifySlot ~= UE.ERGGenericModifySlot.None)
  UpdateVisibility(self.CanvasPanelNull, not SpecificModifyData)
  UpdateVisibility(self.CanvasPanelNormal, SpecificModifyData)
  if GenericModifySlot == UE.ERGGenericModifySlot.None then
    UpdateVisibility(self.RGTextNum, false)
    UpdateVisibility(self.RGTextNumHaveModify, false)
  else
    UpdateVisibility(self.RGTextNum, false)
    UpdateVisibility(self.RGTextNumHaveModify, false)
  end
end

function WBP_BagRoleGenericItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self:HightLight(true)
  if self.UpdateGenericModifyTipsFunc then
    if self.ModifyData then
      self.UpdateGenericModifyTipsFunc(self.ParentView, true, self.ModifyData, ModifyChooseType.GenericModify, self.GenericModifySlot, self)
    elseif self.SpecificModifyData then
      self.UpdateGenericModifyTipsFunc(self.ParentView, true, self.SpecificModifyData, ModifyChooseType.SpecificModify, self.GenericModifySlot, self)
    end
  end
  PlaySound2DEffect(50006, "")
end

function WBP_BagRoleGenericItem_C:OnMouseLeave(MouseEvent)
  self:HightLight(false)
  if self.UpdateGenericModifyTipsFunc then
    self.UpdateGenericModifyTipsFunc(self.ParentView, false, self.ModifyData)
  end
end

function WBP_BagRoleGenericItem_C:HightLight(bIsHighlight)
  UpdateVisibility(self.URGImageHighlight, bIsHighlight)
end

function WBP_BagRoleGenericItem_C:Hide()
  UpdateVisibility(self, false)
  self.UpdateGenericModifyTipsFunc = nil
  self.ParnentView = nil
  self.ModifyData = nil
  self.GenericModifySlot = nil
end

function WBP_BagRoleGenericItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Inscription.OnTriggerCD, self.BindOnClientUpdateInscriptionCD, self)
  self.UpdateGenericModifyTipsFunc = nil
  self.ParnentView = nil
  self.ModifyData = nil
  self.GenericModifySlot = nil
end

return WBP_BagRoleGenericItem_C
