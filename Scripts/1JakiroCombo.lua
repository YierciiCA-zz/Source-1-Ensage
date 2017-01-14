require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("JakiroOneKey")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Soul","Soul Ring",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Arcan","Arcan",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Blink","UseBlink",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("dagOn","Dagon",SGC_TYPE_TOGGLE,false,true,nil)

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
		if target and GetDistance2D(target,me) <= 2000 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
			local Q, W, E, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(3), me:GetAbility(4)
			local distance = GetDistance2D(target,me)
			local dagon = me:FindDagon()
			local ethereal = me:FindItem("item_ethereal_blade")
			local veil = me:FindItem("item_veil_of_discord")
			local atos = me:FindItem("item_rod_of_atos")
			local shiva = me:FindItem("item_shivas_guard")
			local orchid = me:FindItem("item_orchid")
			local sheep = me:FindItem("item_sheepstick")
			local soulring = me:FindItem("item_soul_ring")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local arcane = me:FindItem("item_arcane_boots")
			local linkens = target:IsLinkensProtected()
			local blink = me:FindItem("item_blink")
			local attackRange = me.attackRange	
			local RangeBlink = 1600
			if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
			end
			if W and W:CanBeCasted() and me:CanCast() and IsSlowMove(target) or target:IsStunned() then
				local CP = W:FindCastPoint()
				local speed = 1500  
				local distance = GetDistance2D(target, me)
				local delay =10+client.latency
				local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
					if xyz and distance <= 900  then  
						me:SafeCastAbility(W, xyz)
				end
			end 
			if E and E:CanBeCasted() and me:CanCast() or linkens or target:DoesHaveModifier("modifier_jakiro_dual_breath_slow") then
				me:CastAbility(E,target)
				Sleep(150)
			end
			if ScriptConfig.dagOn and dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if shiva and shiva:CanBeCasted() and distance <= 600 then
				table.insert(castQueue,{100,shiva})
			end
			if sheep and sheep:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
			end
			if orchid and orchid:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,target})
			end
			if Q and Q:CanBeCasted() and me:CanCast() and not linkens then
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target})
			end
			if ethereal and ethereal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
			end
			if atos and atos:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
			end
			if veil and veil:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
			end
			if me.mana < me.maxMana*0.5 and ScriptConfig.Arcan and arcane and arcane:CanBeCasted() then
				table.insert(castQueue,{100,arcane})
			end
			if me.mana < me.maxMana*0.5 and ScriptConfig.Soul and soulring and soulring:CanBeCasted() then
				table.insert(castQueue,{100,soulring})
			end
			if distance <= 900 and R and R:CanBeCasted() and me:CanCast() and IsSlowMove(target) or target:IsStunned() and not linkens  then
				local CP = R:FindCastPoint()
				local delay = CP*1000+client.latency+me:GetTurnTime(target)*1000
				local speed = 1200
				local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
				if xyz then 
					table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target})
				end
			end
			if ScriptConfig.dagOn and dagon and dagon:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(me)
			end
			sleep = tick + 100
		end
	end
end

function IsSlowMove(target)
	return target:DoesHaveModifier("modifier_rod_of_atos_debuff")
	or target:DoesHaveModifier("modifier_skywrath_mage_concussive_shot_slow")
	or target:DoesHaveModifier("modifier_item_diffusal_blade_slow")
	or target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
	or target:DoesHaveModifier("modifier_kunkka_torrent_slow")
	or target:DoesHaveModifier("modifier_leshrac_lightning_storm_slow")
	or target:DoesHaveModifier("modifier_lich_slow")
	or target:DoesHaveModifier("modifier_templar_assassin_trap_slow")
	or target:DoesHaveModifier("modifier_terrorblade_reflection_slow")
	or target:DoesHaveModifier("modifier_troll_warlord_whirling_axes_slow")
	or target:DoesHaveModifier("modifier_tusk_walrus_punch_slow")
	or target:DoesHaveModifier("modifier_viper_viper_strike_slow")
	or target:DoesHaveModifier("modifier_crystal_maiden_freezing_field_slow")
	or target:DoesHaveModifier("modifier_drow_ranger_frost_arrows_slow")
	or target:DoesHaveModifier("modifier_enchantress_enchant_slow")
	or target:DoesHaveModifier("modifier_ghost_frost_attack_slow")
	or target:DoesHaveModifier("modifier_gyrocopter_call_down_slow")
	or target:DoesHaveModifier("modifier_huskar_life_break_slow")
	or target:DoesHaveModifier("modifier_skeleton_king_reincarnate_slow")
	or target:DoesHaveModifier("modifier_viper_poison_attack_slow")
	or target:DoesHaveModifier("modifier_jakiro_dual_breath_slow")
	or target:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff")
	or target:DoesHaveModifier("odifier_faceless_void_time_walk_slow") 
	or target:DoesHaveModifier("modifier_axe_berserkers_call")
	or target:DoesHaveModifier("modifier_legion_commander_duel") 
	or target:DoesHaveModifier("modifier_venomancer_venomous_gale") 
	or target:DoesHaveModifier("modifier_tusk_walrus_punch_slow")
	or target:DoesHaveModifier("modifier_undying_tombstone_zombie_deathstrike_slow") 
end
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Jakiro then 
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
