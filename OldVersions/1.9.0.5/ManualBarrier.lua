--
-- Manual Barrier (automatic included) FS17 Edition
-- by Blacky_BPG
-- 
--
-- Version 1.9.0.5   | 21.12.2019 - fix non working farm restricted on manualOpen
-- Version 1.9.0.4   | 16.12.2019 - fix error on saving random event barrier
-- Version 1.9.0.3   | 14.12.2019 - fix missing message on random closed triggers
-- Version 1.9.0.2   | 12.12.2019 - fix error on enter trigger with weight
-- Version 1.9.0.1   | 08.12.2019 - script converted to FS19
-- Version 1.4.4.0 G | 31.10.2017 - fixed random closed object with automatic open/close function, fix load function for random chance
-- Version 1.4.4.0 F | 27.10.2017 - add posibility for multiple opening and closing times
-- Version 1.4.4.0 E | 28.05.2017 - fix multiplayer event error, fix wrong open text in help window
-- Version 1.4.4.0 D | 20.05.2017 - fix control key activation  (thanks to SanAndreas76), fix closeWhileRain for more actions (thanks to alfalfa6945)
-- Version 1.4.4.0 C | 11.05.2017 - add own control key variable for every object
-- Version 1.4.4.0 B | 06.05.2017 - close while rain function by alfalfa6945 implemented
-- Version 1.4.4.0 A | 06.05.2017 - fixed trigger with NoRigidBody for automatic type functions (thanks to alfalfa6945)
-- Version 1.4.4.0   | 10.04.2017 - fixed warning message for random close events
-- Version 1.3.1.0   | 17.12.2016 - multiplayer fixed and tested
-- Version 1.3.0.0 C | 05.12.2016 - smaller improvements
-- Version 1.3.0.0 B | 30.11.2016 - fix wrong variable
-- Version 1.3.0.0 A | 22.11.2016 - add animation direction setting for reverse play animation, add audio loop functionality
-- Version 1.3.0.0   | 17.11.2016 - script converted to FS17
-- Version 5.15.19   | 13.12.2015 - add all FS13 functions to FS15 version of ManualBarrier
-- Version 5.15.18   | 12.12.2015 - fieldId variable for automaticMode activated
-- Version 5.15.17   | 18.10.2015 - add random close option like OpenDoor Trigger
-- Version 5.15.14   | 17.10.2015 - add error messages for easy failure detection
-- Version 5.15.13   | 13.10.2015 - add various functions from OpenDoor Trigger
-- Version 5.15.12   | 12.10.2015 - fixed start rotation for barrier types
-- Version 5.15.11   | 22.09.2015 - add rotatable object and open/close symbols
-- Version 5.15.10   | 21.09.2015 - fixed global variable for working allong FS13 ODT Script
-- Version 5.15.9    | 28.02.2015 - add fieldId variable for ownership check, add traffic option
-- Version 5.15.8    | 29.12.2014 - fixed wrong variables for type gate (Thanks TracMaxX)
-- Version 5.15.7    | 07.12.2014 - fixed sound bug for barrier functionality, remove scripted collision mask setting for manual setting the required values
-- Version 5.15.6    | 04.12.2014 - fixed automatic mode for night useability
-- Version 5.15.5    | 29.11.2014 - fixed error when a trailer leaves the trigger before the vehicle (reverse drive for example)
-- Version 5.15.4    | 08.11.2014
--
-- No script change without my permission
-- 

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--   ATTENTION      ATTENTION      ATTENTION      ATTENTION      ATTENTION   --
-- ========================================================================= --
--   The UserAttribute   manualBarrierId   must be unique for each object    --
--   that must work with this script, thats realy important, otherwise       --
--   you can open only the last assigned objects with the same               --
--   manualBarrierId .                                                       --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


ManualBarrier = {}
ManualBarrier.version = "1.9.0.5"
ManualBarrier.date = "21.12.2019"
ManualBarrier.keyId = nil
ManualBarrier_mt = Class(ManualBarrier, Object)
InitObjectClass(ManualBarrier, "ManualBarrier")

function ManualBarrier.onCreate(id)
	local object = ManualBarrier:new(g_server ~= nil, g_client ~= nil)
	if object:load(id) then
		g_currentMission:addOnCreateLoadedObject(object)
		g_currentMission:addOnCreateLoadedObjectToSave(object)
		object:register(true)
		table.insert(g_currentMission.updateables, object)
	else
		object:delete()
	end
end
function ManualBarrier:new(isServer, isClient, customMt)
	local mt = customMt
	if mt == nil then
		mt = ManualBarrier_mt
	end
	local self = Object:new(isServer, isClient, mt)
	self.openState = 0
	return self
end
function ManualBarrier:delete()
	if self.triggerId ~= nil and getRigidBodyType(self.triggerId) ~= "NoRigidBody" then
		removeTrigger(self.triggerId)
	end
	if self.nodeId ~= 0 then
		g_currentMission:removeNodeObject(self.nodeId)
	end
	ManualBarrier:superClass().delete(self)
end
function ManualBarrier:readStream(streamId, connection)
	ManualBarrier:superClass().readStream(self, streamId, connection)
	if connection:getIsServer() then
		self.openState = streamReadInt8(streamId)
		self.randomActive = streamReadBool(streamId)
		self.randomStart = streamReadFloat32(streamId)
		self.randomEnd = streamReadFloat32(streamId)
		self.randomActiveText = streamReadString(streamId)
	end
end
function ManualBarrier:writeStream(streamId, connection)
	ManualBarrier:superClass().writeStream(self, streamId, connection)
	if not connection:getIsServer() then
		streamWriteInt8(streamId, self.openState)
		streamWriteBool(streamId, self.randomActive)
		streamWriteFloat32(streamId, self.randomStart)
		streamWriteFloat32(streamId, self.randomEnd)
		streamWriteString(streamId, Utils.getNoNil(self.randomActiveText," "))
	end
end
function ManualBarrier:readUpdateStream(streamId, timestamp, connection)
	ManualBarrier:superClass().readUpdateStream(self, streamId, timestamp, connection)
	if connection:getIsServer() then
		self.openState = streamReadInt8(streamId)
		self.randomActive = streamReadBool(streamId)
		self.randomStart = streamReadFloat32(streamId)
		self.randomEnd = streamReadFloat32(streamId)
		self.randomActiveText = streamReadString(streamId)
	end
