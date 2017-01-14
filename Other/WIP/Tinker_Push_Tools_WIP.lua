--<<Tinker Push Tools>>
--[[
		--------------------------------------
		|    Tinker Push Tools by MaZaiPC    |
		--------------------------------------
		=========== Version 0.5 ===========
		 
		Description:
		------------
					   -----------------------------------------------------------------------
					  |						SCRIPT CAPABILITIES							  	  |
					  |-----------------------------------------------------------------------|
					  | Default keycode	|	 Function									  	  |
					  |-----------------------------------------------------------------------|
					  | Numpad1 		|	 March of Machines: Smart Cast Ability (No Rearm) |
					  | Numpad2 		|	 Maximal ranged Blink to Mouse side -> Rearm	  |
					  | Numpad3 		|	 Fast TP on fountain						  	  |
					  | Numpad4 		|	 March of Machines + Rearm if CD			  	  |
					   -----------------------------------------------------------------------
		Changelog:
		----------
				0.5 - it works! Notify me if you found bug(s).
				0.4 - some fixes
				0.3 - Indev ver.
					   
]]--
require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Machines", 97, config.TYPE_HOTKEY)
config:SetParameter("MoreMachines", 100, config.TYPE_HOTKEY)
config:SetParameter("Blink", 98, config.TYPE_HOTKEY)
config:SetParameter("TPout", 99, config.TYPE_HOTKEY)

config:Load()

local play = false
local castQueue = {} local sleep = {0,0,0}

function Tick(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	if not me or me.classId ~= CDOTA_Unit_Hero_Tinker then
		script:Disable()
	else
		local mp = entityList:GetMyPlayer()

		if mp.team == LuaEntity.TEAM_RADIANT then
			foun = Vector(-7272,-6757,270)
		else
			foun = Vector(7200,6624,256)
		end
		
	
		
			
	local E  = me:GetAbility(3) -- Machines
	local R  = me:GetAbility(4) -- Rearm
	local BlinkDagger = me:FindItem("item_blink")
	local SoulRing = me:FindItem("item_soul_ring")
	local travel = me:FindItem("item_tpscroll") or me:FindItem("item_travel_boots")
	local RearmPhase = {3,2,1} local RearmPhaseLVL = RearmPhase[R.level]+100
	
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
			sleep[2] = tick + v[1] + client.latency
			return
		end
	end
	
	--machines
	if IsKeyDown(config.Machines) and not client.chat then
		if E and E:CanBeCasted() and me:CanCast() then
			table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E,me.position})
		end
	end	
	if IsKeyDown(config.MoreMachines) and not client.chat then
		if E and E:CanBeCasted() and me:CanCast() then
			table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E,me.position})
		end
		if R and R:CanBeCasted() and me:CanCast() and not E:CanBeCasted() then
			table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R})
			if E:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E,me.position})
			end
		end
	end	
	--blink + refresh
	if IsKeyDown(config.Blink) and not client.chat then
		--blinkout
		if BlinkDagger and BlinkDagger:CanBeCasted() then
			local distance = math.sqrt(math.pow(client.mousePosition.x - me.position.x, 2) + math.pow(client.mousePosition.y - me.position.y, 2))
			local expectedY = ((client.mousePosition.y - me.position.y) / distance) * 1199 + me.position.y
            local expectedX = ((client.mousePosition.x - me.position.x) / distance) * 1199 + me.position.x
            local blinkPosition = Vector(expectedX, expectedY, 0)
			table.insert(castQueue,{1000+math.ceil(BlinkDagger:FindCastPoint()*1000),BlinkDagger,blinkPosition})
			client:ExecuteCmd("+dota_camera_center_on_hero")
		end
		table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R})
	end
	--tpout
	if IsKeyDown(config.TPout) and not client.chat then
		if not R.abilityPhase then
		if travel and travel:CanBeCasted() then
			me:CastAbility(travel,foun) Sleep(700,"travel")
			client:ExecuteCmd("+dota_camera_center_on_hero")
			Sleep(700,"travelt")
			client:ExecuteCmd("-dota_camera_center_on_hero")
		end
		end
	end
end
end

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	end
end

function Close()
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
