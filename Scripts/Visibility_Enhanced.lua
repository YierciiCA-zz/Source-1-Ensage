--<<Visibility_Enhanced script by Zanko version 1.0b>>
--[[
    -------------------------------------
    | Visibility_Enhanced Script by Zanko |
    -------------------------------------
    =========== Version 1.0b ===========
    Description:
    ------------
        Enhanced version of visible by enemy. Set in config files what to reveal.
        
    Change log:
    ----------
		Version 1.0b - 25th February 2015 2:22PM:
            - Fixed config duplication bug
			
        Version 1.0a - 25th February 2015 1:00PM:
            - Fixed effect given to unspawned creeps
            - Includes Utils
            
        Version 1.0 - 24th February 2015 3:18PM:
            - Initial release.
]]--
require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("Self", true)
config:SetParameter("Allies", true)
config:SetParameter("Neutral", true)
config:SetParameter("Courier", true)
config:SetParameter("Mines", true)
config:SetParameter("Creep", true)
config:SetParameter("Ward", true)
config:SetParameter("Building", true)
config:SetParameter("SummonMisc", true)

-- Not yet supported --
config:SetParameter("VisibleRoshan", false)
config:SetParameter("VisibleRune", false)
config:Load()

Visible_Self = config.Self
Visible_Allies = config.Allies
Visible_Neutral = config.Neutral
Visible_Courier = config.Courier
Visible_Mines = config.Mines
Visible_Creep = config.Creep
Visible_Ward = config.Ward
Visible_Summon_Misc = config.SummonMisc
Visible_Building = config.Building

-- Not yet supported --
local Visible_Rune = config.VisibleRune
local Visible_Roshan = config.VisibleRoshan



local visibilityEffect = {}