end
function ManualBarrier:writeUpdateStream(streamId, connection, dirtyMask)
	ManualBarrier:superClass().writeUpdateStream(self, streamId, connection, dirtyMask)
	if not connection:getIsServer() then
		streamWriteInt8(streamId, self.openState)
		streamWriteBool(streamId, self.randomActive)
		streamWriteFloat32(streamId, self.randomStart)
		streamWriteFloat32(streamId, self.randomEnd)
		streamWriteString(streamId, Utils.getNoNil(self.randomActiveText," "))
	end
end
function ManualBarrier:load(nodeId)
	self.nodeId = nodeId

	local manualBarrierId = getUserAttribute(nodeId, "manualBarrierId")
	if manualBarrierId ~= nil then
		self.manualBarrierId = manualBarrierId
	else
		return false
	end
	self.triggerId = nil
	local triggerId = getUserAttribute(nodeId, "triggerIndex")
	if triggerId ~= nil and triggerId ~= "" then
		self.triggerId = I3DUtil.indexToObject(nodeId,triggerId)
	else
		self.triggerId = nodeId
	end
	self.triggerObjectFarmId = 0
	self.triggerPlayer = 0

	self.farmLandRestricted = Utils.getNoNil(getUserAttribute(nodeId, "farmLandRestricted"), false)
	self.allowTraffic = Utils.getNoNil(getUserAttribute(nodeId, "allowTraffic"), false)
	self.getRainyWeather = ManualBarrier.getRainyWeather
	self.closeIfRaining = Utils.getNoNil(getUserAttribute(nodeId, "closeIfRaining"), false)

	self.typeBarrier = Utils.getNoNil(getUserAttribute(nodeId, "typeBarrier"), false)
	self.typeGate = Utils.getNoNil(getUserAttribute(nodeId, "typeGate"), false)
	self.typeAnimated = Utils.getNoNil(getUserAttribute(nodeId, "typeAnimated"), false)
	self.typeLight = Utils.getNoNil(getUserAttribute(nodeId, "typeLight"), false)
	self.flickerMode = Utils.getNoNil(getUserAttribute(nodeId, "flickerMode"), false)
	self.lightOnMove = Utils.getNoNil(getUserAttribute(nodeId, "lightOnMove"), false)
	self.lightOnlyNight = Utils.getNoNil(getUserAttribute(nodeId, "lightOnlyNight"),false)
	self.lightAutoNight = Utils.getNoNil(getUserAttribute(nodeId, "lightAutoNight"),false)
	self.lightAutoNightOn = Utils.getNoNil(getUserAttribute(nodeId, "lightsAutoNightOn"),-1)
	self.lightAutoNightOff = Utils.getNoNil(getUserAttribute(nodeId, "lightsAutoNightOff"),-1)
	self.flickerCounter = 0
	local lightGreen = getUserAttribute(nodeId, "greenLightIndex")
	local lightRed = getUserAttribute(nodeId, "redLightIndex")
	if lightGreen ~= nil then self.lightGreen = I3DUtil.indexToObject(nodeId, lightGreen) end
	if lightRed ~= nil then self.lightRed = I3DUtil.indexToObject(nodeId, lightRed) end

	self.stringOpen = Utils.getNoNil(getUserAttribute(nodeId, "string_Open"), "string_OPEN")
	self.stringClose = Utils.getNoNil(getUserAttribute(nodeId, "string_Close"), "string_CLOSE")
	self.stringName = Utils.getNoNil(getUserAttribute(nodeId, "string_Name"), "string_DEFAULT")
	self.stringOption = self.stringOpen

	self.automaticMode = Utils.getNoNil(getUserAttribute(nodeId, "automaticMode"), false)
	self.halfAutomatic = false
	local automaticOpen = StringUtil.splitString(" ", Utils.getNoNil(getUserAttribute(nodeId, "automaticOpen"), 7))
	local automaticClose = StringUtil.splitString(" ", Utils.getNoNil(getUserAttribute(nodeId, "automaticClose"), 18))
	self.automaticOpen = {}
	self.automaticClose = {}
	local lastOpen, lastClose = -1,-1
	for k,v in pairs(automaticOpen) do
		v = tonumber(v)
		local x = tonumber(Utils.getNoNil(automaticClose[k],v+1))
		if lastOpen > -1 and lastClose > -1 then
			if v > lastOpen then
				if v > lastClose then
					lastOpen = v
					lastClose = x
					self.automaticOpen[k] = lastOpen
					self.automaticClose[k] = lastClose
					if self.automaticClose[k] >= 24 then self.automaticClose[k] = self.automaticClose[k] - 24 end
				else
					print(" Error: Manual Barrier ID "..tostring(self.manualBarrierId).." lastOpenTime "..tostring(v).." (Index="..tostring(k)..") can not be befor lastClose time")
				end
			else
				print(" Error: Manual Barrier ID "..tostring(self.manualBarrierId).." lastOpenTime "..tostring(v).." (Index="..tostring(k)..") can not be befor lastOpen time")
			end
		else
			lastOpen = v
			lastClose = x
			self.automaticOpen[k] = lastOpen
			self.automaticClose[k] = lastClose
			if self.automaticClose[k] >= 24 then self.automaticClose[k] = self.automaticClose[k] - 24 end
		end
	end
	self.automaticStrict = Utils.getNoNil(getUserAttribute(nodeId, "automaticStrict"), false)
	self.closeSymbol = nil
	local closeSymbolIndex = getUserAttribute(nodeId, "closeSymbolIndex")
	if closeSymbolIndex ~= nil then
		local closeSymbolNode = I3DUtil.indexToObject(nodeId, closeSymbolIndex)
		if closeSymbolNode ~= nil then self.closeSymbol = closeSymbolNode end
	end
	self.openSymbol = nil
	local openSymbolIndex = getUserAttribute(nodeId, "openSymbolIndex")
	if openSymbolIndex ~= nil then
		local openSymbolNode = I3DUtil.indexToObject(nodeId, openSymbolIndex)
		if openSymbolNode ~= nil then self.openSymbol = openSymbolNode end
	end
	self.rotationObject = nil
	local rotationObjectIndex = getUserAttribute(nodeId, "rotationObjectIndex")
	if rotationObjectIndex ~= nil then
		local rotationObjectNode = I3DUtil.indexToObject(nodeId, rotationObjectIndex)
		if rotationObjectNode ~= nil then
			self.rotationObject = rotationObjectNode
			self.rotationObjectSpeed = Utils.getNoNil(getUserAttribute(nodeId, "rotationObjectSpeed"), 10) / 1200
			self.rotationObjectAxis = Utils.getNoNil(getUserAttribute(nodeId, "rotationObjectAxis"), 1)
			if self.rotationObjectAxis < 1 or self.rotationObjectAxis > 3 then self.rotationObjectAxis = 1 end
		end
	end

	self.manualOpen = Utils.getNoNil(getUserAttribute(nodeId, "manualOpen"), false)
	self.openState = 1
	self.keysActive = false
	if self.manualOpen then
		self.openState = 0
		if self.automaticMode then
			self.halfAutomatic = true
			self.automaticMode = false
		end
		FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, ManualBarrier.registerActionEvents)
	end

	self.playerInTrigger = false

	self.Barriers = {}
	self.audio = nil
	self.light = nil
	self.speedScale = Utils.getNoNil(getUserAttribute(nodeId, "speedScale"),60) / 20
	self.animCharSet = 0
	self.trackTime = 0
	self.lastTrackTime = 0
	local audio = getUserAttribute(nodeId, "audioIndex")
	if audio ~= nil then
		self.audio = I3DUtil.indexToObject(nodeId, audio)
		self.audioLoopOnClose = Utils.getNoNil(getUserAttribute(nodeId, "audioLoopOnClose"),false)
		self.audioLoopOnOpen = Utils.getNoNil(getUserAttribute(nodeId, "audioLoopOnOpen"),false)
	end
	if self.typeLight then
		local lightIndex = getUserAttribute(nodeId, "lightIndex")
		if lightIndex ~= nil then
			local lightNode = I3DUtil.indexToObject(nodeId, lightIndex)
			if lightNode ~= nil then
				self.light = lightNode
			else
				self.typeLight = false
			end
		else
			self.typeLight = false
		end
	end
	if self.typeBarrier or self.typeGate then
		local num = getNumOfChildren(self.triggerId)
		if num == nil then
			print(" Error: Trigger has no child objects for Manual Barrier ID "..tostring(self.manualBarrierId)..", object deactivated.")
			return false
		end
		for i=0, num-1 do
			local childLevel1 = getChildAt(self.triggerId, i)
			if childLevel1 ~= 0 and getNumOfChildren(childLevel1) >= 1 then
				local BarriersId = getChildAt(childLevel1, 0)
				if BarriersId ~= 0 then
					local barrier = {}
					barrier.node = BarriersId
					barrier[1] = {}
					barrier[2] = {}
					barrier[3] = {}
					local rotX, rotY, rotZ = getRotation(BarriersId)
					barrier[1].maxAngle = Utils.getNoNil(getUserAttribute(nodeId, "maxXAngle"), rotX)
					barrier[1].minAngle = Utils.getNoNil(getUserAttribute(nodeId, "minXAngle"), rotX)
					barrier[2].maxAngle = Utils.getNoNil(getUserAttribute(nodeId, "maxYAngle"), rotY)
					barrier[2].minAngle = Utils.getNoNil(getUserAttribute(nodeId, "minYAngle"), rotY)
					barrier[3].maxAngle = Utils.getNoNil(getUserAttribute(nodeId, "maxZAngle"), rotZ)
					barrier[3].minAngle = Utils.getNoNil(getUserAttribute(nodeId, "minZAngle"), rotZ)
					barrier[1].angle = (barrier[1].maxAngle - barrier[1].minAngle) / 2
					barrier[2].angle = (barrier[2].maxAngle - barrier[2].minAngle) / 2
					barrier[3].angle = (barrier[3].maxAngle - barrier[3].minAngle) / 2

					barrier[1].trans, barrier[2].trans, barrier[3].trans = getTranslation(BarriersId)
					barrier[1].maxTrans = Utils.getNoNil(getUserAttribute(nodeId, "maxX"), barrier[1].trans)
					barrier[1].minTrans = Utils.getNoNil(getUserAttribute(nodeId, "minX"), barrier[1].trans)
					barrier[2].maxTrans = Utils.getNoNil(getUserAttribute(nodeId, "maxY"), barrier[2].trans)
					barrier[2].minTrans = Utils.getNoNil(getUserAttribute(nodeId, "minY"), barrier[2].trans)
					barrier[3].maxTrans = Utils.getNoNil(getUserAttribute(nodeId, "maxZ"), barrier[3].trans)
					barrier[3].minTrans = Utils.getNoNil(getUserAttribute(nodeId, "minZ"), barrier[3].trans)
					table.insert(self.Barriers, barrier)
				end
			end
		end
	end
	if self.typeAnimated then
		local animIndex = getUserAttribute(nodeId, "animatorIndex")
		local rootNode = nil
		if animIndex ~= nil then
			rootNode = I3DUtil.indexToObject(nodeId, animIndex)
		else
			self.typeAnimated = false
		end
		if rootNode ~= nil then
			self.animCharSet = getAnimCharacterSet(rootNode)
			if self.animCharSet ~= 0 then
				local clipSource = getUserAttribute(nodeId, "animationClip")
				if clipSource ~= nil then
					self.clip = getAnimClipIndex(self.animCharSet, clipSource)
					if self.clip ~= nil and self.clip >= 0 then
						self.animDirection = Utils.getNoNil(getUserAttribute(nodeId, "animatorDirection"),1)
						assignAnimTrackClip(self.animCharSet, 0, self.clip)
						setAnimTrackLoopState(self.animCharSet, 0, false)
						setAnimTrackSpeedScale(self.animCharSet, 0, self.speedScale)
						self.animDuration = getAnimClipDuration(self.animCharSet, self.clip)
						enableAnimTrack(self.animCharSet, self.clip)
						if self.animDirection > 0 then
							setAnimTrackTime(self.animCharSet, self.clip, 0, true)
						elseif self.animDirection < 0 then
							setAnimTrackTime(self.animCharSet, self.clip, self.animDuration, true)
						end
						disableAnimTrack(self.animCharSet, self.clip)
					else
						print(" Error: Manual barrier with ID "..tostring(self.manualBarrierId).." should be typeAnimated but has no clip in clipSource")
						self.typeAnimated = false
					end
				else
					print(" Error: Manual barrier with ID "..tostring(self.manualBarrierId).." should be typeAnimated but has no animation clip assigned")
					self.typeAnimated = false
				end
			else
				print(" Error: Manual barrier with ID "..tostring(self.manualBarrierId).." should be typeAnimated but no animation is assigned to object "..tostring(animIndex))
				self.typeAnimated = false
			end
		else
			print(" Error: Manual barrier with ID "..tostring(self.manualBarrierId).." should be typeAnimated but object for animation can not be found")
			self.typeAnimated = false
		end
	end

	if not self.typeBarrier and not self.typeGate and not self.typeAnimated and not self.typeLight then
		print(" Error: Manual barrier with ID "..tostring(self.manualBarrierId).." cant be loaded, no type specified")
		return false
	end
	self.saveId = "ManualBarrier_"
	if self.typeBarrier then
		self.saveId = self.saveId .."B"
	end
	if self.typeGate then
		self.saveId = self.saveId .."G"
	end
	if self.typeAnimated then
		self.saveId = self.saveId .."A"
	end
	if self.typeLight then
		self.saveId = self.saveId .."L"
	end
	self.saveId = self.saveId.."_"..tostring(self.manualBarrierId)

	if self.triggerId ~= nil and getRigidBodyType(self.triggerId) ~= "NoRigidBody" then
		addTrigger(self.triggerId, "triggerCallback", self)
	end

	self.isEnabled = true
	self.count = 0

	if self.audio ~= nil then
		setVisibility(self.audio, false)
	end

	if self.light ~= nil then
		setVisibility(self.light, false)
	end

	self.randomClose = Utils.getNoNil(getUserAttribute(nodeId, "randomClose"), false)
	self.randomRotate = Utils.getNoNil(getUserAttribute(nodeId, "randomRotate"), false)
	self.randomLight = Utils.getNoNil(getUserAttribute(nodeId, "randomLight"), false)
	self.randomChance = Utils.getNoNil(getUserAttribute(nodeId, "randomChance"), 25) / 2
	self.randomStart = 0
	self.randomEnd = 0
	self.randomActive = false
	self.randomCMskBckup = 0
	self.randomRun = false
	self.randomText1 = Utils.getNoNil(getUserAttribute(nodeId, "randomText1"), "default_noentry_msg")
	self.randomText2 = Utils.getNoNil(getUserAttribute(nodeId, "randomText2"), "default_noentry_msg")
	self.randomText3 = Utils.getNoNil(getUserAttribute(nodeId, "randomText3"), "default_noentry_msg")
	if self.randomText1 == "" then
		self.randomText1 = "default_noentry_msg"
	end
	if self.randomText2 == "" then
		self.randomText2 = "default_noentry_msg"
	end
	if self.randomText3 == "" then
		self.randomText3 = "default_noentry_msg"
	end
	self.randomActiveText = " "
	self.randomCheckHour = 0

	self.setOpenState = ManualBarrier.setOpenState

	self.ManualBarrierDirtyFlag = self:getNextDirtyFlag()
	self.triggerIsAdded = false
	
	self.debugA = 0
	self.debugB = 0

	return true
