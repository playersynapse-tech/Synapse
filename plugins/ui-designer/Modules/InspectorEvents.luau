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
	local applied = R.applied
	local applyAt = R.applyAt
	local applyingProperties = R.applyingProperties
	local baseline = R.baseline
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
	local notify = R.notify
	local num = R.num
	local orderer = R.orderer
	local padding = R.padding
	local parseParams = R.parseParams
	local parseValue = R.parseValue
	local playConnection = R.playConnection
	local pluginGui = R.pluginGui
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

	local function anchorBelow(object)
		local origin = mainBg.AbsolutePosition
		return Vector2.new(object.AbsolutePosition.X - origin.X, object.AbsolutePosition.Y - origin.Y + object.AbsoluteSize.Y + 2)
	end
	
	local function anchorFromInput(input)
		local origin = mainBg.AbsolutePosition
		return Vector2.new(input.Position.X - origin.X, input.Position.Y - origin.Y)
	end
	
	local playhead = nil
	
	local function mouseToTime(x)
		local relative = x - scroll.AbsolutePosition.X + scroll.CanvasPosition.X - LEFT_PAD
		return math.max(0, relative / State.pxPerSec)
	end
	
	function A.updatePlayhead()
		if playhead then
			playhead.Position = UDim2.fromOffset(LEFT_PAD + State.time * State.pxPerSec - 1, 0)
		end
	
		if State.playing and State.follow then
			local x = LEFT_PAD + State.time * State.pxPerSec
			local left = scroll.CanvasPosition.X
			if x < left or x > left + scroll.AbsoluteSize.X - 24 then
				scroll.CanvasPosition = Vector2.new(math.max(0, x - 40), 0)
			end
		end
	end
	
	function A.updateStatus()
		if not State.target then
			statusLabel.Text =
				'No UI linked. Create an object in the "Synapse UI Designer - Object" window, or select a GuiObject and click "Link UI".'
			return
		end
	
		statusLabel.Text = string.format(
			"%s  |  %.2fs / %.2fs  |  %d keyframe(s)  |  %d event(s)%s",
			State.target.Name,
			State.time,
			getDuration(),
			#State.keyframes,
			countEvents(),
			State.playing and "  |  playing" or ""
		)
	end
	
	function A.updatePlayButton()
		Btn.play.Text = State.playing and "Pause" or "Play"
		Btn.play.BackgroundColor3 = State.playing and C.orange or C.green
	end
	
	function A.updateToggleButtons()
		Btn.loop.Text = State.loop and "Loop: on" or "Loop: off"
		Btn.loop.BackgroundColor3 = State.loop and C.blue or C.gray
		Btn.auto.Text = State.autoKey and "Auto-key: on" or "Auto-key: off"
		Btn.auto.BackgroundColor3 = State.autoKey and C.orange or C.gray
		Btn.speed.Text = string.format("Speed: %gx", State.speed)
		Btn.snap.Text = State.snap > 0 and string.format("Snap: %gs", State.snap) or "Snap: off"
		Btn.log.Text = State.logEvents and "Log: on" or "Log: off"
		Btn.log.BackgroundColor3 = State.logEvents and C.event or C.gray
	end
	
	function A.updateHistoryButtons()
		Btn.undo.TextTransparency = #State.undo > 0 and 0 or 0.55
		Btn.redo.TextTransparency = #State.redo > 0 and 0 or 0.55
		if A.onHistoryChanged then
			A.onHistoryChanged()
		end
	end
	
	function A.refreshProperties()
		for property, button in pairs(propertyButtons) do
			local available = not State.target or hasProperty(State.target, property)
			local enabled = State.enabledProps[property] == true
	
			button.Text = string.format("%s %s", enabled and "[x]" or "[ ]", property)
			button.TextColor3 = available and C.text or C.textDim
			button.BackgroundColor3 = (enabled and available) and C.selected or C.row
			button.Visible = available and State.showProps
		end
	
		A.refreshValues()
	end
	
	function A.refreshValues()
		local target = State.target
		local keyed = keyframeAt(State.time)
	
		for property, entry in pairs(valueRows) do
			local available = target ~= nil and hasProperty(target, property)
			entry.row.Visible = available
	
			if available then
				local value = target[property]
	
				if not entry.box:IsFocused() then
					entry.box.Text = formatValue(value)
				end
				if entry.swatch then
					entry.swatch.BackgroundColor3 = value
				end
	
				local isKeyed = keyed ~= nil and keyed.Properties[property] ~= nil
				entry.label.TextColor3 = isKeyed and C.keySel or C.text
			end
		end
	
		if A.onTextChanged then
			A.onTextChanged()
		end
	end
	
	local pendingEventFocus = nil
	local pendingParamFocus = nil
	local EVENT_SELECTED = Color3.fromRGB(70, 52, 96)
	
	local function presetMenuItems(onPick)
		local list = {}
		for _, preset in ipairs(EV.PRESETS) do
			table.insert(list, menuItem(preset.name, function()
				onPick(preset)
			end))
		end
		return list
	end
	
	local function usedEventNames()
		local seen, names = {}, {}
		for _, keyframe in ipairs(State.keyframes) do
			for _, event in ipairs(keyframe.Events) do
				if not seen[event.Name] then
					seen[event.Name] = true
					table.insert(names, event.Name)
				end
			end
		end
		table.sort(names)
		return names
	end
	
	function A.openEventMenu(keyframe, index, position)
		local event = keyframe and keyframe.Events[index]
		if not event then
			return
		end
		local enabled = event.Enabled ~= false
		local items = {}
	
		table.insert(items, menuItem(enabled and "Disable event (mute)" or "Enable event", function()
			A.setEventEnabled(keyframe, index, not enabled)
		end))
		table.insert(items, menuItem("Test fire (log)", function()
			A.testEvent(keyframe, index)
		end))
		table.insert(items, MENU_SEPARATOR)
	
		table.insert(items, {
			text = "Apply preset",
			sub = presetMenuItems(function(preset)
				A.applyPreset(keyframe, index, preset)
			end),
		})
		local names = usedEventNames()
		if #names > 0 then
			local list = {}
			for _, name in ipairs(names) do
				table.insert(list, menuItem(name, function()
					A.renameEvent(keyframe, index, name)
				end, name == event.Name))
			end
			table.insert(items, { text = "Rename to existing name", sub = list })
		end
	
		table.insert(items, MENU_SEPARATOR)
		table.insert(items, menuItem("Duplicate", function()
			A.duplicateEvent(keyframe, index)
		end))
		if index > 1 then
			table.insert(items, menuItem("Move up", function()
				A.moveEvent(keyframe, index, -1)
			end))
		end
		if index < #keyframe.Events then
			table.insert(items, menuItem("Move down", function()
				A.moveEvent(keyframe, index, 1)
			end))
		end
		table.insert(items, menuItem("Copy event", function()
			A.copyEvent(keyframe, index)
		end))
		if State.eventClipboard then
			table.insert(items, menuItem("Paste event here", function()
				A.pasteEvent(keyframe)
			end))
		end
		table.insert(items, MENU_SEPARATOR)
		table.insert(items, menuItem("Clear parameters", function()
			A.clearParams(keyframe, index)
		end))
		table.insert(items, menuItem("Delete event", function()
			A.deleteEvent(keyframe, index)
		end))
	
		A.openMenu(items, position)
	end
	
	function A.rebuildEventOverview()
		local frame = Insp.overviewFrame
		if not frame then
			return
		end
		for _, child in ipairs(frame:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end
	
		local total = countEvents()
		if total == 0 then
			create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = "No events in this animation yet.",
				TextColor3 = C.textDim,
				Font = BRAND.Font,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, frame)
			return
		end
	
		local shown, order = 0, 0
		for _, keyframe in ipairs(State.keyframes) do
			for index, event in ipairs(keyframe.Events) do
				if shown >= 60 then
					break
				end
				shown += 1
				order += 1
	
				local active = keyframe == State.selected and State.selectedEvent == index
				local off = event.Enabled == false
				local params = formatParams(event.Params)
				local row = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundColor3 = active and EVENT_SELECTED or C.row,
					BorderSizePixel = 0,
					Text = string.format(
						"%s  %s%s%s",
						fmtTime(keyframe.Time),
						off and "(off) " or "",
						event.Name,
						params ~= "" and ("  " .. params) or ""
					),
					TextColor3 = off and C.textDim or C.event,
					Font = BRAND.Font,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					LayoutOrder = order,
				}, frame)
				corner(row)
				padding(row, 6, 6, 0, 0)
	
				row.MouseButton1Click:Connect(function()
					A.stopPlayback()
					State.selected = keyframe
					State.selectedEvent = index
					A.setTime(keyframe.Time)
					A.refreshInspector()
					A.rebuildTimeline()
				end)
			end
		end
	
		if total > shown then
			create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = string.format("+ %d more event(s)", total - shown),
				TextColor3 = C.textDim,
				Font = BRAND.Font,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = order + 1,
			}, frame)
		end
	end
	
	function A.rebuildEventList()
		local frame = Insp.eventsFrame
		for _, child in ipairs(frame:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end
	
		local keyframe = State.selected
		if not keyframe or #keyframe.Events == 0 then
			create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = keyframe and "No events on this keyframe." or "Select a keyframe to edit its events.",
				TextColor3 = C.textDim,
				Font = BRAND.Font,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, frame)
			A.rebuildEventOverview()
			return
		end
	
		local cards = {}
	
		local function highlight(selectedIndex)
			State.selectedEvent = selectedIndex
			for cardIndex, card in pairs(cards) do
				card.BackgroundColor3 = cardIndex == selectedIndex and EVENT_SELECTED or C.row
			end
		end
	
		local function smallButton(parent, text, color, position, width, tooltip)
			local button = create("TextButton", {
				Position = position,
				Size = UDim2.fromOffset(width, 22),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Text = text,
				TextColor3 = Color3.new(1, 1, 1),
				Font = BRAND.FontBold,
				TextSize = 12,
				AutoButtonColor = true,
			}, parent)
			corner(button)
			if tooltip then
				tip(button, tooltip)
			end
			return button
		end
	
		local function inputBox(parent, text, placeholder, position, size, font, color)
			local box = create("TextBox", {
				Position = position,
				Size = size,
				BackgroundColor3 = C.lane,
				BorderSizePixel = 0,
				Text = text,
				PlaceholderText = placeholder,
				PlaceholderColor3 = C.textDim,
				TextColor3 = color or C.text,
				Font = font or Enum.Font.Code,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ClearTextOnFocus = false,
			}, parent)
			corner(box)
			padding(box, 5, 5, 0, 0)
			return box
		end
	
		for index, event in ipairs(keyframe.Events) do
			local enabled = event.Enabled ~= false
	
			local card = create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = State.selectedEvent == index and EVENT_SELECTED or C.row,
				BorderSizePixel = 0,
				LayoutOrder = index,
			}, frame)
			corner(card)
			padding(card, 4, 4, 4, 4)
			create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, card)
			cards[index] = card
			local nextRow = orderer()
	
			local header = create("Frame", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				LayoutOrder = nextRow(),
			}, card)
	
			local toggle = smallButton(
				header,
				enabled and "ON" or "OFF",
				enabled and C.green or C.gray,
				UDim2.fromOffset(0, 1),
				30,
				"Enable / disable this event (disabled events are skipped in preview and export)"
			)
			local nameBox = inputBox(
				header,
				event.Name,
				"Event name",
				UDim2.fromOffset(34, 1),
				UDim2.new(1, -112, 0, 22),
				BRAND.FontBold,
				enabled and C.event or C.textDim
			)
			nameBox.TextSize = 14
			local testButton = smallButton(header, ">", C.blue, UDim2.new(1, -74, 0, 1), 22, "Test fire (logs the event)")
			local menuButton = smallButton(header, "...", C.gray, UDim2.new(1, -48, 0, 1), 22, "More: presets, duplicate, move, copy")
			local removeButton = smallButton(header, "x", C.danger, UDim2.new(1, -22, 0, 1), 22, "Delete this event")
	
			nameBox.Focused:Connect(function()
				highlight(index)
			end)
			nameBox.FocusLost:Connect(function()
				local name = sanitizeEventName(nameBox.Text)
				if not name then
					notify("An event needs a name.", "error")
					nameBox.Text = event.Name
					return
				end
				nameBox.Text = name
				if name ~= event.Name then
					pushUndo()
					event.Name = name
					A.rebuildTimeline()
					A.rebuildEventOverview()
					A.scheduleSave()
				end
			end)
			toggle.MouseButton1Click:Connect(function()
				A.setEventEnabled(keyframe, index, not enabled)
			end)
			testButton.MouseButton1Click:Connect(function()
				highlight(index)
				A.testEvent(keyframe, index)
			end)
			menuButton.MouseButton1Click:Connect(function()
				highlight(index)
				A.openEventMenu(keyframe, index, anchorBelow(menuButton))
			end)
			removeButton.MouseButton1Click:Connect(function()
				A.deleteEvent(keyframe, index)
			end)
	
			for _, key in ipairs(EV.sortedKeys(event.Params)) do
				local value = event.Params[key]
				local kind = EV.typeOf(value)
				local isColor = kind == "Color3"
	
				local row = create("Frame", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundTransparency = 1,
					LayoutOrder = nextRow(),
				}, card)
	
				local keyBox = inputBox(row, key, "name", UDim2.fromOffset(0, 0), UDim2.new(0.34, -2, 1, 0), Enum.Font.Code, C.text)
				local typeButton = smallButton(
					row,
					EV.LABELS[kind],
					C.gray,
					UDim2.new(0.34, 0, 0, 0),
					46,
					"Click to change the parameter type"
				)
				local valueWidth = UDim2.new(0.66, -50 - 22 - (isColor and 22 or 0), 1, 0)
				local valuePosition = UDim2.new(0.34, 50, 0, 0)
				local removeParam = smallButton(row, "x", C.danger, UDim2.new(1, -20, 0, 0), 20, "Delete parameter")
	
				local valueBox, swatch = nil, nil
				if kind == "boolean" then
					local boolButton = smallButton(
						row,
						tostring(value),
						value and C.green or C.gray,
						valuePosition,
						0,
						"Click to toggle"
					)
					boolButton.Size = valueWidth
					boolButton.MouseButton1Click:Connect(function()
						highlight(index)
						pushUndo()
						event.Params[key] = not event.Params[key]
						A.rebuildEventList()
						A.scheduleSave()
					end)
				else
					valueBox = inputBox(
						row,
						EV.toText(value),
						kind == "Color3" and "#RRGGBB or r, g, b" or "value",
						valuePosition,
						valueWidth,
						Enum.Font.Code,
						C.text
					)
					if isColor then
						swatch = create("Frame", {
							Position = UDim2.new(1, -44, 0, 2),
							Size = UDim2.fromOffset(18, 18),
							BackgroundColor3 = value,
							BorderSizePixel = 0,
						}, row)
						corner(swatch)
					end
	
					valueBox.Focused:Connect(function()
						highlight(index)
					end)
					valueBox.FocusLost:Connect(function()
						local current = event.Params[key]
						if current == nil then
							return
						end
						local parsed = EV.fromText(valueBox.Text, kind)
						if parsed == nil then
							notify(string.format('Invalid %s value for "%s".', EV.LABELS[kind]:lower(), key), "error")
							valueBox.Text = EV.toText(current)
							return
						end
						valueBox.Text = EV.toText(parsed)
						if parsed ~= current then
							pushUndo()
							event.Params[key] = parsed
							if swatch then
								swatch.BackgroundColor3 = parsed
							end
							A.rebuildEventOverview()
							A.scheduleSave()
						end
					end)
				end
	
				keyBox.Focused:Connect(function()
					highlight(index)
				end)
				keyBox.FocusLost:Connect(function()
					local newKey = trim(keyBox.Text)
					if newKey == key then
						return
					end
					if not newKey:match("^[%a_][%w_]*$") then
						notify("Parameter names use letters, numbers and _ (and cannot start with a number).", "error")
						keyBox.Text = key
						return
					end
					if event.Params[newKey] ~= nil then
						notify('A parameter named "' .. newKey .. '" already exists.', "error")
						keyBox.Text = key
						return
					end
					pushUndo()
					event.Params[newKey] = event.Params[key]
					event.Params[key] = nil
					A.rebuildEventList()
					A.scheduleSave()
				end)
	
				typeButton.MouseButton1Click:Connect(function()
					highlight(index)
					local nextKind = cycleNumber(EV.TYPES, kind)
					pushUndo()
					event.Params[key] = EV.convert(event.Params[key], nextKind)
					A.rebuildEventList()
					A.scheduleSave()
				end)
	
				removeParam.MouseButton1Click:Connect(function()
					pushUndo()
					event.Params[key] = nil
					State.selectedEvent = index
					A.rebuildEventList()
					A.scheduleSave()
				end)
	
				if pendingParamFocus and pendingParamFocus.index == index and pendingParamFocus.key == key then
					pendingParamFocus = nil
					task.defer(function()
						keyBox:CaptureFocus()
						pcall(function()
							keyBox.CursorPosition = #keyBox.Text + 1
							keyBox.SelectionStart = 1
						end)
					end)
				end
			end
	
			local footer = create("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				LayoutOrder = nextRow(),
			}, card)
			local quickBox = inputBox(
				footer,
				"",
				'quick add: damage=10, sound="hit"',
				UDim2.fromOffset(0, 0),
				UDim2.new(1, -66, 1, 0),
				Enum.Font.Code,
				C.text
			)
			local addParam = smallButton(footer, "+ Param", C.blue, UDim2.new(1, -62, 0, 0), 62, "Add a parameter row")
	
			quickBox.Focused:Connect(function()
				highlight(index)
			end)
			quickBox.FocusLost:Connect(function()
				local text = trim(quickBox.Text)
				if text == "" then
					return
				end
				local parsed, err = parseParams(text)
				if not parsed then
					notify(err, "error")
					return
				end
				local merged = table.clone(event.Params)
				for key, value in pairs(parsed) do
					merged[key] = value
				end
				local count = 0
				for _ in pairs(merged) do
					count += 1
				end
				if count > MAX_EVENT_PARAMS then
					notify("An event can hold at most 24 parameters.", "error")
					return
				end
				pushUndo()
				event.Params = merged
				State.selectedEvent = index
				A.rebuildEventList()
				A.scheduleSave()
			end)
	
			addParam.MouseButton1Click:Connect(function()
				local count = 0
				for _ in pairs(event.Params) do
					count += 1
				end
				if count >= MAX_EVENT_PARAMS then
					notify("An event can hold at most 24 parameters.", "error")
					return
				end
				pushUndo()
				local key = EV.nextKey(event.Params, "param")
				event.Params[key] = ""
				pendingParamFocus = { index = index, key = key }
				State.selectedEvent = index
				A.rebuildEventList()
				A.scheduleSave()
			end)
	
			if pendingEventFocus == index then
				pendingEventFocus = nil
				task.defer(function()
					nameBox:CaptureFocus()
					pcall(function()
						nameBox.CursorPosition = #nameBox.Text + 1
						nameBox.SelectionStart = 1
					end)
				end)
			end
		end
	
		A.rebuildEventOverview()
	end
	
	function A.refreshInspector()
		local keyframe = State.selected
	
		Insp.timeBox.Text = keyframe and string.format("%.3f", keyframe.Time) or ""
		Insp.btnStyle.Text = "Style: " .. (keyframe and keyframe.Style.Name or "-")
		Insp.btnDirection.Text = "Direction: " .. (keyframe and keyframe.Direction.Name or "-")
	
		local enabled = keyframe ~= nil
		local transparency = enabled and 0 or 0.5
		Insp.timeBox.TextEditable = enabled
		for _, button in ipairs({
			Insp.btnStyle,
			Insp.btnDirection,
			Insp.btnApplyEasing,
			Insp.btnDuplicate,
			Insp.btnDelete,
			}) do
			button.Active = enabled
			button.AutoButtonColor = enabled
			button.TextTransparency = transparency
		end
		Insp.btnDelete.BackgroundColor3 = enabled and C.danger or C.row
	
		A.rebuildEventList()
	end
	
	local function captureProperties()
		local properties = {}
		local target = State.target
		if not target then
			return properties
		end
		for _, property in ipairs(PROPERTY_CATALOG) do
			if State.enabledProps[property] and hasProperty(target, property) then
				properties[property] = target[property]
			end
		end
		return properties
	end
	

	R.anchorBelow = anchorBelow
	R.anchorFromInput = anchorFromInput
	R.playhead = playhead
	R.mouseToTime = mouseToTime
	R.pendingEventFocus = pendingEventFocus
	R.presetMenuItems = presetMenuItems
	R.captureProperties = captureProperties

end
