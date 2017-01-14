--<<Automatic learning abilities. d.l.>>
require("libs.ScriptConfig")
require("libs.Utils")
require("libs.SideMessage")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "57", config.TYPE_HOTKEY)
config:Load()

toggleKey = config.Hotkey

activated = false
icon = {} rect = {} table1 = {} table2 = {} table3 = {} spellS = {} spellL = {} text = {} textR = {}

F16 = drawMgr:CreateFont("F14","Arial",16,500)

icon[1] = drawMgr:CreateRect(140,100,16,16,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/".."shadow_demon_shadow_poison_release"))
icon[1].visible = false
rect[1] = drawMgr:CreateRect(139,99,18,18,0xFFFFFF90,true)
rect[1].visible = false
icon[2] = drawMgr:CreateRect(170,100,16,16,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/".."shadow_demon_shadow_poison"))
icon[2].visible = false
rect[2] = drawMgr:CreateRect(169,99,18,18,0xFFFFFF90,true)
rect[2].visible = false
icon[3] = drawMgr:CreateRect(200,100,16,16,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/".."kunkka_return"))
icon[3].visible = false
rect[3] = drawMgr:CreateRect(199,99,18,18,0xFFFFFF90,true)
rect[3].visible = false
rect[4] = drawMgr:CreateRect(62,123,754,176,0x00000090)
rect[4].visible = false
rect[5] = drawMgr:CreateRect(30,123,786,176,0xFFFFFF30,true)
rect[5].visible = false
for a = 6,9 do rect[a] = drawMgr:CreateRect(31,123+35*(a-5),784,1,0xFFFFFF30,true) rect[a].visible = false end
for a = 10,35 do rect[a] = drawMgr:CreateRect(36+(a-10)*30,123,1,175,0xFFFFFF30,true) rect[a].visible = false end
rect[36] = drawMgr:CreateRect(0,124,1,174,0xFFFFFF70,true)
rect[36].visible = false
rect[37] = drawMgr:CreateRect(0,124,1,174,0xFFFFFF70,true)
rect[37].visible = false
rect[38] = drawMgr:CreateRect(0,0,29,34,0x000000ff,true)
rect[38].visible = false
for a = 39, 44 do rect[a] = drawMgr:CreateRect(31,89+35*(a-38),34,34,0x00000FF,true) rect[a].visible = false end
for a = 5, 10 do icon[a] = drawMgr:CreateRect(32,90+35*(a-4),32,32,0x000000FF) icon[a].visible = false end
icon[4] = drawMgr:CreateRect(32,90+35*5,32,32,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1"))
icon[4].visible = false
for a = 1,25 do textR[a] = drawMgr:CreateRect(0,0,29,34,0x000000ff,true) textR[a].visible = false end
for a = 1,25 do text[a] = drawMgr:CreateText(0,90, 0x000000ff, "",F16) text[a].visible = false end


function Tick(tick)

	if not IsIngame() or not SleepCheck() then return end
	
	local me = entityList:GetMyHero()
		
	if not me then return end
		
	if not table1[1] then
		local ability = me.abilities
		for a,spell in ipairs(ability) do			
			if not spell.hidden and not spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NOT_LEARNABLE) and spell.abilityData.maxLevel > 1 and spell.name ~= "nevermore_shadowraze3" and spell.name ~= "nevermore_shadowraze2"  then				
				table.insert(table1, spell)
			end			
		end
	else
		local point = me.abilityPoints		
		if point > 0 then
			local level = me.level
			for i,v in ipairs(table1) do		
				for a = 1,25 do
					if spellL[a] ~= 0 then
						if point == 1 then
							if level == spellS[a] and i == spellL[a] then
								local prev = SelectUnit(me)
								entityList:GetMyPlayer():LearnAbility(v)
								SelectBack(prev)
							end
						elseif point == 2 then
							if (level - 1) == spellS[a] and i == spellL[a] then
								local prev = SelectUnit(me)
								entityList:GetMyPlayer():LearnAbility(v)
								SelectBack(prev)
							end
						end
					end
				end
			end
		end
		
		if activated then		
	
			for a = 1, 3 do
				icon[a].visible = true			
			end		
			rect[36].x = 36+me:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel")*30
			rect[37].x = 36+(me:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel")+1)*30
			if me.classId == CDOTA_Unit_Hero_Invoker then
				icon[4].visible = true
			end
			for a = 1, 37 do
				rect[a].visible = true
			end

			if save then
				for a = 1,25 do
					table2[a] = spellS[a]..":"..spellL[a]
				end
				WriteLines(SCRIPT_PATH.."/config/"..me.name..".txt",table2)
				save = false
				RoshanSideMessage(me.name,"Save","Successful")			
			elseif loat then
				local lines = ReadLines(SCRIPT_PATH.."/config/"..me.name..".txt")
				for i,line in ipairs(lines) do
					table3 = split(lines[i],":")
					if table3[1] ~= nil and table3[2] ~= nil then
					spellS[i] = table3[1] + 0 spellL[i] = table3[2] + 0
					end
				end
				loat = false
				RoshanSideMessage(me.name,"Load","Successful")
			elseif cler then 
				for a = 1, 25 do
					spellL[a] = 0 spellS[a] = 0	
					for a = 1,25 do
						text[a].visible = false
						textR[a].visible = false
					end
				end
				cler = false
				RoshanSideMessage(me.name,"Clear","Successful")
			end		

			for a = 1,25 do
				if spellS[a] ~= 0 and spellS[a] ~= 0 then
					local b = spellL[a]
					local z = spellS[a]
					if b and z then
						if b==1 then col = 0x3399FFFF elseif b==2 then col = 0x00FFD5AA elseif b==3 then col = 0xFFFFFFFF elseif b==4 then col = 0xFF7676FF elseif b==5 then col = 0xFFFF66FF end
						text[a].visible = true
						text[a].x = 44+z*30
						text[a].y = 97+35*b
						text[a].color = col
						text[a].text = ""..z
						textR[a].visible = true
						textR[a].x = 37+z*30
						textR[a].y = 89+35*b
						textR[a].color = col
					end
				end
			end
			for i,v in ipairs(table1) do
				icon[i+4].visible = true
				icon[i+4].textureId = drawMgr:GetTextureId("NyanUI/spellicons/"..v.name)
				rect[i+38].visible = true
			end
					
		else	
			if rect[1].visible then
				for a = 1, 44 do
					rect[a].visible = false
				end				
				for a = 1,10 do
					icon[a].visible = false
				end
				for a = 1,25 do
					text[a].visible = false
					textR[a].visible = false
				end
			end		
		end
		
	end
	Sleep(250)
end

function Key(msg,code)

	if client.chat or not table1[1] then return end
	
	if IsKeyDown(toggleKey) then
		activated = not activated       
	end

	if activated then
	
		if msg == LBUTTON_DOWN then
			if IsMouseOnButton(139,99,18,18) then	
				save = true
			elseif IsMouseOnButton(169,99,18,18) then
				loat = true
			elseif IsMouseOnButton(199,99,18,18) then 
				cler = true
			else
				save,loat,cler = false,false,false
			end
		elseif msg ~= LBUTTON_UP then
			save,loat,cler = false,false,false
		end
	
		for a = 1, 25 do
			for i,v in ipairs(table1) do
				if IsMouseOnButton(31+a*30,89+35*i,32,32) then
					if msg == LBUTTON_DOWN then
						spellL[a] = i
						spellS[a] = a
						return true	
					elseif msg == RBUTTON_DOWN then
						spellL[a] = 0
						spellS[a] = 0
						text[a].visible = false
						textR[a].visible = false
						return true	
					end
				end
			end
		end			
	end
	
end

function ReadLines(sPath)
	local file = io.open(sPath, "r")
	if file then
		local tLines = {}
		for line in file:lines() do
			table.insert(tLines, line)
		end
		file.close()
		return tLines
	else
		WriteLines(sPath,{})
		return {}
	end
end

function WriteLines(sPath, tLines)
  local file = io.open(sPath, "w")
  if file then
	  local text = ""
	  local lastline = nil
	for _, sLine in ipairs(tLines) do
		text = text..sLine.."\n"
	end
	file:write(text)
	file:close()
	end
end

function RoshanSideMessage(hero,title,sms)
	local test = sideMessage:CreateMessage(200,60)	
	test:AddElement(drawMgr:CreateRect(5,5,80,50,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..hero:gsub("npc_dota_hero_",""))))
	test:AddElement(drawMgr:CreateText(90,3,-1,title,drawMgr:CreateFont("defaultFont","Arial",22,500)))
	test:AddElement(drawMgr:CreateText(100,25,-1,""..sms.."",drawMgr:CreateFont("defaultFont","Arial",25,500)))
end

function split(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function IsMouseOnButton(x,y,h,w)
        local mx = client.mouseScreenPosition.x
        local my = client.mouseScreenPosition.y
        return mx > x and mx <= x + w and my > y and my <= y + h
end

function GameClose()
	spellS = {} spellL = {} table1 = {} 
	table2= {} table3 = {}
	activated = false
	collectgarbage("collect")
end


script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
