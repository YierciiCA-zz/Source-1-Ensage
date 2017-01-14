require("libs.ScriptConfig")
require("libs.Utils")

-- Config --
local config = ScriptConfig.new()
config:SetParameter("AutoDisjoint",true)
config:Load()

-- Globals --
local reg = false
local activated = 0
local visible_time = {}

-- Load --
function Load()
    if PlayingGame() then
        if entityList:GetMyHero().classId ~= CDOTA_Unit_Hero_Weaver then 
            script:Disable() 
        else
            reg = true
            script:RegisterEvent(EVENT_FRAME,Tick)
            script:UnregisterEvent(Load)
        end
    end
end

-- Main --
function Tick(tick)
    local me = entityList:GetMyHero()
    if not me then return end
    
    if config.AutoDisjoint == true then
        local enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, alive = true, team = me:GetEnemyTeam()})
        for i,v in ipairs(enemies) do
            if not v:IsIllusion() and not v.visible then
                if visible_time[v.handle] then
                    visible_time[v.handle] = nil
                end
            end
            if not v:IsIllusion() and v.visible then
                local Q = v:GetAbility(1)
                local W = v:GetAbility(2)
                local E = v:GetAbility(3)
                local R = v:GetAbility(4)
                local D = v:GetAbility(5)
                local F = v:GetAbility(6)
                local distance = GetDistance2D(v,me)                               
                
                if not visible_time[v.handle] then
                    visible_time[v.handle] = client.gameTime
                end
                if v.classId == CDOTA_Unit_Hero_SkeletonKing then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 600 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_BountyHunter then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 480 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Sven then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 680 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Broodmother then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 780 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Chaos_Knight then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 580 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Dazzle then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 680 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Naga_Siren then
                    if W and W.level > 0 and W.abilityPhase then
                        if distance < 650+80 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Morphling then
                    if W and W.level > 0 and W.abilityPhase then
                        if distance < 980 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_PhantomAssassin then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 1280 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_PhantomLancer then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 750+80 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_QueenOfPain then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 600 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_VengefulSpirit then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 580 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Skywraith_Mage then
                    if W and W.level > 0 and W.abilityPhase then
                        if distance < 1680 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Tidehunter then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 780 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Tinker then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 620 then
                            WeaverW()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Viper then
                    if R and R.level > 0 and R.abilityPhase then
                        if v:AghanimState() then
                            rdist = 980
                        else
                            rdist = 580
                        end
                        if distance < rdist then
                            WeaverW()
                        end                       
                    end
                elseif v.classId == CDOTA_Unit_Hero_Lina then
                    if R and R.level > 0 and R.abilityPhase then
                        WeaverW()
                    end
                end
                
                local cast = entityList:GetEntities({classId=282})
                local rocket = entityList:GetEntities({classId=CDOTA_BaseNPC})
                local hit = entityList:GetProjectiles({source=v,target=me})
                local projs = entityList:GetProjectiles({})
                for i,k in ipairs(projs) do
                    if k.target and k.target == me and k.source and k.source.team ~= me.team then
                        if k.source.classId == CDOTA_Unit_Hero_Tinker and k.speed == 900 and k.source:GetAbility(2) and math.ceil(k.source:GetAbility(2).cd - 0.1) ==  math.ceil(k.source:GetAbility(2):GetCooldown(k.source:GetAbility(2).level)) then
                            WeaverW()
                        elseif k.source.classId == CDOTA_Unit_Hero_Ogre_Magi and k.speed == 1000 and k.source:GetAbility(2) and math.ceil(k.source:GetAbility(2).cd - 0.1) ==  math.ceil(k.source:GetAbility(2):GetCooldown(k.source:GetAbility(2).level)) then
                            WeaverW()
                        end
                    end
                end
            end 
        end
        activated = 0
    end    
end

function WeaverW()
	if activated == 0 then
    local me = entityList:GetMyHero()
        if me:GetAbility(2) then
            if me:CanCast() and me:GetAbility(2):CanBeCasted() then
                me:CastAbility(me:GetAbility(2))
                activated=1
                sleepTick= GetTick() +600
			end
        end
    end
end

-- Close --
function GameClose()
    collectgarbage("collect")
    if reg then
        reg = false
        script:UnregisterEvent(Tick)
        script:RegisterEvent(EVENT_TICK,Load)
    end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_FRAME,Load)
