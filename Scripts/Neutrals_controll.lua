--[[
-- Controll List. -- 
	* Controll All Neutrals.
	* Controll All Illusions.
	* Controll [Invoker] Forged Spirit.
	* Controll [Warlock] Golem.
	* Controll [Tusk] Sigil.
	* Controll [Necronomicons].
	* Controll [DruidBear]
-- Notes/How to use. --
	SPACE - Controll[Creeps Attack enemy,Cast Skills].
		* Change key config "activated_button".
		* Creeps have Target param "mode".
			* mode=1 - GetTarget you hero radius.
			* mode=2 - GetTarget your Mouse Cursor.
			* mode=3 - GetTarget Creep radius.
	L - Support [stackscript].
		* Only works for Neutrals!
		* Select Creep and press "L" and use "O" for stack ;)
		* To remove this Creep. Target self or select any other your Creep and then press "L".
		* Creep will not respond to SPACE[Controll].
		* Change key config "no_stack_creep_button".
		* If the parameter "effecttocreep" true, then creep will have effect aura.
]]
require("libs.Utils")
require("libs.TargetFind")
if client.language == "russian" then
	local f=io.open(SCRIPT_PATH.."/libs/Neutrals.lua","r")
	if f~=nil then
		io.close(f) 
		require("libs.Neutrals")
	else
		print("Error: loading -> libs/Neutrals.lua")
		script:Disable()
		return
	end
end
local Version = "1.10"
local eff = {}
local activated = false
local creepHandle = nil
local SaveCreep = nil
local param = 1
local Font = drawMgr:CreateFont("NoStack","Arial",14,500)
local NoStackText = drawMgr:CreateText(5,63,-1,"",Font)

-- Setting
local activated_button = string.byte(" ") -- KEY TO USE
local no_stack_creep_button = string.byte("L") -- KEY TO USE
local mode=3 -- MODE 1/2/3
local effecttocreep = true -- Effect for Creep.

function Tick( tick )
	local me = entityList:GetMyHero()
	if not me then return end
	
	if sleepTick and sleepTick > tick then
		return
	end
	local target = nil
	local Neutrals = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Neutral,controllable=true,alive=true,visible=true})
	local InvForgeds = entityList:FindEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,controllable=true,alive=true,visible=true})
	local WarlockGolem = entityList:FindEntities({classId=CDOTA_BaseNPC_Warlock_Golem,controllable=true,alive=true,visible=true})
	local TuskSigil = entityList:FindEntities({classId=CDOTA_BaseNPC_Tusk_Sigil,controllable=true,alive=true,visible=true})
	local Necronomicons = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep,controllable=true,alive=true,visible=true})
	local Illusions = entityList:FindEntities({classId=TYPE_HERO,controllable=true,alive=true,visible=true,illusion=true})
	local DruidBear = entityList:FindEntities({classId=CDOTA_Unit_SpiritBear,controllable=true,alive=true,visible=true})

	if creepHandle ~= nil and effecttocreep then
		if not SaveCreep.alive then
			if eff[creepHandle] ~= nil then
				eff[creepHandle] = nil
				creepHandle = nil
				SaveCreep = nil
				NoStackText.visible = false
				collectgarbage("collect")
			end
		end
	end
	
	if mode == 1 then
		target = targetFind:GetLastMouseOver(1300)
	elseif mode == 2 then
		target = entityList:GetMouseover()
	elseif mode == 3 then
		target = targetFind:GetClosestToMouse(1300)
	else
		print("please check mode 1/2/3. Thank.")
		return
	end
	if target and activated then
		if target.team == (5-me.team) then
			if #Neutrals > 0 then
			CheckStun = target:DoesHaveModifier("modifier_centaur_hoof_stomp")
			CheckSetka = target:DoesHaveModifier("modifier_dark_troll_warlord_ensnare")
				for i,v in ipairs(Neutrals) do
					if v.controllable and v.handle ~= creepHandle then
						if v.unitState ~= -1031241196 then
							local distance = GetDistance2D(v,target)
							if distance <= 1300 then
								if v.name == "npc_dota_neutral_centaur_khan" then
									if distance < 250 and not (CheckStun or CheckSetka) then
										v:SafeCastAbility(v:GetAbility(1),nil)
									end
								elseif v.name == "npc_dota_neutral_satyr_hellcaller" then
									if distance < 980 then
										v:SafeCastAbility(v:GetAbility(1),target.position)
									end						
								elseif v.name == "npc_dota_neutral_polar_furbolg_ursa_warrior" then
									if distance < 300 then
										v:SafeCastAbility(v:GetAbility(1),nil)
									end							
								elseif v.name == "npc_dota_neutral_dark_troll_warlord" then
									if distance < 550 and not (CheckStun or CheckSetka) then
										v:SafeCastAbility(v:GetAbility(1),target)
									end							
								end
								if distance <= 1300 then
									v:Attack(target)
								end
							end
						end
					end
				end
			end
			
			if #InvForgeds > 0 then
				for i,v in ipairs(InvForgeds) do
					if v.controllable and v.unitState ~= -1031241196 then
						local distance = GetDistance2D(v,target)
						if distance <= 1300 then
							v:Attack(target)
						end
					end
				end
			end
			
			if #WarlockGolem > 0 then
				for i,v in ipairs(WarlockGolem) do
					if v.controllable and v.unitState ~= -1031241196 then
						local distance = GetDistance2D(v,target)
						if distance <= 1300 then
							v:Attack(target)
						end
					end
				end
			end
			
			if #TuskSigil > 0 then
				for i,v in ipairs(TuskSigil) do
					if v.controllable and v.unitState ~= -1031241196 then
						local distance = GetDistance2D(v,target)
						if distance <= 1300 then
							v:Follow(target)
						end
					end
				end
			end
			
			if #DruidBear > 0 then
				for i,v in ipairs(DruidBear) do
					if v.controllable and v.unitState ~= -1031241196 then
						local distance = GetDistance2D(v,target)
						if distance <= 1300 then
							v:Attack(target)
						end
					end
				end
			end
			
			if #Necronomicons > 0 then
				for i,v in ipairs(Necronomicons) do
					if v.controllable and v.unitState ~= -1031241196 then
						local distance = GetDistance2D(v,target)
						if v.name == "npc_dota_necronomicon_archer_1" or v.name == "npc_dota_necronomicon_archer_2" or v.name == "npc_dota_necronomicon_archer_3" then
							if distance < 600 then
								v:SafeCastAbility(v:GetAbility(1),target)
							end				
						end
						if distance <= 1300 then
							v:Attack(target)
						end
					end
				end
			end
			
			if #Illusions > 0 then
				for i,v in ipairs(Illusions) do
					if v.controllable and v.unitState ~= -1031241196 then
						local distance = GetDistance2D(v,target)
						if distance <= 1300 then
							v:Attack(target)
						end
					end
				end
			end
		end
	end
	sleepTick = tick + 333
	return
