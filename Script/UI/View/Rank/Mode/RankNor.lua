local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RankData = require("UI.View.Rank.RankData")
local RankNor = Class(ViewBase)

function RankNor:OnBindUIInput()
  self.WBP_InteractTipWidgetGameMode:BindInteractAndClickEvent(self, self.OnGameModeClicked)
  self.WBP_InteractTipWidgetWorld:BindInteractAndClickEvent(self, self.OnWorldClicked)
end

function RankNor:OnUnBindUIInput()
  self.WBP_InteractTipWidgetGameMode:UnBindInteractAndClickEvent(self, self.OnGameModeClicked)
  self.WBP_InteractTipWidgetWorld:UnBindInteractAndClickEvent(self, self.OnWorldClicked)
end

function RankNor:OnGameModeClicked()
  self.ComboBoxGameMode:OpenOption()
end

function RankNor:OnWorldClicked()
  self.ComboBoxWorld:OpenOption()
end

function RankNor:BindClickHandler()
  EventSystem.AddListener(self, EventDef.Rank.OnRequestServerDataSuccess, RankNor.OnRequestServerDataSuccess)
  self.Btn_Team_new.OnClicked:Add(self, RankNor.SwitchTeam)
  self.Btn_Single_new.OnClicked:Add(self, RankNor.SwitchSingle)
  self.ComboBoxHero.OnSelectionChanged:Add(self, self.OnComboBoxChange)
  self.ComboBoxWorld.OnSelectionChanged:Add(self, self.OnWorldChange)
  self.ComboBoxGameMode.OnSelectionChanged:Add(self, self.OnModeChange)
  self.ComboBoxSeason.OnSelectionChanged:Add(self, self.OnSeasonChange)
end

function RankNor:UnBindClickHandler()
  EventSystem.RemoveListener(EventDef.Rank.OnRequestServerDataSuccess, RankNor.OnRequestServerDataSuccess, self)
  self.Btn_Team_new.OnClicked:Remove(self, RankNor.SwitchTeam)
  self.Btn_Single_new.OnClicked:Remove(self, RankNor.SwitchSingle)
  self.ComboBoxHero.OnSelectionChanged:Remove(self, self.OnComboBoxChange)
  self.ComboBoxWorld.OnSelectionChanged:Remove(self, self.OnWorldChange)
  self.ComboBoxSeason.OnSelectionChanged:Remove(self, self.OnSeasonChange)
end

function RankNor:OnInit()
  self.DataBindTable = {}
end

function RankNor:OnDestroy()
end

function RankNor:OnShow(...)
  self.bFinishInit = false
  self:BindClickHandler()
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnESCClicked)
  self:InitWidget()
  self:SwitchTeam()
  LogicRole.ShowOrLoadLevel(-1)
  ChangeLobbyCamera(self, "Rank")
  LogicRole.ChangeRoleMainTransform("Rank")
  LogicRole.ShowOrHideRoleMainHero(true)
  self.WBP_RankView:PlayAnimation(self.WBP_RankView.Ani_in)
end

function RankNor:OnRollback()
  LogicRole.ShowOrLoadLevel(-1)
  ChangeLobbyCamera(self, "Rank")
  LogicRole.ChangeRoleMainTransform("Rank")
  LogicRole.ShowOrHideRoleMainHero(true)
  self.WBP_RankView:PlayAnimation(self.WBP_RankView.Ani_in)
end

function RankNor:BindOnESCClicked()
  if self:IsAnimationPlaying(self.Anim_OUT) then
    return
  end
  self:PlayAnimation(self.Anim_OUT)
  self.WBP_RankView:PlayAnimation(self.WBP_RankView.Ani_out)
end

function RankNor:OnAnimationFinished(Animation)
  if Animation == self.Anim_OUT then
    UIMgr:Hide(ViewID.UI_RankView_Nor, true)
  end
end

function RankNor:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnESCClicked)
  if UIMgr:IsShow(ViewID.UI_ContactPersonOperateButtonPanel) then
    UIMgr:Hide(ViewID.UI_ContactPersonOperateButtonPanel)
  end
  LogicRole.ShowOrHideRoleMainHero(false)
  self:UnBindClickHandler()
