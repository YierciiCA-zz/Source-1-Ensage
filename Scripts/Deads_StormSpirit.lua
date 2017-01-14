require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Animations")
require("libs.Skillshot")

-- Config --
local config = ScriptConfig.new()
config:SetParameter("Chase", "D", config.TYPE_HOTKEY)
config:SetParameter("Stay", "S", config.TYPE_HOTKEY)
config:SetParameter("NoBall", "F", config.TYPE_HOTKEY)
config:SetParameter("Distance", "E", config.TYPE_HOTKEY)
config:SetParameter("Toggle", "X", config.TYPE_HOTKEY)
config:SetParameter("Escape", "Z", config.TYPE_HOTKEY)
config:SetParameter("AutoDisjoint", true)
config:SetParameter("SKeyDistance", 400)
config:SetParameter("EKeyDistance", 650)
config:Load()

local ChaseKey = config.Chase
local StayKey = config.Stay
local BallKey = config.NoBall
local DistanceKey = config.Distance
local StayDistance = config.SKeyDistance
local JumpDistance = config.EKeyDistance
local toggleKey = config.Toggle
local EscapeKey = config.Escape

-- Globals --
local reg = false
local victim = nil
local sleep = 0
local attack = 0
local move = 0
local start = false
local reset = nil
local active = false
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(-20*monitor,80*monitor,-1,"Targeting",F14) statusText.visible = false
local toggleText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") Hex + Silence",F14) toggleText.visible = false
local activated = 0
local visible_time = {}


-- Load --
function Load()
    if PlayingGame() then  
    local me = entityList:GetMyHero()
        if me.classId ~= CDOTA_Unit_Hero_StormSpirit then 
            script:Disable() 
        else
            reg = true
            victim = nil
            start = false
            sleep = 0
            reset = nil
            toggleText.visible = true
            script:RegisterEvent(EVENT_KEY,Key)
            script:RegisterEvent(EVENT_FRAME,Tick)
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
			toggleText.text = "(" .. string.char(toggleKey) .. ") Hex > Silence"
		else
			toggleText.text = "(" .. string.char(toggleKey) .. ") Hex + Silence"
		end
	end
end


