--<<Skywrath Mage script by MaZaiPC (AILEN's core)>>
require("libs.Utils")
require("libs.TargetFind")
require("libs.ScriptConfig")
require("libs.Animations")
require("libs.Skillshot")

local config = ScriptConfig.new()
config:SetParameter("HotKey", "D", config.TYPE_HOTKEY)
config:SetParameter("Ulti", "F", config.TYPE_HOTKEY)
config:Load()

local play = false local target = nil local Tulti = false local effect = {} local castQueue = {} local sleep = {0,0,0}
local ulti = config.Ulti

--Text on your screen
local x,y = 1320, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Verdana",15*monitor,550*monitor)
local Sulti = drawMgr:CreateText(x*monitor,y*monitor,-1,"Ultimate: ''"..string.char(ulti).."'' Status: OFF",F14) Sulti.visible = false

function Main(tick)
    if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end

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

	if IsKeyDown(config.HotKey) and not client.chat then
		target = targetFind:GetClosestToMouse(100)
		if tick > sleep[1] then
			if target and target.alive and target.visible and GetDistance2D(target,me) <= 2000 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
				local Q = me:GetAbility(1)
				local W = me:GetAbility(2)
				local E = me:GetAbility(3)
				local R = me:GetAbility(4)
				local distance = GetDistance2D(target,me)
				local dagon = me:FindDagon()
				local ethereal = me:FindItem("item_ethereal_blade")
				local atos = me:FindItem("item_ethereal_blade")
				local veil = me:FindItem("item_veil_of_discord")
				local soulring = me:FindItem("item_soul_ring")
				local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_veil_of_discord_debuff") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
					Sleep(me:GetTurnTime(target)*1000, "casting")
				end
				if ethereal and ethereal:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
				end
				if distance < Q.castRange and Q and Q:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target})
				end
				if distance < W.castRange and W and W:CanBeCasted() and me:CanCast() and target then
					table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W})
				end
				if distance < E.castRange and E and E:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E,target})
				end
				if Tulti and R and R:CanBeCasted() and me:CanCast() then
						if atos and atos:CanBeCasted() and distance <= atos.castRange and not disable then
							table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
						end
						local CP = R:FindCastPoint()
						local delay = ((300-Animations.getDuration(R)*1000)+CP*1000+client.latency+me:GetTurnTime(victim)*1000)
						local speed = 1400
						local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
						if xyz and distance <= 550 then 
							table.insert(castQueue,{math.ceil(R:FindCastPoint()*1000),Q,xyz})
						end
					end
				if veil and veil:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
				end
				if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
					table.insert(castQueue,{100,soulring})
				end
					if not slow then
						me:Attack(target)
					elseif slow then
						me:Follow(target)
					end
				sleep[1] = tick + 100
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Skywrath_Mage then 
			script:Disable()
		else
			play = true
			Sulti.visible = true
			target = nil
			myhero = me.classId
			script:RegisterEvent(EVENT_FRAME, Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function Key(msg,code)
	if msg ~= KEY_UP and code == config.Ulti and not client.chat then
		if not Tulti then
			Tulti = true
			Sulti.text = "Ultimate: ''"..string.char(ulti).."'' Status: ON"
		else
			Tulti = false
			Sulti.text = "Ultimate: ''"..string.char(ulti).."'' Status: OFF"
		end
	end
end

function Close()
	target = nil 
	myhero = nil
	collectgarbage("collect")
	if play then
		Sulti.visible = false
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close) 
script:RegisterEvent(EVENT_TICK, Load)
