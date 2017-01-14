--<<SpiritBreaker Auto Charge to Escape >>

--Libraries
require("libs.Utils")
require("libs.ScriptConfig")

--Config
config = ScriptConfig.new()
config:SetParameter("EscapeKey", "B", config.TYPE_HOTKEY)
config:Load()

local EscapeKey     = config.EscapeKey
local registered	= false

local target	    = nil
local active	    = false

--Text on your screen
local x,y = 1420, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Verdana",15*monitor,550*monitor) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,-1,"AutoSBEscape - Hotkey: ''"..string.char(EscapeKey).."''",F14) statusText.visible = false

function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_SpiritBreaker then
			script:Disable()
		else
			registered = true
			statusText.visible = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == EscapeKey then
		active = (msg == KEY_DOWN)
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not (me and active) then return end
	local Charge = me:GetAbility(1)
	
	if active then
	FindTarget()
	    if target and me.alive then
	        me:CastAbility(Charge,target)
	    end
	end
end

function FindTarget()
	local FurthestCreep = nil
	local me = entityList:GetMyHero()
	local enemies = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,team = me:GetEnemyTeam(),alive=true,visible=true})
	for i,v in ipairs(enemies) do
		distance = GetDistance2D(v,me)
		if distance > 1500 then 
			if FurthestCreep == nil then
		        FurthestCreep = v
			elseif distance > GetDistance2D(FurthestCreep,me) then
			    FurthestCreep = v
		    end
		end
	end
	target = FurthestCreep
end

function onClose()
	collectgarbage("collect")
	if registered then
	    statusText.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,onLoad)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
