require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("ShowAbilityPanel", "56", config.TYPE_HOTKEY)
config:SetParameter("SingleHotKey", "O", config.TYPE_HOTKEY)
config:SetParameter("Range", 1200)
config:Load()

--ability
local toggleKey = config.ShowAbilityPanel
local activated1,move = false,false
local xx,yy = 180,80
local spells = {}
local global = nil
local text = drawMgr:CreateText(0,0,0xFFFFFFff,"Range Display",drawMgr:CreateFont("manabarsFont","Arial",14,500))
text.visible = false

--single
local rangeSingle = config:GetParameter("Range")
local keySingle = config.SingleHotKey
local activated2 = false
local effectSingle = nil

function Tick(tick)

	if client.console or not SleepCheck() then return end

	Sleep(250)

	local me = entityList:GetMyHero()
	if not me then return end
	local ability = me.abilities
	local spellList = {}
	
	for a,spell in ipairs(me.abilities) do
		if spell.abilityType ~= LuaEntityAbility.TYPE_ATTRIBUTES and not spell.hidden then
			spellList[#spellList+1] = spell
		end
	end
	
	for a,v in ipairs(spellList) do
		if not spells[a] then 
			spells[a] = {}
			spells[a].img = drawMgr:CreateRect(0,0,32,32,0x000000FF) spells[a].img.visible = false
			spells[a].rect = drawMgr:CreateRect(0,0,36,36,0xFFFFFFff,true) spells[a].rect.visible = false
			spells[a].img.textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..v.name)	
		end
	end
	
	global = #spellList
	
	if activated1 then
		if xx == 180 and yy == 80 then LoadGUIConfig() end
		if move == true then
			xx,yy = client.mouseScreenPosition.x - 39*global/2 - 20,client.mouseScreenPosition.y + 15
		end
		text.x,text.y,text.visible = xx + 39*global/2,yy-18,true		
		for a,v in ipairs(spellList) do
			spells[a].img.x,spells[a].img.y = xx+38*a,yy
			spells[a].rect.x,spells[a].rect.y = xx+38*a-2,yy - 2
			if spells[a].state then					
				spells[a].rect.color = 0xFFFFFFff
			else
				spells[a].rect.color = 0x000000ff
			end
			spells[a].img.visible,spells[a].rect.visible = true,true
		end
	elseif text.visible then
		for a = 1, #spellList do
			spells[a].img.visible,spells[a].rect.visible = false,false		
		end
		text.visible = false
	end

	local dirty = false
	for a,v in ipairs(spellList) do
		if v.level ~= 0 then
			if spells[a].state then
				spells[a].range = v.castRange
				if not spells[a].range or spells[a].range == 0 then	
					spells[a].range = GetSpecial(v)					
				end
				if not spells[a].range then return end
				if not spells[a].effect or spells[a].ranges ~= spells[a].range then
					spells[a].effect = Effect(me,"range_display")
					spells[a].effect:SetVector( 1,Vector(spells[a].range,0,0) )
					spells[a].ranges = spells[a].range
					dirty = true
				end						
			elseif spells[a].effect then
				spells[a].effect = nil
				dirty = true
			end
		end
	end
	if dirty then
		collectgarbage("collect")
	end

end

function Key(msg,code)

	local count = global

	if not count or client.chat then return end

	if msg == KEY_DOWN then
		if code == toggleKey then
			activated1 = not activated1
		elseif code == keySingle then
			 local me = entityList:GetMyHero()
			 activated2 = not activated2
			 if activated2 then
				-- add effect
				effectSingle = Effect(me,"range_display")
				effectSingle:SetVector(1,Vector(rangeSingle,0,0))
			else
				RemoveEffect()
			end  
		end
	elseif msg == LBUTTON_UP then
		if activated1 then
			if IsMouseOnButton(xx+39*count/2,yy-20,20,100) then
				move = (not move)
				SaveGUIConfig(xx,yy)
			else
				for a = 1,count do
					if IsMouseOnButton(xx+38*a,yy,32,32) then
						spells[a].state = (not spells[a].state)
					end
				end
			end
		end
	end

end

function RemoveEffect()
	effectSingle = nil
	collectgarbage("collect")
	activated2 = false
end

function GetSpecial(spell)
	if spell.specialCount > 1 then
		for i,v in ipairs(spell.specials) do
			if v.name == "radius" then
				return v:GetData(math.min(v.dataCount,spell.level))
			elseif v.name == "area_of_effect" then
				return v:GetData(math.min(v.dataCount,spell.level))
			elseif v.name == "dash_length" then
				return v:GetData(math.min(v.dataCount,spell.level))
			end
		end
		local last = spell:GetSpecial(1):GetData(math.min(spell.specials[1].dataCount,spell.level))
		if type(last) == "number" and last > 100 then
			return last
		end
	end
	return nil
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

function SaveGUIConfig(xx,yy)
	local file = io.open(SCRIPT_PATH.."/libs/DRDConfig.txt", "w+")
	if file then
			file:write(xx.."\n"..yy)
			file:close()
	end
end

function LoadGUIConfig()
	local file = io.open(SCRIPT_PATH.."/libs/DRDConfig.txt", "r")
	if file then
			xx, yy = file:read("*number", "*number")
			file:close()
	end
end

function Load()
	if PlayingGame() then
		play = true
		text.visible = false
		spells = {}
		activated1,move = false,false
		RemoveEffect()
		script:RegisterEvent(EVENT_TICK,Tick)
		script:RegisterEvent(EVENT_KEY,Key)
		script:UnregisterEvent(Load)
	end
end

function GameClose()	
	if play then
		print("213")
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
	text.visible = false
	spells = {}
	activated1,move = false,false
	RemoveEffect()
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
