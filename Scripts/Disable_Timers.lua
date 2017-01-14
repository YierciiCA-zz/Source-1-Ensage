--<<Show timings of stunnes, hexes, silences>>

require("libs.Utils")
local mod = {}
local play = false
local xx,yy = -30,-50
local stuncolor = 0xFFFFFFFF
local hexcolor =  0xFFFF00FF
local silencecolor = 0xD50000FF
local HexList = {"modifier_sheepstick_debuff","modifier_lion_voodoo","modifier_shadow_shaman_voodoo"}
local SilenceList = {"modifier_skywrath_mage_ancient_seal","modifier_earth_spirit_boulder_smash_silence","modifier_orchid_malevolence_debuff","modifier_night_stalker_crippling_fear",
"modifier_silence","modifier_silencer_last_word_disarm","modifier_silencer_global_silence","modifier_doom_bringer_doom","modifier_legion_commander_duel"}

function Tick(tick)

	if not SleepCheck() or client.console then return end
	
	local me  = entityList:GetMyHero()
	
	if not me then return end

	local enemy = entityList:GetEntities({type=LuaEntity.TYPE_HERO, illusion = false, team = 5-me.team})

	for i,v in ipairs(enemy) do

		local offset = v.healthbarOffset
		if offset == -1 then return end
		local hand = v.handle
		if not mod[hand] then
			mod[hand] = drawMgr:CreateText(xx,yy,stuncolor,"",drawMgr:CreateFont("F13","Arial",20,500)) mod[hand].visible = false mod[hand].entity = v mod[hand].entityPosition = Vector(0,0,offset)			
		end

		if v.alive and v.visible and v.health > 0 then
			if v:IsStunned() then
				local stun = FindStunModifier(v)
				if stun then
					mod[hand].text = ""..stun
					mod[hand].color = stuncolor
					mod[hand].visible = true
				end
			elseif v:IsHexed() then
				local hex = FindHexOrSilenceModifier(v,HexList)
				if hex then
					mod[hand].text = ""..hex
					mod[hand].color = hexcolor
					mod[hand].visible = true
				end
			elseif v:IsSilenced() then
				local silence = FindHexOrSilenceModifier(v,SilenceList)
				if silence then
					mod[hand].text = ""..silence
					mod[hand].color = silencecolor
					mod[hand].visible = true
				end
			elseif mod[hand].visible then
				mod[hand].visible = false
			end
		elseif mod[hand].visible then
			mod[hand].visible = false
		end
		
	end	
	
	Sleep(250)

end

function FindStunModifier(ent)
	for i = ent.modifierCount, 1, -1 do
		local v = ent.modifiers[i]
		if v.stunDebuff then
			return math.floor(v.remainingTime*10)/10
		end
	end
	return false
end

function FindHexOrSilenceModifier(ent,tab)
	for i = ent.modifierCount, 1, -1 do
		local v = ent.modifiers[i]
		if v.debuff then
			for k,l in ipairs(tab) do
				if v.name == l then
					return math.floor(v.remainingTime*10)/10
				end
			end
		end
	end
	return false
end

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	mod = {}
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
