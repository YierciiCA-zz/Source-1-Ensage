require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Silencer")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Ult","UseUlt",SGC_TYPE_TOGGLE,false,true,nil)
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
		if target and GetDistance2D(target,me) <= 2000 and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
			local Q, W, E, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(3), me:GetAbility(4)
			local distance = GetDistance2D(target,me)
			local attackRange = me.attackRange	
			local dagon = me:FindDagon()
			local staff = me:FindItem("item_force_staff")
			local bkb = me:FindItem("item_black_king_bar")
			local halberd = me:FindItem("item_heavens_halberd")
			local ethereal = me:FindItem("item_ethereal_blade")
			local soulring = me:FindItem("item_soul_ring")
			local satanic = me:FindItem("item_satanic")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local veil = me:FindItem("item_veil_of_discord")
			local atos = me:FindItem("item_rod_of_atos")
			local shiva = me:FindItem("item_shivas_guard")
			local orchid = me:FindItem("item_orchid")
			local sheep = me:FindItem("item_sheepstick")
			local linkens = target:IsLinkensProtected()
			if Q and Q:CanBeCasted() and me:CanCast() then  
				table.insert(castQueue,{math.ceil(Q:FindCastPoint()*1000),Q,target.position})
			end
			if E and E:CanBeCasted() and me:CanCast() then  
				table.insert(castQueue,{math.ceil(E:FindCastPoint()*1000),E,target})
			end
			if atos and atos:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
			end
			if staff and staff.cd == 0 and staff:CanBeCasted() and IsPanic(me) then
				me:CastAbility(staff,me)
			end	
			if veil and veil:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
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
			if ethereal and ethereal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
			end
			if dagon and dagon:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
			end
			if W and W:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(W:FindCastPoint()*1000),W,target})
			end
			if me.mana < me.maxMana*0.5 and  soulring and soulring:CanBeCasted() then
				table.insert(castQueue,{100,soulring})
			end
			if halberd and halberd:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
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
			if ScriptConfig.Ult and R and R:CanBeCasted() then
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1500 end)
				if #heroes == 3 then
					table.insert(castQueue,{100,R})
				elseif #heroes == 4 then
					table.insert(castQueue,{100,R})
				elseif #heroes == 5 then
					table.insert(castQueue,{100,R})
				return
				end
			end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(me)
			end
			sleep = tick + 150
		end
	end
end

function IsPanic(me)
	return me:DoesHaveModifier("modifier_riki_smoke_screen")
	or me:DoesHaveModifier("modifier_rod_of_atos_debuff")
	or me:DoesHaveModifier("modifier_sand_king_epicenter_slow")
	or me:DoesHaveModifier("modifier_shadow_demon_purge_slow")
	or me:DoesHaveModifier("modifier_abaddon_frostmourne_debuff")
	or me:DoesHaveModifier("modifier_antimage_mana_break")
	or me:DoesHaveModifier("modifier_dark_seer_wall_of_replica")
	or me:DoesHaveModifier("modifier_drow_ranger_frost_arrows_slow")
	or me:DoesHaveModifier("modifier_gyrocopter_call_down_slow")
	or me:DoesHaveModifier("modifier_item_diffusal_blade_slow")
	or me:DoesHaveModifier("modifier_item_skadi_slow")
	or me:DoesHaveModifier("modifier_kunkka_torrent_slow")
	or me:DoesHaveModifier("modifier_magnataur_skewer_slow")
	or me:DoesHaveModifier("modifier_pudge_meat_hook")
	or me:DoesHaveModifier("modifier_skeleton_king_reincarnate_slow")
	or me:DoesHaveModifier("modifier_skywrath_mystic_flare_aura_effect")
	or me:DoesHaveModifier("modifier_slark_pounce")
	or me:DoesHaveModifier("modifier_terrorblade_reflection_slow")
	or me:DoesHaveModifier("modifier_ursa_earthshock")
	or me:DoesHaveModifier("modifier_wisp_tether_slow")
	or me:DoesHaveModifier("modifier_huskar_life_break_slow")
	or me:DoesHaveModifier("modifier_riki_smoke_screen_thinker") 
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Silencer then 
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
