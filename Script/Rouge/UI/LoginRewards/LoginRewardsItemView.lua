local rapidjson = require("rapidjson")
local RedDotData = require("Modules.RedDot.RedDotData")
local LoginRewardsItemView = UnLua.Class()

function LoginRewardsItemView:Construct()
end

function LoginRewardsItemView:InitLoginRewardsItem(Index, bReceive)
  local IsNewCreate = RedDotData:CreateRedDotState("Event_LoginReward_Item_" .. Index, "Event_LoginReward_Item")
  local RedDotState = {}
  if IsNewCreate then
    RedDotState.Num = 1
  end
  RedDotData:UpdateRedDotState("Event_LoginReward_Item_" .. Index, RedDotState)
  self.WBP_RedDotView:ChangeRedDotIdByTag(Index)
  self.Index = Index
  self:InitShowTime(Index)
  local bItem = false
  local Config = LuaTableMgr.GetLuaTableByName(TableNames.TBSevenDayLogin)
  if Config and Config[Index].showType then
    bItem = 2 == Config[Index].showType
  end
  if bItem then
    self:InitItem(Index)
  else
    self:InitSkin(Index)
  end
  local ServerOpenTime = DataMgr:GetServerOpenTime()
  local LocalTime = tonumber(GetCurrentUTCTimestamp())
  if bReceive then
    self:SetStatus(2)
    return
  end
  if LocalTime > ServerOpenTime + 86400 * Index then
    self:SetStatus(1)
  elseif LocalTime < ServerOpenTime + 86400 * Index and LocalTime > ServerOpenTime + 86400 * (Index - 1) then
    self:SetStatus(1)
  else
    self:SetStatus(0)
  end
end

function LoginRewardsItemView:GetToolTipWidget()
  if self.bSkin then
    local Config = LuaTableMgr.GetLuaTableByName(TableNames.TBSevenDayLogin)
    if Config[self.Index] and Config[self.Index].RewardList then
      return GetItemDetailWidget(Config[self.Index].RewardList[1].key)
    end
  end
end

function LoginRewardsItemView:InitShowTime(Index)
  local Config = LuaTableMgr.GetLuaTableByName(TableNames.TBSevenDayLogin)
  if Config and Config[Index].unLockTime then
    self.RGTextBlock_Time:SetText(Config[Index].unLockTime)
    self.RGTextBlock_Time_1:SetText(Config[Index].unLockTime)
  end
end

function LoginRewardsItemView:InitSkin(Index)
  UpdateVisibility(self.Skin, true)
  local Config = LuaTableMgr.GetLuaTableByName(TableNames.TBSevenDayLogin)
  if Config[Index] and Config[Index].Icon then
    SetImageBrushByPath(self.URGImage_Icon, Config[Index].Icon)
  end
  self.bSkin = true
end

function LoginRewardsItemView:InitItem(Index)
  UpdateVisibility(self.Item, true)
  local Config = LuaTableMgr.GetLuaTableByName(TableNames.TBSevenDayLogin)
  if Config[Index] then
    local RewardList = Config[Index].RewardList
    self.WrapBox_387:ClearChildren()
    for index, value in ipairs(RewardList) do
      local Widget = GetItemWidget(value.key, value.value)
      self.WrapBox_387:AddChild(Widget)
      if 2 == index and self.WrapBox_387.Slot then
        self.WrapBox_387.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
        self.ScaleBox_6:SetUserSpecifiedScale(0.31)
      end
    end
  end
  self.bSkin = false
end

function LoginRewardsItemView:SetStatus(StatusId)
  self.StatusId = StatusId
  self.WBP_RedDotView:SetNum(0)
  if 0 == StatusId then
    UpdateVisibility(self.CanvasPanel_unclaimed, true)
    UpdateVisibility(self.CanvasPanel_Time, true)
  elseif 1 == StatusId then
    self.WBP_RedDotView:SetNum(1)
    UpdateVisibility(self.CanvasPanel_Receive, true)
    UpdateVisibility(self.projection, true)
    UpdateVisibility(self.CanvasPanel_Time_Red, true)
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UpdateVisibility(self.WBP_GenericModifyTipsChangeHover_Group_6, true)
      end
    }, 0.5, false)
  elseif 2 == StatusId then
    UpdateVisibility(self.CanvasPanel_Time, true)
    UpdateVisibility(self.Overlay_Received, true)
    UpdateVisibility(self.CanvasPanel_Receive, false)
    UpdateVisibility(self.projection, false)
    UpdateVisibility(self.CanvasPanel_Time_Red, false)
    UpdateVisibility(self.WBP_GenericModifyTipsChangeHover_Group_6, false)
  end
end

function LoginRewardsItemView:CloseAnim()
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      UpdateVisibility(self.WBP_GenericModifyTipsChangeHover_Group_6, false)
    end
  }, 0.05, false)
end

function LoginRewardsItemView:OnHover()
  self.RGStateController_Hover:ChangeStatus("Hover", true)
end

function LoginRewardsItemView:OnUnHover()
  self.RGStateController_Hover:ChangeStatus("UnHover", true)
end

function LoginRewardsItemView:OnMouseEnter(MyGeometry, MouseEvent)
  self:OnHover()
end

function LoginRewardsItemView:OnMouseLeave(MyGeometry, MouseEvent)
  self:OnUnHover()
end

function LoginRewardsItemView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    if 1 ~= self.StatusId then
      print("\228\184\141\230\152\175\229\143\175\228\187\165\233\162\134\229\143\150\231\154\132\231\138\182\230\128\129")
      return
    end
    local Path = "playergrowth/sevendaylogin/getreward"
    HttpCommunication.Request(Path, {
      day = self.Index
    }, {
      self,
      function(Target, JsonResponse)
        local JsonTable = rapidjson.decode(JsonResponse.Content)
        self:InitLoginRewardsItem(self.Index, true)
        local VM = UIModelMgr:Get("LoginRewardsViewModel")
        if VM then
          table.insert(VM.Rewards, self.Index)
        end
      end
    }, {
      self,
      function()
      end
    }, false, true)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

return LoginRewardsItemView
