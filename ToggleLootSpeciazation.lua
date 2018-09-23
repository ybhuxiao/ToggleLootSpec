--[[
todo
因为这个是按boss来的，如果是大秘境，就会导致最后boss的拾取专精，变成了大秘境箱子的专精
为了防止乌龙事件，大秘境开始就禁用这个插件，然后开始、结束的时候给个提示

CHALLENGE_MODE_START 大秘境开始的事件
事件开始   就把这个插件禁用   提示"插件已禁用，你当前的拾取专精是xxx"
结束再给个提示

level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
level >=2就禁用

]]--
--构造专精表
local spec_table = {}--kv
local spec_name_arr = {}--arr

--获取boss信息
--local name, description, bossID, rootSectionID, link = EJ_GetEncounterInfoByIndex(bossIndex);
local dropdownFrames={}

--set
local function SetBossSpec(bossID,bossName, specName)
  lootspecs[bossName] = specName
  --print(json.encode(lootspecs))
end

--ui
local function CreateDropDown(bossIndex, bossID, bossName, checkedSpecName)
  local baseFrame = _G["EncounterJournalBossButton"..bossIndex]
  local newFrameName = "EncounterJournalBossButton"..bossID.."DropDown"
  local newFrame = _G[newFrameName]
  if newFrame and not newFrame:IsVisible() then
    newFrame:Show()
    return
  end
  local checkValues = {"",unpack(spec_name_arr)}

  newFrame = CreateFrame("Button", "EncounterJournalBossButton"..bossIndex.."DropDown", baseFrame, "UIDropDownMenuTemplate")
  tinsert(dropdownFrames,newFrame)
  newFrame:SetPoint("TOPRIGHT", baseFrame,"BOTTOMRIGHT",15,20)--右下角，偏下

  local function OnClick(self)
    UIDropDownMenu_SetSelectedID(newFrame, self:GetID())
    --print(self:GetID(),self:GetText())
    local specName = self:GetText()
    SetBossSpec(bossID, bossName, specName)
  end

  local function initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for k, v in pairs(checkValues) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = OnClick
      UIDropDownMenu_AddButton(info, level)
    end
  end

  UIDropDownMenu_Initialize(newFrame, initialize)
  UIDropDownMenu_SetWidth(newFrame, 80);
  UIDropDownMenu_SetButtonWidth(newFrame, 80)
  UIDropDownMenu_SetSelectedID(newFrame, 1)
  UIDropDownMenu_JustifyText(newFrame, "LEFT")

  for k, v in pairs(checkValues) do
    if checkedSpecName and v==checkedSpecName then
    	UIDropDownMenu_SetSelectedID(newFrame, k)
    end
  end
end

--hook
local hookFrame = CreateFrame("Frame");
hookFrame:RegisterEvent("ADDON_LOADED");
hookFrame:SetScript("OnEvent", function(self, event,moduleName)
  if moduleName=="Blizzard_EncounterJournal" then
    local EncounterJournal_DisplayInstance_original = EncounterJournal_DisplayInstance
    EncounterJournal_DisplayInstance = function(self,instanceID, noButton)
      if noButton then return;end

      for i,v in ipairs(dropdownFrames) do
        v:Hide()
      end
      for bossIndex=1,50,1 do
        local name, description, bossID, rootSectionID, link = EJ_GetEncounterInfoByIndex(bossIndex)
        if not bossID then break;end
        CreateDropDown(bossIndex,bossID,name,GetLootSpecByBossName(name))
      end
      return EncounterJournal_DisplayInstance_original(self,instanceID, noButton)
    end
  end
end)

function GetLootSpecByBossName(bossName)
  local lootSpec = lootspecs[bossName]
  if lootSpec=="" or lootSpec==nil then lootSpec=nil;end
  return lootSpec
end

local enteringWorldFrame = CreateFrame("Frame")
enteringWorldFrame:SetScript("OnEvent", function()
  for i=1,4 do
    local specId, specName = GetSpecializationInfo(i)
    if specName then
      spec_table[specName]=specId
      tinsert(spec_name_arr,specName)
    end
  end

  lootspecs = lootspecs or {}
  print("ToggleLootSpeciazation加载完成，请在“冒险指南”中设置拾取专精，设置完成后，进入战斗就会自动切换专精。有bug可反馈给我QQ376665005")
end)
enteringWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

--onEncounterStart
function onEncounterStart(encounterName)
  --目标拾取专精
  local targetSpecName = lootspecs[encounterName]

  if targetSpecName==nil or targetSpecName=="" then
    print("当前boss未设置拾取专精");
    return;
  end--为空表示任何专精都ok
  local targetSpecId = spec_table[targetSpecName]

  --当前拾取专精id，例如神圣65、防护66、惩戒70
  local nowSpecId = GetLootSpecialization()


  --如果专精相同则不做处理，不相同，则切换到目标专精
  if targetSpecId~=nowSpecId then
    print("切换拾取专精为：",targetSpecName)
    SetLootSpecialization(targetSpecId)
  else
    print("不需要切换拾取专精")
  end
end

local encouterFrame = CreateFrame("Frame");
encouterFrame:RegisterEvent("ENCOUNTER_START");
encouterFrame:SetScript("OnEvent", function(self, event,...)
  local encounterID, encounterName, difficulty, size = ...
  local level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
  if level>1 then
    print("大秘境boss，不切换专精")
    return
  end
  onEncounterStart(encounterName)
end)
