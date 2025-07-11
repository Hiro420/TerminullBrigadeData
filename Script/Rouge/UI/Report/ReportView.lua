local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local LocalizationConfig = require("GameConfig.Localization.LocalizationConfig")
local ReportItemCountPerLine = 3
local ReportView = Class(ViewBase)
function ReportView:BindClickHandler()
  self.TitleList.BP_OnItemSelectionChanged:Add(self, ReportView.BP_OnItemSelectionChanged_TitleList)
  self.ContentList.BP_OnItemSelectionChanged:Add(self, ReportView.BP_OnItemSelectionChanged_ContentList)
  self.BP_ButtonConfirm.OnClicked:Add(self, ReportView.Confirm)
  self.BP_ButtonCancel.OnClicked:Add(self, ReportView.Cancel)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, ReportView.Cancel)
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    ReportView.Cancel
  })
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
  end
end
function ReportView:UnBindClickHandler()
  self.ContentList.BP_OnItemSelectionChanged:Remove(self, ReportView.BP_OnItemSelectionChanged_ContentList)
  self.ContentList.BP_OnItemSelectionChanged:Remove(self, ReportView.BP_OnItemSelectionChanged_ContentList)
  self.BP_ButtonConfirm.OnClicked:Remove(self, ReportView.Confirm)
  self.BP_ButtonCancel.OnClicked:Remove(self, ReportView.Cancel)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, ReportView.Cancel)
  StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
end
function ReportView:OnInit()
end
function ReportView:OnDestroy()
  self:UnBindClickHandler()
end
function ReportView:OnShow(ReportScene, ReportedRoleID, PlayerName, ReportedContent)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.Ed_Desc:SetText("")
  self:BindClickHandler()
  self.SceneId = ReportScene
  self.Txt_PlayerName:SetText(PlayerName)
  self.ReportedContent = ReportedContent
  if nil == ReportedContent then
    self.ReportedContent = ""
  end
  self.ReportedRoleID = ReportedRoleID
  self:InitTitleList(ReportScene)
  self:SetEnhancedInputActionBlocking(true)
  if 2 == self.SceneId then
    self:SetEnhancedInputActionPriority(1)
  end
end
function ReportView:OnHide()
  self:UnBindClickHandler()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local TeamDamagePanelView = RGUIMgr:GetUI(UIConfig.WBP_TeamDamagePanel_C.UIName)
  if TeamDamagePanelView then
    TeamDamagePanelView:OnRepeorViewClosed()
  end
  self:SetEnhancedInputActionBlocking(false)
  if 2 == self.SceneId then
    self:SetEnhancedInputActionPriority(0)
  end
end
function ReportView:GetConfigByReportScene(ReportScene)
  local Result, Row = GetRowData(DT.DT_ReportTable, ReportScene)
  if Result then
    return Row.ReportConfig
  end
end
function ReportView:InitReportContent(CategoryId)
  local RowData = self:GetConfigByReportScene(self.SceneId)
  if RowData then
    local ReportContrnt = RowData:Find(CategoryId)
    self.ContentList:BP_ClearSelection()
    self.ContentList:ClearListItems()
    local TargetTable = ReportContrnt.ReportInfo:ToTable()
    local KeysTable = ReportContrnt.ReportInfo:Keys():ToTable()
    for key, value in pairs(KeysTable) do
      local Obj = self.ContentList:GetOrCreateDataObj()
      if Obj then
        Obj.ID = value
        Obj.Name = TargetTable[value]
        self.ContentList:AddItem(Obj)
      end
    end
  end
end
function ReportView:InitTitleList(ReportScene)
  self.TitleList:ClearListItems()
  local RowData = self:GetConfigByReportScene(ReportScene)
  local TargetTable = RowData:ToTable()
  local KeysTable = RowData:Keys():ToTable()
  table.sort(KeysTable, function(A, B)
    return A < B
  end)
  for key, value in pairs(KeysTable) do
    local Obj = self.TitleList:GetOrCreateDataObj()
    if Obj then
      Obj.ID = value
      Obj.Name = TargetTable[value].Desc
      self.TitleList:AddItem(Obj)
    end
  end
  self.TitleList:SetSelectedIndex(0)
end
function ReportView:BP_OnItemSelectionChanged_TitleList(Item, bSelection)
  if Item and bSelection then
    self:InitReportContent(Item.ID)
  end
end
function ReportView:BP_OnItemSelectionChanged_ContentList(Item, bSelection)
  if not Item or bSelection then
  end
end
function ReportView:ReportToServer()
  local Category = self.TitleList:BP_GetSelectedItem().ID
  local Desc = self.Ed_Desc:GetText()
  local Len = UTF8Len(tostring(Desc))
  if Len > 50 then
    ShowWaveWindow(303013)
    return
  end
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  local TxtCultureTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Interface")
  local TxtCultureValue = RGGameUserSettings:GetGameSettingByTag(TxtCultureTag)
  local Language = ECultureType_Report[TxtCultureValue]
  local bSel, ReasonObjs = self.ContentList:BP_GetSelectedItems()
  local Reason = {}
  for index, value in ipairs(ReasonObjs:ToTable()) do
    table.insert(Reason, value.ID)
  end
  if 0 == table.count(Reason) then
    ShowWaveWindow(303007)
    return
  end
  local ReportedContent = self.ReportedContent
  local ReportedRoleID = self.ReportedRoleID
  local Scene = self.SceneId
  local Param = {
    category = Category,
    desc = Desc,
    language = Language,
    reason = Reason,
    reportedContent = ReportedContent,
    reportedRoleID = ReportedRoleID,
    scene = Scene
  }
  HttpCommunication.Request("diplomat/reportcheating", Param, {
    self,
    function(Target, JsonResponse)
      ShowWaveWindow(303010)
      print("\228\184\190\230\138\165\230\136\144\229\138\159")
      UIMgr:Hide(ViewID.UI_ReportView)
    end
  }, {
    self,
    function(Error)
      ShowWaveWindow(303011)
      print("\228\184\190\230\138\165\229\164\177\232\180\165", Error.Content)
    end
  })
