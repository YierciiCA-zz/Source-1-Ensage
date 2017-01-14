--<<mb work or not. no matter. d.l.>>

--randomly found an old script, maybe someone will be useful
--screen http://imgur.com/GZPbl5G,RIyiEvZ,5gpiyzg#0

-- how to use:
-- 1)Download texture https://mega.co.nz/#!8AZiFAbY!kMdEz0Fezz6cRzpVPrsNJTuUd4RFwHqDSI3cOV51U34 and unpack to nyanui/other
-- 2)Change config for u (autoattack and autottack after spell set like in dota 2)
-- 3)You need to click on icon with swords
-- 4)Then click on the skill/item is and move it into the correct slot
-- 5)If you want to delete, click on the right mouse button on the skill/item in sequence
-- 6)Select Target (me, enemy), the same like 
-- 7)If such a combo with eulom, you can put a delay for example 1.6 seconds (also by pressing the left button for reset click on the arrow)
--Combo key - (T)

require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Combo", "T", config.TYPE_HOTKEY)
config:SetParameter("AutoAttack", false)
config:SetParameter("AttackAfterSpell", true)
config:SetParameter("ComboState", true)
config:Load()

local rate = client.screenSize.x/1600

local spells = {} local combo = {} local all = {} local rec = {}

rec[1] = drawMgr:CreateRect(18*rate,42*rate,490*rate,222*rate,0x00000090,drawMgr:GetTextureId("NyanUI/other/CM_def")) rec[1].visible = false
rec[2] = drawMgr:CreateRect(167*rate,6*rate,25*rate,24*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_buttom")) rec[2].visible = false
rec[3] = drawMgr:CreateText(205*rate,67*rate,0xFFFFFFFF,"Combo Maker",drawMgr:CreateFont("manabarsFont","Arial",18*rate,700)) rec[3].visible = false
rec[4] = drawMgr:CreateRect(156*rate,26*rate,270*rate,60*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_status_1")) rec[4].visible = false
rec[5] = drawMgr:CreateText(175*rate,52*rate,0xFFFFFF90,"State:",drawMgr:CreateFont("manabarsFont","Arial",18*rate,700)) rec[5].visible = false
rec[6] = drawMgr:CreateText(175*rate,52*rate,0xFFFFFF90,"Hero:",drawMgr:CreateFont("manabarsFont","Arial",18*rate,700)) rec[6].visible = false
rec[7] = drawMgr:CreateRect(220*rate,54*rate,16*rate,16*rate,0xFFFFFF30) rec[7].visible = false
local icon = drawMgr:CreateRect(0,0,0,32*rate,0x000000ff) icon.visible = false
local Combo = config.Combo
local AutoAttack = config.AutoAttack
local AttackAfterSpell = config.AttackAfterSpell
local ComboState = config.AttackAfterSpell
local activated = false local activatedC = false local enemy = nil local count = 0

function Tick(tick)

	if client.console or not SleepCheck() then return end	
	
	Sleep(100)

	local me = entityList:GetMyHero()	
	if not me then return end
	
	if not activatedC then
		enemy = FindTarget(me.team)
	end

	rec[2].visible = true

	--no
	if activated then
	
		if rec[4].visible then
			rec[4].visible = false
			rec[5].visible = false
			rec[6].visible = false
			rec[7].visible = false
			for a = 1, 6 do
				if combo[a].bgret.visible then
					combo[a].bgret.visible = false
					combo[a].bgimg.visible = false
					combo[a].bgtext.visible = false
					combo[a].bg.visible = false
				end
			end
		end
		
		all = {}
		
		for a,v in ipairs(me.abilities) do
			if v.abilityType ~= LuaEntityAbility.TYPE_ATTRIBUTES and v.abilityData.behavior ~= LuaEntityAbility.BEHAVIOR_PASSIVE then 
				table.insert(all,v)
			end
		end
		for a,v in ipairs(me.items) do
			if not v.recipe and v.abilityData.behavior ~= LuaEntityAbility.BEHAVIOR_PASSIVE then
				table.insert(all,v)
			end
		end
		
		if one then
			if one.item then		
				icon.textureId = drawMgr:GetTextureId("NyanUI/items/"..one.name:gsub("item_",""))
				icon.w = 44
			else				
				icon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..one.name)
				icon.w = 32			
			end
			icon.x,icon.y = client.mouseScreenPosition.x-15,client.mouseScreenPosition.y - 15
			icon.visible = true		
		elseif icon.visible then
			icon.visible = false
		end	
			
		--no	
		if not loads then
			for a = 1,10 do
				if not spells[a] then spells[a] = {} end		
				if not spells[a].img then
					spells[a].img = drawMgr:CreateRect(0,0,32*rate,32*rate,0x000000FF) spells[a].img.visible = false
					spells[a].rect = drawMgr:CreateRect(0,0,34*rate,34*rate,0x000000FF,true) spells[a].rect.visible = false

				end
			end
			for a = 1, 6 do
				if not combo[a] then combo[a] = {} end
				if not combo[a].img then
					combo[a].inbg = drawMgr:CreateRect(-4*rate+70*a*rate,188*rate,36*rate,36*rate,0xFFFFFF02) combo[a].inbg.visible = false
					combo[a].rect = drawMgr:CreateRect(-4*rate+70*a*rate,188*rate,36*rate,36*rate,0xFFFFFF30,true) combo[a].rect.visible = false
					combo[a].img = drawMgr:CreateRect(-2*rate+70*a*rate,190*rate,32*rate,32*rate,0xFFFFFF30,true) combo[a].img.visible = false								
					combo[a].arrow = drawMgr:CreateRect(33*rate+70*a*rate,200*rate,36*rate,18*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/arrow_usual_left")) combo[a].arrow.visible = false					
					combo[a].sleep = 0.1
					combo[a].sleepText = drawMgr:CreateText(35*rate+70*a*rate,188*rate,0xFFFFFFFF,"",drawMgr:CreateFont("manabarsFont","Arial",14*rate,500)) combo[a].sleepText.visible = false
					combo[a].target = drawMgr:CreateText(-3+70*a*rate,225*rate,0xFFFFFFFF,"",drawMgr:CreateFont("manabarsFont","Arial",14*rate,500)) combo[a].target.visible = false
					if ComboState then
						combo[a].bgimg = drawMgr:CreateRect(205*rate+28*a*rate,49*rate,24*rate,24*rate,0xFFFFFF30) combo[a].bgimg.visible = false
						combo[a].bgret = drawMgr:CreateRect(204*rate+28*a*rate,48*rate,26*rate,26*rate,0xFFFFFF30,true) combo[a].bgret.visible = false
						combo[a].bg = drawMgr:CreateRect(205*rate+28*a*rate,49*rate,24*rate,24*rate,0xA1A4A150) combo[a].bg.visible = false
						combo[a].bgtext = drawMgr:CreateText(210*rate+28*a*rate,54*rate,0xFFFFFFFF,"",drawMgr:CreateFont("manabarsFont","Arial",14*rate,500)) combo[a].bgtext.visible = false
					end
				end
			end
			loads = true
		else 
			rec[1].visible = true 
			rec[3].visible = true
			
			for a = 1,10 do
				spells[a].img.x,spells[a].img.y = (-5+#all*4+38*a*(10/#all))*rate,110*rate
				spells[a].rect.x,spells[a].rect.y = (-4+#all*4+38*a*(10/#all)-2)*rate,109*rate
				local v = all[a]
				if v then			
					if v.item then
						spells[a].img.textureId = drawMgr:GetTextureId("NyanUI/items/"..v.name:gsub("item_",""))
						spells[a].img.w = 44*rate
					else
						spells[a].img.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..v.name)
						spells[a].img.w = 32*rate
					end
					spells[a].img.visible,spells[a].rect.visible = true,true
				elseif spells[a].img and spells[a].img.visible then
					spells[a].img.visible,spells[a].rect.visible = false,false
				end
			end

			for a = 1, 6 do
			
				combo[a].rect.visible = true
				combo[a].inbg.visible = true

				if combo[a].spell and entityList:GetEntity(combo[a].spell.handle)~= nil then
					if combo[a].spell.item then
						combo[a].img.textureId = drawMgr:GetTextureId("NyanUI/items/"..combo[a].spell.name:gsub("item_",""))				
						combo[a].img.w = 44*rate					
					else				
						combo[a].img.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..combo[a].spell.name)
						combo[a].img.w = 32*rate
					end		
					
					if combo[a].spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
						combo[a].cast = nil
						if combo[a].target then
							combo[a].target.visible = false
						end
					elseif combo[a].spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) then				
						if not combo[a].cast or not combo[a].cast.hero then
							if enemy then
								combo[a].cast = enemy
							else
								combo[a].cast = me
							end
						end
						if combo[a].spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not combo[a].spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
							combo[a].cast = me
						end	
						combo[a].target.text = Who(combo[a].cast,me)
						combo[a].target.visible = true
					elseif combo[a].spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or combo[a].spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
						if not combo[a].cast or not combo[a].cast.hero then
							if enemy then
								combo[a].cast = enemy
							else
								combo[a].cast = me
							end
						end
						if combo[a].spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not combo[a].spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
							combo[a].cast = me
						end	
						combo[a].target.text = Who(combo[a].cast,me)
						combo[a].target.visible = true
					end	
					
					combo[a].img.visible = true
					combo[a].sleepText.visible = true

					if a < 6 then
						combo[a].arrow.visible = true
						combo[a].sleepText.visible = true
						combo[a].sleepText.text = "  "..combo[a].sleep
					end						
					
				end
					
				
			end	
			
		end
	else
		if rec[1].visible then
			rec[1].visible = false 
			rec[3].visible = false
			for a = 1,10 do
				spells[a].img.visible = false
				spells[a].rect.visible = false
			end
			for a = 1, 6 do
				combo[a].inbg.visible = false
				combo[a].rect.visible = false
				combo[a].img.visible = false
				combo[a].arrow.visible = false
				combo[a].sleepText.visible = false
				combo[a].target.visible = false
			end
		end
		if loads and ComboState then
			local countt = 0				
			for a = 1, 6 do
				local Spell = combo[a].spell
				if Spell then
					countt = countt+1
					combo[a].bgret.visible = true
					if Spell.item then
						combo[a].bgimg.textureId = drawMgr:GetTextureId("NyanUI/items/"..Spell.name:gsub("item_",""))
						combo[a].bgimg.w = 34*rate
					else					
						combo[a].bgimg.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..Spell.name)
						combo[a].bgimg.w = 24*rate
					end
					combo[a].bgret.visible = true
					combo[a].bgimg.visible = true
					if Spell.state == LuaEntityAbility.STATE_NOTLEARNED then
						combo[a].bg.visible = true
					elseif Spell.state == LuaEntityAbility.STATE_READY then
						combo[a].bg.visible = false		
						combo[a].bgtext.visible = false
					elseif Spell.cd > 0 then
						local cooldown = math.ceil(Spell.cd)
						combo[a].bgtext.text = ""..cooldown
						combo[a].bgtext.color = 0xFFFFFFFF
						combo[a].bgtext.visible = true
						combo[a].bg.visible = true
					elseif Spell.state == LuaEntityAbility.STATE_NOMANA then
						local ManaCost = math.floor(math.ceil(Spell.manacost) - me.mana)
						combo[a].bgtext.text = ""..ManaCost
						combo[a].bgtext.color = 0xBBA9EEff
						combo[a].bgtext.visible = true
						combo[a].bg.visible = true
					end
				else
					if combo[a].bgret.visible then
						combo[a].bgret.visible = false
						combo[a].bgimg.visible = false
						combo[a].bgtext.visible = false
						combo[a].bg.visible = false
					end
				end
			end	
			local numb = 90*rate+30*countt*rate+65*rate
			rec[4].w = numb
			rec[6].x = 175*rate + numb - 95*rate
			rec[7].x = 175*rate + numb - 50*rate
			rec[7].textureId = drawMgr:GetTextureId("NyanUI/miniheroes/"..enemy.name:gsub("npc_dota_hero_",""))
			
			for z = 4,7 do
				rec[z].visible = true
			end
			
		end
	end
			
	--yes
	if loads then
		if times and tick < times then return end
		times = nil
		if SleepCheck("123") then
			if activatedC then				
				for a = 1, 6 do
					local qu = nil					
					if a == 1 then Console(1) qu = false else qu = true end
					local v = combo[a].spell
					if v then						
						if not combo[a].sleepCheck then
							if combo[a].cast and combo[a].cast.hero and combo[a].cast.team ~= me.team then
								if combo[a].cast.health == 0 then
									activatedC = false for z = 1,6 do combo[z].sleepCheck = nil end
									Console(0) times = tick + 1000
									break 
								end
								combo[a].cast = enemy								
							end
							combo[a].sleepCheck = true	
							if v:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or (v:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) and not v:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET)) then
								me:SafeCastAbility(v,combo[a].cast.position,qu)
							elseif v:IsBehaviourType(LuaEntityAbility.BEHAVIOR_TOGGLE) then
								entityList:GetMyPlayer():ToggleAbility(v,qu)
							else
								me:CastAbility(v,combo[a].cast,qu)
							end
							if combo[a].sleep and combo[a].sleep > 0.1 then
								if combo[a].cast and combo[a].cast.position then
									Sleep(combo[a].sleep*1000 - client.latency+TurnRate(combo[a].cast.position,me),"123")
								else
									Sleep(combo[a].sleep*1000 - client.latency,"123")
								end
							end
							break
						end
					end	
					if a == 6 then
						Console(0)
						times = tick + 1000
						activatedC = false for z = 1,6 do combo[z].sleepCheck = nil end
					end
				end				
			end
		end	
	end
 
	
