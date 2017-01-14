--<<Colored X near healthbar | by HiRusSai>>
require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("Toggle", "K", config.TYPE_HOTKEY)
config:Load()

local reg = false
local active = true
local monitor = client.screenSize.x/1600
local Font = drawMgr:CreateFont("Font","Verdana",13*monitor,560*monitor)
local ToggleKey = config.Toggle
local statusText = drawMgr:CreateText(3*monitor,90*monitor,-1,"Display MS: ON",Font) statusText.visible = false
local MS = {}
local showMS = true

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			reg = true
			statusText.visible = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function Key(msg,code)	
	if client.console or client.chat then return end
	if msg == KEY_DOWN and code == ToggleKey then
			showMS = not showMS
	elseif msg == KEY_UP and code == ToggleKey then
			active = not active
			if active then
				statusText.text = "Display MS: ON"
			elseif not active then
				statusText.text = "Display MS: OFF"
			end
	end
end

function Tick()
	if not PlayingGame() or client.console then return end
	local me = entityList:GetMyHero()
	if active then
		local enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = me:GetEnemyTeam()})
		for i,v in ipairs(enemies) do
			if v.healthbarOffset ~= -1 and not v:IsIllusion() then
				if not MS[v.handle] then
					MS[v.handle] = drawMgr:CreateText(33*monitor,-19*monitor, 0xFFFFFF80, "X", Font) MS[v.handle].visible = false MS[v.handle].entity = v MS[v.handle].entityPosition = Vector(0,0,v.healthbarOffset)
				end	
				if v.visible and v.alive then
					MS[v.handle].visible = showMS
					if v:FindModifier("modifier_rune_haste") then
						if 522 > me:GetMovespeed() then
							MS[v.handle].color = 0xE8F000FF
						end
					elseif v:FindItem("item_bottle") and v:FindItem("item_bottle").storedRune == LuaEntityRune.TYPE_HASTE then
						if 522 > me:GetMovespeed() then
							MS[v.handle].color = 0xE8F000FF
						end
					elseif v:FindItem("item_butterfly") and v:FindItem("item_butterfly").cd == 0 then
						if v:GetMovespeed() * 1.25 > me:GetMovespeed() then
							MS[v.handle].color = 0xE8F000FF
						end
						if v:GetMovespeed() * 1.25 <= me:GetMovespeed() then
							MS[v.handle].color = 0xFFFFFF80
						end
					elseif v:FindItem("item_mask_of_madness") and v:FindItem("item_mask_of_madness").cd == 0 then
						if v:GetMovespeed() * 1.17 > me:GetMovespeed() then
							MS[v.handle].color = 0xE8F000FF
						end
						if v:GetMovespeed() * 1.17 <= me:GetMovespeed() then
							MS[v.handle].color = 0xFFFFFF80
						end
					elseif v:FindItem("item_phase_boots") and v:FindItem("item_phase_boots").cd == 0 then
						if v:GetMovespeed() * 1.16 > me:GetMovespeed() then
							MS[v.handle].color = 0xE8F000FF
						end
						if v:GetMovespeed() * 1.16 <= me:GetMovespeed() then
							MS[v.handle].color = 0xFFFFFF80
						end
					elseif v:FindItem("item_ancient_janggo") and v:FindItem("item_ancient_janggo").cd == 0 then
						if v:GetMovespeed() * 1.1 > me:GetMovespeed() then
							MS[v.handle].color = 0xE8F000FF
						end
						if v:GetMovespeed() * 1.1 <= me:GetMovespeed() then
							MS[v.handle].color = 0xFFFFFF80
						end
					elseif v:GetMovespeed() > me:GetMovespeed() then
						MS[v.handle].color = 0xFF3D3DFF
					elseif v:GetMovespeed() <= me:GetMovespeed() then
						MS[v.handle].color = 0xFFFFFF80
					end
				elseif MS[v.handle].visible then
					MS[v.handle].visible = false
				end
			end
		end
	end
end

function Close()
	collectgarbage("collect")
	if reg then
		active = false
		MS = {}
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end 

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)