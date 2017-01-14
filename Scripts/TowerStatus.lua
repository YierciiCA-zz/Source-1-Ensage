--<<Tower Health Display - DON'T USE UNLESS GIVEN PERMISSION>>
--[[
                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
			   THIS IS AN EARLY BETA, THERE WILL MOST LIKELY BE BUGS
											 
                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬● 
]]--
--Libraries 
require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Text X", 5)
config:SetParameter("Text Y", 100)
config:Load()

local registered	= false

-- Initial Config of only 40 billion variables --
toptower = nil
midtower = nil
bottower = nil
newtop = false
newmid = false
newbot = false
Tlasthealth = nil
Thit = false
TresetTick = nil
initnewtop = false
Mlasthealth = nil
Mhit = false
MresetTick = nil
initnewmid = false
Blasthealth = nil
Bhit = false
BresetTick = nil
initnewbot = false


-- Icon Stuff --
local x,y = config:GetParameter("Text X"), config:GetParameter("Text Y")
local Font = drawMgr:CreateFont("Trees are awesome","Segue UI",12,500)

local topbg = drawMgr:CreateRect(x-5, y-5, 256, 34, 0x454545FF) topbg.visible = false
local topblk2 = drawMgr:CreateRect(x+44, y+17, 201, 4, 0x000000FF) topblk2.visible = false
local topblk = drawMgr:CreateRect(x+45, y+18, 200, 3, 0x000000FF) topblk.visible = false
local topdmg = drawMgr:CreateRect(x+45, y+18, 155, 3, 0x9E0209FF) topdmg.visible = false
local top = drawMgr:CreateRect(x+45, y+18, 150, 3, 0x47B541FF) top.visible = false
local toptext = drawMgr:CreateText(x+45, y+2,0x9BF598FF,"TOP TOWER UNDER ATTACK!                    ",Font) toptext.visible = false

local midbg = drawMgr:CreateRect(x-5, y+35, 256, 34, 0x454545FF) midbg.visible = false
local midblk2 = drawMgr:CreateRect(x+44, y+57, 201, 4, 0x000000FF) midblk2.visible = false
local midblk = drawMgr:CreateRect(x+45, y+58, 200, 3, 0x000000FF) midblk.visible = false
local middmg = drawMgr:CreateRect(x+45, y+58, 155, 3, 0x9E0209FF) middmg.visible = false
local mid = drawMgr:CreateRect(x+45, y+58, 150, 3, 0x47B541FF) mid.visible = false
local midtext = drawMgr:CreateText(x+45, y+42,0x9BF598FF,"MID TOWER UNDER ATTACK!                    ",Font) midtext.visible = false

local botbg = drawMgr:CreateRect(x-5, y+75, 256, 34, 0x454545FF) botbg.visible = false
local botblk2 = drawMgr:CreateRect(x+44, y+97, 201, 4, 0x000000FF) botblk2.visible = false
local botblk = drawMgr:CreateRect(x+45, y+98, 200, 3, 0x000000FF) botblk.visible = false
local botdmg = drawMgr:CreateRect(x+45, y+98, 155, 3, 0x9E0209FF) botdmg.visible = false
local bot = drawMgr:CreateRect(x+45, y+98, 150, 3, 0x47B541FF) bot.visible = false
local bottext = drawMgr:CreateText(x+45,y+82,0x9BF598FF,"BOT TOWER UNDER ATTACK!                    ",Font) bottext.visible = false

function onLoad()
	if PlayingGame() then
		registered = true
		script:RegisterEvent(EVENT_TICK,Main)		
		script:UnregisterEvent(onLoad)
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	local mp = entityList:GetMyPlayer()
	if not me then return end
	
	if (midtower == nil or toptower == nil or bottower == nil) then
	    FindTowers()
	end
	
	if midtower then
	    if midtower.alive then
		    MidTowers()
		else
		   initnewmid = true
		   midtower = nil
		end
    end
	
	if toptower then
	    if toptower.alive then
		    TopTowers()
		else
		   initnewtop = true
		   toptower = nil
		end
    end
	
	if bottower then
	    if bottower.alive then
		    BotTowers()
		else
		   initnewbot = true
		   bottower = nil
		end
    end
	

