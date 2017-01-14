--<<Use auto armlet at your own risk.)>>
require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig2")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("HuskarOneLife")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("Hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,68)
ScriptConfig:AddParam("Ult","Ultimate",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Diffusal","diff",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Cheese","Cheese",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("BkB","BkB",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("Mail","Mail",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("ArmletTogle","ArmletTogle",SGC_TYPE_TOGGLE,false,true,nil)

local play, target, castQueue, castsleep, sleep = false, nil, {}, 0, 0

hp = 250
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
		if target and GetDistance2D(target,me) <= 2000  and not target:IsMagicImmune() and target:CanDie() then
			local Q, W, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(4)
			local distance = GetDistance2D(target,me)
			local attackRange = me.attackRange	
			local bkb = me:FindItem("item_black_king_bar")
			local mail = me:FindItem("item_blade_mail")
			local halberd = me:FindItem("item_heavens_halberd")
			local abyssal = me:FindItem("item_abyssal_blade")
			local ethereal = me:FindItem("item_ethereal_blade")
			local mom = me:FindItem("item_mask_of_madness")
			local soulring = me:FindItem("item_soul_ring")
			local satanic = me:FindItem("item_satanic")
			local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
			local diffusal = me:FindItem("item_diffusal_blade") or me:FindItem("item_diffusal_blade_2")
			local wand = me:FindItem("item_magic_wand")
			local stick = me:FindItem("item_magic_stick")
			local cheese = me:FindItem("item_cheese")
			local linkens = target:IsLinkensProtected()
			local actv = me:DoesHaveModifier("modifier_item_armlet_unholy_strength")
			local armlet = me:FindItem("item_armlet")
			local D_lay = 1000
			local idmg = 0
			if abyssal and abyssal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(abyssal:FindCastPoint()*1000),abyssal,target})
			end
			if (ScriptConfig.Diffusal) and diffusal and diffusal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(diffusal:FindCastPoint()*800),diffusal,target})
			end
			if W and W:CanBeCasted() and me:CanCast() then 
				table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W,target})
			end
			if ethereal and ethereal:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
			end
			if Q and Q:CanBeCasted() and me:CanCast() and me.health/me.maxHealth <= 0.4  then 
				table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,me})
			end
			if mom and mom:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(mom:FindCastPoint()*1000),mom})        
			end
			if me.mana < me.maxMana*0.5 and  soulring and soulring:CanBeCasted() then
				table.insert(castQueue,{100,soulring})
			end
			if halberd and halberd:CanBeCasted() and me:CanCast() then
				table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,target})
			end
			if (ScriptConfig.Ult) and R and R:CanBeCasted() and me:CanCast() and not linkens then
				table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target})
			end
			if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+200 then
				table.insert(castQueue,{100,satanic})
			end
			if (ScriptConfig.Cheese) and cheese and cheese:CanBeCasted() and me.health/me.maxHealth <= 0.2 and distance <= attackRange+600 then
				table.insert(castQueue,{100,cheese})
			end	
			if wand and wand:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600 then
				table.insert(castQueue,{100,wand})
			end	
			if (ScriptConfig.ArmletTogle) and armlet and armlet:CanBeCasted() and not actv and not me:IsInvisible() and SleepCheck() and distance <= attackRange+800 and me.health/me.maxHealth <= 1 then
				me:SafeCastItem("item_armlet")
				Sleep(D_lay)
			end
			if (ScriptConfig.ArmletTogle) and armlet and armlet:CanBeCasted() and SleepCheck() and me.health < hp and(math.max(me.health - 475,1) - idmg) and not me:IsInvisible() and distance <= attackRange+2500 then
				if actv then
					me:SafeCastItem("item_armlet")
					me:SafeCastItem("item_armlet")
					Sleep(D_lay*2)
				else
					me:SafeCastItem("item_armlet")
					Sleep(D_lay*2)
				end
			end
			if stick and stick:CanBeCasted() and me.health/me.maxHealth <= 0.3 and distance <= attackRange+600 then
				table.insert(castQueue,{100,stick})
			end	
			if (ScriptConfig.BkB) and bkb and bkb:CanBeCasted() then
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 800 end)
				if #heroes == 3 then
					table.insert(castQueue,{100,bkb})
				elseif #heroes == 4 then
					table.insert(castQueue,{100,bkb})
				elseif #heroes == 5 then
					table.insert(castQueue,{100,bkb})
				return
				end
			end
			if (ScriptConfig.Mail) and mail and mail:CanBeCasted() then
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 700 end)
				if #heroes == 3 then
					table.insert(castQueue,{100,mail})
				elseif #heroes == 4 then
					table.insert(castQueue,{100,mail})
				elseif #heroes == 5 then
					table.insert(castQueue,{100,mail})
				return
				end
			end
			if not slow then
				me:Attack(target)
			elseif slow then
				me:Follow(target)
			end
			sleep = tick + 150
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Huskar then 
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
