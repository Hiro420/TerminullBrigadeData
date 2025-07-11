local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_SpecificLobbyUnlockShow = UnLua.Class()
local TipsData = {
  Default = {
    ClsPath = "/Game/Rouge/UI/Common/WBP_CommonItemDetail.WBP_CommonItemDetail_C",
    InitFuncName = "InitCommonItemDetail",
    ParamName = {
      "PropId",
      "IsInscription"
    }
  },
  [TableEnums.ENUMResourceType.Puzzle] = {
    ClsPath = "/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleItemTip.WBP_PuzzleItemTip_C",
    InitFuncName = "ShowWithoutOperator",
    GetParamFunc = function(PropsData)
      if not PropsData then
        return {}
      end
      for k, v in pairs(PropsData.extra) do
        return {k}
      end
      return {}
    end
  }
}
function WBP_SpecificLobbyUnlockShow:BindClickHandler()
end
function WBP_SpecificLobbyUnlockShow:UnBindClickHandler()
end
function WBP_SpecificLobbyUnlockShow:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_SpecificLobbyUnlockShow:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_SpecificLobbyUnlockShow:OnShow(...)
  self.Conseing = false
  if table.IsEmpty(IllustratedGuideData.NewUnlockSpecificModifyList) then
    self:CloseSelf()
    return
  end
  if not IsListeningForInputAction(self, "Space") then
    ListenForInputAction("Space", UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SpecificLobbyUnlockShow.CloseSelf
    })
  end
  if not IsListeningForInputAction(self, "PauseGame") then
    ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SpecificLobbyUnlockShow.CloseSelf
    })
  end
  self.Button_Buy.OnClicked:Add(self, WBP_SpecificLobbyUnlockShow.CloseSelf)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.CloseSelf)
  if not self.WBP_CommonTipBg:IsAnimationPlaying(self.WBP_CommonTipBg.Ani_in) then
    self.WBP_CommonTipBg:PlayAnimation(self.WBP_CommonTipBg.Ani_in, 0)
  end
  self:ShowItem()
end
function WBP_SpecificLobbyUnlockShow:ShowItem()
  local ObjCls = UE.UClass.Load("/Game/Rouge/UI/Common/BP_GetPropData.BP_GetPropData_C")
  self.PropList:ClearListItems()
  local PropInfoList = IllustratedGuideData.NewUnlockSpecificModifyList
  for key, SinglePropInfo in pairs(PropInfoList) do
    local DataObj = NewObject(ObjCls, self, nil)
    DataObj.PropId = SinglePropInfo.SpecificId
    DataObj.PropNum = 1
    DataObj.IsInscription = false
    DataObj.ParentView = self
    self.PropList:AddItem(DataObj)
  end
  IllustratedGuideData.NewUnlockSpecificModifyList = {}
end
function WBP_SpecificLobbyUnlockShow:CloseSelf()
  if self.Conseing then
    return
  end
  self.Conseing = true
  if self.CloseCallback then
    self.CloseCallback()
  end
  UIMgr:Hide(ViewID.UI_SpecificLobbyUnlockShow)
end
function WBP_SpecificLobbyUnlockShow:UnHoveredFunc()
  if self.HoveredTipWidget ~= nil then
    UpdateVisibility(self.HoveredTipWidget, false)
    self.HoveredTipWidget = nil
  end
  self.HoveredTipWidgetRef = nil
end
function WBP_SpecificLobbyUnlockShow:HoveredFunc(TargetItem, PropsData)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, PropsData.PropId)
  if not result then
    return
  end
  local generalType = row.Type
  local clsPath = TipsData.Default.ClsPath
  local initFuncName = TipsData.Default.InitFuncName
  local paramNames = TipsData.Default.ParamName
  local getParamsFunc = TipsData.Default.GetParamFunc
  if TipsData[generalType] then
    clsPath = TipsData[generalType].ClsPath
    initFuncName = TipsData[generalType].InitFuncName
    paramNames = TipsData[generalType].ParamName
    getParamsFunc = TipsData[generalType].GetParamFunc
  end
  if not self.HoveredTipWidgetMap then
    self.HoveredTipWidgetMap = {}
  end
  self.HoveredTipWidget = nil
  if self.HoveredTipWidgetMap[clsPath] then
    self.HoveredTipWidget = self.HoveredTipWidgetMap[clsPath]
  else
    local cls = UE.UClass.Load(clsPath)
    self.HoveredTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, cls)
    self.HoveredTipWidgetRef = UnLua.Ref(self.HoveredTipWidget)
    self.HoveredTipWidgetMap[clsPath] = self.HoveredTipWidget
    self.CanvasPanel_0:AddChild(self.HoveredTipWidget)
  end
  local params = {}
  if paramNames then
    for i = 1, #paramNames do
      table.insert(params, PropsData[paramNames[i]])
    end
  elseif getParamsFunc then
    params = getParamsFunc(PropsData)
  end
  self.HoveredTipWidget[initFuncName](self.HoveredTipWidget, table.unpack(params))
  if self.HoveredTipWidget.ShowExpireAt then
    self.HoveredTipWidget:ShowExpireAt(PropsData.expireAt)
  end
  UpdateVisibility(self.HoveredTipWidget, true)
  local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(TargetItem)
  local Size = UE.USlateBlueprintLibrary.GetLocalSize(self.HoveredTipWidget:GetCachedGeometry())
  MousePosition.Y = MousePosition.Y - Size.Y
  if self.HoveredTipWidget.Slot then
    self.HoveredTipWidget.Slot:SetAutoSize(true)
    self.HoveredTipWidget.Slot:SetPosition(MousePosition)
  end
end
function WBP_SpecificLobbyUnlockShow:OnHide()
  if IsListeningForInputAction(self, "Space") then
    StopListeningForInputAction(self, "Space", UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  self.Button_Buy.OnClicked:Remove(self, WBP_SpecificLobbyUnlockShow.CloseSelf)
end
function WBP_SpecificLobbyUnlockShow:Destruct()
  if not self.HoveredTipWidgetMap then
    return
  end
  for k, v in pairs(self.HoveredTipWidgetMap) do
    UnLua.Unref(v)
  end
  self.HoveredTipWidgetMap = {}
end
return WBP_SpecificLobbyUnlockShow
