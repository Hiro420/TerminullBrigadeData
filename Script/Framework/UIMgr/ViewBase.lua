local ViewBase = {
  ViewBaseMark_MakeUnique = true,
  bHideByOther = false,
  ViewID = nil
}
ViewBase.ViewModels = {}
ViewBase._isViewBaseType = true
function ViewBase:AttachViewModel(viewmodel, BindFunc, View)
  if UE_BUILD_SHIPPING == false then
    if not viewmodel then
      error("viewmodel can not be nil.")
    end
    if not BindFunc then
      error("BindFunc can not be nil.")
    end
    if not View then
      error("View can not be nil.")
    end
  end
  if nil ~= viewmodel and nil ~= View and viewmodel.RegisterPropertyChanged then
    viewmodel:RegisterPropertyChanged(BindFunc, View)
  end
end
function ViewBase:DetachViewModel(viewmodel, BindFunc, View)
  if UE_BUILD_SHIPPING == false then
    if not viewmodel then
      error("viewmodel can not be nil.")
    end
    if not BindFunc then
      error("BindFunc can not be nil.")
    end
    if not View then
      error("View can not be nil.")
    end
  end
  if nil ~= viewmodel and viewmodel.UnRegisterPropertyChanged then
    viewmodel:UnRegisterPropertyChanged(BindFunc, View)
  end
end
function ViewBase:DetachAllViewModel(viewmodel)
  if nil ~= viewmodel then
    viewmodel:UnRegisterAllPropertyChanged()
  end
end
return ViewBase