end

function RankNor:InitWidget()
  local TBRankModeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRankMode)
  self.ComboBoxWorld:ClearOptions()
  self.ComboBoxHero:ClearOptions()
  self.ComboBoxSeason:ClearOptions()
  local ChaheTable = {}
  for index, value in ipairs(TBRankModeTable) do
    if value.bEnable then
      ChaheTable[value.SeasonId] = value
    end
  end
  for key, value in pairs(ChaheTable) do
    self.ComboBoxSeason:AddOption(key)
  end
  if self.SelSeasonId then
    self.ComboBoxSeason:SetSelectedOption(self.SelSeasonId)
  else
    self.ComboBoxSeason:SetSelectedIndex(0)
  end
  local HeroTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  local ChaheTable = {}
  for key, value in pairs(HeroTable) do
    if value.CanChoose and value.Type == TableEnums.ENUMHeroType.Hero then
      table.insert(ChaheTable, value)
    end
  end
  table.sort(ChaheTable, function(a, b)
    return a.ID < b.ID
  end)
  for index, value in ipairs(ChaheTable) do
    self.ComboBoxHero:AddOption(value.ID)
  end
  self.ComboBoxHero:SetSelectedIndex(0)
  self.bFinishInit = true
end

function RankNor:OnComboBoxWorldGenerateWidget(Item)
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, self.ComboBoxItemClass)
  if Widget then
    local AResult, WorldModeRowInfo = GetRowData(DT.DT_GameMode, tonumber(Item))
    if AResult then
      Widget.Txt_HeroName:SetText(WorldModeRowInfo.Name)
    end
    self.WorldGenerateWidgets:Add(Widget)
    if self.ComboBoxWorld:IsOpen() then
      Widget.Txt_HeroName:SetColorAndOpacity(Widget.OpenColor)
    else
      Widget.Txt_HeroName:SetColorAndOpacity(Widget.CloseColor)
    end
  end
  return Widget
end

function RankNor:OnComboBoxHeroGenerateWidget(Item)
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, self.ComboBoxItemClass)
  if Widget then
    local HeroTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
    if HeroTable[tonumber(Item)] then
      Widget.Txt_HeroName:SetText(HeroTable[tonumber(Item)].Name)
      self.HeroGenerateWidgets:Add(Widget)
      if self.ComboBoxHero:IsOpen() then
        Widget.Txt_HeroName:SetColorAndOpacity(Widget.OpenColor)
      else
        Widget.Txt_HeroName:SetColorAndOpacity(Widget.CloseColor)
      end
    end
  end
  return Widget
end

function RankNor:OnComboBoxGameModeGenerateWidget(Item)
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, self.ComboBoxItemClass)
  if Widget then
    local TBRankModeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRankMode)
    for index, value in ipairs(TBRankModeTable) do
      if value.bEnable and value.ModeId == tonumber(Item) and value.SeasonId == self.SelSeasonId then
        Widget.Txt_HeroName:SetText(value.ModeName)
      end
    end
    if self.ComboBoxGameMode:IsOpen() then
      Widget.Txt_HeroName:SetColorAndOpacity(Widget.OpenColor)
    else
      Widget.Txt_HeroName:SetColorAndOpacity(Widget.CloseColor)
    end
  end
  return Widget
end

function RankNor:On_ComboBoxSeason_GenerateWidget(Item)
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, self.ComboBoxItemClass)
  if Widget then
    local TBRankModeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRankMode)
    for index, value in ipairs(TBRankModeTable) do
      if value.bEnable and value.SeasonId == tonumber(Item) then
        Widget.Txt_HeroName:SetText(value.SeasonName)
      end
    end
    if self.ComboBoxGameMode:IsOpen() then
      Widget.Txt_HeroName:SetColorAndOpacity(Widget.OpenColor)
    else
      Widget.Txt_HeroName:SetColorAndOpacity(Widget.CloseColor)
    end
  end
  return Widget
end

function RankNor:OnRequestServerDataSuccess(JsonTable)
  print("OnRequestServerDataSuccess")
  self.WBP_RankView.ParentClass = self
  self.WBP_RankView:UpdateRankList(JsonTable)
