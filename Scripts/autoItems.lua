--<< Phase boots, bottle in fountain, magic stick when low >>

--===================--
--     LIBRARIES     --
--===================--
require("libs.ScriptConfig")
require("libs.Utils")

--===================--
--      CONFIG       --
--===================--
config = ScriptConfig.new()
config:SetParameter("Bottle", true)
config:SetParameter("PhaseBoots", true)
config:SetParameter("MagicStick", true)
config:Load()

local enableBottle     = config.Bottle
local enablePhaseBoots = config.PhaseBoots
local enableMagicStick = config.MagicStick
local useStickAt       = 0.2 -- 20% HP
local range            = 1000

--===================--
--       CODE        --
--===================--

function Tick( tick )
	if not client.connected or client.loading or client.console or not SleepCheck("AutoItems") then
		return
	end

	local me = entityList:GetMyHero()
	if not me then return end Sleep(125)

	local bottle     = me:FindItem("item_bottle")
	local phaseboots = me:FindItem("item_phase_boots")
	local lowstick   = me:FindItem("item_magic_stick")
	local gradestick = me:FindItem("item_magic_wand")
	local stick      = lowstick and lowstick or gradestick

	if me.alive and not me:IsUnitState(LuaEntityNPC.STATE_INVISIBLE) and not me:IsChanneling() then

		if enableBottle and bottle and me:DoesHaveModifier("modifier_fountain_aura_buff") and not me:DoesHaveModifier("modifier_bottle_regeneration") and (me.health < me.maxHealth or me.mana < me.maxMana) then
			me:SafeCastItem(bottle.name)
		end

		if enablePhaseBoots and phaseboots then
			me:SafeCastItem(phaseboots.name)
		end

		if enableMagicStick and stick and stick.charges > 0 and (me.health/me.maxHealth < useStickAt) then
			me:SafeCastItem(stick.name)
		end

	end

	Sleep(250 + client.latency, "AutoItems")
end

script:RegisterEvent(EVENT_TICK,Tick)