end
function ManualBarrier:registerActionEvents()
    local arg, eventName = g_inputBinding:registerActionEvent(InputAction.OPEN_GATE,ManualBarrier,ManualBarrier.keyPressed,false,true,false,true)
    if arg then
		ManualBarrier.keyId = eventName
		g_inputBinding.events[eventName].displayIsVisible = false
	end
end
function ManualBarrier:keyEvent(unicode, sym, modifier, isDown) end
function ManualBarrier:mouseEvent(posX, posY, isDown, isUp, button) end
function ManualBarrier:updateKey()
	if ManualBarrier.keyId ~= nil then
		local sName = ""
		local sOption = ""
		local keysActive = false
		for k,v in pairs(g_currentMission.manualBarrierTriggers) do
			if v.keysActive then
				keysActive = true
				sName = v.stringName
				sOption = v.stringOption
			end
		end
		if keysActive then
			g_inputBinding:setActionEventText(ManualBarrier.keyId, g_i18n:getText(sName).." "..g_i18n:getText(sOption))
			g_inputBinding.events[ManualBarrier.keyId].displayPriority = 1
		end
		g_inputBinding:setActionEventActive(ManualBarrier.keyId, keysActive)
		g_inputBinding:setActionEventTextVisibility(ManualBarrier.keyId, keysActive)
	end
