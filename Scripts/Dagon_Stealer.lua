--<<ez kills d.l.>>
require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "48", config.TYPE_HOTKEY)
config:Load()

local key =  config.Hotkey
local xx = client.screenSize.x/300 
local yy = client.screenSize.y/1.55

local activated = true 
local play = false
local sleep = 250
local icon = drawMgr:CreateRect(xx,yy,36,24,0x000000ff,drawMgr:GetTextureId("NyanUI/items/dagon")) icon.visible = false
local rect = drawMgr:CreateRect(xx-1,yy-1,26,25,0xFFFFFF90,true) rect.visible = false

function Tick(tick)
 
	if client.console or not SleepCheck() then return end
	
	Sleep(250)

	local me = entityList:GetMyHero() 
	
	if not me then return end

	local dagon = me:FindDagon()
	local visible = IsTrue(activated,dagon)
	
	rect.visible = visible
	icon.visible = visible
	
	if visible and dagon:CanBeCasted() and me:CanUseItems() and not me:IsChanneling() and Nyx(me) then
		local dmgD = dagon:GetSpecialData("damage")
		local enemy = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team ~= me.team and not v:IsIllusion() end)		
		for i, v in ipairs(enemy) do
			if GetDistance2D(v,me) < dagon.castRange+25 and v:CanDie() then
				if not v:DoesHaveModifier("modifier_nyx_assassin_spiked_carapace") and not v:IsLinkensProtected() then
					if v.health + (client.latency/1000*v.healthRegen) < v:DamageTaken(dmgD, DAMAGE_MAGC, me) then
						me:CastAbility(dagon,v)
						break
					end
				end
			end
		end
	end

end

function IsTrue(a,b)
	return a and b ~= nil
end

function Nyx(target)
	if target.classId == CDOTA_Unit_Hero_Nyx_Assassin and target:DoesHaveModifier("modifier_nyx_assassin_vendetta") then
		return false
	end
	return true
end

function Key(msg,code)
	if msg ~= KEY_UP and code == key and not client.chat then
		activated = not activated
	end
end

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:RegisterEvent(EVENT_KEY,Key)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	if play then
		rect.visible = false
		icon.visible = false
		activated = true
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