end

function FindTowers()
    local me = entityList:GetMyHero()
    local towers = entityList:FindEntities({type = 2,classId = 323,team = me.team, alive=true})
	
	for i,v in ipairs(towers) do
	    if not v:DoesHaveModifier("modifier_invulnerable") then
	        if not toptower and (v.position.x < -5500 or v.position.y > 5500) then 
	    	    toptower = v
	    	elseif not bottower and (v.position.y < -5500 or v.position.x > 5500) then
	            bottower = v
		    elseif not midtower and (v.position.y > -5500 and v.position.x < 5500 and v.position.x > -5500 and v.position.y < 5500) then
		        midtower = v
            end
		end
	end
end

function TopTowers()
    local hp = toptower.health
	local maxhp = toptower.maxHealth
	local health = math.floor((hp/maxhp)*100)
	
	if initnewtop then 
	    Tlasthealth = nil
	    Thit = false
	    TresetTick = nil
        topbg.visible = false
		top.visible = false
		topblk.visible = false
	    topblk2.visible = false
	    topdmg.visible = false
	    toptext.visible = false
	    collectgarbage("collect")
		initnewtop = false
		return
	end
	
    if toptower and not Tlasthealth then
	    Tlasthealth = hp
    elseif Tlasthealth then
	
	    if hp < Tlasthealth then
		    Thit = true
			TresetTick = nil
		end
		
		if Tlasthealth == hp and not TresetTick then
		    TresetTick = client.gameTime
		elseif TresetTick then 
		    if client.gameTime > TresetTick + 10 then
			    Thit = false
			end
		end
		    
		if Thit == true then
		    Tlasthealth = nil
		   	topbg.visible = true
			top.visible = true
			topblk.visible = true
			topblk2.visible = true
			topdmg.visible = true
			toptext.visible = true
			toptext.text = "TOP TOWER UNDER ATTACK!                   "..(health).."%"
			top.w = 200*(hp/maxhp)
			if SleepCheck("Tdelay") and topdmg.visible then
		        topdmg.w = 200*(hp/maxhp)
				Sleep(1000,"Tdelay")
			end
		elseif Thit == false then
		   	topbg.visible = false
			top.visible = false
			topblk.visible = false
			topblk2.visible = false
			topdmg.visible = false
			toptext.visible = false
			collectgarbage("collect")
		end
		
    end
	
	if hp/maxhp > 0.75 then
	    toptext.color = 0x9BF598FF
	elseif hp/maxhp > 0.50 then
	    toptext.color = 0xF2F280FF
	elseif hp/maxhp > 0.25 then
	    toptext.color = 0xED9F4CFF
	elseif hp/maxhp > 0 then
	    toptext.color = 0xF25A5AFF
	end
	
end

function MidTowers()
    local hp = midtower.health
	local maxhp = midtower.maxHealth
	local health = math.floor((hp/maxhp)*100)
	
	if initnewmid then 
	    Mlasthealth = nil
	    Mhit = false
	    MresetTick = nil
        midbg.visible = false
		mid.visible = false
		midblk.visible = false
	    midblk2.visible = false
	    middmg.visible = false
	    midtext.visible = false
	    collectgarbage("collect")
		initnewmid = false
		return
	end
	
    if midtower and not Mlasthealth then
	    Mlasthealth = hp
    elseif Mlasthealth then
	
	    if hp < Mlasthealth then
		    Mhit = true
			MresetTick = nil
		end
		
		if Mlasthealth == hp and not MresetTick then
		    MresetTick = client.gameTime
		elseif MresetTick then 
		    if client.gameTime > MresetTick + 10 then
			    Mhit = false
			end
		end
		    
		if Mhit == true then
		    Mlasthealth = nil
		   	midbg.visible = true
			mid.visible = true
			midblk.visible = true
			midblk2.visible = true
			middmg.visible = true
			midtext.visible = true
			midtext.text = "MID TOWER UNDER ATTACK!                   "..(health).."%"
			mid.w = 200*(hp/maxhp)
			if SleepCheck("Mdelay") and middmg.visible then
		        middmg.w = 200*(hp/maxhp)
				Sleep(1000,"Mdelay")
			end
		elseif Mhit == false then
		   	midbg.visible = false
			mid.visible = false
			midblk.visible = false
			midblk2.visible = false
			middmg.visible = false
			midtext.visible = false
			collectgarbage("collect")
		end
		
    end
	
	if hp/maxhp > 0.75 then
	    midtext.color = 0x9BF598FF
	elseif hp/maxhp > 0.50 then
	    midtext.color = 0xF2F280FF
	elseif hp/maxhp > 0.25 then
	    midtext.color = 0xED9F4CFF
	elseif hp/maxhp > 0 then
	    midtext.color = 0xF25A5AFF
	end
	
