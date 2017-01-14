--<<Escape with Blink Dagger | by HiRusSai>>
require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("Toggle", "K", config.TYPE_HOTKEY)
config:Load()

local active = false
local reg = false
local BlinkRange = nil
local monitor = client.screenSize.x/1600
local Font = drawMgr:CreateFont("Font","Tahoma",14*monitor,560*monitor)
local ToggleKey = config.Toggle
local statusText = drawMgr:CreateText(1215*monitor,760*monitor,-1,"Hold " .. string.char(ToggleKey) .. " to escape",Font) statusText.visible = false

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
			active = true
	elseif msg == KEY_UP and code == ToggleKey then
			active = false
			statusText.text = "Hold " .. string.char(ToggleKey) .. " to escape"
	end
end

function Tick(tick)
	if not PlayingGame() or client.console then return end
	if active then
		local me = entityList:GetMyHero()
		local BlinkDagger = me:FindItem("item_blink")
		if SleepCheck("reTime") and BlinkDagger ~= nil and BlinkRange == nil then
			if me:DoesHaveModifier("modifier_eul_cyclone") then
				if BlinkDagger.cd - 0.5 <= me:FindModifier("modifier_eul_cyclone").remainingTime then
					BlinkRange = Effect(me,"range_display")
					BlinkRange:SetVector(1,Vector(1200,0,0))
					statusText.text = "Will blink in " .. string.format("%.1f",me:FindModifier("modifier_eul_cyclone").remainingTime) .. " sec"
					Sleep(BlinkDagger.cd * 1000, "reTime")
					return
				else
					statusText.text = "Blink cd is too big. Max cd is 3 sec"
					return
				end
			elseif me:DoesHaveModifier("modifier_obsidian_destroyer_astral_imprisonment_prison") then
				if BlinkDagger.cd - 0.5 <= me:FindModifier("modifier_obsidian_destroyer_astral_imprisonment_prison").remainingTime then
					BlinkRange = Effect(me,"range_display")
					BlinkRange:SetVector(1,Vector(1200,0,0))
					statusText.text = "Will blink in " .. string.format("%.1f",me:FindModifier("modifier_obsidian_destroyer_astral_imprisonment_prison").remainingTime) .. " sec"
					Sleep(BlinkDagger.cd * 1000, "reTime")			
					return
				else
					statusText.text = "Blink cd is too big. Max cd is " .. string.format("%.1f",me:FindModifier("modifier_obsidian_destroyer_astral_imprisonment_prison").duration + 0.5)
					return
				end
			elseif me:DoesHaveModifier("modifier_puck_phase_shift") then
				if BlinkDagger.cd - 0.5 <= me:FindModifier("modifier_puck_phase_shift").remainingTime then
					BlinkRange = Effect(me,"range_display")
					BlinkRange:SetVector(1,Vector(1200,0,0))
					statusText.text = "Will blink in " .. string.format("%.1f",me:FindModifier("modifier_puck_phase_shift").remainingTime) .. " sec"
					Sleep(BlinkDagger.cd * 1000, "reTime")
					return
				else
					statusText.text = "Blink cd is too big. Max cd is " .. string.format("%.1f",me:FindModifier("modifier_puck_phase_shift").duration + 0.5)
					return
				end
			end
		end
		if SleepCheck("reTime") and BlinkDagger ~= nil and BlinkRange ~= nil and not me:IsStunned() and me.alive and not me:IsIllusion() then
			me:CastAbility(BlinkDagger,client.mousePosition)
			BlinkRange = nil
			collectgarbage("collect")
		end
	end
end

function Close()
	collectgarbage("collect")
	if reg then
		active = false
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end 

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)