require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("InvokerItem")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("ComboKey1","KeyItem1",SGC_TYPE_ONKEYDOWN,false,false,90)
ScriptConfig:AddParam("CombKey1","UseItem1",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("ComboKey2","KeyItem2",SGC_TYPE_ONKEYDOWN,false,false,88)
ScriptConfig:AddParam("CombKey2","UseItem2",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("ComboKey3","KeyItem3",SGC_TYPE_ONKEYDOWN,false,false,67)
ScriptConfig:AddParam("CombKey3","UseItem3",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("ComboKey4","KeyItem4",SGC_TYPE_ONKEYDOWN,false,false,86)
ScriptConfig:AddParam("CombKey4","UseItem4",SGC_TYPE_TOGGLE,false,true,nil)
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
	
	if (ScriptConfig.ComboKey1) and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
		if target and (ScriptConfig.CombKey1) and GetDistance2D(target,me) <= 2500 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
				local distance = GetDistance2D(target,me)
				local attackRange = me.attackRange	
				local dagon = me:FindDagon()
				local halberd = me:FindItem("item_heavens_halberd")
				local abyssal = me:FindItem("item_abyssal_blade")
				local shiva = me:FindItem("item_shivas_guard")
				local sheep = me:FindItem("item_sheepstick")
				local ethereal = me:FindItem("item_ethereal_blade")
				local veil = me:FindItem("item_veil_of_discord")
				local atos = me:FindItem("item_rod_of_atos")
				local mom = me:FindItem("item_mask_of_madness")
				local satanic = me:FindItem("item_satanic")
				local sheep = me:FindItem("item_sheepstick")
				local orchid = me:FindItem("item_orchid")
				local soulring = me:FindItem("item_soul_ring")
				local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
				local blink = me:FindItem("item_blink")
				local attackRange = me.attackRange	
				local RangeBlink = 1600
				if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
				if halberd and halberd:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
				end
				if shiva and shiva:CanBeCasted() and distance <= 600  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{100,shiva})
				end
				if abyssal and abyssal:CanBeCasted() and me:CanCast()  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
				end
				if mom and mom:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
				end
				if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange then
					table.insert(castQueue,{100,satanic})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if orchid and orchid:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,target})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if ethereal and ethereal:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
				end
				if atos and atos:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
				end
				if veil and veil:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
				end
				if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
					table.insert(castQueue,{100,soulring})
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(me)
			end
			sleep = tick + 450
		end
	end
	
	if (ScriptConfig.ComboKey2) and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
		if target and (ScriptConfig.CombKey2) and GetDistance2D(target,me) <= 2500 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
				local distance = GetDistance2D(target,me)
				local attackRange = me.attackRange	
				local dagon = me:FindDagon()
				local halberd = me:FindItem("item_heavens_halberd")
				local abyssal = me:FindItem("item_abyssal_blade")
				local shiva = me:FindItem("item_shivas_guard")
				local sheep = me:FindItem("item_sheepstick")
				local ethereal = me:FindItem("item_ethereal_blade")
				local veil = me:FindItem("item_veil_of_discord")
				local atos = me:FindItem("item_rod_of_atos")
				local mom = me:FindItem("item_mask_of_madness")
				local satanic = me:FindItem("item_satanic")
				local sheep = me:FindItem("item_sheepstick")
				local orchid = me:FindItem("item_orchid")
				local soulring = me:FindItem("item_soul_ring")
				local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
				local blink = me:FindItem("item_blink")
				local attackRange = me.attackRange	
				local RangeBlink = 1600
				if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
				if halberd and halberd:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
				end
				if shiva and shiva:CanBeCasted() and distance <= 600  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{100,shiva})
				end
				if abyssal and abyssal:CanBeCasted() and me:CanCast()  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
				end
				if mom and mom:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
				end
				if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange then
					table.insert(castQueue,{100,satanic})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if orchid and orchid:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,target})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if ethereal and ethereal:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
				end
				if atos and atos:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
				end
				if veil and veil:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
				end
				if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
					table.insert(castQueue,{100,soulring})
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(me)
			end
			sleep = tick + 450
		end
	end
	
	if (ScriptConfig.ComboKey3) and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
		if target and (ScriptConfig.CombKey3) and GetDistance2D(target,me) <= 2500 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
				local distance = GetDistance2D(target,me)
				local attackRange = me.attackRange	
				local dagon = me:FindDagon()
				local halberd = me:FindItem("item_heavens_halberd")
				local abyssal = me:FindItem("item_abyssal_blade")
				local shiva = me:FindItem("item_shivas_guard")
				local sheep = me:FindItem("item_sheepstick")
				local ethereal = me:FindItem("item_ethereal_blade")
				local veil = me:FindItem("item_veil_of_discord")
				local atos = me:FindItem("item_rod_of_atos")
				local mom = me:FindItem("item_mask_of_madness")
				local satanic = me:FindItem("item_satanic")
				local sheep = me:FindItem("item_sheepstick")
				local orchid = me:FindItem("item_orchid")
				local soulring = me:FindItem("item_soul_ring")
				local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
				local blink = me:FindItem("item_blink")
				local attackRange = me.attackRange	
				local RangeBlink = 1600
				if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
				if halberd and halberd:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
				end
				if shiva and shiva:CanBeCasted() and distance <= 600  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{100,shiva})
				end
				if abyssal and abyssal:CanBeCasted() and me:CanCast()  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
				end
				if mom and mom:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
				end
				if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange then
					table.insert(castQueue,{100,satanic})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if orchid and orchid:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,target})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if ethereal and ethereal:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
				end
				if atos and atos:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
				end
				if veil and veil:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
				end
				if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
					table.insert(castQueue,{100,soulring})
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(me)
			end
			sleep = tick + 450
		end
	end
	
	if (ScriptConfig.ComboKey4) and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
		if target and (ScriptConfig.CombKey4) and GetDistance2D(target,me) <= 2500 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
				local distance = GetDistance2D(target,me)
				local attackRange = me.attackRange	
				local dagon = me:FindDagon()
				local halberd = me:FindItem("item_heavens_halberd")
				local abyssal = me:FindItem("item_abyssal_blade")
				local shiva = me:FindItem("item_shivas_guard")
				local sheep = me:FindItem("item_sheepstick")
				local ethereal = me:FindItem("item_ethereal_blade")
				local veil = me:FindItem("item_veil_of_discord")
				local atos = me:FindItem("item_rod_of_atos")
				local mom = me:FindItem("item_mask_of_madness")
				local satanic = me:FindItem("item_satanic")
				local sheep = me:FindItem("item_sheepstick")
				local orchid = me:FindItem("item_orchid")
				local soulring = me:FindItem("item_soul_ring")
				local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
				local blink = me:FindItem("item_blink")
				local attackRange = me.attackRange	
				local RangeBlink = 1600
				if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
				if halberd and halberd:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
				end
				if shiva and shiva:CanBeCasted() and distance <= 600  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{100,shiva})
				end
				if abyssal and abyssal:CanBeCasted() and me:CanCast()  and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
				end
				if mom and mom:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
				end
				if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange then
					table.insert(castQueue,{100,satanic})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if orchid and orchid:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,target})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if ethereal and ethereal:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
				end
				if atos and atos:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
				end
				if veil and veil:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
				end
				if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
					table.insert(castQueue,{100,soulring})
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_invoker_tornado") then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(me)
			end
			sleep = tick + 450
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me and me.name ~= "npc_dota_hero_invoker"  then
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
