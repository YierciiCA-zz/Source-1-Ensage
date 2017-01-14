--<<EARLY BETA EXTENSION for Timbersaw Simple Combo (use with last)>>

require("libs.Utils")
require('libs.HotkeyConfig2')
require("libs.Skillshot")

local play = false

--CONFIG
local lowUltPriority = true
--END

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Shredder Combo")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Toggle Key",SGC_TYPE_TOGGLE,false,false,68)
ScriptConfig:AddParam("CK","Use: Chakram",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("SG","Use: Shiva",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("SR","Use: Soul Ring",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("SS","Use: Hex",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("HH","Use: Halberd",SGC_TYPE_TOGGLE,false,true,nil)

local F14 = drawMgr:CreateFont("F14","Segoe UI",14,550)
local statusText = drawMgr:CreateText(0,0,0xFF6600FF,"Combo Disabled!",F14); statusText.visible = false

function Key(msg,code)
	if msg ~= KEY_UP and not client.chat then
		if ScriptConfig.Hotkey then
			statusText.text = "Combo Enabled!"
			statusText.color = 0x66FF33FF
			statusText.entity			= entityList:GetMyHero()
			statusText.entityPosition	= Vector(0,0,entityList:GetMyHero().healthbarOffset)
		else
			statusText.text = "Combo Disabled!"
			statusText.color = 0xFF6600FF
			statusText.entity			= entityList:GetMyHero()
			statusText.entityPosition	= Vector(0,0,entityList:GetMyHero().healthbarOffset)
		end
	end
end

function ShredderTick(tick)
	if not ScriptConfig.Hotkey or not SleepCheck() or client.paused then return end
	
	local me = entityList:GetMyHero()
	local enemy = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 900 end)
	local lowestHP = {nil}
	for i,v in ipairs(enemy) do
		if not lowestHP[1] then
			lowestHP[1] = v
		end
		if lowestHP[1].health > v.health then
			lowestHP[2] = lowestHP[1]
			lowestHP[1] = v
		end
	end
	
	statusText.entity			= me 
	statusText.entityPosition	= Vector(0,0,me.healthbarOffset)
	
	if me:GetAbility(2).cd > 3 then 
		local SG = me:FindItem("item_shivas_guard")
		local SR = me:FindItem("item_soul_ring")
		local SS = me:FindItem("item_sheepstick")
		local HH = me:FindItem("item_heavens_halberd")
		local CK  = {me:GetAbility(6), me:GetAbility(4)}		-- N Chakram
		local Q  = me:GetAbility(1)
		
		-- Soul Ring
		if me.mana < me.maxMana*0.5 and ScriptConfig.SR and SR and SR:CanBeCasted() and not IsAllAllCasted() then
			for i,v in ipairs(enemy) do
				if me:GetDistance2D(v) <= 600 then
					me:CastAbility(SR)
				end
			end
		end
		-- Sheep Stick (Hex)
		if ScriptConfig.SS and SS and SS:CanBeCasted() and not Q:CanBeCasted() then
			for i,v in ipairs(enemy) do
				if SS:CanBeCasted() and v.health > 0 and not v:IsMagicDmgImmune() and me:GetDistance2D(v) <= 600 then
					me:CastAbility(SS,v)
				end
			end
		end
		-- Shiva's Guard
		if ScriptConfig.SG and SG and SG:CanBeCasted() then
			for i,v in ipairs(enemy) do
				if SG:CanBeCasted() and v.health > 0 and not v:IsMagicDmgImmune() and not v:IsHexed() and me:GetDistance2D(v) <= 600 then
					me:CastAbility(SG)
				end
			end
		end
		-- Heaven's Halberd
		if ScriptConfig.HH and HH and HH:CanBeCasted() and not Q:CanBeCasted() then
			for i,v in ipairs(enemy) do
				if HH:CanBeCasted() and v.health > 0 and not v:IsMagicDmgImmune() and not v:IsHexed() and not v:IsStunned() and me:GetDistance2D(v) <= 500 then
					me:CastAbility(HH,v)
				end
			end
		end
		-- Chakram
		if ScriptConfig.CK and IsAllCasted() and ((CK[1] and CK[1]:CanBeCasted()) or (CK[2] and CK[2]:CanBeCasted())) and not Q:CanBeCasted() then
			for i,v in ipairs(lowestHP) do
				if v.health > 0 and not v:IsMagicDmgImmune() and me:GetDistance2D(v) <= 500 then
					local CP1,CP2 = CK[1]:FindCastPoint(),CK[2]:FindCastPoint()
					local delay1,delay2 = CP1*1000+client.latency+me:GetTurnTime(v)*1000,CP2*1000+client.latency+me:GetTurnTime(v)*1000
					local speed = 1200
					local xyz1,xyz2 = SkillShot.SkillShotXYZ(me,v,delay1,speed),SkillShot.SkillShotXYZ(me,v,delay2,speed)
					if CK[1]:CanBeCasted() then
						me:CastAbility(CK[1],xyz1)
					elseif CK[2]:CanBeCasted() then
						me:CastAbility(CK[2],xyz2)
					end
				end
			end
		end
	end
end

-- HELPFUL FUNCTIONS
function IsAllCasted()
	if lowUltPriority then
		local me = entityList:GetMyHero()
		
		local SG = me:FindItem("item_shivas_guard")
		local SS = me:FindItem("item_sheepstick")
		local HH = me:FindItem("item_heavens_halberd")
		-- Shiva's Guard
		if SG then
			if SG:CanBeCasted() then
				return false
			end
		end
		-- Sheep Stick (Hex)
		if SS then
			if SS:CanBeCasted() then
				return false
			end
		end
		-- Heaven's Halberd
		if HH then
			if HH:CanBeCasted() then
				return false
			end
		end
		
	end
	return true
end

function IsAllAllCasted()
	local me = entityList:GetMyHero()
	local key = false
	
	if lowUltPriority == false then
		lowUltPriority = true
		key = true
	end
	IsAllCasted()
	
	CK  = {me:GetAbility(6), me:GetAbility(4)}		-- N Chakram
	
	if ScriptConfig.CK and ((CK[1] and CK[1]:CanBeCasted()) or (CK[2] and CK[2]:CanBeCasted())) then
		if CK[1]:CanBeCasted() then
			return false
		elseif CK[2]:CanBeCasted() then
			return false
		end
	end
	
	if key == true then
		lowUltPriority = false
		key = false
	end
	return true
end
--HELPFUL FUNCTIONS END

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()	
		if me.classId == CDOTA_Unit_Hero_Shredder then			
			play = true
			ScriptConfig:SetVisible(true)
			statusText.visible = true
			script:RegisterEvent(EVENT_TICK,ShredderTick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()	
	if play then
		script:UnregisterEvent(ShredderTick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		statusText.visible = false
		ScriptConfig:SetVisible(false)
		play = false
		activated = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
