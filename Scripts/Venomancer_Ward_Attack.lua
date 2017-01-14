--<<Venomancer plague ward automatically attack heroes without debuff. d.l.>>
require("libs.Utils")

function Tick(tick)

	if not client.connected or client.loading or client.console or not SleepCheck() then return end

	local me = entityList:GetMyHero()   
	if not me then return end Sleep(125)
		
	if me.classId ~= CDOTA_Unit_Hero_Venomancer then
		script:Disable()
	else
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,visible = true, alive = true, team = me:GetEnemyTeam(),illusion=false})
		local ward = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive = true,visible = true,controllable=true})
		for i,v in ipairs(enemies) do
			if not v:DoesHaveModifier("modifier_venomancer_poison_sting_ward") and v.health > 0 then
				for l,k in ipairs(ward) do
					if GetDistance2D(v,k) < k.attackRange and SleepCheck(k.handle) then						
						k:Attack(v)
						Sleep(1000,k.handle)
						break
					end
				end
			end
		end
	end
	
end

script:RegisterEvent(EVENT_TICK, Tick)
