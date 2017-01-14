require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("GoFirstTrade")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
local BuyItem1 = {38,38,38,38,46,177}
local StepsOfBuy={BuyItem1}

local play, sleep = false, nil, {}, 0, 0


function Main(me)
	lineR = {Vector(-6178, 2081, 256)}
	lineD = {Vector(6182, -1934, 256)}
	if  ScriptConfig.Hotkey  then
	local me = entityList:GetMyHero()
		local playerEntity = entityList:GetEntities({classId=CDOTA_PlayerResource})[1]
		local gold = playerEntity:GetGold(me.playerId)
		for i, Step in ipairs(StepsOfBuy) do
			if me:DoesHaveModifier("modifier_fountain_aura_buff") then 
				for j, itemID in ipairs(Step) do
					entityList:GetMyPlayer():BuyItem(itemID)
					Sleep(20000)
				end
				Sleep(20000)
			end
			if me:DoesHaveModifier("modifier_fountain_aura_buff") and me:FindItem("item_tpscroll") then
					if me.team == LuaEntity.TEAM_RADIANT then
					me:CastAbility(me:FindItem("item_tpscroll"),lineR[1])
				Sleep(client.latency+400,"Fast")
						else
					me:CastAbility(me:FindItem("item_tpscroll"),lineD[1])
				Sleep(client.latency+400,"Fast")
					end
			end
		end
	end
end	

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Techies then 
			script:Disable()
		else
			play, target, myhero = true, nil, me.classId
			ScriptConfig:SetVisible(true)
			script:RegisterEvent(EVENT_TICK, Main)
			script:UnregisterEvent(Load)
		end
	end
end

function Close()
	target, myhero = nil, nil
	ScriptConfig:SetVisible(false)
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close) 
script:RegisterEvent(EVENT_TICK, Load)
