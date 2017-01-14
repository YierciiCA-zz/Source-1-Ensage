--<<Fix Q+W. Fix R+D)>>
require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("EmberSpirit")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Tie_up","Tie up",SGC_TYPE_ONKEYDOWN,false,false,87)
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
		if target and GetDistance2D(target,me) <= 2000 then
			local Q, W, E, D, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(3), me:GetAbility(4), me:GetAbility(5)
			local distance = GetDistance2D(target,me)
			--local distance2 = GetDistance2D(target,creep)
			local distance3 = GetDistance2D(target,remnEnd)
			local remnEnd = entityList:GetEntities({"npc_dota_ember_spirit_remnant"})
			--local creep = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,}) or entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,team=enemyTeam,}) or entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Boar,team=enemyTeam,}) or entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Siege,team=enemyTeam,}) or entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling,team=enemyTeam,})		
			local dagon = me:FindDagon()
			local ethereal = me:FindItem("item_ethereal_blade")
			local halberd = me:FindItem("item_heavens_halberd")
			local abyssal = me:FindItem("item_abyssal_blade")
			local shiva = me:FindItem("item_shivas_guard")
			local veil = me:FindItem("item_veil_of_discord")
			local sheep = me:FindItem("item_sheepstick")
			local mjollnir = me:FindItem("item_mjollnir")
			local mom = me:FindItem("item_mask_of_madness")
			local satanic = me:FindItem("item_satanic")
			local soulring = me:FindItem("item_soul_ring")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local arcane = me:FindItem("item_arcane_boots")
			local diffusal = me:FindItem("item_diffusal_blade") or me:FindItem("item_diffusal_blade_2")
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local blink = me:FindItem("item_blink")
			local linkens = target:IsLinkensProtected()
			local attackRange = me.attackRange	
			local RangeBlink = 1500
			if GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange+400 and not blink.abilityPhase then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
			end
			if diffusal and diffusal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(diffusal:FindCastPoint()*800),diffusal,target})
			end
			if (mjollnir and mjollnir.cd == 0) then
				if mjollnir and mjollnir then
						me:CastAbility(mjollnir,me)
					activated = 1
					sleepTick = GetTick() + 500
					return
				end
			end
			if W and W:CanBeCasted() and me:CanCast() then 
				table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W,target.position})   				
			end
			if Q and Q:CanBeCasted() and me:CanCast() and distance <= 110 and not target:IsMagicImmune() then
					table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q})
				sleep = tick + 50
			end
			if Q and Q:CanBeCasted() and me:CanCast() and distance <= 400 --[[ and not distance2 <= 380 ]] and not me:DoesHaveModifier("modifier_ember_spirit_sleight_of_fist_caster") and not target:IsMagicImmune() then
					table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q})
			end
			if distance <= 400 and E and E:CanBeCasted() and me:CanCast() and not target:IsMagicImmune() then
				table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E})
			end
			if abyssal and abyssal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
			end
			if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if mom and mom:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
			end
			if halberd and halberd:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
			end
			if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+300 then
				table.insert(castQueue,{100,satanic})
			end
			if wand and wand:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 then
				table.insert(castQueue,{100,wand})
			end	
			if stick and stick:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 then
				table.insert(castQueue,{100,stick})
			end	
			if (ScriptConfig.Cheese) and cheese and cheese:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600 then
				table.insert(castQueue,{100,cheese})
			end	
			if shiva and shiva:CanBeCasted() and distance <= 600 then
				table.insert(castQueue,{100,shiva})
			end
			if sheep and sheep:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
			end
			if veil and veil:CanBeCasted() and me:CanCast() and not target:IsMagicImmune() then
				table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
			end
			if me.mana < me.maxMana*0.5 and ScriptConfig.Arcan and arcane and arcane:CanBeCasted() then
				table.insert(castQueue,{100,arcane})
			end
			if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
				table.insert(castQueue,{100,soulring})
			end
			if (ScriptConfig.Ult) and R and R:CanBeCasted() and me:CanCast()--[[ and SleepCheck("X_x")]] and not target:IsMagicImmune() then
				local CP = R:FindCastPoint()
				local speed = 900  
				local distance = GetDistance2D(target, me)
				local delay =100+client.latency
				local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
					if xyz and distance <= 1100  then  
						me:SafeCastAbility(R, xyz)
						--Sleep(100+client.latency,"X_x")
					end
			end 
			if D and D:CanBeCasted() and me:CanCast() and distance3 <= 800 and SleepCheck("X__x") and not me:DoesHaveModifier("modifier_ember_spirit_sleight_of_fist_caster") then
					table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),D,target.position})
					Sleep(500+client.latency,"X__x")
			end
			if dagon and dagon:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(target)
			end
			sleep = tick + 50
		end
	end
	if ScriptConfig.Tie_up and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
		if target and GetDistance2D(target,me) <= 2000 and not target:IsMagicImmune() and target:CanDie() then
			local Q, W = me:GetAbility(1), me:GetAbility(2)
			local distance = GetDistance2D(target,me)
			if W and W:CanBeCasted() and me:CanCast() then 
				table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W,target.position})   				
			end
			if Q and Q:CanBeCasted() and me:CanCast()  and distance <= 100 then
					table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q})
			end
			if not slow then
				me:Attack(target)
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_EmberSpirit then 
			script:Disable()
		else
			play, target, myhero = true, nil, me.classId
			ScriptConfig:SetVisible(true)
			script:RegisterEvent(EVENT_TICK, Main)
			script:UnregisterEvent(Load)
		end
	end
end
function EmberKey(msg,code)

	if msg == KEY_DOWN and not client.chat and code == key then
		activated = true
	else
		activated = false
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