end

function RankNor:OnSeasonChange(Id, Type)
  if "" == Id then
    return
  end
  self.SelSeasonId = tonumber(Id)
  self.ComboBoxGameMode:ClearOptions()
  local TBRankModeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRankMode)
  for index, value in ipairs(TBRankModeTable) do
    if self.SelSeasonId == value.SeasonId and value.bEnable then
      if self.TeamMode then
        if 0 ~= value.TeamBoardType then
          self.ComboBoxGameMode:AddOption(value.ModeId)
        end
      elseif 0 ~= value.SoloBoardType then
        self.ComboBoxGameMode:AddOption(value.ModeId)
      end
      if self.WorldModeTable == nil then
        self.WorldModeTable = {}
      end
      self.WorldModeTable[value.ModeId] = value.WorldIds
    end
  end
  self.ComboBoxGameMode:SetSelectedIndex(0)
end

function RankNor:OnWorldChange(Id, Type)
  if "" == Id then
    return
  end
  self.SelWorldId = tonumber(Id)
  self.WBP_RankView:SetShowType(self.TeamMode, self.SelWorldId, self.SelModeId, self.SelHeroId, self.SelSeasonId)
  if not self.bFinishInit then
    return
  end
  if self.TeamMode == false then
    RankData.RequestServerData(self.SelSeasonId, self.SelModeId, self.SelWorldId, self.SelHeroId, 100)
  else
    RankData.RequestServerData(self.SelSeasonId, self.SelModeId, self.SelWorldId, nil, 200)
  end
end

function RankNor:OnModeChange(Id, Type)
  if "" == Id then
    return
  end
  self.SelModeId = tonumber(Id)
  self.ComboBoxWorld:ClearOptions()
  for index, value in ipairs(self.WorldModeTable[self.SelModeId]) do
    self.ComboBoxWorld:AddOption(value)
  end
  self.ComboBoxWorld:SetSelectedIndex(0)
end

function RankNor:OnComboBoxChange(Item, Type)
  if "" == Item then
    return
  end
  self.SelHeroId = tonumber(self.ComboBoxHero:GetSelectedOption())
  if self.TeamMode == nil or self.TeamMode then
    return
  end
  self.WBP_RankView.HeroId = self.SelHeroId
  if not self.bFinishInit then
    return
  end
  if self.SelHeroId then
    RankData.RequestServerData(self.SelSeasonId, self.SelModeId, self.SelWorldId, self.SelHeroId, 100)
  else
    RankData.RequestServerData(self.SelSeasonId, self.SelModeId, self.SelWorldId, self.SelHeroId, 200)
  end
end

function RankNor:SwitchTeam()
  self.TeamMode = true
  self:OnSeasonChange(self.SelSeasonId)
  self.WBP_RankView:SetShowType(self.TeamMode, self.SelWorldId, self.SelModeId, self.SelHeroId, self.SelSeasonId)
  UpdateVisibility(self.Pnl_ComboBoxHero, false)
  UpdateVisibility(self.Btn_Team_Select, true)
  UpdateVisibility(self.Btn_Single_Select_1, false)
  UpdateVisibility(self.Btn_Team_Normal, false)
  UpdateVisibility(self.Btn_Single_Normal, true)
end

function RankNor:SwitchSingle()
  self.TeamMode = false
  self:OnSeasonChange(self.SelSeasonId)
  UpdateVisibility(self.Btn_Team_Select, false)
  UpdateVisibility(self.Btn_Single_Select_1, true)
  UpdateVisibility(self.Pnl_ComboBoxHero, true, true)
  UpdateVisibility(self.Btn_Team_Normal, true)
  UpdateVisibility(self.Btn_Single_Normal, false)
  self.SelHeroId = tonumber(self.ComboBoxHero:GetSelectedOption())
  self.WBP_RankView:SetShowType(self.TeamMode, self.SelWorldId, self.SelModeId, self.SelHeroId, self.SelSeasonId)
  if self.SelHeroId == nil then
    return
  end
end

return RankNor
