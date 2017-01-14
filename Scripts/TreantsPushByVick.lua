--<<Treants Micro-control: Beta version. V0.2 Added LastHit>>
--[[thx MazaiPC for optimized code.]]
require("libs.Utils")
require("libs.ScriptConfig")
 
 
config = ScriptConfig.new()
config:SetParameter("Treants", "D", config.TYPE_HOTKEY)
config:SetParameter("DenyWithTreants", true)
config:SetParameter("LastHitWithTreants", true)
config:Load()
 
local play, target, castQueue, castsleep, sleep = false, nil, {}, 0, 0

 
local treantLastHit = config.LastHitWithTreants
local treantDeny = config.DenyWithTreants
 
local damage = 22
 
local treantsPath = {
top = { --Data: [1],[2],[3],[4],top511,[5],[6],[7]
Vector(-6400, -793, 256),
Vector(-6356, 1141, 256),
Vector(-6320, 3762, 256),
Vector(-5300, 5714, 256),
Vector(-826, 5942, 256),
Vector(1445, 5807, 256),
Vector(3473, 5949, 256)
        },
top511 = Vector(-3104, 5929, 256),
       
mid = { --Data: mid0,[1],[2],[3],[4],[5],[6],mid00
Vector(-4027, -3532, 137),
Vector(-2470, -1960, 127),
Vector(-891, -425, 55),
Vector(1002, 703, 127),
Vector(2627, 2193, 127),
Vector(4382, 3601, 2562)
        },
mid00 = Vector(4873, 4274, 256),
mid0 = Vector(-5589, -5098, 261),
       
bot = { --Data: [1],[2],[3],[4],[5],[6],[7],[8],[9],[10]
Vector(-4077, -6160, 268),
Vector(-1875, -6125, 127),
Vector(325, -6217, 256),
Vector(2532, -6215, 256),
Vector(4736, -6064, 256),
Vector(6090, -4318, 256),
Vector(6180, -2117, 256),
Vector(6242, 84, 256),
Vector(6307, 2286, 141),
Vector(6254, 3680, 256)
        }
} --treantsPath: End
 

 
local KeyUp = config.Treants
local Treants = false
local play = false
 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
 
local x,y = 220,15
local monitor = client.screenSize.x/1600
local font = drawMgr:CreateFont("font","Verdana",12,300)
local statusText = drawMgr:CreateText(x*monitor,y*monitor,0x66FF33FF,"(" .. string.char(KeyUp) .. ")It is time to pushing.",font) statusText.visible = false
 
local me = entityList:GetMyHero()
 
function Key(msg, code)

    if client.chat or client.console or client.loading then return end 


    if IsKeyDown(KeyUp) then 
        Treants = not Treants

        if Treants  then
            statusText.text = "(" ..string.char(KeyUp) .. ") Push Treants Active"
            Treants = true
        else
            statusText.text = "(" ..string.char(KeyUp) .. ") Push Treants UnActive"
            Treants = false
        end

    end
end
 
 
function Main(tick)
        if Treants then
    if client.pause or client.shopOpen or not SleepCheck()  then return end
     local me = entityList:GetMyHero()   
       
       
        -- Get visible treants
        local treants = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep,alive = true,visible = true,controllable=true})
        -- Get treants damage
		local me = entityList:GetMyHero()
        local ID = me.classId if ID ~= myhero then return end
        if me.team == LuaEntity.TEAM_RADIANT and SleepCheck("go") then
                        for i,v in ipairs(treants) do
        if GetDistance2D(me,v) > 580 then
        local trDistance = {
top = { --Data: [1],[2],[3],[4],top511,[5],[6],[7],[8]
GetDistance2D(v,treantsPath.top[1]),
GetDistance2D(v,treantsPath.top[2]),
GetDistance2D(v,treantsPath.top[3]),
GetDistance2D(v,treantsPath.top[4]),
GetDistance2D(v,treantsPath.top[5]),
GetDistance2D(v,treantsPath.top[6]),
GetDistance2D(v,treantsPath.top[7]),
GetDistance2D(v,treantsPath.mid00[8])
                },
top511 = GetDistance2D(v,treantsPath.top511),
               
mid = { --Data: mid0,[1],[2],[3],[4],[5],[6],mid00
GetDistance2D(v,treantsPath.mid[1]),
GetDistance2D(v,treantsPath.mid[2]),
GetDistance2D(v,treantsPath.mid[3]),
GetDistance2D(v,treantsPath.mid[4]),
GetDistance2D(v,treantsPath.mid[5]),
GetDistance2D(v,treantsPath.mid[6])
                },
mid0 = GetDistance2D(v,treantsPath.mid0),
mid00 = GetDistance2D(v,treantsPath.mid00),
               
bot = { --Data: [1],[2],[3],[4],[5],[6],[7],[8],[9],[10]
GetDistance2D(v,treantsPath.bot[1]),
GetDistance2D(v,treantsPath.bot[2]),
GetDistance2D(v,treantsPath.bot[3]),
GetDistance2D(v,treantsPath.bot[4]),
GetDistance2D(v,treantsPath.bot[5]),
GetDistance2D(v,treantsPath.bot[6]),
GetDistance2D(v,treantsPath.bot[7]),
GetDistance2D(v,treantsPath.bot[8]),
GetDistance2D(v,treantsPath.bot[9]),
GetDistance2D(v,treantsPath.bot[10])
                }
        } --trDistance: End
       

       if v.alive then
         if trDistance.top[1] < 3660 and trDistance.top[2] > 2190  then
