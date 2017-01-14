require("libs.Utils")
require("libs.TargetFind")
require("libs.ScriptConfig")
require("libs.Skillshot")

local config = ScriptConfig.new()
config:SetParameter("HotKey", "D", config.TYPE_HOTKEY)
config:Load()

local play = false local target = nil local castQueue = {} local sleep = {0,0,0}

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
			sleep[2] = tick + v[1] + client.latency
			return
		end
	end

	if IsKeyDown(config.HotKey) and not client.chat then
		target = targetFind:GetClosestToMouse(100)
		if tick > sleep[1] then
			if target and target.alive and target.visible and GetDistance2D(target,me) <= 2000 and not target:DoesHaveModifier("modifier_item_blade_mail_reflect") and not target:DoesHaveModifier("modifier_item_lotus_orb_active") and not target:IsMagicImmune() and target:CanDie() then
				local Q = me:GetAbility(1)
				local W = me:GetAbility(2)
				local R = me:GetAbility(5)
				local distance = GetDistance2D(target,me)
				local dagon = me:FindDagon()
				local ethereal = me:FindItem("item_ethereal_blade")
				local veil = me:FindItem("item_veil_of_discord")
				local atos = me:FindItem("item_rod_of_atos")
				local eul = me:FindItem("item_cyclone")
				local orchid = me:FindItem("item_orchid")
				local shiva = me:FindItem("item_shivas_guard")
				local sheep = me:FindItem("item_sheepstick")
				local soulring = me:FindItem("item_soul_ring")
				local arcane = me:FindItem("item_arcane_boots")
				local slow = target:DoesHaveModifier("modifier_item_ethereal_blade_slow")
				local linkens = target:IsLinkensProtected()
				local blink = me:FindItem("item_blink")
				local attackRange = me.attackRange	
				local RangeBlink = 1600
				if (ScriptConfig.Blink) and GetDistance2D(me,target) <= RangeBlink and blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and not blink.abilityPhase then
				table.insert(castQueue,{1000+math.ceil(blink:FindCastPoint()*1000),blink,target.position})        
				end
				if orchid and orchid:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,target})
				end
				if shiva and shiva:CanBeCasted() and distance <= 600 then
					table.insert(castQueue,{100,shiva})
				end
				if orchid and not eul and orchid:CanBeCasted() and me:CanCast() and linkens then
					me:CastAbility(orchid,target)
				end
				if ethereal and ethereal:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(ethereal:FindCastPoint()*1000),ethereal,target})
				end
				if dagon and dagon:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(dagon:FindCastPoint()*1000),dagon,target})
				end
				if sheep and sheep:CanBeCasted() and me:CanCast() and not linkens  then
					table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*800),sheep,target})
				end
				if atos and not eul and atos:CanBeCasted() and me:CanCast() and linkens then
					me:CastAbility(atos,target)
				end
				if atos and atos:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,target})
				end
				if eul and eul:CanBeCasted() and me:CanCast() and linkens then
					me:CastAbility(eul,target)
				end
				if Q and Q:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,target.position})
				end
				if distance <= 399 and W and W:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(W:FindCastPoint()*1000),W})        
				end
				if veil and veil:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(veil:FindCastPoint()*1000),veil,target.position})        
				end
				if me.mana < me.maxMana*0.5 and ScriptConfig.Arcan and arcane and arcane:CanBeCasted() then
					table.insert(castQueue,{100,arcane})
				end
				if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
					table.insert(castQueue,{100,soulring})
				end
				if R and R:CanBeCasted() and me:CanCast() then
					table.insert(castQueue,{1000+math.ceil(R:FindCastPoint()*1000),R,target.position})    
				end
				if not slow then
					me:Attack(target)
				elseif slow then
					me:Follow(target)
				end
				sleep[1] = tick + 100
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Puck then 
			script:Disable()
		else
			play = true
			target = nil
			myhero = me.classId
			script:RegisterEvent(EVENT_FRAME, Main)
			script:UnregisterEvent(Load)
		end
	end
end

function Close()
	target = nil 
	myhero = nil
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close) 
script:RegisterEvent(EVENT_TICK, Load)
