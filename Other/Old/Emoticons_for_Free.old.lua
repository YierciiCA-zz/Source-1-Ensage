--<<IMPORTANT! Download texture https://mega.co.nz/#!qMMCUaJD!FaqONLMxfS1hHAxa8V-72g1CvTKjmM_-7f22RyrFPEQ and unpack to NyanUI/>>

local rec = {}
local rate = client.screenSize.x/1600
local xx = 807.5
local yy = 607
local move = false
local activate = false
local sayTo = "say_team "

local ShiftEnter = {16,13}
--1
rec[1] = drawMgr:CreateRect(5*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/other/XY"))
rec[2] = drawMgr:CreateRect(25*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/wink"))
rec[3] = drawMgr:CreateRect(45*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/blush"))
rec[4] = drawMgr:CreateRect(65*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/cheeky"))
rec[5] = drawMgr:CreateRect(85*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/cool"))
rec[6] = drawMgr:CreateRect(105*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/crazy"))
rec[7] = drawMgr:CreateRect(125*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/cry"))
rec[8] = drawMgr:CreateRect(145*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/disapprove"))
rec[9] = drawMgr:CreateRect(165*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/minirunes/doubledamage"))
rec[10] = drawMgr:CreateRect(185*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/facepalm"))
rec[11] = drawMgr:CreateRect(205*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/happytears"))
rec[12] = drawMgr:CreateRect(225*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/haste"))
rec[13] = drawMgr:CreateRect(245*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/hex"))
rec[14] = drawMgr:CreateRect(265*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/highfive"))
rec[15] = drawMgr:CreateRect(285*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/huh"))
--2
rec[16] = drawMgr:CreateRect(5*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/hush"))
rec[17] = drawMgr:CreateRect(25*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/minirunes/illusion"))
rec[18] = drawMgr:CreateRect(45*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/minirunes/invis"))
rec[19] = drawMgr:CreateRect(65*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/ti5_antimage"))
rec[20] = drawMgr:CreateRect(85*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/rage"))
rec[21] = drawMgr:CreateRect(105*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/minirunes/regen"))
rec[22] = drawMgr:CreateRect(125*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/sad"))
rec[23] = drawMgr:CreateRect(145*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/ti5_pudge_troll"))
rec[24] = drawMgr:CreateRect(165*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/sleeping"))
rec[25] = drawMgr:CreateRect(185*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/smile"))
rec[26] = drawMgr:CreateRect(205*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/surprise"))
rec[27] = drawMgr:CreateRect(225*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/bts3_bristle"))
rec[28] = drawMgr:CreateRect(245*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/burn"))
rec[29] = drawMgr:CreateRect(265*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/hide"))
rec[30] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/iceburn"))
--3
rec[31] = drawMgr:CreateRect(5*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/tears"))
rec[32] = drawMgr:CreateRect(25*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/techies"))
rec[33] = drawMgr:CreateRect(45*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/dac15_fade"))
rec[34] = drawMgr:CreateRect(65*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/goodjob"))
rec[35] = drawMgr:CreateRect(85*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/headshot"))
rec[36] = drawMgr:CreateRect(105*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/heart"))
rec[37] = drawMgr:CreateRect(125*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/horse"))
rec[38] = drawMgr:CreateRect(145*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/grave"))
rec[39] = drawMgr:CreateRect(165*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/ti4_gold"))
rec[40] = drawMgr:CreateRect(185*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/fire"))
rec[41] = drawMgr:CreateRect(205*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/bts3_merlini"))
rec[42] = drawMgr:CreateRect(225*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/bts3_rosh"))
rec[43] = drawMgr:CreateRect(245*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/dac15_water"))
rec[44] = drawMgr:CreateRect(265*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/dac15_angry"))
rec[45] = drawMgr:CreateRect(285*rate,100*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/emoticons/puppy"))
rec[46] = drawMgr:CreateRect(5*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/other/Passive_Deny"))

rec[#rec+1] = drawMgr:CreateRect(5*rate,60*rate,300*rate,60*rate,0x0000070)

for i = 1, #rec do
                         rec[i].visible = false
end

function Tick(tick)                         
                         if move then
                          xx = client.mouseScreenPosition.x - 5*rate - 25 yy = client.mouseScreenPosition.y - 60*rate - 12
                          Clear()                          
                         end
             	         if IsKeysDown(ShiftEnter) then
						  sayTo = "say "
						  rec[46].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Deny")
						 elseif IsKeyDown(13) and not IsKeyDown(16) and not rec[46].visible == true then
						  sayTo = "say_team "
						  rec[46].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Deny")
						 end
end

function Key(msg,code)                         

                         if not client.chat then
						 for i = 1,#rec do                         
                           rec[i].visible = false
                          end
						  activate = not activate
						 return
						 end
						 for i = 1,#rec do                         
                           rec[i].visible = true
                          end
						  activate = true
                         if msg == LBUTTON_DOWN then -- Left mouse
                          if activate then
                           if IsMouseOn(rec[1]) then                         
                            move = not move    SaveGUIConfig()
                           elseif IsMouseOn(rec[2]) then
							client:ExecuteCmd(sayTo.."") --wink
                           elseif IsMouseOn(rec[3]) then
                            client:ExecuteCmd(sayTo.."") --blush
                           elseif IsMouseOn(rec[4]) then
                            client:ExecuteCmd(sayTo.."") --cheeky
                           elseif IsMouseOn(rec[5]) then
                            client:ExecuteCmd(sayTo.."") --cool
                           elseif IsMouseOn(rec[6]) then
                            client:ExecuteCmd(sayTo.."") --crazy
                           elseif IsMouseOn(rec[7]) then
                            client:ExecuteCmd(sayTo.."") --cry
                           elseif IsMouseOn(rec[8]) then
                            client:ExecuteCmd(sayTo.."") --disapprove
                           elseif IsMouseOn(rec[9]) then
                            client:ExecuteCmd(sayTo.."") --doubledamage
                           elseif IsMouseOn(rec[10]) then
                            client:ExecuteCmd(sayTo.."") --facepalm
                           elseif IsMouseOn(rec[11]) then
                            client:ExecuteCmd(sayTo.."") --happytears
                           elseif IsMouseOn(rec[12]) then
                            client:ExecuteCmd(sayTo.."") --haste
                           elseif IsMouseOn(rec[13]) then
                            client:ExecuteCmd(sayTo.."") --hex
                           elseif IsMouseOn(rec[14]) then
                            client:ExecuteCmd(sayTo.."") --highfive
                           elseif IsMouseOn(rec[15]) then
                            client:ExecuteCmd(sayTo.."") --huh
							
                           elseif IsMouseOn(rec[16]) then                         
                            client:ExecuteCmd(sayTo.."") --hush
                           elseif IsMouseOn(rec[17]) then
                            client:ExecuteCmd(sayTo.."") --illusion
                           elseif IsMouseOn(rec[18]) then
                            client:ExecuteCmd(sayTo.."") --invisibility
                           elseif IsMouseOn(rec[19]) then
                            client:ExecuteCmd(sayTo.."") --ti5_antimage
                           elseif IsMouseOn(rec[20]) then
                            client:ExecuteCmd(sayTo.."") --rage
                           elseif IsMouseOn(rec[21]) then
                            client:ExecuteCmd(sayTo.."") --regeneration
                           elseif IsMouseOn(rec[22]) then
                            client:ExecuteCmd(sayTo.."") --sad
                           elseif IsMouseOn(rec[23]) then
                            client:ExecuteCmd(sayTo.."") --ti5_pudge_troll
                           elseif IsMouseOn(rec[24]) then
                            client:ExecuteCmd(sayTo.."") --sleeping
                           elseif IsMouseOn(rec[25]) then
                            client:ExecuteCmd(sayTo.."") --smile
                           elseif IsMouseOn(rec[26]) then
                            client:ExecuteCmd(sayTo.."") --surprise 
                           elseif IsMouseOn(rec[27]) then
                            client:ExecuteCmd(sayTo.."") --bts3_bristle
                           elseif IsMouseOn(rec[28]) then
                            client:ExecuteCmd(sayTo.."") --burn
                           elseif IsMouseOn(rec[29]) then
                            client:ExecuteCmd(sayTo.."") --hide
                           elseif IsMouseOn(rec[30]) then
                            client:ExecuteCmd(sayTo.."") --iceburn
                      
                           elseif IsMouseOn(rec[31]) then
                            client:ExecuteCmd(sayTo.."") --tears
                           elseif IsMouseOn(rec[32]) then
                            client:ExecuteCmd(sayTo.."") --techies
                           elseif IsMouseOn(rec[33]) then
                            client:ExecuteCmd(sayTo.."") --dac15_fade
                           elseif IsMouseOn(rec[34]) then
                            client:ExecuteCmd(sayTo.."") --goodjob
                           elseif IsMouseOn(rec[35]) then
                            client:ExecuteCmd(sayTo.."") --headshot
                           elseif IsMouseOn(rec[36]) then
                            client:ExecuteCmd(sayTo.."") --heart
                           elseif IsMouseOn(rec[37]) then
                            client:ExecuteCmd(sayTo.."") --horse
                           elseif IsMouseOn(rec[38]) then
                            client:ExecuteCmd(sayTo.."") --grave
                           elseif IsMouseOn(rec[39]) then
                            client:ExecuteCmd(sayTo.."") --ti4_gold
                           elseif IsMouseOn(rec[40]) then
                            client:ExecuteCmd(sayTo.."") --fire
                           elseif IsMouseOn(rec[41]) then
                            client:ExecuteCmd(sayTo.."") --bts_merlini
                           elseif IsMouseOn(rec[42]) then
                            client:ExecuteCmd(sayTo.."") --bts_rosh
                           elseif IsMouseOn(rec[43]) then
                            client:ExecuteCmd(sayTo.."") --dac15_water
                           elseif IsMouseOn(rec[44]) then
                            client:ExecuteCmd(sayTo.."") --dac15_angry
                           elseif IsMouseOn(rec[45]) then
                            client:ExecuteCmd(sayTo.."") --puppy
                           elseif IsMouseOn(rec[46]) then
                           end
                          end
						  if IsMouseOn(rec[46]) then
                           if sayTo == "say_team " then
						   sayTo = "say "
						   rec[46].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Deny")
						   elseif sayTo == "say " then
						   sayTo = "say_team "
						   rec[46].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Deny")
						   end
                          end
						  end
end

function IsMouseOn(obj)
                         local mx = client.mouseScreenPosition.x
                         local my = client.mouseScreenPosition.y
                         return mx > obj.x and mx <= obj.x + obj.w and my > obj.y and my <= obj.y + obj.h
end

-- From Utils lib
function IsKeysDown(key_table,orCheck)
	smartAssert(GetType(key_table) == "table", debug.getinfo(1, "n").name..": Invalid Key Table")
	if not orCheck then orCheck = false end
    for i,v in ipairs(key_table) do
    	local bool = nil
    	if v >= 0 then
    		bool = IsKeyDown(v)
    	else
			bool = not IsKeyDown(-v)
    	end
        if (not orCheck and not bool) or (orCheck and bool) then
                return bool
    	end
    end
    return not orCheck
end

function smartAssert(condition, ...)
	if not condition then
		if next({...}) then
			local s,r = pcall(function (...) return(string.format(...)) end, ...)
			if s then
				print(debug.traceback())
            			error("assertion failed!: " .. r, 2)
         		end
      		end
		print(debug.traceback())
		error("assertion failed!", 2)
	end
end
-- From Utils lib END

function SaveGUIConfig()
                         local file = io.open(SCRIPT_PATH.."/config/EmoticonsConfig.txt", "w+")
                         if file then
                          file:write(xx.."\n"..yy)
                          file:close()
                         end
end
                            
function LoadGUIConfig()
                         local file = io.open(SCRIPT_PATH.."/config/EmoticonsConfig.txt", "r")
                         if file then
                          xx, yy = file:read("*number", "*number")
                          file:close()                           
                         end
                         if not xx then                         
                          xx = 807.5
                          yy = 607
                         end
end

function Clear()
                         rec[#rec].x = 25*rate + xx
                         rec[#rec].y = 60*rate + yy
                         for i = 1,#rec-1 do
                          if i < 16 then
                           rec[i].x = 25*rate+20*(i-1)*rate + xx
                           rec[i].y = 60*rate + yy                            
                          elseif i < 31 then
                           rec[i].x = 25*rate+20*(i-16)*rate + xx
                           rec[i].y = 80*rate + yy                         
                          else
                           rec[i].x = 25*rate+20*(i-31)*rate + xx
                           rec[i].y = 100*rate + yy
                          end
                         end
end

function Load()
                         if PlayingGame() then
                          LoadGUIConfig()
                          rec[#rec].x = 25*rate + xx
                          rec[#rec].y = 60*rate + yy
                          rec[#rec].visible = false
                          for i = 1,#rec-1 do
                           if i < 16 then
                            rec[i].x = 25*rate+20*(i-1)*rate + xx
                            rec[i].y = 60*rate + yy                            
                           elseif i < 31 then
                            rec[i].x = 25*rate+20*(i-16)*rate + xx
                            rec[i].y = 80*rate + yy                         
                           else
                            rec[i].x = 25*rate+20*(i-31)*rate + xx
                            rec[i].y = 100*rate + yy
                           end
                           rec[i].visible = false
                          end                           
                          play = true
                          script:RegisterEvent(EVENT_KEY,Key)
                          script:RegisterEvent(EVENT_TICK,Tick)
                          script:UnregisterEvent(Load)
                         end
end

function GameClose()
                         if play then
                          for i = 1,#rec do                         
                           rec[i].visible = false
                          end                         
                          move = false
                          activate = false
						  sayTo = "say_team "
                          script:UnregisterEvent(Key)
                          script:UnregisterEvent(Tick)
                          script:RegisterEvent(EVENT_TICK,Load)
                          play = false
                         end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)