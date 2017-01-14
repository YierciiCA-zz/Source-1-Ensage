xPosition,yPosition = 220,5
xPositionN,yPositionN = 220,20
myFont = drawMgr:CreateFont("Roshancheg","Arial",13,400)
StatusText = drawMgr:CreateText(xPosition,yPosition,0xFFFFFFFF,"",myFont);
InstructionTextToSpawn = drawMgr:CreateText(xPositionN,yPositionN,0xff0000ff,"Time, to respawn - To complete full respawn",myFont);
InstructionTextSpawn = drawMgr:CreateText(xPositionN,yPositionN,0x00ff00ff,"Begun respawn time - To complete full respawn",myFont);
ReloadTextSpawn = drawMgr:CreateText(xPositionN,yPositionN,0xff0000ff,"The respawn time of unknown!",myFont);
sleepTick = nil
function Frame( tick )
	if not client.connected or client.loading or client.console then
		return
	end
	
	local entities = entityList:FindEntities({classId=CDOTA_Unit_Roshan})
	
	if not deathTime then
		if #entities == 1 then
			StatusText.text = "Roshan: Alive"
			ReloadTextSpawn.visible=false
			InstructionTextToSpawn.visible = false
			InstructionTextSpawn.visible = false
		elseif #entities == 0 then
			StatusText.text = "Roshan: Dead"
			ReloadTextSpawn.visible = true
			InstructionTextToSpawn.visible = false
			InstructionTextSpawn.visible = false
		end
		return
	end
	
	local tickDelta = client.gameTime-deathTime
	local minutes = math.floor(tickDelta/60)
	local seconds = tickDelta%60
	local printMe
	
	if client.gameTime > sleepTick and #entities > 0 then
		local rosh = entities[1]
		if rosh and rosh.alive then
			deathTime = nil
			return
		end
	end
	if minutes < 8 then
		printMe = string.format("Roshan: %02d:%02d - %02d:%02d ++",7-minutes,59-seconds,10-minutes,59-seconds)
	elseif minutes == 8 then
		InstructionTextToSpawn.visible = false
		InstructionTextSpawn.visible = true
		printMe = string.format("Roshan: %02d:%02d - %02d:%02d ++",8-minutes,59-seconds,10-minutes,59-seconds)
	elseif minutes == 9 then
		printMe = string.format("Roshan: %02d:%02d - %02d:%02d ++",9-minutes,59-seconds,10-minutes,59-seconds)
	else
		printMe = string.format("Roshan: %02d:%02d",0,59-seconds)
	end

	StatusText.text = printMe
	
end
function Roshanchik( kill )
    if kill.name == "dota_roshan_kill" then
		script:RegisterEvent(EVENT_TICK,ubiliroshana)
    end
end
function ubiliroshana(tick)
	deathTime = client.gameTime
	sleepTick = client.gameTime+10
	InstructionTextToSpawn.visible=true
	ReloadTextSpawn.visible=false
	if reakciyacheloveka == nil then
		sleep = tick + 1000
		reakciyacheloveka = 1
	end
	if tick > sleep then
		client:ExecuteCmd("chatwheel_say 53")
		client:ExecuteCmd("chatwheel_say 57")
		reakciyacheloveka = nil
		script:UnregisterEvent(ubiliroshana)
	end
end

function Close()
	script:UnregisterEvent(Frame)
	script:UnregisterEvent(Roshanchik)
	deathTime = nil
	InstructionTextToSpawn.visible = false
	InstructionTextSpawn.visible = false
	StatusText.visible = false
	ReloadTextSpawn.visible = false
	registered = false
end

function Load()
	if registered then return end
	script:RegisterEvent(EVENT_FRAME,Frame)
	script:RegisterEvent(EVENT_DOTA,Roshanchik)
	InstructionTextToSpawn.visible = false
	InstructionTextSpawn.visible = false
	StatusText.visible = true
	ReloadTextSpawn.visible = false
	registered = true
end

if client.connected and not client.loading then
	Load()
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_LOAD,Load)