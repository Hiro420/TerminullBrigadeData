local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
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
local GetPorpsView = Class(ViewBase)
function GetPorpsView:BindClickHandler()
end
function GetPorpsView:UnBindClickHandler()
end
function GetPorpsView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("GetPorpsViewModel")
  self:BindClickHandler()
end
function GetPorpsView:OnDestroy()
  self:UnBindClickHandler()
end
function GetPorpsView:OnShow(...)
  self.Conseing = false
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if not IsListeningForInputAction(self, "Space") then
    ListenForInputAction("Space", UE.EInputEvent.IE_Pressed, true, {
      self,
      GetPorpsView.CloseSelf
    })
  end
  if not IsListeningForInputAction(self, "PauseGame") then
    ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
      self,
      GetPorpsView.CloseSelf
    })
  end
  self.Button_Buy.OnClicked:Add(self, GetPorpsView.CloseSelf)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.CloseSelf)
  if not self.WBP_CommonTipBg:IsAnimationPlaying(self.WBP_CommonTipBg.Ani_in) then
    self.WBP_CommonTipBg:PlayAnimation(self.WBP_CommonTipBg.Ani_in, 0)
  end
end
function GetPorpsView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if IsListeningForInputAction(self, "Space") then
    StopListeningForInputAction(self, "Space", UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  self.Button_Buy.OnClicked:Remove(self, GetPorpsView.CloseSelf)
end
function GetPorpsView:SetCloseCallback(CloseCallback)
  self.CloseCallback = CloseCallback
end
function GetPorpsView:HoveredFunc(TargetItem, PropsData)
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
  ShowCommonTips(nil, TargetItem, self.HoveredTipWidget)
end
function GetPorpsView:UnHoveredFunc()
  if self.HoveredTipWidget ~= nil then
    UpdateVisibility(self.HoveredTipWidget, false)
    self.HoveredTipWidget = nil
  end
  self.HoveredTipWidgetRef = nil
end
function GetPorpsView:CloseSelf()
  if self.Conseing then
    return
  end
  self.Conseing = true
  if self.CloseCallback then
    self.CloseCallback()
  end
  UIMgr:Hide(ViewID.UI_Common_GetProps)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnGetPropsViewHide)
end
function GetPorpsView:Destruct()
  if not self.HoveredTipWidgetMap then
    return
  end
  for k, v in pairs(self.HoveredTipWidgetMap) do
    UnLua.Unref(v)
  end
  self.HoveredTipWidgetMap = {}
end
return GetPorpsView
