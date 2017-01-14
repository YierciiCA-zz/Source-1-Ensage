--<<Zeus Ult Script by Raphaelpdc / edwynxero Version 1.0>>
--<<Updated Github>>

--LIBRARIES
require("libs.ScriptConfig")
require("libs.TargetFind")

--CONFIG
config = ScriptConfig.new()
config:SetParameter("ComboKey", "F", config.TYPE_HOTKEY)
config:SetParameter("UseULT", false)
config:SetParameter("TargetLeastHP", false)
config:Load()

--SETTINGS
local comboKey       = config.ComboKey
local useULT         = config.UseULT
local getLeastHP     = config.TargetLeastHP
local registered	 = false
local range          = 900

--CODE
local sleepMain     = 0
local currentMain   = 0
local target        = nil
local active        = false

--[[Loading Script...]]
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Zuus then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

--check if comboKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == comboKey then
		active = (msg == KEY_DOWN)
	end
end

function Main(tick)
	currentMain = tick
	if not SleepCheck() then return end Sleep(200)

	local me = entityList:GetMyHero()
	if not (me and active) then return end

	-- Get hero abilities --
	local Arc            = me:GetAbility(1)
	local LightBolt      = me:GetAbility(2)
	local Static         = me:GetAbility(3)
	local Thunder        = me:GetAbility(4)

	-- Get visible enemies --
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})

	for i,v in ipairs(enemies) do
		local distance = GetDistance2D(v,me)

		-- Get a valid target in range --
		if not target and distance < range then
			target = v
		end

		-- Get the closest / least health target --
		if target then
			if getLeastHP and distance < range then
				target = targetFind:GetLowestEHP(range,"magic")
			elseif distance < GetDistance2D(target,me) and target.alive then
				target = v
			elseif GetDistance2D(target,me) > range or not target.alive then
				target = nil
				active = false
			end
		end
	end

	-- Do the combo! --
	if target and me.alive then
		CastSpell(Arc, target)
		CastSpell(LightBolt, target)
		if useULT then
			CastSpell(Thunder, true)
		end
		return
	end

end

function CastSpell(spell,victim, isQueued)
	if spell.state == LuaEntityAbility.STATE_READY then
		if victim == nil then
			entityList:GetMyPlayer():UseAbility(spell)
		elseif isQueued == nil then
			entityList:GetMyPlayer():UseAbility(spell, victim)
		else
			entityList:GetMyPlayer():UseAbility(spell, victim, isQueued)
		end
	end
end

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
