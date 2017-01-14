--<<Crystal Maiden Combo | Tutorial for new scripters>>
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
--
-- Welcome to one of my various DOTO scripts, if you enjoy it please leave a thanks on my thread :) 
--
--            This script is a combo script that will Shadow Amulet ➪ Blink ➪ Ult (Default: D)
--                                      - Blink's to your mouse position
--                                      - Press S to cancel
--
--                                      - Works with ShadowBlade 
--
--                           If you have a suggestion or need help, please PM me 
--                          This script was made with full comments for learners :)
--
--                                   And again, thanks for using my script!
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬● 
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Libraries (All of them explain their use on their relevant pages, but as a short description, it allows us to easily do actions with a script)  
require("libs.Utils")  -- Honestly, just go here - https://github.com/Rulfy/ensage-wip/blob/master/Libraries/Utils.lua and read all the functions.
require("libs.ScriptConfig") --This one is so I can set a hotkey and the user can easily change it on Ensage

--Config -- Just copy it and change the keys, you can also have things like TYPE_NUMBER (Good for changing a delay, or text position for example)
config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY) 
config:SetParameter("StopKey", "S", config.TYPE_HOTKEY) 
config:Load()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Some variables we gotta set (Well we don't have to, just makes our lives easier) 
local ComboKey     = config.ComboKey   -- So when we refer to our key we can just say "ComboKey", rather than config.ComboKey everytime
local StopKey      = config.StopKey    -- If we want to cancel the combo
local active	   = false             --Initially the Combo will not be active until we press a hotkey

local registered   = false            --Used when closing and opening the script 

--We don't really need these this time, but 90% of the time they are really useful :)
local range 	= 1200                 --The range of our script, lets just make it the blink dagger range for this example
local target    = nil                  --Initially there should be no target unless we try to find one

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--TEXT INGAME (If you wanna set the location of the text then change the numbers on the line under this one)
local x,y = 1350, 50  -- x = x axis || y = y axis 
local monitor = client.screenSize.x/1600
local font = drawMgr:CreateFont("font","Verdana",12,300)  --CreateFont(name, fontname, tall, weight)

local statusText = drawMgr:CreateText(x*monitor,y*monitor,0x5DF5F5FF,"Crystal Maiden Combo || Press " .. string.char(ComboKey) .. " ||",font) statusText.visible = false
--CreateText(x, y, colour, text, font) 
--If you just want white text then you can just put -1 for colour, to do a colour the format is 0x#######FF  Where #'s is HTML colour code. 0F at end makes text transparent.
--The text is initially OFF 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--When the script loads up, this happens
function onLoad()
	if PlayingGame() then  --if I'm playing the game then... (Note this PlayingGame() function comes from Utils)
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_CrystalMaiden then 
			script:Disable()
		else
			registered = true
			statusText.visible = true   --The text is now ENABLED because we are playing, and I am Crystal Maiden
			script:RegisterEvent(EVENT_TICK,Main)  --This assigns the game tick to function Main(tick)
			script:RegisterEvent(EVENT_KEY,Key)   --This assigns keys to function Key
			script:UnregisterEvent(onLoad)  --Unregisters this function so it doesn't keep checking once you are registered. More details at bottom of page.
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--What pressing a key does
function Key(msg,code)
	if client.chat or client.console or client.loading then return end --Just so talking on chat for example doesn't set off your hotkeys
	
	if code == ComboKey then  -- If I press D then my script is "Active"
		active = true                       
	end
	
	if code == StopKey then     -- If I press S then my script is not "Active"
		active = false                   
	end
	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Now that we've sorted out all the initiation stuff, let's get into the actual script 


function Main(tick)  --The tick is a function that is run constantly
    if not SleepCheck() then return end

    local me = entityList:GetMyHero() --Gets my hero, useful for getting a lot of information
    if not me then return end  --If the player is not me, then the tick function would end here.
	
--Now lets get what we need for the Combo (Note, all of these use "me")
    local SA = me:FindItem("item_shadow_amulet")
    local SB = me:FindItem("item_invis_sword") --Shadow Blade
    local Blink = me:FindItem("item_blink")
    local Ult = me:GetAbility(4)
    local SAModif = me:FindModifier("modifier_item_shadow_amulet_fade") -- Modifier for Shadow Amulet, you see how I use it in a bit

	
--Now the actual Combo
    if active then --If I've pressed the ComboKey, then this is true, as soon as I press the StopKey, this becomes false and stops the combo :)
	
        if me.alive and SA and SA:CanBeCasted() and not SAModif then -- If I don't have the Shadow Amulet modifier then I'll cast Shadow Amulet
	        me:CastAbility(SA,me)
			Sleep(100) --It's a good idea to add some Sleep after every action to reduce lag.
	    	return
    	end
	
    	if me.alive and SAModif.elapsedTime >= (0.90 - (me:GetTurnTime(client.mousePosition))) then --If Shadow Amulet fade has been active for 0.9 seconds, minus turn time
	        me:SafeCastAbility(Blink, client.mousePosition) --Blink to mouse position                 --SafeCasting checks if it can be casted, if not then it skips it.
	    	me:SafeCastAbility(Ult,true) --True makes it only cast ult after it has blinked           --SafeCasting checks if it can be casted, if not then it skips it.
			active = false -- It's important do to this, otherwise the script will still be active and keep doing the combo
	    	return
	end 
	
	if me.alive and SB then
	        me:SafeCastAbility(Blink, client.mousePosition) --Blink to mouse position                 --SafeCasting checks if it can be casted, if not then it skips it.
	    	me:SafeCastAbility(Ult,true) --True makes it only cast ult after it has blinked           --SafeCasting checks if it can be casted, if not then it skips it.
		me:SafeCastAbility(SB,true)	
			active = false -- It's important do to this, otherwise the script will still be active and keep doing the combo
	    	return	
	end
    end
	
end

--       Information
--[[ 

  The reason why true only makes one cast after another is because it SHIFT queues the actions,
  if I were to use false then it would do the opposite and act immediately even if the player is,
  holding shift. It deletes the current queue and just acts.]]
  

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Here you would normally put functions which you can use otherwise, like say a "function FindTarget()" then put it under "if active" in the main tick.
--You could also just make all your combo's functions of their own, it's really up to how you want to lay it out.
--This example script was to show you a non entity target related script 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--When the game ends
function onClose()
	collectgarbage("collect")
	if registered then
	    statusText.visible = false --Make sure to turn your status text off after script closes
            script:UnregisterEvent(Main)
    	    script:UnregisterEvent(Key)
    	    script:RegisterEvent(EVENT_TICK,onLoad) --Reregistering tick back to onLoad for next game.
	    registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose) 
script:RegisterEvent(EVENT_TICK,onLoad) -- At the beginning TICK is assigned to onload (to keep checking until registered)
