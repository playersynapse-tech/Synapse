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
	local afterEdit = R.afterEdit
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
	local disconnectTarget = R.disconnectTarget
	local drag = R.drag
	local encodeKeyframes = R.encodeKeyframes
	local evaluateProperty = R.evaluateProperty
	local fireEvents = R.fireEvents
	local fmtTime = R.fmtTime
	local formatParams = R.formatParams
	local formatValue = R.formatValue
	local getDuration = R.getDuration
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
	local tip = R.tip
	local trim = R.trim
	local unlinkTarget = R.unlinkTarget
	local valueRows = R.valueRows

	local function styleMenuItems(keyframe)
		local list = {}
		for _, style in ipairs(STYLES) do
			table.insert(list, menuItem(style.Name, function()
				A.setKeyEasing(keyframe, style, nil)
			end, style == keyframe.Style))
		end
		return list
	end
	
	local function directionMenuItems(keyframe)
		local list = {}
		for _, direction in ipairs(DIRECTIONS) do
			table.insert(list, menuItem(direction.Name, function()
				A.setKeyEasing(keyframe, nil, direction)
			end, direction == keyframe.Direction))
		end
		return list
	end
	
	local function snapMenuItems()
		local list = {}
		for _, step in ipairs(SNAP_STEPS) do
			local label = step > 0 and string.format("%gs", step) or "Off"
			table.insert(list, menuItem(label, function()
				setSnap(step)
			end, State.snap == step))
		end
		return list
	end
	
	function A.openKeyframeMenu(keyframe, position)
		local items = {}
	
		table.insert(items, menuItem("Add event...", function()
			A.addEvent(keyframe)
		end))
		table.insert(items, {
			text = "Add event from preset",
			sub = presetMenuItems(function(preset)
				A.addEvent(keyframe, preset)
			end),
		})
		if State.eventClipboard then
			table.insert(items, menuItem("Paste event", function()
				A.pasteEvent(keyframe)
			end))
		end
		if #keyframe.Events > 0 then
			local editList = {}
			for index, event in ipairs(keyframe.Events) do
				table.insert(editList, menuItem((event.Enabled == false and "(off) " or "") .. event.Name, function()
					State.selected = keyframe
					State.selectedEvent = index
					A.refreshInspector()
				end))
			end
			table.insert(items, { text = "Select event", sub = editList })
	
			local deleteList = {}
			for index, event in ipairs(keyframe.Events) do
				table.insert(deleteList, menuItem(event.Name, function()
					A.deleteEvent(keyframe, index)
				end))
			end
			table.insert(items, { text = "Delete event", sub = deleteList })
			table.insert(items, menuItem("Clear all events", function()
				A.clearEvents(keyframe)
			end))
		end
	
		table.insert(items, MENU_SEPARATOR)
		table.insert(items, menuItem("Go to keyframe", function()
			stopPlayback()
			A.setTime(keyframe.Time)
		end))
		if keyframeAt(State.time) ~= keyframe then
			table.insert(items, menuItem("Move to playhead", function()
				A.moveKeyframeToPlayhead(keyframe)
			end))
		end
	
		table.insert(items, MENU_SEPARATOR)
		table.insert(items, menuItem("Copy", function()
			A.copyKeyframe(keyframe)
		end))
		table.insert(items, menuItem("Cut", function()
			A.cutKeyframe(keyframe)
		end))
		if State.clipboard then
			table.insert(items, menuItem("Paste at playhead", function()
				A.pasteKeyframe(State.time)
			end))
		end
		table.insert(items, menuItem("Duplicate", function()
			A.duplicateKeyframe(keyframe)
		end))
		table.insert(items, menuItem("Delete", function()
			A.deleteKeyframe(keyframe)
		end))
	
		table.insert(items, MENU_SEPARATOR)
		table.insert(items, { text = "Easing style (" .. keyframe.Style.Name .. ")", sub = styleMenuItems(keyframe) })
		table.insert(items, { text = "Easing direction (" .. keyframe.Direction.Name .. ")", sub = directionMenuItems(keyframe) })
		table.insert(items, menuItem("Apply this easing to all keyframes", function()
			A.applyEasingToAll(keyframe)
		end))
	
		A.openMenu(items, position)
	end
	
	function A.openTimelineMenu(time, position)
		time = snapTime(time)
		local items = {}
	
		table.insert(items, menuItem("Add keyframe here", function()
			A.setTime(time)
			A.recordKeyframe()
		end))
		table.insert(items, menuItem("Add event here", function()
			A.addEventAt(time)
		end))
		table.insert(items, {
			text = "Add event here from preset",
			sub = presetMenuItems(function(preset)
				A.addEventAt(time, preset)
			end),
		})
		if State.eventClipboard then
			table.insert(items, menuItem("Paste event here", function()
				A.setTime(time)
				A.pasteEvent(keyframeAt(time))
			end))
		end
		if State.clipboard then
			table.insert(items, menuItem("Paste keyframe here", function()
				A.pasteKeyframe(time)
			end))
		end
		table.insert(items, MENU_SEPARATOR)
		table.insert(items, menuItem("Open Effects panel", function()
			A.toggleEffects(true)
		end))
		table.insert(items, menuItem("Move playhead here", function()
			stopPlayback()
			A.setTime(time)
		end))
		table.insert(items, menuItem("Go to start", A.goToStart))
		table.insert(items, menuItem("Go to end", A.goToEnd))
		table.insert(items, MENU_SEPARATOR)
		table.insert(items, menuItem("Zoom in", function()
			setZoom(State.pxPerSec * 1.25)
		end))
		table.insert(items, menuItem("Zoom out", function()
			setZoom(State.pxPerSec / 1.25)
		end))
		table.insert(items, menuItem("Fit to animation", A.fitZoom))
		table.insert(items, { text = "Snapping", sub = snapMenuItems() })
		table.insert(items, menuItem("Follow playhead while playing", function()
			State.follow = not State.follow
			A.saveSettings()
		end, State.follow))
	
		A.openMenu(items, position)
	end
	
	local timelineRefreshQueued = false
	
	local function scheduleTimelineRefresh()
		if timelineRefreshQueued then
			return
		end
		timelineRefreshQueued = true
		task.delay(1 / 30, function()
			timelineRefreshQueued = false
			if drag then
				A.rebuildTimeline()
			end
		end)
	end
	
	local dragLayer = create("TextButton", {
		Name = "DragLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		Visible = false,
		ZIndex = 250,
	}, mainBg)
	
	local function endDrag()
		dragLayer.Visible = false
		if not drag then
			return
		end
		local moved = drag.moved
		drag = nil
	
		if moved then
			sortKeyframes()
			A.rebuildTimeline()
			A.refreshInspector()
			A.scheduleSave()
		end
	end
	
	local function beginDrag(mode, key)
		if State.playing then
			stopPlayback()
		end
		drag = { mode = mode, key = key, moved = false }
		dragLayer.Visible = true
	end
	
	local function onDragMove(x)
		if not drag then
			return
		end
	
		local time = snapTime(mouseToTime(x))
		if drag.mode == "scrub" then
			A.setTime(time)
		elseif drag.key then
			if time == drag.key.Time then
				return
			end
			local clash = keyframeAt(time)
			if clash and clash ~= drag.key then
				return
			end
			if not drag.moved then
				drag.moved = true
				pushUndo()
			end
			drag.key.Time = time
			sortKeyframes()
			A.setTime(time)
			scheduleTimelineRefresh()
			Insp.timeBox.Text = string.format("%.3f", time)
		end
	end
	
	dragLayer.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			onDragMove(input.Position.X)
		end
	end)
	dragLayer.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			endDrag()
		end
	end)
	dragLayer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			endDrag()
		end
	end)
	dragLayer.MouseLeave:Connect(endDrag)
	pluginGui.WindowFocusReleased:Connect(endDrag)
	
	local function handleWheel(input)
		if input.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end
		scroll.CanvasPosition = Vector2.new(math.max(0, scroll.CanvasPosition.X - input.Position.Z * 90), 0)
	end
	
	scroll.InputChanged:Connect(handleWheel)
	
	local lastClickAt, lastClickX = 0, 0
	
	local function bindKeyInput(object, keyframe, eventIndex)
		object.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				State.selected = keyframe
				State.selectedEvent = eventIndex
				beginDrag("key", keyframe)
				A.setTime(keyframe.Time)
				A.refreshInspector()
				A.rebuildTimeline()
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				local position = anchorFromInput(input)
				State.selected = keyframe
				State.selectedEvent = eventIndex
				A.refreshInspector()
				A.rebuildTimeline()
				A.openKeyframeMenu(keyframe, position)
			end
		end)
	end
	
	function A.rebuildTimeline()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
	
		local duration = getDuration()
		local widthPx = math.max((math.max(duration, 2) + 2) * State.pxPerSec + LEFT_PAD * 2, scroll.AbsoluteSize.X)
		scroll.CanvasSize = UDim2.fromOffset(widthPx, 0)
	
		local keyLaneBottom = EVENT_LANE_Y - 22
	
		create("Frame", {
			Size = UDim2.fromOffset(widthPx, RULER_H),
			BackgroundColor3 = C.bar,
			BorderSizePixel = 0,
		}, scroll)
		create("Frame", {
			Position = UDim2.fromOffset(0, RULER_H),
			Size = UDim2.fromOffset(widthPx, keyLaneBottom - RULER_H),
			BackgroundColor3 = C.laneKeys,
			BorderSizePixel = 0,
		}, scroll)
		create("Frame", {
			Position = UDim2.fromOffset(0, keyLaneBottom),
			Size = UDim2.fromOffset(widthPx, LANES_H - keyLaneBottom),
			BackgroundColor3 = C.laneEvents,
			BorderSizePixel = 0,
		}, scroll)
	
		if duration > 0 then
			create("Frame", {
				Position = UDim2.fromOffset(LEFT_PAD, 0),
				Size = UDim2.fromOffset(duration * State.pxPerSec, LANES_H),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.96,
				BorderSizePixel = 0,
			}, scroll)
		end
	
		local step = 10
		for _, candidate in ipairs({ 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10 }) do
			if candidate * State.pxPerSec >= 64 then
				step = candidate
				break
			end
		end
	
		local totalSeconds = (widthPx - LEFT_PAD * 2) / State.pxPerSec
		for i = 0, math.floor(totalSeconds / step) do
			local x = LEFT_PAD + i * step * State.pxPerSec
	
			create("Frame", {
				Position = UDim2.fromOffset(x, RULER_H - 8),
				Size = UDim2.fromOffset(1, 8),
				BackgroundColor3 = C.textDim,
				BorderSizePixel = 0,
			}, scroll)
	
			create("Frame", {
				Position = UDim2.fromOffset(x, RULER_H),
				Size = UDim2.fromOffset(1, LANES_H - RULER_H),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.93,
				BorderSizePixel = 0,
			}, scroll)
	
			create("TextLabel", {
				Position = UDim2.fromOffset(x + 3, 2),
				Size = UDim2.fromOffset(60, 14),
				BackgroundTransparency = 1,
				Text = step < 1 and string.format("%.2fs", i * step) or string.format("%ds", i * step),
				TextColor3 = C.textDim,
				Font = BRAND.Font,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, scroll)
		end
	
		local scrubArea = create("TextButton", {
			Size = UDim2.fromOffset(widthPx, LANES_H),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 1,
		}, scroll)
	
		scrubArea.InputChanged:Connect(handleWheel)
		scrubArea.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local time = snapTime(mouseToTime(input.Position.X))
				local localY = input.Position.Y - scroll.AbsolutePosition.Y
				local now = os.clock()
	
				if localY > RULER_H and now - lastClickAt < 0.3 and math.abs(input.Position.X - lastClickX) < 6 then
					lastClickAt = 0
					A.setTime(time)
					A.recordKeyframe()
					return
				end
	
				lastClickAt, lastClickX = now, input.Position.X
				beginDrag("scrub")
				A.setTime(time)
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				A.openTimelineMenu(mouseToTime(input.Position.X), anchorFromInput(input))
			end
		end)
	
		for index = 1, #State.keyframes - 1 do
			local a, b = State.keyframes[index], State.keyframes[index + 1]
			create("Frame", {
				Position = UDim2.fromOffset(LEFT_PAD + a.Time * State.pxPerSec, KEY_LANE_Y - 1),
				Size = UDim2.fromOffset(math.max((b.Time - a.Time) * State.pxPerSec, 1), 2),
				BackgroundColor3 = C.key,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				ZIndex = 2,
			}, scroll)
		end
	
		local eventXs = {}
		for _, keyframe in ipairs(State.keyframes) do
			if #keyframe.Events > 0 then
				table.insert(eventXs, LEFT_PAD + keyframe.Time * State.pxPerSec)
			end
		end
	
		for _, keyframe in ipairs(State.keyframes) do
			local x = LEFT_PAD + keyframe.Time * State.pxPerSec
			local isSelected = keyframe == State.selected
			local propertyCount = 0
			for _ in pairs(keyframe.Properties) do
				propertyCount += 1
			end
	
			local diamond = create("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(x, KEY_LANE_Y),
				Size = UDim2.fromOffset(16, 16),
				Rotation = 45,
				BackgroundColor3 = isSelected and C.keySel or C.key,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5,
			}, scroll)
			bindKeyInput(diamond, keyframe, nil)
			diamond.MouseEnter:Connect(function()
				setHint(string.format(
					"Keyframe %s  |  %d propert%s  |  %d event(s)  |  right-click for options",
					fmtTime(keyframe.Time),
					propertyCount,
					propertyCount == 1 and "y" or "ies",
					#keyframe.Events
					))
			end)
			diamond.MouseLeave:Connect(function()
				setHint("")
			end)
	
			create("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromOffset(x, KEY_LANE_Y + 14),
				Size = UDim2.fromOffset(60, 14),
				BackgroundTransparency = 1,
				Text = fmtTime(keyframe.Time),
				TextColor3 = isSelected and C.keySel or C.textDim,
				Font = BRAND.Font,
				TextSize = 12,
				ZIndex = 5,
			}, scroll)
	
			if #keyframe.Events > 0 then
				create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromOffset(x, KEY_LANE_Y + 9),
					Size = UDim2.fromOffset(1, EVENT_LANE_Y - KEY_LANE_Y - 18),
					BackgroundColor3 = C.event,
					BackgroundTransparency = 0.6,
					BorderSizePixel = 0,
					ZIndex = 2,
				}, scroll)
	
				local allOff = true
				for _, e in ipairs(keyframe.Events) do
					if e.Enabled ~= false then
						allOff = false
						break
					end
				end
	
				local marker = create("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(x, EVENT_LANE_Y),
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = isSelected and C.keySel or (allOff and C.gray or C.event),
					BorderSizePixel = 0,
					Text = #keyframe.Events > 1 and tostring(#keyframe.Events) or "",
					TextColor3 = isSelected and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
					Font = BRAND.FontBold,
					TextSize = 12,
					AutoButtonColor = false,
					ZIndex = 6,
				}, scroll)
				corner(marker, 5)
				bindKeyInput(marker, keyframe, 1)
	
				local names = {}
				for _, event in ipairs(keyframe.Events) do
					table.insert(names, event.Name .. (event.Enabled == false and " (off)" or ""))
				end
				marker.MouseEnter:Connect(function()
					setHint("Events: " .. table.concat(names, ", ") .. "  |  right-click for options", C.event)
				end)
				marker.MouseLeave:Connect(function()
					setHint("")
				end)
	
				local labelWidth = 150
				for _, otherX in ipairs(eventXs) do
					if otherX > x + 1 then
						labelWidth = math.min(labelWidth, otherX - x - 24)
						break
					end
				end
				if labelWidth >= 24 then
					create("TextLabel", {
						Position = UDim2.fromOffset(x + 14, EVENT_LANE_Y - 8),
						Size = UDim2.fromOffset(labelWidth, 16),
						BackgroundTransparency = 1,
						Text = keyframe.Events[1].Name .. (#keyframe.Events > 1 and (" +" .. (#keyframe.Events - 1)) or ""),
						TextColor3 = C.event,
						Font = BRAND.FontBold,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						ZIndex = 6,
					}, scroll)
				end
			end
		end
	
		playhead = create("Frame", {
			Position = UDim2.fromOffset(LEFT_PAD + State.time * State.pxPerSec - 1, 0),
			Size = UDim2.fromOffset(2, LANES_H + 40),
			BackgroundColor3 = C.playhead,
			BorderSizePixel = 0,
			ZIndex = 10,
		}, scroll)
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromOffset(12, 10),
			BackgroundColor3 = C.playhead,
			BorderSizePixel = 0,
			ZIndex = 10,
		}, playhead)
	end
	
	do
		local resizePending = false
		scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if resizePending then
				return
			end
			resizePending = true
			task.defer(function()
				resizePending = false
				A.rebuildTimeline()
			end)
		end)
	end
	
	local function ensureId(target)
		local current = target:GetAttribute(ID_ATTRIBUTE)
		if current == nil then
			local legacy = target:GetAttribute(LEGACY_ID_ATTRIBUTE)
			if type(legacy) == "string" and legacy ~= "" then
				current = legacy
				pcall(function()
					target:SetAttribute(ID_ATTRIBUTE, legacy)
					target:SetAttribute(LEGACY_ID_ATTRIBUTE, nil)
				end)
			end
		end

		if type(current) == "string" and current ~= "" then
			local duplicated = false
			for _, other in ipairs(StarterGui:GetDescendants()) do
				if other ~= target and other:GetAttribute(ID_ATTRIBUTE) == current then
					duplicated = true
					break
				end
			end
			if not duplicated then
				return current
			end
		end

		local id = HttpService:GenerateGUID(false):gsub("%-", ""):sub(1, 8):lower()
		pcall(function()
			target:SetAttribute(ID_ATTRIBUTE, id)
		end)
		return id
	end

	R.styleMenuItems = styleMenuItems
	R.directionMenuItems = directionMenuItems
	R.ensureId = ensureId

end
