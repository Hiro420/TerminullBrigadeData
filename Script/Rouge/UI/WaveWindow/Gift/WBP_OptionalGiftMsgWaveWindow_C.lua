local ruletaskhandler = require("Protocol.RuleTask.RuleTaskHandler")
local rapidjson = require("rapidjson")
local WBP_OptionalGiftMsgWaveWindow_C = UnLua.Class()
function WBP_OptionalGiftMsgWaveWindow_C:Construct()
  self.WBP_CommonButton.OnMainButtonClicked:Add(self, self.OnMainButtonClick)
  EventSystem.AddListener(self, EventDef.Gift.OnOptionalGiftItemSelect, WBP_OptionalGiftMsgWaveWindow_C.OnItemSelectionChanged)
end
function WBP_OptionalGiftMsgWaveWindow_C:Destruct()
  self.WBP_CommonButton.OnMainButtonClicked:Remove(self, self.OnMainButtonClick)
  EventSystem.RemoveListener(EventDef.Gift.OnOptionalGiftItemSelect, WBP_OptionalGiftMsgWaveWindow_C.OnItemSelectionChanged, self)
end
function WBP_OptionalGiftMsgWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
end
function WBP_OptionalGiftMsgWaveWindow_C:InitOptionalGift(GiftId, SourceId, Type, Num, TaskId)
  self.GiftId = GiftId
  self.SourceId = SourceId
  self.Type = Type
  self.TaskId = TaskId
  self.Num = Num
  local TBOptionalGift = LuaTableMgr.GetLuaTableByName(TableNames.TBOptionalGift)
  if not TBOptionalGift then
    return
  end
  if not TBOptionalGift[GiftId] then
    return
  end
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TotalResourceTable[GiftId] then
    print("WBP_OptionalGiftMsgWaveWindow_C", GiftId, TotalResourceTable[GiftId], TotalResourceTable[GiftId].Name)
    self.Txt_Info:SetText(TotalResourceTable[GiftId].Name)
  end
  local bLeft = #TBOptionalGift[GiftId].Resources > 5
  UpdateVisibility(self.RGTileView_243, false)
  UpdateVisibility(self.PropList, false)
  local List = {}
  if not bLeft then
    self.RGStateController_Num:ChangeStatus("NoMorethanFive")
    List = self.PropList
  else
    List = self.RGTileView_243
    self.RGStateController_Num:ChangeStatus("MorethanFive")
  end
  UpdateVisibility(List, true)
  self.RGTileView_243:ClearListItems()
  self.PropList:ClearListItems()
  for index, Resources in ipairs(TBOptionalGift[GiftId].Resources) do
    local ItemObj = NewObject(self.ItemClass, self, nil)
    ItemObj.ResourcesIndex = index - 1
    ItemObj.ResourcesId = Resources.key
    ItemObj.ResourcesNum = Resources.value
    ItemObj.MaxNum = self.Num
    List:AddItem(ItemObj)
  end
  self.OptionalGiftIndexs = {}
  self.OptionalGiftIndexsTable = {}
  self.RGStateController_Btn:ChangeStatus("Disable")
  self.SelectProgress:SetText("0/" .. self.Num)
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.K2_CloseWaveWindow)
end
function WBP_OptionalGiftMsgWaveWindow_C:OnItemSelectionChanged(Index, SelectNum)
  if self.OptionalGiftIndexsTable == nil or 1 == self.Num then
    self.OptionalGiftIndexsTable = {}
  end
  self.OptionalGiftIndexsTable[Index] = SelectNum
  self.OptionalGiftIndexs = {}
  for k, v in pairs(self.OptionalGiftIndexsTable) do
    if 0 ~= v then
      for i = 1, v do
        table.insert(self.OptionalGiftIndexs, k)
      end
    end
  end
  self.SelectProgress:SetText(table.count(self.OptionalGiftIndexs) .. "/" .. self.Num)
  self.bBtnEnabled = self.Num == table.count(self.OptionalGiftIndexs)
  if self.bBtnEnabled then
    if self.Num > 1 then
      self.RGStateController_Btn:ChangeStatus("Enable_Multiple")
    else
      self.RGStateController_Btn:ChangeStatus("Enable")
    end
  else
    self.RGStateController_Btn:ChangeStatus("Disable")
  end
