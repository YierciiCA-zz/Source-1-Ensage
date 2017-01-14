require("libs.ScriptConfig")
require("libs.Utils")
require("libs.HeroInfo")

-- Config --
local config = ScriptConfig.new()
config:SetParameter("Stop", "S", config.TYPE_HOTKEY)
config:SetParameter("Toggle", "X", config.TYPE_HOTKEY)
config:SetParameter("NoSpam", true)
config:SetParameter("FreeAttack", true)
config:Load()

local StopKey = config.Stop
local toggleKey = config.Toggle
local NoSpam = config.NoSpam
local FreeAttack = config.FreeAttack

-- Globals --
local reg = false
local active = true
local Jinada = nil
local Gem = nil
local Tidebringer = nil
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local toggleText  = drawMgr:CreateText(10*monitor,620*monitor,-1,"(" .. string.char(toggleKey) .. ") Last Hit: On",F14) toggleText.visible = false


-- Load --
function Load()
    if PlayingGame() then
        reg = true
        toggleText.visible = true
        script:RegisterEvent(EVENT_KEY,Key)
        script:RegisterEvent(EVENT_FRAME,Tick)
        script:UnregisterEvent(Load)
    end
end

-- Key --
function Key(msg,code)
	if not PlayingGame() or client.chat then return end	
	if IsKeyDown(toggleKey) and SleepCheck("toggle") then
		active = not active
        Sleep(200, "toggle")
		if active then
			toggleText.text = "(" .. string.char(toggleKey) .. ") Last Hit: On"
		else
			toggleText.text = "(" .. string.char(toggleKey) .. ") Last Hit: Off"
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
    local name = entityList:GetMyHero().name
    local apoint = ((heroInfo[name].attackPoint*100)/(1+me.attackSpeed))*1000
    local aRange = me.attackRange
    local bonus = 0
    local buffer = 0
    
    if me.classId == CDOTA_Unit_Hero_Sniper then
        local TakeAim = me:GetAbility(3)
        local aimrange = {100,200,300,400}
        
        if TakeAim and TakeAim.level > 0 then
            bonus = aimrange[TakeAim.level]
        end
    end
    if me.classId == CDOTA_Unit_Hero_TemplarAssassin then
        local PsyBlade = me:GetAbility(3)
        local PsyRange = {60,120,180,240}
        
        if PsyBlade and PsyBlade.level > 0 then
            bonus = PsyRange[PsyBlade.level]
        end
    end

    if me.classId == CDOTA_Unit_Hero_Kunkka then
        local Tide = me:GetAbility(2)
    
        if Tide and Tidebringer.level > 0 then
            if Tidebringer.cd == 0 then
                Tidebringer = true
            else
                Tidebringer = false
            end
        end
    end
    
    local attackRange = aRange + bonus
    
    if (active and not IsKeyDown(StopKey)) and not client.chat then
        local damage = me.dmgMin + me.dmgBonus
        local megaplayer = entityList:GetMyPlayer()
        local qblade = me:FindItem("item_quelling_blade")
        local bfury = me:FindItem("item_bfury")

        if megaplayer.orderId == Player.ORDER_ATTACKENTITY and megaplayer.alive == true then
            if megaplayer.target == nil then return end
            if (megaplayer.target.classId == CDOTA_BaseNPC_Creep_Lane or megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege or megaplayer.target.classId == CDOTA_BaseNPC_Tower) and 
            (megaplayer.target.alive == true and megaplayer.target.visible == true and megaplayer.target ~= nil) then
                    
                if qblade and (not (bfury or Tidebringer or megaplayer.target.classId == CDOTA_BaseNPC_Tower or megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege)) then
                   if attackRange > 195 then
                        damage = me.dmgMin*1.15 + me.dmgBonus
                    else
                        damage = me.dmgMin*1.40 + me.dmgBonus
                    end
                end
                
                if bfury and not (Tidebringer or megaplayer.target.classId == CDOTA_BaseNPC_Tower or megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege) then
                    if attackRange > 195 then
                        damage = me.dmgMin*1.25 + me.dmgBonus
                    else
                        damage = me.dmgMin*1.60 + me.dmgBonus
                    end
                end
                
                if me.classId == CDOTA_Unit_Hero_AntiMage then
                    local Manabreak = me:GetAbility(1)
                    local Manaburn = {28,40,52,64}
                        
                    if Manabreak and Manabreak.level > 0 and megaplayer.target.maxMana > 0 and megaplayer.target.mana > 0 and megaplayer.target.team ~= me.team then
                        damage = damage + Manaburn[Manabreak.level]*0.60
                    end
                end          
                if me.classId == CDOTA_Unit_Hero_Viper then
                    local Nethertoxin = me:GetAbility(2)
                    local Toxindamage = {2.2,4.7,7.2,9.7}  
                    
                    if Nethertoxin and Nethertoxin.level > 0 and megaplayer.target.team ~= me.team then
                        local HPcent = (megaplayer.target.health / megaplayer.target.maxHealth)*100
                        local Netherdamage = nil
                        if HPcent > 80 and HPcent <= 100 then
                            Netherdamage = Toxindamage[Nethertoxin.level]*0.5
                        elseif HPcent > 60 and HPcent <= 80 then
                            Netherdamage = Toxindamage[Nethertoxin.level]
                        elseif HPcent > 40 and HPcent <= 60 then
                            Netherdamage = Toxindamage[Nethertoxin.level]*2
                        elseif HPcent > 20 and HPcent <= 40 then
                            Netherdamage = Toxindamage[Nethertoxin.level]*4
                        elseif HPcent > 0 and HPcent <= 20 then
                            Netherdamage = Toxindamage[Nethertoxin.level]*8
                        end
                        if Netherdamage then
                            damage = damage + Netherdamage
                        end
                    end
                end           
                if me.classId == CDOTA_Unit_Hero_Ursa and not (megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege or megaplayer.target.classId == CDOTA_BaseNPC_Tower) then
                    local Furyswipes = me:GetAbility(3)
                    local Furybuff = megaplayer.target:FindModifier("modifier_ursa_fury_swipes_damage_increase")
                    local Furydamage = {15,20,25,30}
                    
                    if Furyswipes.level > 0 and megaplayer.target.team ~= me.team then
                        if Furybuff then
                            damage = damage + Furydamage[Furyswipes.level]*(Furybuff.stacks+1)
                        else
                            damage = damage + Furydamage[Furyswipes.level]
                        end
                    end
                end
                if me.classId == CDOTA_Unit_Hero_BountyHunter and not (megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege or megaplayer.target.classId == CDOTA_BaseNPC_Tower) then
                    Jinada = me:GetAbility(2)
                    local Jinadadamage = {1.5,1.75,2,2.25}
                    
                    if Jinada and Jinada.level > 0 and Jinada.cd == 0 and megaplayer.target.team ~= me.team then
                        damage = damage*(Jinadadamage[Jinada.level])
                    end
                end            
                if me.classId == CDOTA_Unit_Hero_Weaver then
                    Gem = me:GetAbility(3)
                    
                    if Gem and Gem.level > 0 and Gem.cd == 0 then
                        damage = damage*1.8
                    end
                end            
                
               	if (me.classId == CDOTA_Unit_Hero_SkeletonKing or me.classId == CDOTA_Unit_Hero_ChaosKnight) and me.activity == 426 and not (megaplayer.target.classId == CDOTA_BaseNPC_Tower) then
			local critabil = me:GetAbility(3)
			local critmult = {1.5,2,2.5,3}
			
			if critabil and critabil.level > 0 and megaplayer.target.team ~= me.team then
				damage = damage*(critmult[critabil.level])
			end
		end
                
                if (me.classId == CDOTA_Unit_Hero_Juggernaut or me.classId == CDOTA_Unit_Hero_Brewmaster) and me.activity == 426 and not (megaplayer.target.classId == CDOTA_BaseNPC_Tower) then
                    local jugcrit = me:GetAbility(3)
                    
                    if jugcrit and jugcrit.level > 0 and megaplayer.target.team ~= me.team then
                        damage = damage*2
                    end
                end
                
                if me.classId == CDOTA_Unit_Hero_PhantomAssassin and me.activity == 426 and not (megaplayer.target.classId == CDOTA_BaseNPC_Tower) then
                    local pacrit = me:GetAbility(4)
                    local pamod = {2.3,3.4,4.5}
                    
                    if pacrit and pacrit.level > 0 and megaplayer.target.team ~= me.team then
                        damage = damage*(pamod[pacrit.level])
                    end
                end

                if me.classId == CDOTA_Unit_Hero_Riki and not (megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege or megaplayer.target.classId == CDOTA_BaseNPC_Tower) then
                    if (me.rot+180 > megaplayer.target.rot+180-(220/2) and me.rot+180 < megaplayer.target.rot+180+(220/2)) and me:GetAbility(3).level > 0 then
                        damage = damage + me.agilityTotal*(me:GetAbility(3).level*0.25+0.25)
                    end
                end

                if megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege or megaplayer.target.classId == CDOTA_BaseNPC_Tower then
                    damage = damage*0.5
                end
                
                if megaplayer.target.team == me.team and qblade and megaplayer.target.classId == CDOTA_BaseNPC_Creep_Lane then
                    damage = me.dmgMin + me.dmgBonus
                end
                
                toggleText.text = "(" .. string.char(toggleKey) .. ") Last Hit: On | Target HP = "..megaplayer.target.health.. "| Damage = "..(megaplayer.target:DamageTaken(damage,DAMAGE_PHYS,me))          
                
                if (((megaplayer.target.classId == CDOTA_BaseNPC_Creep_Lane or megaplayer.target.classId == CDOTA_BaseNPC_Creep_Siege) and GetDistance2D(me,megaplayer.target) <= attackRange+100) or (megaplayer.target.classId == CDOTA_BaseNPC_Tower and GetDistance2D(me,megaplayer.target) <= attackRange+300)) and 
                (megaplayer.target.health > (megaplayer.target:DamageTaken(damage,DAMAGE_PHYS,me))) and 
                (not FreeAttack or (FreeAttack and (megaplayer.target.health < (megaplayer.target:DamageTaken(damage,DAMAGE_PHYS,me)*2.5))) or 
                (FreeAttack and
                ( 
                (me.classId == CDOTA_Unit_Hero_BountyHunter and Jinada and Jinada.cd == 0) or 
                (me.classId == CDOTA_Unit_Hero_Weaver and Gem and Gem.cd == 0) or
                (Tidebringer)
                ))) 
                then 
                    if SleepCheck("stop") then                        
                        if me.classId == CDOTA_Unit_Hero_Bristleback then
                            Sleep(apoint*0.80,"stop")
                        else
                            Sleep(apoint,"stop")
                        end
                        megaplayer:HoldPosition()
                        if NoSpam then 	
                            megaplayer:Attack(megaplayer.target) 
                        end
                    end
                elseif megaplayer.target.health < (megaplayer.target:DamageTaken(damage,DAMAGE_PHYS,me)) and SleepCheck("StopIt") then
                    megaplayer:Attack(megaplayer.target)
                    Sleep(250,"StopIt")
                end
            end
		end
    end
end

-- Close --
function GameClose()
    collectgarbage("collect")
    if reg then
        reg = false
        active = true
        toggleText.visible = false
        Gem = nil
        Jinada = nil
        Tidebringer = nil
        script:UnregisterEvent(Tick)
        script:UnregisterEvent(Key)
        script:RegisterEvent(EVENT_FRAME,Load)
    end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_FRAME,Load)
