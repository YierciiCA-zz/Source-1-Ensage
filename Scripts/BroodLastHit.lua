--<<Spider LastHit: Beta version. V.0.4.6 >>
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.Skillshot")
 
config = ScriptConfig.new()
config:SetParameter("Spider", "D", config.TYPE_HOTKEY)
config:SetParameter("Chase", "F", config.TYPE_HOTKEY)
config:SetParameter("ChaseSpider", "E", config.TYPE_HOTKEY)
config:SetParameter("DenyWithSpider", true)
config:SetParameter("LastHitWithSpider", true)
config:SetParameter("UseQlasthit", true)
config:Load()
 
local play, target, castQueue, castsleep, sleep = false, nil, {}, 0, 0

 
local spidersLastHit = config.LastHitWithSpider
local spidersDeny = config.DenyWithSpider
local spidersQ = config.UseQlasthit
local damage = 88
local damageSp = 38

 
 
local KeyUp = config.Spider
local Spider = false
local play = false
 
local x,y = 220,15
local monitor = client.screenSize.x/1600
local font = drawMgr:CreateFont("font","Verdana",12,300)
local statusText = drawMgr:CreateText(x*monitor,y*monitor,0x66FF33FF,"(" .. string.char(KeyUp) .. ")It is time to LastHit.",font) statusText.visible = false
 
local me = entityList:GetMyHero()
 
function Key(msg, code)

    if client.chat or client.console or client.loading then return end 


    if IsKeyDown(KeyUp) then 
        Spider = not Spider

        if Spider  then
            statusText.text = "(" ..string.char(KeyUp) .. ") LastHit Spider Active"
            Spider = true
        else
            statusText.text = "(" ..string.char(KeyUp) .. ") LastHit Spider UnActive"
            Spider = false
        end
		
    end
end
 
 

function Main(tick)
if Spider and not (IsKeyDown(config.Chase) or IsKeyDown(config.ChaseSpider)) and tick > sleep and not client.paused then
    if client.pause or client.shopOpen or not SleepCheck() then return end
	
				local creeps = entityList:GetEntities(function (v) return ((v.courier and v.team == me:GetEnemyTeam()) or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Venomancer_PlagueWard or v.classId == CDOTA_BaseNPC_Warlock_Golem or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar and v.team == me:GetEnemyTeam()) or v.classId == CDOTA_Unit_Undying_Zombie or v.classId == CDOTA_Unit_SpiritBear or (v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.alive and v.health > 0  end)
		local creep = entityList:GetEntities(function (v) return ( v.classId == CDOTA_BaseNPC_Warlock_Golem or v.classId == CDOTA_BaseNPC_Creep_Lane   or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team == me:GetEnemyTeam() or v.classId == CDOTA_BaseNPC_Creep_Neutral  and v.alive and v.health > 20  end)
		local Spiderlings = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, alive=true})
		local Spiderlow = entityList:GetEntities(function (v) return ( v.classId == CDOTA_Unit_Broodmother_Spiderling) and v.alive and v.health < 70  end)
		local Q = me:GetAbility(1)
		local Soul = me:FindItem("item_soul_ring")
		local Qlvl = {74,149,224,299}
		local SoulLvl = {120,190,270,360}
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,visible = true, alive = true, team = me:GetEnemyTeam(),illusion=false})
		if spidersQ and me.alive then
			for i,v in ipairs(creep) do
			--	for i,x in ipairs(enemies) do
				--if me:GetDistance2D(x) <= 600 then
                local offset = v.healthbarOffset
                if offset == -1 then return end
               if v.visible and v.alive  then
					if Q and Q:CanBeCasted() and Q.level > 0 and v.health < Qlvl[Q.level]  and me:GetDistance2D(v) <= 600 then
					local me = entityList:GetMyHero()
						for l,tr in ipairs(creep) do
							if  me:GetDistance2D(v) <= 600 and SleepCheck("tr.handle") then
								me:CastAbility(me:GetAbility(1),v)
								Sleep(client.latency+600,"tr.handle")
							end
						end
					end	
					if Q and Soul and Q.level > 0 and Q:CanBeCasted() and Soul:CanBeCasted() and v.health < SoulLvl[Q.level] and me:GetDistance2D(v) <= 600 then
					local me = entityList:GetMyHero()
						for l,tr in ipairs(creep) do
							if  me:GetDistance2D(v) <= 600 and SleepCheck("tr.handle") then
								me:SafeCastItem(Soul.name)
								Sleep(client.latency+600,"tr.handle")
							end
						end
					end	
				end
		--	end
		--end
		end
		end
		if #Spiderlings > 6 then
		for i,v in ipairs(enemies) do
			if v.health > 0 and v.health/v.maxHealth <= 0.4 then
				for l,tr in ipairs(Spiderlings) do
					if GetDistance2D(tr,v) < 700 then
						tr:Attack(v)
					end
				end
			end
		end
		end
        for i,v in ipairs(creeps) do
        local offset = v.healthbarOffset
        if offset == -1 then return end
           if v.visible and v.alive  then
               if spidersLastHit  and v.health < (damage+10*(1-v.dmgResist))+88 then
                     for l,tr in ipairs(Spiderlings) do
                       if  v:GetDistance2D(tr) <= 700 then
							tr:Attack(v)
                       end
                    end
               end
           end
        end
		if #Spiderlow < 7 then
        for i,v in ipairs(Spiderlings) do
        local offset = v.healthbarOffset
        if offset == -1 then return end
            if v.visible and v.alive  then
                if spidersDeny  and v.health < (damageSp+10*(1-v.dmgResist))+38 then
                    for l,tr in ipairs(Spiderlings) do
                        if v:GetDistance2D(tr) <= 700 then
							tr:Attack(v)
						end
					end
				end
			end
        end
		end
	sleep = tick + 400
	end
