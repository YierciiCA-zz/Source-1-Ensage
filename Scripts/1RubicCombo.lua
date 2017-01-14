--[[Thanks to a small help Fodder]]
require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("RubickCombo")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("KeyD","UseStealSpell",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Blink","UseBlink",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("UseR","UseUltR",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("GoHomeLowHP","GoHomeLowHP",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Soul","Soul Ring",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Arcan","Arcan",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("dagOn","Dagon",SGC_TYPE_TOGGLE,false,true,nil)

local play, target, castQueue, castsleep, sleep = false, nil, {}, 0, 0
local me = entityList:GetMyHero()


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
			local Q, W, D, R = me:GetAbility(1), me:GetAbility(3), me:GetAbility(5), me:GetAbility(7)
			local distance = GetDistance2D(target,me)
			local dagon = me:FindDagon()
			local ethereal = me:FindItem("item_ethereal_blade")
			local veil = me:FindItem("item_veil_of_discord")
			local atos = me:FindItem("item_rod_of_atos")
			local shiva = me:FindItem("item_shivas_guard")
			local orchid = me:FindItem("item_orchid")
			local sheep = me:FindItem("item_sheepstick")
			local soulring = me:FindItem("item_soul_ring")
			local arcane = me:FindItem("item_arcane_boots")
			local blink = me:FindItem("item_blink")
			local attackRange = me.attackRange	
			
		--[[	local bases = entityList:GetEntities(function (ent) return ent.classId==CDOTA_Unit_Fountain, end)[1]	
			local bases = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = meTeam})[1]
					if (ScriptConfig.GoHomeLowHP) and bases and SleepCheck("all") and me.health/me.maxHealth < 0.7 then 
					entityList:GetMyPlayer():Select(me)
					entityList:GetMyPlayer():Move(bases)
						Sleep(client.latency+600,"all")
			end]]
			if (ScriptConfig.Blink) and GetDistance2D(me,target) and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
			end
			if ScriptConfig.dagOn and dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_item_ethereal_blade_slow") and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if W and W:CanBeCasted() and me:CanCast() then
				me:SafeCastAbility(W,target)
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
			if Q and Q:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target})
			end
			if Q and Q:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_rubick_telekinesis") and SleepCheck("all") then
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,me.position})
						Sleep(client.latency+700,"all")
			end
			if (ScriptConfig.KeyD) and distance <= 325 and D and D:CanBeCasted() and me:CanCast() and not IsTargetSpell(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D})
			end
			if (ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and not IsTargetSpell(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,target.position})
			end
			if (ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsPanick(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,target.position})
			end
			if (ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsPanick(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,target})
			end
			if (ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsPanick(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D})
			end
			if (ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsPanick(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,me})
			end
			if (ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and not IsTargetSpell(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,target})
			end
			if (ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsMeSpell(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,me})
			end
			
			if (ScriptConfig.GoHomeLowHP and ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsGoHome(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,base.position})
			end
			if (ScriptConfig.GoHomeLowHP and ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsGoHome(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D})
			end
			if (ScriptConfig.GoHomeLowHP and ScriptConfig.KeyD) and D and D:CanBeCasted() and me:CanCast() and IsGoHome(spell) and not me:IsInvisible() then
				table.insert(castQueue,{1000+math.ceil(D:FindCastPoint()*1000),D,me})
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
			if ScriptConfig.dagOn and dagon and dagon:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if ScriptConfig.UseR and R and R:CanBeCasted() and me:CanCast() and D.abilityPhase and not me:IsInvisible()  then
				table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target})
			end
			sleep = tick + 200
		end
	end
end

function Mains(tick)
    if ScriptConfig.GoHomeLowHP and not SleepCheck() then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end
	foun = {Vector(-7263,-6747,281)}
	foun2 = {Vector(7204,6611,262)}
	if ScriptConfig.GoHomeLowHP and me.controllable and me.unitState ~= -1031241196 and me.health/me.maxHealth < 0.5 and not me:DoesHaveModifier("modifier_bloodseeker_rupture") and me.alive then
		if me.team == LuaEntity.TEAM_RADIANT then
		me:Move(foun[1])
			Sleep(1000)
		else
		me:Move(foun2[1])
			Sleep(1000)
		end
	end
end


function IsGoHome(spell)
	local me = entityList:GetMyHero() 
	if me.health/me.maxHealth <= 0.3 and not me:IsInvisible() then
	return me:FindSpell("antimage_blink")
	or me:FindSpell("chen_teleport")
	or me:FindSpell("faceless_void_time_walk")
	or me:FindSpell("morphling_morph_str")
	or me:FindSpell("dark_seer_surge")
	or me:FindSpell("dazzle_shallow_grave")
	or me:FindSpell("huskar_inner_vitality")
	or me:FindSpell("invoker_ghost_walk")
	or me:FindSpell("nyx_assassin_vendetta")
	or me:FindSpell("queen_blink")
	or me:FindSpell("omniknight_purification")
	or me:FindSpell("slark_pounce")
	or me:FindSpell("weaver_shukuchi")
	or me:FindSpell("wisp_relocate")
	or me:FindSpell("magnataur_skewer")
	end
