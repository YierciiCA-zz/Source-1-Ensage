--<<                   Nova's Tread Switcher                         >>
--[[

             
              ╔════════════════════════════════════════════════════════════════════════╗     
                 NOVA's TreadSwitcher Revision 1//

                      This will -
                        - Change to INT before casting
                        - Change to STR on movement (If not already)
                        - Change to AGI when being healed/regenerating
                        - Change to AGI on attack (Optional, Toggle in Script-Config)
                        - Will work for all heroes
                        - Supports QuickCasting (Select in Config)
                        - Supports custom hotkeys (Choose in Config)
              ╚════════════════════════════════════════════════════════════════════════╝

]]--
--Libraries
require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Ability1", "Q", config.TYPE_HOTKEY)
config:SetParameter("Ability2", "W", config.TYPE_HOTKEY)
config:SetParameter("Ability3", "E", config.TYPE_HOTKEY)
config:SetParameter("Ability4", "D", config.TYPE_HOTKEY)
config:SetParameter("Ability5", "F", config.TYPE_HOTKEY)
config:SetParameter("AbilityUltimate", "R", config.TYPE_HOTKEY)
config:SetParameter("QuickCasting", false, config.TYPE_BOOL)
config:SetParameter("AgilityOnAttack", false, config.TYPE_BOOL)
config:Load()

local AbilityKey1     = config.Ability1
local AbilityKey2     = config.Ability2
local AbilityKey3     = config.Ability3
local AbilityKey4     = config.Ability4
local AbilityKey5     = config.Ability5
local AbilityUltimate = config.AbilityUltimate
local quickcasting    = config.QuickCasting
local AgilAttack      = config.AgilityOnAttack

local registered	= false
local current     = 0
local active      = false
local Healing     = false
local Spell       = nil

function onLoad()
  if PlayingGame() then
    local me = entityList:GetMyHero()
    if not me then
      script:Disable()
    else
      registered = true
      script:RegisterEvent(EVENT_TICK,Main)
      script:RegisterEvent(EVENT_KEY,Key)
      script:UnregisterEvent(onLoad)
    end
  end
end

function Key(msg, code)
  if client.chat or client.console or client.loading then return end

  local me = entityList:GetMyHero()
  local mp = entityList:GetMyPlayer()
  if not me then return end

  local pt = me:FindItem("item_power_treads")
  if not pt then return end
  
  if mp.selection[1].name ~= me.name then return end
  
  if not me.alive then return end
  if me:IsInvisible() then return end
  
  if IsKeyDown(17) or code == 18 then return end
  
  if not quickcasting and pt then
    if code == AbilityKey1 then
      Spell = me:GetAbility(1)
      active = true
      current = 0
      if Spell and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
        return true
      end
    end

    if code == AbilityKey2 then
      Spell = me:GetAbility(2)
      active = true
      current = 0
      if Spell and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
        return true
      end
    end

    if code == AbilityKey3 then
      Spell = me:GetAbility(3)
      active = true
      current = 0
      if Spell and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
        return true
      end
    end

    if code == AbilityKey4 then
      Spell = me:GetAbility(4)
      active = true
      current = 0
      if Spell and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
        return true
      end
    end

    if code == AbilityKey5 then
      Spell = me:GetAbility(5)
      active = true
      current = 0
      if Spell and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
        return true
      end
    end

    if code == AbilityUltimate then
      Spell = me:GetAbility(GetUltimate())
      active = true
      current = 0
      if Spell and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
        return true
      end
    end

    if active and msg == RBUTTON_DOWN then
      rightclick = true
    elseif not active and msg == RBUTTON_DOWN and pt.bootsState ~= 0  and Healing == false then
      me:SetPowerTreadsState(0)
    end
  end

  if quickcasting and pt then
    if code == AbilityKey1 then
      Spell = me:GetAbility(1)
      active = true
      return true
    end

    if code == AbilityKey2 then
      Spell = me:GetAbility(2)
      active = true
      return true
    end

    if code == AbilityKey3 then
      Spell = me:GetAbility(3)
      active = true
      return true
    end

    if code == AbilityKey4 then
      Spell = me:GetAbility(4)
      active = true
      return true
    end

    if code == AbilityKey5 then
      Spell = me:GetAbility(5)
      active = true
      return true
    end

    if code == AbilityUltimate then
      Spell = me:GetAbility(GetUltimate())
      active = true
      return true
    end

    if active and msg == RBUTTON_DOWN then
      rightclick = true
    elseif not active and msg == RBUTTON_DOWN and pt.bootsState ~= 0 and Healing == false then
      me:SetPowerTreadsState(0)
    end

  end

end

