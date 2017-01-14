--<<DooM script by MaZaiPC (AILEN's core)>>

require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Skillshot")
require("libs.Animations")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "D", config.TYPE_HOTKEY)
config:Load()

local play = false local myhero = nil local victim = nil local start = false local resettime = nil local sleep = {0,0,0}
local rate = client.screenSize.x/1600 local rec = {} local castQueue = {}
rec[1] = drawMgr:CreateRect(70*rate,26*rate,270*rate,60*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_status_1")) rec[1].visible = false
rec[2] = drawMgr:CreateText(175*rate,52*rate,0xFFFFFF90,"Target :",drawMgr:CreateFont("manabarsFont","Arial",18*rate,700)) rec[2].visible = false
rec[3] = drawMgr:CreateRect(220*rate,54*rate,16*rate,16*rate,0xFFFFFF30) rec[3].visible = false

function Main(tick)
	if not PlayingGame() then return end
	me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end

	if victim and victim.visible then
		if not rec[i] then
			rec[3].textureId = drawMgr:GetTextureId("NyanUI/miniheroes/"..victim.name:gsub("npc_dota_hero_",""))
		end
	else
		rec[3].textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
	end

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
			sleep[3] = tick + v[1] + client.latency
			return
		end
	end

	local attackRange = me.attackRange	

	if IsKeyDown(config.Hotkey) and not client.chat then	
		if Animations.CanMove(me) or not start or (victim and GetDistance2D(victim,me) > attackRange+50) then
			start = true
			local lowestHP = targetFind:GetLowestEHP(3000, phys)
			if lowestHP and (not victim or GetDistance2D(me,victim) > 600 or not victim.alive or lowestHP.health < victim.health) and SleepCheck("victim") then			
				victim = lowestHP
				Sleep(250,"victim")
			end
			if victim and GetDistance2D(victim,me) > attackRange+200 and victim.visible then
				local closest = targetFind:GetClosestToMouse(me,2000)
				if closest and (not victim or closest.handle ~= victim.handle) then 
					victim = closest
				end
			end
		end
		if not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 2000 then
			if tick > sleep[1] then
				if not Animations.isAttacking(me) then
					local shadowplay = me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk")
					local W = me:GetAbility(2)
					local E = me:GetAbility(3)
					local R = me:GetAbility(6)
					
					local CreepNet = GetSpell("dark_troll_warlord_ensnare")
					local CreepKentStun = GetSpell("centaur_khan_war_stomp")
					local CreepSWave = GetSpell("satyr_hellcaller_shockwave")
					local CreepIceArmor = GetSpell("ogre_magi_frost_armor")
					local CreepManaburn = GetSpell("satyr_soulstealer_mana_burn")
					local CreepShock = GetSpell("harpy_storm_chain_lightning") -- aka dagon
					local CreepRockStun = GetSpell("mud_golem_hurl_boulder")
					local moc = me:FindItem("item_medallion_of_courage")
					local satanic = me:FindItem("item_satanic")
					local blink = me:FindItem("item_blink")
					local shiva = me:FindItem("item_shivas_guard")
					local sheep = me:FindItem("item_sheepstick")
					local halberd = me:FindItem("item_heavens_halberd")
					local soulring = me:FindItem("item_soul_ring")
					local BlackKingBar = me:FindItem("item_black_king_bar")
					local distance = GetDistance2D(victim,me)
					if not shadowplay and victim.alive and victim.visible then
						if blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange+150 then
							local CP = blink:FindCastPoint()
							local delay = ((500-Animations.getDuration(blink)*1000)+CP*1000+client.latency+me:GetTurnTime(victim)*1000)
							local speed = blink:GetSpecialData("blink_range")
							local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
							if xyz then
								table.insert(castQueue,{math.ceil(blink:FindCastPoint()*1000),blink,xyz})
							end
						end
						
						--Creep spells
						if CreepKentStun and CreepKentStun:CanBeCasted() and me:CanCast() and distance < 250 then
							table.insert(castQueue,{100,CreepKentStun})
						elseif CreepKentStun and CreepKentStun.abilityPhase and Animations.getDuration(CreepKentStun) > 0.2 then
							me:Stop()
						end
						if CreepManaburn and CreepManaburn:CanBeCasted() and me:CanCast() and distance < CreepManaburn.castRange then
							table.insert(castQueue,{1000+math.ceil(CreepManaburn:FindCastPoint()*1000),CreepManaburn,victim})
						end
						if CreepShock and CreepShock:CanBeCasted() and me:CanCast() and distance < CreepShock.castRange then
							table.insert(castQueue,{1000+math.ceil(CreepShock:FindCastPoint()*1000),CreepShock,victim})
						end
						if CreepRockStun and CreepRockStun:CanBeCasted() and me:CanCast() and distance < CreepRockStun.castRange then
							table.insert(castQueue,{1000+math.ceil(CreepRockStun:FindCastPoint()*1000),CreepRockStun,victim})
						end
						if CreepNet and CreepNet:CanBeCasted() and me:CanCast() and distance > attackRange+150 and distance < CreepNet.castRange then
							table.insert(castQueue,{1000+math.ceil(CreepNet:FindCastPoint()*1000),CreepNet,victim})
						end
						if CreepIceArmor and CreepIceArmor:CanBeCasted() and not me:DoesHaveModifier("modifier_ogre_magi_frost_armor") then
							table.insert(castQueue,{1000+math.ceil(CreepIceArmor:FindCastPoint()*1000),CreepIceArmor,me})
						end
						if CreepSWave and CreepSWave:CanBeCasted() and me:CanCast() and distance < CreepSWave.castRange-5 then
							local CP = CreepSWave:FindCastPoint()
							local delay = ((500-Animations.getDuration(CreepSWave)*1000)+CP*1000+client.latency+me:GetTurnTime(victim)*1000)
							local speed = 200
							local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
							if xyz then
								table.insert(castQueue,{math.ceil(CreepSWave:FindCastPoint()*1000),CreepSWave,xyz})
							end
						end
						--Creep spells end
						if W and W:CanBeCasted() and me:CanCast() and distance < 590 then
							table.insert(castQueue,{100,W})
						end
						if E and E:CanBeCasted() and me:CanCast() then
							table.insert(castQueue,{1000+math.ceil(E:FindCastPoint()*1000),E,victim})
						end
						if R and R:CanBeCasted() and me:CanCast() and victim.health/victim.maxHealth >= 0.4 then
							table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,victim})
						end
						if shiva and shiva:CanBeCasted() and distance <= 500 and not victim:DoesHaveModifier("modifier_item_sheepstick") then
							table.insert(castQueue,{100,shiva})
						end
						if sheep and sheep:CanBeCasted() and me:CanCast() then
							table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*1000),sheep,victim})
						end
						if halberd and halberd:CanBeCasted() and distance < halberd.castRange and not victim:IsStunned() and not victim:DoesHaveModifier("modifier_item_sheepstick") and distance <= victim.attackRange then
							table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,victim})
						end
						if moc and moc:CanBeCasted() and distance < moc.castRange then
							table.insert(castQueue,{1000+math.ceil(moc:FindCastPoint()*1000),moc,victim})
						end
						if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+50 then
							table.insert(castQueue,{100,satanic})
						end	
						if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
							table.insert(castQueue,{100,soulring})
						end
						if BlackKingBar and BlackKingBar:CanBeCasted() then
							local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
							if #heroes == 3 then
								table.insert(castQueue,{100,BlackKingBar})
							elseif #heroes == 4 then
								table.insert(castQueue,{100,BlackKingBar})
							elseif #heroes == 5 then
								table.insert(castQueue,{100,BlackKingBar})
								return
							end
						end
					end
				end
				me:Attack(victim)
				sleep[1] = tick + 100
			end
		elseif tick > sleep[2] then
			if victim then
				if victim.visible then
					local xyz = SkillShot.PredictedXYZ(victim,me:GetTurnTime(victim)*1000+client.latency+500)
					me:Move(xyz)
				else
					me:Follow(victim)
				end
			end
			sleep[2] = tick + 100
			start = false
		end
	elseif victim then
		if not resettime then
			resettime = client.gameTime
		elseif (client.gameTime - resettime) >= 6 then
			victim = nil		
		end
		start = false
	end 
