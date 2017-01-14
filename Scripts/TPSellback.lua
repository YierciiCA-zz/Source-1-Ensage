--<<Teleport Sellback temp fix | Mod by HiRusSai>>
require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "U", config.TYPE_HOTKEY)
config:SetParameter("DependOnPing", true, config.TYPE_BOOL)
config:SetParameter("RemainingTime", "0.06", config.TYPE_NUMBER)
config:Load()

local Screen = client.screenSize.x/1600
local Active = false
local Hotkey = config.Hotkey
local DependOnPing = config.DependOnPing
local RemainingTime = config.RemainingTime
local registered  = false

local F14 = drawMgr:CreateFont("F14","Tahoma",14*Screen,550*Screen)
local statusText = drawMgr:CreateText(1500*Screen,695*Screen,-1,"TP Sellback: OFF",F14)

function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_FRAME,Frame)
			script:UnregisterEvent(onLoad)
		end
	end
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(Hotkey) then
		Active = not Active
		if Active then
			statusText.text = "TP Sellback: ON"
			print("TP Sellback is enabled! Your ping is", client.avgLatency)
		elseif not Active then
			statusText.text = "TP Sellback: OFF"
		end
	end
end

function Frame(frame)
	if not client.connected or client.console then return end	
	if not Active then return end
	local me = entityList:GetMyHero()
	local tpBuff = me:FindModifier("modifier_teleporting")
	
	if tpBuff then
		local tpItem = me:FindItem("item_tpscroll")
		if tpItem and tpItem.charges == 1 then
			if DependOnPing then
				if tpBuff.remainingTime < ((client.latency)/1100) then
					entityList:GetMyPlayer():Select(me)
					entityList:GetMyPlayer():SellItem(tpItem)
					Sleep(500)
				end
			elseif not DependOnPing then
				if tpBuff.remainingTime <= RemainingTime then
					entityList:GetMyPlayer():Select(me)
					entityList:GetMyPlayer():SellItem(tpItem)
					Sleep(500)
				end
			end
		end
	end
end

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Frame)
		statusText.visible = false
		registered = false
		script:RegisterEvent(EVENT_TICK,onLoad)
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)