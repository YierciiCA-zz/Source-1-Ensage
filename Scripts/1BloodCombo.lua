require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("AllBlood")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Ult","Rupture",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Diffusal","diff",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Cheese","Cheese",SGC_TYPE_TOGGLE,false,true,nil)

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
		if target and GetDistance2D(target,me) <= 2000  and not target:IsMagicImmune() and target:CanDie() then
			local Q, W, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(4)
			local distance = GetDistance2D(target,me)
			local attackRange = me.attackRange	
			local bkb = me:FindItem("item_black_king_bar")
			local Eul = me:FindItem("item_cyclone")
			local mail = me:FindItem("item_blade_mail")
			local mail2 = target:FindItem("item_blade_mail")
			local halberd = me:FindItem("item_heavens_halberd")
			local abyssal = me:FindItem("item_abyssal_blade")
			local ethereal = me:FindItem("item_ethereal_blade")
			local mom = me:FindItem("item_mask_of_madness")
			local mjollnir = me:FindItem("item_mjollnir")
			local soulring = me:FindItem("item_soul_ring")
			local satanic = me:FindItem("item_satanic")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local diffusal = me:FindItem("item_diffusal_blade") or me:FindItem("item_diffusal_blade_2")
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local linkens = target:IsLinkensProtected()
			if abyssal and abyssal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
			end
			if (ScriptConfig.Diffusal) and diffusal and diffusal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(diffusal:FindCastPoint()*800),diffusal,target})
			end
			if Q and Q:CanBeCasted() and me:CanCast() and linkens then  
				me:CastAbility(Q,target)
			end
			if Eul and Eul:CanBeCasted() and me:CanCast() and distance <= 590  then  
				me:CastAbility(Eul,target)
				if (W and W.cd == 0)  then
					me:CastAbility(W,target.position)
					activated = 1
					sleepTick = GetTick() + 300
				return
				end
			end
			if Q and Q:CanBeCasted() and me:CanCast() and not me:DoesHaveModifier("modifier_bloodseeker_bloodrage") then 
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,me})
			end
			if ethereal and ethereal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
			end
			if (mjollnir and mjollnir.cd == 0) then
				if mjollnir and mjollnir then
						me:CastAbility(mjollnir,me)
					activated = 1
					sleepTick = GetTick() + 500
					return
				end
			end
			if W and W:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_bloodseeker_rupture") and not Eul then
				local CP = W:FindCastPoint()
				local speed = 1500  
				local distance = GetDistance2D(target, me)
				local delay =600+client.latency
				local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
					if xyz and distance <= 1100  then  
						me:SafeCastAbility(W, xyz)
				end
			end 
			if mom and mom:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
			end
			if me.mana < me.maxMana*0.5 and  soulring and soulring:CanBeCasted() then
				table.insert(castQueue,{100,soulring})
			end
			if halberd and halberd:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
			end
			if (ScriptConfig.Ult) and R and R:CanBeCasted() and me:CanCast() and not linkens and not mail2 and not target:DoesHaveModifier("modifier_item_lotus_orb_active") then
				table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target})
			end
			if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+300 then
				table.insert(castQueue,{100,satanic})
			end
			if (ScriptConfig.Cheese) and cheese and cheese:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600 then
				table.insert(castQueue,{100,cheese})
			end	
			
			if wand and wand:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 then
				table.insert(castQueue,{100,wand})
			end	
			
			if stick and stick:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 then
				table.insert(castQueue,{100,stick})
			end	
			if bkb and bkb:CanBeCasted() then
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 800 end)
				if #heroes == 3 then
					table.insert(castQueue,{100,bkb})
				elseif #heroes == 4 then
					table.insert(castQueue,{100,bkb})
				elseif #heroes == 5 then
					table.insert(castQueue,{100,bkb})
				return
				end
			end
			if mail and mail:CanBeCasted() then
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 700 end)
				if #heroes == 3 then
					table.insert(castQueue,{100,mail})
				elseif #heroes == 4 then
					table.insert(castQueue,{100,mail})
				elseif #heroes == 5 then
					table.insert(castQueue,{100,mail})
				return
				end
			end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(me)
			end
			sleep = tick + 200
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Bloodseeker then 
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
