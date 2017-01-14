--<<Maximum_Blink script by Zanko version 1.0>>
--[[
    -------------------------------------
    | Maximum_Blink Script by Zanko |
    -------------------------------------
    =========== Version 1.0 ===========
    Description:
    ------------
        According to Dota 2 Mechanics, ""When targeting beyond the max blink distance, it blinks for 960 range towards the targeted direction, instead of 1200."
        This script will ensure that you will blink 1200 units even if you target beyond the maximum distance.
        
    Change log:
    ----------
        Version 1.0a - 18th March 2015 1:20AM:
            - User can now choose whether the hot key should include ALT key
            - User can now choose whether the script will operate as quickcast or not (Thanks Nova)
        Version 1.0 - 18th March 2015 3:18PM:
            - Initial release.
]]--
require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("BlinkRange", true)
config:SetParameter("AltKey", true)
config:SetParameter("Quickcast", false)
config:SetParameter("BlinkKey", 65, config.TYPE_HOTKEY) -- "A"
config:Load()
Blink_Range = config.BlinkRange
Qckcast = config.Quickcast
Blink_Key = config.BlinkKey
ALT_Key = config.AltKey

local rangeEffect = {}
local blinkHotKey = Blink_Key
local ALT = ALT_Key
local isQuickCast = Qckcast
local keyPressed = nil

function Key(msg, code)
    if ALT then
        keyPressed = IsKeyDown(18) and code == blinkHotKey
    else
        keyPressed = code == blinkHotKey
    end
    if keyPressed then
        aiming = true  --Now I know that the user is aiming with the spell
        if isQuickCast == true then
            active = true
        end
    end

    if aiming and msg == RBUTTON_DOWN then --If I right click to cancel or move
        aiming = false
    end

    if aiming and msg == LBUTTON_DOWN then --If I left click to use the spell 
        active = true
        return true -- Wont go through dota
    end
end

function Tick(tick)
    
    currentTick = tick
    if not client.connected or client.loading or not PlayingGame() or client.console or not SleepCheck("stop") then return end
    if sleepTick and sleepTick > tick then return end

    local me = entityList:GetMyHero()
    
    if not rangeEffect[me.handle] then
        rangeEffect[me.handle] = Effect(me,"range_display")
    end
    if IsKeyDown(18) and Blink_Range then
        rangeEffect[me.handle]:SetVector(1, Vector(1200,0,0))
    else 
        if  rangeEffect[me.handle] then
            rangeEffect[me.handle] = nil
            collectgarbage("collect")
        end
    end
    --[[for i = 1,6 do
        local item = me:GetItem(i)
        if item ~= nil then
            if item.name == "item_blink" then
                local e = client:GetKeyBinding("dota_item_execute " .. i - 1)
                print(e)
            end
        end
        
    end]]
    if active then
        local blink = me:FindItem("item_blink")
        if blink then
            local distance = math.sqrt(math.pow(client.mousePosition.x - me.position.x, 2) + math.pow(client.mousePosition.y - me.position.y, 2))
            if (distance > 0) then
                if (distance > 1200) and blink.cd == 0 then
                    local expectedY = ((client.mousePosition.y - me.position.y) / distance) * 1199 + me.position.y
                    local expectedX = ((client.mousePosition.x - me.position.x) / distance) * 1199 + me.position.x
                    local blinkPosition = Vector(expectedX, expectedY, 0)
                    me:CastAbility(blink, blinkPosition)
                else
                    me:CastAbility(blink, Vector(client.mousePosition.x, client.mousePosition.y, 0))
                end
                aiming = false
                active = false
            end
        end
    end
    Sleep(50)
end

function Sleep(duration)
    sleepTick = currentTick + duration
end

function GameClose()
    sleepTick = 0
    rangeEffect = {}
    collectgarbage("collect")
end


script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_KEY,Key)