v:AttackMove(treantsPath.top[1])
Sleep(2000,"go")
                        end
                if trDistance.top[2] < 2400 and trDistance.top[3] > 2490 then
v:AttackMove(treantsPath.top[2])
Sleep(2000,"go")
                end
                if trDistance.top[3] < 2640 and trDistance.top[4] > 2420 then
v:AttackMove(treantsPath.top[3])
Sleep(2000,"go")
                end
                if trDistance.top[4] < 2340 and trDistance.top[5] > 2280 then
v:AttackMove(treantsPath.top[4])
Sleep(2000,"go")
                end
                if trDistance.top511 < 2380 and trDistance.top[5] > 2380 then
v:AttackMove(treantsPath.top[5])
Sleep(2000,"go")
                end
                if trDistance.top[5] < 2380 and trDistance.top[6] > 2380 then
v:AttackMove(treantsPath.top[6])
Sleep(2000,"go")
                end
                if trDistance.top[6] < 2680 and trDistance.top[7] > 2380 then
v:AttackMove(treantsPath.top[7])
Sleep(2000,"go")
                end
                if trDistance.top[7] < 2630 and trDistance.top[8] > 2080 then
v:AttackMove(treantsPath.mid00)
Sleep(2000,"go")
                end
                if trDistance.mid[1] < 3160 and trDistance.mid[2] > 2190 then
v:AttackMove(treantsPath.mid[1])
Sleep(2000,"go")
                        end
                if trDistance.mid[2] < 2400 and trDistance.mid[3] > 2490 then
v:AttackMove(treantsPath.mid[2])
Sleep(2000,"go")
                end
                if trDistance.mid[3] < 2640 and trDistance.mid[4] > 2420 then
v:AttackMove(treantsPath.mid[3])
Sleep(2000,"go")
                end
                if trDistance.mid[4] < 2340 and trDistance.mid[5] > 2280 then
v:AttackMove(treantsPath.mid[4])
Sleep(2000,"go")
                end
                if trDistance.mid[5] < 2380 and trDistance.mid[6] > 2380 then
v:AttackMove(treantsPath.mid[5])
Sleep(2000,"go")
                end
                if trDistance.mid[6] < 2380 and trDistance.mid00 > 2380 then
v:AttackMove(treantsPath.mid[6])
Sleep(2000,"go")
                end
                if trDistance.mid00 < 2630 then
v:AttackMove(treantsPath.mid00)
Sleep(2000,"go")
                end
                if trDistance.bot[1] < 2400 and trDistance.bot[2] > 2490 then
v:AttackMove(treantsPath.bot[1])
Sleep(2000,"go")
                end
                if trDistance.bot[2] < 2640 and trDistance.bot[3] > 2420 then
v:AttackMove(treantsPath.bot[2])
Sleep(2000,"go")
                end
                if trDistance.bot[3] < 2340 and trDistance.bot[4] > 2280 then
v:AttackMove(treantsPath.bot[3])
Sleep(2000,"go")
                end
                if trDistance.bot[4] < 2380 and trDistance.bot[5] > 2380 then
v:AttackMove(treantsPath.bot[4])
Sleep(2000,"go")
                end
                if trDistance.bot[5] < 2380 and trDistance.bot[6] > 2380 then
v:AttackMove(treantsPath.bot[5])
Sleep(2000,"go")
                end
                if trDistance.bot[6] < 2400 and trDistance.bot[7] > 2490 then
v:AttackMove(treantsPath.bot[6])
Sleep(2000,"go")
                end
                if trDistance.bot[7] < 2640 and trDistance.bot[8] > 2420 then
v:AttackMove(treantsPath.bot[7])
Sleep(2000,"go")
                end
                if trDistance.bot[8] < 2340 and trDistance.bot[9] > 2280 then
v:AttackMove(treantsPath.bot[8])
Sleep(2000,"go")
                end
                if trDistance.bot[9] < 2380 and trDistance.bot[10] > 2380 then