end

function Combo(tick)
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

	local attackRange = me.attackRange	

	if IsKeyDown(config.Chase) and not client.chat and not client.paused then	
		v = targetFind:GetClosestToMouse(900)
		
		if v and GetDistance2D(me,v) <= 2000 then
			if tick > sleep then
					local tr = entityList:GetMyPlayer()
					local Q, W, R = me:GetAbility(1), me:GetAbility(2), me:GetAbility(4)
					local butterfly = me:FindItem("item_butterfly")
					local moc = me:FindItem("item_medallion_of_courage") or me:FindItem("item_solar_crest")
					local mom = me:FindItem("item_mask_of_madness")
					local satanic = me:FindItem("item_satanic")
					local atos = me:FindItem("item_rod_of_atos")
					local shiva = me:FindItem("item_shivas_guard")
					local abyssal = me:FindItem("item_abyssal_blade")
					local sheep = me:FindItem("item_sheepstick")
					local halberd = me:FindItem("item_heavens_halberd")
					local soulring = me:FindItem("item_soul_ring")
					local BlackKingBar = me:FindItem("item_black_king_bar") 
					local inv = me:DoesHaveModifier("modifier_broodmother_spin_web_invisible_applier")
					local orchid = me:FindItem("item_orchid")
					local distance = GetDistance2D(me,v)
					local ControlAttack = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, alive=true})
					if inv and v.alive and v.visible then
						if orchid and orchid:CanBeCasted() and me:CanCast() then
							table.insert(castQueue,{math.ceil(orchid:FindCastPoint()*1000),orchid,v})
						end
						if Q and Q:CanBeCasted() and me:CanCast() then
							table.insert(castQueue,{1000+math.ceil(Q:FindCastPoint()*1000),Q,v})
						end
						if shiva and shiva:CanBeCasted() and distance <= 500 and not v:DoesHaveModifier("modifier_item_sheepstick") then
							table.insert(castQueue,{100,shiva})
						end
						if abyssal and abyssal:CanBeCasted() and not v:DoesHaveModifier("modifier_item_sheepstick") and not v:IsStunned() then
							table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),abyssal,v})
						end
						if (ScriptConfig.Butterfly) and  butterfly and butterfly:CanBeCasted() and me.health/me.maxHealth >= 0.7 and distance >= attackRange+800 then
							table.insert(castQueue,{100,butterfly})
						end
						if atos and atos:CanBeCasted() and me:CanCast() then
							table.insert(castQueue,{math.ceil(atos:FindCastPoint()*1000),atos,v})
						end
						if sheep and sheep:CanBeCasted() and me:CanCast() then
							table.insert(castQueue,{math.ceil(sheep:FindCastPoint()*1000),sheep,v})
						end
						if halberd and halberd:CanBeCasted() and distance < halberd.castRange and not v:IsStunned() and not v:DoesHaveModifier("modifier_item_sheepstick") then
							table.insert(castQueue,{1000+math.ceil(halberd:FindCastPoint()*1000),halberd,v})
						end
						if moc and moc:CanBeCasted() and distance < moc.castRange then
							table.insert(castQueue,{1000+math.ceil(moc:FindCastPoint()*1000),moc,v})
						end
						if mom and mom:CanBeCasted() and distance <= attackRange+200 then
							table.insert(castQueue,{100,mom})
						end
						if R and R:CanBeCasted() and R.cd > 5 and me.health > 800 then
							table.insert(castQueue,{100,R})
						end
						local Spiderlings = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, team=me.team, alive=true})
						
						if #Spiderlings > 6 then
							local t = targetFind:GetClosestToMouse(900)
						
						if v and v.alive and SleepCheck("w") then
							local z = tr.selection
						for i,c in pairs(tr.selection) do tr:Unselect(c) end
						for i,c in pairs(Spiderlings) do
						if SleepCheck(c.handle) then
							tr:SelectAdd(c)
						end
						end
							tr:Attack(t)
							SelectBack(z)
						Sleep(500, "w")
						end
						end
						if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.4 and distance <= attackRange+50 then
							table.insert(castQueue,{100,satanic})
						end
						if BlackKingBar and BlackKingBar:CanBeCasted() and not inv then
							local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
							if #heroes > 3 then
								table.insert(castQueue,{100,BlackKingBar})
								return
							end
						end
					end
						if v and distance <= 1500  then
							if distance > 350 and SleepCheck("all") then
								tr:Follow(v)
									Sleep(client.latency+200,"all")
							end
							if distance < 400 and SleepCheck("all") then
								tr:Attack(v)
									Sleep(client.latency+300,"all")
							end
						end
					sleep = tick + 300	
				end	
			end
		end	
	
	if IsKeyDown(config.ChaseSpider) and not client.chat and not client.paused then
		if tick > sleep then
			local Spiderlings = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, team=me.team, alive=true})
			local tr = entityList:GetMyPlayer()
					if #Spiderlings > 6 then
							local t = targetFind:GetClosestToMouse(900)
						
						if v and v.alive and SleepCheck("w") then
							local z = tr.selection
						for i,c in pairs(tr.selection) do tr:Unselect(c) end
						for i,c in pairs(Spiderlings) do
						if SleepCheck(c.handle) then
							tr:SelectAdd(c)
						end
						end
							tr:Attack(t)
							SelectBack(z)
						Sleep(500, "w")
						end
				sleep = tick + 300
			end
		end
	end
end





function Load()
    if PlayingGame() then
                local me = entityList:GetMyHero()
                if not me or me.classId ~= CDOTA_Unit_Hero_Broodmother or not client.connected or client.loading or client.console then
				script:Disable()
        else
			statusText.visible = true
			play, target, myhero = true, nil, me.classId
			script:RegisterEvent(EVENT_TICK, Main)
			script:RegisterEvent(EVENT_TICK, Combo)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
        end
    end
end
 
 
 
function Close()
target, myhero = nil, nil
        collectgarbage("collect")
        if play then
script:UnregisterEvent(Main)
script:UnregisterEvent(Key)
statusText.visible = false
script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_TICK,Combo)
play = false
        end
end
 
script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