function Main(tick)
  if not SleepCheck() then return end

  local me = entityList:GetMyHero()
  if not me then return end

  local mp = entityList:GetMyPlayer()

  local pt = me:FindItem("item_power_treads")
  if not pt then return end

  local mOver = entityList:GetMouseover()
  
  if not me.alive then return end
  if me:IsInvisible() then return end
  
  if active and current == 0 and (Spell and (Spell.manacost == 0 or Spell.cd > 0)) then NormalCast() return end

  if (me:DoesHaveModifier("modifier_bottle_regeneration")
    or me:DoesHaveModifier("modifier_flask_healing")
    or me:DoesHaveModifier("modifier_clarity_potion")
    or me:DoesHaveModifier("modifier_tango_heal")
    or me:DoesHaveModifier("modifier_fountain_aura_buff")) and pt and pt.bootsState ~= 2 and not active and not me:IsChanneling() then
    me:SetPowerTreadsState(2)
    Sleep(400)
  elseif AgilAttack and pt and pt.bootsState ~= 2 and mp.orderId == Player.ORDER_ATTACKENTITY and not active and not me:IsChanneling() then
    me:SetPowerTreadsState(2)
    Sleep(400)
  elseif (me:DoesHaveModifier("modifier_bottle_regeneration")
    or me:DoesHaveModifier("modifier_flask_healing")
    or me:DoesHaveModifier("modifier_clarity_potion")
    or me:DoesHaveModifier("modifier_tango_heal")
    or me:DoesHaveModifier("modifier_fountain_aura_buff")) and pt and pt.bootsState == 2 and not active and not me:IsChanneling() then
    Healing = true
  elseif Healing == true then
    Healing = false
  end

  if active and not quickcasting then
    if current == 0 and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
      if pt.bootsState == 2 then
        me:CastAbility(pt)
        me:CastAbility(pt)
        me:CastAbility(Spell)
        current = 1
      elseif pt.bootsState == 0 then
        me:CastAbility(pt)
        me:CastAbility(Spell)
        current = 1
      elseif pt.bootsState == 1 then
        me:CastAbility(Spell)
        current = 1
      end
      Sleep(Spell:FindCastPoint()*1000 + 800,"Reset")
    elseif current == 0 and not Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
      if pt.bootsState == 2 then
        me:CastAbility(pt)
        me:CastAbility(pt)
        Sleep(500)
      elseif pt.bootsState == 0 then
        me:CastAbility(pt)
        Sleep(500)
      elseif pt.bootsState == 1 then
        current = 1
      end
      Sleep(Spell:FindCastPoint()*1000 + 800,"Reset")
    elseif current == 1 and rightclick then
      me:SetPowerTreadsState(0)
      current = 0
      active = false
      rightclick = false
    elseif SleepCheck("Reset") and current == 1 and Spell.cd > 0 and not me:IsChanneling() then
      me:SetPowerTreadsState(0)
      current = 0
      active = false
    end
  end

  if active and quickcasting then
    if Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and current == 0 then
      if pt.bootsState == 2 then
        me:CastAbility(pt)
        me:CastAbility(pt)
        me:CastAbility(Spell)
        current = 1
        Sleep(100)
      elseif pt.bootsState == 0 then
        me:CastAbility(pt)
        me:CastAbility(Spell)
        current = 1
        Sleep(100)
      elseif pt.bootsState == 1 then
        me:CastAbility(Spell)
        current = 1
        Sleep(100)
      end
      Sleep(Spell:FindCastPoint()*1000 + 800,"Reset")
    elseif Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) and current == 0 and mOver ~= nil then
      if pt.bootsState == 2 then
        me:CastAbility(pt)
        me:CastAbility(pt)
        me:CastAbility(Spell,mOver)
        current = 1
        Sleep(100)
      elseif pt.bootsState == 0 then
        me:CastAbility(pt)
        me:CastAbility(Spell,mOver)
        current = 1
        Sleep(100)
      elseif pt.bootsState == 1 then
        me:CastAbility(Spell,mOver)
        current = 1
        Sleep(100)
      end
      Sleep(Spell:FindCastPoint()*1000 + 800,"Reset")
    elseif Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) and current == 0 then
      if pt.bootsState == 2 then
        me:CastAbility(pt)
        me:CastAbility(pt)
        me:CastAbility(Spell,client.mousePosition)
        current = 1
        Sleep(100)
      elseif pt.bootsState == 0 then
        me:CastAbility(pt)
        me:CastAbility(Spell,client.mousePosition)
        current = 1
        Sleep(100)
      elseif pt.bootsState == 1 then
        me:CastAbility(Spell,client.mousePosition)
        current = 1
        Sleep(100)
      end
      Sleep(Spell:FindCastPoint()*1000 + 800,"Reset")
    elseif current == 1 then
      ShiftCheck = Spell
      current = 2
    elseif ShiftCheck ~= Spell and not SleepCheck("Reset") then
      current = 0
    elseif current == 2 and rightclick then
      me:CastAbility(pt)
      me:CastAbility(pt)
      current = 0
      rightclick = false
      active = false
    elseif current == 2 and (Spell.abilityPhase or Spell:FindCastPoint() == 0) then
      current = 3
    elseif current == 3 and not Spell.abilityPhase and SleepCheck("Reset") and not me:IsChanneling() then
      me:CastAbility(pt)
      me:CastAbility(pt)
      current = 0
      active = false
    end
  end
end

function NormalCast()
  local me = entityList:GetMyHero()
  local mOver = entityList:GetMouseover()
  if not Spell then return end

  if active and quickcasting then
    if Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) then
      me:CastAbility(Spell)
    elseif Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) then
      me:CastAbility(Spell, mOver)
    elseif Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) and mOver then
      me:CastAbility(Spell, mOver)
    elseif Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) then
      me:CastAbility(Spell, client.mousePosition)
    end
    active = false
  elseif active and Spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and not quickcasting then
    me:CastAbility(Spell)
    active = false
  elseif active then
    active = false
  end
end

function GetUltimate()
  local me = entityList:GetMyHero()
  for i=1,6 do
    if me:GetAbility(i).abilityType == LuaEntityAbility.TYPE_ULTIMATE then
      return i
    end
  end
end

function onClose()
  current = 0
  active = false
  Healing = false
  Spell = nil
  collectgarbage("collect")
  if registered then
    script:UnregisterEvent(Main)
    script:UnregisterEvent(Key)
    script:RegisterEvent(EVENT_TICK,onLoad)
    registered = false
  end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
