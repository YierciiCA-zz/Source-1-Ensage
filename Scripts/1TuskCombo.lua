require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Tusk")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Ult","UseUlt",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Diffusal","diff",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Urn","Urn",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Cheese","Cheese",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Blink","UseBlink",SGC_TYPE_TOGGLE,false,true,nil)

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
			local Q, W, E, R, D = me:GetAbility(1), me:GetAbility(2), me:GetAbility(3), me:GetAbility(6),  me:GetAbility(5)
			local distance = GetDistance2D(target,me)
			local attackRange = me.attackRange	
			local urn = me:FindItem("item_urn_of_shadows")
			local dagon = me:FindDagon()
			local halberd = me:FindItem("item_heavens_halberd")
			local abyssal = me:FindItem("item_abyssal_blade")
			local ethereal = me:FindItem("item_ethereal_blade")
			local mom = me:FindItem("item_mask_of_madness")
			local soulring = me:FindItem("item_soul_ring")
			local satanic = me:FindItem("item_satanic")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local diffusal = me:FindItem("item_diffusal_blade") or me:FindItem("item_diffusal_blade_2")
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local inv = me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") or me:DoesHaveModifier("modifier_item_silver_edge_windwalk")
			local attackRange = me.attackRange
			local medall = me:FindItem("item_medallion_of_courage") or me:FindItem("item_solar_crest")
			local invis = me:FindItem("item_invis_sword") or me:FindItem("item_silver_edge") 
			local blink = me:FindItem("item_blink")
			local TuskSigil = entityList:FindEntities({classId=CDOTA_BaseNPC_Tusk_Sigil,controllable=true,alive=true,visible=true})
			if (ScriptConfig.Blink) and GetDistance2D(me,target) and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange+300 and not blink.abilityPhase and not inv then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
			end
			if dagon and dagon:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if ScriptConfig.Urn and urn and urn:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{math.ceil(urn:FindCastPoint()*1000),urn,target})
			end
			if medall and medall:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{1000+math.ceil(medall:FindCastPoint()*1000),medall,target})
			end
			if abyssal and abyssal:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
			end
			if (ScriptConfig.Diffusal) and diffusal and diffusal:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{math.ceil(diffusal:FindCastPoint()*800),diffusal,target})
			end
			if Q and Q:CanBeCasted() and me:CanCast() and me:DoesHaveModifier("modifier_tusk_snowball_movement") and not inv then 
				local CP = Q:FindCastPoint()
				local speed = 1300  
				local distance = GetDistance2D(target, me)
				local delay =500+client.latency
				local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
					if xyz and distance <= 1400  then  
						me:SafeCastAbility(Q, xyz)
				end
			end 
			if invis and invis:CanBeCasted() and me:CanCast() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600  then
				table.insert(castQueue,{math.ceil(invis:FindCastPoint()*800),invis})
			end
			if ethereal and ethereal:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
			end
			if W and W:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W,target})        
			end
			if W and W:CanBeCasted() and me:CanCast() and  me:DoesHaveModifier("modifier_tusk_snowball_movement") and not inv then
				table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W})        
			end
			if distance <= 350 and  E and E:CanBeCasted() and me:CanCast() and  me:DoesHaveModifier("modifier_tusk_snowball_movement") and not inv then
				table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E})        
			end
			if mom and mom:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
			end
			if me.mana < me.maxMana*0.5 and  soulring and soulring:CanBeCasted() and not inv then
				table.insert(castQueue,{100,soulring})
			end
			if halberd and halberd:CanBeCasted() and me:CanCast() and not inv then
				table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
			end
			if me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") or me:DoesHaveModifier("modifier_item_silver_edge_windwalk") then
				table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target})
			end
			if (ScriptConfig.Ult) and R and R:CanBeCasted() and me:CanCast() and not me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") or me:DoesHaveModifier("modifier_item_silver_edge_windwalk") then
				table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target})
			end
			if D and D:CanBeCasted() then
				for i,v in ipairs(entityList:GetEntities(function (v) return (v.type == LuaEntity.TYPE_HERO and not v:IsIllusion() and v.alive and v.team == me.team and me:GetDistance2D(v) <= 2000) end)) do
					if (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, v))) - 0.20, 0)) == 0 and target:GetDistance2D(v) >= 550 then
						table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,target})
					end	
				end
			end
			if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+300  and not inv then
				table.insert(castQueue,{100,satanic})
			end
			if (ScriptConfig.Cheese) and cheese and cheese:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600 and not inv then
				table.insert(castQueue,{100,cheese})
			end	
			if wand and wand:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 and not inv then
				table.insert(castQueue,{100,wand})
			end	
			
			if stick and stick:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 and not inv then
				table.insert(castQueue,{100,stick})
			end	
			if #TuskSigil > 0 then
				for i,v in ipairs(TuskSigil) do
					if v.controllable and v.unitState ~= -1031241196 then
						local distance = GetDistance2D(v,target)
						if distance <= 1300 then
							v:Follow(target)
						end
					end
				end
			end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(target)
			end
			sleep = tick + 100
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Tusk then 
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