v:AttackMove(treantsPath.bot[9])
Sleep(2000,"go")
                end
                if trDistance.bot[10] < 2380 and trDistance.mid00 > 2380 then
v:AttackMove(treantsPath.bot[10])
Sleep(2000,"go")
                        end
                end
        end
end
if me.team == LuaEntity.TEAM_DIRE and SleepCheck("go") then
                        for i,v in ipairs(treants) do
        if GetDistance2D(me,v) > 580 then
       
        local trDistance = {
top = { --Data: [1],[2],[3],[4],top511,[5],[6],[7],[8]
GetDistance2D(v,treantsPath.top[1]),
GetDistance2D(v,treantsPath.top[2]),
GetDistance2D(v,treantsPath.top[3]),
GetDistance2D(v,treantsPath.top[4]),
GetDistance2D(v,treantsPath.top[5]),
GetDistance2D(v,treantsPath.top[6]),
GetDistance2D(v,treantsPath.top[7]),
GetDistance2D(v,treantsPath.mid00)
                },
top511 = GetDistance2D(v,treantsPath.top511),
               
mid = { --Data: mid0,[1],[2],[3],[4],[5],[6],mid00
GetDistance2D(v,treantsPath.mid[1]),
GetDistance2D(v,treantsPath.mid[2]),
GetDistance2D(v,treantsPath.mid[3]),
GetDistance2D(v,treantsPath.mid[4]),
GetDistance2D(v,treantsPath.mid[5]),
GetDistance2D(v,treantsPath.mid[6])
                },
mid0 = GetDistance2D(v,treantsPath.mid0),
mid00 = GetDistance2D(v,treantsPath.mid00),
               
bot = { --Data: [1],[2],[3],[4],[5],[6],[7],[8],[9],[10]
GetDistance2D(v,treantsPath.bot[1]),
GetDistance2D(v,treantsPath.bot[2]),
GetDistance2D(v,treantsPath.bot[3]),
GetDistance2D(v,treantsPath.bot[4]),
GetDistance2D(v,treantsPath.bot[5]),
GetDistance2D(v,treantsPath.bot[6]),
GetDistance2D(v,treantsPath.bot[7]),
GetDistance2D(v,treantsPath.bot[8]),
GetDistance2D(v,treantsPath.bot[9]),
GetDistance2D(v,treantsPath.bot[10])
                }
        } --trDistance: End
       

       
                if trDistance.top[7] < 3660 and trDistance.top[6] > 2190 then
v:AttackMove(treantsPath.top[7])
Sleep(2000,"go")
                        end
                if trDistance.top[6] < 2400 and trDistance.top[5] > 2490 then
v:AttackMove(treantsPath.top[6])
Sleep(2000,"go")
                end
                if trDistance.top[5] < 2640 and trDistance.top511 > 2420 then
v:AttackMove(treantsPath.top[5])
Sleep(2000,"go")
                end
                if trDistance.top511 < 2340 and trDistance.top[4] > 2280 then
v:AttackMove(treantsPath.top[4])
Sleep(2000,"go")
                end
                if trDistance.top[4] < 2380 and trDistance.top[3] > 2380 then
v:AttackMove(treantsPath.top[3])
Sleep(2000,"go")
                end
                if trDistance.top[3] < 2380 and trDistance.top[2] > 2380 then
v:AttackMove(treantsPath.top[2])
Sleep(2000,"go")
                end
                if trDistance.top[2] < 2680 and trDistance.top[1] > 2380 then
v:AttackMove(treantsPath.top[1])
Sleep(2000,"go")
                end
                if trDistance.top[1] < 2630 and trDistance.mid0 > 2080 then
v:AttackMove(treantsPath.mid0)
Sleep(2000,"go")
                end
                if trDistance.mid00 < 3660 and trDistance.mid[6] > 2190 then
v:AttackMove(treantsPath.mid[6])
Sleep(2000,"go")
                end
                if trDistance.mid[6] < 2400 and trDistance.mid[5] > 2490 then
v:AttackMove(treantsPath.mid[5])
Sleep(2000,"go")
                end
                if trDistance.mid[5] < 2640 and trDistance.mid[4] > 2420 then
v:AttackMove(treantsPath.mid[4])
Sleep(2000,"go")
                end
                if trDistance.mid[4] < 2340 and trDistance.mid[3] > 2280 then
v:AttackMove(treantsPath.mid[3])
Sleep(2000,"go")
                end
                if trDistance.mid[3] < 2380 and trDistance.mid[2] > 2380 then
v:AttackMove(treantsPath.mid[2])
Sleep(2000,"go")
                end
                if trDistance.mid[2] < 2380 and trDistance.mid[1] > 2380 then
