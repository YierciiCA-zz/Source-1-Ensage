--<<Slardar script by MaZaiPC (AILEN's core)>>

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
	local me = entityList:GetMyHero()
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
					local Q = me:GetAbility(1)
					local W = me:GetAbility(2)
					local R = me:GetAbility(4)
					local moc = me:FindItem("item_medallion_of_courage")
					local blink = me:FindItem("item_blink")
					local satanic = me:FindItem("item_satanic")
					local halberd = me:FindItem("item_heavens_halberd")
					local shiva = me:FindItem("item_shivas_guard")
					local soulring = me:FindItem("item_soul_ring")
					local BlackKingBar = me:FindItem("item_black_king_bar")
					local distance = GetDistance2D(victim,me)
					if not shadowplay and victim.alive and victim.visible then
						if blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange then
							local CP = blink:FindCastPoint()
							local delay = ((500-Animations.getDuration(blink)*1000)+CP*1000+client.latency+me:GetTurnTime(victim)*1000)
							local speed = blink:GetSpecialData("blink_range")
							local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
							if xyz then
								table.insert(castQueue,{math.ceil(blink:FindCastPoint()*1000),blink,xyz})
							end
						end
						if Q and Q:CanBeCasted() and me:CanCast() then
							if blink then
								if not blink:CanBeCasted() and distance > 350 then
									table.insert(castQueue,{100,Q})
								end
							else
								table.insert(castQueue,{100,Q})
							end
						end
						if W and W:CanBeCasted() and me:CanCast() and distance < 345 then
							table.insert(castQueue,{100,W})
						elseif W.abilityPhase and Animations.getDuration(W) > 0.3 then
							me:Stop()
						end
						if shiva and shiva:CanBeCasted() and distance <= 600 then
							table.insert(castQueue,{100,shiva})
						end
						if R and R:CanBeCasted() and me:CanCast() and distance < R.castRange and not victim:DoesHaveModifier("modifier_slardar_amplify_damage") then
							table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,victim})
						end
						if moc and moc:CanBeCasted() and distance < moc.castRange then
							table.insert(castQueue,{1000+math.ceil(moc:FindCastPoint()*1000),moc,victim})
						end
						if halberd and halberd:CanBeCasted() and distance < halberd.castRange and not victim:IsStunned() then
							table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,victim})
						end
						if me.mana < me.maxMana*0.3 and soulring and soulring:CanBeCasted() and W.state ~= LuaEntityAbility.STATE_COOLDOWN then
							table.insert(castQueue,{100,soulring})
						end
						if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.5 then
							table.insert(castQueue,{100,satanic})
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

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Slardar then 
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