-- Main --
function Tick(tick)
    if client.chat or client.console or client.loading then return end
    me = entityList:GetMyHero()
    if not me then return end
    if sleepTick and sleepTick > tick then return end
    local attackRange = 480
    local fountain = entityList:FindEntities({classId=CDOTA_Unit_Fountain})
    local myfountain = nil
    
    if victim and victim.visible then
        if not statusText.visible then
            statusText.visible = true
        end
    else
        statusText.visible = false
    end
        
    for h,z in ipairs(fountain) do
        if z.team == me.team then
            myfountain = z
        end
        if z.team ~= me.team then
            enemyfountain = z
        end
    end
    
    if config.AutoDisjoint == true then
        local enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, alive = true, team = me:GetEnemyTeam()})
        for i,v in ipairs(enemies) do
            if not v:IsIllusion() and not v.visible then
                if visible_time[v.handle] then
                    visible_time[v.handle] = nil
                end
            end
            if not v:IsIllusion() and v.visible and (v:FindRelativeAngle(me) < 0.2 and v:FindRelativeAngle(me) > -0.2) then
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
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_BountyHunter then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 480 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Sven then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 680 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Broodmother then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 780 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Chaos_Knight then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 580 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Dazzle then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 680 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Naga_Siren then
                    if W and W.level > 0 and W.abilityPhase then
                        if distance < 650+80 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Morphling then
                    if W and W.level > 0 and W.abilityPhase then
                        if distance < 980 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_PhantomAssassin then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 1280 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_PhantomLancer then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 750+80 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_QueenOfPain then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 600 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_VengefulSpirit then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 580 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Skywraith_Mage then
                    if W and W.level > 0 and W.abilityPhase then
                        if distance < 1680 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Tidehunter then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 780 then
                            StormUlt()
                        end
                    end
                elseif v.classId == CDOTA_Unit_Hero_Tinker then
                    if Q and Q.level > 0 and Q.abilityPhase then
                        if distance < 620 then
                            StormUlt()
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
                            StormUlt()
                        end                       
                    end
                elseif v.classId == CDOTA_Unit_Hero_Lina then
                    if R and R.level > 0 and R.abilityPhase then
                        StormUlt()
                    end
                end
                
                local cast = entityList:GetEntities({classId=282})
                local rocket = entityList:GetEntities({classId=CDOTA_BaseNPC})
                local hit = entityList:GetProjectiles({source=v,target=me})
                local projs = entityList:GetProjectiles({})
                for i,k in ipairs(projs) do
                    if k.target and k.target == me and k.source and k.source.team ~= me.team then
                        if k.source.classId == CDOTA_Unit_Hero_Tinker and k.speed == 900 and k.source:GetAbility(2) and math.ceil(k.source:GetAbility(2).cd - 0.1) ==  math.ceil(k.source:GetAbility(2):GetCooldown(k.source:GetAbility(2).level)) then
                            StormUlt()
                        elseif k.source.classId == CDOTA_Unit_Hero_Ogre_Magi and k.speed == 1000 and k.source:GetAbility(2) and math.ceil(k.source:GetAbility(2).cd - 0.1) ==  math.ceil(k.source:GetAbility(2):GetCooldown(k.source:GetAbility(2).level)) then
                            StormUlt()
                        end
                    end
                end
            end 
        end
        activated = 0
    end
        
    if IsKeyDown(EscapeKey) and SleepCheck("chill") then
        local R = me:GetAbility(4)
        local tp = (me:FindItem("item_tpscroll") or  me:FindItem("item_travel_boots") or me:FindItem("item_travel_boots_2"))
        
        if not R and tp and me:CanCast() and tp.cd == 0 and tp:CanBeCasted() then
            me:CastAbility(tp,myfountain.position)
        end
        
        if R and not tp and me:CanCast() and R:CanBeCasted() then
            me:CastAbility(R,myfountain.position)
        end
        
        if R and R:CanBeCasted() and me:CanCast() and tp and tp.cd == 0 and me.mana > (R.manacost + tp.manacost) and not me:IsChanneling() then
            if (me.rot+180 > enemyfountain.rot and me.rot+180 < enemyfountain.rot+180) then            
                me:CastAbility(R,enemyfountain.position)
                me:CastAbility(tp,myfountain.position)
                Sleep(250,"chill")
            else
                me:CastAbility(R,myfountain.position)
                me:CastAbility(tp,myfountain.position)
                Sleep(250,"chill")
            end
        end
    end
    
    if (IsKeyDown(ChaseKey) or IsKeyDown(StayKey) or IsKeyDown(BallKey) or IsKeyDown(DistanceKey))and not client.chat then
        if Animations.CanMove(me) or not start or (victim and GetDistance2D(victim,me) > attackRange+450) then
            start = true
            local MouseOver = targetFind:GetLastMouseOver(1500)
            if MouseOver and (not victim or GetDistance2D(me,victim) > attackRange or not victim.alive) and SleepCheck("victim") then            
                victim = MouseOver
                statusText.entity = victim
                statusText.entityPosition = Vector(0,0,victim.healthbarOffset)
                Sleep(250,"victim")
            end
        end
        if not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 1500 then
            if tick > attack and SleepCheck("casting") and victim.hero then
                local Q = me:GetAbility(1)
                local W = me:GetAbility(2)
                local R = me:GetAbility(4)
                local Sheep = me:FindItem("item_sheepstick")
                local Orchid = me:FindItem("item_orchid")
                local Shivas = me:FindItem("item_shivas_guard")
                local SoulRing = me:FindItem("item_soul_ring")                   
                local silenced = victim:IsSilenced() 
                local pull = victim:IsHexed() or victim:IsStunned()
                local disabled = victim:IsHexed() or victim:IsStunned() or victim:IsSilenced()
                local linkens = victim:IsLinkensProtected()
                local immune =  victim:IsMagicImmune()
                local distance = GetDistance2D(victim,me)                
                local Overload = me:DoesHaveModifier("modifier_storm_spirit_overload")                
                local balling = me:DoesHaveModifier("modifier_storm_spirit_ball_lightning")
                
                if W and W:CanBeCasted() and me:CanCast() and distance <= W.castRange+100 and not pull and not linkens and not (Sheep and Sheep:CanBeCasted()) and not immune then
                    me:CastAbility(W,victim)
                    Sleep(W:FindCastPoint()*1000+me:GetTurnTime(victim)*1000,"casting")
                end

                if Q and Q:CanBeCasted() and me:CanCast() and distance <= attackRange+200 and not Overload then
                    me:CastAbility(Q)
                end
                    
                if IsKeyDown(ChaseKey) and R and R:CanBeCasted() and me:CanCast() and distance > attackRange and not balling and not R.abilityPhase then
                    local position = (victim.position - me.position) * (GetDistance2D(me,victim) - (attackRange-350)) / GetDistance2D(me,victim) + me.position
                    if GetDistance2D(me,victim) ~= 0 then
                        me:CastAbility(R,position)
                        Sleep(R:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "casting")
                    end
                end
                
                if IsKeyDown(StayKey) and R and R:CanBeCasted() and me:CanCast() and distance > attackRange+300 and not balling and not R.abilityPhase then
                    local position = (victim.position - me.position) * (GetDistance2D(me,victim) - (attackRange)) / GetDistance2D(me,victim) + me.position
                    if GetDistance2D(me,victim) ~= 0 then
                        me:CastAbility(R,position)
                        Sleep(R:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "casting")
                    end
                end
                
                if IsKeyDown(DistanceKey) and R and R:CanBeCasted() and me:CanCast() and distance > attackRange+200 and not balling and not R.abilityPhase then
                    local position = (victim.position - me.position) * (GetDistance2D(me,victim) - (attackRange-JumpDistance)) / GetDistance2D(me,victim) + me.position
                    if GetDistance2D(me,victim) ~= 0 then
                        me:CastAbility(R,position)
                        Sleep(R:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "casting")
                    end
                end
                
                if SoulRing and SoulRing:CanBeCasted() and distance < attackRange+200 then
                    me:CastAbility(SoulRing)
                end
                
                if Shivas and Shivas:CanBeCasted() and distance < attackRange+200 then
                    me:CastAbility(Shivas)
                end
                
                if (Sheep and not Orchid) and Sheep:CanBeCasted() and not pull and not immune then
                    me:CastAbility(Sheep, victim)
                    Sleep(me:GetTurnTime(victim)*1000, "casting")
                end
                
                if (Orchid and not Sheep) and Orchid:CanBeCasted() and not silenced and not immune then
                    me:CastAbility(Orchid, victim)
                    Sleep(me:GetTurnTime(victim)*1000, "casting")
                end
                
                if (Orchid and Sheep) and active and not immune then
                    if Sheep:CanBeCasted() and not disabled and not linkens then
                        me:CastAbility(Sheep, victim)
                        Sleep(me:GetTurnTime(victim)*1000, "casting")
                    end
                    if (Orchid:CanBeCasted() and not Sheep:CanBeCasted()) and not disabled then
                        me:CastAbility(Orchid, victim)
                        Sleep(me:GetTurnTime(victim)*1000, "casting")
                    end
                end
                
                if (Orchid and Sheep) and not active and not immune then
                    if Sheep:CanBeCasted() and not pull and not linkens then
                        me:CastAbility(Sheep, victim)
                        Sleep(me:GetTurnTime(victim)*1000, "casting")
                    end
                    if Orchid:CanBeCasted() and not silenced then
                        me:CastAbility(Orchid, victim)
                        Sleep(me:GetTurnTime(victim)*1000, "casting")
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
            if victim and victim.hero and not Animations.isAttacking(me) then
                local R = me:GetAbility(4)    
                local Overload = me:DoesHaveModifier("modifier_storm_spirit_overload")                
                local distance = GetDistance2D(victim,me)               
                local balling = me:DoesHaveModifier("modifier_storm_spirit_ball_lightning")                
                
                if IsKeyDown(ChaseKey) and R and R:CanBeCasted() and me:CanCast() and distance < attackRange and not Overload and not balling and not R.abilityPhase then
                    me:CastAbility(R,me.position)
                    Sleep(R:FindCastPoint()*1000, "casting")
                end                
                if IsKeyDown(StayKey) and R and R:CanBeCasted() and me:CanCast() and distance < attackRange+300 and not Overload and not balling and not R.abilityPhase then
                    local mouse = client.mousePosition
                    local xyz = (mouse - me.position) * StayDistance / GetDistance2D(mouse,me) + me.position
                    if GetDistance2D(me,victim) ~= 0 then
                        me:CastAbility(R,xyz)
                        Sleep(R:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "casting")
                    end
                end
                if IsKeyDown(DistanceKey) and R and R:CanBeCasted() and me:CanCast() and distance < attackRange+200 and not Overload and not balling and not R.abilityPhase then
                    local position = (victim.position - me.position) * (GetDistance2D(me,victim) - (attackRange-JumpDistance)) / GetDistance2D(me,victim) + me.position
                    if GetDistance2D(me,victim) ~= 0 then
                        me:CastAbility(R,position)
                        Sleep(R:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "casting")
                    end
                end
            end
            if victim then
                if (IsKeyDown(StayKey) or IsKeyDown(BallKey)) then
                    me:Move(client.mousePosition)
                elseif (IsKeyDown(DistanceKey) or IsKeyDown(ChaseKey)) then
                    me:Attack(victim)
                else
                    me:Follow(victim)
                end
            else
                me:Move(client.mousePosition)
            end
            move = Animations.maxCount/1.5
            start = false
        end
    elseif victim then
        if not reset then
            reset = client.gameTime
        elseif (client.gameTime - reset) >= 5 then
            victim = nil
        end
        start = false
    end
end

function StormUlt()
	if activated == 0 then
    local me = entityList:GetMyHero()
        if me:GetAbility(4) then
            if me:CanCast() and me:GetAbility(4):CanBeCasted() then
                me:CastAbility(me:GetAbility(4),me.position)
                activated=1
                sleepTick= GetTick() +500
			end
        end
    end
end

-- Close --
function GameClose()
    collectgarbage("collect")
    if reg then
        reg = false
        statusText.visible = false
        toggleText.visible = false
        active = false
        victim = nil
        start = false
        reset = nil
        script:UnregisterEvent(Key)
        script:UnregisterEvent(Tick)
        script:RegisterEvent(EVENT_FRAME,Load)
    end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_FRAME,Load)
