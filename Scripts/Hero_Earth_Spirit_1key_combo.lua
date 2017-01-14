require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "T", config.TYPE_HOTKEY)
config:SetParameter("AutoAttack", false)
config:SetParameter("AttackAfterSpell", true)
config:Load()

local key = config.Hotkey
local AutoAttack = config.AutoAttack
local AttackAfterSpell = config.AttackAfterSpell

local xx,yy = 10,client.screenSize.y/25.714
local statusText = drawMgr:CreateText(xx,yy,-1,"Press "..string.char(key).." to enable, press again to disable",drawMgr:CreateFont("f14","Arial",14,400)) statusText.visible = false

local sleep,start = nil,nil
local remnants,ultistate = {},{}
local stage,xxx,yyy = 0,-30,-40

if AutoAttack then AutoAttack = "1" else AutoAttack = "0" end
if AttackAfterSpell then AttackAfterSpell = "1" else AttackAfterSpell = "0" end

function Key(msg,code)

	if msg ~= KEY_UP or code ~= key or client.chat then	return end
	
	if not start then
		sleep,start = nil,true
		statusText.text = "Status: On"
		client:ExecuteCmd("dota_player_units_auto_attack 0")
		client:ExecuteCmd("dota_player_units_auto_attack_after_spell 0")
		return true
	else
		Off()
		return true
	end

end

function Tick(tick)	

	if client.console then return end
	
	local me = entityList:GetMyHero() 

	if not me then return end
		
	Track()

	if start and me:CanCast() then
		local sel = entityList:GetMyPlayer().selection[1]
		if sel and sel.handle ~= me.handle then
			Off()
			return
		end
		
		local remnant = me:GetAbility(4)
		local grip = me:GetAbility(3)
		local roll = me:GetAbility(2)
		local smash = me:GetAbility(1)
		local last = Last()
		local stunned = entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_HERO and v.health > 0 and v.team ~= me.team and v:DoesHaveModifier("modifier_stunned") end)[1]		
		
		if stage == 0 then			
			if me.activity == LuaEntityNPC.ACTIVITY_MOVE then
				me:Stop()					
			end	
			stage = 1
		elseif stage == 1 then
			if remnant:CanBeCasted() and smash:CanBeCasted() then
				local t_ = client.mousePosition
				local vector = (t_ - me.position) * 150 / GetDistance2D(t_,me) + me.position
				me:CastAbility(remnant,vector,false)
				me:CastAbility(smash,vector,true)	
				sleep = tick + 1300
				stage = 2
			end			
		elseif stage == 2 and stunned and grip:CanBeCasted() and GetDistance2D(stunned,me) < grip.castRange then
			if last then
				local distance = GetDistance2D(last.position,me)
				local vector = (last.position - me.position) * (distance+(1200*client.latency/1000)) / distance + me.position
				me:CastAbility(grip,vector)
				stage = 3
				sleep = tick + 800
			else
				me:CastAbility(grip,stunned.position)
				stage = 3
				sleep = tick + 800
			end
		elseif stage == 3 and roll:CanBeCasted() and stunned and stunned:DoesHaveModifier("modifier_earth_spirit_geomagnetic_grip_debuff") then
			me:CastAbility(roll,(stunned.position - me.position) * 600 / GetDistance2D(stunned,me) + me.position,false)
			Off()
		end	
		
		if sleep and tick > sleep then
			Off()
		end
		
	end
		
	if SleepCheck("ulti") and me:GetAbility(6).cd ~= 0 then
		local enemy = entityList:GetEntities({type=LuaEntity.TYPE_HERO, illusion=false})
		for i,v in ipairs(enemy) do
			local offset = v.healthbarOffset
			if offset == -1 then return end
		
			if not ultistate[v.handle] then	ultistate[v.handle] = {}
				ultistate[v.handle].fon = drawMgr:CreateRect(xxx,yyy,60,6,0x000000D0) ultistate[v.handle].fon.visible = false ultistate[v.handle].fon.entity = v ultistate[v.handle].fon.entityPosition = Vector(0,0,offset)
				ultistate[v.handle].im = drawMgr:CreateRect(xxx,yyy,60,6,0x008000FF) ultistate[v.handle].im.visible = false ultistate[v.handle].im.entity = v ultistate[v.handle].im.entityPosition = Vector(0,0,offset)
				ultistate[v.handle].bo = drawMgr:CreateRect(xxx-1,yyy-1,62,8,0x000000FF,true) ultistate[v.handle].bo.visible = false ultistate[v.handle].bo.entity = v ultistate[v.handle].bo.entityPosition = Vector(0,0,offset)				
			end
			
			if v.alive and v.visible and v.health > 0 then
				local mag = v:FindModifier("modifier_earth_spirit_magnetize")
				if mag then
					ultistate[v.handle].im.w = 60 - (mag.elapsedTime*10)					
					ultistate[v.handle].bo.visible = true
					ultistate[v.handle].fon.visible = true
					ultistate[v.handle].im.visible = true
				elseif ultistate[v.handle].im.visible then
					ultistate[v.handle].im.visible = false
					ultistate[v.handle].bo.visible = false
					ultistate[v.handle].fon.visible = false
				end
			elseif ultistate[v.handle].im.visible then
				ultistate[v.handle].im.visible = false
				ultistate[v.handle].bo.visible = false
				ultistate[v.handle].fon.visible = false
			end

		end	Sleep(200,"ulti")
	end
	
end

function Off()
	statusText.text = "Status: Off"
	sleep,start,stage = nil,nil,0
	client:ExecuteCmd("dota_player_units_auto_attack "..AutoAttack)
	client:ExecuteCmd("dota_player_units_auto_attack_after_spell "..AttackAfterSpell)
end

function Last()
	local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
	if #remn > 1 then
		table.sort(remn, function(a,b) return remnants[a.handle]>remnants[b.handle] end)
		return remn[1]
	else
		return remn[1]
	end
end

function Track()	
	local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
	for i,v in ipairs(remn) do
		if not remnants[v.handle] then
			remnants[v.handle] = client.totalGameTime
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_EarthSpirit then
			statusText.visible = true
			play = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()
	if play then
		sleep,start,stage = nil,nil,0	
		statusText.text = "Press "..string.char(key).." to enable, press again to disable"
		statusText.visible = false
		remnants,ultistate = {},{}
		collectgarbage("collect")
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