end
function WBP_OptionalGiftMsgWaveWindow_C:BindOnConfirmClick(Func)
  self.OnConfirmClickFunc = Func
end
function WBP_OptionalGiftMsgWaveWindow_C:OnMainButtonClick()
  if not self.bBtnEnabled then
    ShowWaveWindow(self.WaveWindow_Disable)
    return
  elseif self.Num > 1 then
    local WaveWindow = ShowWaveWindowWithDelegate(306003, {}, function()
      self:K2_OnConfirmClick()
      CloseWaveWindow(self)
    end)
    if WaveWindow then
      WaveWindow:InitOptionalGift(self.GiftId, self.OptionalGiftIndexs)
    end
  else
    self:K2_OnConfirmClick()
  end
end
function WBP_OptionalGiftMsgWaveWindow_C:K2_OnConfirmClick()
  if self.OptionalGiftIndexs == nil then
    return
  end
  if not self.bBtnEnabled then
    ShowWaveWindow(self.WaveWindow_Disable)
    return
  end
  local optionalGiftInfo = {
    optionalGiftResourceID = self.GiftId,
    selectedIndexs = self.OptionalGiftIndexs
  }
  local optionalGiftInfos = {optionalGiftInfo}
  if self.Type == _G.EOptionalGiftType.Rule then
    ruletaskhandler:RequestReceiveOptionalGiftRewardToServer(self.SourceId, optionalGiftInfos)
  elseif self.Type == _G.EOptionalGiftType.Task then
    local JsonParams = {
      groupID = self.SourceId,
      taskID = self.TaskId,
      optionalGiftInfos = optionalGiftInfos
    }
    local LocalTaskId = self.TaskId
    HttpCommunication.Request("task/receivereward/task", JsonParams, {
      GameInstance,
      function(Target, JsonResponse)
        local Response = rapidjson.decode(JsonResponse.Content)
        if Logic_MainTask.TaskInfo and Logic_MainTask.TaskInfo[LocalTaskId] then
          Logic_MainTask.TaskInfo[LocalTaskId].state = ETaskState.GotAward
          EventSystem.Invoke(EventDef.MainTask.OnMainTaskFinish, self.SourceId, LocalTaskId)
          EventSystem.Invoke(EventDef.MainTask.OnMainTaskChange, self.SourceId, LocalTaskId, true, false)
        end
        if self.OnConfirmClickFunc then
          self.OnConfirmClickFunc()
        end
        EventSystem.Invoke(EventDef.MainTask.OnReceiveAward, nil, self.SourceId, LocalTaskId)
        Logic_MainTask.OnReceiveAward(LocalTaskId)
        Logic_MainTask.PullTask({
          self.SourceId
        })
      end
    }, {
      GameInstance,
      function()
        print("ReceiveAwardFaill")
      end
    })
  elseif self.Type == _G.EOptionalGiftType.Mall then
    if self.OnConfirmClickFunc then
      self.OnConfirmClickFunc(optionalGiftInfos)
    end
  elseif self.OnConfirmClickFunc then
    self.OnConfirmClickFunc(optionalGiftInfos)
  end
end
function WBP_OptionalGiftMsgWaveWindow_C:K2_OnCancelClick()
end
function WBP_OptionalGiftMsgWaveWindow_C:K2_CloseWaveWindow()
  CloseWaveWindow(self)
  self:SetEnhancedInputActionBlocking(false)
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.K2_CloseWaveWindow)
end
function WBP_OptionalGiftMsgWaveWindow_C:SetMultipleSelection(IsMultipleSelection)
end
return WBP_OptionalGiftMsgWaveWindow_C
