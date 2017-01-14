--<<ShadowFiend FINAL>>
--[[
                                                ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
         ShadowFiend Final BETA, HOLD the hotkey's to automatically raze/combo the enemy closest to your mouse.
                             Additional Features - Amazingly awesome range display :D
                             Additional Features - Combo from public version
             
             CAUTION- This may have bugs, if you try this script please PM me, and tell me what you think
             
                               Most Recent Changes -
                                           - Added features from public version
                                           - Improved AutoRaze to work over cliffs
                                           - Updated combo a little to avoid failure
             
                                                     CREDITS
                                 - Me (He's awesome and wrote this)
                                 - Blaxpirit (SkillBuild and Killable Display)
                                 - Blaxpirit (Combo Modification + Initial AutoRaze)
                                 - Moones (Various libraries)
                                 - Coffee (Coffee)
                                                ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
]]
--Libraries
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.SkillShot")
require("libs.Animations")

--Config
config = ScriptConfig.new()
config:SetParameter("Hotkey", "F", config.TYPE_HOTKEY)
config:SetParameter("RazeKey", "D", config.TYPE_HOTKEY)
config:SetParameter("ToggleRange", "G", config.TYPE_HOTKEY)
config:SetParameter("SkillBuild", 1)
config:SetParameter("TextPositionX", 5)
config:SetParameter("TextPositionY", 45)
config:Load()

local Hotkey = config.Hotkey
local RazeKey  = config.RazeKey
local ToggleRange  = config.ToggleRange
local skillbuild = config.SkillBuild
local registered  = false
local active      = false
local Ractive     = false
local command = 0
local mypos = nil
local init = false
local Awesome = true
local Default = false
local Off = false

R = {200, 450, 700}
razes = {}

local shotgunned = false
local etherealactive = true
local hero = {}
local disableAutoAttack = false
local TimeRemaining = 0
local Souls = 0

local wavedamage = {80,120,160}

--=====================<< SkillBuilds >>=======================
--1 - raze, 4 - necromastery, 5 - presence of a dark lord, 6 - ult, 7 - attribute bonus
local sb1 = {4,1,1,4,1,4,1,4,6,5,6,5,5,5,7,6,7,7,7,7,7,7,7,7,7}
local sb2 = {4,5,4,5,4,5,4,5,6,7,6,7,7,7,7,6,7,7,7,7,7,1,1,1,1} -- no coils build
--=========================<< END >>===========================

--Text on your screen
local x,y = config:GetParameter("TextPositionX"), config:GetParameter("TextPositionY")
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor)
local F15 = drawMgr:CreateFont("F14","Segue UI",15*monitor,550*monitor)
local statusText3 = drawMgr:CreateText((x)*monitor,(y+32)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(RazeKey).."'' for Auto Raze, ''"..string.char(Hotkey).."''  for Eul Combo.",F15) statusText3.visible = false
local statusText4 = drawMgr:CreateText((x)*monitor,(y+47)*monitor,0xFFFFFFFFF,"This is now in the FINAL BETA stage.",F15) statusText4.visible = false
local statusText5 = drawMgr:CreateText((x)*monitor,(y+62)*monitor,0xFFFFFFFFF,"On your screen you have a cool range display, click "..string.char(ToggleRange).." to toggle it. (Awesome/Default/Off)",F15) statusText5.visible = false
local statusText6 = drawMgr:CreateText((x)*monitor,(y+77)*monitor,0xFFFFFFFFF,"In this update I've included the Eul Combo from the public version and made some core changes.",F15) statusText6.visible = false
local statusText7 = drawMgr:CreateText((x)*monitor,(y+92)*monitor,0xC73C3CFF,"",F15) statusText7.visible = false

function onLoad()
  if PlayingGame() then
    local me = entityList:GetMyHero()
    if me.classId ~= CDOTA_Unit_Hero_Nevermore then
      script:Disable()
    else
      registered = true
      script:RegisterEvent(EVENT_FRAME,Main)
      script:RegisterEvent(EVENT_KEY,Key)
      script:UnregisterEvent(onLoad)
    end
  end
end

