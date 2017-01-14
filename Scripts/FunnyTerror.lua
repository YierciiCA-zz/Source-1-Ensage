--<<This is a beta version, will supplement refinement.It made for myself...>>
--[[Blink,Ult,Dagon.]]--
require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("KiddingTerror")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
 
ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Blink","UseBlink",SGC_TYPE_TOGGLE,false,true,nil)
 
 
local play, target, castQueue, castsleep, sleep = false, nil, {}, 0, 0
 
function Main(tick)
    if not PlayingGame() then return end
        local me = entityList:GetMyHero()
        local ID = me.classId if ID ~= myhero then return end
        for i=1,#castQueue,1 do
                local v = castQueue[1]
                table.remove(castQueue,1)
                local ability = v[2]
                if type(ability) == "string" then
ability = me:FindItem(ability)
                end
                if ability and ((me:SafeCastAbility(ability,v[3],false)) or (v[4] and ability:CanBeCasted())) then
                        if v[4] and ability:CanBeCasted() then
me:CastAbility(ability,v[3],false)
                        end
castsleep = tick + v[1]
                        return
						
                end
        end

   if ScriptConfig.Hotkey and tick > sleep then
		target = targetFind:GetClosestToMouse(100)
                if (target and target.alive and target.health > 0) and GetDistance2D(me,target) <= 1500 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() then
                        local Q, W, R  = me:GetAbility(1), me:GetAbility(2), me:GetAbility(4)
                        local distance = GetDistance2D(me,target)
                        local dagon = me:FindDagon()
                        local linkens = target:IsLinkensProtected()
                        local blink = me:FindItem("item_blink")
                        local attackRange = me.attackRange
                        local RangeBlink = 1180
                        if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase and me.health/me.maxHealth <= 0.4 and R.level > 0 then
                                table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
                        end
                        if Q and Q:CanBeCasted() and me:CanCast() and linkens then
                                table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target})
                        end
                        if  not linkens and target.health/target.maxHealth < 0.4 and me.health/me.maxHealth > 0.7 then
							if not target:DoesHaveModifier("modifier_nyx_assassin_spiked_carapace") and not target:IsLinkensProtected() then
										me:CastAbility(dagon,target)
							end
						end
						if  R and R:CanBeCasted() and me:CanCast() and not linkens and target.health/target.maxHealth > 0.7 and me.health/me.maxHealth <= 0.4 and R.level > 0  then
								table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target})
						end
			if target and distance <= 1500  then
				if distance > 350 and SleepCheck("all") then
					me:Follow(target)
					Sleep(client.latency+350,"all")
				end
				if distance < 600 and SleepCheck("all") then
					me:Attack(target)
					Sleep(client.latency+185,"all")
				end
			end
			else
				me:Move(client.mousePosition)
sleep = tick + 170
                end
        end
end



function Load()
        if PlayingGame() then
                local me = entityList:GetMyHero()
                if not me or me.classId ~= CDOTA_Unit_Hero_Terrorblade then
script:Disable()
                else
play, target, myhero = true, nil, me.classId
ScriptConfig:SetVisible(true)
script:RegisterEvent(EVENT_TICK, Main)
script:UnregisterEvent(Load)
                end
        end
end
 
function Close()
target, myhero = nil, nil
ScriptConfig:SetVisible(false)
        collectgarbage("collect")
        if play then
script:UnregisterEvent(Main)
script:RegisterEvent(EVENT_TICK,Load)
play = false
        end
end
 
script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
