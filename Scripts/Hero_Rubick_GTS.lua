--<<rrrrrrrrrubick. d.l.>>

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.SideMessage")

local config = ScriptConfig.new()
config:SetParameter("ShowLastSpell", true)
config:SetParameter("EverySpells", true)
config:SetParameter("XX", 20)
config:SetParameter("YY", 0)
config:Load()

local main = {} local icon = {} local spell = {} local steelSpells = {}
main.lastSpell = {} main.draw = {} main.togl = {} main.sleep = {} main.phase = {} main.rec = {} main.target = {} main.count = 0

local ShowLastSpell = config.ShowLastSpell
local EverySpells = config.EverySpells
local xx = config.XX
local yy = config.YY
local rate = client.screenSize.x/1600
local xxx,yyy = -90*rate,-28*rate
local move = true
local CanSteal = {"lone_druid_true_form_battle_cry","keeper_of_the_light_recall","keeper_of_the_light_blinding_light","troll_warlord_whirling_axes_melee","shredder_chakram_2","earth_spirit_petrify","treant_eyes_in_the_forest","ogre_magi_unrefined_fireblast"}

main.rec[1] = drawMgr:CreateRect(xx+168*rate,yy+8*rate,18*rate,18*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/miniheroes/rubick")) main.rec[1].visible = false
main.rec[2] = drawMgr:CreateRect(xx+18*rate,yy+42*rate,350*rate,222*rate,0x00000090,drawMgr:GetTextureId("NyanUI/other/CM_def")) main.rec[2].visible = false
main.rec[3] = drawMgr:CreateRect(xx+156*rate,yy+20*rate,270*rate,85*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_status_1")) main.rec[3].visible = false
main.rec[4] = drawMgr:CreateRect(xx+175*rate,yy+80*rate,15*rate,15*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_space")) main.rec[4].visible = false
main.rec[5] = drawMgr:CreateText(xx+196*rate,yy+80*rate,0xFFFFFFff,"Disable",drawMgr:CreateFont("manabarsFont","Arial",14*rate,500)) main.rec[5].visible = false

local play = false

function Tick( tick )

	if client.console then return end	

	local me = entityList:GetMyHero()	

	if not me then return end
	main.rec[1].visible = true
	
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,illusion = false,team = (5-me.team)})

	local steal = me:GetAbility(7)
	local stealing = me:GetAbility(5)
	local cast = not me:IsChanneling() and steal:CanBeCasted() and me:CanCast() and not steal.abilityPhase and move
	
	if not move then
		main.rec[4].textureId = drawMgr:GetTextureId("NyanUI/other/CM_space_light")
	else
		main.rec[4].textureId = drawMgr:GetTextureId("NyanUI/other/CM_space")
	end

	for i, v in ipairs(enemies) do
		
		local ability = v.abilities
		local Id = GetPlayerId(v.playerId)

		if main.draw[Id] then
			if v.alive and v.health > 0 then
				if v.visible then
					if not icon[Id].ol.visible then
						icon[Id].ol.visible = ShowLastSpell
						icon[Id].bg.visible = ShowLastSpell
					end
					main.sleep[Id] = nil
					--track all spells 
					if v.classId == CDOTA_Unit_Hero_LoneDruid then
						for a,s in ipairs(v.modifiers) do
							if s.name == "modifier_lone_druid_druid_form_transform" or s.name == "modifier_lone_druid_true_form_transform" then
								main.lastSpell[Id] = "lone_druid_true_form"
							end
						end
					end
					for g,spell in ipairs(ability) do						
						if spell.level ~= 0 then
							if not (spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_ATTACK) or spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE)) then
								if not spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_TOGGLE) then	
									local cd = spell:GetCooldown(spell.level)									
									if cd > 1 then
										if spell.abilityType ~= LuaEntityAbility.TYPE_ULTIMATE then
											if spell.cd > 0 then
												if math.ceil(spell.cd*10) ==  math.ceil(cd*10) then								
													main.lastSpell[Id] = spell.name
												end
											end
										elseif spell.name == "brewmaster_primal_split" then
											if spell.cd > 0 then
												local fullcd = {125,103,80}
												if math.ceil(spell.cd*10) ==  math.ceil(fullcd[spell.level]*10) then								
													main.lastSpell[Id] = spell.name
												end
											end
										elseif spell.name == "phoenix_supernova" then
											if spell.cd > 0 then
												if math.ceil(spell.cd*10) == 1040 then
													main.lastSpell[Id] = spell.name
												end
											end										
										elseif spell.name ~= "invoker_invoke" then
											if spell.cd > 0 then
												if math.ceil(spell.cd*10) ==  math.ceil(cd*10) then								
													main.lastSpell[Id] = spell.name
												end
											end
										end											
									elseif cd == 0 and not spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NOT_LEARNABLE) then
										if spell.abilityPhase then
											if not main.phase[Id] then
												main.phase[Id] = tick + spell:FindCastPoint()*700
											elseif tick > main.phase[Id] then
												main.phase[Id] = nil												
												main.lastSpell[Id] = spell.name
											end													
										else
											main.phase[Id] = nil
										end
									end
								elseif not (spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_HIDDEN) or spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NOT_LEARNABLE)) then
									if spell.toggled then
										if not main.togl[spell.name] then
											main.lastSpell[Id] = spell.name
											main.togl[spell.name] = true
										end
									elseif main.togl[spell.name] then
										main.togl[spell.name] = nil
									end									
								end
							end
						end
					end
					--stop me
					if main.target[Id] ~= nil and main.lastSpell[Id] ~= main.target[Id] then
						me:Stop()
						main.target[Id] = nil
					end
					
					--steals function
					if main.lastSpell[Id] then
						icon[Id].ol.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..main.lastSpell[Id])
						if SleepCheck() then
							if cast and not v:IsLinkensProtected() and GetDistance2D(v,me) < steal.castRange and not v:IsInvul() then
								for g,spell in ipairs(icon[Id].steelSpells) do
									if main.lastSpell[Id] == spell and spell ~= stealing.name then
										local ulti = GetUlti(spell,ability)
										if ulti then
											if stealing.abilityType == LuaEntityAbility.TYPE_ULTIMATE then
												if stealing.cd ~= 0 then
													entityList:GetMyPlayer():Select(me)
													entityList:GetMyPlayer():UseAbility(steal,v)
													if main.target[Id] == nil then
														main.target[Id] = spell														
														GenerateSideMessage(v.name:gsub("npc_dota_hero_",""),main.lastSpell[Id])
													end
													Sleep(100)
													break
												end
											else
												entityList:GetMyPlayer():Select(me)
												entityList:GetMyPlayer():UseAbility(steal,v)
												if main.target[Id] == nil then													
													main.target[Id] = spell
													GenerateSideMessage(v.name:gsub("npc_dota_hero_",""),main.lastSpell[Id])
												end
												Sleep(100)
												break	
											end
										elseif stealing.abilityType ~= LuaEntityAbility.TYPE_ULTIMATE then
											entityList:GetMyPlayer():Select(me)
											entityList:GetMyPlayer():UseAbility(steal,v)
											if main.target[Id] == nil then
												main.target[Id] = spell
												GenerateSideMessage(v.name:gsub("npc_dota_hero_",""),main.lastSpell[Id])
											end
											Sleep(100)
											break	
										end
									end
								end
							elseif main.target[Id] and not steal.abilityPhase then
								main.target[Id] = nil
							end
						end
					else
						icon[Id].ol.textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
					end

				else
					
					if icon[Id].ol.visible then
						icon[Id].ol.visible = false
						icon[Id].bg.visible = false
					end
					
					if main.lastSpell[Id] then
						--erase if not visible
						if not main.sleep[Id] then
							main.sleep[Id] = tick + 500
						elseif main.sleep[Id] < tick then
							main.lastSpell[Id] = nil
						end
					end

				end

			elseif icon[Id].ol.visible then
				icon[Id].ol.visible = false
				icon[Id].bg.visible = false				
			end
		end

		--draw function(ones)
		if not main.draw[Id] and v.healthbarOffset ~= -1 then
			if v.classId == CDOTA_Unit_Hero_Invoker then
				main.rec[2].w = 490*rate
			end
			if not icon[Id] then icon[Id] = {}
				if not icon[Id].spell then icon[Id].spell = {} end
				if not icon[Id].steelSpells then icon[Id].steelSpells = {} end
				icon[Id].mini = drawMgr:CreateRect(xx+50*rate,yy+28*rate+Id*35*rate,28*rate,35*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/heroes_vertical/"..v.name:gsub("npc_dota_hero_",""))) icon[Id].mini.visible = false
				icon[Id].ol = drawMgr:CreateRect(xxx+54*rate,yyy+81*rate,24*rate,24*rate,0x00000095,drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")) icon[Id].ol.entity = v icon[Id].ol.entityPosition = Vector(0,0,v.healthbarOffset) icon[Id].ol.visible = false
				icon[Id].bg = drawMgr:CreateRect(xxx+54*rate-1,yyy+81*rate-1,26*rate,26*rate,0x00000095,true) icon[Id].bg.entity = v icon[Id].bg.entityPosition = Vector(0,0,v.healthbarOffset) icon[Id].bg.visible = false
			end
			if #ability > 0 then
				local realSpells = {}
				local maximum = 0
				for k,l in ipairs(ability) do
					if l.abilityType ~= LuaEntityAbility.TYPE_ATTRIBUTES and l.name ~= "invoker_wex" and l.name ~= "invoker_exort" and l.name ~= "invoker_quas" and l.name ~= "invoker_invoke" then							
						if not (l:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE) or l:IsBehaviourType(LuaEntityAbility.BEHAVIOR_ATTACK) or ((l.hidden or l:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NOT_LEARNABLE)) and v.name ~= "npc_dota_hero_invoker")) then 
							realSpells[#realSpells + 1] = l
						end
						for a,s in ipairs(CanSteal) do
							if s == l.name then
								realSpells[#realSpells + 1] = l
							end
						end
					end
				end
				for a,sp in ipairs(realSpells) do
					if not spell[a] then spell[a] = {} end										
					if not icon[Id].spell[a] then icon[Id].spell[a] = {}							
						icon[Id].spell[a].img = drawMgr:CreateRect(xx+55*rate+a*40*rate,yy+30*rate+Id*35*rate,30*rate,30*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/translucent/"..sp.name.."_t25")) icon[Id].spell[a].img.visible = false						
						icon[Id].spell[a].rect = drawMgr:CreateRect(xx+55*rate+a*40*rate,yy+30*rate+Id*35*rate,30*rate+1,30*rate+1,0x000000FF,true) icon[Id].spell[a].rect.visible = false
						icon[Id].spell[a].bord = drawMgr:CreateRect(0,50*rate,yy+26*rate,26*rate,0x000000FF) icon[Id].spell[a].bord.visible = false
						icon[Id].spell[a].brect = drawMgr:CreateRect(0,49*rate,yy+26*rate+1,26*rate+1,0x000000FF,true) icon[Id].spell[a].brect.visible = false
						icon[Id].spell[a].name = sp.name
						icon[Id].spell[a].status = false						
						if sp.abilityType == LuaEntityAbility.TYPE_ULTIMATE then
							icon[Id].spell[a].status = true
							icon[Id].steelSpells[#icon[Id].steelSpells+1] = sp.name	
							icon[Id].spell[a].img.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..sp.name)
						end
					end
				end
				for a,sp in ipairs(icon[Id].steelSpells) do
					main.count = main.count + 1
					icon[Id].spell[a].bord.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..sp)
					icon[Id].spell[a].bord.x = xx+145*rate+30*rate*main.count
					icon[Id].spell[a].brect.x = xx+145*rate+30*rate*main.count-1
					icon[Id].spell[a].bord.visible = true
					icon[Id].spell[a].brect.visible = true
				end
				if main.count < 2 then
					main.rec[3].w = 100
				else
					main.rec[3].w = 35*rate+main.count*30*rate
				end
				main.rec[3].visible = true
				main.rec[4].visible = true
				main.rec[5].visible = true
				main.draw[Id] = true
			end
		end

		
	end	
	
	--show spell before get it
	--[[if EverySpells and math.ceil(steal.cd*10) ==  math.ceil(steal:GetCooldown(steal.level)*10) then
		for i,v in ipairs(entityList:GetProjectiles({})) do
			if v.target.classId == me.classId and v.speed == 900 then --  v.name is broken :(
				local ls = main.lastSpell[GetPlayerId(v.source.playerId)]
				if ls then
					GenerateSideMessage(v.source.name:gsub("npc_dota_hero_",""),main.lastSpell[GetPlayerId(v.source.playerId)])
				end
			end
		end
	end]]
	
	--interface control
	if activated then
	
		if not main.rec[2].visible then
			main.rec[2].visible = true
			main.rec[3].visible = false
			main.rec[4].visible = false
			main.rec[5].visible = false
			for i = 1,5 do					
				if main.draw[i] then
					icon[i].mini.visible = true
					for a = 1, 10 do
						if icon[i].spell[a] and not icon[i].spell[a].img.visible then
							icon[i].spell[a].img.visible = true
							icon[i].spell[a].rect.visible = true
						end
					end
					for a,s in ipairs(icon[i].steelSpells) do
						icon[i].spell[a].bord.visible = false
						icon[i].spell[a].brect.visible = false
					end
				end
			end
		end
		
	elseif main.rec[2].visible then
	
		main.rec[2].visible = false	
		main.rec[4].visible = true
		main.rec[5].visible = true
		for i = 1,5 do
			if main.draw[i] then
				icon[i].mini.visible = false
				for a = 1, 10 do
					if icon[i].spell[a] and icon[i].spell[a].img.visible then
						icon[i].spell[a].img.visible = false
						icon[i].spell[a].rect.visible = false
					end
				end					
			end
		end	
		local shift = 0
		for i = 1,5 do
			if icon[i] then
				for a,s in ipairs(icon[i].steelSpells) do
					if not icon[i].spell[a].brect.visible then
						shift = shift + 1
						icon[i].spell[a].bord.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..s)
						icon[i].spell[a].bord.x = xx+145*rate+30*rate*shift
						icon[i].spell[a].brect.x = xx+145*rate+30*rate*shift-1
						icon[i].spell[a].bord.visible = true
						icon[i].spell[a].brect.visible = true
					end
				end
			end
		end
		if shift < 2 then
			main.rec[3].w = 100
		else
			main.rec[3].w = 35*rate+shift*30*rate
		end
		main.rec[3].visible = true
		
	end
		
		
end

function Key(msg,code)

	if client.chat then return end
	
	if msg == LBUTTON_DOWN then
		if IsMouseOnButton(xx+168*rate,yy+8*rate,18*rate,18*rate) then
			activated = not activated
			return true
		end			
		if activated then			
			for i = 1,5 do
				if icon[i] then
					for a = 1,10 do
						if icon[i].spell[a] then
							if IsMouseOnButton(xx+55*rate+a*40*rate,yy+30*rate+i*35*rate,30*rate,30*rate) then
								if icon[i].spell[a].status == false then
									icon[i].spell[a].status = true
									icon[i].steelSpells[#icon[i].steelSpells+1] = icon[i].spell[a].name
									icon[i].spell[a].img.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..icon[i].spell[a].name)
								elseif icon[i].spell[a].status == true then
									icon[i].spell[a].img.textureId = drawMgr:GetTextureId("NyanUI/spellicons/translucent/"..icon[i].spell[a].name.."_t25")
									icon[i].spell[a].status = false
									for z = 1,#icon[i].steelSpells do
										if icon[i].steelSpells[z] == icon[i].spell[a].name then
											 table.remove(icon[i].steelSpells, z)
										end
									end								
								end
							end
						end
					end
				end
			end	
				
		elseif IsMouseOnButton(xx+175*rate,yy+80*rate,15*rate,15*rate) then
			move = not move
			return true			
		end
	end

end

function GetPlayerId(id)
	if id <=4 then
		return id + 1
	else
		return id - 4
	end
end

function GetUlti(spell,ability)
	for i,v in ipairs(ability) do
		if v.name == spell then
			if v.abilityType == LuaEntityAbility.TYPE_ULTIMATE then
				return true
			end
		end
	end
	return false
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

function GenerateSideMessage(heroName,spellName)
	local test = sideMessage:CreateMessage(200,60)
	test:AddElement(drawMgr:CreateRect(120,11,72,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(55,16,62,31,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_usual")))
	test:AddElement(drawMgr:CreateRect(10,10,40,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/spellicons/"..spellName)))
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_Rubick then
			play = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()
	icon = {} spell = {} steelSpells = {} main.lastSpell = {} main.draw = {} 
	main.togl = {}	main.sleep = {} main.phase = {} main.target = {} main.count = 0
	main.rec[2].w = 350*rate move = true
	for i = 1,#main.rec do
		main.rec[i].visible = false
	end
	if play then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
		collectgarbage("collect")
	end
end
 
script:RegisterEvent(EVENT_CLOSE,GameClose) 
script:RegisterEvent(EVENT_TICK,Load)
