local rapidjson = require("rapidjson")
local RedDotData = require("Modules.RedDot.RedDotData")
local LoginRewardActivityItemView = UnLua.Class()

function LoginRewardActivityItemView:Construct()
end

function LoginRewardActivityItemView:InitLoginRewardActivityItem(Index, TaskId, TaskGroupId)
  self.Index = Index
  self.TaskId = TaskId
  self.TaskGroupId = TaskGroupId
  local taskInfo = Logic_MainTask.GetTaskInfoByTaskId(TaskId)
  local taskState = Logic_MainTask.GetStateByTaskId(TaskId)
  self.RGStateController_TaskState:ChangeStatus(taskState)
  self.RGTextBlock_Time:SetText(taskInfo.name)
  self.RGTextBlock_Time_1:SetText(taskInfo.name)
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local rewardList = taskInfo.rewardlist
  local rewardMaxRare = 0
  for i, reward in ipairs(rewardList) do
    rewardMaxRare = math.max(rewardMaxRare, tbGeneral[reward.key].Rare)
  end
  if rewardMaxRare >= 5 then
    self.RGStateController_BgColor:ChangeStatus("Special")
  else
    self.RGStateController_BgColor:ChangeStatus("Normal")
  end
  UpdateVisibility(self.SclBox_Skin, false)
  UpdateVisibility(self.Canvas_ItemList_New, false)
  self.WidgetShowList = {
    self.WBP_Item_4,
    self.WBP_Item_5,
    self.WBP_Item_6
  }
  if taskInfo.icon == "" then
    self:InitItem(rewardList)
  else
    self:InitSkin(taskInfo.icon)
  end
end

function LoginRewardActivityItemView:GetToolTipWidget()
end

function LoginRewardActivityItemView:InitSkin(ImagePath)
  self.bIsSkin = true
  UpdateVisibility(self.SclBox_Skin, true)
  SetImageBrushByPath(self.URGImage_Icon, ImagePath)
end

function LoginRewardActivityItemView:InitItem(RewardList)
  self.bIsSkin = false
  UpdateVisibility(self.Canvas_ItemList_New, true)
  for index, Widget in ipairs(self.WidgetShowList) do
    if RewardList[index] then
      UpdateVisibility(Widget, true)
      Widget:InitItem(RewardList[index].key, RewardList[index].value)
      if 2 == index and self.WrapBox_ItemList_1.Slot then
        self.WrapBox_ItemList_1.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
      end
    else
      UpdateVisibility(Widget, false)
    end
  end
end

function LoginRewardActivityItemView:CloseAnim()
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      UpdateVisibility(self.WBP_GenericModifyTipsChangeHover_Group_6, false)
    end
  }, 0.05, false)
end

function LoginRewardActivityItemView:OnHover()
  self.RGStateController_Hover:ChangeStatus("Hover", true)
  PlaySound2DByName(self.HoverSoundName, "LoginRewardActivityItemView")
end

function LoginRewardActivityItemView:OnUnHover()
  self.RGStateController_Hover:ChangeStatus("UnHover", true)
end

function LoginRewardActivityItemView:OnMouseEnter(MyGeometry, MouseEvent)
  self:OnHover()
  if self.bIsSkin then
    local taskInfo = Logic_MainTask.GetTaskInfoByTaskId(self.TaskId)
    local rewardList = taskInfo.rewardlist
    local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonItemDetail.WBP_CommonItemDetail_C"
    self.TipsWidget = ShowCommonTips(nil, self, self.TipsWidget, WidgetClassPath)
    self.TipsWidget:InitCommonItemDetail(rewardList[1].key)
  end
end

function LoginRewardActivityItemView:OnMouseLeave(MyGeometry, MouseEvent)
  self:OnUnHover()
  UpdateVisibility(self.TipsWidget)
end

function LoginRewardActivityItemView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    PlaySound2DByName(self.ClickSoundName, "LoginRewardActivityItemView")
    local taskState = Logic_MainTask.GetStateByTaskId(self.TaskId)
    if 2 == taskState then
      Logic_MainTask.ReceiveAward(self.TaskGroupId, self.TaskId, false, function()
        self:InitLoginRewardActivityItem(self.Index, self.TaskId, self.TaskGroupId)
      end, self)
    end
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

return LoginRewardActivityItemView
