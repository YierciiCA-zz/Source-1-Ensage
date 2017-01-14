--<<Updated by ☢bruninjaman☢ New Link: https://github.com/bruninjaman/ENSAGE-SCRIPT/blob/master/Scripts/Challenge_accepted.lua>>--
--[[
☑ Reworked version.
☑ Some new functions and more performance.
☑ Fixed little bugs, FPS drops and more.
☛ This script do?
☑ Jump in enemy with blink dagger, use all itens and ultimate super fast.
☒ Auto use first skill when enemy is killable.
☑ Little text Menu, with mini manual.
☑ Show if enemy is on blink dagger range and your target.
********************************************************************************
♜ Change Log ♜
➩ V1.1C - Thursday, June 4, 2015 - New official version is available. Please visit this link https://github.com/bruninjaman/ENSAGE-SCRIPT/blob/master/Scripts/Challenge_accepted.lua and download it.
➩ V1.1B - Friday, June 5, 2015, [MaZaiPC] - Added new items to combo (Lotus Orb, Solar Crest). Added Smart BKB config. Some changes.
➩ V1.1A - Sunday, May 31, 2015, [MaZaiPC] - Added CD check (use duel only if all casted). Black King Bar now used wisely. Reworked by MaZaiPC, on all issues related with this version contact me.
➩ V1.0E - Sunday, March 29, 2015 - Satanic use when your Health is < 50%. Fixed autoblink bug. Fixed no mana bug.
➩ V1.0D - Monday, March 9, 2015  - REMOVED AUTO DUEL(Because it isn't good.)  and OverHelmingOdds(Fix lag problem). Reworked itens Icons.
➩ V1.0C - Monday, March 2, 2015  - Increased speed of combo and Blink dagger will only be used if enemy is out of duel range. Added auto OverwhelmingOdds.
➩ V1.0B - Thursday, February 28, 2015 - Option for Low Resolution screen and Hidemessage option.
➩ V1.0A - Thursday, February 26, 2015 - New Reworked Version Released.
]]

-- ✖ Libraries ✖ --
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.AbilityDamage")
require("libs.Animations")

-- ✖ config ✖ --
config = ScriptConfig.new()
config:SetParameter("toggleKey", "F", config.TYPE_HOTKEY)
config:SetParameter("BlinkComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("StopComboKey", "S", config.TYPE_HOTKEY)
config:SetParameter("SmartBKB", true)
config:SetParameter("minEnemiesToSmartBKB", 3) -- Optimal for me, but u can change
config:SetParameter("lowResolution", false)
config:SetParameter("hidemessage", false)
config:SetParameter("manacheck", true)
config:SetParameter("cdcheck", true)
config:Load()

local toggle = {
			config.toggleKey,       	-- ➜ toggle Key            		--  toggle[1]
			config.BlinkComboKey,   	-- ➜ blink Combo Key       		--  toggle[2]
			config.StopComboKey,    	-- ➜ Stop Combo Key        		--  toggle[3]
			config.lowResolution,   	-- ➜ Low Resolution Option 		--  toggle[4]
			config.hidemessage,     	-- ➜ Hide TXT              		--  toggle[5]
			config.SmartBKB,     		-- ➜ Smart BKB Option         		--  toggle[6]
			config.minEnemiesToSmartBKB -- ➜ Minimum Enemies to Smart BKB	--  toggle[7]
}

-- Global Variables --
local target   = nil
local item     = nil
local skill    = nil
local me       = nil
local manacheck = config.manacheck
local cdcheck = config.cdcheck

local codes = {
	true,   -- codes[1]
	true,   -- codes[2]
	true,   -- codes[3]
	false,  -- codes[4]
	false,  -- codes[5]
	false,  -- codes[6]
	false,  -- codes[7]
	true,   -- codes[8]
}
-- ✖ Menu screen ✖ --
local x,y            = 1150, 50
local monitor        = client.screenSize.x/1600
local F14            = drawMgr:CreateFont("F14","Franklin Gothic Medium",17,800) 
local F12            = drawMgr:CreateFont("F12","Franklin Gothic Medium",12,10)
local statusText     = drawMgr:CreateText(x*monitor,y*monitor,0xA4A4A4FF,"Finding Black King Bar - Blink Combo - (".. string.char(toggle[2]) ..")",F14) statusText.visible  = false
-- ➜ marked for death text
local legion         = drawMgr:CreateFont("Font","Fixedsys",14,550)
local ikillyou       = drawMgr:CreateText(-50,-50,-1,"Marked for death!",legion); ikillyou.visible = false
-- ➜ Images
local bkb3       = drawMgr:CreateRect(-17,-82,34,34,0xFFD700ff) bkb3.visible     = false
local bkb1       = drawMgr:CreateRect(-16,-80,45,30,0x000000ff) bkb1.visible     = false
local bkb2       = drawMgr:CreateRect(-16,-80,45,30,0x000000ff) bkb2.visible     = false
local orb3       = drawMgr:CreateRect(-17,-82,34,34,0xFF66FFAA) orb3.visible     = false
local orb1       = drawMgr:CreateRect(-16,-80,49,30,0x000000ff) orb1.visible     = false
local orb2       = drawMgr:CreateRect(-16,-80,45,30,0x000000ff) orb2.visible     = false
local blinkbg    = drawMgr:CreateRect(-19,-83,36,33,0x1C1C1Cff) blinkbg.visible  = false
local blink      = drawMgr:CreateRect(-16,-80,43,27,0x000000ff) blink.visible    = false

-- ✖ When you start the game (check hero) ✖ --
function onLoad()
	if PlayingGame() then
		me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Legion_Commander then 
			script:Disable()
		else
			if toggle[4] then
				statusText     = drawMgr:CreateText((x-150)*monitor,(y+10)*monitor,0xA4A4A4FF,"Finding Black King Bar - Blink Combo - (".. string.char(toggle[2]) ..")",F12) statusText.visible  = false
			end
			if toggle[5] then
				statusText.visible  = false
			else
				statusText.visible  = true 
			end
			codes[5] = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

-- ✖ pressing 'F' or 'D' or 'S' ✖ --
function Key(msg,code)
	me = entityList:GetMyHero()
	if not me then return end
	item = {
		me:FindItem("item_black_king_bar"), -- ➜ BKB 	  	item[1]
		me:FindItem("item_lotus_orb") 	    -- ➜ Lotus Orb	item[2]
	}
	skill = {
		me:GetAbility(4)                   -- ➜ skill[1] -- DUEL
	}
	if client.chat or client.console or client.loading then return end
	local shiftX = 0
	
	if item[1] and codes[1] and not toggle[5] then
		statusText.text = "Black King Bar - Enable - (" .. string.char(toggle[1]) .. ")   Blink Combo - (" .. string.char(toggle[2]) .. ") "
		codes[1] = false
		codes[3] = true
		-- ➜ BKB icon
		if not item[2] then
			shiftX = 0
		else
			shiftX = 22
			orb1.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
			orb3.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
			orb2.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
			shiftX = -22
		end
		bkb1.entity            = me 
		bkb1.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
		bkb1.textureId         = drawMgr:GetTextureId("NyanUI/items/black_king_bar")
		bkb1.visible           = true
		bkb3.entity            = me 
		bkb3.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
		bkb3.visible           = true
		bkb2.entity            = me 
		bkb2.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
		bkb2.textureId         = drawMgr:GetTextureId("NyanUI/items/translucent/black_king_bar_t25")
	end
	
	if item[2] and codes[8] and not toggle[5] then
		codes[8] = false
		-- ➜ Lotus Orb icon
		if not item[1] then
			shiftX = 0
		else
			shiftX = -22
			bkb1.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
			bkb3.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
			bkb2.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
			shiftX = 22
		end
		orb1.entity            = me 
		orb1.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
		orb1.textureId         = drawMgr:GetTextureId("NyanUI/items/lotus_orb")
		orb1.visible           = true
		orb3.entity            = me 
		orb3.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
		orb3.visible           = true
		orb2.entity            = me 
		orb2.entityPosition    = Vector(shiftX,0,me.healthbarOffset)
		orb2.textureId         = drawMgr:GetTextureId("NyanUI/items/translucent/lotus_orb")
	end
	
	if IsKeyDown(toggle[1]) and SleepCheck("CD_toggle2") and not toggle[5] then
		codes[2] = not codes[2]
		Sleep(500,"CD_toggle2")
		if codes[2] then
			if item[1] then
				statusText.text = "Black King Bar - Enable - (" .. string.char(toggle[1]) .. ")   Blink Combo - (" .. string.char(toggle[2]) .. ") "
				statusText.color = 0xDF0101FF
				codes[3] = true
				bkb1.visible = true
				bkb2.visible = false
				bkb3.visible = true
			else
				statusText.text    = "Finding Black King Bar - Blink Combo - (".. string.char(toggle[2]) ..")"
				statusText.color = 0xA4A4A4FF
				bkb1.visible = false
				bkb2.visible = false
				bkb3.visible = false
			end
		else
			if item[1] then
				statusText.text = "Black King Bar - Disable - (" .. string.char(toggle[1]) .. ")   Blink Combo - (" .. string.char(toggle[2]) .. ") "
				codes[3] = false
				bkb1.visible = false
				bkb2.visible = true
				bkb3.visible = true
				statusText.color = 0x8A0808FF
			else
				statusText.text = "Finding Black King Bar - Blink Combo - (".. string.char(toggle[2]) ..")"
				statusText.color = 0xA4A4A4FF
				bkb1.visible = false
				bkb2.visible = false
				bkb3.visible = false
			end
		end
	end
	if code == toggle[2] then
		codes[4] = true
	end
	if code == toggle[3] then
		codes[4] = false
	end
end


-- ✖ Starting Combo ✖ --
function Main(tick)
	me = entityList:GetMyHero()
	if not me then return end
	if not SleepCheck() then return end
	target = targetFind:GetClosestToMouse(100)
	item = {
		me:DoesHaveModifier("modifier_item_armlet_unholy_strength"), -- ➜ item[1]
		me:FindItem("item_blink"), 									 -- ➜ item[2]
		me:FindItem("item_armlet"),                                  -- ➜ item[3]
		me:FindItem("item_blade_mail"),                              -- ➜ item[4]
		me:FindItem("item_black_king_bar"),                          -- ➜ item[5]
		me:FindItem("item_abyssal_blade"),                           -- ➜ item[6]
		me:FindItem("item_mjollnir"),                                -- ➜ item[7]
		me:FindItem("item_heavens_halberd"),                         -- ➜ item[8]
		me:FindItem("item_medallion_of_courage"),                    -- ➜ item[9]
		me:FindItem("item_mask_of_madness"),                         -- ➜ item[10]
		me:FindItem("item_urn_of_shadows"),                          -- ➜ item[11]
		me:FindItem("item_satanic"),                                 -- ➜ item[12]
		me:FindItem("item_lotus_orb"),                               -- ➜ item[13] NEW
		me:FindItem("item_solar_crest")                              -- ➜ item[14] NEW
	}
	skill = {
		me:GetAbility(1),                                            -- ➜ skill[1] -- Arrows
		me:GetAbility(2),                                            -- ➜ skill[2] -- Buff
		me:GetAbility(4),                                            -- ➜ skill[3] -- DUEL
	}
	if target and GetDistance2D(me,target) < 2000 and skill[3] and target.alive and target.visible then
		blink.entity            = target 
		blink.entityPosition    = Vector(0,0,target.healthbarOffset)
		blink.textureId         = drawMgr:GetTextureId("NyanUI/items/blink")
		blinkbg.entity          = target 
		blinkbg.entityPosition  = Vector(0,0,target.healthbarOffset)
		ikillyou.entity = target
		ikillyou.entityPosition = Vector(0,0,target.healthbarOffset)
		markedfordeath()
	else
		ikillyou.visible   = false
		blink.visible      = false
		blinkbg.visible    = false
	end
	if target and GetDistance2D(me,target) < 950 and item[11] then
		Autourn()
	end
	if GetDistance2D(me,target) > 1200 then -- ➜ distance correction
		codes[4] = false
	end
	if codes[4] and skill[3].level > 0 and target and target.visible and target.alive and me.alive and GetDistance2D(me,target) < 1200 and SleepCheck("DelayCombo") and SleepCheck("duelactive") then
		Sleep(300,"DelayCombo")
		BlinkCombo()
	end
end

function markedfordeath()
	if target and target.alive and target.visible then
		ikillyou.visible = true
		if item[2] and GetDistance2D(me,target) < 1200 then
			blink.visible   = true
			blinkbg.visible = true
		else
			blink.visible      = false
			blinkbg.visible    = false
		end
	end
end

function Autourn()
	if target and target.health <= 150 and item[11] and GetDistance2D(me,target) < 950 and target.visible and target.alive and me.alive then
		if item[11] and item[11]:CanBeCasted() then
			me:CastItem("item_urn_of_shadows",target)
			Sleep(100+me:GetTurnTime(target)*500)
		return
		end
	end
end

function BlinkCombo()
	local manapool = 0
	if manacheck then
		if skill[2] and skill[2]:CanBeCasted() then
			manapool = manapool + skill[2].manacost
		end
		if codes[3] and item[5] and item[5]:CanBeCasted() then
			manapool = manapool + item[5].manacost
		end
		if item[7] and item[7].state == LuaEntityItem.STATE_READY and item[7]:CanBeCasted() then
			manapool = manapool + item[7].manacost
		end
		if item[13] and item[13].state == LuaEntityItem.STATE_READY and item[13]:CanBeCasted() then -- Lotus ORB
			manapool = manapool + item[13].manacost
		end
		if item[10] and item[10]:CanBeCasted() then
			manapool = manapool + item[10].manacost
		end
		if item[6] and item[6].state == LuaEntityItem.STATE_READY and item[6]:CanBeCasted() then
			manapool = manapool + item[6].manacost
		end
		if item[11] and item[11]:CanBeCasted() then
			manapool = manapool + item[11].manacost
		end
		if item[8] and item[8].state == LuaEntityItem.STATE_READY and item[8]:CanBeCasted() then
			manapool = manapool + item[8].manacost
		end
		if item[4] and item[4]:CanBeCasted() then
			manapool = manapool + item[4].manacost
		end
		if item[12] and item[12].state == LuaEntityItem.STATE_READY and item[12]:CanBeCasted() and me.health < (me.maxHealth * 0.5) then
		manapool = manapool + item[12].manacost
		end
	end
	if me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") then
		codes[6] = true
		me:Attack(target)
		Sleep(100+me:GetTurnTime(target)*500)
	else
		codes[6] = false
	end
	if me:CanCast() and not me:IsChanneling() and not codes[6] then
	 -- In my opinion, unnecessary information for typical player. You can undo this if you need.
	 -- print("me.mana "..me.mana.." manapool "..manapool.." skill[3] "..skill[3].manacost)
	 
		-- ➜ Press the attack
		if skill[2].level > 0 then
			if skill[2]:CanBeCasted() and me.mana > manapool and me.mana > skill[3].manacost then
				me:CastAbility(skill[2],me)
				Sleep(skill[2]:FindCastPoint()*800)
			end
		end
		-- ➜ Blink dagger
		if item[2] and item[2]:CanBeCasted() and GetDistance2D(me,target) > 80 then
			me:CastAbility(item[2],target.position)
			Sleep(100+me:GetTurnTime(target)*500)
		end
		-- ➜ Check if bkb is active or inactive
		if codes[3] and item[5] and item[5]:CanBeCasted() then
			local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
			if toggle[6] then
				if #heroes >= toggle[7] and #heroes <= 5 then
					me:SafeCastItem("item_black_king_bar")
				end
			else
					me:SafeCastItem("item_black_king_bar")
			end
			Sleep(100+me:GetTurnTime(target)*500)
		end
		-- ➜ Mjolnir item
		if item[7] then
			if item[7].state == LuaEntityItem.STATE_READY and item[7]:CanBeCasted() and me.mana > skill[3].manacost then
				me:CastAbility(item[7],me)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Lotus Orb item
		if item[13] then
			if item[13].state == LuaEntityItem.STATE_READY and item[13]:CanBeCasted() and me.mana > skill[3].manacost then
				me:CastAbility(item[13],me)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Armlet item
		if item[3] then
			if item[3]:CanBeCasted() and not item[1] and SleepCheck("Armlet_use_delay") then
				me:SafeCastItem("item_armlet")
				Sleep(100)
				Sleep(200,"Armlet_use_delay")
			end
		end
		-- ➜ Madness item
		if item[10] then
			if item[10]:CanBeCasted() and me.mana > skill[3].manacost then
				me:SafeCastItem("item_mask_of_madness")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Abyssal item
		if item[6] then
			if item[6].state == LuaEntityItem.STATE_READY and item[6]:CanBeCasted() and me.mana > skill[3].manacost then
				me:CastItem("item_abyssal_blade",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Urn of Shadows item
		if item[11] then
			if item[11]:CanBeCasted() and me.mana > skill[3].manacost then
				me:CastItem("item_urn_of_shadows",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Halberd item
		if item[8] then
			if item[8].state == LuaEntityItem.STATE_READY and item[8]:CanBeCasted() and me.mana > skill[3].manacost then
				me:CastItem("item_heavens_halberd",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Medallion of courage item
		if item[9] then
			if item[9].state == LuaEntityItem.STATE_READY and item[9]:CanBeCasted() and me.mana > skill[3].manacost then
				me:CastItem("item_medallion_of_courage",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Solar Crest item
		if item[14] then
			if item[14].state == LuaEntityItem.STATE_READY and item[14]:CanBeCasted() and me.mana > skill[3].manacost then
				me:CastItem("item_solar_crest",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Blademail item
		if item[4] then
			if item[4]:CanBeCasted() and me.mana > skill[3].manacost then
				me:SafeCastItem("item_blade_mail")
				Sleep(100+me:GetTurnTime(target)*600)
			end
		end
		-- ➜ Satanic
		if item[12] then
			if item[12].state == LuaEntityItem.STATE_READY and item[12]:CanBeCasted() and me.health < (me.maxHealth * 0.5) and me.mana > skill[3].manacost then
				me:SafeCastItem("item_satanic")
				Sleep(100+me:GetTurnTime(target)*600)
				Sleep(100,"duel")
			end
		end
		-- ➜ Duel Hability
		if target.classId == CDOTA_Unit_Hero_Abaddon and target:GetAbility(4).cd > 5 then
			if SleepCheck("duel") and skill[3]:CanBeCasted() and IsAllCasted() and not target:IsLinkensProtected() and not target:IsPhysDmgImmune() and not target:DoesHaveModifier("modifier_abaddon_borrowed_time") then
				me:CastAbility(skill[3],target)
				Sleep(skill[2]:FindCastPoint()*700)
				Sleep(80,"duelactive")
				codes[4] = false
			end
		elseif target.classId ~= CDOTA_Unit_Hero_Abaddon then
			if SleepCheck("duel") and skill[3]:CanBeCasted() and IsAllCasted() and not target:IsLinkensProtected() and not target:IsPhysDmgImmune() and not target:DoesHaveModifier("modifier_abaddon_borrowed_time") then
				me:CastAbility(skill[3],target)
				Sleep(skill[2]:FindCastPoint()*700)
				Sleep(80,"duelactive")
				codes[4] = false
			end
		end
		codes[4] = false
		Sleep(200)
	else
	    return
	end
end

function IsAllCasted()
	if cdcheck then
		-- ➜ Madness cd check
		if item[10] then
			if item[10]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Medallion of courage cd check
		if item[9] then
			if item[9].state == LuaEntityItem.STATE_READY and item[9]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Solar Crest cd check
		if item[9] then
			if item[9].state == LuaEntityItem.STATE_READY and item[9]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Halberd cd check
		if item[8] then
			if item[8].state == LuaEntityItem.STATE_READY and item[8]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Satanic cd check
		if item[12] then
			if item[12].state == LuaEntityItem.STATE_READY and item[12]:CanBeCasted() and me.health < (me.maxHealth * 0.5) and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Armlet cd check
		if item[3] then
			if item[3]:CanBeCasted() and not item[1] and SleepCheck("Armlet_use_delay") then
				return false
			end
		end
		-- ➜ Urn of Shadows cd check
		if item[11] then
			if item[11]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Mjolnir cd check
		if item[7] then
			if item[7].state == LuaEntityItem.STATE_READY and item[7]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Lotus Orb cd check
		if item[13] then
			if item[13].state == LuaEntityItem.STATE_READY and item[13]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		if codes[3] and item[5] and item[5]:CanBeCasted() then
			local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
			if toggle[6] then
				if #heroes >= toggle[7] and #heroes <= 5 then
					return false
				end
			else
					return false
			end
			Sleep(100+me:GetTurnTime(target)*500)
		end
		-- ➜ Blademail cd check
		if item[4] then
			if item[4]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
		-- ➜ Abyssal cd check
		if item[6] then
			if item[6].state == LuaEntityItem.STATE_READY and item[6]:CanBeCasted() and me.mana > skill[3].manacost then
				return false
			end
		end
	end
	return true
end

-- ✖ END OF GAME  ✖ --
function onClose()
	collectgarbage("collect")
	if codes[5] then
	    statusText.visible = false
		ikillyou.visible = false
		bkb1.visible  = false
		bkb2.visible  = false
		blink.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		codes[5] = false
	end
end
script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