end
function ManualBarrier:keyPressed(actionName, keyStatus, arg4, arg5, arg6)
    for k,v in pairs(g_currentMission.manualBarrierTriggers) do
		if v.keysActive then
			if v.openState == 0 then
				v:setOpenState(2, v.randomActive, v.randomStart, v.randomEnd, v.randomActiveText)
			else
				v:setOpenState(0, v.randomActive, v.randomStart, v.randomEnd, v.randomActiveText)
			end
		end
	end
end
function ManualBarrier:update(dt)
	ManualBarrier:superClass().update(self, dt)
	self.debugA = self.debugA + 1
	local showCloseSymbol = false
	if not self.triggerIsAdded then
		if g_currentMission.manualBarrierTriggers == nil then
			g_currentMission.manualBarrierTriggers = {}
		end
		if g_currentMission.manualBarrierTriggers[self.manualBarrierId] ~= nil then
			print(" Error: Manual barrier with ID "..tostring(self.manualBarrierId).." already registered, entry will be overwriten")
		end
		g_currentMission.manualBarrierTriggers[self.manualBarrierId] = self
		self.triggerIsAdded = true
	end

	local ctime = math.floor(g_currentMission.environment.dayTime / 3600) / 1000
	local ctimeHour = math.floor(ctime)
	local changeStatusLights = false

	if self.halfAutomatic and self.manualOpen then
		for k,_ in pairs(self.automaticOpen) do
			if (ctime < self.automaticOpen[k]) or (ctime > self.automaticClose[k]) then
				if not self.automaticStrict then
					if not self.playerInTrigger then
						if self.openState == 2 then
							self:setOpenState(0, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText)
						end
					end
				else
					self.playerInTrigger = false
					if self.openState == 2 then
						self:setOpenState(0, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText)
					end
				end
			end
		end
	end
	if self.automaticMode then
		if not self.randomRun then
			if self.farmLandRestricted and self:getFieldOwnership() then
				self.count = 1
			end
			if not self.automaticStrict then
				self.count = 1
			end
			local closeCount = 0
			for k,_ in pairs(self.automaticOpen) do
				if self.automaticClose[k] > self.automaticOpen[k] and (ctime > self.automaticClose[k] or ctime < self.automaticOpen[k]) then
					closeCount = closeCount + 1
				elseif self.automaticClose[k] < self.automaticOpen[k] and (ctime > self.automaticClose[k] and ctime < self.automaticOpen[k]) then
					closeCount = closeCount + 1
				end
			end
			if closeCount == #self.automaticOpen then
				self.count = 0
				showCloseSymbol = true
			end
		end
	end

	if self.manualOpen == true and self.isClient then
		if self.playerInTrigger == true and (not self.farmLandRestricted or (self.farmLandRestricted and self:getFieldOwnership())) then
			if not self.keysActive then
				self.keysActive = true
				self:updateKey()
			end
		else
			if self.keysActive then
				self.keysActive = false
				self:updateKey()
			end
		end
	elseif self.keysActive then
		self.keysActive = false
		self:updateKey()
	end

	if self.closeIfRaining and self:getRainyWeather() then
		if self.openState > 1 then
			self:setOpenState(0, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText)
		end
	end

	if self.isServer or g_server ~= nil then
		if self.randomClose and self.randomCheckHour ~= ctimeHour then
			self.randomCheckHour = ctimeHour
			if self.randomActive == false then
				local tActive = math.random(1, 100)
				if tActive >= (50 - self.randomChance) and tActive < (50 + self.randomChance) then
					self.randomActive = true
					self.randomStart = math.random(0, 1415)/60
					self.randomEnd = math.random(self.randomStart + 1, self.randomStart + 5)
					if self.randomEnd >= 24 then
						self.randomEnd = self.randomEnd - 24
					end
					local tText = math.random(1, 9)
					if tText >= 1 and tText < 3 then
						self.randomActiveText = self.randomText1
					elseif tText >= 3 and tText < 6 then
						self.randomActiveText = self.randomText2
					else
						self.randomActiveText = self.randomText3
					end
					self:setOpenState(0, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText)
				end
			end
		end
	end
	if self.randomActive then
		local rTime = ctime
		if self.randomEnd >= 24 then
			self.randomEnd = self.randomEnd - 24
		end
		local canEnd = false
		local lastRandomRun = self.randomRun
		if self.randomEnd < self.randomStart then
			if rTime > self.randomEnd and rTime > self.randomStart then
				self.randomRun = true
			elseif rTime < self.randomEnd and rTime < self.randomStart then
				self.randomRun = true
			else
				canEnd = true
			end
		else
			if rTime < self.randomEnd and rTime > self.randomStart then
				self.randomRun = true
			else
				canEnd = true
			end
		end
		if self.randomRun == true then
			if self.randomCMskBckup == 0 then
				self.randomCMskBckup = getCollisionMask(self.triggerId)
				setCollisionMask(self.triggerId,4294967295)
			end
		
			if lastRandomRun ~= self.randomRun then self.count = 0 end
			if self.count > 0 then
				if self.randomActiveText ~= nil and self.randomActiveText ~= "" and self.randomActiveText ~= " " then
					self.count = self.count - 1
					if self.count < 0 then self.count = 0 end
					if self.playerInTrigger then
						local fixTime = self.randomEnd
						if fixTime >= 24 then
							fixTime = fixTime - 24
						end
						local h = math.floor(fixTime)
						local m = math.floor((fixTime - h) * 60)
						local msg = g_i18n:getText(self.randomActiveText).." "..tostring(h)..":"..tostring(m).." "..g_i18n:getText("default_noentry_clock")
						g_currentMission:showBlinkingWarning(msg,5000)
					end
				end
			end
			if canEnd then
				if self.randomCMskBckup > 0 then
					setCollisionMask(self.triggerId,self.randomCMskBckup)
				end
				self.randomRun = false
				self.randomActive = false
				self.randomStart = 0
				self.randomEnd = 0
				self.randomActiveText = " "
			end
		end
	end

	local isWorking = false
	if self.typeBarrier or self.typeGate then
		for i=1, table.getn(self.Barriers) do
			for a=1, 3 do
				local moveSpeedAngle = 0
				local moveSpeedTrans = 0
				local oldAngle = self.Barriers[i][a].angle
				local oldTrans = self.Barriers[i][a].trans
				if (((self.count > 0 and not self.randomRun) and not self.manualOpen) or self.openState > 1) and not (self.closeIfRaining and self:getRainyWeather()) then
					if self.Barriers[i][a].maxAngle < self.Barriers[i][a].minAngle then
						moveSpeedAngle = 0-dt*(self.speedScale/50)
					elseif self.Barriers[i][a].maxAngle > self.Barriers[i][a].minAngle then
						moveSpeedAngle = dt*(self.speedScale/50)
					end
					if self.Barriers[i][a].maxTrans < self.Barriers[i][a].minTrans then
						moveSpeedTrans = 0-dt*(self.speedScale/1500)
					elseif self.Barriers[i][a].maxTrans > self.Barriers[i][a].minTrans then
						moveSpeedTrans = dt*(self.speedScale/1500)
					end
					self.Barriers[i][a].angle = self.Barriers[i][a].angle + moveSpeedAngle
					self.Barriers[i][a].trans = self.Barriers[i][a].trans + moveSpeedTrans
					if moveSpeedAngle > 0 then
						if self.Barriers[i][a].angle > self.Barriers[i][a].maxAngle then self.Barriers[i][a].angle = self.Barriers[i][a].maxAngle end
					elseif moveSpeedAngle < 0 then
						if self.Barriers[i][a].angle < self.Barriers[i][a].maxAngle then self.Barriers[i][a].angle = self.Barriers[i][a].maxAngle end
					end
					if moveSpeedTrans > 0 then
						if self.Barriers[i][a].trans > self.Barriers[i][a].maxTrans then self.Barriers[i][a].trans = self.Barriers[i][a].maxTrans end
					elseif moveSpeedTrans < 0 then
						if self.Barriers[i][a].trans < self.Barriers[i][a].maxTrans then self.Barriers[i][a].trans = self.Barriers[i][a].maxTrans end
					end
				else
					if self.Barriers[i][a].maxAngle > self.Barriers[i][a].minAngle then
						moveSpeedAngle = 0-dt*(self.speedScale/50)
					elseif self.Barriers[i][a].maxAngle < self.Barriers[i][a].minAngle then
						moveSpeedAngle = dt*(self.speedScale/50)
					end
					if self.Barriers[i][a].maxTrans > self.Barriers[i][a].minTrans then
						moveSpeedTrans = 0-dt*(self.speedScale/1500)
					elseif self.Barriers[i][a].maxTrans < self.Barriers[i][a].minTrans then
						moveSpeedTrans = dt*(self.speedScale/1500)
					end
					self.Barriers[i][a].angle = self.Barriers[i][a].angle + moveSpeedAngle
					self.Barriers[i][a].trans = self.Barriers[i][a].trans + moveSpeedTrans
					if moveSpeedAngle > 0 then
						if self.Barriers[i][a].angle > self.Barriers[i][a].minAngle then self.Barriers[i][a].angle = self.Barriers[i][a].minAngle end
					elseif moveSpeedAngle < 0 then
						if self.Barriers[i][a].angle < self.Barriers[i][a].minAngle then self.Barriers[i][a].angle = self.Barriers[i][a].minAngle end
					end
					if moveSpeedTrans > 0 then
						if self.Barriers[i][a].trans > self.Barriers[i][a].minTrans then self.Barriers[i][a].trans = self.Barriers[i][a].minTrans end
					elseif moveSpeedTrans < 0 then
						if self.Barriers[i][a].trans < self.Barriers[i][a].minTrans then self.Barriers[i][a].trans = self.Barriers[i][a].minTrans end
					end
				end
				if oldAngle ~= self.Barriers[i][a].angle or oldTrans ~= self.Barriers[i][a].trans then
					isWorking = true
					setRotation(self.Barriers[i].node, MathUtil.degToRad(self.Barriers[i][1].angle), MathUtil.degToRad(self.Barriers[i][2].angle), MathUtil.degToRad(self.Barriers[i][3].angle))
					setTranslation(self.Barriers[i].node, self.Barriers[i][1].trans, self.Barriers[i][2].trans, self.Barriers[i][3].trans)
				end
			end
			if self.Barriers[i][1].angle == self.Barriers[i][1].maxAngle and self.Barriers[i][2].angle == self.Barriers[i][2].maxAngle and self.Barriers[i][3].angle == self.Barriers[i][3].maxAngle and self.Barriers[i][1].trans == self.Barriers[i][1].maxTrans and self.Barriers[i][2].trans == self.Barriers[i][2].maxTrans and self.Barriers[i][3].trans == self.Barriers[i][3].maxTrans then
				changeStatusLights = true
			end
			if self.Barriers[i][1].angle == self.Barriers[i][1].minAngle and self.Barriers[i][2].angle == self.Barriers[i][2].minAngle and self.Barriers[i][3].angle == self.Barriers[i][3].minAngle and self.Barriers[i][1].trans == self.Barriers[i][1].minTrans and self.Barriers[i][2].trans == self.Barriers[i][2].minTrans and self.Barriers[i][3].trans == self.Barriers[i][3].minTrans then
				changeStatusLights = false
			end
		end
	end

	if self.typeAnimated then
		if self.trackTime < 1 then
			self.trackTime = 0
		end

		if self.trackTime > self.animDuration then
			self.trackTime = self.animDuration
		end
		if self.animDirection > 0 then
			if (((self.count > 0 and not self.randomRun) and not self.manualOpen) or self.openState > 1) and not (self.closeIfRaining and self:getRainyWeather()) then
				if self.trackTime < self.animDuration then
					self.trackTime = self.trackTime + 10 * self.speedScale
				end
			else
				if self.trackTime > 0 then
					self.trackTime = self.trackTime - 10 * self.speedScale
				end
			end
		elseif self.animDirection < 0 then
			if (((self.count > 0 and not self.randomRun) and not self.manualOpen) or self.openState > 1) and not (self.closeIfRaining and self:getRainyWeather()) then
				if self.trackTime > 0 then
					self.trackTime = self.trackTime - 10 * self.speedScale
				end
			else
				if self.trackTime < self.animDuration then
					self.trackTime = self.trackTime + 10 * self.speedScale
				end
			end
		end
		if self.lastTrackTime ~= self.trackTime then
			isWorking = true
			enableAnimTrack(self.animCharSet, self.clip)
			setAnimTrackTime(self.animCharSet, self.clip, self.trackTime, true)
			disableAnimTrack(self.animCharSet, self.clip)
			self.lastTrackTime = self.trackTime
		end
		if self.animDirection > 0 then
			if self.trackTime >= (self.animDuration * 0.8) then
				changeStatusLights = true
			end
			if self.trackTime <= (self.animDuration * 0.8) then
				changeStatusLights = false
			end
		elseif self.animDirection < 0 then
			if self.trackTime <= (self.animDuration * 0.8) then
				changeStatusLights = true
			end
			if self.trackTime >= (self.animDuration * 0.8) then
				changeStatusLights = false
			end
		end
	end
	if self.typeLight then
		local willSet = false
		if (((self.count > 0 and not self.randomRun) and not self.manualOpen) or self.openState > 1) and not (self.closeIfRaining and self:getRainyWeather()) then
			willSet = true
		end
		if self.lightOnlyNight and willSet then
			if g_currentMission.environment ~= nil and not g_currentMission.environment.isSunOn then
				willSet = true
			else
				willSet = false
			end
		end
		if self.lightAutoNight then
			if self.lightAutoNightOn > -1 and self.lightAutoNightOff > -1 then
				if (ctime >= self.lightAutoNightOn or ctime < self.lightAutoNightOff) then
					willSet = true
				else
					willSet = false
				end
			else
				if g_currentMission.environment ~= nil and not g_currentMission.environment.isSunOn then
					willSet = true
				else
					willSet = false
				end
			end
		end
		if willSet then
			if self.flickerMode then
				if self.flickerCounter == 0 or self.flickerCounter == 8 or self.flickerCounter == 14 or self.flickerCounter == 20 or self.flickerCounter >= 31 then
					setVisibility(self.light, true)
				elseif self.flickerCounter == 2 or self.flickerCounter == 10 or self.flickerCounter == 18 or self.flickerCounter == 28 then
					setVisibility(self.light, false)
				end
				if self.flickerCounter < 32 then
					self.flickerCounter = self.flickerCounter + 1
				end
			else
				self.flickerCounter = 0
				if not getVisibility(self.light) then
					setVisibility(self.light,true)
				end
			end
		else
			self.flickerCounter = 0
			if getVisibility(self.light) then
				setVisibility(self.light,false)
			end
		end
	end
	if isWorking then
		if self.typeLight and self.lightOnMove then
			if not getVisibility(self.light) then
				setVisibility(self.light,true)
			end
		end
		if self.audio ~= nil then
			if not getVisibility(self.audio) then
				setVisibility(self.audio, true)
			end
		end
		if self.rotationObject ~= nil then
			if self.rotationObjectAxis == 3 then
				rotate(self.rotationObject,0,0,self.rotationObjectSpeed*dt)
			elseif self.rotationObjectAxis == 2 then
				rotate(self.rotationObject,0,self.rotationObjectSpeed*dt,0)
			elseif self.rotationObjectAxis == 1 then
				rotate(self.rotationObject,self.rotationObjectSpeed*dt,0,0)
			end
		end
	else
		if self.typeLight and self.lightOnMove then
			if getVisibility(self.light) then
				setVisibility(self.light,false)
			end
		end
		local audioStayOn = false
		if self.audioLoopOnOpen and ((((self.count > 0 and not self.randomRun) and not self.manualOpen) or self.openState > 1) and not (self.closeIfRaining and self:getRainyWeather())) then
			audioStayOn = true
		end
		if self.audioLoopOnClose and (self.count == 0 or self.openState < 1 or (self.closeIfRaining and self:getRainyWeather())) then
			audioStayOn = true
		end
		if self.audio ~= nil and not audioStayOn then
			if getVisibility(self.audio) then
				setVisibility(self.audio, false)
			end
		end
	end
	if self.randomRun then
		if self.randomLight then
			if self.typeLight then
				if not getVisibility(self.light) then
					setVisibility(self.light,true)
				end
			end
		end
		if self.randomRotate then
			if self.rotationObject ~= nil then
				if self.rotationObjectAxis == 3 then
					rotate(self.rotationObject,0,0,self.rotationObjectSpeed*dt)
				elseif self.rotationObjectAxis == 2 then
					rotate(self.rotationObject,0,self.rotationObjectSpeed*dt,0)
				elseif self.rotationObjectAxis == 1 then
					rotate(self.rotationObject,self.rotationObjectSpeed*dt,0,0)
				end
			end
		end
	end
	
	if self.lightGreen ~= nil then
		setVisibility(self.lightGreen,changeStatusLights)
	end
	if self.lightRed ~= nil then
		setVisibility(self.lightRed,not changeStatusLights)
	end

	if self.openSymbol ~= nil then
		if (((self.count > 0 and not self.randomRun) and not self.manualOpen) or self.openState > 1) and not (self.closeIfRaining and self:getRainyWeather()) then
			setVisibility(self.openSymbol,true)
		else
			setVisibility(self.openSymbol,false)
		end
	end
	if self.closeSymbol ~= nil then
		if (((self.count > 0 and not self.randomRun) and not self.manualOpen) or self.openState > 1) and not (self.closeIfRaining and self:getRainyWeather()) then
			setVisibility(self.closeSymbol,false)
		else
			if showCloseSymbol then
				setVisibility(self.closeSymbol,true)
			else
				setVisibility(self.closeSymbol,false)
			end
		end
	end
