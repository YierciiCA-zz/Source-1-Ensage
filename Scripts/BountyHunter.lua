require("libs.Utils")
local damage = {100,200,250,325}
local range = 650
local sleepTick = nil

-- Setting
-- % enemy hp for use track.
local hpbarfortrack = 0.4
-- Auto Track when enemy HP enemy < %
local autotrackhp = true
-- Auto Track when enemy have invisible rune,items,spells.
local autotrackinv = true
-- Auto Shuriken Steal.
local shurikensteal = true
function Tick( tick )
	if not client.connected or client.loading or client.console or client.paused then 
		return 
	end
	
	local me = entityList:GetMyHero()
	
	if not me then return end
	
	if sleepTick and sleepTick > tick then
		return
	end

	if me.name ~= "npc_dota_hero_bounty_hunter" then
		script:Disable()
	else
		local Shuriken = me:GetAbility(1)
		local Track = me:GetAbility(4)
		
		local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,alive=true,illusion=false,team = (5-me.team),visible=true})
		for i,v in ipairs(enemies) do
			local distance = GetDistance2D(me,v)
			if v.health > 0 and distance <= 1300 then
				local CheckTrack = v:DoesHaveModifier("modifier_bounty_hunter_track")
				local CheckInvis = me:DoesHaveModifier("modifier_bounty_hunter_wind_walk")
				if autotrackinv and InvisibleHeroes(v) and not CheckTrack and not CheckInvis and distance <= 1200 then
					me:SafeCastAbility(Track,v)
				end		
				if autotrackhp and not CheckTrack and not CheckInvis and v.health/v.maxHealth < hpbarfortrack and distance <= 1200 then
					me:SafeCastAbility(Track,v)
				end
				if shurikensteal and Shuriken.level > 0 and v.health+v.healthRegen < damage[Shuriken.level]*(1-v.magicDmgResist) and distance < range then
					me:SafeCastAbility(Shuriken,v)
				end
			end
		end
	end
	sleepTick = tick + 333
	return
end

function InvisibleHeroes(v)
	local invokerhuesos=ivoka("invoker_ghost_walk",v)
	local invisItem = v:FindItem("item_invis_sword")
	local invisBottle = v:FindItem("item_bottle")
	if invisItem and invisItem.state == LuaEntityAbility.STATE_READY then
		return true
	end
	if invisBottle and invisBottle.storedRune == 3 then
		return true
	end
	if v.name == "npc_dota_hero_riki" then
		if v:GetAbility(4).level ~=0 then
			return true
		end
	elseif v.name == "npc_dota_hero_clinkz" then
		if v:GetAbility(3).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_nyx_assassin" then
		if v:GetAbility(3).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_templar_assassin" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_broodmother" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_weaver" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_treant" then
		if v:GetAbility(1).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_sand_king" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_invoker" then
			if invokerhuesos then
				if invokerhuesos.state == LuaEntityAbility.STATE_READY then
					return true
				end
			end
	end
	return false
end

function etotJeEtotSpell(spellname,v)
        return (v:GetAbility(4).name == spellname) or (v:GetAbility(5).name == spellname)
end

function ivoka(spellname,v)
        if spellname and etotJeEtotSpell(spellname,v) then
                if v:GetAbility(4).name == spellname then
                        return v:GetAbility(4)
                elseif v:GetAbility(5).name == spellname then
                        return v:GetAbility(5)
                end
        end
end

script:RegisterEvent(EVENT_TICK,Tick)
