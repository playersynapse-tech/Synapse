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
	local buildObjectsWindow = R.buildObjectsWindow
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

	buildSaveWindow()
	buildImportWindow()
	local objectsGui = buildObjectsWindow()
	local effectsGui = buildEffectsWindow()
	
	local function initializeToolbar()
		local toolbar = plugin:CreateToolbar("Synapse Tools")
	
		local function addToolbarButton(id, tooltip, icon, text, window)
			local button = toolbar:CreateButton(id, tooltip, icon, text)
			button.ClickableWhenViewportHidden = true
			button.Click:Connect(function()
				window.Enabled = not window.Enabled
			end)
			window:GetPropertyChangedSignal("Enabled"):Connect(function()
				button:SetActive(window.Enabled)
			end)
			button:SetActive(window.Enabled)
		end
	
		addToolbarButton("SynapseUiDesigner", "Open UI Designer", LOGO_IMAGE, "UI Designer", pluginGui)
		addToolbarButton("SynapseUiDesignerObjects", "Open UI Designer Objects", LOGO_IMAGE, "UI Objects", objectsGui)
		addToolbarButton("SynapseUiDesignerEffects", "Open the Effects panel", EFFECTS_ICON, "Effects", effectsGui)
	end
	
	initializeToolbar()
	
	plugin.Unloading:Connect(function()
		stopPlayback()
		saveToTarget()
		restoreBaseline()
		disconnectTarget()
		A.saveSettings()
	end)
	
	A.updateToggleButtons()
	A.updateHistoryButtons()
	A.refreshProperties()
	A.refreshInspector()
	A.rebuildTimeline()
	A.updateStatus()
	A.updatePlayButton()
	
end
