--<<Auto Q after W. Hold W (default) when ember uses fist. d.l.>>

require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "W", config.TYPE_HOTKEY)
config:Load()

local key = config.Hotkey
local play = false
local activated = false

function EmberKey(msg,code)

	if msg == KEY_DOWN and not client.chat and code == key then
		activated = true
	else
		activated = false
	end

end

function EmberTick(tick)

	if not activated or not SleepCheck() then return end

	local me = entityList:GetMyHero()

	local enemy = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive = true,team = (5-me.team),illusion = false})
	local w_ = me:GetAbility(1)
	if w_.state == -1 and me:DoesHaveModifier("modifier_ember_spirit_sleight_of_fist_caster") then
		for i,v in ipairs(enemy) do
			if v.health > 0 and not v:IsMagicDmgImmune() and me:GetDistance2D(v) < 400 then
				me:CastAbility(w_)
				activated = false
				Sleep(1000)
			end
		end
	end			

end


function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()	
		if me.classId == CDOTA_Unit_Hero_EmberSpirit then			
			play = true
			script:RegisterEvent(EVENT_KEY,EmberKey)
			script:RegisterEvent(EVENT_FRAME,EmberTick)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()	
	if play then
		script:UnregisterEvent(EmberKey)
		script:UnregisterEvent(EmberTick)
		script:RegisterEvent(EVENT_TICK,Load)		
		play = false
		activated = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
