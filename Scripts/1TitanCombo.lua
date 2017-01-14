require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Titan")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Hotkey2","OthersCombo",SGC_TYPE_ONKEYDOWN,false,false,69)
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
		if target and GetDistance2D(target,me) <= 2700 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() then
			local Q, W, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(5)
			local distance = GetDistance2D(target,me)
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local blink = me:FindItem("item_blink")
			local veil = me:FindItem("item_veil_of_discord")
			local attackRange = me.attackRange	
			local RangeBlink = 2000
			if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange+300 and not blink.abilityPhase  and not inv then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
			end
			if veil and veil:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
			end
			if W and W:CanBeCasted() and me:CanCast() and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				local CP = W:FindCastPoint()
				local speed = 1500  
				local distance = GetDistance2D(target, me)
				local delay =400+client.latency
				local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
					if xyz and distance <= 1100  then  
						me:SafeCastAbility(W, xyz)
				end
			end 
			if Q and Q:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_elder_titan_natural_order") and SleepCheck("allcast") then
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q}) 
						Sleep(1800+client.latency,"allcast")	
			end
			if (ScriptConfig.Cheese) and cheese and cheese:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600 and not inv then
				table.insert(castQueue,{100,cheese})
			end	
			if wand and wand:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{100,wand})
			end	
			if stick and stick:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{100,stick})
			end	
			if R and R:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target.position})
			end
			if ScriptConfig.BkB and bkb and bkb:CanBeCasted() and not me:DoesHaveModifier("modifier_elder_titan_natural_order") and not Q and not R then
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and me:GetDistance2D(v) <= 900 and v.alive and v.visible and v.team~=me.team end)
				if #heroes == 3 then
					table.insert(castQueue,{100,bkb})
				elseif #heroes == 4 then
					table.insert(castQueue,{100,bkb})
				elseif #heroes == 5 then
					table.insert(castQueue,{100,bkb})
					return
				end
			end
			sleep = tick +150
		end
	end
	
	if ScriptConfig.Hotkey2 and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
		if target and GetDistance2D(target,me) <= 2700 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() then
			local distance = GetDistance2D(target,me)
			local dagon = me:FindDagon()
			local R = me:GetAbility(5)
			local ethereal = me:FindItem("item_ethereal_blade")
			local halberd = me:FindItem("item_heavens_halberd")
			local medall = me:FindItem("item_medallion_of_courage") or me:FindItem("item_solar_crest")
			local shiva = me:FindItem("item_shivas_guard")
			local urn = me:FindItem("item_urn_of_shadows")
			local satanic = me:FindItem("item_satanic")
			local diffusal = me:FindItem("item_diffusal_blade") or me:FindItem("item_diffusal_blade_2")
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local inv = me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") or me:DoesHaveModifier("modifier_item_silver_edge_windwalk")
			local mom = me:FindItem("item_mask_of_madness")
			local sheep = me:FindItem("item_sheepstick")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local linkens = target:IsLinkensProtected()
			local blink = me:FindItem("item_blink")
			local attackRange = me.attackRange	
			local RangeBlink = 2000
			if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange+300 and not blink.abilityPhase  and not inv then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
			end
			if diffusal and diffusal:CanBeCasted() and me:CanCast() and not inv and not target:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{math.ceil(diffusal:FindCastPoint()*800),diffusal,target})
			end
			if medall and medall:CanBeCasted() and me:CanCast()  and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{1000+math.ceil(medall:FindCastPoint()*1000),medall,target})
			end
			if shiva and shiva:CanBeCasted() and distance <= 600 and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{100,shiva})
			end
			if sheep and sheep:CanBeCasted() and me:CanCast()  and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
			end
			if mom and mom:CanBeCasted() and me:CanCast() and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
			end
			if halberd and halberd:CanBeCasted() and me:CanCast() and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
			end
			if ethereal and ethereal:CanBeCasted() and me:CanCast()  and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
			end
			if urn and urn:CanBeCasted() and me:CanCast() and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{math.ceil(urn:FindCastPoint()*1000),urn,target})
			end	
			if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+300  and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{100,satanic})
			end
			if (ScriptConfig.Cheese) and cheese and cheese:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600 and not inv then
				table.insert(castQueue,{100,cheese})
			end	
			if wand and wand:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{100,wand})
			end	
			if stick and stick:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+600 and not inv and not me:DoesHaveModifier("modifier_elder_titan_echo_stomp") then
				table.insert(castQueue,{100,stick})
			end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(target)
			end
			sleep = tick + 200
		end
	end
end	



function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Elder_Titan then 
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