function Key(msg,code)

  if client.chat or client.console or client.loading then return end

  if code == Hotkey then
    active = (msg == KEY_DOWN)
  end

  if code == RazeKey then
    Ractive = (msg == KEY_DOWN)
  end

  if IsKeyDown(ToggleRange) then

    if Awesome == true then
      Awesome = false
      Default = true
      for i=1,3 do
        razes[i] = nil
        collectgarbage("collect")
      end
      return
    end

    if Default == true then
      Default = false
      Off = true
      for i=1,3 do
        razes[i] = nil
        collectgarbage("collect")
      end
      return
    end

    if Off == true then
      Off = false
      Awesome = true
      for i=1,3 do
        razes[i] = nil
        collectgarbage("collect")
      end
      return
    end

  end

end

function Main(frame)
  if not SleepCheck() then return end

  local me = entityList:GetMyHero()
  local mp = entityList:GetMyPlayer()
  if not me then return end

  if not init then
    Abilities = {me:GetAbility(1),me:GetAbility(2),me:GetAbility(3)}
    init = true
  end

  --Auto attack toggle
  if not SleepCheck("auto_attack") and disableAutoAttack then -- disabling
    client:ExecuteCmd("dota_player_units_auto_attack_after_spell 0")
    disableAutoAttack = false
  elseif SleepCheck("auto_attack") and not disableAutoAttack then -- enabling
    client:ExecuteCmd("dota_player_units_auto_attack_after_spell 1")
    disableAutoAttack = true
  end

  --Choosing skillbuild
  if skillbuild == 1 then
    sb = sb1
  elseif skillbuild == 2 then
    sb = sb2
  end

  --Auto ability learn
  local points = me.abilityPoints
  if points > 0 then
    local prev = SelectUnit(me)
    mp:LearnAbility(me:GetAbility(sb[me.level+1-points]))
    SelectBack(prev)
    Sleep(100)
  end

  --Stuff we need for combo
  local eul = me:FindItem("item_cyclone")
  local blink = me:FindItem("item_blink")
  local ethereal = me:FindItem("item_ethereal_blade")
  local ult = me:GetAbility(6)

  local target = targetFind:GetClosestToMouse(100)

  --Eul combo
  if active then
    if target then
      local eulmodif = target:FindModifier("modifier_eul_cyclone")
      if eul and eul.cd > 0 and SleepCheck("Time") then
        TimeRemaining = 2500+GetTick()
        Sleep(2500,"Time")
      end

      local etherealmodif = target:FindModifier("modifier_item_ethereal_blade_slow")
      if eul and eul.cd == 0 and not eulmodif then
        if etherealactive and ethereal and ethereal:CanBeCast() then
          me:CastAbility(ethereal,target)
          shotgunned = true
          Sleep(10,"ethereal")
        end
        if SleepCheck("ethereal") then
          if etherealmodif and shotgunned then
            me:CastAbility(eul,target)
            shotgunned = false
          elseif not shotgunned and not blink and GetDistance2D(me,target) < me.movespeed*0.8 then
            me:CastAbility(eul,target)
          elseif not shotgunned and blink then
            me:CastAbility(eul,target)
          end
        end
        Sleep(2500,"auto_attack")
        Sleep(100)
        return
      end
      if eulmodif then
        if GetDistance2D(me,target)/me.movespeed < 0.8 and SleepCheck("move") and SleepCheck("blink") then
          me:SafeCastItem("item_phase_boots")
          mp:Move(target.position)
          Sleep(2000,"move")
        elseif blink and blink.cd == 0 and (((TimeRemaining - GetTick())/1000) < 2.5) and SleepCheck("move") then
          me:CastAbility(blink, target.position)
          Sleep(2000,"blink")
          Sleep(50)
          return
        end
        if ult and ult:CanBeCast() and (((TimeRemaining - GetTick())/1000) < 1.75) and GetDistance2D(me,target) <= 150 then
          me:CastAbility(ult)
          Sleep(2500)
          return
        end
      end
    end
  end

  if not Ractive then
    target = nil
    command = 0
    for i=1,3 do
      local p = Vector(me.position.x + R[i] * math.cos(me.rotR), me.position.y + R[i] * math.sin(me.rotR), me.position.z)

      if not razes[i] then
        if Abilities[i] and Abilities[i]:CanBeCast() then
          if Awesome then
            razes[i] = Effect(p,  "aura_vlads")
            razes[i]:SetVector(0, p )
          elseif Default then
            razes[i] = Effect(p,  "range_display")
            razes[i]:SetVector(1,Vector(250,0,0) )
            razes[i]:SetVector(0, p )
          end
        end
      elseif not Off then
        if Abilities[i] and Abilities[i]:CanBeCast() then
          razes[i]:SetVector(0, p )
        else
          razes[i] = nil
          collectgarbage("collect")
        end
      end
    end
    if eff ~= nil then
      eff = nil
      collectgarbage("collect")
    end
  else
    for i=1,3 do
      razes[i] = nil
      collectgarbage("collect")
    end
  end

  -- AUTORAZE ST00F
  if Ractive and target then
    local Raze1 = me:GetAbility(1)
    local Raze2 = me:GetAbility(2)
    local Raze3 = me:GetAbility(3)
    local TurnTime = (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, target))) - 0.69, 0)/(1.0*(1/0.03)))

    if command == 0 then
      xyz1 = SkillShot.PredictedXYZ(target,(670 + client.latency +(TurnTime*1000)))
      xyz = (xyz1 - me.position) * 120 / GetDistance2D(xyz1,me) + me.position
      eff = Effect(xyz1,"aura_endurance")
      eff:SetVector(0,xyz1)
      effect = true
      command = 1
    end

    local distance = GetDistance2D(me,xyz1)
    if distance <= 400 and distance >= 0 and Raze1 and Raze1:CanBeCast() and SleepCheck("CastDelay") and SleepCheck("raze1cd") then
      if Animations.getDuration(Raze1) > 0 and (me:FindRelativeAngle(xyz1) > 1 or me:FindRelativeAngle(xyz1) < -1) then
        me:Stop()
        command = 0
      elseif command == 1 then
        me:Stop()
        mypos = nil
        me:Move(xyz)
        command = 2
      elseif command == 2 and IsTurning() == false then
        CastRaze(1)
        Sleep(1000,"CastCheck")
        command = 3
      elseif command == 3 and Animations.getDuration(Raze1) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) > 250 then
        me:Stop()
        command = 0
      elseif command == 3 and Animations.getDuration(Raze1) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) <= 250 then
        command = 0
        Sleep(9000,"raze1cd")
        Sleep(170,"CastDelay")
      elseif command == 3 and Raze1.cd >= 0 and SleepCheck("CastCheck") then
        command = 0
      end
    elseif distance <= 650 and distance >= 250 and Raze2 and Raze2:CanBeCast() and SleepCheck("raze2cd") and SleepCheck("CastDelay") then
      if Animations.getDuration(Raze2) > 0 and (me:FindRelativeAngle(xyz1) > 1 or me:FindRelativeAngle(xyz1) < -1) then
        me:Stop()
        command = 0
      elseif command == 1 then
        me:Stop()
        mypos = nil
        me:Move(xyz)
        command = 2
      elseif command == 2 and IsTurning() == false then
        CastRaze(2)
        Sleep(1000,"CastCheck")
        command = 3
      elseif command == 3 and Animations.getDuration(Raze2) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) > 250 then
        me:Stop()
        command = 0
      elseif command == 3 and Animations.getDuration(Raze2) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) <= 250 then
        command = 0
        Sleep(9000,"raze2cd")
        Sleep(170,"CastDelay")
      elseif command == 3 and Raze2.cd >= 0 and SleepCheck("CastCheck") then
        command = 0
      end
    elseif distance <= 900 and distance >= 500 and Raze3 and Raze3:CanBeCast() and SleepCheck("raze3cd") and SleepCheck("CastDelay") then
      if Animations.getDuration(Raze3) > 0 and (me:FindRelativeAngle(xyz1) > 1 or me:FindRelativeAngle(xyz1) < -1) then
        me:Stop()
        command = 0
      elseif command == 1 then
        me:Stop()
        mypos = nil
        me:Move(xyz)
        command = 2
      elseif command == 2 and IsTurning() == false then
        CastRaze(3)
        Sleep(1000,"CastCheck")
        command = 3
      elseif command == 3 and Animations.getDuration(Raze3) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) > 250 then
        me:Stop()
        command = 0
      elseif command == 3 and Animations.getDuration(Raze3) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) <= 250 then
        command = 0
        Sleep(9000,"raze3cd")
        Sleep(170,"CastDelay")
      elseif command == 3 and Raze3.cd >= 0 and SleepCheck("CastCheck") then
        command = 0
      end
    elseif command == 1 then
      command = 0
    end
  end

  --Damage calculator
  if ult.level > 0 then
    local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,illusion=false,team=me:GetEnemyTeam()})
    local stacks = me:FindModifier("modifier_nevermore_necromastery")
    local numberofstacks = 0
    if stacks then
      numberofstacks = me:FindModifier("modifier_nevermore_necromastery").stacks
    end
    for i,v in ipairs(enemies) do
      local OnScreen = client:ScreenPosition(v.position)
      if OnScreen then
        if v.healthbarOffset ~= -1 then
          local hand = v.handle
          if hand ~= me.handle then
            if not hero[hand] then
              hero[hand] = drawMgr:CreateText(25*monitor,-55*monitor, 0x00FFFFAA, "",F14)
              hero[hand].visible = false
              hero[hand].entity = v
              hero[hand].entityPosition = Vector(0,0,v.healthbarOffset)
            end
            if v.alive and v.visible  then
              local totaldamage = wavedamage[ult.level]*numberofstacks/2 + 50
              local magicdmgreduction = (1 - v.magicDmgResist)
              if ethereal and not v:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
                totaldamage = totaldamage + 2*me.agilityTotal + 75
                magicdmgreduction = (1 + 0.4)*magicdmgreduction
              end
              local damage = totaldamage*magicdmgreduction
              hero[hand].visible = true
              if v.health - damage < 0 then
                hero[hand].text = "Killable"
              else
                hero[hand].text = "HP left: "..math.ceil(v.health - damage)
              end
            elseif hero[hand].visible then
              hero[hand].visible = false
            end
          end
        end
      end
    end
  end

  if ignore then
    return
  end

  if not expired then
    statusText3.visible = true
    statusText4.visible = true
    statusText5.visible = true
    statusText6.visible = true
    statusText7.visible = true
    timeremain = math.ceil(30 - client.gameTime)
    statusText7.text = "These messages will disappear in " .. (timeremain) .. " seconds"
    if timeremain < 1 then
      expired = true
    end
  elseif expired then
    statusText3.visible = false
    statusText4.visible = false
    statusText5.visible = false
    statusText6.visible = false
    statusText7.visible = false
    ignore = true
  end
