require("libs.ScriptConfig")
require("libs.Utils")
require("libs.Animations")

-- Config --
local config = ScriptConfig.new()
config:SetParameter("Fight", "D", config.TYPE_HOTKEY)
config:SetParameter("Kill", "F", config.TYPE_HOTKEY)
config:SetParameter("Harass", "E", config.TYPE_HOTKEY)
config:SetParameter("Armlet", true)
config:SetParameter("AutoQ", true)
config:Load()

local ChaseKey = config.Fight
local KillKey = config.Kill
local HarassKey = config.Harass
local ArmletSetting = config.Armlet
local AutoQ = config.AutoQ

-- Globals --
local target = nil
local Registered = nil
local attack = 0
local move = 0
local reg = false
local ledistance = 0
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(-20*monitor,80*monitor,-1,"Targeting",F14) statusText.visible = false

-- Load --
function Load()
    if PlayingGame() then  
    local me = entityList:GetMyHero()
        if me.classId ~= CDOTA_Unit_Hero_Huskar then 
            script:Disable() 
        else
            reg = true
            script:RegisterEvent(EVENT_TICK,Key)
            script:UnregisterEvent(Load)
        end
    end
end

-- Key --
function Key(msg,code)
	if not PlayingGame() or client.chat then return end	
	if (IsKeyDown(ChaseKey) or IsKeyDown(KillKey) or IsKeyDown(HarassKey)) then
        if not Registered then
            script:RegisterEvent(EVENT_TICK, Kill)
            Registered = true
        end
    else
        if Registered then
            script:UnregisterEvent(Kill)
            Registered = false
            target = nil
        end
    end
end

-- Main --
function Kill(tick)
    if client.chat or client.console or client.loading then return end
    local me = entityList:GetMyHero()
    if not me then return end
    local attackRange = me.attackRange
    local Q = me:GetAbility(1)
    local W = me:GetAbility(2)
    local R = me:GetAbility(4)
    
    if R and R:CanBeCasted() and R.cd == 0 then
        ledistance = 550
    else
        ledistance = me.attackRange
    end
    
    if not target then
        FindTarget()
        statusText.visible = false
        if SleepCheck("moving") and not target then
            me:Move(client.mousePosition)
            Sleep(150,"moving")
        end
    elseif target and ((not target.alive) or (not target.visible)) then
        target = nil
    elseif target and IsKeyDown(ChaseKey) and (WillDie(target) or (GetDistance2D(target,me) > ledistance)) then
        target = nil
    elseif target and IsKeyDown(HarassKey) and WillDie(target) then
        target = nil
    end
    
    if target then
        if target.visible then
            statusText.visible = true
            statusText.entity = target
            statusText.entityPosition = Vector(0,0,target.healthbarOffset)
        end
        if not Animations.CanMove(me) then
            if tick > attack and SleepCheck("casting") then
                local satanic = me:FindItem("item_satanic")
                local armlet = me:FindItem("item_armlet")
                local halberd = me:FindItem("item_heavens_halberd")
                local armmod = me:DoesHaveModifier("modifier_item_armlet_unholy_strength")
                local solarcrest = me:FindItem("item_solar_crest")
                
                if R and R:CanBeCasted() and me:CanCast() and (not IsKeyDown(HarassKey)) and GetDistance2D(target,me) < 550 then                   
                    if (target.health > target.maxHealth*0.50 or GetDistance2D(target,me) > attackRange) then
                        if solarcrest and solarcrest.cd == 0 and solarcrest:CanBeCasted() then
                            me:CastAbility(solarcrest,target)
                            me:CastAbility(R,target)
                            Sleep(R:FindCastPoint()+client.latency/3+150,"casting")
                        else                            
                            me:CastAbility(R,target)
                            Sleep(R:FindCastPoint()+client.latency/3+150,"casting")
                        end
                    end
                end
                
                if Q and Q:CanBeCasted() and me.health < me.maxHealth*0.4 and me:CanCast() and AutoQ then
                    me:CastAbility(Q,me)
                    Sleep(Q:FindCastPoint()+client.latency/3+150,"casting")
                end

                if armlet and me:CanCast() and ArmletSetting then
                    if Animations.isAttacking(me) and not armmod then
                        me:CastItem("item_armlet")
                        Sleep(300,"casting")
                    elseif me.health < me.maxHealth*0.5 and not armmod then
                        me:CastItem("item_armlet")
                        Sleep(300,"casting")
                    elseif me.health < 151 and armmod then
                        me:CastItem("item_armlet")
                        me:CastItem("item_armlet")
                        Sleep(1000,"casting")
                    end
                end
                
                if satanic and satanic:CanBeCasted() and me:CanCast() and me.health < me.maxHealth*0.3 and GetDistance2D(me,target) < attackRange then
                    me:CastAbility(satanic)
                    Sleep(150,"casting")
                end
                
                if halberd and halberd:CanBeCasted() and me:CanCast() and GetDistance2D(me,target) < 550 then
                    me:CastAbility(halberd,target)
                    Sleep(150,"casting")
                end 
                
                if target:IsAttackImmune() == true then
                    me:Move(client.mousePosition)
                else
                    if W and W.level > 0 then
                        me:CastAbility(W,target)
                    else
                        me:Attack(target)
                    end
                end
                attack = tick + Animations.maxCount + client.latency
            end
        elseif tick > move and SleepCheck("casting") then
            if me.attackSpeed < 240 then
                me:Move(client.mousePosition)
            else
                if W and W.level > 0 then
                    me:CastAbility(W,target)
                else
                    me:Attack(target)
                end
            end
            move = tick + Animations.maxCount + client.latency
        end
    end        
