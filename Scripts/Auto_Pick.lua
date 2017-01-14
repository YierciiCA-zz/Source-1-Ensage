--<<ясно понятно d.l.>>

require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("Heroes", "techies")
config:Load()
local hero = config.Heroes

function Tick(tick)
	if not client.connected or client.loading or client.console then return end
	if client.gameState == Client.STATE_PICK then
		client:ExecuteCmd("dota_select_hero npc_dota_hero_"..hero)
		script:Disable()
	end	
end
	
script:RegisterEvent(EVENT_TICK,Tick)