end
function ManualBarrier:getRainyWeather()
	if g_currentMission.environment.weather:getRainFallScale() <= 0.1 and g_currentMission.environment.weather:getTimeSinceLastRain() > 20 then
		if not self.isEnabled then
			self.isEnabled = true
		end
		return false
	end
	if self.isEnabled then
		self.isEnabled = false
	end
	return true
end
function ManualBarrier:updateTick(dt) end
function ManualBarrier:setOpenState(state, rndActive, rndStart, rndEnd, rndText, noEventSend)
	if state ~= nil then
		self.openState = state
		if state == 0 then
			self.stringOption = self.stringOpen
		elseif state == 2 then
			self.stringOption = self.stringClose
		end
		if rndActive ~= nil then
			self.randomActive = rndActive
			self.randomStart = rndStart
			self.randomEnd = rndEnd
			self.randomActiveText = rndText
		end
	end
	if noEventSend == nil or noEventSend == false then
		if g_currentMission:getIsServer() then
			g_server:broadcastEvent(ManualBarrierEvent:new(self, self.manualBarrierId, state, rndActive, rndStart, rndEnd, Utils.getNoNil(rndText," ")), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(ManualBarrierEvent:new(self, self.manualBarrierId, state, rndActive, rndStart, rndEnd, Utils.getNoNil(rndText," ")))
		end
	end
	if self.manualOpen == true and self.isClient then
		if self.keysActive then
			self:updateKey()
		end
	end
	if self.isServer or g_server ~= nil then
		self:raiseDirtyFlags(self.ManualBarrierDirtyFlag)
	end
end
function ManualBarrier:loadFromXMLFile(xmlFile, key)
	self.openState = Utils.getNoNil(getXMLInt(xmlFile, key .. "#openState"),self.openState)
	self.randomActive = Utils.getNoNil(getXMLBool(xmlFile, key .. "#randomActive"),self.randomActive)
	self.randomStart = Utils.getNoNil(getXMLFloat(xmlFile, key .. "#randomStart"),self.randomStart)
	self.randomEnd = Utils.getNoNil(getXMLFloat(xmlFile, key .. "#randomEnd"),self.randomEnd)
	self.randomActiveText = Utils.getNoNil(getXMLString(xmlFile, key .. "#randomActiveText"),self.randomActiveText)
	self:setOpenState(self.openState, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText, true)
	return true
end
function ManualBarrier:saveToXMLFile(xmlFile, key, usedModNames)
	setXMLInt(xmlFile, key.."#openState", self.openState)
	setXMLBool(xmlFile, key.."#randomActive", self.randomActive)
	setXMLFloat(xmlFile, key.."#randomStart", self.randomStart)
	setXMLFloat(xmlFile, key.."#randomEnd", self.randomEnd)
	setXMLString(xmlFile, key.."#randomActiveText", Utils.getNoNil(self.randomActiveText," "))
end
function ManualBarrier:getFieldOwnership()
	if self.farmLandRestricted then
		local x,_,z = getWorldTranslation(self.nodeId)
		local ownerFarmId = g_farmlandManager:getFarmlandIdAtWorldPosition(x, z)
		local farmId = 0
		if ownerFarmId ~= nil then
			farmId = g_farmlandManager:getFarmlandOwner(ownerFarmId)
		end
		if ownerFarmId == nil or g_currentMission.accessHandler:canFarmAccessOtherId(farmId, self.triggerObjectFarmId) then
			return true
		end
	else
		return true
	end
	return false
end
function ManualBarrier:triggerCallback(triggerId, otherId, onEnter, onLeave, onStay, valOpt)
	if g_currentMission ~= nil then
			local pName = nil
			if g_currentMission.player ~= nil then
				pName = g_currentMission.player.visualInformation.playerName
				if self.manualOpen == true or self.randomRun == true then
					if g_currentMission.player.rootNode == otherId then
						self.triggerObjectFarmId = g_currentMission.player.farmId
						if self:getFieldOwnership() then
							if onEnter and self.isEnabled then
								self.playerInTrigger = true
								self.count = self.count + 1
							elseif onLeave then
								self.playerInTrigger = false
								self.count = self.count - 1
								if self.count <= 0 then
									self.count = 0
								end
							end
						end
					end
				end
			end

			local vehicle = g_currentMission.nodeToObject[otherId]
			if vehicle ~= nil then
				self.triggerObjectFarmId = vehicle.ownerFarmId
				if self:getFieldOwnership() then
					if onEnter and self.isEnabled then
						self.count = self.count + 1
						if vehicle.getIsControlled ~= nil and vehicle:getIsControlled() ~= nil and pName ~= nil and pName == vehicle:getControllerName() then
							self.playerInTrigger = true
						end
					elseif onLeave then
						self.count = self.count - 1
						if vehicle.getIsControlled ~= nil and vehicle:getIsControlled() ~= nil and pName ~= nil and pName == vehicle:getControllerName() then
							self.playerInTrigger = false
						end
						if self.count <= 0 then
							self.count = 0
						end
					end
				end
			else
				if self.allowTraffic then
					if onEnter and self.isEnabled then
						self.count = self.count + 1
					elseif onLeave then
						self.count = self.count - 1
						if self.count < 0 then
							self.count = 0
						end
					end
				end
			end
		--end
	end
end
g_onCreateUtil.addOnCreateFunction("ManualBarrier", ManualBarrier.onCreate)

ManualBarrierEvent={}
ManualBarrierEvent_mt=Class(ManualBarrierEvent,Event)
InitEventClass(ManualBarrierEvent,"ManualBarrierEvent")
function ManualBarrierEvent:emptyNew()
	local self = Event:new(ManualBarrierEvent_mt)
	return self
end
function ManualBarrierEvent:new(barrier, manualBarrierId, state, randomActive, randomStart, randomEnd, randomActiveText)
	local self = ManualBarrierEvent:emptyNew()
	self.barrier = barrier
	self.manualBarrierId = manualBarrierId
	self.state = state
	self.randomActive = randomActive
	self.randomStart = randomStart
	self.randomEnd = randomEnd
	self.randomActiveText = randomActiveText
	return self
end
function ManualBarrierEvent:readStream(streamId, connection)
	self.barrier = NetworkUtil.readNodeObject(streamId)
	self.manualBarrierId = streamReadInt32(streamId)
	self.state = streamReadInt8(streamId)
	self.randomActive = streamReadBool(streamId)
	self.randomStart = streamReadFloat32(streamId)
	self.randomEnd = streamReadFloat32(streamId)
	self.randomActiveText = streamReadString(streamId)
	self:run(connection)
end
function ManualBarrierEvent:writeStream(streamId, connection)
	NetworkUtil.writeNodeObject(streamId,self.barrier)
	streamWriteInt32(streamId, self.manualBarrierId)
	streamWriteInt8(streamId, self.state)
	streamWriteBool(streamId, self.randomActive)
	streamWriteFloat32(streamId, self.randomStart)
	streamWriteFloat32(streamId, self.randomEnd)
	streamWriteString(streamId, Utils.getNoNil(self.randomActiveText," "))
	end function ManualBarrierEvent:run(connection)
	if g_currentMission.manualBarrierTriggers ~= nil and g_currentMission.manualBarrierTriggers[self.manualBarrierId] ~= nil then
		g_currentMission.manualBarrierTriggers[self.manualBarrierId]:setOpenState(self.state, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText,true)
	end
	if self.barrier ~= nil then
		self.barrier:setOpenState(self.state, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText,true)
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(ManualBarrierEvent:new(self.barrier, self.manualBarrierId, self.state, self.randomActive, self.randomStart, self.randomEnd, self.randomActiveText), nil, connection, self.barrier)
	end
end

print(" ++ loading ManualBarrier V "..tostring(ManualBarrier.version).." - "..tostring(ManualBarrier.date).." (by Blacky_BPG)")
