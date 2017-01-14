--<<If the icon has become a color that mean that creep dies from your attack d.l.>>
--lash hit marker
require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("LastHitKey", "C", config.TYPE_HOTKEY)
config:SetParameter("DenayHitKey", "X", config.TYPE_HOTKEY)
config:SetParameter("AutoDisableLateGame", false)
config:SetParameter("LastHit", false)
config:Load()

local rect = {}
local sleep = 0
local play = false
local play1 = false
local ex = client.screenSize.x/1600*0.8

local lasthit = config.LastHit
local ad = config.AutoDisableLateGame
local lasthitKey = config.LastHitKey
local denyKey = config.DenayHitKey

function Tick(tick)

	if client.console or not SleepCheck() then return end	
	
	Sleep(100)

	local me = entityList:GetMyHero()	
	if not me then return end

	if ad and client.gameTime > 1800 or me.dmgMin > 100 then
		GameClose()
		script:Disable()
	end

	local dmg = Damage(me)
	local creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane})

	for i,v in ipairs(creeps) do
		if v.spawned then
			local OnScreen = client:ScreenPosition(v.position)	
			if OnScreen then
				local offset = v.healthbarOffset
				if offset == -1 then return end			
				
				if not rect[v.handle] then 
					rect[v.handle] = drawMgr:CreateRect(-4*ex,-32*ex,0,0,0xFF8AB160) rect[v.handle].entity = v rect[v.handle].entityPosition = Vector(0,0,offset) rect[v.handle].visible = false 					
				end
				
				if v.visible and v.alive then
					local damage = (dmg*(1-v.dmgResist)+1)
					if v.health > 0 and v.health < damage then						
						if v.team == me.team then
							rect[v.handle].w = 20*ex
							rect[v.handle].h = 20*ex
							rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Deny")
						else
							rect[v.handle].w = 15*ex
							rect[v.handle].h = 15*ex
							rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Coin")
						end
						rect[v.handle].visible = true
					elseif v.health < damage+88 then					
						if v.team == me.team then
							rect[v.handle].w = 20*ex
							rect[v.handle].h = 20*ex
							rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Deny")
						else
							rect[v.handle].w = 15*ex
							rect[v.handle].h = 15*ex
							rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Coin")
						end
						rect[v.handle].visible = true
					else 
						rect[v.handle].visible = false
					end
				elseif rect[v.handle].visible then
					rect[v.handle].visible = false
				end
			end	
		end
	end

end

function ZuusTick(tick)
	
	if client.console or not SleepCheck() then return end	
	
	Sleep(100)

	local me = entityList:GetMyHero()	
	if not me then return end

	if ad and client.gameTime > 1800 or me.dmgMin > 100 then
		GameClose()
		script:Disable()
	end

	local dmg = Damage(me)
	local q_ = me:GetAbility(1)
	local q_dmg = q_:GetDamage(q_.level)
	local creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane})	
	
	for i,v in ipairs(creeps) do
		if v.spawned then
			local OnScreen = client:ScreenPosition(v.position)	
			if OnScreen then
				local offset = v.healthbarOffset
				if offset == -1 then return end			
				
				if not rect[v.handle] then 
				   rect[v.handle] = drawMgr:CreateRect(-4*ex,-32*ex,0,0,0xFF8AB160) rect[v.handle].entity = v rect[v.handle].entityPosition = Vector(0,0,offset) rect[v.handle].visible = false					
				end
				
				if v.visible and v.alive then
					local damage = (dmg*(1-v.dmgResist)+1)
					if v.health > 0 and v.health < damage then						
						if v.team == me.team then
							rect[v.handle].w = 20*ex
							rect[v.handle].h = 20*ex
							rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Deny")
						else
							rect[v.handle].w = 15*ex
							rect[v.handle].h = 15*ex
							rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Coin")
						end
						rect[v.handle].visible = true
					elseif v.health < q_dmg then					
						if v.team ~= me.team then
							rect[v.handle].w = 15*ex
							rect[v.handle].h = 15*ex	
							rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Zuus_Coin")
						end
						rect[v.handle].visible = true
					else
						rect[v.handle].visible = false
					end
				elseif rect[v.handle].visible then
					rect[v.handle].visible = false
				end
			end	
		end
	end
	
end

function Damage(me)
	local items = me.items
	for i,item in ipairs(items) do
		if item and item.name == "item_quelling_blade" then
			return me.dmgMin*1.40 + me.dmgBonus
		end
	end
	return me.dmgMin + me.dmgBonus
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Zuus then
			play = true
			script:RegisterEvent(EVENT_TICK,Tick)
		else
			play1 = true
			script:RegisterEvent(EVENT_TICK,ZuusTick)
		end
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	rect = {}
	rect1 = {}
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		play = false
	elseif play1 then
		script:UnregisterEvent(ZuusTick)
		play1 = false
	end
	script:RegisterEvent(EVENT_TICK,Load)
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