end

function BotTowers()
    local hp = bottower.health
	local maxhp = bottower.maxHealth
	local health = math.floor((hp/maxhp)*100)
	
	if initnewbot then 
	    Blasthealth = nil
	    Bhit = false
	    BresetTick = nil
        botbg.visible = false
		bot.visible = false
		botblk.visible = false
	    botblk2.visible = false
	    botdmg.visible = false
	    bottext.visible = false
	    collectgarbage("collect")
		initnewbot = false
		return
	end
	
    if bottower and not Blasthealth then
	    Blasthealth = hp
    elseif Blasthealth then
	
	    if hp < Blasthealth then
		    Bhit = true
			BresetTick = nil
		end
		
		if Blasthealth == hp and not BresetTick then
		    BresetTick = client.gameTime
		elseif BresetTick then 
		    if client.gameTime > BresetTick + 10 then
			    Bhit = false
			end
		end
		    
		if Bhit == true then
		    Blasthealth = nil
		   	botbg.visible = true
			bot.visible = true
			botblk.visible = true
			botblk2.visible = true
			botdmg.visible = true
			bottext.visible = true
			bottext.text = "BOT TOWER UNDER ATTACK!                   "..(health).."%"
			bot.w = 200*(hp/maxhp)
			if SleepCheck("Bdelay") and botdmg.visible then
		        botdmg.w = 200*(hp/maxhp)
				Sleep(1000,"Bdelay")
			end
		elseif Bhit == false then
		   	botbg.visible = false
			bot.visible = false
			botblk.visible = false
			botblk2.visible = false
			botdmg.visible = false
			bottext.visible = false
			collectgarbage("collect")
		end
		
    end
	
	if hp/maxhp > 0.75 then
	    bottext.color = 0x9BF598FF
	elseif hp/maxhp > 0.50 then
	    bottext.color = 0xF2F280FF
	elseif hp/maxhp > 0.25 then
	    bottext.color = 0xED9F4CFF
	elseif hp/maxhp > 0 then
	    bottext.color = 0xF25A5AFF
	end
	
end

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK,onLoad)
		registered = false
		toptower = nil
        midtower = nil
        bottower = nil
        newtop = false
        newmid = false
		newbot = false
	    Tlasthealth = nil
	    Thit = false
	    TresetTick = nil
        topbg.visible = false
		top.visible = false
		topblk.visible = false
	    topblk2.visible = false
	    topdmg.visible = false
	    toptext.visible = false
		initnewtop = false
	    Mlasthealth = nil
	    Mhit = false
	    MresetTick = nil
        midbg.visible = false
		mid.visible = false
		midblk.visible = false
	    midblk2.visible = false
	    middmg.visible = false
	    midtext.visible = false
		initnewmid = false
	    Blasthealth = nil
	    Bhit = false
	    BresetTick = nil
        botbg.visible = false
		bot.visible = false
		botblk.visible = false
	    botblk2.visible = false
	    botdmg.visible = false
	    bottext.visible = false
		initnewbot = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
