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
	local Windows = R.Windows
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

	local function makeWindow(id, title, width, height)
		local gui = plugin:CreateDockWidgetPluginGui(
			id,
			DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, width, height, 340, 300)
		)
		gui.Title = title
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
		local frame = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = C.bg,
			BorderSizePixel = 0,
		}, gui)
		padding(frame, 10, 10, 10, 10)
		return gui, frame
	end
	
	local function windowLabel(parent, text, y, height, extra)
		local label = create("TextLabel", {
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.textDim,
			Font = BRAND.FontBold,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, parent)
		for property, value in pairs(extra or {}) do
			label[property] = value
		end
		return label
	end
	
	local function windowButton(parent, text, color, position, size)
		local button = create("TextButton", {
			Position = position,
			Size = size,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			Font = BRAND.FontBold,
			TextSize = 14,
			AutoButtonColor = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, parent)
		corner(button, 5)
		return button
	end
	
	local function windowBox(parent, placeholder, position, size, multiline)
		local box = create("TextBox", {
			Position = position,
			Size = size,
			BackgroundColor3 = C.row,
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = placeholder,
			PlaceholderColor3 = C.textDim,
			TextColor3 = C.text,
			Font = multiline and Enum.Font.Code or BRAND.Font,
			TextSize = multiline and 12 or 15,
			ClearTextOnFocus = false,
			MultiLine = multiline == true,
			TextWrapped = multiline == true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		}, parent)
		corner(box)
		padding(box, 8, 8, multiline and 6 or 0, 0)
		return box
	end
	
	local function setMessage(label, text, kind)
		label.Text = text or ""
		label.TextColor3 = kind == "error" and C.red or (kind == "ok" and C.green or C.textDim)
	end
	
	local function createList(parent, position, size)
		local list = create("ScrollingFrame", {
			Position = position,
			Size = size,
			BackgroundColor3 = C.lane,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 6,
		}, parent)
		create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, list)
		padding(list, 4, 4, 4, 4)
		create("TextLabel", {
			Name = "Empty",
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Text = "No saved animations yet.",
			TextColor3 = C.textDim,
			Font = BRAND.Font,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = -1,
		}, list)
		return list
	end
	
	local function fillList(list, entries, selectedName, onPick)
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		list.Empty.Visible = #entries == 0
	
		for index, entry in ipairs(entries) do
			local active = entry.name == selectedName
			local row = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = active and C.selected or C.row,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = true,
				LayoutOrder = index,
			}, list)
			corner(row)
			create("TextLabel", {
				Position = UDim2.fromOffset(8, 3),
				Size = UDim2.new(1, -16, 0, 17),
				BackgroundTransparency = 1,
				Text = entry.name,
				TextColor3 = active and C.keySel or C.text,
				Font = BRAND.FontBold,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)
			create("TextLabel", {
				Position = UDim2.fromOffset(8, 20),
				Size = UDim2.new(1, -16, 0, 15),
				BackgroundTransparency = 1,
				Text = string.format(
					"%d keyframe(s)  |  %d event(s)  |  %.2fs  |  %s",
					entry.keyframes,
					entry.events,
					entry.duration,
					entry.target
				),
				TextColor3 = C.textDim,
				Font = BRAND.Font,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)
	
			row.MouseButton1Click:Connect(function()
				onPick(entry)
			end)
		end
	end
	
	local function buildSaveWindow()
		local saveGui, saveFrame = makeWindow("SynapseUiDesignerSave", "Synapse UI Designer - Save Animation", 380, 420)
	
		windowLabel(saveFrame, "SAVE ANIMATION", 0, 18)
		local saveInfo = windowLabel(saveFrame, "", 22, 34, { Font = BRAND.Font, TextColor3 = C.text })
		local saveBox = windowBox(saveFrame, "Animation name...", UDim2.fromOffset(0, 62), UDim2.new(1, 0, 0, 30))
		local saveAction = windowButton(saveFrame, "Save", C.green, UDim2.fromOffset(0, 98), UDim2.new(1, 0, 0, 30))
		local saveMessage = windowLabel(saveFrame, "", 134, 34, { Font = BRAND.Font })
		windowLabel(saveFrame, "SAVED ANIMATIONS (click one to overwrite it)", 172, 18)
		local saveList = createList(saveFrame, UDim2.fromOffset(0, 192), UDim2.new(1, 0, 1, -192))
	
		local function refreshSaveWindow()
			if State.target then
				saveInfo.Text = string.format(
					"Object: %s  |  %d keyframe(s)  |  %d event(s)  |  %.2fs",
					State.target.Name,
					#State.keyframes,
					countEvents(),
					getDuration()
				)
			else
				saveInfo.Text = "No UI linked. Link a UI before saving."
			end
	
			local name = Library.cleanName(saveBox.Text)
			local existing = name and Library.find(name)
			saveAction.Text = existing and ('Overwrite "' .. name .. '"') or "Save"
			saveAction.BackgroundColor3 = existing and C.orange or C.green
	
			fillList(saveList, Library.list(), name, function(entry)
				saveBox.Text = entry.name
			end)
		end
	
		local function doSave()
			local name = Library.cleanName(saveBox.Text)
			local existing = name and Library.find(name)
			local ok, result, replaced = Library.save(saveBox.Text, existing ~= nil)
			if ok then
				local savedName = result.Name
				saveBox.Text = savedName
				setMessage(
					saveMessage,
					string.format('%s "%s"  ->  %s', replaced and "Overwritten" or "Saved", savedName, result:GetFullName()),
					"ok"
				)
				notify((replaced and "Overwritten: " or "Saved: ") .. result:GetFullName(), "ok")
	
				print("========================================")
				print("SYNAPSE UI DESIGNER - " .. (replaced and "OVERWRITTEN" or "SAVED"))
				print(result:GetFullName())
				print("")
				print('local Animation = require(ReplicatedStorage.UIAnimations["' .. savedName .. '"])')
				print("local anim = Animation.new(script.Parent)")
				print("anim:Play()")
				if countEvents() > 0 then
					print("anim.EventFired:Connect(function(name, params, time) print(name, params) end)")
				end
				print("========================================")
			else
				setMessage(saveMessage, result, "error")
			end
			refreshSaveWindow()
		end
	
		saveAction.MouseButton1Click:Connect(doSave)
	
		saveBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				doSave()
			end
		end)
	
		saveBox:GetPropertyChangedSignal("Text"):Connect(function()
			if saveGui.Enabled then
				refreshSaveWindow()
			end
		end)
	
		saveGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if saveGui.Enabled then
				refreshSaveWindow()
			end
		end)
	
		function Windows.openSave()
			if State.target and Library.cleanName(saveBox.Text) == nil then
				saveBox.Text = State.target.Name
			end
			saveGui.Enabled = true
			refreshSaveWindow()
		end
	end
	
	local function buildImportWindow()
		local importGui, importFrame =
			makeWindow("SynapseUiDesignerImport", "Synapse UI Designer - Import Animation", 380, 580)
	
		local importMode = "replace"
		local importSelected = nil
		local deleteToken = 0
	
		windowLabel(importFrame, "IMPORT INTO TIMELINE", 0, 18)
		local importInfo = windowLabel(importFrame, "", 22, 30, { Font = BRAND.Font, TextColor3 = C.text })
		windowLabel(importFrame, "SAVED ANIMATIONS (click to select)", 56, 18)
		local importList = createList(importFrame, UDim2.fromOffset(0, 76), UDim2.new(1, 0, 0, 170))
		local btnMode = windowButton(importFrame, "", C.gray, UDim2.fromOffset(0, 254), UDim2.new(1, 0, 0, 28))
		local btnImportSelected =
			windowButton(importFrame, "Import selected", C.green, UDim2.fromOffset(0, 288), UDim2.new(0.5, -3, 0, 30))
		local btnDeleteSelected =
			windowButton(importFrame, "Delete", C.danger, UDim2.new(0.5, 3, 0, 288), UDim2.new(0.5, -3, 0, 30))
		local importMessage = windowLabel(importFrame, "", 324, 44, { Font = BRAND.Font })
		windowLabel(importFrame, "JSON  (export a saved animation, or paste JSON and import it)", 372, 18)
		local jsonBox = windowBox(importFrame, "{ ... }", UDim2.fromOffset(0, 392), UDim2.new(1, 0, 1, -428), true)
		local btnExportJson = windowButton(
			importFrame,
			"Export selected to box",
			C.purple,
			UDim2.new(0, 0, 1, -30),
			UDim2.new(0.5, -3, 0, 30)
		)
		local btnImportJson = windowButton(
			importFrame,
			"Import JSON from box",
			C.blue,
			UDim2.new(0.5, 3, 1, -30),
			UDim2.new(0.5, -3, 0, 30)
		)
	
		local function updateModeButton()
			if importMode == "replace" then
				btnMode.Text = "Mode: replace the timeline"
				btnMode.BackgroundColor3 = C.gray
			else
				btnMode.Text = "Mode: add at the playhead (merge)"
				btnMode.BackgroundColor3 = C.blue
			end
		end
	
		local refreshImportWindow
		refreshImportWindow = function()
			if State.target then
				importInfo.Text = string.format(
					"Object: %s  |  playhead %.2fs  |  %d keyframe(s) in timeline",
					State.target.Name,
					State.time,
					#State.keyframes
				)
			else
				importInfo.Text = "No UI linked. Link a UI before importing."
			end
	
			local entries = Library.list()
			if importSelected then
				local stillExists = false
				for _, entry in ipairs(entries) do
					if entry.name == importSelected then
						stillExists = true
						break
					end
				end
				if not stillExists then
					importSelected = nil
				end
			end
	
			updateModeButton()
			fillList(importList, entries, importSelected, function(entry)
				importSelected = entry.name
				refreshImportWindow()
			end)
		end
	
		btnMode.MouseButton1Click:Connect(function()
			importMode = importMode == "replace" and "append" or "replace"
			updateModeButton()
		end)
	
		btnImportSelected.MouseButton1Click:Connect(function()
			if not importSelected then
				setMessage(importMessage, "Select an animation from the list first.", "error")
				return
			end
			local ok, message = Library.import(importSelected, importMode)
			setMessage(importMessage, message, ok and "ok" or "error")
			refreshImportWindow()
		end)
	
		btnDeleteSelected.MouseButton1Click:Connect(function()
			if not importSelected then
				setMessage(importMessage, "Select an animation from the list first.", "error")
				return
			end
	
			if deleteToken == 0 then
				local token = os.clock()
				deleteToken = token
				btnDeleteSelected.Text = "Click again to confirm"
				task.delay(3, function()
					if deleteToken == token then
						deleteToken = 0
						btnDeleteSelected.Text = "Delete"
					end
				end)
				return
			end
	
			deleteToken = 0
			btnDeleteSelected.Text = "Delete"
	
			local name = importSelected
			local ok, message = Library.delete(name)
			if ok then
				importSelected = nil
				setMessage(importMessage, 'Deleted "' .. name .. '".', "ok")
			else
				setMessage(importMessage, message, "error")
			end
			refreshImportWindow()
		end)
	
		btnExportJson.MouseButton1Click:Connect(function()
			if not importSelected then
				setMessage(importMessage, "Select an animation from the list first.", "error")
				return
			end
			local json, err = Library.exportJson(importSelected)
			if json then
				jsonBox.Text = json
				setMessage(importMessage, "Animation JSON exported to the text box.", "ok")
			else
				setMessage(importMessage, err, "error")
			end
		end)
	
		btnImportJson.MouseButton1Click:Connect(function()
			if jsonBox.Text:gsub("%s", "") == "" then
				setMessage(importMessage, "Paste the animation JSON in the box first.", "error")
				return
			end
			local ok, message = Library.importJson(jsonBox.Text, importMode)
			setMessage(importMessage, message, ok and "ok" or "error")
			refreshImportWindow()
		end)
	
		importGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if importGui.Enabled then
				refreshImportWindow()
			end
		end)
	
		function Windows.openImport()
			importGui.Enabled = true
			refreshImportWindow()
		end
	end
	
	local function buildEffectsWindow()
		local S, D = Enum.EasingStyle, Enum.EasingDirection
		local TRANSP = {
			"BackgroundTransparency",
			"TextTransparency",
			"ImageTransparency",
			"GroupTransparency",
			"TextStrokeTransparency",
		}
		local SIZE_OR_FADE = { "Size", "BackgroundTransparency", "TextTransparency", "ImageTransparency", "GroupTransparency" }
		local POS_OR_FADE = { "Position", "BackgroundTransparency", "TextTransparency", "ImageTransparency", "GroupTransparency" }
		local CAT_COLORS = {
			Entrance = C.green,
			Exit = C.red,
			Attention = C.orange,
			Text = C.blue,
			Color = C.purple,
			Loop = C.teal,
		}
		local CATEGORIES = { "All", "Recent", "Entrance", "Exit", "Attention", "Text", "Color", "Loop" }
		local EFFECTS = {}
		local BY_ID = {}
	
		local function has(property)
			return State.target ~= nil and hasProperty(State.target, property)
		end
	
		local function makeContext(t, d, amount, styleOverride, dirOverride)
			local c = { t = t, d = d, amount = amount, touched = 0 }
	
			function c.base(property)
				local value = evaluateProperty(property, t)
				if value == nil then
					value = State.target[property]
				end
				return value
			end
	
			function c.st(default)
				return styleOverride or default
			end
	
			function c.di(default)
				return dirOverride or default
			end
	
			function c.key(time, property, value, style, direction)
				time = roundTo(time, 4)
				local keyframe = keyframeAt(time)
				if not keyframe then
					keyframe = makeKeyframe(time, {}, DEFAULT_STYLE, DEFAULT_DIRECTION)
					table.insert(State.keyframes, keyframe)
				end
				keyframe.Properties[property] = value
				if style then
					keyframe.Style = style
				end
				if direction then
					keyframe.Direction = direction
				end
				State.enabledProps[property] = true
				c.touched += 1
				return keyframe
			end
	
			function c.hold(property, value)
				if t <= 0.0005 then
					return
				end
				for _, keyframe in ipairs(State.keyframes) do
					if keyframe.Time < t - 0.0005 and keyframe.Properties[property] ~= nil then
						return
					end
				end
				c.key(0, property, value, S.Linear, D.In)
			end
	
			function c.enter(property, from, to, style, direction)
				c.hold(property, from)
				c.key(t, property, from, style, direction)
				c.key(t + d, property, to)
			end
	
			function c.exit(property, from, to, style, direction)
				c.key(t, property, from, style, direction)
				c.key(t + d, property, to)
			end
	
			return c
		end
	
		local function scaleSize(v, k)
			return UDim2.new(v.X.Scale * k, v.X.Offset * k, v.Y.Scale * k, v.Y.Offset * k)
		end
	
		local function scaleXY(v, sx, sy)
			return UDim2.new(v.X.Scale * sx, v.X.Offset * sx, v.Y.Scale * sy, v.Y.Offset * sy)
		end
	
		local function shift(v, sx, sy, ox, oy)
			return UDim2.new(v.X.Scale + sx, v.X.Offset + (ox or 0), v.Y.Scale + sy, v.Y.Offset + (oy or 0))
		end
	
		local function fadeProps(c, fadingIn, only)
			local list = {}
			for _, property in ipairs(only or TRANSP) do
				if has(property) then
					local current = c.base(property)
					local design = baseline[property] or current
					if fadingIn then
						if design < 0.99 then
							table.insert(list, { property, current < 0.99 and current or design })
						end
					elseif current < 0.99 then
						table.insert(list, { property, current })
					end
				end
			end
			return list
		end
	
		local function colorProps(c)
			local list = {}
			if has("TextColor3") then
				table.insert(list, "TextColor3")
			end
			if has("ImageColor3") then
				table.insert(list, "ImageColor3")
			end
			if has("BackgroundColor3") and (not has("BackgroundTransparency") or c.base("BackgroundTransparency") < 0.99) then
				table.insert(list, "BackgroundColor3")
			end
			return list
		end
	
		local function def(id, name, cat, desc, duration, amount, amountLabel, needs, run, loops)
			local fx = {
				id = id,
				name = name,
				cat = cat,
				desc = desc,
				duration = duration,
				amount = amount,
				amountLabel = amountLabel,
				needs = needs,
				run = run,
				loops = loops == true,
			}
			table.insert(EFFECTS, fx)
			BY_ID[id] = fx
		end
	
		def("fadeIn", "Fade In", "Entrance", "Appears smoothly from transparent.", 0.4, nil, nil, TRANSP, function(c)
			for _, entry in ipairs(fadeProps(c, true)) do
				c.enter(entry[1], 1, entry[2], c.st(S.Quad), c.di(D.Out))
			end
		end)
	
		local function slide(id, name, sx, sy, entering)
			def(
				id,
				name,
				entering and "Entrance" or "Exit",
				entering and "Glides in from the edge of the screen." or "Glides out to the edge of the screen.",
				0.5,
				60,
				"Distance (% of the screen)",
				{ "Position" },
				function(c)
					local base = c.base("Position")
					local k = c.amount / 100
					local offset = shift(base, sx * k, sy * k)
					if entering then
						c.enter("Position", offset, base, c.st(S.Quart), c.di(D.Out))
					else
						c.exit("Position", base, offset, c.st(S.Quart), c.di(D.In))
					end
				end
			)
		end
		slide("slideInLeft", "Slide In Left", -1, 0, true)
		slide("slideInRight", "Slide In Right", 1, 0, true)
		slide("slideInTop", "Slide In Top", 0, -1, true)
		slide("slideInBottom", "Slide In Bottom", 0, 1, true)
	
		def("popIn", "Pop In", "Entrance", "Grows from nothing with a small overshoot.", 0.45, nil, nil, { "Size" }, function(c)
			local base = c.base("Size")
			c.enter("Size", scaleSize(base, 0), base, c.st(S.Back), c.di(D.Out))
		end)
	
		def("bounceIn", "Bounce In", "Entrance", "Grows from nothing and bounces into place.", 0.7, nil, nil, { "Size" }, function(c)
			local base = c.base("Size")
			c.enter("Size", scaleSize(base, 0), base, c.st(S.Bounce), c.di(D.Out))
		end)
	
		def("elasticIn", "Elastic Pop", "Entrance", "Springy growth, like rubber.", 0.9, nil, nil, { "Size" }, function(c)
			local base = c.base("Size")
			c.enter("Size", scaleSize(base, 0), base, c.st(S.Elastic), c.di(D.Out))
		end)
	
		def("zoomIn", "Zoom In", "Entrance", "Starts bigger and fades in while settling.", 0.5, 40, "Start size (% larger)", SIZE_OR_FADE, function(c)
			if has("Size") then
				local base = c.base("Size")
				c.enter("Size", scaleSize(base, 1 + c.amount / 100), base, c.st(S.Quad), c.di(D.Out))
			end
			for _, entry in ipairs(fadeProps(c, true)) do
				c.enter(entry[1], 1, entry[2], c.st(S.Quad), c.di(D.Out))
			end
		end)
	
		def("riseIn", "Rise In", "Entrance", "Floats up a little while fading in.", 0.5, 30, "Distance (pixels)", POS_OR_FADE, function(c)
			if has("Position") then
				local base = c.base("Position")
				c.enter("Position", shift(base, 0, 0, 0, c.amount), base, c.st(S.Quart), c.di(D.Out))
			end
			for _, entry in ipairs(fadeProps(c, true)) do
				c.enter(entry[1], 1, entry[2], c.st(S.Quart), c.di(D.Out))
			end
		end)
	
		def("dropIn", "Drop In", "Entrance", "Falls from above and bounces.", 0.8, 200, "Height (pixels)", { "Position" }, function(c)
			local base = c.base("Position")
			c.enter("Position", shift(base, 0, 0, 0, -c.amount), base, c.st(S.Bounce), c.di(D.Out))
		end)
	
		def("fadeOut", "Fade Out", "Exit", "Disappears smoothly.", 0.4, nil, nil, TRANSP, function(c)
			for _, entry in ipairs(fadeProps(c, false)) do
				c.exit(entry[1], entry[2], 1, c.st(S.Quad), c.di(D.In))
			end
		end)
		slide("slideOutLeft", "Slide Out Left", -1, 0, false)
		slide("slideOutRight", "Slide Out Right", 1, 0, false)
		slide("slideOutTop", "Slide Out Top", 0, -1, false)
		slide("slideOutBottom", "Slide Out Bottom", 0, 1, false)
	
		def("popOut", "Pop Out", "Exit", "Shrinks to nothing.", 0.35, nil, nil, { "Size" }, function(c)
			local base = c.base("Size")
			c.exit("Size", base, scaleSize(base, 0), c.st(S.Back), c.di(D.In))
		end)
	
		def("zoomOut", "Zoom Out", "Exit", "Shrinks and fades away.", 0.4, 40, "Shrink (%)", SIZE_OR_FADE, function(c)
			if has("Size") then
				local base = c.base("Size")
				c.exit("Size", base, scaleSize(base, math.max(0, 1 - c.amount / 100)), c.st(S.Quad), c.di(D.In))
			end
			for _, entry in ipairs(fadeProps(c, false)) do
				c.exit(entry[1], entry[2], 1, c.st(S.Quad), c.di(D.In))
			end
		end)
	
		def("fallOut", "Fall Out", "Exit", "Drops down while fading out.", 0.6, 120, "Distance (pixels)", POS_OR_FADE, function(c)
			if has("Position") then
				local base = c.base("Position")
				c.exit("Position", base, shift(base, 0, 0, 0, c.amount), c.st(S.Quad), c.di(D.In))
			end
			for _, entry in ipairs(fadeProps(c, false)) do
				c.exit(entry[1], entry[2], 1, c.st(S.Quad), c.di(D.In))
			end
		end)
	
		def("pulse", "Pulse", "Attention", "Quick grow and return.", 0.4, 15, "Grow (%)", { "Size" }, function(c)
			local base = c.base("Size")
			local peak = scaleSize(base, 1 + c.amount / 100)
			c.key(c.t, "Size", base, c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d / 2, "Size", peak, c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d, "Size", base)
		end)
	
		def("heartbeat", "Heartbeat", "Attention", "Double beat, like a pulse.", 1, 15, "Beat strength (%)", { "Size" }, function(c)
			local base = c.base("Size")
			local a = c.amount / 100
			local times = { 0, 0.15, 0.3, 0.45, 1 }
			local scales = { 1, 1 + a, 1, 1 + a * 0.7, 1 }
			for i, f in ipairs(times) do
				c.key(c.t + c.d * f, "Size", scaleSize(base, scales[i]), c.st(S.Sine), c.di(D.InOut))
			end
		end)
	
		def("wiggle", "Wiggle", "Attention", "Quick rotation back and forth.", 0.6, 12, "Angle (degrees)", { "Rotation" }, function(c)
			local r = c.base("Rotation")
			local steps = { 0, 1, -1, 0.6, -0.6, 0 }
			for i, v in ipairs(steps) do
				c.key(c.t + c.d * (i - 1) / (#steps - 1), "Rotation", r + v * c.amount, c.st(S.Sine), c.di(D.InOut))
			end
		end)
	
		def("tada", "Tada", "Attention", "Shrinks, then grows and wobbles.", 0.9, 10, "Wobble (degrees)", { "Size", "Rotation" }, function(c)
			local size = has("Size") and c.base("Size") or nil
			local r = has("Rotation") and c.base("Rotation") or nil
			local times = { 0, 0.1, 0.3, 0.5, 0.7, 0.9, 1 }
			local scales = { 1, 0.9, 1.1, 1.1, 1.1, 1.1, 1 }
			local rots = { 0, -3, 3, -3, 3, -3, 0 }
			for i, f in ipairs(times) do
				if size then
					c.key(c.t + c.d * f, "Size", scaleSize(size, scales[i]), S.Sine, D.InOut)
				end
				if r then
					c.key(c.t + c.d * f, "Rotation", r + rots[i] * c.amount / 3, S.Sine, D.InOut)
				end
			end
		end)
	
		def("shake", "Shake", "Attention", "Fast random shaking that fades out.", 0.4, 8, "Strength (pixels)", { "Position" }, function(c)
			local base = c.base("Position")
			local steps = math.clamp(math.floor(c.d / 0.04), 2, 60)
			for i = 0, steps do
				local f = i / steps
				local decay = 1 - f
				local value = base
				if i > 0 and i < steps then
					value = shift(
						base,
						0,
						0,
						(math.random() * 2 - 1) * c.amount * decay,
						(math.random() * 2 - 1) * c.amount * decay
					)
				end
				c.key(c.t + c.d * f, "Position", value, S.Linear, D.In)
			end
		end)
	
		def("jelly", "Jelly", "Attention", "Squash and stretch like jelly.", 0.7, 25, "Squash (%)", { "Size" }, function(c)
			local base = c.base("Size")
			local a = c.amount / 100
			local times = { 0, 0.25, 0.5, 0.75, 1 }
			local sx = { 1, 1 + a, 1 - a * 0.6, 1 + a * 0.3, 1 }
			local sy = { 1, 1 - a * 0.7, 1 + a * 0.5, 1 - a * 0.2, 1 }
			for i, f in ipairs(times) do
				c.key(c.t + c.d * f, "Size", scaleXY(base, sx[i], sy[i]), c.st(S.Sine), c.di(D.InOut))
			end
		end)
	
		def("hop", "Hop", "Attention", "Jumps up and lands with a bounce.", 0.7, 40, "Height (pixels)", { "Position" }, function(c)
			local base = c.base("Position")
			c.key(c.t, "Position", base, c.st(S.Quad), c.di(D.Out))
			c.key(c.t + c.d * 0.4, "Position", shift(base, 0, 0, 0, -c.amount), S.Bounce, D.Out)
			c.key(c.t + c.d, "Position", base)
		end)
	
		def("blink", "Blink", "Attention", "Blinks on and off three times.", 0.6, nil, nil, TRANSP, function(c)
			local list = fadeProps(c, false)
			for _, entry in ipairs(list) do
				for i = 0, 6 do
					local value = i % 2 == 0 and entry[2] or 1
					c.key(c.t + c.d * i / 6, entry[1], value, S.Linear, D.In)
				end
			end
		end)
	
		def("spin", "Spin", "Attention", "Spins around.", 0.8, 360, "Angle (degrees)", { "Rotation" }, function(c)
			local r = c.base("Rotation")
			c.key(c.t, "Rotation", r, c.st(S.Quad), c.di(D.InOut))
			c.key(c.t + c.d, "Rotation", r + c.amount)
		end)
	
		def("typewriter", "Typewriter", "Text", "Reveals the text one character at a time.", 1.5, nil, nil, { "MaxVisibleGraphemes" }, function(c)
			if not has("Text") then
				return false, "This object has no text."
			end
			local length = utf8.len(State.target.Text) or #State.target.Text
			c.enter("MaxVisibleGraphemes", 0, length, c.st(S.Linear), c.di(D.In))
		end)
	
		def("typewriterOut", "Erase Text", "Text", "Deletes the text one character at a time.", 1, nil, nil, { "MaxVisibleGraphemes" }, function(c)
			if not has("Text") then
				return false, "This object has no text."
			end
			local length = utf8.len(State.target.Text) or #State.target.Text
			c.exit("MaxVisibleGraphemes", length, 0, c.st(S.Linear), c.di(D.In))
		end)
	
		def("textFadeIn", "Text Fade In", "Text", "Only the text fades in.", 0.5, nil, nil, { "TextTransparency" }, function(c)
			for _, entry in ipairs(fadeProps(c, true, { "TextTransparency", "TextStrokeTransparency" })) do
				c.enter(entry[1], 1, entry[2], c.st(S.Quad), c.di(D.Out))
			end
		end)
	
		def("textFadeOut", "Text Fade Out", "Text", "Only the text fades out.", 0.5, nil, nil, { "TextTransparency" }, function(c)
			for _, entry in ipairs(fadeProps(c, false, { "TextTransparency", "TextStrokeTransparency" })) do
				c.exit(entry[1], entry[2], 1, c.st(S.Quad), c.di(D.In))
			end
		end)
	
		def("textPop", "Text Pop", "Text", "The text size jumps and returns.", 0.4, 30, "Grow (%)", { "TextSize" }, function(c)
			local base = c.base("TextSize")
			c.key(c.t, "TextSize", base, c.st(S.Quad), c.di(D.Out))
			c.key(c.t + c.d / 2, "TextSize", math.round(base * (1 + c.amount / 100)), c.st(S.Quad), c.di(D.In))
			c.key(c.t + c.d, "TextSize", base)
		end)
	
		local function colorFlash(id, name, desc, target, amountDefault)
			def(id, name, "Color", desc, 0.5, amountDefault, "Intensity (%)", { "TextColor3", "ImageColor3", "BackgroundColor3" }, function(c)
				for _, property in ipairs(colorProps(c)) do
					local base = c.base(property)
					local mixed = base:Lerp(target, math.clamp(c.amount / 100, 0, 1))
					c.key(c.t, property, base, c.st(S.Quad), c.di(D.Out))
					c.key(c.t + c.d * 0.3, property, mixed, c.st(S.Quad), c.di(D.In))
					c.key(c.t + c.d, property, base)
				end
			end)
		end
		colorFlash("flashWhite", "Flash White", "Flashes to white and back.", Color3.new(1, 1, 1), 80)
		colorFlash("tintRed", "Tint Red", "Flashes red (damage / error feedback).", Color3.fromRGB(255, 60, 60), 70)
		colorFlash("tintGold", "Tint Gold", "Flashes gold (reward / highlight).", Color3.fromRGB(255, 205, 40), 70)
		colorFlash("tintGreen", "Tint Green", "Flashes green (success feedback).", Color3.fromRGB(60, 220, 110), 70)
	
		def("hueCycle", "Hue Cycle", "Color", "Cycles through the colors of the rainbow.", 2, nil, nil, { "TextColor3", "ImageColor3", "BackgroundColor3" }, function(c)
			for _, property in ipairs(colorProps(c)) do
				local base = c.base(property)
				local h, s, v = base:ToHSV()
				s, v = math.max(s, 0.6), math.max(v, 0.8)
				for i = 0, 5 do
					local value = i == 5 and base or Color3.fromHSV((h + i / 5) % 1, s, v)
					c.key(c.t + c.d * i / 5, property, value, S.Linear, D.In)
				end
			end
		end)
	
		def("float", "Float", "Loop", "Gently floats up and down (enables Loop).", 1.6, 10, "Height (pixels)", { "Position" }, function(c)
			local base = c.base("Position")
			c.key(c.t, "Position", base, c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d / 2, "Position", shift(base, 0, 0, 0, -c.amount), c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d, "Position", base)
		end, true)
	
		def("sway", "Sway", "Loop", "Sways left and right (enables Loop).", 2, 6, "Angle (degrees)", { "Rotation" }, function(c)
			local r = c.base("Rotation")
			c.key(c.t, "Rotation", r, c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d * 0.25, "Rotation", r + c.amount, c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d * 0.75, "Rotation", r - c.amount, c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d, "Rotation", r)
		end, true)
	
		def("breathe", "Breathe", "Loop", "Slowly grows and shrinks (enables Loop).", 2, 5, "Grow (%)", { "Size" }, function(c)
			local base = c.base("Size")
			c.key(c.t, "Size", base, c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d / 2, "Size", scaleSize(base, 1 + c.amount / 100), c.st(S.Sine), c.di(D.InOut))
			c.key(c.t + c.d, "Size", base)
		end, true)
	
		def("glow", "Fade Pulse", "Loop", "Softly fades in and out (enables Loop).", 1.4, 50, "Fade depth (%)", TRANSP, function(c)
			for _, entry in ipairs(fadeProps(c, false)) do
				local low = entry[2] + (1 - entry[2]) * math.clamp(c.amount / 100, 0, 1)
				c.key(c.t, entry[1], entry[2], c.st(S.Sine), c.di(D.InOut))
				c.key(c.t + c.d / 2, entry[1], low, c.st(S.Sine), c.di(D.InOut))
				c.key(c.t + c.d, entry[1], entry[2])
			end
		end, true)
	
		local gui = plugin:CreateDockWidgetPluginGui(
			"SynapseUiDesignerEffects",
			DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 340, 600, 300, 400)
		)
		gui.Title = "Synapse UI Designer - Effects"
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
		local BOTTOM_H = 250
	
		local root = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = C.bg,
			BorderSizePixel = 0,
		}, gui)
		padding(root, 8, 8, 8, 8)
	
		local header = create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 }, root)
		local badge = create("Frame", {
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = C.purple,
			BorderSizePixel = 0,
		}, header)
		corner(badge, 9)
		create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(28, 28),
			BackgroundTransparency = 1,
			Image = EFFECTS_ICON,
			ScaleType = Enum.ScaleType.Fit,
		}, badge)
		create("TextLabel", {
			Position = UDim2.fromOffset(46, 0),
			Size = UDim2.new(1, -46, 0, 22),
			BackgroundTransparency = 1,
			Text = "Effects",
			TextColor3 = C.text,
			Font = BRAND.FontBold,
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, header)
		local subtitle = create("TextLabel", {
			Position = UDim2.fromOffset(46, 22),
			Size = UDim2.new(1, -46, 0, 16),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = C.textDim,
			Font = BRAND.Font,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, header)
	
		local searchBox = create("TextBox", {
			Position = UDim2.fromOffset(0, 46),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = C.row,
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Search effects...",
			PlaceholderColor3 = C.textDim,
			TextColor3 = C.text,
			Font = BRAND.Font,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
		}, root)
		corner(searchBox)
		padding(searchBox, 8, 8, 0, 0)
	
		local tabs = create("ScrollingFrame", {
			Position = UDim2.fromOffset(0, 78),
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			ScrollingDirection = Enum.ScrollingDirection.X,
			ScrollBarThickness = 0,
		}, root)
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 4),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, tabs)
	
		local grid = create("ScrollingFrame", {
			Position = UDim2.fromOffset(0, 112),
			Size = UDim2.new(1, 0, 1, -112 - BOTTOM_H - 6),
			BackgroundColor3 = C.lane,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 6,
		}, root)
		padding(grid, 5, 5, 5, 5)
		create("UIGridLayout", {
			CellSize = UDim2.new(0.5, -3, 0, 46),
			CellPadding = UDim2.fromOffset(6, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, grid)
	
		local bottom = create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, BOTTOM_H),
			BackgroundTransparency = 1,
		}, root)
	
		local info = create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundTransparency = 1,
			RichText = true,
			Text = "",
			TextColor3 = C.text,
			Font = BRAND.Font,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, bottom)
	
		local function fieldBox(xScale, y, labelText)
			create("TextLabel", {
				Position = UDim2.new(xScale, 0, 0, y),
				Size = UDim2.new(0.2, 0, 0, 24),
				BackgroundTransparency = 1,
				Text = labelText,
				TextColor3 = C.text,
				Font = BRAND.Font,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, bottom)
			local box = create("TextBox", {
				Position = UDim2.new(xScale + 0.2, 0, 0, y),
				Size = UDim2.new(0.3, -6, 0, 24),
				BackgroundColor3 = C.row,
				BorderSizePixel = 0,
				Text = "",
				TextColor3 = C.text,
				PlaceholderColor3 = C.textDim,
				Font = BRAND.Font,
				TextSize = 13,
				ClearTextOnFocus = false,
			}, bottom)
			corner(box)
			return box
		end
	
		local function halfButton(xScale, y, text, color)
			local button = create("TextButton", {
				Position = UDim2.new(xScale, xScale > 0 and 3 or 0, 0, y),
				Size = UDim2.new(0.5, -3, 0, 24),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Text = text,
				TextColor3 = Color3.new(1, 1, 1),
				Font = BRAND.FontBold,
				TextSize = 13,
				AutoButtonColor = true,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, bottom)
			corner(button)
			return button
		end
	
		local durationBox = fieldBox(0, 48, "Duration")
		local amountBox = fieldBox(0.5, 48, "Amount")
		local styleButton = halfButton(0, 78, "Style: Auto", C.row)
		local dirButton = halfButton(0.5, 78, "Direction: Auto", C.row)
		local placeButton = halfButton(0, 108, "At: Playhead", C.row)
		local previewButton = halfButton(0.5, 108, "", C.blue)
		local markerButton = halfButton(0, 138, "", C.gray)
	
		local applyButton = create("TextButton", {
			Position = UDim2.fromOffset(0, 172),
			Size = UDim2.new(0.5, -3, 0, 34),
			BackgroundColor3 = C.green,
			BorderSizePixel = 0,
			Text = "Apply effect",
			TextColor3 = Color3.new(1, 1, 1),
			Font = BRAND.FontBold,
			TextSize = 15,
			AutoButtonColor = true,
		}, bottom)
		corner(applyButton, 5)
		local replayButton = create("TextButton", {
			Position = UDim2.new(0.5, 3, 0, 172),
			Size = UDim2.new(0.25, -3, 0, 34),
			BackgroundColor3 = C.blue,
			BorderSizePixel = 0,
			Text = "Replay",
			TextColor3 = Color3.new(1, 1, 1),
			Font = BRAND.FontBold,
			TextSize = 14,
			AutoButtonColor = true,
		}, bottom)
		corner(replayButton, 5)
		local undoButton = create("TextButton", {
			Position = UDim2.new(0.75, 3, 0, 172),
			Size = UDim2.new(0.25, -3, 0, 34),
			BackgroundColor3 = C.gray,
			BorderSizePixel = 0,
			Text = "Undo",
			TextColor3 = Color3.new(1, 1, 1),
			Font = BRAND.FontBold,
			TextSize = 14,
			AutoButtonColor = true,
		}, bottom)
		corner(undoButton, 5)
	
		local status = create("TextLabel", {
			Position = UDim2.fromOffset(0, 212),
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			Text = "Pick an effect. Double-click a card to apply it.",
			TextColor3 = C.textDim,
			Font = BRAND.Font,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, bottom)
	
		local function setStatus(text, kind)
			status.Text = text or ""
			status.TextColor3 = kind == "error" and Color3.fromRGB(255, 120, 130) or (kind == "ok" and C.green or C.textDim)
		end
	
		local selected = EFFECTS[1]
		local currentCat = "All"
		local styleIndex, dirIndex = 0, 0
		local lastRange = nil
		local cardClick = { id = nil, at = 0 }
		local tabButtons = {}
		local rebuildCards
	
		local function isAvailable(fx)
			if not State.target then
				return false
			end
			for _, property in ipairs(fx.needs) do
				if hasProperty(State.target, property) then
					return true
				end
			end
			return false
		end
	
		local function placeTime()
			if State.fx.place == "start" then
				return 0
			elseif State.fx.place == "end" then
				return getDuration()
			end
			return State.time
		end
	
		local function refreshControls()
			styleButton.Text = "Style: " .. (styleIndex == 0 and "Auto" or STYLES[styleIndex].Name)
			dirButton.Text = "Direction: " .. (dirIndex == 0 and "Auto" or DIRECTIONS[dirIndex].Name)
	
			if State.fx.place == "start" then
				placeButton.Text = "At: Start (0s)"
			elseif State.fx.place == "end" then
				placeButton.Text = "At: After last key"
			else
				placeButton.Text = "At: Playhead"
			end
	
			previewButton.Text = "Auto-preview: " .. (State.fx.autoPreview and "on" or "off")
			previewButton.BackgroundColor3 = State.fx.autoPreview and C.blue or C.gray
			markerButton.Text = "Event marker: " .. (State.fx.eventMarker and "on" or "off")
			markerButton.BackgroundColor3 = State.fx.eventMarker and C.event or C.gray
	
			replayButton.TextTransparency = lastRange and 0 or 0.55
			undoButton.TextTransparency = #State.undo > 0 and 0 or 0.55
	
			subtitle.Text = State.target and ("Target: " .. State.target.Name .. "  (" .. State.target.ClassName .. ")")
				or "No UI linked yet"
		end
	
		local function selectEffect(fx)
			selected = fx
			durationBox.Text = tostring(fx.duration)
			if fx.amount then
				amountBox.Text = tostring(fx.amount)
				amountBox.TextEditable = true
				amountBox.TextTransparency = 0
				amountBox.PlaceholderText = ""
			else
				amountBox.Text = ""
				amountBox.TextEditable = false
				amountBox.PlaceholderText = "-"
			end
	
			local color = CAT_COLORS[fx.cat] or C.text
			info.Text = string.format(
				'<b><font color="#%s">%s</font></b>  <font color="#969699">(%s)</font>\n%s%s',
				color:ToHex(),
				fx.name,
				fx.cat,
				fx.desc,
				fx.amountLabel and ("  <i>Amount: " .. fx.amountLabel .. "</i>") or ""
			)
	
			if isAvailable(fx) then
				setStatus("Ready. Place: " .. placeButton.Text:gsub("At: ", "") .. ".")
			elseif State.target then
				setStatus("This object has none of the properties this effect needs.", "error")
			else
				setStatus("Link a UI first (use the Object window or Link UI).", "error")
			end
			rebuildCards()
		end
	
		local function pushRecent(id)
			local recent = State.fx.recent
			local index = table.find(recent, id)
			if index then
				table.remove(recent, index)
			end
			table.insert(recent, 1, id)
			while #recent > 8 do
				table.remove(recent)
			end
		end
	
		local function applyEffect()
			local fx = selected
			if not State.target then
				setStatus("Link a UI first.", "error")
				notify("Link a UI first.", "error")
				return
			end
			if not isAvailable(fx) then
				setStatus("This object has none of the properties this effect needs.", "error")
				return
			end
	
			local duration = tonumber(durationBox.Text)
			if not duration or not isFiniteNumber(duration) or duration < 0.05 or duration > 60 then
				setStatus("Duration must be between 0.05 and 60 seconds.", "error")
				return
			end
	
			local amount = 0
			if fx.amount then
				amount = tonumber(amountBox.Text)
				if not amount or not isFiniteNumber(amount) then
					setStatus("Amount must be a number.", "error")
					return
				end
			end
	
			local t = roundTo(placeTime(), 4)
			if t + duration > MAX_ANIMATION_TIME then
				setStatus("The effect would go past 3,600 seconds.", "error")
				return
			end
	
			stopPlayback()
			local backup = encodeKeyframes(State.keyframes)
			local backupProps = table.clone(State.enabledProps)
			local backupSelected = State.selected
			pushUndo()
	
			local context = makeContext(
				t,
				duration,
				amount,
				styleIndex > 0 and STYLES[styleIndex] or nil,
				dirIndex > 0 and DIRECTIONS[dirIndex] or nil
			)
			local ok, result, message = pcall(fx.run, context)
	
			local failure = nil
			if not ok then
				failure = tostring(result)
			elseif result == false then
				failure = message or "Could not apply the effect."
			elseif context.touched == 0 then
				failure = "This object has none of the properties this effect needs."
			elseif #State.keyframes > MAX_IMPORT_KEYFRAMES then
				failure = "The animation would exceed 1,000 keyframes."
			end
	
			if failure then
				State.keyframes = decodeKeyframes(backup)
				State.enabledProps = backupProps
				State.selected = backupSelected and State.keyframes[table.find(State.keyframes, backupSelected) or 0] or nil
				table.remove(State.undo)
				A.updateHistoryButtons()
				setStatus(failure, "error")
				notify(failure, "error")
				return
			end
	
			sortKeyframes()
	
			if State.fx.eventMarker and countEvents() < MAX_IMPORT_EVENTS then
				local keyframe = keyframeAt(t)
				if keyframe then
					table.insert(
						keyframe.Events,
						EV.new((fx.name:gsub("%s", "")), { duration = roundTo(duration, 3) })
					)
				end
			end
	
			if fx.loops and not State.loop then
				State.loop = true
				A.updateToggleButtons()
			end
	
			State.selected = keyframeAt(t)
			State.selectedEvent = nil
			lastRange = { t, t + duration }
			pushRecent(fx.id)
			A.saveSettings()
	
			A.refreshProperties()
			A.setTime(t)
			afterEdit()
			refreshControls()
			rebuildCards()
	
			setStatus(string.format("%s applied at %.2fs (%.2fs long).", fx.name, t, duration), "ok")
			notify(fx.name .. " applied.", "ok")
	
			if State.fx.autoPreview and #State.keyframes >= 2 then
				A.playRange(t, t + duration)
			end
		end
	
		rebuildCards = function()
			for _, child in ipairs(grid:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
	
			local query = searchBox.Text:lower()
			local list = {}
			if currentCat == "Recent" then
				for _, id in ipairs(State.fx.recent) do
					if BY_ID[id] then
						table.insert(list, BY_ID[id])
					end
				end
			else
				for _, fx in ipairs(EFFECTS) do
					if currentCat == "All" or fx.cat == currentCat then
						table.insert(list, fx)
					end
				end
			end
	
			local shown = 0
			for _, fx in ipairs(list) do
				if
					query == ""
					or fx.name:lower():find(query, 1, true)
					or fx.cat:lower():find(query, 1, true)
					or fx.desc:lower():find(query, 1, true)
				then
					shown += 1
					local available = isAvailable(fx)
					local card = create("TextButton", {
						BackgroundColor3 = fx == selected and C.selected or C.row,
						BorderSizePixel = 0,
						Text = "",
						AutoButtonColor = true,
						LayoutOrder = shown,
					}, grid)
					corner(card)
					local bar = create("Frame", {
						Size = UDim2.new(0, 4, 1, 0),
						BackgroundColor3 = CAT_COLORS[fx.cat] or C.gray,
						BackgroundTransparency = available and 0 or 0.6,
						BorderSizePixel = 0,
					}, card)
					corner(bar, 2)
					create("TextLabel", {
						Position = UDim2.fromOffset(12, 5),
						Size = UDim2.new(1, -16, 0, 20),
						BackgroundTransparency = 1,
						Text = fx.name,
						TextColor3 = available and C.text or C.textDim,
						Font = BRAND.FontBold,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
					}, card)
					create("TextLabel", {
						Position = UDim2.fromOffset(12, 25),
						Size = UDim2.new(1, -16, 0, 16),
						BackgroundTransparency = 1,
						Text = fx.cat .. (fx.loops and "  -  loop" or "") .. (available and "" or "  -  n/a"),
						TextColor3 = C.textDim,
						Font = BRAND.Font,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
					}, card)
	
					card.MouseButton1Click:Connect(function()
						local now = os.clock()
						local doubleClick = cardClick.id == fx.id and now - cardClick.at < 0.35
						cardClick.id, cardClick.at = fx.id, now
						if selected ~= fx then
							selectEffect(fx)
						end
						if doubleClick then
							cardClick.id = nil
							applyEffect()
						end
					end)
				end
			end
	
			if shown == 0 then
	
				local empty = create("TextButton", {
					BackgroundTransparency = 1,
					Text = currentCat == "Recent" and "No recent effects yet." or "No effects match.",
					TextColor3 = C.textDim,
					Font = BRAND.Font,
					TextSize = 13,
					AutoButtonColor = false,
				}, grid)
				empty.Active = false
			end
		end
	
		local function refreshTabs()
			for name, button in pairs(tabButtons) do
				local active = name == currentCat
				button.BackgroundColor3 = active and C.purple or C.row
				button.TextColor3 = active and Color3.new(1, 1, 1) or C.text
			end
		end
	
		for index, name in ipairs(CATEGORIES) do
			local button = create("TextButton", {
				Size = UDim2.fromOffset(0, 24),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = C.row,
				BorderSizePixel = 0,
				Text = name,
				TextColor3 = C.text,
				Font = BRAND.FontBold,
				TextSize = 13,
				LayoutOrder = index,
			}, tabs)
			corner(button, 12)
			padding(button, 10, 10, 0, 0)
			tabButtons[name] = button
			button.MouseButton1Click:Connect(function()
				currentCat = name
				refreshTabs()
				rebuildCards()
			end)
		end
	
		searchBox:GetPropertyChangedSignal("Text"):Connect(rebuildCards)
	
		styleButton.MouseButton1Click:Connect(function()
			styleIndex = (styleIndex + 1) % (#STYLES + 1)
			refreshControls()
		end)
		dirButton.MouseButton1Click:Connect(function()
			dirIndex = (dirIndex + 1) % (#DIRECTIONS + 1)
			refreshControls()
		end)
		placeButton.MouseButton1Click:Connect(function()
			local order = { "playhead", "start", "end" }
			local current = table.find(order, State.fx.place) or 1
			State.fx.place = order[current % #order + 1]
			A.saveSettings()
			refreshControls()
		end)
		previewButton.MouseButton1Click:Connect(function()
			State.fx.autoPreview = not State.fx.autoPreview
			A.saveSettings()
			refreshControls()
		end)
		markerButton.MouseButton1Click:Connect(function()
			State.fx.eventMarker = not State.fx.eventMarker
			A.saveSettings()
			refreshControls()
		end)
	
		applyButton.MouseButton1Click:Connect(applyEffect)
		replayButton.MouseButton1Click:Connect(function()
			if lastRange then
				A.playRange(lastRange[1], lastRange[2])
			else
				setStatus("Apply an effect first.", "error")
			end
		end)
		undoButton.MouseButton1Click:Connect(function()
			A.undo()
			refreshControls()
		end)
	
		table.insert(A.linkListeners, function()
			lastRange = nil
			refreshControls()
			selectEffect(selected)
		end)
		A.onHistoryChanged = refreshControls
	
		function A.toggleEffects(force)
			local visible = force
			if visible == nil then
				visible = not gui.Enabled
			end
			gui.Enabled = visible
		end
	
		refreshTabs()
		refreshControls()
		selectEffect(selected)
	
		return gui
	end
	

	R.buildSaveWindow = buildSaveWindow
	R.buildImportWindow = buildImportWindow
	R.buildEffectsWindow = buildEffectsWindow

end
