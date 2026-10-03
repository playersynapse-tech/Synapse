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
	local buildEffectsWindow = R.buildEffectsWindow
	local buildImportWindow = R.buildImportWindow
	local buildModuleSource = R.buildModuleSource
	local buildSaveWindow = R.buildSaveWindow
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

	local function linkSelection()
		local selected = Selection:Get()[1]
		if selected and selected:IsA("GuiObject") then
			linkTarget(selected)
		else
			notify("Select a GuiObject in the Explorer.", "error")
		end
	end
	
	local function buildObjectsWindow()
		local STAGE_NAME = "SynapseUiStage"
		local OBJECT_TYPES = { "Frame", "TextLabel", "TextButton", "TextBox", "ImageLabel", "ImageButton", "CanvasGroup" }
	
		local TEXT_STYLE = {
			TextSize = 28,
			Font = BRAND.FontBold,
			TextColor3 = Color3.new(1, 1, 1),
		}
	
		local OBJECT_DEFAULTS = {
			Frame = { Size = UDim2.fromOffset(200, 120), BackgroundColor3 = Color3.fromRGB(0, 120, 215) },
			TextLabel = {
				Size = UDim2.fromOffset(260, 60),
				Text = "TextLabel",
				BackgroundColor3 = Color3.fromRGB(30, 30, 34),
			},
			TextButton = {
				Size = UDim2.fromOffset(220, 60),
				Text = "TextButton",
				BackgroundColor3 = Color3.fromRGB(0, 120, 215),
			},
			TextBox = {
				Size = UDim2.fromOffset(260, 60),
				Text = "TextBox",
				BackgroundColor3 = Color3.fromRGB(30, 30, 34),
				ClearTextOnFocus = false,
			},
			ImageLabel = { Size = UDim2.fromOffset(150, 150), BackgroundColor3 = Color3.fromRGB(30, 30, 34) },
			ImageButton = { Size = UDim2.fromOffset(150, 150), BackgroundColor3 = Color3.fromRGB(30, 30, 34) },
			CanvasGroup = { Size = UDim2.fromOffset(240, 160), BackgroundColor3 = Color3.fromRGB(60, 60, 66) },
		}
	
		local function getStage(make)
			local stage = StarterGui:FindFirstChild(STAGE_NAME)
			if not stage and make then
				stage = Instance.new("ScreenGui")
				stage.Name = STAGE_NAME
				stage.ResetOnSpawn = false
				stage.IgnoreGuiInset = true
				stage.Parent = StarterGui
			end
			return stage
		end
	
		local function uniqueName(parent, base)
			if not parent:FindFirstChild(base) then
				return base
			end
			local index = 2
			while parent:FindFirstChild(base .. index) do
				index += 1
			end
			return base .. index
		end
	
		local function createStageObject(className)
			local stage = getStage(true)
			local object = Instance.new(className)
	
			object.AnchorPoint = Vector2.new(0.5, 0.5)
			object.Position = UDim2.fromScale(0.5, 0.5)
			object.BorderSizePixel = 0
	
			if className:find("Text") then
				for property, value in pairs(TEXT_STYLE) do
					pcall(function()
						object[property] = value
					end)
				end
			end
			for property, value in pairs(OBJECT_DEFAULTS[className] or {}) do
				pcall(function()
					object[property] = value
				end)
			end
	
			object.Name = uniqueName(stage, className)
			object.Parent = stage
	
			ChangeHistoryService:SetWaypoint("Create " .. className .. " (Synapse UI Designer)")
			Selection:Set({ object })
			linkTarget(object)
		end
	
		local objectsGui = plugin:CreateDockWidgetPluginGui(
			"SynapseUiDesignerObjects",
			DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, true, false, 260, 420, 220, 260)
		)
		objectsGui.Title = "Synapse UI Designer - Object"
		objectsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
		local objRoot = create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = C.bg,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 6,
		}, objectsGui)
	
		padding(objRoot, 8, 8, 8, 8)
		create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, objRoot)
	
		local objOrder = orderer()
	
		local objHeaderBar = create("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			LayoutOrder = objOrder(),
		}, objRoot)
		create("ImageLabel", {
			Name = "Logo",
			Size = UDim2.fromOffset(34, 34),
			BackgroundTransparency = 1,
			Image = LOGO_IMAGE,
			ScaleType = Enum.ScaleType.Fit,
		}, objHeaderBar)
		create("TextLabel", {
			Position = UDim2.fromOffset(40, 0),
			Size = UDim2.new(1, -40, 1, 0),
			BackgroundTransparency = 1,
			Text = "Synapse UI Designer",
			TextColor3 = C.text,
			Font = BRAND.FontBold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, objHeaderBar)
	
		local function objHeader(text)
			create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = C.textDim,
				Font = BRAND.FontBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = objOrder(),
			}, objRoot)
		end
	
		local function objButton(text, color, parent)
			local button = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = color or C.row,
				BorderSizePixel = 0,
				Text = text,
				TextColor3 = C.text,
				Font = BRAND.FontBold,
				TextSize = 13,
				LayoutOrder = objOrder(),
			}, parent or objRoot)
			corner(button)
			return button
		end
	
		local function objLabeledBox(label)
			local row = create("Frame", {
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundTransparency = 1,
				Visible = false,
				LayoutOrder = objOrder(),
			}, objRoot)
			create("TextLabel", {
				Size = UDim2.new(0.25, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = label,
				TextColor3 = C.text,
				Font = BRAND.Font,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			local box = create("TextBox", {
				Position = UDim2.fromScale(0.25, 0),
				Size = UDim2.fromScale(0.75, 1),
				BackgroundColor3 = C.row,
				BorderSizePixel = 0,
				Text = "",
				TextColor3 = C.text,
				Font = BRAND.Font,
				TextSize = 13,
				ClearTextOnFocus = false,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)
			corner(box)
			return row, box
		end
	
		local fxButton = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = C.purple,
			BorderSizePixel = 0,
			Text = "Open Effects panel",
			TextColor3 = Color3.new(1, 1, 1),
			Font = BRAND.FontBold,
			TextSize = 14,
			LayoutOrder = objOrder(),
		}, objRoot)
		corner(fxButton, 5)
		padding(fxButton, 26, 0, 0, 0)
		create("ImageLabel", {
			Position = UDim2.new(0, -20, 0.5, -9),
			Size = UDim2.fromOffset(18, 18),
			BackgroundTransparency = 1,
			Image = EFFECTS_ICON,
			ScaleType = Enum.ScaleType.Fit,
		}, fxButton)
		fxButton.MouseButton1Click:Connect(function()
			A.toggleEffects(true)
		end)
	
		objHeader("CREATE OBJECT (goes to StarterGui)")
	
		local grid = create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = objOrder(),
		}, objRoot)
		create("UIGridLayout", {
			CellSize = UDim2.new(0.5, -3, 0, 26),
			CellPadding = UDim2.fromOffset(6, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, grid)
	
		for _, className in ipairs(OBJECT_TYPES) do
			local button = objButton(className, C.row, grid)
			button.MouseButton1Click:Connect(function()
				createStageObject(className)
			end)
		end
	
		objHeader("CURRENT OBJECT")
	
		local currentLabel = create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = C.text,
			Font = BRAND.Font,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = objOrder(),
		}, objRoot)
	
		local nameRow, nameBox = objLabeledBox("Name")
		local textRow, textBox = objLabeledBox("Text")
	
		local btnLinkSelected = objButton("Link selection from Explorer", C.blue)
		local btnSelectCurrent = objButton("Select in Explorer", C.row)
		local btnDuplicateObject = objButton("Duplicate object (with animation)", C.row)
		local btnDeleteObject = objButton("Delete object", C.danger)
	
		objHeader("OBJECTS ON STAGE (click to animate)")
	
		local listFrame = create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = objOrder(),
		}, objRoot)
		create("UIListLayout", {
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, listFrame)
	
		local emptyLabel = create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = "No objects on stage yet.",
			TextColor3 = C.textDim,
			Font = BRAND.Font,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = -1,
		}, listFrame)
	
		create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundTransparency = 1,
			Text = "Only 1 object is animated at a time. Keyframes and events are saved on each object.",
			TextColor3 = C.textDim,
			Font = BRAND.Font,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = objOrder(),
		}, objRoot)
	
		local function refreshObjects()
			local target = State.target
	
			if target then
				local id = target:GetAttribute(ID_ATTRIBUTE)
				currentLabel.Text = string.format(
					"Animating: %s (%s)%s",
					target.Name,
					target.ClassName,
					type(id) == "string" and ("\nID: " .. id) or ""
				)
			else
				currentLabel.Text = "No object linked. Create one above or link one from the Explorer."
			end
	
			nameRow.Visible = target ~= nil
			if target and not nameBox:IsFocused() then
				nameBox.Text = target.Name
			end
	
			local hasText = target ~= nil and hasProperty(target, "Text")
			textRow.Visible = hasText
			if hasText and not textBox:IsFocused() then
				textBox.Text = target.Text
			end
	
			for _, child in ipairs(listFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
	
			local count = 0
			local stage = getStage(false)
			if stage then
				for _, object in ipairs(stage:GetChildren()) do
					if object:IsA("GuiObject") then
						count += 1
						local active = object == target
	
						local row = create("TextButton", {
							Size = UDim2.new(1, 0, 0, 24),
							BackgroundColor3 = active and C.selected or C.row,
							BorderSizePixel = 0,
							Text = string.format("%s  [%s]", object.Name, object.ClassName),
							TextColor3 = active and C.keySel or C.text,
							Font = BRAND.Font,
							TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							LayoutOrder = count,
						}, listFrame)
						corner(row)
						padding(row, 8, 8, 0, 0)
	
						row.MouseButton1Click:Connect(function()
							Selection:Set({ object })
							linkTarget(object)
						end)
					end
				end
			end
	
			emptyLabel.Visible = count == 0
		end
	
		table.insert(A.linkListeners, refreshObjects)
	
		A.onTextChanged = function()
			local target = State.target
			if target and hasProperty(target, "Text") and not textBox:IsFocused() and textBox.Text ~= target.Text then
				textBox.Text = target.Text
			end
		end
	
		nameBox.FocusLost:Connect(function()
			local target = State.target
			if target and nameBox.Text ~= "" then
				target.Name = nameBox.Text
				A.updateStatus()
			end
			refreshObjects()
		end)
	
		textBox.FocusLost:Connect(function()
			local target = State.target
			if target and hasProperty(target, "Text") then
				target.Text = textBox.Text
				ChangeHistoryService:SetWaypoint("Edit text (Synapse UI Designer)")
			end
			refreshObjects()
		end)
	
		btnLinkSelected.MouseButton1Click:Connect(linkSelection)
	
		btnSelectCurrent.MouseButton1Click:Connect(function()
			if State.target then
				Selection:Set({ State.target })
			end
		end)
	
		btnDuplicateObject.MouseButton1Click:Connect(function()
			local target = State.target
			local stage = getStage(false)
			if not target or not stage or not target:IsDescendantOf(stage) then
				notify("Only objects created on the stage can be duplicated.", "error")
				return
			end
	
			saveToTarget()
			local clone = target:Clone()
			clone:SetAttribute(ID_ATTRIBUTE, nil)
			clone.Name = uniqueName(stage, target.Name)
			clone.Parent = stage
	
			ChangeHistoryService:SetWaypoint("Duplicate object (Synapse UI Designer)")
			Selection:Set({ clone })
			linkTarget(clone)
		end)
	
		btnDeleteObject.MouseButton1Click:Connect(function()
			local target = State.target
			if not target then
				return
			end
	
			local stage = getStage(false)
			if not stage or not target:IsDescendantOf(stage) then
				notify("Only objects created on the stage can be deleted (" .. STAGE_NAME .. ").", "error")
				return
			end
	
			ChangeHistoryService:SetWaypoint("Before deleting object (Synapse UI Designer)")
			unlinkTarget()
			target:Destroy()
			ChangeHistoryService:SetWaypoint("Delete object (Synapse UI Designer)")
			refreshObjects()
		end)
	
		local stageConnections = {}
	
		local function bindStage()
			for _, connection in ipairs(stageConnections) do
				connection:Disconnect()
			end
			table.clear(stageConnections)
	
			local stage = getStage(false)
			if stage then
				table.insert(stageConnections, stage.ChildAdded:Connect(function()
					task.defer(refreshObjects)
				end))
				table.insert(stageConnections, stage.ChildRemoved:Connect(function()
					task.defer(refreshObjects)
				end))
			end
	
			refreshObjects()
		end
	
		StarterGui.ChildAdded:Connect(function(child)
			if child.Name == STAGE_NAME then
				bindStage()
			end
		end)
	
		StarterGui.ChildRemoved:Connect(function(child)
			if child.Name == STAGE_NAME then
				task.defer(bindStage)
			end
		end)
	
		plugin.Unloading:Connect(function()
			for _, connection in ipairs(stageConnections) do
				connection:Disconnect()
			end
		end)
	
		bindStage()
		return objectsGui
	end
	
	Btn.link.MouseButton1Click:Connect(linkSelection)
	Btn.key.MouseButton1Click:Connect(A.recordKeyframe)
	Btn.event.MouseButton1Click:Connect(function()
		A.addEventAt(State.time)
	end)
	Btn.effects.MouseButton1Click:Connect(function()
		A.toggleEffects()
	end)
	
	Btn.home.MouseButton1Click:Connect(A.goToStart)
	Btn.play.MouseButton1Click:Connect(A.togglePlay)
	
	Btn.loop.MouseButton1Click:Connect(function()
		State.loop = not State.loop
		A.updateToggleButtons()
		A.scheduleSave()
	end)
	
	Btn.auto.MouseButton1Click:Connect(function()
		State.autoKey = not State.autoKey
		A.updateToggleButtons()
		A.saveSettings()
	end)
	
	Btn.snap.MouseButton1Click:Connect(function()
		setSnap(cycleNumber(SNAP_STEPS, State.snap))
	end)
	
	Btn.speed.MouseButton1Click:Connect(function()
		State.speed = cycleNumber(SPEEDS, State.speed)
		A.updateToggleButtons()
		A.saveSettings()
	end)
	
	Btn.log.MouseButton1Click:Connect(function()
		State.logEvents = not State.logEvents
		A.updateToggleButtons()
		A.saveSettings()
	end)
	
	Btn.zoomIn.MouseButton1Click:Connect(function()
		setZoom(State.pxPerSec * 1.25)
	end)
	Btn.zoomOut.MouseButton1Click:Connect(function()
		setZoom(State.pxPerSec / 1.25)
	end)
	Btn.fit.MouseButton1Click:Connect(A.fitZoom)
	
	Btn.undo.MouseButton1Click:Connect(A.undo)
	Btn.redo.MouseButton1Click:Connect(A.redo)
	
	Btn.save.MouseButton1Click:Connect(function()
		if type(Windows.openSave) == "function" then
			Windows.openSave()
		else
			notify("The Save window is unavailable.", "error")
		end
	end)
	Btn.import.MouseButton1Click:Connect(function()
		if type(Windows.openImport) == "function" then
			Windows.openImport()
		else
			notify("The Import window is unavailable.", "error")
		end
	end)
	Btn.help.MouseButton1Click:Connect(function()
		A.toggleHelp()
	end)
	
	Btn.clear.MouseButton1Click:Connect(function()
		if not State.target or #State.keyframes == 0 then
			return
		end
	
		pushUndo()
		stopPlayback()
		restoreBaseline()
	
		State.keyframes = {}
		State.selected = nil
		State.selectedEvent = nil
		State.time = 0
	
		pcall(function()
			State.target:SetAttribute(ATTRIBUTE_NAME, nil)
		end)
	
		afterEdit()
		notify("Timeline cleared. Use the Undo button to restore it.", "ok")
	end)
	
	Insp.timeBox.FocusLost:Connect(function()
		local keyframe = State.selected
		local value = tonumber(Insp.timeBox.Text)
	
		if keyframe and value then
			if not isFiniteNumber(value) or value < 0 or value > MAX_ANIMATION_TIME then
				notify("Keyframe time must be between 0 and 3,600 seconds.", "error")
			else
				local clash = keyframeAt(value)
				if clash and clash ~= keyframe then
					notify("There is already a keyframe at that time.", "error")
				elseif math.abs(value - keyframe.Time) > 0.0001 then
					pushUndo()
					keyframe.Time = value
					sortKeyframes()
					A.setTime(keyframe.Time)
					A.rebuildTimeline()
					A.scheduleSave()
				end
			end
		end
	
		A.refreshInspector()
	end)
	
	Insp.btnStyle.MouseButton1Click:Connect(function()
		local keyframe = State.selected
		if not keyframe then
			notify("Select a keyframe first.", "error")
			return
		end
		A.openMenu(styleMenuItems(keyframe), anchorBelow(Insp.btnStyle))
	end)
	
	Insp.btnDirection.MouseButton1Click:Connect(function()
		local keyframe = State.selected
		if not keyframe then
			notify("Select a keyframe first.", "error")
			return
		end
		A.openMenu(directionMenuItems(keyframe), anchorBelow(Insp.btnDirection))
	end)
	
	Insp.btnApplyEasing.MouseButton1Click:Connect(function()
		A.applyEasingToAll(State.selected)
	end)
	Insp.btnDuplicate.MouseButton1Click:Connect(function()
		A.duplicateKeyframe()
	end)
	Insp.btnDelete.MouseButton1Click:Connect(function()
		A.deleteKeyframe()
	end)
	Insp.btnAddEvent.MouseButton1Click:Connect(function()
		A.addEvent(State.selected)
	end)
	Insp.btnPreset.MouseButton1Click:Connect(function()
		local keyframe = State.selected
		A.openMenu(presetMenuItems(function(preset)
			A.addEvent(keyframe, preset)
		end), anchorBelow(Insp.btnPreset))
	end)
	

	R.buildObjectsWindow = buildObjectsWindow

end
