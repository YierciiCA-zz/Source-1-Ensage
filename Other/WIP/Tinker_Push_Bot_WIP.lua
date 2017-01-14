--<<Tinker Push Bot WIP>>
--[[
		-------------------------------------
		|   TinkerPush Bot WIP by MaZaiPC   |
		-------------------------------------
		=========== Version 0.3 Indev ===========
		 
		Description:
		------------
	   
				Push mode:
						Teleport on line with enemy creeps -> Cast March of the Machines -> blink out -> Rearm -> Teleport to fountain -> loop...
				Minimal requirements:
						- Rearm
						- March of the Machines
						- Boots of Travel or Teleport Scrolls (TB priority)
						- Soul Ring
				Recommended:
						- Rearm
						- March of the Machines
						- Boots of Travel or Teleport Scrolls (TB priority)
						- Soul Ring
						- Blink Dagger
						- Bottle
		Changelog:
		----------
				0.4 - some fixes
				0.3 - Indev ver.
					   
]]--
 
--Libraries
require("libs.Utils")
require("libs.ScriptConfig")
 
--Config
config = ScriptConfig.new()
config:SetParameter("Hotkey", "J", config.TYPE_HOTKEY)
config:Load()
 
local Hotkey	 	 = config.Hotkey
local registered	 = false
local range			 = 50000
 
local target		= nil
local baseLoc	    = nil
local active		= false
local castQueue = {}
local sleep = {0,0,0}

-- Manacost
local UltC = {150,250,350} local TravelC = 75
 
--Text on your screen
local x,y = 1320, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Verdana",15*monitor,550*monitor)
local statusText = drawMgr:CreateText(x*monitor,y*monitor,-1,"Tinker PUSH Bot - Hotkey: ''"..string.char(Hotkey).."'' Status: OFF",F14) statusText.visible = false
 
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Tinker then
			script:Disable()
		else
			registered = true
			statusText.visible = true
			if me.team == LuaEntity.TEAM_RADIANT then
				baseLoc = Vector(-7188,-6708,398)
			else
				baseLoc = Vector(7033,6418,391)
			end
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end
 
function Key(msg,code)
	if msg ~= KEY_UP and code == config.Hotkey and not client.chat then
		if not activated then
			activated = true
			statusText.text = "Tinker PUSH Bot - Hotkey: ''"..string.char(Hotkey).."'' Status: ON"
		else
			activated = false
			statusText.text = "Tinker PUSH Bot - Hotkey: ''"..string.char(Hotkey).."'' Status: OFF"
		end
	end
end
 
function Main(tick)
	--init
	if not SleepCheck() then return end
	me = entityList:GetMyHero()
	TravelBoots = me:FindItem("item_travel_boots")
	TPScroll	= me:FindItem("item_tpscroll")
	E  			= me:GetAbility(3) -- Machines
	R  			= me:GetAbility(4) -- Rearm
	BlinkDagger = me:FindItem("item_blink")
	SoulRing 	= me:FindItem("item_soul_ring")
	Bottle 		= me:FindItem("item_bottle")
	for i=1,#castQueue,1 do
		local v = castQueue[1]
		table.remove(castQueue,1)
		local ability = v[2]
		if type(ability) == "string" then
			ability = me:FindItem(ability)
		end
		if ability and ((me:SafeCastAbility(ability,v[3],false)) or (v[4] and ability:CanBeCasted())) then
			if v[4] and ability:CanBeCasted() then
				me:CastAbility(ability,v[3],false)
			end
			sleep[3] = tick + v[1] + client.latency
			return
		end
	end
	FindTarget()
	--Push bot activation
	if active == true then
		--CD check
		cdCheck(TravelBoots,TPScroll)
		--function
		if target and me.alive and (TravelBoots or TPScroll) then
			if TravelBoots then
				Teleport(TravelBoots,target)
			elseif not TravelBoots and TPScroll then
				Teleport(TPScroll,target)
			end
		end
		if E and E:CanBeCasted() and me:CanCast() then
			table.insert(castQueue,{math.ceil(item:FindCastPoint()*1000),E,me.position})
		end
		--blink out
		local fs = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]
		local vec = Vector((fs.position.x - me.position.x) * 1100 / GetDistance2D(fs,me) + me.position.x,(fs.position.y - me.position.y) * 1100 / GetDistance2D(fs,me) + me.position.y,fs.position.z)
		if blinkfront then
			vec = Vector(me.position.x+1200*math.cos(me.rotR), me.position.y+1200*math.sin(me.rotR), me.position.z)
		end
		if BlinkDagger and BlinkDagger:CanBeCasted() then
			table.insert(castQueue,{math.ceil(item:FindCastPoint()*1000),BlinkDagger,vec})
		end
		--Back
		BackToFountain()
	end
end
 
function BackToFountain()
	--CD check
	cdCheck(TravelBoots,TPScroll)
   
	--function
	if me.mana < TravelBoots.manacost and me.alive and not me:IsChanneling() and SoulRing and SoulRing:CanBeCasted() then
		table.insert(castQueue,{100,SoulRing})
	end
	if TravelBoots then
		Teleport(TravelBoots,baseLoc)
	elseif TPScroll then
		Teleport(TPScroll,baseLoc)
	end
	while mana == me.maxMana do
		if not me:IsChanneling() and me:DoesHaveModifier("modifier_fountain_aura_buff") and not me:DoesHaveModifier("modifier_bottle_regeneration") then
			table.insert(castQueue,{100,Bottle})
			Sleep(500)
		end
	end
end
 
function cdCheck(TB,TP)
	if TB and not TB:CanBeCasted() then
		Refresh()
	end
	if not TB and TP and not TP:CanBeCasted() then
		Refresh()
	end
end
 
function Refresh()
	--init
	local me = entityList:GetMyHero()
	local R  = me:GetAbility(4)
	local SoulRing = me:FindItem("item_soul_ring")
	-- return if we're casting our ult
	if R.channelTime > 0 or R.abilityPhase then
		return
	end
	--function
	if me:mana() > UltC[R.level] and me.alive and not me:IsChanneling() and SoulRing and SoulRing:CanBeCasted() then
		table.insert(castQueue,{100,SoulRing})
	end
	if R and R:CanBeCasted() and me:CanCast() then
		table.insert(castQueue,{100,R})
	end
end
 
function Teleport(item,victim)
	if item:CanBeCasted() then
		table.insert(castQueue,{math.ceil(item:FindCastPoint()*1000),item,victim})
	end
end
 
function FindTarget()
	local FurthestCreep = nil
	local me = entityList:GetMyHero()
	local enemies = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,team = me:GetEnemyTeam(),alive=true,visible=true})
	for i,v in ipairs(enemies) do
		distance = GetDistance2D(v,me)
		if distance <= range then
			if FurthestCreep == nil then
				FurthestCreep = v
			elseif distance > GetDistance2D(FurthestCreep,me) then
				FurthestCreep = v
			end
		end
	end
	target = FurthestCreep
end
 
function onClose()
	collectgarbage("collect")
	if registered then
		statusText.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end
 
script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)