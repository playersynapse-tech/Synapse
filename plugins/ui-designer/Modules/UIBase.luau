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
	local notify = R.notify
	local num = R.num
	local orderer = R.orderer
	local padding = R.padding
	local parseParams = R.parseParams
	local parseValue = R.parseValue
	local playConnection = R.playConnection
	local pluginGui = R.pluginGui
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

	local function sideHeader(text)
		return create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.textDim,
			Font = BRAND.FontBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = sideOrder(),
		}, side)
	end
	
	local function sideButton(text, color)
		local button = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = color or C.row,
			BorderSizePixel = 0,
			Text = text,
			TextColor3 = C.text,
			Font = BRAND.Font,
			TextSize = 13,
			LayoutOrder = sideOrder(),
		}, side)
		corner(button)
		return button
	end
	
	local propsHeader = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "[-] RECORDED PROPERTIES",
		TextColor3 = C.textDim,
		Font = BRAND.FontBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = sideOrder(),
	}, side)
	tip(propsHeader, "Click to collapse / expand")
	
	local propertyButtons = {}
	for _, property in ipairs(PROPERTY_CATALOG) do
		local button = sideButton(property, C.row)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Size = UDim2.new(1, 0, 0, 22)
		padding(button, 8, 0, 0, 0)
		propertyButtons[property] = button
	
		button.MouseButton1Click:Connect(function()
			if State.target and not hasProperty(State.target, property) then
				return
			end
			State.enabledProps[property] = not State.enabledProps[property]
			A.refreshProperties()
		end)
	end
	
	propsHeader.MouseButton1Click:Connect(function()
		State.showProps = not State.showProps
		propsHeader.Text = (State.showProps and "[-]" or "[+]") .. " RECORDED PROPERTIES"
		A.refreshProperties()
	end)
	
	sideHeader("VALUES AT PLAYHEAD (edit and press Enter)")
	
	local DISPLAY_NAMES = {
		Position = "Position",
		Size = "Size",
		Rotation = "Rotation",
		AnchorPoint = "Anchor",
		BackgroundTransparency = "BG Transp.",
		BackgroundColor3 = "BG Color",
		ImageTransparency = "Img Transp.",
		ImageColor3 = "Img Color",
		Text = "Text",
		TextTransparency = "Text Transp.",
		TextColor3 = "Text Color",
		TextStrokeTransparency = "Stroke Transp.",
		TextStrokeColor3 = "Stroke Color",
		TextSize = "Text Size",
		MaxVisibleGraphemes = "Typewriter",
		BorderColor3 = "Border Color",
		BorderSizePixel = "Border Size",
		GroupTransparency = "Group Transp.",
	}
	
	local valueRows = {}
	for _, property in ipairs(PROPERTY_CATALOG) do
		local isColor = property:sub(-6) == "Color3"
	
		local row = create("Frame", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = sideOrder(),
		}, side)
	
		local label = create("TextLabel", {
			Size = UDim2.new(0.34, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = DISPLAY_NAMES[property] or property,
			TextColor3 = C.text,
			Font = BRAND.Font,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
	
		local box = create("TextBox", {
			Position = UDim2.fromScale(0.34, 0),
			Size = UDim2.new(0.66, isColor and -24 or 0, 1, 0),
			BackgroundColor3 = C.row,
			BorderSizePixel = 0,
			Text = "",
			TextColor3 = C.text,
			Font = BRAND.Font,
			TextSize = 13,
			ClearTextOnFocus = false,
		}, row)
		corner(box)
	
		local swatch = nil
		if isColor then
			swatch = create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromOffset(20, 20),
				BorderSizePixel = 0,
			}, row)
			corner(swatch)
		end
	
		valueRows[property] = { row = row, label = label, box = box, swatch = swatch }
	
		box.FocusLost:Connect(function()
			A.commitText(property)
		end)
	end
	
	sideHeader("SELECTED KEYFRAME")
	
	local Insp = {}
	
	local timeRow = create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		LayoutOrder = sideOrder(),
	}, side)
	create("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Time (s)",
		TextColor3 = C.text,
		Font = BRAND.Font,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, timeRow)
	Insp.timeBox = create("TextBox", {
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(0.5, 1),
		BackgroundColor3 = C.row,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "-",
		TextColor3 = C.text,
		Font = BRAND.Font,
		TextSize = 13,
		ClearTextOnFocus = false,
	}, timeRow)
	corner(Insp.timeBox)
	
	Insp.btnStyle = sideButton("Style: -")
	Insp.btnDirection = sideButton("Direction: -")
	Insp.btnApplyEasing = sideButton("Apply easing to all")
	Insp.btnDuplicate = sideButton("Duplicate keyframe")
	Insp.btnDelete = sideButton("Delete keyframe", C.danger)
	
	sideHeader("EVENTS ON SELECTED KEYFRAME")
	
	Insp.eventsFrame = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = sideOrder(),
	}, side)
	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, Insp.eventsFrame)
	
	Insp.btnAddEvent = sideButton("+ Add event to selected keyframe", C.event)
	Insp.btnAddEvent.TextColor3 = Color3.new(1, 1, 1)
	tip(Insp.btnAddEvent, "Adds an event to the selected keyframe. Use the top + Event button to add one at the playhead.")
	
	Insp.btnPreset = sideButton("+ Event from preset...", C.event)
	Insp.btnPreset.TextColor3 = Color3.new(1, 1, 1)
	tip(Insp.btnPreset, "Ready-made events (PlaySound, Damage, CameraShake...) with typed parameters.")
	
	sideHeader("ALL EVENTS IN ANIMATION (click to jump)")
	Insp.overviewFrame = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = sideOrder(),
	}, side)
	create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, Insp.overviewFrame)
	
	create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		Text = 'Each event has typed parameters (Text, Number, Bool, Vec2, Color). Use "+ Param" for a row, or type name=value pairs in the quick box and press Enter, e.g. damage=10, sound="hit", crit=true. ON/OFF mutes an event without deleting it; "..." has presets, duplicate, move, copy and paste.',
		TextColor3 = C.textDim,
		Font = BRAND.Font,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = sideOrder(),
	}, side)
	
	local HELP_TEXT = table.concat({
		"<b>TIMELINE (MOUSE)</b>",
		"  Click / drag the ruler or lane       move the playhead",
		"  Double-click the lane                add a keyframe",
		"  Drag a keyframe / event marker       change its time",
		"  Right-click the lane                 timeline menu",
		"  Right-click a keyframe / marker      keyframe menu",
		"  Mouse wheel                          scroll the timeline",
		"",
		"<b>KEYBOARD (click the Designer window first)</b>",
		"  Space          play / pause",
		"  K              add / update keyframe at the playhead",
		"  E              add event at the playhead",
		"  L              toggle loop",
		"  F              open / close the Effects panel",
		"  Home / End     go to start / end",
		"  Left / Right   step the playhead (snap size)",
		"  Shift+Left/Right   previous / next keyframe",
		"  Delete         delete the selected keyframe",
		"  Ctrl+Z / Ctrl+Y    undo / redo",
		"  Ctrl+C / X / V     copy / cut / paste keyframe",
		"  Ctrl+D         duplicate keyframe",
		"  Esc            close menu / help",
		"",
		"<b>EVENTS</b>",
		"  + Event      add an event at the playhead",
		"  ON/OFF       mute the event (not exported)",
		"  >            test (logs the event)",
		"  ...          presets, duplicate, move, copy, paste",
		"",
		"<b>EFFECTS PANEL</b>",
		"  Pick an effect (double-click applies), tune duration / amount / easing,",
		"  choose where to place it (playhead, start or after the last keyframe) and Apply.",
		"  Replay re-plays the last effect, Undo reverts it. Effects stack on the same timeline.",
	}, "\n")
	
	local helpOverlay = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(14, 14, 17),
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		Visible = false,
		Active = true,
		ZIndex = 200,
	}, mainBg)
	create("TextLabel", {
		Position = UDim2.fromOffset(20, 12),
		Size = UDim2.new(1, -150, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		RichText = true,
		Text = HELP_TEXT,
		TextColor3 = C.text,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 201,
	}, helpOverlay)
	
	local helpClose = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 12),
		Size = UDim2.fromOffset(90, 28),
		BackgroundColor3 = C.blue,
		BorderSizePixel = 0,
		Text = "Close",
		TextColor3 = Color3.new(1, 1, 1),
		Font = BRAND.FontBold,
		TextSize = 14,
		Visible = false,
		ZIndex = 210,
	}, mainBg)
	corner(helpClose, 5)
	
	function A.toggleHelp(force)
		local visible = force
		if visible == nil then
			visible = not helpOverlay.Visible
		end
		helpOverlay.Visible = visible
		helpClose.Visible = visible
	end
	
	helpClose.MouseButton1Click:Connect(function()
		A.toggleHelp(false)
	end)
	
	local MENU_SEPARATOR = { separator = true }
	
	local function menuItem(text, run, checked)
		return { text = (checked == nil and "" or (checked and "*  " or "    ")) .. text, run = run }
	end
	
	do
		local MENU_W, ROW_H, SEP_H = 240, 24, 7
	
		local layer = create("TextButton", {
			Name = "MenuLayer",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Active = true,
			Visible = false,
			ZIndex = 300,
		}, mainBg)
	
		local panel = create("ScrollingFrame", {
			Size = UDim2.fromOffset(MENU_W, 100),
			BackgroundColor3 = C.bar,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 4,
			Active = true,
			ZIndex = 301,
		}, layer)
		corner(panel, 5)
		create("UIStroke", { Color = C.gray, Thickness = 1 }, panel)
		padding(panel, 3, 3, 3, 3)
		create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, panel)
	
		local stack = {}
		local anchor = Vector2.new(20, 20)
		local render
	
		local function close()
			layer.Visible = false
			stack = {}
		end
	
		local function push(items)
			table.insert(stack, items)
			render()
		end
	
		local function pop()
			table.remove(stack)
			render()
		end
	
		render = function()
			for _, child in ipairs(panel:GetChildren()) do
				if child:IsA("GuiObject") then
					child:Destroy()
				end
			end
	
			local items = stack[#stack]
			if not items then
				close()
				return
			end
	
			local order, height = 0, 6
	
			local function addRow(text, color, onClick)
				order += 1
				height += ROW_H + 2
				local button = create("TextButton", {
					Size = UDim2.new(1, 0, 0, ROW_H),
					BackgroundColor3 = color,
					BorderSizePixel = 0,
					Text = text,
					TextColor3 = C.text,
					Font = BRAND.Font,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					AutoButtonColor = true,
					LayoutOrder = order,
					ZIndex = 302,
				}, panel)
				corner(button)
				padding(button, 8, 8, 0, 0)
				button.MouseButton1Click:Connect(onClick)
			end
	
			if #stack > 1 then
				addRow("<  Back", C.gray, pop)
			end
	
			for _, item in ipairs(items) do
				if item.separator then
					order += 1
					height += SEP_H + 2
					local sep = create("Frame", {
						Size = UDim2.new(1, 0, 0, SEP_H),
						BackgroundTransparency = 1,
						LayoutOrder = order,
						ZIndex = 302,
					}, panel)
					create("Frame", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(1, 0, 0, 1),
						BackgroundColor3 = C.gray,
						BackgroundTransparency = 0.4,
						BorderSizePixel = 0,
						ZIndex = 303,
					}, sep)
				elseif item.sub then
					addRow(item.text .. "   >", C.row, function()
						push(item.sub)
					end)
				else
					addRow(item.text, C.row, function()
						close()
						task.defer(function()
							local ok, err = pcall(item.run)
							if not ok then
								warn(PREFIX .. "Menu action error: " .. tostring(err))
								notify("Menu action failed: " .. tostring(err), "error")
							end
						end)
					end)
				end
			end
	
			local bounds = mainBg.AbsoluteSize
			local h = math.min(height, math.max(bounds.Y - 8, 60))
			panel.Size = UDim2.fromOffset(MENU_W, h)
			panel.CanvasPosition = Vector2.new(0, 0)
			panel.Position = UDim2.fromOffset(
				math.clamp(anchor.X, 4, math.max(4, bounds.X - MENU_W - 4)),
				math.clamp(anchor.Y, 4, math.max(4, bounds.Y - h - 4))
			)
		end
	
		layer.MouseButton1Click:Connect(close)
		layer.MouseButton2Click:Connect(close)
		pluginGui.WindowFocusReleased:Connect(close)
	
		function A.openMenu(items, position)
			anchor = position or Vector2.new(20, 20)
			stack = { items }
			layer.Visible = true
			render()
		end
	
		function A.closeMenu()
			close()
		end
	
		function A.isMenuOpen()
			return layer.Visible
		end
	end
	

	R.propertyButtons = propertyButtons
	R.valueRows = valueRows
	R.Insp = Insp
	R.MENU_SEPARATOR = MENU_SEPARATOR
	R.menuItem = menuItem

end
