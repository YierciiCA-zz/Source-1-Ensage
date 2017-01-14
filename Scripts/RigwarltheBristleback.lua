--<<Bristleback Script by Raphaelpdc Version 1.0>>

-- LIBRARIES
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.HeroInfo")

-- CONFIG
config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("ToggleFarm", "F", config.TYPE_HOTKEY)
config:SetParameter("TargetLeastHP", false)
config:Load()

-- SETTINGS
local ComboKey       = config.ComboKey
local ToggleFarm     = config.ToggleFarm
local getLeastHP     = config.TargetLeastHP
local registered	 = false
local range          = 700

-- Menu screen
local x,y            = 1420, 690
local monitor        = client.screenSize.x/1600
local F14            = drawMgr:CreateFont("F14","Franklin Gothic Medium",17,800) 
local statusText     = drawMgr:CreateText(x*monitor,y*monitor,0x00FF00FF,"Combo-(".. string.char(ComboKey) ..")-OFF",F14) statusText.visible = false

-- Farm Screen
local x1,y1          = 1420, 670
local farmText       = drawMgr:CreateText(x1*monitor,y1*monitor,0x00FF00FF,"AutoFarm Disabled - (" .. string.char(ToggleFarm) .. ")",F14) farmText.visible = false

-- CODE
local sleepMain     = 0
local currentMain   = 0
local target        = nil
local active        = false
local active2       = false

--[[Loading Script...]]
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Bristleback then
			script:Disable()
		else
			registered = true
			statusText.visible = true
			farmText.visible = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

--check if comboKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	
	if code == ComboKey then
		active 	= (msg == KEY_DOWN)
		active2 = false
	end
	
	if active then 
		statusText.text = "Combo-(".. string.char(ComboKey) ..")-ON"
		farmText.text   = "AutoFarm Disabled - (" .. string.char(ToggleFarm) .. ")"
	else
		statusText.text = "Combo-(".. string.char(ComboKey) ..")-OFF"
	end
	
	if IsKeyDown(ToggleFarm) then
		active2 = not active2
    	if active2 then
	    	farmText.text  = "AutoFarm Enabled - (" .. string.char(ToggleFarm) .. ")"
    	else
	    	farmText.text  = "AutoFarm Disabled - (" .. string.char(ToggleFarm) .. ")"
	    end
	end
end

--Main Combo--
function Main(tick)
	currentMain = tick
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not (me and (active or active2)) then return end

	if active2 then
	    OnFarm()
		return
	end
	
	-- Get hero abilities --
	local Nasal          = me:GetAbility(1)
	local Spray          = me:GetAbility(2)
	
	-- Get hero Itens --
	local Treads         = me:FindItem("item_power_treads")

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
            if me:CanCast() then
                 if Nasal:CanBeCasted() and SleepCheck("Nasal") then
                   	me:SetPowerTreadsState(1)
                    me:SafeCastAbility(Nasal,target)
				    me:SafeCastItem("item_power_treads",true)
				    me:SafeCastItem("item_power_treads",true)
					Sleep(4000,"Nasal")
					return
				end
		    end
		if target and me.alive then
            if me:CanCast() then
                 if Spray:CanBeCasted() then
                   	me:SetPowerTreadsState(1)
                    me:SafeCastAbility(Spray)
				    me:SafeCastItem("item_power_treads",true)
				    me:SafeCastItem("item_power_treads",true)
					return
				end
		    end	
		else
            if me:CanCast() then
                if Treads and Treads:CanBeCasted() and Spray and Spray:CanBeCasted() then
                   	me:SetPowerTreadsState(1,true)
                    me:CastAbility(Spray,true)
				    me:SafeCastItem("item_power_treads",true)      
				    me:SafeCastItem("item_power_treads",true) 
					Sleep(2500)
					return
				end
			end
		end
	end
end

--AutoFarm--
function OnFarm()
	local me = entityList:GetMyHero()
	local Treads = me:FindItem("item_power_treads")
	local damage = {20,40,60,80}
	local Spray  = me:GetAbility(2)
	if not Spray or Spray.level == 0 then return end		
		
	local creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true,team = me:GetEnemyTeam()})
		for i,v in ipairs(creeps) do	
		    if GetDistance2D(v,me) < 625 and Spray:CanBeCasted() and me:CanCast() and (v.health > 0 and v.health < damage[Spray.level]) then
			me:SetPowerTreadsState(1,true)
			me:SafeCastAbility(Spray)	
			me:SafeCastItem("item_power_treads",true)  
			me:SafeCastItem("item_power_treads",true) 
            Sleep(250)
            return 
		end
	end
 end

--CloseGame--
function onClose()
	collectgarbage("collect")
	if registered then
		statusText.visible = false
		farmText.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
