--<<фаст чардж через минимапу на ближайшего к курсору крипа, по дефолту Q>>
require("libs.Res")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "Q", config.TYPE_HOTKEY)
config:Load()

local play = false

function SBKey(msg,code)
	if msg ~= KEY_UP or client.chat or not PlayingGame() then return end
	if code == config.Hotkey then
		local me = entityList:GetMyHero()	
		local coor = MapToMinimap(me.position.x,me.position.y)
		if coor ~= nil then
			local list = entityList:GetEntities(function (v) return (v.type == LuaEntity.TYPE_CREEP or v.type == LuaEntity.TYPE_HERO) and v.alive and v.visible and v.team ~= me.team and v:GetDistance2D(me) > 2000 end)
			table.sort( list, function (a,b) return a:GetDistance2D(coor) < b:GetDistance2D(coor) end )
			me:CastAbility(me:GetAbility(1),list[1])
			return true
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_SpiritBreaker then			
			play = true
			script:RegisterEvent(EVENT_KEY,SBKey)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()	
  if play then
		script:UnregisterEvent(SBKey)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