function Tick(tick)
    currentTick = tick

    if not client.connected or client.loading or not PlayingGame() or client.console or not SleepCheck("stop") then return end
    if sleepTick and sleepTick > tick then return end

    Sleep(200)
    local me = entityList:GetMyHero()
    
    if Visible_Self then
        drawEffect(me, "aura_shivas")
    end

    if Visible_Allies then
        local hero = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = me.team})
        for _,v in ipairs(hero) do 
            drawEffect(v, "aura_shivas")
        end
    end
    
    if Visible_Neutral then
        local neutral = entityList:FindEntities({classId = CDOTA_BaseNPC_Creep_Neutral})    
        for _,v in ipairs(neutral) do 
            if v.spawned then
                drawEffect(v, "aura_shivas")
            end
        end
    end
    
    
    if Visible_Courier then
        local courier = entityList:FindEntities({classId = CDOTA_Unit_Courier, team = me.team})    
        for _,v in ipairs(courier) do 
            drawEffect(v, "aura_shivas")
        end
    end
    
    if Visible_Creep then
        local creep = entityList:FindEntities({classId = CDOTA_BaseNPC_Creep_Lane, team = me.team})
        for _,v in ipairs(creep) do 
            if v.spawned then
                drawEffect(v, "aura_shivas")
            end
        end
    end
    
    if Visible_Ward then
        local observerWard = entityList:GetEntities({classId = CDOTA_NPC_Observer_Ward, team = me.team})
        for _,v in ipairs(observerWard) do 
            drawEffect(v, "aura_shivas")
        end
        
        local sentryWard = entityList:GetEntities({classId = CDOTA_NPC_Observer_Ward_TrueSight, team = me.team})
        for _,v in ipairs(sentryWard) do 
            drawEffect(v, "aura_shivas")
        end
    end
    
    if Visible_Mines then
        local mines = entityList:GetEntities({classId = CDOTA_NPC_TechiesMines, team = me.team})
        for _,v in ipairs(mines) do 
            drawEffect(v, "aura_shivas")
        end
    end
    
    if Visible_Building then
        local building = entityList:GetEntities({classId = CDOTA_BaseNPC_Building, team = me.team})
        for _,v in ipairs(building) do 
            drawEffect(v, "mjollnir_shield")
        end
        
        local tower = entityList:GetEntities({classId = CDOTA_BaseNPC_Tower, team = me.team})
        for _,v in ipairs(tower) do 
            drawEffect(v, "mjollnir_shield")
        end
        
        local barracks = entityList:GetEntities({classId = CDOTA_BaseNPC_Barracks, team = me.team})
        for _,v in ipairs(barracks) do 
            drawEffect(v, "mjollnir_shield")
        end
    end
    
    if Visible_Summon_Misc then
        local broodSpiderling = entityList:GetEntities({classId = CDOTA_Unit_Broodmother_Spiderling, team = me.team})
        for _,v in ipairs(broodSpiderling) do 
            drawEffect(v, "aura_shivas")
        end
    
        local beastBeast = entityList:GetEntities({classId = CDOTA_Unit_Hero_Beastmaster_Beasts, team = me.team})
        for _,v in ipairs(beastBeast) do 
            drawEffect(v, "aura_shivas")
        end
        
        local beastBoar = entityList:GetEntities({classId = CDOTA_Unit_Hero_Beastmaster_Boar, team = me.team})
        for _,v in ipairs(beastBoar) do 
            drawEffect(v, "aura_shivas")
        end
        
        local beastHawk = entityList:GetEntities({classId = CDOTA_Unit_Hero_Beastmaster_Hawk, team = me.team})
        for _,v in ipairs(beastHawk) do 
            drawEffect(v, "aura_shivas")
        end
        
        local shadowShamanWard = entityList:GetEntities({classId = CDOTA_BaseNPC_ShadowShaman_SerpentWard, team = me.team})
        for _,v in ipairs(shadowShamanWard) do 
            drawEffect(v, "aura_shivas")
        end
        
        local venomancerWard = entityList:GetEntities({classId = CDOTA_BaseNPC_Venomancer_PlagueWard, team = me.team})
        for _,v in ipairs(venomancerWard) do 
            drawEffect(v, "aura_shivas")
        end
        
        local invokerForged = entityList:GetEntities({classId = CDOTA_BaseNPC_Invoker_Forged_Spirit, team = me.team})
        for _,v in ipairs(invokerForged) do 
            drawEffect(v, "aura_shivas")
        end

        -- Mirana Arrow
        -- Invoker Sunstrike
        -- Rocket Flare
        -- etc.
        local misc = entityList:GetEntities({classId = CDOTA_BaseNPC, team = me.team})
        for _,v in ipairs(misc) do
            drawEffect(v, "aura_shivas")
        end
        
        -- Juggernaut Healing
        -- Beastmaster Axe
        -- Invoker Sunstrike
        -- Invoker Tornado
        -- etc.
        local misc_extra = entityList:GetEntities({classId = CDOTA_BaseNPC_Additive, team = me.team})
        for _,v in ipairs(misc_extra) do
            drawEffect(v, "aura_shivas")
        end
    end
    
    -- Not yet supported --
    if Visible_Roshan then
        local roshan = entityList:GetEntities({classId = CDOTA_Unit_Roshan})    
        for _,v in ipairs(roshan) do 
            drawEffect(v, "aura_shivas")
        end
    end
    
    if Visible_Rune then
        local rune = entityList:GetEntities({classId = CDOTA_Item_Rune})    
        for _,v in ipairs(rune) do 
            drawEffect(v, "aura_shivas")
        end
    end

    
end

function Sleep(duration)
    sleepTick = currentTick + duration
end

function drawEffect(object, effectName)
    if object ~= nil then
        local onScreen = client:ScreenPosition(object.position)
        if onScreen and object.alive and object.visibleToEnemy then
            if not visibilityEffect[object.handle] then
                visibilityEffect[object.handle] = Effect(object, effectName)
                visibilityEffect[object.handle]:SetVector(1, Vector(0,0,0))
            end
        else
            if visibilityEffect[object.handle] then
                visibilityEffect[object.handle] = nil
                collectgarbage("collect")
            end
        end
    end
end

function GameClose()
    sleepTick = 0
    visibilityEffect = {}
    collectgarbage("collect")
end


script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_CLOSE,GameClose)