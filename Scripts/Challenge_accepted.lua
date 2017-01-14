--<<Legion commander V1.1D ✰ - by ☢bruninjaman☢>>--
--[[
☑ Reworked version.
☑ Some new functions and more performance.
☑ Fixed little bugs, FPS drops and more.
☛ This script do?
☑ Blink in your enemy target and use all itens that you have for win the duel.
☒ Auto use first skill when enemy is killable.
☑ Show if enemy is on blink dagger range and your target.
********************************************************************************
♜ Change Log ♜
➩ V1.1D - Sunday, June 14, 2015 - Fixed Halberd(don't work in duel) - Added new sistem to remove linkens.
    -> removed auto cast abyssal if is using blademail, unless if target is magic imunne.
	-> fixed always use 'press the attack' when you can.
	-> fixed bugs if enemy is using bkb
➩ V1.1C - Thursday, June 4, 2015 - Reworked script again - trying to remove fps drops problem. You know when you is out of mana for full combo.
	-> Added (Solar Crest, Dust, Mango, Arcane, Buckler, Crimson, Lotus Orb and Silver Edge)
	-> Reworked Mana Calculation(With all itens)
	-> When you are out of mana, auto usage of soulring, arcane, mango and magic wand/stick. and auto cheese.
	-> Added Auto dust.
	-> new template (colors, fonts, etc..) of display menu.(Snall changes.)
	-> removed "AbilityDamage" and "Animations" lib.
	-> thanks Nova for help-me :D. thanks MaZaiPC for stay keeping my script updated and for new ideias for my legion script.
➩ V1.1A - Sunday, May 31, 2015 - Added CD check (use duel only if all casted). Black King Bar now used wisely. Reworked by MaZaiPC, on all issues related with this version contact me.
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

-- ✖ Settings Variables ✖ --
config = ScriptConfig.new()
config:SetParameter("toggleKey", "F", config.TYPE_HOTKEY)
config:SetParameter("BlinkComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("StopComboKey", "S", config.TYPE_HOTKEY)
config:Load()

local toggle = {
	["switchbkb"]  = config.toggleKey,
	["blinkcombo"] = config.BlinkComboKey,
	["stopcombo"]  = config.StopComboKey,
}

-- Global Variables --
local target   = nil
local item     = nil
local skill    = nil
local me       = nil
local KeyCode = {
	BlackKingBar  = false,
	shadow        = false,
	BlackKingBar2 = false,
	CanCombo      = false,
	registered    = false,
}
-- * Variables for graphic
local x,y            = 1150, 50
local monitor        = client.screenSize.x/1600
local F14            = drawMgr:CreateFont("F14","Franklin Gothic Medium",17,800) 
local BKBtext        = drawMgr:CreateText(x*monitor,y*monitor,0xA4A4A4FF,"Trying to find Black King Bar - Duel Combo - (".. string.char(toggle.blinkcombo) ..")",F14) BKBtext.visible  = false
local legion         = drawMgr:CreateFont("Font","Fixedsys",14,550)
local MyTarget       = drawMgr:CreateText(-50,-50,-1,"Marked for death!",legion) MyTarget.visible   = false
local manapooltxt    = drawMgr:CreateText(-50,-105,-1,"Not enough mana!",legion) manapooltxt.visible = false
local BlinkBackGround    = drawMgr:CreateRect(-19,-83,36,33,0x1C1C1Cff) BlinkBackGround.visible     = false
local BlinkTexture       = drawMgr:CreateRect(-16,-80,43,27,0x000000ff) BlinkTexture.visible        = false

-- ✖ When you start the game (check hero) ✖ --
function onLoad()
	if PlayingGame() then
		if me == nil then
			me = entityList:GetMyHero()
		end
		if not me or me.classId ~= CDOTA_Unit_Hero_Legion_Commander then 
			script:Disable()
			print ("--- Legion Commander Script inactivated. ---")
			return
		else
			if skill == nil then
				skill = {
					-- ["arrows"] = me:GetAbility(1),  Not used yet
					["healbuff"] = me:GetAbility(2),
					["duel"] = me:GetAbility(4),
				}
			end
			registered = true
			BKBtext.visible  = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

-- Function for keys.--
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if me == nil then
		me = entityList:GetMyHero()
	end
	if not me then return end
	if IsKeyDown(toggle.switchbkb) and SleepCheck("CD_toggle_Black_King_Bar") then
		KeyCode.BlackKingBar2 = not KeyCode.BlackKingBar2
		Sleep(500,"CD_toggle_Black_King_Bar")
		if KeyCode.BlackKingBar2 then
			if item.blackkingbar then
				if BKBtext.text ~= "Black King Bar - Enable - (" .. string.char(toggle.switchbkb) .. ")   Duel Combo - (" .. string.char(toggle.blinkcombo) .. ") " then
					BKBtext.text       = "Black King Bar - Enable - (" .. string.char(toggle.switchbkb) .. ")   Duel Combo - (" .. string.char(toggle.blinkcombo) .. ") "
				end
				if BKBtext.color ~= 0xDF0101FF then
					BKBtext.color      = 0xDF0101FF
				end
				if KeyCode.BlackKingBar ~= true then
					KeyCode.BlackKingBar  = true
				end
			else
				if BKBtext.text ~= "Trying to find Black King Bar - Duel Combo - (".. string.char(toggle.blinkcombo) ..")" or BKBtext.color ~= 0xA4A4A4FF then
					BKBtext.text       = "Trying to find Black King Bar - Duel Combo - (".. string.char(toggle.blinkcombo) ..")"
					BKBtext.color      = 0xA4A4A4FF
				end
			end
		else
			if item.blackkingbar then
				if BKBtext.text ~= "Black King Bar - Disable - (" .. string.char(toggle.switchbkb) .. ")   Duel Combo - (" .. string.char(toggle.blinkcombo) .. ") " or BKBtext.color ~= 0x8A0808FF or KeyCode.BlackKingBar ~= false then
					BKBtext.text       = "Black King Bar - Disable - (" .. string.char(toggle.switchbkb) .. ")   Duel Combo - (" .. string.char(toggle.blinkcombo) .. ") "
					BKBtext.color      = 0x8A0808FF
					KeyCode.BlackKingBar  = false
				end
			else
				if BKBtext.text ~= "Trying to find Black King Bar - Duel Combo - (".. string.char(toggle.blinkcombo) ..")" or BKBtext.color ~= 0xA4A4A4FF then
					BKBtext.text       = "Trying to find Black King Bar - Duel Combo - (".. string.char(toggle.blinkcombo) ..")"
					BKBtext.color      = 0xA4A4A4FF
				end
			end
		end
	end
	if code == toggle.blinkcombo then
		if not KeyCode.CanCombo then
			KeyCode.CanCombo = true
		end
	end
	if code == toggle.stopcombo then
		if KeyCode.CanCombo then
			KeyCode.CanCombo = false
		end
	end
end
-- Main Function --
function Main()
	if me == nil then me = entityList:GetMyHero() end
	if not me then return end
	if not SleepCheck() then return end
	target = targetFind:GetClosestToMouse(100)
	FindItems(me)
	-- graphic code --
	if target and GetDistance2D(me,target) < 2000 and skill.duel and target.alive and target.visible then
		-- configuration of graphics -- 
		if (BlinkTexture.entity ~= target or
		BlinkTexture.entityPosition ~= Vector(0,0,target.healthbarOffset) or
		BlinkTexture.textureId ~= drawMgr:GetTextureId("NyanUI/items/blink") or
		BlinkBackGround.entity ~= target or
		BlinkBackGround.entityPosition ~= Vector(0,0,target.healthbarOffset) or
		MyTarget.entity ~= target or
		MyTarget.entityPosition ~= Vector(0,0,target.healthbarOffset) or
		manapooltxt.entity ~= target or
		manapooltxt.entityPosition ~= Vector(0,0,target.healthbarOffset) or
		manapooltxt.color ~= 0x013ADFFF) then
			BlinkTexture.entity             = target 
			BlinkTexture.entityPosition    = Vector(0,0,target.healthbarOffset)
			BlinkTexture.textureId         = drawMgr:GetTextureId("NyanUI/items/blink")
			BlinkBackGround.entity          = target 
			BlinkBackGround.entityPosition  = Vector(0,0,target.healthbarOffset)
			MyTarget.entity = target
			MyTarget.entityPosition = Vector(0,0,target.healthbarOffset)
			manapooltxt.entity = target
			manapooltxt.entityPosition = Vector(0,0,target.healthbarOffset)
			manapooltxt.color = 0x013ADFFF
		end
		-- --- --- --- --- --- --- --- --
		markedfordeath()
	else
		if (MyTarget.visible ~= false
		or BlinkTexture.visible ~= false
		or BlinkBackGround.visible ~= false
		or manapooltxt.visible ~= false) then
			MyTarget.visible        = false
			BlinkTexture.visible    = false
			BlinkBackGround.visible = false
			manapooltxt.visible     = false
		end
	end
	-- Auto Urn code --
	if target and GetDistance2D(me,target) < 950 and item.urn then
		Autourn()
	end
	-- Fix autocombos --
	if target and GetDistance2D(me,target) > 1200 then
		KeyCode.CanCombo = false
	end
	-------------------
	-- Combo code --
	if (skill.duel).level > 0 and target and target.visible and target.alive and me.alive and GetDistance2D(me,target) < 1200 and SleepCheck("DelayCombo") and KeyCode.CanCombo then
		Sleep(300,"DelayCombo")
		manacheck()
		breaklinkens()
		BlinkCombo()
	end
end


-- Break Linkens function --
function breaklinkens()
	if target and target:IsLinkensProtected() then
		if item.cyclone and item.cyclone:CanBeCasted() then
			if item.cyclone.state == LuaEntityItem.STATE_READY and item.cyclone:CanBeCasted() then
				me:CastItem("item_cyclone",target)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		elseif item.force and item.force:CanBeCasted() then
			if item.force.state == LuaEntityItem.STATE_READY and item.force:CanBeCasted() then
				me:CastItem("item_force_staff",target)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		elseif item.halberd and item.halberd:CanBeCasted() then
			if item.halberd.state == LuaEntityItem.STATE_READY and item.halberd:CanBeCasted() then
				me:CastItem("item_heavens_halberd",target)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		elseif item.vyse and item.vyse:CanBeCasted() then
			if item.vyse.state == LuaEntityItem.STATE_READY and item.vyse:CanBeCasted() then
				me:CastItem("item_sheepstick",target)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		elseif item.abyssal and item.abyssal:CanBeCasted() then
			if item.abyssal.state == LuaEntityItem.STATE_READY and item.abyssal:CanBeCasted() then
				me:CastItem("item_abyssal_blade",target)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		else
			-- ➜ Blink dagger
			if item.blink and item.blink:CanBeCasted() and GetDistance2D(me,target) > 100 then
				me:CastAbility(item.blink,target.position)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
	end
	return
end


-- Marked for death text Function --
function markedfordeath()
	if target and target.alive and target.visible then
		if not MyTarget.visible then
			MyTarget.visible = true
		end
		if item.blink and GetDistance2D(me,target) < 1200 then
			if not BlinkTexture.visible or BlinkBackGround.visible then
				BlinkTexture.visible    = true
				BlinkBackGround.visible = true
			end
		else
			if BlinkTexture.visible or BlinkBackGround.visible then
				BlinkTexture.visible    = false
				BlinkBackGround.visible = false
			end
		end
		if not manapool() then
			if not manapooltxt.visible then
				manapooltxt.visible = true
			end
		else
			if manapooltxt.visible then
				manapooltxt.visible = false
			end
		end
	end
	return
end

-- Nova - FindItems function --
function FindItems(me)
  item = setmetatable({}, {
    __index = function(item, key)
      if key == "armletactive" then
        return me:DoesHaveModifier("modifier_item_armlet_unholy_strength")
      elseif key == "blink" then
        return me:FindItem("item_blink")
      elseif key == "armlet" then
        return me:FindItem("item_armlet")
      elseif key == "blademail" then
        return me:FindItem("item_blade_mail")
      elseif key == "blackkingbar" then
        return me:FindItem("item_black_king_bar")
      elseif key == "abyssal" then
        return me:FindItem("item_abyssal_blade")
      elseif key == "mjollnir" then
        return me:FindItem("item_mjollnir")
      elseif key == "halberd" then
        return me:FindItem("item_heavens_halberd")
      elseif key == "medallion" then
        return me:FindItem("item_medallion_of_courage")
      elseif key == "madness" then
        return me:FindItem("item_mask_of_madness")
      elseif key == "urn" then
        return me:FindItem("item_urn_of_shadows")
      elseif key == "satanic" then
        return me:FindItem("item_satanic")
      elseif key == "solarcrest" then
        return me:FindItem("item_solar_crest")
      elseif key == "dust" then
        return me:FindItem("item_dust")
      elseif key == "mango" then
        return me:FindItem("item_enchanted_mango")
      elseif key == "arcane" then
        return me:FindItem("item_arcane_boots")
      elseif key == "buckler" then
        return me:FindItem("item_buckler")
      elseif key == "crimson" then
        return me:FindItem("item_crimson_guard")
      elseif key == "lotusorb" then
        return me:FindItem("item_lotus_orb")
      elseif key == "cheese" then
        return me:FindItem("item_cheese")
      elseif key == "magicstick" then
        return me:FindItem("item_magic_stick")
      elseif key == "magicwand" then
        return me:FindItem("item_magic_wand")
      elseif key == "soulring" then
        return me:FindItem("item_soul_ring")
	  elseif key == "force" then
        return me:FindItem("item_force_staff")
	  elseif key == "cyclone" then
        return me:FindItem("item_cyclone")
	  elseif key == "vyse" then
        return me:FindItem("item_sheepstick")
      else
        return item[key]
      end
    end
  })
end
-- Mana Check Function --
function manacheck()
	if not manapool() then
		if item.mango then
			if item.mango.state == LuaEntityItem.STATE_READY and item.mango:CanBeCasted() then
				me:CastAbility(item.mango,me)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		if item.arcane then
			if item.arcane.state == LuaEntityItem.STATE_READY and item.arcane:CanBeCasted() then
				me:SafeCastItem("item_arcane_boots")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		if item.soulring then
			if item.soulring.state == LuaEntityItem.STATE_READY and item.soulring:CanBeCasted() and me.health >= (me.maxHealth * 0.3) or me.maxHealth >= 500 then
				me:SafeCastItem("item_soul_ring")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		if item.magicwand then
			if item.magicwand.state == LuaEntityItem.STATE_READY and item.magicwand:CanBeCasted() then
				me:SafeCastItem("item_magic_wand")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		if item.magicstick then
			if item.magicstick.state == LuaEntityItem.STATE_READY and item.magicstick:CanBeCasted() then
				me:SafeCastItem("item_magic_stick")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		if item.cheese then
			if item.cheese.state == LuaEntityItem.STATE_READY and item.cheese:CanBeCasted() then
				me:SafeCastItem("item_cheese")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
	end
	if me.health <= (me.maxHealth * 0.5) then
		if item.magicwand then
			if item.magicwand.state == LuaEntityItem.STATE_READY and item.magicwand:CanBeCasted() then
				me:SafeCastItem("item_magic_wand")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		if item.magicstick then
			if item.magicstick.state == LuaEntityItem.STATE_READY and item.magicstick:CanBeCasted() then
				me:SafeCastItem("item_magic_stick")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		if item.cheese then
			if item.cheese.state == LuaEntityItem.STATE_READY and item.cheese:CanBeCasted() then
				me:SafeCastItem("item_cheese")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
	end
	return
end

-- Auto Urn Function --
function Autourn()
	if me:CanCast() and not me:IsChanneling() then
		if target and target.health <= 150 and item.urn and GetDistance2D(me,target) < 950 and target.visible and target.alive and me.alive then
			if item.urn and item.urn:CanBeCasted() then
				me:CastItem("item_urn_of_shadows",target)
				Sleep(100+me:GetTurnTime(target)*500)
			return
			end
		end
	end
	return
end

-- Blink Combo Function -- 
function BlinkCombo()
	if me:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") or me:DoesHaveModifier("modifier_item_silver_edge_windwalk") then
		KeyCode.shadow = true
		me:Attack(target)
		Sleep(100+me:GetTurnTime(target)*500)
	else
		KeyCode.shadow = false
	end
	if me:CanCast() and not me:IsChanneling() and not KeyCode.shadow then
		-- ➜ Press the attack
		if skill.healbuff.level > 0 then
			if skill.healbuff:CanBeCasted() and manapool() then
				me:CastAbility(skill.healbuff,me)
				Sleep(skill.healbuff:FindCastPoint()*800)
			end
		end
		-- ➜ Blink dagger
		if item.blink and item.blink:CanBeCasted() and GetDistance2D(me,target) > 100 then
			me:CastAbility(item.blink,target.position)
			Sleep(100+me:GetTurnTime(target)*500)
		end
		-- ➜ anti-invi
		if item.dust then
			-- ➜ dust item
			if EnemyIsInvi() then
				if item.dust.state == LuaEntityItem.STATE_READY and item.dust:CanBeCasted() and manapool() then
					me:CastAbility(item.dust)
					Sleep(100+me:GetTurnTime(target)*500)
				end
			end
		end
		-- ➜ Crimson item
		if item.crimson then
			if item.crimson.state == LuaEntityItem.STATE_READY and item.crimson:CanBeCasted() and manapool() then
				me:SafeCastItem("item_crimson_guard")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Buckler item
		if item.buckler then
			if item.buckler.state == LuaEntityItem.STATE_READY and item.buckler:CanBeCasted() and manapool() then
				me:SafeCastItem("item_buckler")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Lotus Orb item
		if item.lotusorb then
			if item.lotusorb.state == LuaEntityItem.STATE_READY and item.lotusorb:CanBeCasted() and manapool() then
				me:CastAbility(item.lotusorb,me)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Check if bkb is active or inactive
		if item.blackkingbar and item.blackkingbar:CanBeCasted() then
			if KeyCode.BlackKingBar then
				me:SafeCastItem("item_black_king_bar")
				Sleep(100+me:GetTurnTime(target)*500)
			else
				local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
				if #heroes >= 3 then
					me:SafeCastItem("item_black_king_bar") -- thanks MaZaiPc for this ideia.
				end
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Mjolnir item
		if item.mjollnir then
			if item.mjollnir.state == LuaEntityItem.STATE_READY and item.mjollnir:CanBeCasted() and manapool() then
				me:CastAbility(item.mjollnir,me)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Armlet item
		if item.armlet then
			if item.armlet:CanBeCasted() and not item.armletactive and SleepCheck("Armlet_use_delay") then
				me:SafeCastItem("item_armlet")
				Sleep(100)
				Sleep(200,"Armlet_use_delay")
			end
		end
		-- ➜ Madness item
		if item.madness then
			if item.madness:CanBeCasted() and item.madness.state == LuaEntityItem.STATE_READY and manapool() then
				me:SafeCastItem("item_mask_of_madness")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Abyssal item
		if item.abyssal then
			if item.abyssal.state == LuaEntityItem.STATE_READY and item.abyssal:CanBeCasted() and manapool() and (not me:DoesHaveModifier("modifier_item_blade_mail_reflect") or target:IsMagicDmgImmune()) then
				me:CastItem("item_abyssal_blade",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Urn of Shadows item
		if item.urn then
			if item.urn:CanBeCasted() then
				me:CastItem("item_urn_of_shadows",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Solar Crest item
		if item.solarcrest then
			if item.solarcrest.state == LuaEntityItem.STATE_READY and item.solarcrest:CanBeCasted() then
				me:CastItem("item_solar_crest",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Medallion of courage item
		if item.medallion then
			if item.medallion.state == LuaEntityItem.STATE_READY and item.medallion:CanBeCasted() then
				me:CastItem("item_medallion_of_courage",target)
				Sleep(100,"duel")
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
		-- ➜ Blademail item
		if item.blademail then
			if item.blademail:CanBeCasted() and manapool() then
				me:SafeCastItem("item_blade_mail")
				Sleep(100+me:GetTurnTime(target)*600)
			end
		end
		-- ➜ Satanic
		if item.satanic then
			if item.satanic.state == LuaEntityItem.STATE_READY and item.satanic:CanBeCasted() and me.health <= (me.maxHealth * 0.5) and manapool() then
				me:SafeCastItem("item_satanic")
				Sleep(100+me:GetTurnTime(target)*600)
				Sleep(100,"duel")
			end
		end
		-- ➜ Duel Hability
		if target.classId == CDOTA_Unit_Hero_Abaddon and target:GetAbility(4).cd > 5 then
			if SleepCheck("duel") and skill.duel:CanBeCasted() and not target:IsLinkensProtected() and not target:IsPhysDmgImmune() and not target:DoesHaveModifier("modifier_abaddon_borrowed_time") and IsAllCasted() then
				me:CastAbility(skill.duel,target)
				Sleep(skill.healbuff:FindCastPoint()*700)
				KeyCode.CanCombo = false
			end
		elseif target.classId ~= CDOTA_Unit_Hero_Abaddon then
			if SleepCheck("duel") and skill.duel:CanBeCasted() and not target:IsLinkensProtected() and not target:IsPhysDmgImmune() and not target:DoesHaveModifier("modifier_abaddon_borrowed_time") and IsAllCasted() then
				me:CastAbility(skill.duel,target)
				Sleep(skill.healbuff:FindCastPoint()*700)
				KeyCode.CanCombo = false
			end
		end
	end
	KeyCode.CanCombo = false
	return
end

-- Anti-invi Function -- Thanks nova for your AutoDustBETA.lua script.
function EnemyIsInvi()
	if target and (target:DoesHaveModifier("modifier_bounty_hunter_wind_walk") 
	or target:DoesHaveModifier("modifier_riki_permanent_invisibility") 
	or target:DoesHaveModifier("modifier_mirana_moonlight_shadow") 
    or target:DoesHaveModifier("modifier_treant_natures_guise") 
	or target:DoesHaveModifier("modifier_weaver_shukuchi") 
    or target:DoesHaveModifier("modifier_broodmother_spin_web_invisible_applier") 
    or target:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") 
    or target:DoesHaveModifier("modifier_rune_invis") 
    or target:DoesHaveModifier("modifier_clinkz_wind_walk") 
    or target:DoesHaveModifier("modifier_item_shadow_amulet_fade") 
    or target:DoesHaveModifier("modifier_item_glimmer_cape_fade")
    or target:DoesHaveModifier("modifier_item_silver_edge_windwalk")) 
    and not (target:DoesHaveModifier("modifier_bounty_hunter_track") 
	or target:DoesHaveModifier("modifier_bloodseeker_thirst_vision") 
    or target:DoesHaveModifier("modifier_slardar_amplify_damage") 
    or target:DoesHaveModifier("modifier_item_dustofappearance")
    or target:DoesHaveModifier("modifier_truesight"))
	then
	return true
	else return false end
end


-- Function IsAllCasted - thanks MaZaiPC - Great Idea
function IsAllCasted()
	-- ➜ healbuff can be used
	if skill.healbuff.level > 0 then
		if skill.healbuff:CanBeCasted() and manapool() then
			return false
		end
	end
	-- ➜ Madness can be used
	if item.madness then
		if item.madness:CanBeCasted() and manapool() and item.madness.state == LuaEntityItem.STATE_READY then
			return false
		end
	end
	-- ➜ Medallion of courage can be used
	if item.medallion then
		if item.medallion.state == LuaEntityItem.STATE_READY and item.medallion:CanBeCasted() then
			return false
		end
	end
	-- ➜ Solar Crest can be used
	if item.solarcrest then
		if item.solarcrest.state == LuaEntityItem.STATE_READY and item.solarcrest:CanBeCasted() then
			return false
		end
	end
	-- ➜ Satanic can be used
	if item.satanic then
		if item.satanic.state == LuaEntityItem.STATE_READY and item.satanic:CanBeCasted() and me.health < (me.maxHealth * 0.5) and manapool() then
			return false
		end
	end
	-- ➜ Armlet can be used
	if item.armlet then
		if item.armlet:CanBeCasted() and not item.armletactive and SleepCheck("Armlet_use_delay") then
			return false
		end
	end
	-- ➜ Urn of Shadows can be used
	if item.urn then
		if item.urn:CanBeCasted() and not target:IsMagicDmgImmune() then
			return false
		end
	end
	-- ➜ Mjolnir can be used
	if item.mjollnir then
		if item.mjollnir.state == LuaEntityItem.STATE_READY and item.mjollnir:CanBeCasted() and manapool() then
			return false
		end
	end
	-- ➜ bkb can be used
	if KeyCode.BlackKingBar and item.blackkingbar and item.blackkingbar:CanBeCasted() and manapool() then
		local heroes = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and v.visible and v.team~=me.team and me:GetDistance2D(v) <= 1200 end)
		if #heroes <= 3 then
			return false
		end
	end
	-- ➜ Blademail can be used
	if item.blademail then
		if item.blademail:CanBeCasted() and manapool() then
			return false
		end
	end
	-- ➜ Abyssal can be used
	if item.abyssal then
		if item.abyssal.state == LuaEntityItem.STATE_READY and item.abyssal:CanBeCasted() and manapool() and (not me:DoesHaveModifier("modifier_item_blade_mail_reflect") or target:IsMagicDmgImmune()) then
			return false
		end
	end
	-- ➜ Dust can be used
	if item.dust then
		if item.dust.state == LuaEntityItem.STATE_READY and item.dust:CanBeCasted() and manapool() and EnemyIsInvi() then
			return false
		end
	end
	-- ➜ Buckler can be used
	if item.buckler then
		if item.buckler.state == LuaEntityItem.STATE_READY and item.buckler:CanBeCasted() and manapool() then
			return false
		end
	end
	-- ➜ crimson can be used
	if item.crimson then
		if item.crimson.state == LuaEntityItem.STATE_READY and item.crimson:CanBeCasted() and manapool() then
			return false
		end
	end
	-- ➜ Lotus Orb can be used
	if item.lotusorb then
		if item.lotusorb.state == LuaEntityItem.STATE_READY and item.lotusorb:CanBeCasted() and manapool() then
			return false
		end
	end
	return true
end

-- Manapool Function --
function manapool()
	local manapool = 0
	if skill.healbuff then
		if skill.healbuff.cd < 1 then
			manapool = manapool + skill.healbuff.manacost
		end
	end
	if skill.duel then
		manapool = manapool + skill.duel.manacost
	end
	if item.blademail then
		if item.blademail.cd < 1 then   
			manapool = manapool + item.blademail.manacost
		end
	end
	if item.blackkingbar then
		if item.blackkingbar.cd < 1 and KeyCode.BlackKingBar then    
			manapool = manapool + item.blackkingbar.manacost
		end
	end
	if item.abyssal then
		if item.abyssal.cd < 1 and item.abyssal.state == LuaEntityItem.STATE_READY and not me:DoesHaveModifier("modifier_item_blade_mail_reflect") or target:IsMagicDmgImmune() then    
			manapool = manapool + item.abyssal.manacost
		end
	end
	if item.mjollnir then
		if item.mjollnir.cd < 1 and item.mjollnir.state == LuaEntityItem.STATE_READY then    
			manapool = manapool + item.mjollnir.manacost
		end
	end
	if item.madness then
		if item.madness.cd < 1 and item.madness.state == LuaEntityItem.STATE_READY then    
			manapool = manapool + item.madness.manacost
		end
	end
	if item.satanic then
		if item.satanic.cd < 1 and item.satanic.state == LuaEntityItem.STATE_READY then    
			manapool = manapool + item.satanic.manacost
		end
	end
	if item.dust then
		if item.dust.cd < 1 and item.dust.state == LuaEntityItem.STATE_READY and EnemyIsInvi() then
			manapool = manapool + item.dust.manacost
		end
	end
	if item.buckler then
		if item.buckler.cd < 1 and item.buckler.state == LuaEntityItem.STATE_READY then 
			manapool = manapool + item.buckler.manacost
		end
	end
	if item.crimson then
		if item.crimson.cd < 1 and item.crimson.state == LuaEntityItem.STATE_READY then 
			manapool = manapool + item.crimson.manacost
		end
	end
	if item.lotusorb then
		if item.lotusorb.cd < 1 and item.lotusorb.state == LuaEntityItem.STATE_READY then    
			manapool = manapool + item.lotusorb.manacost
		end
	end
	if me.mana >= manapool then
		return true
	else
		return false
	end
end

-- ✖ END OF GAME  ✖ --
function onClose()
	collectgarbage("collect")
	if registered then
		MyTarget.visible          = false
		BlinkBackGround.visible   = false
		BlinkTexture.visible      = false
		manapooltxt.visible       = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
		return
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
