local EBattleLagacyLobbyItemActive = {Active = "Active", NotActive = "NotActive"}
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local WBP_BattleLagacyLobbyTips = UnLua.Class()
local ShowDetailsName = "ViewFullAttributeList"

function WBP_BattleLagacyLobbyTips:Construct()
  self.Overridden.Construct(self)
end

function WBP_BattleLagacyLobbyTips:InitBattleLagacyLobbyTips(CurBattleLagacyData, ParentView)
  UpdateVisibility(self, true)
  self.CurBattleLagacyData = CurBattleLagacyData
  self.ParentView = ParentView
  if CurBattleLagacyData.BattleLagacyType == EBattleLagacyType.GeneircModify then
    local result, row = GetRowData(DT.DT_GenericModify, CurBattleLagacyData.BattleLagacyId)
    if result then
      local resultGroup, rowGroup = GetRowData(DT.DT_GenericModifyGroup, row.GroupId)
      if resultGroup then
        self.TextGroupName:SetText(rowGroup.Name)
      end
      local name = GetInscriptionName(row.Inscription)
      self.TextName:SetText(name)
      local resultRarity, rowRarity = GetRowData(DT.DT_ItemRarity, tostring(row.Rarity))
      if resultRarity then
        self.TextName:SetColorAndOpacity(rowRarity.DisplayNameColor)
      end
    end
    UpdateVisibility(self.CanvasPanel_prompt, true)
    UpdateVisibility(self.TextGroupName, true)
    UpdateVisibility(self.TextDesc, false)
    if not IsListeningForInputAction(self, ShowDetailsName) then
      ListenForInputAction(ShowDetailsName, UE.EInputEvent.IE_Pressed, true, {
        self,
        self.ListenForShowDetailsInputAction
      })
      ListenForInputAction(ShowDetailsName, UE.EInputEvent.IE_Released, true, {
        self,
        self.ListenForHideDetailsInputAction
      })
    end
  elseif CurBattleLagacyData.BattleLagacyType == EBattleLagacyType.Inscription then
    local inscriptionId = tonumber(CurBattleLagacyData.BattleLagacyId)
    if inscriptionId > 0 then
      local name = GetInscriptionName(inscriptionId)
      local inscriptionData = GetLuaInscription(inscriptionId)
      local desc = GetLuaInscriptionDesc(inscriptionId)
      if inscriptionData then
        self.TextName:SetText(name)
        self.TextDesc:SetText(desc)
        local result, row = GetRowData(DT.DT_ItemRarity, tostring(inscriptionData.Rarity))
        if result then
          self.TextName:SetColorAndOpacity(row.DisplayNameColor)
        end
      end
    end
    UpdateVisibility(self.CanvasPanel_prompt, false)
    UpdateVisibility(self.TextDesc, true)
    UpdateVisibility(self.TextGroupName, false)
  end
end

function WBP_BattleLagacyLobbyTips:ListenForShowDetailsInputAction()
  if not self.ParentView then
    return
  end
  if not CheckIsVisility(self) then
    return
  end
  self.ParentView:ShowLagacyModifyDetailsTips(true, self.CurBattleLagacyData)
end

function WBP_BattleLagacyLobbyTips:ListenForHideDetailsInputAction()
  if not self.ParentView then
    return
  end
  self.ParentView:ShowLagacyModifyDetailsTips(false)
end

function WBP_BattleLagacyLobbyTips:Hide()
  if IsListeningForInputAction(self, ShowDetailsName) then
    StopListeningForInputAction(self, ShowDetailsName, UE.EInputEvent.IE_Pressed)
    StopListeningForInputAction(self, ShowDetailsName, UE.EInputEvent.IE_Released)
  end
  self.ParentView = nil
  self.CurBattleLagacyData = nil
  UpdateVisibility(self, false)
end

function WBP_BattleLagacyLobbyTips:Destruct()
  self.Overridden.Destruct(self)
end

return WBP_BattleLagacyLobbyTips
