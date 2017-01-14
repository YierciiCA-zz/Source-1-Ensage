require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")
require("libs.HeroInfo")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("WitchDoctor")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Ult","Ult",SGC_TYPE_TOGGLE,false,true,nil)


local play, target, castQueue, castsleep, sleep = false, nil, {}, 0, 0

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
			castsleep = tick + v[1]
			return
		end
	end

	if ScriptConfig.Hotkey and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
		if target and GetDistance2D(target,me) <= 2000 and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
			local Q, W, E, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(3), me:GetAbility(4)
			local distance = GetDistance2D(target,me)
			local veil = me:FindItem("item_veil_of_discord")
			local atos = me:FindItem("item_rod_of_atos")
			local shiva = me:FindItem("item_shivas_guard")
			local orchid = me:FindItem("item_orchid")
			local sheep = me:FindItem("item_sheepstick")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local linkens = target:IsLinkensProtected()
			local shadowblade = me:FindItem("item_invis_sword") or me:FindItem("item_silver_edge")
			local glimmer = me:FindItem("item_glimmer_cape")
			local medall = me:FindItem("item_medallion_of_courage")
			local amulet = me:FindItem("item_shadow_amulet")
			local attackRange = me.attackRange	
			local RangeBlink = 1800
			if Q and Q:CanBeCasted() and me:CanCast() and linkens then
				me:CastAbility(Q,target)
			end
			if E and E:CanBeCasted() and me:CanCast() or target:IsStunned() and not R.abilityPhase then 
				table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E,target.position})
			end
			if medall and medall:CanBeCasted() and me:CanCast() and SleepCheck("allcast")  then
				table.insert(castQueue,{1000+math.ceil(medall:FindCastPoint()*1000),medall,target})
				Sleep(11000+client.latency,"allcast")	
			end
			if shiva and shiva:CanBeCasted() and distance <= 600 then
				table.insert(castQueue,{100,shiva})
			end
			if R and R:CanBeCasted() and me:CanCast()  and target:DoesHaveModifier("modifier_maledict") then  
				me:CastAbility(R,target.position)
				if (amulet and amulet.cd == 0)  then
					me:CastAbility(amulet,me)
					activated = 1
					sleepTick = GetTick() + 500
				return
				end
				if (shadowblade and shadowblade.cd == 0) or (glimmer and glimmer:CanBeCasted()) then
					if glimmer and R.abilityPhase then
							me:CastAbility(glimmer,me)
						activated = 1
						sleepTick = GetTick() + 500
						return
					end
					if shadowblade and R.abilityPhase then
							me:CastAbility(shadowblade) 
						activated = 1
						sleepTick = GetTick() + 500
					return
					end
				end
			end
			if sheep and sheep:CanBeCasted() and me:CanCast()  then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
			end
			if orchid and orchid:CanBeCasted() and me:CanCast()  then
				table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,target})
			end
			if Q and Q:CanBeCasted() and me:CanCast()  then
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target})
			end
			if atos and atos:CanBeCasted() and me:CanCast() and SleepCheck("allcast") then
				table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
					Sleep(10500+client.latency,"allcast")
			end
			if W and W:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 and not me:DoesHaveModifier("modifier_voodoo_restoration_heal") then
				table.insert(castQueue,{100,W})
			end
			if veil and veil:CanBeCasted() and me:CanCast() and not target:DoesHaveModifier("modifier_witch_doctor_death_ward")  then
				table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
			end
		end
	end
end





function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_WitchDoctor then 
			script:Disable()
		else
			play, target, myhero = true, nil, me.classId
			ScriptConfig:SetVisible(true)
			script:RegisterEvent(EVENT_TICK, Main)
			script:UnregisterEvent(Load)
		end
	end
end

function Close()
	target, myhero = nil, nil
	ScriptConfig:SetVisible(false)
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close) 
script:RegisterEvent(EVENT_TICK, Load)