v:AttackMove(treantsPath.mid[1])
Sleep(2000,"go")
                end
                if trDistance.mid[1] < 2380 and trDistance.mid0 > 2380 then
v:AttackMove(treantsPath.mid0)
Sleep(2000,"go")
                end
                if trDistance.bot[10] < 2400 and trDistance.bot[9] > 2490 then
v:AttackMove(treantsPath.bot[10])
Sleep(2000,"go")
                end
                if trDistance.bot[9] < 2640 and trDistance.bot[8] > 2420 then
v:AttackMove(treantsPath.bot[9])
Sleep(2000,"go")
                end
                if trDistance.bot[8] < 2340 and trDistance.bot[7] > 2280 then
v:AttackMove(treantsPath.bot[8])
Sleep(2000,"go")
                end
                if trDistance.bot[7] < 2380 and trDistance.bot[6] > 2380 then
v:AttackMove(treantsPath.bot[7])
Sleep(2000,"go")
                end
                if trDistance.bot[6] < 2380 and trDistance.bot[5] > 2380 then
v:AttackMove(treantsPath.bot[6])
Sleep(2000,"go")
                end
                if trDistance.bot[5] < 2400 and trDistance.bot[4] > 2490 then
v:AttackMove(treantsPath.bot[5])
Sleep(2000,"go")
                end
                if trDistance.bot[4] < 2640 and trDistance.bot[3] > 2420 then
v:AttackMove(treantsPath.bot[4])
Sleep(2000,"go")
                end
                if trDistance.bot[3] < 2340 and trDistance.bot[2] > 2280 then
v:AttackMove(treantsPath.bot[3])
Sleep(2000,"go")
                end
                if trDistance.bot[2] < 2380 and trDistance.bot[1] > 2380 then
v:AttackMove(treantsPath.bot[2])
Sleep(2000,"go")
                end
                if trDistance.bot[1] < 2380 and trDistance.mid0 > 2380 then
v:AttackMove(treantsPath.mid0)
Sleep(2000,"go")
                                end
                        end
                end
			end
		end
	end
end

 function Denay(tick)
        if Treants then
    if client.pause or client.shopOpen or not SleepCheck()  then return end
    local tr = entityList:GetMyPlayer()
    local me = entityList:GetMyHero()
       
       
        -- Get creeps in range
        local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Venomancer_PlagueWard or v.classId == CDOTA_BaseNPC_Warlock_Golem or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or v.classId == CDOTA_Unit_Undying_Zombie or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.alive and v.health > 0  end)
        -- Get visible treants
		local treants = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep,team=me.team,alive=true,visible=true,controllable = true})
        -- Get treants damage
		--LASTHITS/DENIES INDEV
        for i,v in ipairs(creeps) do
		
                local offset = v.healthbarOffset
                if offset == -1 then return end
                if v.visible and v.alive  then
                        if v.team == entityList:GetMyHero():GetEnemyTeam() and treantLastHit and v.health > 0 and v.health < (damage*(1-v.dmgResist)+20) then
                                for l,tr in ipairs(treants) do
                                        if  v:GetDistance2D(tr) <= 600  and SleepCheck(tr.handle) then
tr:Attack(v)
Sleep(600,tr.handle)
                                                break
                                        end
                                end
                        elseif treantDeny and v.health > (damage*(1-v.dmgResist)) and v.health < (damage*(1-v.dmgResist))+48 then
                                for l,tr in ipairs(treants) do
                                        if v:GetDistance2D(tr) <= 600  and SleepCheck(tr.handle) then
tr:Attack(v)
Sleep(600,tr.handle)
                                                break
                                        end
                                end
                        end
                end
        end
        for i,v in ipairs(treants) do
                local offset = v.healthbarOffset
                if offset == -1 then return end
                if v.visible and v.alive  then
                        if treantDeny and v.health > (damage+10*(1-v.dmgResist)) and v.health < (damage+10*(1-v.dmgResist))+48 then
                                for l,tr in ipairs(treants) do
                                        if  v:GetDistance2D(tr) <= 600 and SleepCheck(tr.handle)   then
tr:Attack(v)
Sleep(800,tr.handle)
                                                break
                                        end
                                end
                        end
                end
        end
	end
end




function Load()
        if PlayingGame() then
                local me = entityList:GetMyHero()
                if not me or me.classId ~= CDOTA_Unit_Hero_Furion or not client.connected or client.loading or client.console then
script:Disable()
                else
statusText.visible = true
play, target, myhero = true, nil, me.classId
script:RegisterEvent(EVENT_TICK, Main)
script:RegisterEvent(EVENT_TICK, Denay)
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
script:UnregisterEvent(Denay)
script:UnregisterEvent(Key)
statusText.visible = false
script:RegisterEvent(EVENT_TICK,Load)
play = false
        end
end
 
script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