end

--Returns true if the input spell can be casted
function CanCast(spell)
        return  spell and spell.level ~= 0 and spell.state == LuaEntityAbility.STATE_READY
end
 
--Returns true if DooM has specified spell
function HasSpell(SpellName)
        return (me:GetAbility(4).name == SpellName) or (me:GetAbility(5).name == SpellName)
end
 
--Returns the spell from the name if DooM has it
function GetSpell(SpellName)
        if SpellName and HasSpell(SpellName) then
                if me:GetAbility(4).name == SpellName then
                        return me:GetAbility(4)
                elseif me:GetAbility(5).name == SpellName then
                        return me:GetAbility(5)
				else
						return false
                end
        end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_DoomBringer then 
			script:Disable() 
		else
			play = true
			victim = nil
			start = false
			resettime = nil
			myhero = me.classId
			rec[1].w = 90*rate + 30*0*rate + 65*rate rec[1].visible = true
			rec[2].x = 30*rate + 90*rate + 30*0*rate + 65*rate - 95*rate rec[2].visible = true
			rec[3].x = 80*rate + 90*rate + 30*0*rate + 65*rate - 50*rate rec[3].visible = true
			script:RegisterEvent(EVENT_FRAME, Main)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	myhero = nil
	victim = nil
	start = false
	resettime = nil
	rec[1].visible = false
	rec[2].visible = false
	rec[3].visible = false
	if play then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