end

function IsTurning()
  local me = entityList:GetMyHero()
  if mypos == nil then
    mypos = me.position
  elseif me.position == mypos then
    return true
  else
    return false
  end
end

function FindAngleBetween(first, second)
  if not first.x then first = first.position end if not second.x then second = second.position end
  xAngle = math.deg(math.atan(math.abs(second.x - first.x)/math.abs(second.y - first.y)))
  if first.x <= second.x and first.y >= second.y then
    return 90 - xAngle
  elseif first.x >= second.x and first.y >= second.y then
    return xAngle + 90
  elseif first.x >= second.x and first.y <= second.y then
    return 270 - xAngle
  elseif first.x <= second.x and first.y <= second.y then
    return xAngle + 270
  end
  return nil
end

function FindAngleR(entity)
  if entity.rotR < 0 then
    return math.abs(entity.rotR)
  else
    return 2 * math.pi - entity.rotR
  end
end

function LuaEntityAbility:CanBeCast()
  return self.cd == 0 and entityList:GetMyHero().mana >= self.manacost and self.level > 0
end

function CastRaze(number)
  local me = entityList:GetMyHero()
  local target = targetFind:GetClosestToMouse(100)
  local Raze = me:GetAbility((number))
  if target then
    me:CastAbility(Raze)
  end
end

function onClose()
  collectgarbage("collect")
  if registered then
    statusText3.visible = false
    statusText4.visible = false
    statusText5.visible = false
    statusText6.visible = false
    statusText7.visible = false
    timeremain = nil
    expired = false
    ignore = false
    effect = false
    command = 0
    mypos = nil
    init = false
    Awesome = true
    Default = false
    Off = false
    for i=1,3 do
      razes[i] = nil
    end
    if eff ~= nil then
      eff = nil
    end
    script:UnregisterEvent(Main)
    script:UnregisterEvent(Key)
    script:RegisterEvent(EVENT_TICK,onLoad)
    registered = false
  end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
