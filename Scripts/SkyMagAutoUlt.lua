--<<Thanks for the idea autoult MazaiPC. Use auto ult at your own risk.)>>
require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")
require("libs.Animations2")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Skywrath Mage")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
 
ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Ult","Mystic Flare",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Auto","[BETA] Auto Ulti",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Soul","Soul Ring",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Arcan","Arcan",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("dagOn","Dagon",SGC_TYPE_TOGGLE,false,true,nil)
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
                if (target and target.alive and target.health > 0) and GetDistance2D(target,me) <= 2000 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
                        local Q, W, E, R  = me:GetAbility(1), me:GetAbility(2), me:GetAbility(3) , me:GetAbility(4)
                        local distance = GetDistance2D(target,me)
                        local dagon = me:FindDagon()
                        local ethereal = me:FindItem("item_ethereal_blade")
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
                        if E and E:CanBeCasted() and me:CanCast() and not linkens then
                                table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E,target})
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
                        if Q and Q:CanBeCasted() and me:CanCast() then
                                table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target})
                        end
                        if ethereal and ethereal:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_skywrath_mage_ancient_seal") then
                                table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
                        end
                        if atos and atos:CanBeCasted() and me:CanCast() then
                                table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
                        end
                        if distance <= 1590 and W and W:CanBeCasted() and me:CanCast() then
                                table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W})        
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
                        local ChanneledSpell = false
                        if R and R:CanBeCasted() and me:CanCast() then
                                for i,v in ipairs(target.abilities) do
                                        if v.abilityData.behavior == LuaEntityAbility.BEHAVIOR_CHANNELLED and v.channelTime > 1 then
ChanneledSpell = true
                                                local CP = R:FindCastPoint()
                                                local speed =1200  
                                                local distance = GetDistance2D(target, me)
                                                local delay =400+client.latency
                                                local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
                                                        if xyz and distance <= 1200  then  
me:SafeCastAbility(R, xyz)
Sleep(me:GetTurnTime(target)*1000, "casting")
                                                        end
                                        end
                                end
                        end
                        if (ScriptConfig.Ult or (not ScriptConfig.Auto and target:IsStunned())) and not target:FindModifier("modifier_skywrath_mystic_flare_aura_effect") and target:FindModifier("modifier_skywrath_mage_concussive_shot_slow") and R and R:CanBeCasted() and me:CanCast() and target.health > target.maxHealth*0.2 then
                                local CP = R:FindCastPoint()
                                local speed =1200  
                                local distance = GetDistance2D(target, me)
                                local delay =400+client.latency
                                local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
                                        if xyz and distance <= 1200  then  
me:SafeCastAbility(R, xyz)
Sleep(me:GetTurnTime(target)*1000, "casting")
                                        end
                        end
                        if ScriptConfig.dagOn and dagon and dagon:CanBeCasted() and me:CanCast() and target:DoesHaveModifier("modifier_skywrath_mage_ancient_seal") then
                                table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
                        end
			if distance > 350 and SleepCheck("all") then
					me:Follow(target)
				Sleep(client.latency+350,"all")
			end
			if distance < 600 and SleepCheck("all") then
					me:Attack(target)
				Sleep(client.latency+185,"all")
			end
sleep = tick + 300
                end
        end
end


function Mains(tick)
if  ScriptConfig.Auto then
		me = entityList:GetMyHero()
		if not me then return end
		if  not SleepCheck()  then return end
			local me = entityList:GetMyHero()
			local ID = me.classId if ID ~= myhero then return end
			target = v
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
				
		local R = me:GetAbility(4)
		local E = me:GetAbility(3)
		local veil = me:FindItem("item_veil_of_discord")
		local scepter = me:FindItem("item_ultimate_scepter")
		if  R and R:CanBeCasted() and me:CanCast()  then
			local enemies = entityList:GetEntities(function(v) return v.type == LuaEntity.TYPE_HERO and v.team == me:GetEnemyTeam() and v.visible and not v.illusion and v.alive  end)
				for i,target in ipairs(enemies)  do
				if me.mana >= me.maxMana*0.5 and IsSlowMove(target) or target:IsStunned() or IsStopMove(target) or target:IsHexed() and not NoUse(target) and target.health > target.maxHealth*0.3  and not target:IsMagicImmune() and SleepCheck() and not target:FindModifier("modifier_skywrath_mystic_flare_aura_effect") then
															local CP = R:FindCastPoint()
															local speed =1200  
															local distance = GetDistance2D(target, me)
															local delay = client.latency+100
															local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
															if veil and veil:CanBeCasted() and me:CanCast() and SleepCheck("allcast1") then
																me:SafeCastAbility(veil, xyz)
																Sleep(client.latency,"allcast1")
															end
															if E and E:CanBeCasted() and me:CanCast() and SleepCheck("allcast2") then
																me:SafeCastAbility(E,target)
																Sleep(client.latency,"allcast2")
															end
															if xyz and IsSlowMove(target) or target:IsHexed()  and not target:FindModifier("modifier_skywrath_mystic_flare_aura_effect") and distance <= 1200 and R:CanBeCasted() and me:CanCast() and SleepCheck("allcast3") and not scepter then  
																me:SafeCastAbility(R,target.position)
																	Sleep(client.latency+300,"allcast3")
															end
															if (IsStopMove(target) or target:IsStunned()) and not target:FindModifier("modifier_skywrath_mystic_flare_aura_effect") and not scepter and R and R:CanBeCasted() and me:CanCast() and target.health > target.maxHealth*0.2 and SleepCheck("allcast4") then
																local CP = R:FindCastPoint()
																local speed =1200  
																local distance = GetDistance2D(target, me)
																local delay = client.latency+50
																local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
																	if xyz and distance <= 1200  then  
																		me:SafeCastAbility(R, xyz)
																	Sleep(client.latency+300,"allcast4")
																	end
															end
															if xyz and IsSlowMove(target) or target:IsHexed()  and not target:FindModifier("modifier_skywrath_mystic_flare_aura_effect") and distance <= 1200 and R:CanBeCasted() and me:CanCast() and SleepCheck("allcast3") and scepter then  
																me:SafeCastAbility(R,target.position)
																	Sleep(client.latency+1600,"allcast3")
															end
															if (IsStopMove(target) or target:IsStunned()) and not target:FindModifier("modifier_skywrath_mystic_flare_aura_effect") and R and R:CanBeCasted() and me:CanCast() and target.health > target.maxHealth*0.2 and SleepCheck("allcast4") and scepter then
																local CP = R:FindCastPoint()
																local speed =1200  
																local distance = GetDistance2D(target, me)
																local delay = client.latency+50
																local xyz = SkillShot.SkillShotXYZ(me,target,delay,speed)
																	if xyz and distance <= 1200  then  
																		me:SafeCastAbility(R, xyz)
																	Sleep(client.latency+1600,"allcast4")
																	end
															end
												end
									end		
						end
			end