end
function ReportView:Confirm()
  self:ReportToServer()
end
function ReportView:Cancel()
  UIMgr:Hide(ViewID.UI_ReportView)
end
function ReportView:OnTitleItemCreated()
  self:FocusDefaultWidget()
end
function ReportView:BindOnInputMethodChanged(InputType)
  if InputType == UE.ECommonInputType.Gamepad then
    self:FocusDefaultWidget()
  end
end
function ReportView:FocusDefaultWidget()
  local Widget = self:DoCustomNavigation_TitleFirst()
  if Widget then
    Widget:SetFocus()
  end
end
function ReportView:DoCustomNavigation_ContentFirst()
  local ItemCount = self.ContentList:GetNumItems()
  local ItemFirst = self.ContentList:GetItemAt(0)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.ContentList, ItemFirst)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:DoCustomNavigation_ContentLast()
  local ItemCount = self.ContentList:GetNumItems()
  local ItemLast = self.ContentList:GetItemAt(ItemCount - 1)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.ContentList, ItemLast)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:GetReprotItemLeft(ItemObject)
  local ItemCount = self.ContentList:GetNumItems()
  local ItemIndex = self.ContentList:GetIndexForItem(ItemObject)
  local TargetIndex = ItemIndex
  if ItemIndex > 0 then
    TargetIndex = ItemIndex - 1
  else
    TargetIndex = ItemIndex + ReportItemCountPerLine - 1
  end
  if TargetIndex > ItemCount - 1 then
    TargetIndex = ItemCount - 1
  end
  local TargetObj = self.ContentList:GetItemAt(TargetIndex)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.ContentList, TargetObj)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:GetReprotItemRight(ItemObject)
  local ItemCount = self.ContentList:GetNumItems()
  local ItemIndex = self.ContentList:GetIndexForItem(ItemObject)
  local ColumnIndex = ItemIndex % ReportItemCountPerLine
  local TargetIndex = ItemIndex
  if ColumnIndex < ReportItemCountPerLine - 1 then
    TargetIndex = ItemIndex + 1
  else
    TargetIndex = ItemIndex - (ReportItemCountPerLine - 1)
  end
  if TargetIndex > ItemCount - 1 then
    TargetIndex = ItemCount - 1
  end
  local TargetObj = self.ContentList:GetItemAt(TargetIndex)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.ContentList, TargetObj)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:GetReprotItemUp(ItemObject)
  local ItemCount = self.ContentList:GetNumItems()
  local ItemIndex = self.ContentList:GetIndexForItem(ItemObject)
  local TargetIndex = ItemIndex
  local CurRowIndex = math.floor(ItemIndex / ReportItemCountPerLine)
  if CurRowIndex > 0 then
    TargetIndex = ItemIndex - ReportItemCountPerLine
  else
    return self:DoCustomNavigation_TitleFirst()
  end
  local TargetObj = self.ContentList:GetItemAt(TargetIndex)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.ContentList, TargetObj)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:GetReprotItemDown(ItemObject)
  local ItemCount = self.ContentList:GetNumItems()
  local ItemIndex = self.ContentList:GetIndexForItem(ItemObject)
  local TargetIndex = ItemIndex
  local CurRowIndex = math.floor(ItemIndex / ReportItemCountPerLine)
  local MaxRowIndex = math.floor((ItemCount - 1) / ReportItemCountPerLine)
  if CurRowIndex < MaxRowIndex then
    TargetIndex = ItemIndex + ReportItemCountPerLine
  else
    return self.Ed_Desc
  end
  if TargetIndex > ItemCount - 1 then
    TargetIndex = ItemCount - 1
  end
  local TargetObj = self.ContentList:GetItemAt(TargetIndex)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.ContentList, TargetObj)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:DoCustomNavigation_TitleFirst()
  local ItemFirst = self.TitleList:GetItemAt(0)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.TitleList, ItemFirst)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:DoCustomNavigation_TitleLast()
  local ItemCount = self.TitleList:GetNumItems()
  local ItemLast = self.TitleList:GetItemAt(ItemCount - 1)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.TitleList, ItemLast)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:GetReprotTitleLeft(ItemObject)
  local ItemCount = self.TitleList:GetNumItems()
  local ItemIndex = self.TitleList:GetIndexForItem(ItemObject)
  local TargetIndex = ItemIndex
  if ItemIndex > 0 then
    TargetIndex = ItemIndex - 1
  else
    TargetIndex = ItemCount - 1
  end
  local TargetObj = self.TitleList:GetItemAt(TargetIndex)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.TitleList, TargetObj)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
function ReportView:GetReprotTitleRight(ItemObject)
  local ItemCount = self.TitleList:GetNumItems()
  local ItemIndex = self.TitleList:GetIndexForItem(ItemObject)
  local TargetIndex = ItemIndex
  if ItemIndex < ItemCount - 1 then
    TargetIndex = ItemIndex + 1
  else
    TargetIndex = 0
  end
  local TargetObj = self.TitleList:GetItemAt(TargetIndex)
  local Widget = UE.URGBlueprintLibrary.K2_GetEntryWidgetFromItem(self.TitleList, TargetObj)
  if Widget then
    return Widget.Button_Main
  end
  return nil
end
return ReportView
