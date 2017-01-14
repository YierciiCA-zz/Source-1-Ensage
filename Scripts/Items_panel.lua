--<<Displays the enemies inventory. d.l.>>
require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "I", config.TYPE_HOTKEY)
config:Load()

local key = config.Hotkey

local activated = true
local play = false
local item = {} local hero = {}
local xx = 50
local yy = 300
local clear = true
local move = false
local con = client.screenSize.x/1600
if con < 1 then	con = 1 end
local F12 = drawMgr:CreateFont("F11","Arial",12*con,500)
local F10 = drawMgr:CreateFont("F11","Arial",10*con,500)

function Tick(tick)

	if client.console or not SleepCheck() then return end

	Sleep(250)

	local me = entityList:GetMyHero()

	if not me then return end	

	if activated then clear = true

		if xx == 50 and yy == 300 then 
			LoadGUIConfig() 
		end

		if move then
			xx = client.mouseScreenPosition.x - 10 yy = client.mouseScreenPosition.y - 32 Clear()	
		end	

		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO ,illusion=false,team = (5-me.team)})
		--table.sort( enemies, function (a,b) return a.playerId < b.playerId end )

		for i,v in ipairs(enemies) do

			if not hero[i] then hero[i] = {}
				hero[i].he = drawMgr:CreateRect(xx+1*con, yy+26*i*con,18,18,0x000000D0)
			end

			hero[i].he.textureId = drawMgr:GetTextureId("NyanUI/miniheroes/"..v.name:gsub("npc_dota_hero_",""))	

			for c= 1, 7 do
				if not item[c] then item[c] = {} end
				if not hero[i].item then hero[i].item = {} end				

				if not hero[i].item[c] then hero[i].item[c] = {}		
					hero[i].item[c].bg = drawMgr:CreateRect(xx+26*c*con,yy+26*i*con,32*con,18*con,0x000000D0,drawMgr:GetTextureId("NyanUI/items/emptyitembg")) hero[i].item[c].bg.visible = true
					hero[i].item[c].ko = drawMgr:CreateRect(xx-1+26*c*con,yy-1+26*i*con,24*con,20*con,0xFFFFFF40,true) hero[i].item[c].ko.visible = true
					hero[i].item[c].txt = drawMgr:CreateText(xx+6+26*c*con,yy+4+26*i*con,0xFFFFFFff,"",F12) hero[i].item[c].txt.visible = false
					hero[i].item[c].rcr = drawMgr:CreateRect(xx+26*c*con,yy+26*i*con,22*con,18*con,0x00000030) hero[i].item[c].rcr.visible = false
					hero[i].item[c].charg = drawMgr:CreateText(xx+18+26*c*con,yy+9+26*i*con,0xFFFFFFff,"",F10) hero[i].item[c].charg.visible = false
				end	
				local Items = v:GetItem(c)
				if Items then
					if Items.recipe then
						hero[i].item[c].bg.textureId = drawMgr:GetTextureId("NyanUI/items/recipe")
					else
					
						hero[i].item[c].bg.textureId = drawMgr:GetTextureId("NyanUI/items/"..Items.name:gsub("item_",""))

						if Items.charges > 0 then
							hero[i].item[c].charg.text = ""..math.ceil(Items.charges) hero[i].item[c].charg.visible = true
						else
							hero[i].item[c].charg.visible = false
						end

						if Items.cd ~= 0 then
							local cd = math.ceil(Items.cd)
							hero[i].item[c].txt.text = ""..cd hero[i].item[c].txt.visible = true
							hero[i].item[c].rcr.color  = 0xA1A4A120 hero[i].item[c].rcr.visible = true						
						elseif Items.state == LuaEntityAbility.STATE_NOMANA then					
							hero[i].item[c].rcr.color  = 0x047AFF20 hero[i].item[c].rcr.visible = true
							hero[i].item[c].txt.visible = false
						elseif hero[i].item[c].rcr.visible then
							hero[i].item[c].rcr.visible = false
							hero[i].item[c].txt.visible = false
						end
					end					
				elseif hero[i].item[c].rcr.visible then
					hero[i].item[c].bg.textureId = drawMgr:GetTextureId("NyanUI/items/emptyitembg")
					hero[i].item[c].charg.visible = false
					hero[i].item[c].txt.visible = false
					hero[i].item[c].rcr.visible = false					
				end				
			end	
		end
		
	else
		if clear then
			Clear()
			clear = false
		end
	end

end

function Key(msg,code)

	if not client.chat then

		if IsKeyDown(key) then
			activated = not activated
		end

		if activated then
			if msg == LBUTTON_UP then
				if IsMouseOnButton(xx+1, yy+26*1*con,20,20) then      
					move = not move
					SaveGUIConfig()
				end
			end
		end
	end

end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end
 
function SaveGUIConfig()
	local file = io.open(SCRIPT_PATH.."/ItemPanelConfig.txt", "w+")
	if file then
		file:write(xx.."\n"..yy)
		file:close()
	end
end
 
function LoadGUIConfig()
	local file = io.open(SCRIPT_PATH.."/ItemPanelConfig.txt", "r")
	if file then
		xx, yy = file:read("*number", "*number")
		file:close()   
	end
	if not xx then 
		xx = 50
		yy = 300
	end
end

function Clear()
	item = {} hero = {}
	collectgarbage("collect")
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
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
	Clear()
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
