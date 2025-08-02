local ESlateVisibility = UE.ESlateVisibility
local UIUtil = {ViewportScale = nil, ViewportScreenSize = nil}

function UIUtil.IsVisible(widget)
  if nil == widget or UE.RGUtil.IsUObjectValid(widget) == false or false == widget:IsValid() then
    print("UIUtil.IsVisible widget is nil or pending kill.")
    return false
  end
  local visibility = widget:GetVisibility()
  return visibility == UE.ESlateVisibility.SelfHitTestInvisible or visibility == UE.ESlateVisibility.Visible
end

function UIUtil.SetVisibility(widget, visible)
  UIUtil.SetVisibilityNoHidden(widget, visible, false)
end

function UIUtil.SetVisibilityNoHidden(widget, bVisible, bHitTest)
  if nil == widget or UE.RGUtil.IsUObjectValid(widget) == false then
    print("UIUtil.SetUIVisibilityNoHidden - widget is nil or pending kill.")
  end
  if bHitTest then
    widget:SetVisibility(bVisible and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
  else
    widget:SetVisibility(bVisible and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Collapsed)
  end
end

function UIUtil.SetVisibilityWithHidden(widget, bVisible, bHitTest)
  if not widget then
    print("UIUtil.SetUIVisibilityWithHidden - widget is nil.")
  end
  if bHitTest then
    widget:SetVisibility(bVisible and ESlateVisibility.Visible or ESlateVisibility.Hidden)
  else
    widget:SetVisibility(bVisible and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Hidden)
  end
end

function UIUtil.MySplit(inputStr, sep)
  if nil == sep then
    sep = "%s"
  end
  local t, i = {}, 1
  for str in string.gmatch(inputStr, "([^" .. sep .. "]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function UIUtil.GetUIBPName(uibpUrl)
  local strArr = UIUtil.MySplit(uibpUrl, "/")
  local nameStr = strArr[#strArr]
  return nameStr
end

function UIUtil.GetWidgetLuaCtrl(uibpUrl, ...)
  local uibpInst
  local uibpClass = UE.LoadClass(uibpUrl)
  if uibpClass then
    local bpName = UIUtil.GetUIBPName(uibpUrl)
    uibpInst = UIMgr:CreateWidget(uibpClass, bpName, false)
  end
  if uibpInst and uibpInst.OnInit then
    uibpInst:OnInit(...)
  end
  return uibpInst
end

local ClearViewAndVMBinds = function(luaInstance)
  for k, v in pairs(luaInstance) do
    if type(v) == "table" and "MapMarkParentPanel" ~= k then
      if v and v._isDefaultViewModelType and luaInstance.Super then
        if luaInstance.Super.DettachViewModel then
          luaInstance.Super:DettachViewModel(v, luaInstance.DataBindTable, luaInstance)
        end
      elseif v._isViewBaseType then
        for key, value in pairs(v) do
          if value and type(value) == "table" and value._isDefaultViewModelType and v.Super and v.Super.DettachViewModel then
            v.Super:DettachViewModel(value, v.DataBindTable, v)
          end
        end
      end
    end
  end
end
local ClearButtonDelegate = function(luaInstance)
  if not (luaInstance and luaInstance.Object) or not UE.RGUtil.IsUObjectValid(luaInstance.Object) then
    return
  end
  for k, v in pairs(luaInstance) do
    if type(v) == "userdata" then
      local FindStart, FindEnd = string.find(tostring(v), "UButton:", 1)
      if FindStart and UE.RGUtil.IsUObjectValid(v) then
        v.OnClicked:Clear()
        v.OnPressed:Clear()
      end
    elseif type(v) == "table" and v.Object and UE.RGUtil.IsUObjectValid(v.Object) then
      local FindStart, FindEnd = string.find(tostring(v.Object), "UTabListPanel", 1)
      if FindStart and v.TabClickEvent then
        v.TabClickEvent:Clear()
      end
    end
  end
end

function UIUtil.ClearWhenDestroy(luaInstance)
  ClearButtonDelegate(luaInstance)
  ClearViewAndVMBinds(luaInstance)
end

return UIUtil