end

function Key(msg,code)
	if client.chat then return end

    if code == activated_button then
        activated = (msg == KEY_DOWN)
	end
		
	if code == no_stack_creep_button and msg == KEY_UP then
		local player = entityList:GetMyPlayer()
		if not player or player.team == LuaEntity.TEAM_NONE then
			return
		end
		
		local effectDeleted = false
		
		if param == 2 then
			if eff[creepHandle] ~= nil and effecttocreep then
				eff[creepHandle] = nil
				effectDeleted = true
			end
			SaveCreep = nil
			creepHandle = nil
			NoStackText.visible = false
			param = 1
		end
		
		if effectDeleted then
			collectgarbage("collect")
		end

		local selection = player.selection
		if #selection ~= 1 or (selection[1].type ~= LuaEntity.TYPE_CREEP and selection[1].type ~= LuaEntity.TYPE_NPC) or selection[1].classId ~= CDOTA_BaseNPC_Creep_Neutral or not selection[1].alive or not selection[1].controllable then
			return
		end

		if param == 1 then
			creepHandle = selection[1].handle
			SaveCreep = selection[1]
			if eff[creepHandle] == nil and effecttocreep then
				eff[creepHandle] = Effect(selection[1],"aura_assault")
				eff[creepHandle]:SetVector(1,Vector(0,0,0))
			end
			if client.language == "russian" then
				NoStackText.text = "Stack Creep: "..client:Localize(names[selection[1].name].Name)
			else	
				NoStackText.text = "Stack Creep: "..client:Localize(selection[1].name)
			end
			local name = client:Localize(selection[1].name)
			NoStackText.visible = true
			param = 2
		end
	end
end

function GameClose()
	eff = {}
	activated = false
	creepHandle = nil
	SaveCreep = nil
	param = 1
	script:UnregisterEvent(Key)
	script:UnregisterEvent(Tick)
	collectgarbage("collect")
	if registered then
		registered = false
		script:RegisterEvent(EVENT_TICK,Load)
	end
end

function Load()
	if not client.connected or client.loading or client.console then return end
	local me = entityList:GetMyHero()
	if not me then return end
	script:RegisterEvent(EVENT_KEY,Key)
	script:RegisterEvent(EVENT_TICK,Tick)
	registered = true
	script:UnregisterEvent(Load)
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
