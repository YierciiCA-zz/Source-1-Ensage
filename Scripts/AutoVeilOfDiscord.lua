--<<Auto Veil of Discord V1.0B ✰ - by ☢bruninjaman☢>>--
--[[
☑ Script Requested by VickTheRock.
☛ This script do?
☑ Use blink and veil of discord.
********************************************************************************
♜ Change Log ♜
➩ V1.0B - Monday, March 9, 2015 - Added tp.
➩ V1.0A - Wednesday, March 4, 2015 - New Version Released.
]]
-- ✖ Libraries ✖ --
require("libs.Utils")
require("libs.TargetFind")
require("libs.ScriptConfig")

-- Global Variables --
local me = nil
local registered = false
local target = nil
local veil  = nil
local blink = nil

-- ✖ When you start the game ✖ --
function onLoad()
	if PlayingGame() then
		me = entityList:GetMyHero()
		if not me then 
			script:Disable()
			registered = false
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:UnregisterEvent(onLoad)
		end
	end
end

-- ✖ Main Event ✖ --
function Main(tick)
	me = entityList:GetMyHero()
	if not me then return end
	if not SleepCheck() then return end
	blink = me:FindItem("item_blink")
	veil = me:FindItem("item_veil_of_discord")
	target = targetFind:GetClosestToMouse(100)
	if blink and blink.cd > 0 and target and GetDistance2D(me,target) < 1200  and target.alive and target.visible then
		if veil and veil:CanBeCasted() and not me:IsChanneling() and me.alive then
			me:CastAbility(veil,target.position)
			Sleep(100+me:GetTurnTime(target)*500)
		end
	end
	if me:IsChanneling() and target and target.alive and target.visible then
		if veil and veil:CanBeCasted() and me.alive then
			me:CastAbility(veil,target.position,true)
			Sleep(100+me:GetTurnTime(target)*500)
			Sleep(1000)
		end
	end
end

-- ✖ END OF GAME  ✖ --
function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Main)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
