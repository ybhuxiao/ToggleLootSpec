--获取boss信息
--local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);


--修改配置的规则：需要切换的，对应的boss后写一下需要切的专精，如果该boss专精无所谓，就空着也行
local lootspecs = {
  ["围攻伯拉勒斯"]={
    ["拜恩比吉中士"]="惩戒",
    ["恐怖船长洛克伍德"]="防护",
    ["哈达尔·黑渊"]="惩戒",
    ["维克戈斯"]=""
  },
  ["地渊孢林"]={
    ["长者莉娅克萨"]="神圣",
    ["被感染的岩喉"]="",
    ["孢子召唤师赞查"]="神圣",--神圣副手、防护饰品、惩戒双手斧
    ["不羁畸变怪"]="惩戒"
  },
  ["塞塔里斯神庙"]={
    ["阿德里斯和阿斯匹克斯"]="",
    ["米利克萨"]="惩戒",
    ["加瓦兹特"]="神圣",
    ["塞塔里斯的化身"]="神圣"--神圣饰品、防骑单手
  },
  ["托尔达戈"]={
    ["泥沙女王"]="",
    ["杰斯·豪里斯"]="神圣",--神圣副手、防护饰品
    ["骑士队长瓦莱莉"]="神圣",
    ["科古斯狱长"]="防护"
  },
  ["暴富矿区！！"]={
    ["投币式群体打击者"]="神圣",--神圣副手，惩戒双手剑
    ["艾泽洛克"]="",
    ["瑞克莎·流火"]="",
    ["商业大亨拉兹敦克"]="神圣"--神圣副手、防护饰品
  },
  ["维克雷斯庄园"]={
    ["毒心三姝"]="",
    ["魂缚巨像"]="神圣",
    ["贪食的拉尔"]="防护",
    ["维克雷斯夫人"]="神圣",--维克雷斯勋爵和夫人
    ["高莱克·图尔"]=""
  },
  ["自由镇"]={
    ["天空上尉库拉格"]="防护",
    ["拉乌尔船长"]="",--海盗议会
    ["鲨鱼拳击手"]="惩戒",--藏宝竞技场
    ["哈兰·斯威提"]=""
  },
  ["诸王之眠"]={
    ["黄金风蛇"]="",
    ["殓尸者姆沁巴"]="防护",
    ["部族议会"]="",
    ["始皇达萨"]=""
  },
  ["阿塔达萨"]={
    ["女祭司阿伦扎"]="",
    ["沃卡尔"]="防护",
    ["莱赞"]="防护",
    ["亚兹玛"]=""
  },
  ["风暴神殿"]={
    ["阿库希尔"]="惩戒",
    ["海贤议会"]="",
    ["斯托颂勋爵"]="",
    ["低语者沃尔兹斯"]=""
  }
}
--构造专精表
local spectable = {}

local enteringWorldFrame = CreateFrame("Frame")
enteringWorldFrame:SetScript("OnEvent", function()
  for i=1,4 do
    local specId, specName = GetSpecializationInfo(i)
    if specName then
      spectable[specName]=specId
    end
  end
  print("_ToggleLootSpeciazation加载完成。")
end)
enteringWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

--onEnterCombat
function onEnterCombat()
  print("进入战斗")
  if not IsInInstance() then return;end
  --获取副本信息
  local zone = GetRealZoneText()
  local instance = lootspecs[zone]
  if not instance then return;end

  --获取当前boss信息
  local bossname = UnitName("boss1")
  if not bossname then return;end

  if instance[bossname]==nil then--为nil表示进入boss战斗了，但是boss信息不存在，通常发生在多个boss的场景，需要特殊处理
    print("bossname不存在：",zone,bossname)
    return;
  end

  --目标拾取专精
  local targetSpecName = instance[bossname]
  if targetSpecName=="" then return;end--为空表示任何专精都ok
  local targetSpecId = spectable[targetSpecName]

  --当前拾取专精id，例如神圣65、防护66、惩戒70
  local nowSpecId = GetLootSpecialization()


  --如果专精相同则不做处理，不相同，则切换到目标专精
  if targetSpecId~=nowSpecId then
    print("切换拾取专精为：",targetSpecName)
    SetLootSpecialization(targetSpecId)
    --PrintLootSpecialization()
  end
end

local combatevent = CreateFrame("Frame");
combatevent:RegisterEvent("PLAYER_ENTER_COMBAT");
combatevent:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTER_COMBAT" then
		onEnterCombat()
	end
end)

