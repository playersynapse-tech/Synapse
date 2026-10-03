return function(R)
	local plugin = R.plugin
	local A = R.A
	local ATTRIBUTE_NAME = R.ATTRIBUTE_NAME
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
	local ancestryConnection = R.ancestryConnection
	local anchorBelow = R.anchorBelow
	local anchorFromInput = R.anchorFromInput
	local applied = R.applied
	local applyAt = R.applyAt
	local applyingProperties = R.applyingProperties
	local baseline = R.baseline
	local captureProperties = R.captureProperties
	local cloneEvents = R.cloneEvents
	local corner = R.corner
	local countEvents = R.countEvents
	local create = R.create
	local cycleNumber = R.cycleNumber
	local decodeKeyframes = R.decodeKeyframes
	local decodeValue = R.decodeValue
	local drag = R.drag
	local encodeKeyframes = R.encodeKeyframes
	local evaluateProperty = R.evaluateProperty
	local fmtTime = R.fmtTime
	local formatParams = R.formatParams
	local formatValue = R.formatValue
	local getDuration = R.getDuration
	local hasProperty = R.hasProperty
	local isFiniteNumber = R.isFiniteNumber
	local isFiniteValue = R.isFiniteValue
	local keyframeAt = R.keyframeAt
	local lastUndoKey = R.lastUndoKey
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
	local side = R.side
	local sideOrder = R.sideOrder
	local snapTime = R.snapTime
	local snapshotBaseline = R.snapshotBaseline
	local snapshotState = R.snapshotState
	local sortKeyframes = R.sortKeyframes
	local statusLabel = R.statusLabel
	local styleButton = R.styleButton
	local tip = R.tip
	local trim = R.trim
	local valueRows = R.valueRows

	local function newKeyframe(time, properties)
		local reference = State.selected
		local keyframe = makeKeyframe(
			time,
			properties,
			reference and reference.Style or nil,
			reference and reference.Direction or nil
		)
		table.insert(State.keyframes, keyframe)
		sortKeyframes()
		return keyframe
	end
	
	local function ensureBaseKeyframe()
		if keyframeAt(0) then
			return keyframeAt(0)
		end
	
		local base = {}
		for property, value in pairs(baseline) do
			if State.enabledProps[property] then
				base[property] = value
			end
		end
		return newKeyframe(0, base)
	end
	
	local function afterEdit()
		A.refreshInspector()
		A.rebuildTimeline()
		A.updateStatus()
		A.scheduleSave()
	end
	
	function A.setTime(time)
		if not isFiniteNumber(time) then
			return
		end
		State.time = math.clamp(time, 0, MAX_ANIMATION_TIME)
		applyAt(State.time)
		A.updatePlayhead()
		A.updateStatus()
		A.refreshValues()
	end
	
	local function stopPlayback()
		if playConnection then
			playConnection:Disconnect()
			playConnection = nil
		end
		State.playing = false
		A.updatePlayButton()
		A.updateStatus()
	end
	A.stopPlayback = stopPlayback
	
	function A.goToStart()
		stopPlayback()
		A.setTime(0)
	end
	
	function A.goToEnd()
		stopPlayback()
		A.setTime(getDuration())
	end
	
	function A.recordKeyframe()
		if not State.target then
			notify("Link a UI first.", "error")
			return
		end
		if State.time > MAX_ANIMATION_TIME then
			notify("Keyframes must be placed within 3,600 seconds.", "error")
			return
		end
	
		pushUndo()
		ensureBaseKeyframe()
	
		local properties = captureProperties()
		local keyframe = keyframeAt(State.time)
	
		if keyframe then
			for property, value in pairs(properties) do
				keyframe.Properties[property] = value
			end
		else
			keyframe = newKeyframe(State.time, properties)
		end
	
		State.selected = keyframe
		State.selectedEvent = nil
		afterEdit()
	end
	
	function A.deleteKeyframe(keyframe)
		keyframe = keyframe or State.selected
		if not keyframe then
			return
		end
		local index = table.find(State.keyframes, keyframe)
		if not index then
			return
		end
	
		pushUndo()
		table.remove(State.keyframes, index)
		State.selectedEvent = nil
		State.selected = State.keyframes[math.clamp(index, 1, math.max(#State.keyframes, 1))]
	
		if #State.keyframes == 0 then
			restoreBaseline()
		end
		A.setTime(State.time)
		afterEdit()
	end
	
	function A.duplicateKeyframe(keyframe)
		local reference = keyframe or State.selected
		if not reference then
			return
		end
	
		local time = reference.Time + 0.5
		while keyframeAt(time) and time <= MAX_ANIMATION_TIME do
			time += 0.5
		end
		if time > MAX_ANIMATION_TIME then
			notify("There is no room to duplicate this keyframe within 3,600 seconds.", "error")
			return
		end
	
		pushUndo()
	
		local copy = makeKeyframe(
			time,
			table.clone(reference.Properties),
			reference.Style,
			reference.Direction,
			cloneEvents(reference.Events)
		)
		table.insert(State.keyframes, copy)
		sortKeyframes()
		State.selected = copy
		State.selectedEvent = nil
	
		A.setTime(copy.Time)
		afterEdit()
	end
	
	function A.copyKeyframe(keyframe)
		keyframe = keyframe or State.selected
		if not keyframe then
			return
		end
		State.clipboard = encodeKeyframes({ keyframe })[1]
		notify("Keyframe copied. Use Paste (Ctrl+V or the context menu).", "ok")
	end
	
	function A.cutKeyframe(keyframe)
		keyframe = keyframe or State.selected
		if not keyframe then
			return
		end
		State.clipboard = encodeKeyframes({ keyframe })[1]
		A.deleteKeyframe(keyframe)
		notify("Keyframe cut.", "ok")
	end
	
	function A.pasteKeyframe(time)
		if not State.clipboard then
			notify("Nothing to paste. Copy a keyframe first.", "error")
			return
		end
		if not State.target then
			notify("Link a UI first.", "error")
			return
		end
		if not isFiniteNumber(time) or time < 0 or time > MAX_ANIMATION_TIME then
			notify("Paste time must be between 0 and 3,600 seconds.", "error")
			return
		end
	
		local copy = decodeKeyframes({ State.clipboard })[1]
		if not copy then
			return
		end
	
		for property in pairs(copy.Properties) do
			if not hasProperty(State.target, property) then
				copy.Properties[property] = nil
			end
		end
	
		pushUndo()
		copy.Time = time
	
		local existing = keyframeAt(time)
		if existing then
			for property, value in pairs(copy.Properties) do
				existing.Properties[property] = value
			end
			for _, event in ipairs(copy.Events) do
				table.insert(existing.Events, event)
			end
			copy = existing
		else
			table.insert(State.keyframes, copy)
			sortKeyframes()
		end
	
		for property in pairs(copy.Properties) do
			State.enabledProps[property] = true
		end
	
		State.selected = copy
		State.selectedEvent = nil
		A.refreshProperties()
		A.setTime(time)
		afterEdit()
	end
	
	function A.moveKeyframeToPlayhead(keyframe)
		if not keyframe or not table.find(State.keyframes, keyframe) then
			return
		end
	
		local time = snapTime(State.time)
		local clash = keyframeAt(time)
		if clash and clash ~= keyframe then
			notify("There is already a keyframe at the playhead.", "error")
			return
		end
		if math.abs(keyframe.Time - time) < 0.0001 then
			return
		end
	
		pushUndo()
		keyframe.Time = time
		State.selected = keyframe
		sortKeyframes()
		A.setTime(time)
		afterEdit()
		notify("Keyframe moved to playhead.", "ok")
	end
	
	function A.setKeyEasing(keyframe, style, direction)
		if not keyframe or not table.find(State.keyframes, keyframe) then
			return
		end
		if (not style or style == keyframe.Style) and (not direction or direction == keyframe.Direction) then
			return
		end
	
		pushUndo()
		if style then
			keyframe.Style = style
		end
		if direction then
			keyframe.Direction = direction
		end
		State.selected = keyframe
		A.setTime(State.time)
		A.refreshInspector()
		A.rebuildTimeline()
		A.updateStatus()
		A.scheduleSave()
		notify("Easing updated: " .. keyframe.Style.Name .. " / " .. keyframe.Direction.Name, "ok")
	end
	
	function A.applyEasingToAll(reference)
		if not reference or not table.find(State.keyframes, reference) then
			return
		end
		pushUndo()
		for _, keyframe in ipairs(State.keyframes) do
			keyframe.Style = reference.Style
			keyframe.Direction = reference.Direction
		end
		A.setTime(State.time)
		A.refreshInspector()
		A.rebuildTimeline()
		A.scheduleSave()
		notify("Easing applied to every keyframe.", "ok")
	end
	
	function A.addEvent(keyframe, preset)
		if not State.target then
			notify("Link a UI first.", "error")
			return
		end
		if countEvents() >= MAX_IMPORT_EVENTS then
			notify("An animation can hold at most 1,000 events.", "error")
			return
		end
		if State.playing then
			stopPlayback()
		end
	
		keyframe = keyframe or keyframeAt(State.time)
		pushUndo()
		if not keyframe then
			keyframe = newKeyframe(State.time, {})
		end
	
		table.insert(keyframe.Events, EV.new(preset and preset.name, preset and preset.params))
		local index = #keyframe.Events
	
		State.selected = keyframe
		State.selectedEvent = index
		if not preset then
			pendingEventFocus = index
		end
		A.setTime(keyframe.Time)
		afterEdit()
	end
	
	function A.addEventAt(time, preset)
		if not State.target then
			notify("Link a UI first.", "error")
			return
		end
	
		time = snapTime(time)
		if time > MAX_ANIMATION_TIME then
			notify("Events must be placed within 3,600 seconds.", "error")
			return
		end
		if State.playing then
			stopPlayback()
		end
	
		A.setTime(time)
		A.addEvent(keyframeAt(time), preset)
	end
	
	function A.deleteEvent(keyframe, index)
		if not keyframe or not keyframe.Events[index] then
			return
		end
		pushUndo()
		table.remove(keyframe.Events, index)
		State.selectedEvent = nil
		afterEdit()
	end
	
	function A.clearEvents(keyframe)
		if not keyframe or #keyframe.Events == 0 then
			return
		end
		pushUndo()
		keyframe.Events = {}
		State.selectedEvent = nil
		afterEdit()
	end
	
	function A.setEventEnabled(keyframe, index, enabled)
		local event = keyframe and keyframe.Events[index]
		if not event then
			return
		end
		pushUndo()
		event.Enabled = enabled
		State.selected = keyframe
		State.selectedEvent = index
		afterEdit()
		notify(event.Name .. (enabled and " enabled." or " muted (skipped in preview and export)."), "ok")
	end
	
	function A.renameEvent(keyframe, index, name)
		local event = keyframe and keyframe.Events[index]
		name = sanitizeEventName(name)
		if not event or not name or name == event.Name then
			return
		end
		pushUndo()
		event.Name = name
		State.selected = keyframe
		State.selectedEvent = index
		afterEdit()
	end
	
	function A.applyPreset(keyframe, index, preset)
		local event = keyframe and keyframe.Events[index]
		if not event or not preset then
			return
		end
		pushUndo()
		event.Name = preset.name
		event.Params = table.clone(preset.params)
		State.selected = keyframe
		State.selectedEvent = index
		afterEdit()
		notify("Preset applied: " .. preset.name, "ok")
	end
	
	function A.clearParams(keyframe, index)
		local event = keyframe and keyframe.Events[index]
		if not event or next(event.Params) == nil then
			return
		end
		pushUndo()
		event.Params = {}
		State.selected = keyframe
		State.selectedEvent = index
		afterEdit()
	end
	
	function A.duplicateEvent(keyframe, index)
		local event = keyframe and keyframe.Events[index]
		if not event then
			return
		end
		if countEvents() >= MAX_IMPORT_EVENTS then
			notify("An animation can hold at most 1,000 events.", "error")
			return
		end
		pushUndo()
		table.insert(keyframe.Events, index + 1, EV.new(event.Name, event.Params, event.Enabled))
		State.selected = keyframe
		State.selectedEvent = index + 1
		afterEdit()
	end
	
	function A.moveEvent(keyframe, index, delta)
		local target = index + delta
		if not keyframe or not keyframe.Events[index] or not keyframe.Events[target] then
			return
		end
		pushUndo()
		keyframe.Events[index], keyframe.Events[target] = keyframe.Events[target], keyframe.Events[index]
		State.selected = keyframe
		State.selectedEvent = target
		afterEdit()
	end
	
	function A.copyEvent(keyframe, index)
		local event = keyframe and keyframe.Events[index]
		if not event then
			return
		end
		State.eventClipboard = EV.new(event.Name, event.Params, event.Enabled)
		notify('Event "' .. event.Name .. '" copied. Use "Paste event here" in a keyframe or event menu.', "ok")
	end
	
	function A.pasteEvent(keyframe)
		local clip = State.eventClipboard
		if not clip then
			notify("Nothing to paste. Copy an event first.", "error")
			return
		end
		if not State.target then
			notify("Link a UI first.", "error")
			return
		end
		if countEvents() >= MAX_IMPORT_EVENTS then
			notify("An animation can hold at most 1,000 events.", "error")
			return
		end
		if State.playing then
			stopPlayback()
		end
	
		pushUndo()
		keyframe = keyframe or keyframeAt(State.time) or newKeyframe(State.time, {})
		table.insert(keyframe.Events, EV.new(clip.Name, clip.Params, clip.Enabled))
		State.selected = keyframe
		State.selectedEvent = #keyframe.Events
		A.setTime(keyframe.Time)
		afterEdit()
	end
	
	function A.testEvent(keyframe, index)
		local event = keyframe and keyframe.Events[index]
		if not event then
			return
		end
		if event.Enabled == false then
			notify("This event is muted. Enable it to test it.", "error")
			return
		end
		A.onEventFired(event, keyframe.Time)
	end
	
	local function restoreSnapshot(snapshot)
		stopPlayback()
		State.keyframes = decodeKeyframes(snapshot.keys)
		State.selected = snapshot.selected and State.keyframes[snapshot.selected] or nil
		State.selectedEvent = snapshot.selectedEvent
		State.time = isFiniteNumber(snapshot.time) and math.clamp(snapshot.time, 0, MAX_ANIMATION_TIME) or 0
		if type(snapshot.loop) == "boolean" then
			State.loop = snapshot.loop
		end
		if type(snapshot.enabledProps) == "table" then
			State.enabledProps = table.clone(snapshot.enabledProps)
		end
	
		for _, keyframe in ipairs(State.keyframes) do
			for property in pairs(keyframe.Properties) do
				State.enabledProps[property] = true
			end
		end
	
		if #State.keyframes == 0 then
			restoreBaseline()
		end
	
		lastUndoKey = nil
		A.updateToggleButtons()
		A.refreshProperties()
		A.setTime(State.time)
		afterEdit()
		A.updateHistoryButtons()
	end
	
	function A.undo()
		if not State.target or #State.undo == 0 then
			notify("Nothing to undo.")
			return
		end
		table.insert(State.redo, snapshotState())
		restoreSnapshot(table.remove(State.undo))
		notify("Undo", "ok")
	end
	
	function A.redo()
		if not State.target or #State.redo == 0 then
			notify("Nothing to redo.")
			return
		end
		table.insert(State.undo, snapshotState())
		restoreSnapshot(table.remove(State.redo))
		notify("Redo", "ok")
	end
	
	function A.commitText(property)
		local entry = valueRows[property]
		local target = State.target
	
		if not target or not entry then
			A.refreshValues()
			return
		end
	
		local parsed = parseValue(entry.box.Text, target[property])
		if parsed == nil then
			notify("Invalid value for " .. property, "error")
			entry.box.Text = formatValue(target[property])
			return
		end
	
		if State.playing then
			stopPlayback()
		end
	
		if INTEGER_PROPS[property] and type(parsed) == "number" then
			parsed = math.round(parsed)
		end
	
		pushUndo()
		State.enabledProps[property] = true
		ensureBaseKeyframe()
	
		applyingProperties += 1
		pcall(function()
			target[property] = parsed
		end)
		applyingProperties -= 1
	
		local final = target[property]
		applied[property] = final
	
		local keyframe = keyframeAt(State.time)
		if not keyframe then
			keyframe = newKeyframe(State.time, {})
		end
		keyframe.Properties[property] = final
	
		State.selected = keyframe
		A.refreshProperties()
		afterEdit()
	end
	
	local function onTargetPropertyChanged(property)
		if not State.playing then
			A.refreshValues()
		end
	
		local target = State.target
		if not target or applyingProperties > 0 or State.playing or drag or not State.autoKey then
			return
		end
		if not hasProperty(target, property) then
			return
		end
	
		local value = target[property]
		if applied[property] == value then
			return
		end
		State.enabledProps[property] = true
	
		pushUndo("autokey")
		applied[property] = value
	
		local keyframe = keyframeAt(State.time)
		if not keyframe then
			if #State.keyframes == 0 then
				ensureBaseKeyframe()
			end
			keyframe = keyframeAt(State.time)
			if not keyframe then
				keyframe = newKeyframe(State.time, {})
			end
		end
	
		keyframe.Properties[property] = value
		State.selected = keyframe
		afterEdit()
	end
	
	local function fireEvents(from, to)
		for _, keyframe in ipairs(State.keyframes) do
			if keyframe.Time > from and keyframe.Time <= to then
				for _, event in ipairs(keyframe.Events) do
					if event.Enabled ~= false then
						A.onEventFired(event, keyframe.Time)
					end
				end
			end
		end
	end
	
	function A.onEventFired(event, time)
		local params = formatParams(event.Params)
		if State.logEvents then
			print(string.format("%sEvent %q @ %.2fs  %s", PREFIX, event.Name, time, params ~= "" and ("{ " .. params .. " }") or ""))
		end
		setHint("Event: " .. event.Name .. (params ~= "" and ("  " .. params) or ""), C.event, 1.6)
	end
	
	local function startPlayback(fromTime, stopAt)
		if not State.target then
			notify("Link a UI first.", "error")
			return
		end
	
		local duration = getDuration()
		if #State.keyframes < 2 or duration <= 0 then
			notify("At least 2 keyframes at different times are required.", "error")
			return
		end
	
		if State.playing then
			stopPlayback()
		end
	
		local limit = duration
		if stopAt then
			limit = math.clamp(stopAt, 0, duration)
		end
		local ranged = stopAt ~= nil
	
		if fromTime then
			State.time = math.clamp(fromTime, 0, duration)
		elseif State.time >= duration then
			State.time = 0
		end
		if State.time >= limit then
			if ranged then
				notify("Nothing to preview in that range.", "error")
				return
			end
			State.time = 0
		end
	
		State.playing = true
		A.updatePlayButton()
		applyAt(State.time)
		fireEvents(State.time <= 0 and -1 or State.time, State.time)
	
		playConnection = RunService.Heartbeat:Connect(function(dt)
			local remaining = math.max(dt * State.speed, 0)
			local safety = 0
	
			while remaining > 0 and State.playing and safety < 8 do
				safety += 1
				local previous = State.time
				local distance = limit - previous
	
				if remaining < distance then
					State.time = previous + remaining
					applyAt(State.time)
					fireEvents(previous, State.time)
					remaining = 0
				elseif State.loop and not ranged then
					fireEvents(previous, limit)
					remaining -= distance
					State.time = 0
					applyAt(0)
					fireEvents(-1, 0)
				else
					fireEvents(previous, limit)
					A.setTime(limit)
					stopPlayback()
					remaining = 0
				end
			end
	
			A.updatePlayhead()
			A.updateStatus()
		end)
	end
	A.playRange = startPlayback
	
	function A.togglePlay()
		if State.playing then
			stopPlayback()
		else
			startPlayback()
		end
	end
	
	local function notifyLinkChanged()
		for _, listener in ipairs(A.linkListeners) do
			pcall(listener)
		end
	end
	
	local function disconnectTarget()
		for _, connection in ipairs(propertyConnections) do
			connection:Disconnect()
		end
		table.clear(propertyConnections)
	
		if ancestryConnection then
			ancestryConnection:Disconnect()
			ancestryConnection = nil
		end
	end
	
	local function resetHistory()
		table.clear(State.undo)
		table.clear(State.redo)
		lastUndoKey = nil
		A.updateHistoryButtons()
	end
	
	local function unlinkTarget()
		stopPlayback()
		disconnectTarget()
		State.target = nil
		State.keyframes = {}
		State.selected = nil
		State.selectedEvent = nil
		State.time = 0
		table.clear(baseline)
		table.clear(applied)
		resetHistory()
		A.refreshProperties()
		A.refreshInspector()
		A.rebuildTimeline()
		A.updateStatus()
		notifyLinkChanged()
	end
	
	local function linkTarget(gui)
		if State.target == gui then
			return
		end
	
		stopPlayback()
		restoreBaseline()
		disconnectTarget()
		table.clear(applied)
	
		State.target = gui
		State.time = 0
		snapshotBaseline()
		loadFromTarget()
		resetHistory()
	
		for _, property in ipairs({ "Text", "TextTransparency", "ImageTransparency", "GroupTransparency" }) do
			if hasProperty(gui, property) then
				State.enabledProps[property] = true
			end
		end
	
		for _, property in ipairs(PROPERTY_CATALOG) do
			if hasProperty(gui, property) then
				table.insert(
					propertyConnections,
					gui:GetPropertyChangedSignal(property):Connect(function()
						onTargetPropertyChanged(property)
					end)
				)
			end
		end
	
		ancestryConnection = gui.AncestryChanged:Connect(function()
			if not gui:IsDescendantOf(game) then
				unlinkTarget()
			end
		end)
	
		A.updateToggleButtons()
		A.refreshProperties()
		A.refreshInspector()
		A.rebuildTimeline()
		A.setTime(0)
		notifyLinkChanged()
	end
	
	local function setSnap(step)
		State.snap = step
		A.updateToggleButtons()
		A.saveSettings()
	end
	
	local function setZoom(newPx, anchorX)
		newPx = math.clamp(newPx, MIN_ZOOM, MAX_ZOOM)
		if newPx == State.pxPerSec then
			return
		end
		anchorX = anchorX or scroll.AbsoluteSize.X / 2
		local anchorTime = (scroll.CanvasPosition.X + anchorX - LEFT_PAD) / State.pxPerSec
		State.pxPerSec = newPx
		A.rebuildTimeline()
		scroll.CanvasPosition = Vector2.new(math.max(0, LEFT_PAD + anchorTime * newPx - anchorX), 0)
		A.saveSettings()
	end
	
	function A.fitZoom()
		local duration = math.max(getDuration(), 1)
		local available = math.max(scroll.AbsoluteSize.X - LEFT_PAD * 2 - 20, 100)
		State.pxPerSec = math.clamp(available / duration, MIN_ZOOM, MAX_ZOOM)

	R.afterEdit = afterEdit
	R.stopPlayback = stopPlayback
	R.fireEvents = fireEvents
	R.disconnectTarget = disconnectTarget
	R.unlinkTarget = unlinkTarget
	R.linkTarget = linkTarget
	R.setSnap = setSnap
	R.setZoom = setZoom

end
