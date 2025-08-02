local WBP_IGuide_SM_SMGroup_C = UnLua.Class()

function WBP_IGuide_SM_SMGroup_C:Construct()
  self.Btn_Previous.OnClicked:Add(self, self.BindOnPreviousButtonClicked)
  self.Btn_Next.OnClicked:Add(self, self.BindOnNextButtonClicked)
  self.SpecificModifyListMaxLength = self.Hrz_SpecificModifyList:GetChildrenCount()
  self.SpecificModifyList = {}
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnSpecificModifyItemClicked, self.BindOnSpecificModifyItemClicked)
end

function WBP_IGuide_SM_SMGroup_C:Destruct()
  self.Btn_Previous.OnClicked:Remove(self, self.BindOnPreviousButtonClicked)
  self.Btn_Next.OnClicked:Remove(self, self.BindOnNextButtonClicked)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnSpecificModifyItemClicked, self.BindOnSpecificModifyItemClicked, self)
end

function WBP_IGuide_SM_SMGroup_C:BindOnPreviousButtonClicked()
  self.NowStartIndex = math.max(1, self.NowStartIndex - self.SpecificModifyListMaxLength)
  self:UpdateSpecificModifyList(self.NowStartIndex)
end

function WBP_IGuide_SM_SMGroup_C:BindOnNextButtonClicked()
  local TempNowStartIndex = self.NowStartIndex + self.SpecificModifyListMaxLength
  if TempNowStartIndex > #self.SpecificModifyList then
    return
  end
  self.NowStartIndex = TempNowStartIndex
  self:UpdateSpecificModifyList(self.NowStartIndex)
end

function WBP_IGuide_SM_SMGroup_C:RefreshInfo(ParentView, HeroId, SpecificModifyGroupInfo)
  self.ParentView = ParentView
  local SkillList = LogicRole.GetCharacterTableRow(HeroId).SkillList
  local SkillIconMap = {}
  self.Txt_ClassName:SetText(SpecificModifyGroupInfo.GroupName)
  local IconPathStr = UE.UKismetSystemLibrary.BreakSoftObjectPath(SpecificModifyGroupInfo.Icon)
  if "" == IconPathStr then
    local SkillEnumMap = {}
    SkillEnumMap[UE.ERGModSkillType.QSkill] = TableEnums.ENUMSkillType.Q
    SkillEnumMap[UE.ERGModSkillType.ESkill] = TableEnums.ENUMSkillType.E
    SkillEnumMap[UE.ERGModSkillType.CSkill] = TableEnums.ENUMSkillType.Alt
    SkillEnumMap[UE.ERGModSkillType.WeaponSkill] = TableEnums.ENUMSkillType.Weapon
    SkillEnumMap[UE.ERGModSkillType.Passive] = TableEnums.ENUMSkillType.Passive
    local SkillType = SkillEnumMap[SpecificModifyGroupInfo.SkillType]
    for k, v in pairs(SkillList) do
      local SkillGroupInfo = LogicRole.GetSkillTableRow(v)
      if SkillGroupInfo[1].Type == SkillType then
        SetImageBrushByPath(self.Img_ClassIcon, SkillGroupInfo[1].IconPath)
      end
    end
  else
    SetImageBrushBySoftObjectPath(self.Img_ClassIcon, SpecificModifyGroupInfo.Icon)
  end
  local ResultHero, HeroData = GetRowData(DT.DT_Hero, tostring(HeroId))
  if ResultHero then
    local LegendList = HeroData.ModConfig.LegendConfig.LegendList
    local TempSpecificModifyList = LegendList:ToTable()
    self.SpecificModifyList = {}
    for k, v in pairs(TempSpecificModifyList) do
      local Result, RowData = GetRowData(DT.DT_ModRefresh, tostring(v))
      if Result and RowData.SkillType == SpecificModifyGroupInfo.SkillType then
        table.insert(self.SpecificModifyList, v)
      end
    end
    table.sort(self.SpecificModifyList, function(A, B)
      local UnLockedA = UIModelMgr:Get("IllustratedGuideSpecificModifyViewModel"):CheckOwnedSpecificModify(A)
      local UnLockedB = UIModelMgr:Get("IllustratedGuideSpecificModifyViewModel"):CheckOwnedSpecificModify(B)
      if UnLockedA ~= UnLockedB then
        return UnLockedA
      end
      return A < B
    end)
    self.NowStartIndex = 1
    self:UpdateSpecificModifyList(self.NowStartIndex)
  end
  self.WBP_RedDotView:ChangeRedDotIdByTag(HeroId .. "_" .. SpecificModifyGroupInfo.SkillType)
  self.WBP_CustomKeyName:SetCustomKeyDisplayInfoByRowNameAry(SpecificModifyGroupInfo.CustomKeyRowNameList.KMKeyRowNameList:ToTable(), SpecificModifyGroupInfo.CustomKeyRowNameList.PadKeyRowNameList:ToTable())
  UpdateVisibility(self.WBP_CustomKeyName, SpecificModifyGroupInfo.CustomKeyRowNameList.KMKeyRowNameList:Length() > 0)
end

function WBP_IGuide_SM_SMGroup_C:UpdateSpecificModifyList(StartIndex)
  local NeedShowSpecificModifyList = {}
  for k, v in pairs(self.SpecificModifyList) do
    if StartIndex <= k and k < StartIndex + self.SpecificModifyListMaxLength then
      table.insert(NeedShowSpecificModifyList, v)
    end
  end
  for k, v in pairs(NeedShowSpecificModifyList) do
    local Item = self.Hrz_SpecificModifyList:GetChildAt(k - 1)
    Item:RefreshInfo(self.ParentView, v)
  end
  HideOtherItem(self.Hrz_SpecificModifyList, #NeedShowSpecificModifyList + 1)
  if #self.SpecificModifyList > self.MaxItemCount then
    if StartIndex + self.SpecificModifyListMaxLength > #self.SpecificModifyList then
      UpdateVisibility(self.Btn_Next, true, false)
      self.Img_BtnNextArrow:SetColorAndOpacity(self.BtnArrowColor_Disable)
    else
      UpdateVisibility(self.Btn_Next, true, true)
      self.Img_BtnNextArrow:SetColorAndOpacity(self.BtnArrowColor_Normal)
    end
    if StartIndex - self.SpecificModifyListMaxLength < 0 then
      UpdateVisibility(self.Btn_Previous, true, false)
      self.Img_BtnPreviousArrow:SetColorAndOpacity(self.BtnArrowColor_Disable)
    else
      UpdateVisibility(self.Btn_Previous, true, true)
      self.Img_BtnPreviousArrow:SetColorAndOpacity(self.BtnArrowColor_Normal)
    end
  else
    UpdateVisibility(self.Btn_Next, false)
    UpdateVisibility(self.Btn_Previous, false)
  end
end

function WBP_IGuide_SM_SMGroup_C:BindOnSpecificModifyItemClicked(SpecificModifyId)
  if table.Contain(self.SpecificModifyList, SpecificModifyId) then
    UpdateVisibility(self.Canvas_Checked, true)
    UpdateVisibility(self.Canvas_Unchecked, false)
  else
    UpdateVisibility(self.Canvas_Checked, false)
    UpdateVisibility(self.Canvas_Unchecked, true)
  end
end

function WBP_IGuide_SM_SMGroup_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_IGuide_SM_SMGroup_C
