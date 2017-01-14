--<<Roshan Slayer V 1.0 | Cleaned by HiRusSai>>--

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.Animations")

config = ScriptConfig.new()
config:SetParameter("Toggle", "K", config.TYPE_HOTKEY)
config:Load()

local Toggle = config.Toggle
local Toggled = false
local Items = {29, 46, 42}
local ItemsB = false
local Step = 0

local x,y = 5, 50
local monitor = client.screenSize.x/1600
local ScreenX = client.screenSize.x
local ScreenY = client.screenSize.y
local Font = drawMgr:CreateFont("Font","Tahoma",0.01671875*ScreenY,0.4375*ScreenX)
local statusText = drawMgr:CreateText((x+1320)*monitor,(y+25)*monitor,0xF2754BB3,"Roshan slayer: OFF",Font)

function Load()
	local me = entityList:GetMyHero()

	if PlayingGame() then
		if (me.classId ~= CDOTA_Unit_Hero_Ursa) then
			script:Disable()
			else
			registered = true
			statusText.visible = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_DOTA,Roshan)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function Key()
	if client.chat or client.console or client.loading then return end

	if IsKeyDown(Toggle) then
		Toggled = not Toggled
		if Toggled then
			statusText.text = "Roshan slayer: ON"
			statusText.color = 0x39B8E3B3
			Toggled = true
		else
			statusText.text = "Roshan slayer: OFF"
			statusText.color = 0xF2754BB3
			Step = 0
			Toggled = false
		end
	end
end

function Danger()
local me = entityList:GetMyHero()
local enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, alive = true, visible = true, team = me:GetEnemyTeam()})
for i, v in ipairs(enemies) do
	if GetDistance2D(v, me) <= 700 then
		return true
	end
end
return false
end

function Main(tick)
	if not SleepCheck() or client.paused then return end
	local me = entityList:GetMyHero()
	if not me then return end

	if Toggled then
		local Ward = entityList:GetEntities(function(x) return x.classId == CDOTA_NPC_Observer_Ward and x:GetDistance2D(me) <= 1000 end)
		local mp = entityList:GetMyPlayer()
		local roshan = entityList:GetEntities({classId = CDOTA_Unit_Roshan}) [1]

		if client.gameTime < 0 then
			if not ItemsB then
				for i, itemID in ipairs(Items) do
					entityList:GetMyPlayer():BuyItem(itemID)
				end
				mp:LearnAbility(me:GetAbility(3))
				Sleep(100)
				if me:FindItem("item_tpscroll") and me:FindItem("item_ward_observer") then
					me:CastItem("item_tpscroll",Vector(1360,-1240,100),true)
					me:CastItem("item_ward_observer", Vector(3805,-2382,400), true)
					ItemsB = true
				end
			end
		elseif client.gameTime > 0 then
			ItemsB = true
		end

		if ItemsB then
			if Step == 0 and not me:FindItem("item_ward_observer") and not Danger() then
				me:AttackMove(Vector(4282,-1816,100))
				Step = 2
				Sleep(2900) return
			end
		end
		
		if Step == 1 and roshan and me:GetDistance2D(roshan) > (380 - client.latency/5.5) and not Danger() then --345
			me:AttackMove(Vector(4282,-1816,100))
			Step = 2
		elseif Step == 2 and Animations.CanMove(me) then
			me:Move(Vector(3478,-1969,100))
			Step = 3
		elseif Step == 3 and roshan and me:GetDistance2D(roshan) < (275 + client.latency/5) and me:GetDistance2D(Vector(3478,-1969,100)) < 3 then --296
			me:Attack(Ward[1])
			me:Stop()
			Step = 1
		end
	end
end

function Roshan(event)
	if event.name == "dota_roshan_kill" then
		Toggled = false
		statusText.visible = false
		collectgarbage("collect")
		script:UnregisterEvent(Main)
	end
end

function Close()
	collectgarbage("collect")
	if registered then
		Toggled = false
		ItemsB = false
		Step = 0
		statusText.Visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)