end

function IsPanick(spell)
	local me = entityList:GetMyHero() 
	if me.health/me.maxHealth <= 0.3 and not me:IsInvisible() then
	return me:FindSpell("omniknight_repel")
	or me:FindSpell("abaddon_aphotic_shield")
	or me:FindSpell("bounty_hunter_windwalk")
	or me:FindSpell("clinkz_windwalk")
	or me:FindSpell("dark_seer_surge")
	or me:FindSpell("dazzle_shallow_grave")
	or me:FindSpell("huskar_inner_vitality")
	or me:FindSpell("invoker_ghost_walk")
	or me:FindSpell("nyx_assassin_vendetta")
	or me:FindSpell("puck_phase_shift")
	or me:FindSpell("omniknight_purification")
	or me:FindSpell("legion_commander_press")
	or me:FindSpell("sandking_sandstorm")
	or me:FindSpell("shadow_demon_disruption")
	or me:FindSpell("treant_naturesguise")
	or me:FindSpell("tusk_snowball")
	or me:FindSpell("warlock_shadow_word")
	or me:FindSpell("weaver_shukuchi")
	or me:FindSpell("witchdoctor_voodoo_restoration")
	end
end

function IsMeSpell(spell)
	local me = entityList:GetMyHero()
	return me:FindSpell("omniknight_repel")
	or me:FindSpell("abaddon_aphotic_shield")
	or me:FindSpell("bloodseeker_bloodrage")
	or me:FindSpell("dazzle_shadow_wave")
	or me:FindSpell("dark_seer_ion_shell")
	or me:FindSpell("dark_seer_surge")
	or me:FindSpell("invoker_alacrity")
	or me:FindSpell("chakra_magic")
	or me:FindSpell("lich_frost_armor")
	or me:FindSpell("magnataur_empower")
	or me:FindSpell("ogre_magi_bloodlust")
	or me:FindSpell("omniknight_purification")
	or me:FindSpell("legion_commander_press")
end

function AllCast(spell)
	local me = entityList:GetMyHero()
	return me:FindSpell("bane_fiends_grip")
	or me:FindSpell("maiden_freezing_field")
	or me:FindSpell("elder_titan_echo_stomp")
	or me:FindSpell("enigma_blackhole")
	or me:FindSpell("keeper_illuminate")
	or me:FindSpell("nevermore_requiemofsouls")
	or me:FindSpell("sandking_epicenter")
	or me:FindSpell("sandking_sandstorm")
	or me:FindSpell("shadowshaman_shackle")
	or me:FindSpell("Warlock_Upheaval")
	or me:FindSpell("witchdoctor_ward")
	or me:FindSpell("witchdoctor_deathward")
	or me:FindSpell("pudge_dismember")
	or me:FindSpell("windrunner_spell_powershot")
end

function IsTargetSpell(spell)
	local me = entityList:GetMyHero()
	return me:FindSpell("invoker_ghost_walk")
	or me:FindSpell("abaddon_aphotic_shield")
	or me:FindSpell("antimage_blink")
	or me:FindSpell("bloodseeker_bloodrage")
	or me:FindSpell("clinkz_windwalk")
	or me:FindSpell("dark_seer_ion_shell")
	or me:FindSpell("dark_seer_surge")
	or me:FindSpell("dazzle_shallow_grave")
	or me:FindSpell("disruptor_glimpse")
	or me:FindSpell("enigma_demonic_conversion")
	or me:FindSpell("furion_teleport")
	or me:FindSpell("Furion_Sprout")
	or me:FindSpell("furion_wrath_of_nature")
	or me:FindSpell("huskar_inner_vitality")
	or me:FindSpell("invoker_alacrity")
	or me:FindSpell("invoker_ghost_walk")
	or me:FindSpell("lich_frost_armor")
	or me:FindSpell("ogre_magi_bloodlust")
	or me:FindSpell("omniknight_repel")
	or me:FindSpell("puck_phase_shift")
	or me:FindSpell("queen_blink")
	or me:FindSpell("shadow_demon_disruption")
	or me:FindSpell("shredder_timberchain")
	or me:FindSpell("naga_siren_song")
	or me:FindSpell("treant_naturesguise")
	or me:FindSpell("weaver_shukuchi")
	or me:FindSpell("oracle_fates_edict")
	or me:FindSpell("bounty_hunter_wind_walk")
	or me:FindSpell("lion_spell_mana_drain")
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Rubick then 
			script:Disable()
		else
			play, target, myhero = true, nil, me.classId
			ScriptConfig:SetVisible(true)
			script:RegisterEvent(EVENT_TICK, Main)
			script:RegisterEvent(EVENT_TICK, Mains)
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
		script:UnregisterEvent(Mains)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close) 
script:RegisterEvent(EVENT_TICK, Load)