end

function Key(msg,code)	

	if client.chat or not rec[2].visible then return end

	local me = entityList:GetMyHero()
		
	--show menu
	if msg == LBUTTON_DOWN then
		if IsMouseOnButton(167*rate,6*rate,25*rate,25*rate) then
			activated = not activated
			return true
		end
	end
	
	--activate combo
	if msg ~= KEY_UP and code == Combo then
		activatedC = not activatedC		
		return true		
	end
	
	--config stuff
	if activated then
		if msg == LBUTTON_DOWN then
			--select ability
			for a = 1, #all do
				if IsMouseOnButton((-5+#all*4+38*a*(10/#all))*rate,110*rate,32*rate,32*rate) then
					one = all[a]
					return true
				end
			end
			--change sleep/target
			for a = 1, 6 do
				if IsMouseOnButton(70*a*rate,225*rate,20*rate,20*rate) then
					if combo[a].cast then
						if combo[a].cast.hero then
							if combo[a].cast == me then
								combo[a].cast = enemy
								return true
							elseif combo[a].cast ~= me then
								combo[a].cast = me
								return true
							end
						end
					end
				elseif IsMouseOnButton(35*rate+70*a*rate,188*rate,12*rate,14*rate) then
					if combo[a].sleep > 9.9 then
						combo[a].sleep = 0
					else					
						combo[a].sleep = combo[a].sleep + 1
					end
					return true
				elseif IsMouseOnButton(35*rate+70*a*rate+12*rate,188*rate,12*rate,14*rate) then
					if combo[a].sleep > 9.9 then
						combo[a].sleep = 0
					else					
						combo[a].sleep = combo[a].sleep + 0.1
					end
					return true
				elseif IsMouseOnButton(33*rate+70*a*rate,200*rate,36*rate,18*rate) then
					combo[a].sleep = 0.10
				end
			end			
		--add ability
		elseif msg == LBUTTON_UP and one then
			for a = 1, 6 do
				if IsMouseOnButton(70*a*rate,190*rate,32*rate,32*rate) then
					combo[a].spell = one
					one = nil
					return true
				end
			end
		--remove ability
		elseif msg == RBUTTON_UP then
			for a = 1, 6 do
				if IsMouseOnButton(70*a*rate,190*rate,32*rate,32*rate) then
					if combo[a].target then
						combo[a].target.visible = false
					end
					combo[a].cast = nil
					combo[a].img.visible = false			
					combo[a].spell = nil
					combo[a].sleep = 0.1
					combo[a].sleepText.visible = false
					combo[a].arrow.visible = false
					me:Stop()
					return true
				end
			end		
		--remove one
		elseif one then
			one = nil	
		end	
	end
	
end

function Who(ent,me)
	if ent.handle == me.handle then
		return "  me"
	else
		return "enemy"
	end
end

function Console(n)
	if n == 1 then
		if AttackAfterSpell then
			client:ExecuteCmd("dota_player_units_auto_attack_after_spell 0")
		end
		if AutoAttack then
			client:ExecuteCmd("dota_player_units_auto_attack 0")
		end
	else
		if AttackAfterSpell then
			client:ExecuteCmd("dota_player_units_auto_attack_after_spell 1")
		end
		if AutoAttack then
			client:ExecuteCmd("dota_player_units_auto_attack 1")
		end
	end
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

function TurnRate(pos,me)
	local angel = ((((math.atan2(pos.y-me.position.y,pos.x-me.position.x) - me.rotR + math.pi) % (2 * math.pi)) - math.pi) % (2 * math.pi)) * 180 / math.pi
	if angel > 180 then 
		return ((360 - angel))
	else
		return (angel)
	end
end

function FindTarget(teams)
	local enemy = entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_HERO and v.team ~= teams and v.visible and v.alive and not v.illusion end)
	if #enemy == 0 then
		return entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_HERO and v.team ~= teams end)[1]
	elseif #enemy == 1 then
		return enemy[1]	
	else
		local mouse = client.mousePosition
		table.sort( enemy, function (a,b) return GetDistance2D(mouse,a) < GetDistance2D(mouse,b) end)
		return enemy[1]
	end
end

function Load()
	if PlayingGame() then		
		script:RegisterEvent(EVENT_TICK,Tick)
		script:RegisterEvent(EVENT_KEY,Key)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	if play then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
	for i = 1, #rec do
		rec[i].visible = false
	end
	enemy = nil
	activated = false activatedC = false loads = false icon.visible = false
	spells = {} combo = {} all = {}
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
