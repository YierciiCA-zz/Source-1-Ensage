require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Baboom")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Suicide","SuicideMoreTarget",SGC_TYPE_TOGGLE,false,true,nil)

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
		if target and GetDistance2D(target,me) <= 2000  then
			local Q, W, E, D, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(3),me:GetAbility(4), me:GetAbility(6)
			local distance = GetDistance2D(target,me)
			local attackRange = me.attackRange	
			local soulring = me:FindItem("item_soul_ring")
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local linkens = target:IsLinkensProtected()
			local Eul = me:FindItem("item_cyclone")
			local dagon = me:FindDagon()
			local medall = me:FindItem("item_medallion_of_courage") or me:FindItem("item_solar_crest")
			local blink = me:FindItem("item_blink")
			if dagon and dagon:CanBeCasted() and me:CanCast() then
                                table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
                        end
			if  GetDistance2D(me,target) and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange+300 and not blink.abilityPhase and not inv then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
			end
			if Eul and Eul:CanBeCasted() and me:CanCast() and distance <= 300  then  
				me:CastAbility(Eul,target)
				if (W and W.cd == 0) and not target:IsMagicImmune() then
					me:CastAbility(W,target.position)
					activated = 1
					sleepTick = GetTick() + 300
				return
				end
			end
			if W and W and not target:IsMagicImmune() and target:IsStunned()  then
					me:CastAbility(W,target.position)
			end
			if medall and medall:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(medall:FindCastPoint()*1000),medall,target})
			end
			if Q and Q:CanBeCasted() and me:CanCast() and not target:IsAttackImmune() then
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target.position})
			end
			if me.mana < me.maxMana*0.5 and  soulring and soulring:CanBeCasted() then
				table.insert(castQueue,{100,soulring})
			end
			if R and R:CanBeCasted() and me:CanCast() and not target:IsMagicImmune() then
				table.insert(castQueue,{100,R,target.position})
			end
			if D and D:CanBeCasted() and me:CanCast() and not target:IsMagicImmune() and GetDistance2D(target,me) <= 850 and R.abilityPhase then
				table.insert(castQueue,{100,D,target.position})
			end
			if wand and wand:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 then
				table.insert(castQueue,{100,wand})
			end	
			if ScriptConfig.Suicide and E and E:CanBeCasted() and not target:IsAttackImmune() then
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 195 end)
				if #heroes > 2 then
					table.insert(castQueue,{100,E,target})
				
				end
			end
			if stick and stick:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 then
				table.insert(castQueue,{100,stick})
			end
			if target.visible and SleepCheck("all") and  distance > 300 then
				local xyz = SkillShot.PredictedXYZ(target,me:GetTurnTime(target)*1000+client.latency+500)
					 me:Move(xyz)
						Sleep(client.latency+500,"all")
			end
			if target.visible and SleepCheck("all") and  distance < 300 then
					me:Attack(target)
						Sleep(client.latency+500,"all")
			end
			sleep = tick + 170
		end
	end
end		

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Techies then 
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
