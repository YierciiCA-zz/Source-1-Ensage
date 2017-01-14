--<<Weaver script by MaZaiPC>>

require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Skillshot")
require("libs.Animations")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "D", config.TYPE_HOTKEY)
config:SetParameter("FastMove", "F", config.TYPE_HOTKEY)
config:SetParameter("FountainSafe", "G", config.TYPE_HOTKEY)
config:SetParameter("SmartBKB", true)
config:SetParameter("minEnemiesToSmartBKB", 3) -- Optimal for me, but u can change
config:Load()

local play = false local myhero = nil local victim = nil local start = false local resettime = nil local sleep = {0,0,0} local ShukuchiC, ShukuchiDmg = {12,10,8,6}, {75,100,125,150}
local rate = client.screenSize.x/1600 local rec = {} local castQueue = {} local FastMove = false local IsActionSafe = true local dangerRangeEffect local enemyFountain = nil local SafeSwitch = true
rec[1] = drawMgr:CreateRect(70*rate,26*rate,270*rate,60*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_status_1")) rec[1].visible = false
rec[2] = drawMgr:CreateText(175*rate,52*rate,0xFFFFFF90,"Target :",drawMgr:CreateFont("manabarsFont","Arial",18*rate,700)) rec[2].visible = false
rec[3] = drawMgr:CreateRect(220*rate,54*rate,16*rate,16*rate,0xFFFFFF30) rec[3].visible = false

local x,y = 1320, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Verdana",15*monitor,550*monitor)
local SFM = drawMgr:CreateText(x*monitor,y*monitor,-1,"Fast Move: ''"..string.char(config.FastMove).."'' Status: OFF",F14) SFM.visible = false
local SFS = drawMgr:CreateText(x*monitor,y*monitor+15,-1,"Fountain Safe Mode: ''"..string.char(config.FountainSafe).."'' Status: ON",F14) SFM.visible = false

-- My Tests, not pay attention.
function IsRecentlyCasted(spell,cooldown)
	if spell.cd > cooldown-3 then
		return true
	else
		return false
	end
	--if spell.state == LuaEntityAbility.STATE_COOLDOWN and spell.cd > cooldown-3 then
	--	return true
	--end
end

function EnemyFountainSafeCombo(vic,config,mode)
	local me = entityList:GetMyHero()
	local eList = entityList:FindEntities({classId=CDOTA_Unit_Fountain})
	for i,v in ipairs(eList) do
		if v.team ~= me.team then
			enemyFountain = v
		end
	end
	if config == nil or config == true then
		local fountainAttackRange = 1200
		if mode == "back" then
			if GetDistance2D(me,enemyFountain) <= fountainAttackRange+250 then
				me:Move(Vector(-786.38,-1152.53,1061.75))
				if IsActionSafe == true then
					dangerRangeEffect = Effect(enemyFountain, "range_display")
					dangerRangeEffect:SetVector(1, Vector(1370, 0, 0))
					IsActionSafe = false
				end
			end
		end
	elseif config == false then
		return
	end
end

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
	
	if SFM.visible == false and me:GetAbility(2).level > 0 then SFM.visible = true end
	
	if enemyFountain and GetDistance2D(me,enemyFountain) >= 1500 then
		if dangerRangeEffect then
			dangerRangeEffect = nil
		end
		if IsActionSafe == false then
			me:Stop()
			IsActionSafe = true
		end
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
	
	if me.activity == LuaEntityNPC.ACTIVITY_MOVE and FastMove then
		local W = me:GetAbility(2)
		if W and W:CanBeCasted() and me:CanCast() then
			table.insert(castQueue,{1000,W})
		end
	end
	if IsKeyDown(config.Hotkey) and not client.chat then
		EnemyFountainSafeCombo(victim,SafeSwitch,"back")
	end
	if IsKeyDown(config.Hotkey) and not client.chat and IsActionSafe then	
		if Animations.CanMove(me) or not start or (victim and GetDistance2D(victim,me) > attackRange+50) then
			start = true
			local lowestHP = targetFind:GetLowestEHP(3000, phys)
			if lowestHP and (not victim or GetDistance2D(me,victim) > 600 or not victim.alive or lowestHP.health < victim.health) and SleepCheck("victim") then			
				victim = lowestHP
				Sleep(250,"victim")
			end
			if victim and GetDistance2D(victim,me) > attackRange+200 and victim.visible and victim.alive then
				local closest = targetFind:GetClosestToMouse(me,2000)
				if closest and (not victim or closest.handle ~= victim.handle) then 
					victim = closest
				end
			end
		end
		if not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 2000 then
			if tick > sleep[1] then
				if not Animations.isAttacking(me) then
					local rage = me:DoesHaveModifier("modifier_troll_warlord_berserkers_rage")
					local berserkers = me:FindSpell("troll_warlord_berserkers_rage")
					local shadowplay = me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk")
					Q = me:GetAbility(1)
					W = me:GetAbility(2)
					R = me:GetAbility(4)
					local IsShukuchiVisible
					local IsTower = entityList:GetEntities(function (v) return v.classId==CDOTA_BaseNPC_Tower and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 850 end)
					if (me:DoesHaveModifier("modifier_weaver_shukuchi") and me.visibleToEnemy and #IsTower == 0) or not me:DoesHaveModifier("modifier_weaver_shukuchi") then
						IsShukuchiVisible = true
					else
						IsShukuchiVisible = false
					end
					local butterfly = me:FindItem("item_butterfly")
					local mom = me:FindItem("item_mask_of_madness")
					local moc = me:FindItem("item_medallion_of_courage")
					local halberd = me:FindItem("item_heavens_halberd")
					local blink = me:FindItem("item_blink")
					local orchid = me:FindItem("item_orchid")
					local shiva = me:FindItem("item_shivas_guard")
					local sheep = me:FindItem("item_sheepstick")
					local refresher = me:FindItem("item_refresher")
					--local lotusOrb = me:FindItem("item_lotus_orb") -- For this we have Counter Skills Script.
					local satanic = me:FindItem("item_satanic")
					local BlackKingBar = me:FindItem("item_black_king_bar")
					local distance = GetDistance2D(victim,me)
					if not shadowplay and victim.alive and victim.visible then
						if blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange+150 and not W:CanBeCasted() then
							local CP = blink:FindCastPoint()
							local delay = ((500-Animations.getDuration(blink)*1000)+CP*1000+client.latency+me:GetTurnTime(victim)*1000)
							local speed = blink:GetSpecialData("blink_range")
							local xyz = SkillShot.SkillShotXYZ(me,victim,0,speed)
							if xyz then
								table.insert(castQueue,{math.ceil(blink:FindCastPoint()*1000),blink,xyz})
							end
						end
						if Q and Q:CanBeCasted() and me:CanCast() and distance <= 1200 and not Q.abilityPhase and IsShukuchiVisible then
							local CP = Q:FindCastPoint()
							local delay = (500+CP*1000+client.latency+me:GetTurnTime(victim)*1000)
							local speed = 1200
							local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
							if xyz then
								table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,xyz})
								Sleep(1000)
							end
						end
						if W and W:CanBeCasted() and me:CanCast() and distance >= me.attackRange and not Q.abilityPhase then
							table.insert(castQueue,{100,W})
						end
						if W and IsRecentlyCasted(W,ShukuchiC[W.level]) ~= nil and IsRecentlyCasted(W,ShukuchiC[W.level]) then
							for i=1, 10, 1 do
							if victim.visible then
								local xyz = SkillShot.PredictedXYZ(victim,me:GetTurnTime(victim)*1000+client.latency+500)
								if victim.recentDamage == ShukuchiDmg[W.level] then
									me:Attack(victim)
									Sleep(200,"Attack")
									for i=1, 3, 1 do
									if Animations.isAttacking(victim) then
										i = i-1
										Sleep(200)
									end
									end
								end
								me:Move(xyz)
							else
								me:Follow(victim)
							end
							if not me:DoesHaveModifier("modifier_weaver_shukuchi") then
								break
							end
							i = i-1
							end
						end
						if me.health/me.maxHealth <= 0.4 and IsShukuchiVisible then
							if satanic and satanic:CanBeCasted() then
								table.insert(castQueue,{100,satanic})
							elseif R and R:CanBeCasted() and me:CanCast() and not me:DoesHaveModifier("modifier_item_satanic") then
								table.insert(castQueue,{100,R})
							end
						end
						if shiva and shiva:CanBeCasted() and distance <= 600 and not victim:DoesHaveModifier("modifier_sheepstick_debuff") and IsShukuchiVisible then
							table.insert(castQueue,{100,shiva})
						end
						if sheep and sheep:CanBeCasted() and me:CanCast() and IsShukuchiVisible then
							table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*1000),sheep,victim})
						end
						if orchid and orchid:CanBeCasted() and me:CanCast() and not victim:DoesHaveModifier("modifier_sheepstick_debuff") and IsShukuchiVisible then
							table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,victim})
						end
						if halberd and halberd:CanBeCasted() and distance < halberd.castRange and not victim:IsStunned() and not victim:DoesHaveModifier("modifier_sheepstick_debuff") and IsShukuchiVisible then
							table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,victim})
						end
						if butterfly and butterfly:CanBeCasted() and IsShukuchiVisible then
							table.insert(castQueue,{100,butterfly})
						end
						if moc and moc:CanBeCasted() and distance < moc.castRange and IsShukuchiVisible then
							table.insert(castQueue,{1000+math.ceil(moc:FindCastPoint()*1000),moc,victim})
						end
						if mom and mom:CanBeCasted() and distance <= attackRange+200 and IsShukuchiVisible then
							table.insert(castQueue,{100,mom})
						end
						if soulring and soulring:CanBeCasted() and IsShukuchiVisible and (not me.mana >= W.manacost or not me.mana >= R.manacost or (not me.mana >= Q.manacost and victim.health/victim.maxHealth <= 0.2)) then
							table.insert(castQueue,{100,soulring})
						end
						-- SoulRing + Refresher combo
						if refresher and refresher:CanBeCasted() and me.mana < 375 and me.mana > 225 and soulring and soulring:CanBeCasted() and IsShukuchiVisible then
							table.insert(castQueue,{100,soulring})
						end
						if refresher and refresher:CanBeCasted() and R and R.cd > 15 and R.state == LuaEntityAbility.STATE_COOLDOWN and IsShukuchiVisible then
							table.insert(castQueue,{100,refresher})
						end
						-- S+R end
						
						-- For this we have Counter Skills Script.
						--if lotusOrb and lotusOrb:CanBeCasted() then
						--	local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
						--	if #heroes >= 2 and #heroes <= 5 then
						--		table.insert(castQueue,{1000+math.ceil(lotusOrb:FindCastPoint()*1000),lotusOrb,me})
						--	end
						--end
						if BlackKingBar and BlackKingBar:CanBeCasted() then
							local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
							if config.SmartBKB then
								if #heroes >= config.minEnemiesToSmartBKB and #heroes <= 5 then
									table.insert(castQueue,{100,BlackKingBar})
								end
							else
									table.insert(castQueue,{100,BlackKingBar})
							end
						end
					end
				end
				local xyz = SkillShot.PredictedXYZ(victim,me:GetTurnTime(victim)*1000+client.latency+500)
				local CanAttack = false
				if not me:DoesHaveModifier("modifier_weaver_shukuchi") then
					CanAttack = true
				elseif me:DoesHaveModifier("modifier_weaver_shukuchi") and GetDistance2D(victim,me) < 175 then
					CanAttack = true
				end
				if CanAttack then
					me:Attack(victim)
				end
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
		if me.classId ~= CDOTA_Unit_Hero_Weaver then 
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
			SFS.visible = true
			script:RegisterEvent(EVENT_FRAME, Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end	
end

function Key(msg,code)
	if msg ~= KEY_UP and code == config.FastMove and not client.chat then
		if not FastMove then
			FastMove = true
			SFM.text = "Fast Move: ''"..string.char(config.FastMove).."'' Status: ON"
		else
			FastMove = false
			SFM.text = "Fast Move: ''"..string.char(config.FastMove).."'' Status: OFF"
		end
	end
	if msg ~= KEY_UP and code == config.Hotkey and not client.chat and victim and GetDistance2D(entityList:GetMyHero(),victim) <= 2000 then
		if FastMove then
			FastMove = false
			SFM.text = "Fast Move: ''"..string.char(config.FastMove).."'' Status: OFF"
		end
	end
	if msg ~= KEY_UP and code == config.FountainSafe and not client.chat then
		if SafeSwitch then
			SafeSwitch = false
			SFS.text = "Fountain Safe Mode: ''"..string.char(config.FountainSafe).."'' Status: OFF"
			SFS.color = 0xFF0000FF
		else
			SafeSwitch = true
			SFS.text = "Fountain Safe Mode: ''"..string.char(config.FountainSafe).."'' Status: ON"
			SFS.color = 0xFFFFFFFF
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
	SFM.visible = false
	SFS.visible = false
	FastMove = false
	IsActionSafe = true
	dangerRangeEffect = nil
	enemyFountain = nil
	SafeSwitch = true
	if play then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
