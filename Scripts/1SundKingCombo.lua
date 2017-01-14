--<<Skript kj2a. Reworked and improved the Vick. USE THE COMBO KEY Ultimate (R)!!!!! >>
require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
me = nil
range = 0
sleepTick = {0,0,0}
Queue = {}
currentTick = nil
lastSpell = nil
Qrange = {350,450,550,650}
x,y = 5,70 -- gui position
myFont = drawMgr:CreateFont("SandKing","Arial",14,400)
statusText = drawMgr:CreateText(x,y,0xffff00ff,"Target: ",myFont);
targetText = drawMgr:CreateText(x+38,y,0xff0000ff,"",myFont);
statusText.visible = false
targetText.visible = false
targetHandle = nil
 
ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("SandKing")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
ScriptConfig:AddParam("combo","Wombo-Combo",SGC_TYPE_ONKEYDOWN,false,false,string.byte(" "))
 
function MainTick(tick)
        if (sleepTick[1] and sleepTick[1] < tick) then
currentTick = tick
        if not client.connected or client.loading or client.console or client.paused then
                        return
                end
me = entityList:GetMyHero()
                if not me then return end
                if not ProcessQueue() then
                        return
                end
               
                if not targetHandle then
targetText.visible = false
statusText.visible = false
                end
       
                if not PlayingGame() then
ScriptConfig:SetVisible(false)
                        return
                end
                if me.name ~= "npc_dota_hero_sand_king" then
ScriptConfig:SetVisible(false)
script:Disable()
                        return
                else
GoUseTick()
                end
        end
end
 
function sleep(i,d)
sleepTick[i] = currentTick + d
end
function ProcessQueue()
    if #Queue == 0 then return true end
target = Queue[1][2]
spell = Queue[1][1]
delay = Queue[1][3]
   if (lastSpell and lastSpell.state == LuaEntityAbility.STATE_COOLDOWN) then table.remove(Queue,1) end
    if  (me.unitState > 33600000 or me.unitState == 16 )and target then
        if currentTick > sleepTick[2] then
sleepTick[2] = currentTick + 500
        end
        return false
    end
Cast(spell,target)
sleep(1,delay)
lastSpell = spell
    table.remove(Queue,1)
end
function QueueSpell(spell,target,delay)
        if spell and spell.state ~= LuaEntityAbility.STATE_COOLDOWN then
                table.insert(Queue, {spell,target,delay})
        end
end
function CastItems(itemList,target,delay)
    for i,name in ipairs(itemList) do
        local item = me:FindItem(name)
        if (item ~= false) then
QueueSpell(item,target,delay)
        end
    end
end
function getPosition(target)
        return Vector(target.x,target.y,target.z)
end
function Cast(spell,target)
    if spell ~= nil and spell.state == LuaEntityAbility.STATE_READY then
        if target then
me:SafeCastAbility(spell,target)
        else
me:SafeCastAbility(spell)
        end
    end
end
 
function GoUseTick()
ScriptConfig:SetVisible(true)
    local _Q = me:GetAbility(1)
        local target = nil
target = targetFind:GetLastMouseOver(1500)
        if not target or not target.visible or not target.alive or not me.alive then
targetHandle = nil
targetText.visible = false
statusText.visible = false
                return
        end    
        if ScriptConfig.combo then
                local blink = me:FindItem("item_blink")
                local veil_of_discord = me:FindItem("item_veil_of_discord")
               
targetText.text = client:Localize(target.name)
targetText.visible = true
statusText.visible = true
targetHandle = target.handle
               
                if  #Queue == 0 then
                        local distance = GetDistance2D(me,target)
                        if _Q.level ~= 0 then
range = Qrange[_Q.level]
                        end
                       
                        if me:DoesHaveModifier("modifier_sand_king_epicenter") then
                                if distance < 800 and veil_of_discord and veil_of_discord.state == LuaEntityAbility.STATE_READY then
me:CastAbility(veil_of_discord,target.position)
sleep(1,100)
                                end
                        end
                       
                        if blink and blink.state == LuaEntityAbility.STATE_READY and (_Q.state == LuaEntityAbility.STATE_READY) and distance-1250 <= range and distance >  range and me:DoesHaveModifier("modifier_sand_king_epicenter") then
me:CastAbility(blink,target.position)
sleep(1,100)
                        end    
                       
                        if distance < range and me:DoesHaveModifier("modifier_sand_king_epicenter") then
QueueSpell(_Q,target,150)
                        end
                       
                        return
                end
               
        end
end
script:RegisterEvent(EVENT_TICK, MainTick)
