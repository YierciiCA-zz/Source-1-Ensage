--<<Auto Q after W when enemy in your way.>>

require("libs.Utils")
require('libs.HotkeyConfig2')
require("libs.Skillshot")

local play = false

--CONFIG
local lowUltPriority = true
--END

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Simple Combo")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("QS","Toggle",SGC_TYPE_TOGGLE,false,true,nil)

function ShredderTick(tick)
	if not ScriptConfig.QS or not SleepCheck() or client.paused then return end
	
	local me = entityList:GetMyHero()
	local enemy = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 900 end)
	
	if me:DoesHaveModifier("modifier_shredder_timber_chain") then
		local Q  = me:GetAbility(1)
		
		-- First Skill
		if Q and Q:CanBeCasted() then
			for i,v in ipairs(enemy) do
				if Q:CanBeCasted() and v.health > 0 and not v:IsMagicDmgImmune() and me:GetDistance2D(v) < 300 then
					me:CastAbility(Q)
				end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()	
		if me.classId == CDOTA_Unit_Hero_Shredder then			
			play = true
			ScriptConfig:SetVisible(true)
			script:RegisterEvent(EVENT_TICK,ShredderTick)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()	
	if play then
		script:UnregisterEvent(ShredderTick)
		script:RegisterEvent(EVENT_TICK,Load)
		ScriptConfig:SetVisible(false)
		play = false
		activated = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
