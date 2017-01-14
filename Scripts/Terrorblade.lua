require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")

config = ScriptConfig.new()
config:SetParameter("Sunder", "Z", config.TYPE_HOTKEY) -- Change me if you don't like Z as the hotkey
config:Load()

local toggleKey = config.Sunder
local target = nil
local activ = true
local reg = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Sunder: On",F14) statusText.visible = false
local myhp = 0.2 --20%, Change me if you want to sunder at a higher / lower HP

local hotkeyText
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
		if activ then
			statusText.text = "(" .. hotkeyText .. ") Auto Sunder: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Sunder: Off"
		end
	end
end

function Tick()
	if not SleepCheck() then return end Sleep(125)
	local me = entityList:GetMyHero()
	if not (me and activ) then return end
	if me.alive and not me:IsChanneling() then
		local Sunder = me:GetAbility(4)
		if Sunder:CanBeCasted() and Sunder.level > 0 then
			local victim = targetFind:GetHighestPercentHP(250,true,true)
			if me.health/me.maxHealth < myhp and victim and victim.alive then
				me:SafeCastAbility(Sunder,victim)
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Terrorblade then 
			script:Disable() 
		else
			statusText.visible = true
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
