require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Animations")
require("libs.Skillshot")

-- Config --
local config = ScriptConfig.new()
config:SetParameter("Chase", "S", config.TYPE_HOTKEY)
config:SetParameter("AutoReplicate", "F", config.TYPE_HOTKEY)
config:SetParameter("ReplicateHPcent", 35)
config:Load()

local ChaseKey = config.Chase
local toggleKey = config.AutoReplicate
local myhp = config.ReplicateHPcent

-- Globals --
local reg = false
local victim = nil
local target = nil
local sleep = 0
local attack = 0
local move = 0
local start = false
local reset = nil
local active = false
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(-20*monitor,80*monitor,-1,"Targeting",F14) statusText.visible = false
local toggleText  = drawMgr:CreateText(10*monitor,460*monitor,-1,"(" .. string.char(toggleKey) .. ") AutoReplicate: On",F14) toggleText.visible = false
local me = entityList:GetMyHero()

-- Load --
function Load()
    if PlayingGame() then
        if entityList:GetMyHero().classId ~= CDOTA_Unit_Hero_Morphling then 
            script:Disable() 
        else
            reg = true
            victim = nil
            start = false
            sleep = 0
            reset = nil
            target = nil
            active = true
            toggleText.visible = true
            script:RegisterEvent(EVENT_KEY,Key)
            script:RegisterEvent(EVENT_TICK,Tick)
            script:UnregisterEvent(Load)
        end
    end
end

-- Key --
function Key(msg,code)
	if not PlayingGame() or client.chat then return end	
	if IsKeyDown(toggleKey) and SleepCheck("toggle") then
		active = not active
        Sleep(200, "toggle")
		if active then
			toggleText.text = "(" .. string.char(toggleKey) .. ") AutoReplicate: On"
		else
			toggleText.text = "(" .. string.char(toggleKey) .. ") AutoReplicate: Off"
		end
	end
end

-- Hotkey Text --
local hotkeyText
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

-- Main --
function Tick(tick)
    local me = entityList:GetMyHero()
    if not me then return end
    local attackRange = me.attackRange
    
    if victim and victim.visible then
        if not statusText.visible then
            statusText.visible = true
        end
    else
        statusText.visible = false
    end
    
    if active then
        local R = me:GetAbility(6)
        local hp = myhp*0.01
        
        if R.name == "morphling_morph_replicate" and R.cd == 0 and me:CanCast() and me.health/me.maxHealth < hp then
            me:CastAbility(R)
        end
    end
            
    if IsKeyDown(ChaseKey) and not client.chat then
        if Animations.CanMove(me) or not start or (victim and GetDistance2D(victim,me) > attackRange+1000) then
            start = true
            local MouseOver = targetFind:GetClosestToMouse(500)
            if MouseOver and (not victim or GetDistance2D(me,victim) > attackRange or not victim.alive) and SleepCheck("victim") then            
                victim = MouseOver
                statusText.entity = victim
                statusText.entityPosition = Vector(0,0,victim.healthbarOffset)
                Sleep(250,"victim")
            end
        end
        if not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 1000 then
            if tick > attack and SleepCheck("casting") then
                if victim.hero then
                    local Q = me:GetAbility(1)
                    local W = me:GetAbility(2)
                    local Winc = {600,700,800,900}                    
                    local R = me:GetAbility(5)
                    local distance = GetDistance2D(me,victim)
                    local eblade = me:FindItem("item_ethereal_blade")
                    local ethereal = (victim:DoesHaveModifier("modifier_item_ethereal_blade_ethereal") or victim:DoesHaveModifier("modifier_pugna_decrepify") or victim:DoesHaveModifier("modifier_item_ghost_scepter"))

                    if W and W.level > 0 then
                        Wrange = Winc[W.level]
                    end
                    
                    
                    if Q and Q.cd == 0 and me:CanCast() and distance <= 950 then
                    	me:CastAbility(Q,victim.position)
		        Sleep((Q:FindCastPoint()*1000)+(me:GetTurnTime(victim)*1000),"casting")
                    end
                    
                    if eblade and eblade.cd == 0 and me:CanCast() and distance <= 750 then
                        me:CastAbility(eblade,victim)
                        Sleep(me:GetTurnTime(victim)*1000,"casting")
                    end
                    
                    if W and W.cd == 0 and me:CanCast() and distance <= Wrange then
                        if (eblade and victim:IsAttackImmune() == true) then
                            me:CastAbility(W,victim)
                            Sleep(me:GetTurnTime(victim)*1000,"casting")
                        elseif not eblade or (eblade and eblade.cd ~= 0 and victim:IsAttackImmune() == false) then
                            me:CastAbility(W,victim)
                            Sleep(me:GetTurnTime(victim)*1000,"casting")
                        end
                    end               
                end
                if victim:IsAttackImmune() == true then
                    me:Move(client.mousePosition)
                else
                    me:Attack(victim)
                end
                attack = Animations.maxCount/1.5
            end
        elseif tick > move and SleepCheck("casting") then
            me:Move(client.mousePosition)
            move = Animations.maxCount/1.5
            start = false
        end
    elseif victim then
        if not reset then
            reset = client.gameTime
        elseif (client.gameTime - reset) >= 3 then
            victim = nil
        end
        start = false
    end
end

-- Close --
function GameClose()
    collectgarbage("collect")
    if reg then
        reg = false
        statusText.visible = false
        quillText.visible = false
        activ = false
        victim = nil
        start = false
        reset = nil
        target = nil
        script:UnregisterEvent(Tick)
        script:UnregisterEvent(Key)
        script:RegisterEvent(EVENT_TICK,Load)
    end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
