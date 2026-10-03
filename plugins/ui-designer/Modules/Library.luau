return function(R)
	local plugin = R.plugin
	local A = R.A
	local ATTRIBUTE_NAME = R.ATTRIBUTE_NAME
	local Animation = R.Animation
	local BRAND = R.BRAND
	local Btn = R.Btn
	local C = R.C
	local ChangeHistoryService = R.ChangeHistoryService
	local DATA_VERSION = R.DATA_VERSION
	local DEFAULT_DIRECTION = R.DEFAULT_DIRECTION
	local DEFAULT_STYLE = R.DEFAULT_STYLE
	local DIRECTIONS = R.DIRECTIONS
	local EFFECTS_ICON = R.EFFECTS_ICON
	local EV = R.EV
	local EVENT_LANE_Y = R.EVENT_LANE_Y
	local HttpService = R.HttpService
	local ID_ATTRIBUTE = R.ID_ATTRIBUTE
	local INTEGER_PROPS = R.INTEGER_PROPS
	local Insp = R.Insp
	local KEY_LANE_Y = R.KEY_LANE_Y
	local LANES_H = R.LANES_H
	local LEFT_PAD = R.LEFT_PAD
	local LEGACY_ID_ATTRIBUTE = R.LEGACY_ID_ATTRIBUTE
	local LIBRARY_ATTRIBUTE = R.LIBRARY_ATTRIBUTE
	local LIBRARY_DATA_ATTRIBUTE = R.LIBRARY_DATA_ATTRIBUTE
	local LIBRARY_FOLDER = R.LIBRARY_FOLDER
	local LOGO_IMAGE = R.LOGO_IMAGE
	local Library = R.Library
	local MAX_ANIMATION_TIME = R.MAX_ANIMATION_TIME
	local MAX_EVENT_PARAMS = R.MAX_EVENT_PARAMS
	local MAX_IMPORT_EVENTS = R.MAX_IMPORT_EVENTS
	local MAX_IMPORT_KEYFRAMES = R.MAX_IMPORT_KEYFRAMES
	local MENU_SEPARATOR = R.MENU_SEPARATOR
	local MIN_ZOOM = R.MIN_ZOOM
	local PREFIX = R.PREFIX
	local PROPERTY_CATALOG = R.PROPERTY_CATALOG
	local RULER_H = R.RULER_H
	local ReplicatedStorage = R.ReplicatedStorage
	local RunService = R.RunService
	local SNAP_STEPS = R.SNAP_STEPS
	local SPEEDS = R.SPEEDS
	local STYLES = R.STYLES
	local Selection = R.Selection
	local StarterGui = R.StarterGui
	local State = R.State
	local TweenService = R.TweenService
	local UserInputService = R.UserInputService
	local afterEdit = R.afterEdit
	local ancestryConnection = R.ancestryConnection
	local anchorBelow = R.anchorBelow
	local anchorFromInput = R.anchorFromInput
	local applied = R.applied
	local applyAt = R.applyAt
	local applyingProperties = R.applyingProperties
	local baseline = R.baseline
	local buildAnimationData = R.buildAnimationData
	local buildModuleSource = R.buildModuleSource
	local captureProperties = R.captureProperties
	local cloneEvents = R.cloneEvents
	local corner = R.corner
	local countEvents = R.countEvents
	local create = R.create
	local cycleNumber = R.cycleNumber
	local decodeKeyframes = R.decodeKeyframes
	local decodeValue = R.decodeValue
	local directionMenuItems = R.directionMenuItems
	local disconnectTarget = R.disconnectTarget
	local drag = R.drag
	local encodeKeyframes = R.encodeKeyframes
	local ensureId = R.ensureId
	local evaluateProperty = R.evaluateProperty
	local fireEvents = R.fireEvents
	local fmtTime = R.fmtTime
	local formatParams = R.formatParams
	local formatValue = R.formatValue
	local getDuration = R.getDuration
	local getLibraryFolder = R.getLibraryFolder
	local hasProperty = R.hasProperty
	local isFiniteNumber = R.isFiniteNumber
	local isFiniteValue = R.isFiniteValue
	local keyframeAt = R.keyframeAt
	local lastUndoKey = R.lastUndoKey
	local linkTarget = R.linkTarget
	local loadFromTarget = R.loadFromTarget
	local mainBg = R.mainBg
	local makeKeyframe = R.makeKeyframe
	local menuItem = R.menuItem
	local mouseToTime = R.mouseToTime
	local notify = R.notify
	local num = R.num
	local orderer = R.orderer
	local padding = R.padding
	local parseParams = R.parseParams
	local parseValue = R.parseValue
	local pendingEventFocus = R.pendingEventFocus
	local playConnection = R.playConnection
	local playhead = R.playhead
	local pluginGui = R.pluginGui
	local presetMenuItems = R.presetMenuItems
	local propertyButtons = R.propertyButtons
	local propertyConnections = R.propertyConnections
	local pushUndo = R.pushUndo
	local restoreBaseline = R.restoreBaseline
	local roundTo = R.roundTo
	local sanitizeEventName = R.sanitizeEventName
	local saveToTarget = R.saveToTarget
	local scroll = R.scroll
	local serializeValue = R.serializeValue
	local setHint = R.setHint
	local setSnap = R.setSnap
	local setZoom = R.setZoom
	local side = R.side
	local sideOrder = R.sideOrder
	local snapTime = R.snapTime
	local snapshotBaseline = R.snapshotBaseline
	local snapshotState = R.snapshotState
	local sortKeyframes = R.sortKeyframes
	local statusLabel = R.statusLabel
	local stopPlayback = R.stopPlayback
	local styleButton = R.styleButton
	local styleMenuItems = R.styleMenuItems
	local tip = R.tip
	local trim = R.trim
	local unlinkTarget = R.unlinkTarget
	local valueRows = R.valueRows

	function Library.cleanName(name)
		if type(name) ~= "string" then
			return nil
		end
		name = name:gsub("%c", " ")
		name = name:gsub("^%s+", "")
		name = name:gsub("%s+$", "")
		name = name:sub(1, 60)
		if name == "" then
			return nil
		end
		return name
	end
	
	function Library.find(name)
		local folder = getLibraryFolder(false)
		if not folder then
			return nil
		end
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("ModuleScript") and child:GetAttribute(LIBRARY_ATTRIBUTE) == name then
				return child
			end
		end
		return nil
	end
	
	function Library.list()
		local result = {}
		local folder = getLibraryFolder(false)
		if folder then
			for _, child in ipairs(folder:GetChildren()) do
				local name = child:IsA("ModuleScript") and child:GetAttribute(LIBRARY_ATTRIBUTE)
				if type(name) == "string" then
					table.insert(result, {
						name = name,
						module = child,
						keyframes = tonumber(child:GetAttribute("SynapseUiKeyframes")) or 0,
						events = tonumber(child:GetAttribute("SynapseUiEvents")) or 0,
						duration = tonumber(child:GetAttribute("SynapseUiDuration")) or 0,
						target = tostring(child:GetAttribute("SynapseUiTarget") or "?"),
					})
				end
			end
		end
		table.sort(result, function(a, b)
			return a.name:lower() < b.name:lower()
		end)
		return result
	end
	
	function Library.read(name)
		local module = Library.find(name)
		if not module then
			return nil, "Animation not found: " .. tostring(name)
		end
	
		local raw = module:GetAttribute(LIBRARY_DATA_ATTRIBUTE)
		if type(raw) ~= "string" then
			local _, legacyBody = module.Source:match("Animation%.Data = %[(=*)%[(.-)%]%1%]")
			raw = legacyBody
		end
		if type(raw) ~= "string" then
			return nil, "This module has no stored animation data."
		end
	
		local ok, data = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not ok or type(data) ~= "table" then
			return nil, "The saved data is corrupted."
		end
		return data
	end
	
	function Library.save(name, overwrite)
		name = Library.cleanName(name)
		if not name then
			return false, "Type a name for the animation."
		end
		if not State.target or not State.target.Parent then
			return false, "Link a UI first."
		end
		if #State.keyframes == 0 then
			return false, "There are no keyframes to save."
		end
	
		local existing = Library.find(name)
		if existing and not overwrite then
			return false, 'An animation named "' .. name .. '" already exists.'
		end
	
		local source = buildModuleSource(name)
		if not source then
			return false, "There is no valid animation to save."
		end
	
		local module = existing or Instance.new("ModuleScript")
		module.Name = name
		module.Source = source
		module:SetAttribute(LIBRARY_ATTRIBUTE, name)
		module:SetAttribute(LIBRARY_DATA_ATTRIBUTE, HttpService:JSONEncode(buildAnimationData(name)))
		module:SetAttribute(ID_ATTRIBUTE, ensureId(State.target))
		module:SetAttribute("SynapseUiKeyframes", #State.keyframes)
		module:SetAttribute("SynapseUiEvents", countEvents())
		module:SetAttribute("SynapseUiDuration", getDuration())
		module:SetAttribute("SynapseUiTarget", State.target.Name)
		module.Parent = getLibraryFolder(true)
	
		ChangeHistoryService:SetWaypoint("Save UI Animation: " .. name)
		return true, module, existing ~= nil
	end
	
	function Library.delete(name)
		local module = Library.find(name)
		if not module then
			return false, "Animation not found."
		end
		module:Destroy()
		ChangeHistoryService:SetWaypoint("Delete UI Animation: " .. name)
		return true
	end
	
	function Library.exportJson(name)
		local data, err = Library.read(name)
		if not data then
			return nil, err
		end
		return HttpService:JSONEncode(data)
	end
	
	local function validateImportData(data, target)
		if type(data) ~= "table" or type(data.keyframes) ~= "table" then
			return false, "Invalid animation data."
		end
		if #data.keyframes == 0 then
			return false, "That animation has no keyframes."
		end
		if #data.keyframes > MAX_IMPORT_KEYFRAMES then
			return false, "The animation exceeds the 1,000 keyframe limit."
		end
		if data.loop ~= nil and type(data.loop) ~= "boolean" then
			return false, "The animation loop setting is invalid."
		end
	
		local times = {}
		local eventCount = 0
		for _, item in ipairs(data.keyframes) do
			if type(item) ~= "table" then
				return false, "The animation contains an invalid keyframe."
			end
			local time = tonumber(item.time)
			if not isFiniteNumber(time) or time < 0 or time > MAX_ANIMATION_TIME then
				return false, "Keyframe times must be between 0 and 3,600 seconds."
			end
			for _, previous in ipairs(times) do
				if math.abs(previous - time) < 0.001 then
					return false, "The animation contains keyframes at duplicate times."
				end
			end
			table.insert(times, time)
	
			if item.props ~= nil and type(item.props) ~= "table" then
				return false, "A keyframe has invalid property data."
			end
			for property, encoded in pairs(item.props or {}) do
				if type(property) ~= "string" or type(encoded) ~= "table" then
					return false, "A keyframe has invalid property data."
				end
				local ok, value = pcall(decodeValue, encoded)
				if not ok or value == nil or not isFiniteValue(value) then
					return false, "A keyframe contains an invalid property value."
				end
				if
					table.find(PROPERTY_CATALOG, property)
					and hasProperty(target, property)
					and typeof(value) ~= typeof(target[property])
				then
					return false, 'The value type for "' .. property .. '" does not match the linked object.'
				end
			end
	
			if item.events ~= nil and type(item.events) ~= "table" then
				return false, "A keyframe has invalid event data."
			end
			for _, event in ipairs(item.events or {}) do
				eventCount += 1
				if eventCount > MAX_IMPORT_EVENTS then
					return false, "The animation exceeds the 1,000 event limit."
				end
				if type(event) ~= "table" or not sanitizeEventName(event.name) then
					return false, "The animation contains an invalid event name."
				end
				if event.enabled ~= nil and type(event.enabled) ~= "boolean" then
					return false, "An event has an invalid enabled flag."
				end
				if event.params ~= nil and type(event.params) ~= "table" then
					return false, "An event contains invalid parameters."
				end
				local paramCount = 0
				for key, encoded in pairs(event.params or {}) do
					paramCount += 1
					if paramCount > MAX_EVENT_PARAMS then
						return false, "An event exceeds the 24 parameter limit."
					end
					if type(key) ~= "string" or not key:match("^[%a_][%w_]*$") or type(encoded) ~= "table" then
						return false, "An event contains invalid parameters."
					end
					local ok, value = pcall(decodeValue, encoded)
					if not ok or value == nil or not isFiniteValue(value) then
						return false, "An event contains an invalid parameter value."
					end
				end
			end
		end
		return true
	end
	
	function Library.apply(data, mode)
		local target = State.target
		if not target or not target.Parent then
			return false, "Link a UI first."
		end
		if mode ~= "replace" and mode ~= "append" then
			return false, "Invalid import mode."
		end
	
		local valid, validationError = validateImportData(data, target)
		if not valid then
			return false, validationError
		end
	
		local imported = decodeKeyframes(data.keyframes)
		if #imported == 0 then
			return false, "That animation has no keyframes."
		end
		if mode == "append" then
			for _, keyframe in ipairs(imported) do
				if keyframe.Time + State.time > MAX_ANIMATION_TIME then
					return false, "Appending would place a keyframe beyond 3,600 seconds."
				end
			end
		end
	
		local skipped = {}
		for _, keyframe in ipairs(imported) do
			for property in pairs(keyframe.Properties) do
				if not table.find(PROPERTY_CATALOG, property) or not hasProperty(target, property) then
					keyframe.Properties[property] = nil
					skipped[property] = true
				end
			end
		end
	
		stopPlayback()
		pushUndo()
	
		local eventCount = 0
		for _, keyframe in ipairs(imported) do
			eventCount += #keyframe.Events
		end
		local firstTime = imported[1].Time
	
		if mode == "append" then
			local offset = State.time
			for _, keyframe in ipairs(imported) do
				keyframe.Time += offset
				local existing = keyframeAt(keyframe.Time)
				if existing then
					for property, value in pairs(keyframe.Properties) do
						existing.Properties[property] = value
					end
					for _, event in ipairs(keyframe.Events) do
						table.insert(existing.Events, event)
					end
				else
					table.insert(State.keyframes, keyframe)
				end
			end
			sortKeyframes()
			firstTime += offset
		else
			State.keyframes = imported
			State.time = 0
			if type(data.loop) == "boolean" then
				State.loop = data.loop
				A.updateToggleButtons()
			end
		end
	
		for _, keyframe in ipairs(State.keyframes) do
			for property in pairs(keyframe.Properties) do
				State.enabledProps[property] = true
			end
		end
	
		State.selected = keyframeAt(firstTime) or State.keyframes[1]
		State.selectedEvent = nil
	
		A.refreshProperties()
		A.refreshInspector()
		A.rebuildTimeline()
		A.setTime(State.time)
		A.updateStatus()
		A.scheduleSave()
	
		local skippedList = {}
		for property in pairs(skipped) do
			table.insert(skippedList, property)
		end
		table.sort(skippedList)
	
		local message = string.format(
			"Imported %d keyframe(s) and %d event(s) (%s).",
			#imported,
			eventCount,
			mode == "append" and "added at the playhead" or "timeline replaced"
		)
		if #skippedList > 0 then
			message ..= " Skipped (not available on this object): " .. table.concat(skippedList, ", ")
		end
		return true, message
	end
	
	function Library.import(name, mode)
		local data, err = Library.read(name)
		if not data then
			return false, err
		end
		return Library.apply(data, mode)
	end
	
	function Library.importJson(json, mode)
		local ok, data = pcall(function()
			return HttpService:JSONDecode(json)
		end)
		if not ok or type(data) ~= "table" then
			return false, "Invalid JSON."
		end
		return Library.apply(data, mode)
	end
	
	local Windows = {}
	

	R.Windows = Windows

end
