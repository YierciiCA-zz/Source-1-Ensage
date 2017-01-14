--<<Auto Urn V1.0B ✰ - by ☢bruninjaman☢>>--
--[[
☑ Script Requested by monyaxd.
☛ This script do?
☑ Use auto urn on enemies killables.
☑ You can change the configuration.
********************************************************************************
♜ Change Log ♜
➩ V1.0B - Monday, March 9, 2015 - fixed tp cancel and if is not alive.
➩ V1.0A - Tuesday, March 3, 2015 - New Reworked Version Released.
]]

-- ✖ Libraries ✖ --
require("libs.Utils")
require("libs.ScriptConfig")

-- ✖ config ✖ --
config = ScriptConfig.new()
config:SetParameter("AutoUrnHP", 150) -- 150 by default (enemy killable)
config:Load()

-- Global Variables --
local me = nil
local urnHP = config.AutoUrnHP
local registered = false

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
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, alive=true, visible = true, team=me:GetEnemyTeam()})
	if me.alive and not me:IsChanneling() then
		for i,enemy in ipairs(enemies) do
			if enemy and enemy.health <= urnHP and me:FindItem("item_urn_of_shadows") and GetDistance2D(me,enemy) < 950 and enemy.visible and enemy.alive and not me:IsChanneling() and not enemy:IsIllusion() then
				if me:FindItem("item_urn_of_shadows") and me:FindItem("item_urn_of_shadows"):CanBeCasted() then
					me:CastItem("item_urn_of_shadows",enemy)
					Sleep(100+me:GetTurnTime(enemy)*500)
				end
			end
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