end

function NoUse(target)
        return  target:DoesHaveModifier("modifier_rune_haste")
			or target:DoesHaveModifier("modifier_lycan_shapeshift_speed")
			or target:DoesHaveModifier("modifier_centaur_stampede") 
end

function IsStopMove(target)
        return  target:DoesHaveModifier("modifier_crystal_maiden_frostbite_ministun")
			or target:DoesHaveModifier("modifier_winter_wyvern_winters_curse")
			or target:DoesHaveModifier("modifier_axe_berserkers_call") 
			or target:DoesHaveModifier("modifier_legion_commander_duel")
			or target:DoesHaveModifier("modifier_ember_spirit_searing_chains")
			or target:DoesHaveModifier("modifier_lone_druid_spirit_bear_entangle_effect")
			or target:DoesHaveModifier("modifier_naga_siren_ensnare")
			or target:DoesHaveModifier("modifier_rubick_telekinesis")
			or target:DoesHaveModifier("modifier_shadow_shaman_shackles")
			or target:DoesHaveModifier("modifier_storm_spirit_electric_vortex_pull")
			or target:DoesHaveModifier("modifier_winter_wyvern_cold_embrace")
			or target:DoesHaveModifier("modifier_bane_fiends_grip")
end

function IsSlowMove(target)
        return  target:DoesHaveModifier("modifier_item_diffusal_blade_slow")
                or target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
                or target:DoesHaveModifier("modifier_kunkka_torrent_slow")
                or target:DoesHaveModifier("modifier_faceless_void_time_walk_slow")
                or target:DoesHaveModifier("modifier_lich_slow")
                or target:DoesHaveModifier("modifier_templar_assassin_trap_slow")
                or target:DoesHaveModifier("modifier_terrorblade_reflection_slow")
                or target:DoesHaveModifier("modifier_troll_warlord_whirling_axes_slow")
                or target:DoesHaveModifier("modifier_tusk_walrus_punch_slow")
                or target:DoesHaveModifier("modifier_viper_viper_strike_slow")
                or target:DoesHaveModifier("modifier_crystal_maiden_freezing_field_slow")
                or target:DoesHaveModifier("modifier_drow_ranger_frost_arrows_slow")
                or target:DoesHaveModifier("modifier_ghost_frost_attack_slow")
                or target:DoesHaveModifier("modifier_gyrocopter_call_down_slow")
                or target:DoesHaveModifier("modifier_huskar_life_break_slow")
                or target:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff")
				or target:DoesHaveModifier("modifier_axe_berserkers_call_armor")
				or target:DoesHaveModifier("modifier_dazzle_poison_touch")
				or target:DoesHaveModifier("modifier_earth_spirit_rolling_boulder_slow")
				or target:DoesHaveModifier("modifier_elder_titan_earth_splitter")
				or target:DoesHaveModifier("modifier_enchantress_enchant_slow")
				or target:DoesHaveModifier("modifier_life_stealer_open_wounds")
				or target:DoesHaveModifier("modifier_magnataur_skewer_slow")
				or target:DoesHaveModifier("modifier_night_stalker_void")
				or target:DoesHaveModifier("modifier_omniknight_degen_aura_effect")
				or target:DoesHaveModifier("modifier_phantom_assassin_stiflingdagger")
				or target:DoesHaveModifier("modifier_pugna_decrepify")
				or target:DoesHaveModifier("modifier_shadow_demon_purge_slow")
				or target:DoesHaveModifier("modifier_tidehunter_gush")
				or target:DoesHaveModifier("modifier_tusk_frozen_sigil_aura")
				or target:DoesHaveModifier("modifier_ursa_earthshock")
				or target:DoesHaveModifier("modifier_venomancer_venomous_gale")
				or target:DoesHaveModifier("modifier_warlock_upheaval")
end
 
function Load()
        if PlayingGame() then
                local me = entityList:GetMyHero()
                if not me or me.classId ~= CDOTA_Unit_Hero_Skywrath_Mage then
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