end

function FindTarget()
    local me = entityList:GetMyHero()
    local Enemies = entityList:GetEntities(function(v) return v.type == LuaEntity.TYPE_HERO and v.team == me:GetEnemyTeam() and v.visible and not v.illusion and v.alive and v:GetDistance2D(me) < 550  end)
    if #Enemies > 0 then
        table.sort(Enemies, function(a,b) return a:GetDistance2D(me) < b:GetDistance2D(me) end)
        for _,v in ipairs(Enemies) do
            if not WillDie(v) then
                target = v
                return v
            end
        end
    end
end

function WillDie(victim)
    local me = entityList:GetMyHero()
    local WStacks = victim:FindModifier("modifier_huskar_burning_spear_debuff")
    local NStacks = 0
    local WTime = 0
    local Damage = 0
    local DPS = 0
    local DamageLimit = 0
    local LeDPS = 0
    local WDamage = {5,10,15,20}
    local W = me:GetAbility(2)
    local MWand = victim:FindItem("item_magic_wand") 
    local MStick = victim:FindItem("item_magic_stick")
    
    if WStacks then
        NStacks = WStacks.stacks
        WTime = WStacks.remainingTime
        Damage = ((WDamage[W.level])*(1-victim.magicDmgResist))
        DPS = math.floor(Damage)*NStacks*math.floor(WTime)
        DamageLimit = math.floor(Damage)*8*5.5
        if DPS < DamageLimit then
            LeDPS = DPS
        elseif DPS >= DamageLimit then
            LeDPS = DamageLimit
        end
        if MWand or MStick then
            if MStick then
                Potential = (MStick.charges + 2) * 15
            elseif MWand then
                Potential = (MWand.charges + 2) * 15
            end
        else
            Potential = 0
        end
        Regen = WTime*victim.healthRegen
        ADHD = Regen + victim.health + Potential
        if LeDPS > ADHD then
            return true
        else
            return false
        end
    end
end


-- Close --
function GameClose()
    collectgarbage("collect")
    if reg then
        Potential = nil
        satanic = nil
        halberd = nil
        ADHD = nil
        Enemies = nil
        monitor = nil
        F14 = nil
        me = nil
        DamageLimit = nil
        LeDPS = nil
        WStacks = nil
        NStacks = nil
        WTime = nil
        Damage = nil
        DPS = nil
        WDamage = nil
        W = nil
        Q = nil
        R = nil
        MWand = nil
        MStick = nil
        statusText.visible = false
        target = nil
        Registered = nil
        attack = nil
        move = nil
        ledistance = nil
        reg = false
        script:UnregisterEvent(Key)
        script:RegisterEvent(EVENT_TICK,Load)
    end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
