local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local RedDotData = require("Modules.RedDot.RedDotData")
local WBP_IGuide_PlotFragmentsDetail_C = UnLua.Class()
function WBP_IGuide_PlotFragmentsDetail_C:Construct()
  self.Btn_ReceiveAward.OnClicked:Add(self, self.BindOnReceiveAward)
end
function WBP_IGuide_PlotFragmentsDetail_C:Destruct()
  self.Btn_ReceiveAward.OnClicked:Remove(self, self.BindOnReceiveAward)
end
function WBP_IGuide_PlotFragmentsDetail_C:InitInfo(FragmentId, Level)
  self.FragmentId = FragmentId
  self.ClueId = -1
  local FragmentInfo = IllustratedGuideData:GetPlotFragmentInfoByFragmentId(FragmentId)
  local ClueInfo = IllustratedGuideData:GetClueInfoByClueId(IllustratedGuideData.CurrentClueId)
  local TaskId = FragmentInfo.taskID
  if TaskId then
    local TaskInfo = Logic_MainTask.GetTaskInfoByTaskId(TaskId)
    local TaskState = Logic_MainTask.GetStateByTaskId(TaskId)
    if not table.Contain({2, 3}, TaskState) then
      self:RefreshUnFinishedUIByInfo(tostring(TaskInfo.content), ClueInfo.title, TaskId, TaskInfo.rewardlist, TaskState)
    else
      self:RefreshFinishedUIByInfo(FragmentInfo.image, FragmentInfo.title, FragmentInfo.content, ClueInfo.title, TaskInfo.rewardlist, TaskState)
      if 3 == TaskState then
        RedDotData:SetRedDotNum("Piece_Item_Num_" .. IllustratedGuideData.CurrentClueId .. "_" .. FragmentId, 0)
      end
    end
  end
  if self.Level ~= Level then
    self:PlayAnimationForward(self["Ani_in_" .. Level])
    self.Level = Level
  end
end
function WBP_IGuide_PlotFragmentsDetail_C:InitInfoByClueId(ClueId, Level)
  self.FragmentId = -1
  self.ClueId = ClueId
  local ClueInfo = IllustratedGuideData:GetClueInfoByClueId(ClueId)
  self:RefreshFinishedUIByInfo(ClueInfo.image, ClueInfo.titleDesc, ClueInfo.content, ClueInfo.title)
  if self.Level ~= Level then
    self:PlayAnimationForward(self["Ani_in_" .. Level])
    self.Level = Level
  end
end
function WBP_IGuide_PlotFragmentsDetail_C:RefreshUnFinishedUIByInfo(Desc, Level, TaskId, RewardList, TaskState)
  UpdateVisibility(self.SclBox_Unlock, false)
  UpdateVisibility(self.SclBox_Lock, true)
  local FirstCount = tonumber(Logic_MainTask.GetFirstCountValueByTaskId(TaskId))
  local TargetCount = tonumber(Logic_MainTask.GetFirstTargetValueByTaskId(TaskId))
  self.Txt_TaskDesc:SetText(Desc)
  self.Txt_DetailLevel_1:SetText(Level)
  self.Txt_Progress:SetText(FirstCount .. "/" .. TargetCount)
  self.Progress_Task:SetPercent(FirstCount / TargetCount)
  self:RefreshRewardList(RewardList, TaskState)
end
function WBP_IGuide_PlotFragmentsDetail_C:RefreshFinishedUIByInfo(ImagePath, Name, Desc, Level, RewardList, TaskState)
  UpdateVisibility(self.SclBox_Unlock, true)
  UpdateVisibility(self.SclBox_Lock, false)
  Desc = tostring(Desc)
  if "" ~= ImagePath and "" ~= Desc then
    UpdateVisibility(self.Canvas_Image, true)
    UpdateVisibility(self.Canvas_FragmentIcon, true)
    UpdateVisibility(self.Img_FragmentBigIcon, false)
    SetImageBrushByPath(self.Img_FragmentIcon, ImagePath)
    UpdateVisibility(self.SclBox_text, true)
    self.Txt_DetailName:SetText(Name)
    self.Txt_Desc:SetText(Desc)
    self.Txt_DetailLevel:SetText(Level)
  elseif "" ~= Desc then
    UpdateVisibility(self.Canvas_Image, false)
    UpdateVisibility(self.SclBox_text, true)
    self.Txt_DetailName:SetText(Name)
    self.Txt_Desc:SetText(Desc)
    self.Txt_DetailLevel:SetText(Level)
  elseif "" ~= ImagePath then
    UpdateVisibility(self.Canvas_Image, true)
    UpdateVisibility(self.Canvas_FragmentIcon, false)
    UpdateVisibility(self.Img_FragmentBigIcon, true)
    SetImageBrushByPath(self.Img_FragmentBigIcon, ImagePath)
    UpdateVisibility(self.SclBox_text, false)
  end
  self:RefreshRewardList(RewardList, TaskState)
end
function WBP_IGuide_PlotFragmentsDetail_C:RefreshRewardList(RewardList, TaskState)
  if RewardList and #RewardList > 0 then
    UpdateVisibility(self.Canvas_Reward, true)
    local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    for i, v in ipairs(RewardList) do
      if tbGeneral and tbGeneral[v.key] then
        local item = GetOrCreateItem(self.ScrollBoxAward, i, self.WBP_Item:GetClass())
        local itemSlotTemplate = UE.UWidgetLayoutLibrary.SlotAsScrollBoxSlot(self.WBP_Item)
        local itemSlot = UE.UWidgetLayoutLibrary.SlotAsScrollBoxSlot(item)
        if itemSlot then
          itemSlot:SetPadding(itemSlotTemplate.Padding)
        end
        item:InitItem(v.key, v.value)
        if 3 == TaskState then
          item:UpdateReceivedPanelVis(true)
        else
          item:UpdateReceivedPanelVis(false)
        end
      end
    end
    HideOtherItem(self.ScrollBoxAward, #RewardList + 1)
    self:BindOnReceiveAward()
  else
    UpdateVisibility(self.Canvas_Reward, false)
  end
end
function WBP_IGuide_PlotFragmentsDetail_C:Hide()
  if self:IsVisible() then
    self.Level = nil
    self:PlayAnimationForward(self.Ani_out)
  end
end
function WBP_IGuide_PlotFragmentsDetail_C:BindOnReceiveAward()
  local FragmentInfo = IllustratedGuideData:GetPlotFragmentInfoByFragmentId(self.FragmentId)
  local TaskId = FragmentInfo.taskID
  local TaskState = Logic_MainTask.GetStateByTaskId(TaskId)
  local ClueInfo = IllustratedGuideData:GetClueInfoByClueId(IllustratedGuideData.CurrentClueId)
  if 2 == TaskState then
    Logic_MainTask.ReceiveAward(ClueInfo.taskGroupID, TaskId, false, function()
      self:InitInfo(self.FragmentId, self.Level)
    end, self)
  end
end
function WBP_IGuide_PlotFragmentsDetail_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end
return WBP_IGuide_PlotFragmentsDetail_C
