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
	
	local MODULE_TEMPLATE = [===[
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")
	
	local Animation = {}
	Animation.__index = Animation
	
	Animation.Id = {{ID}}
	Animation.TargetName = {{TARGETNAME}}
	Animation.Duration = {{DURATION}}
	Animation.DefaultLoop = {{LOOP}}
	Animation.Name = {{ANIMNAME}}
	
	local TRACKS = {
	{{TRACKS}}
	}
	
	local EVENTS = {
	{{EVENTS}}
	}
	
	Animation.Events = EVENTS
	
	do
		local names, seen = {}, {}
		for _, event in ipairs(EVENTS) do
			if not seen[event.Name] then
				seen[event.Name] = true
				table.insert(names, event.Name)
			end
		end
		Animation.EventNames = names
	end
	
	local INTEGER = { TextSize = true, MaxVisibleGraphemes = true, BorderSizePixel = true }
	
	local function lerp(a, b, alpha)
		if typeof(a) == "number" then
			return a + (b - a) * alpha
		end
		if typeof(a) == "string" then
			return alpha < 1 and a or b
		end
		return a:Lerp(b, alpha)
	end
	
	local function evaluate(track, time)
		local previous, nextKey
	
		for _, key in ipairs(track) do
			if key.Time <= time then
				previous = key
			else
				nextKey = key
				break
			end
		end
	
		if not previous then
			return nextKey.Value
		end
		if not nextKey then
			return previous.Value
		end
	
		local span = nextKey.Time - previous.Time
		local alpha = span > 0 and (time - previous.Time) / span or 1
		alpha = math.clamp(alpha, 0, 1)
		alpha = TweenService:GetValue(alpha, previous.Style, previous.Direction)
	
		return lerp(previous.Value, nextKey.Value, alpha)
	end
	
	function Animation.GetEvents(name)
		local copy = {}
		for _, event in ipairs(EVENTS) do
			if name == nil or event.Name == name then
				table.insert(copy, { Time = event.Time, Name = event.Name, Params = table.clone(event.Params) })
			end
		end
		return copy
	end
	
	function Animation.Find(root)
		if not root then
			local player = Players.LocalPlayer
			root = player and player:WaitForChild("PlayerGui")
		end
		if not root then
			return nil
		end
		if root:GetAttribute("SynapseUiId") == Animation.Id then
			return root
		end
	
		for _, descendant in ipairs(root:GetDescendants()) do
			if descendant:GetAttribute("SynapseUiId") == Animation.Id then
				return descendant
			end
		end
	
		return root:FindFirstChild(Animation.TargetName, true)
	end
	
	function Animation.new(target)
		target = target or Animation.Find()
		assert(typeof(target) == "Instance", "Animation.new could not find the object (pass a GuiObject or check the ID).")
	
		local self = setmetatable({}, Animation)
		self.Target = target
		self.Speed = 1
		self.Loop = Animation.DefaultLoop
		self.Time = 0
		self.IsPlaying = false
		self.IsPaused = false
	
		self._completed = Instance.new("BindableEvent")
		self._looped = Instance.new("BindableEvent")
		self._eventFired = Instance.new("BindableEvent")
		self._named = {}
	
		self.Completed = self._completed.Event
		self.Looped = self._looped.Event
		self.EventFired = self._eventFired.Event
	
		return self
	end
	
	function Animation:_apply(time)
		for property, track in pairs(TRACKS) do
			pcall(function()
				local value = evaluate(track, time)
				if INTEGER[property] and type(value) == "number" then
					value = math.round(value)
				end
				self.Target[property] = value
			end)
		end
	end
	
	function Animation:GetEventSignal(name)
		local event = self._named[name]
		if not event then
			event = Instance.new("BindableEvent")
			self._named[name] = event
		end
		return event.Event
	end
	
	function Animation:OnEvent(name, callback)
		return self:GetEventSignal(name):Connect(callback)
	end
	
	function Animation:OnEvents(map)
		local connections = {}
		for name, callback in pairs(map) do
			table.insert(connections, self:OnEvent(name, callback))
		end
		return connections
	end
	
	function Animation:_fireEvents(from, to)
		for _, event in ipairs(EVENTS) do
			if event.Time > from and event.Time <= to then
				self._eventFired:Fire(event.Name, table.clone(event.Params), event.Time)
	
				local named = self._named[event.Name]
				if named then
					named:Fire(table.clone(event.Params), event.Time)
				end
			end
		end
	end
	
	function Animation:_step(dt)
		local duration = Animation.Duration
		local previous = self.Time
		local current = previous + dt * self.Speed
	
		if current >= duration then
			if self.Loop and duration > 0 then
				self:_fireEvents(previous, duration)
				current %= duration
				self.Time = current
				self:_apply(current)
				self._looped:Fire()
				self:_fireEvents(-1, current)
			else
				self.Time = duration
				self:_apply(duration)
				self:_fireEvents(previous, duration)
				self:Stop()
				self._completed:Fire()
			end
			return
		end
	
		self.Time = current
		self:_apply(current)
		self:_fireEvents(previous, current)
	end
	
	function Animation:_connect()
		self._connection = RunService.Heartbeat:Connect(function(dt)
			self:_step(dt)
		end)
		self.IsPlaying = true
		self.IsPaused = false
	end
	
	function Animation:Play(speed, loop)
		self:Stop()
	
		if speed then
			assert(type(speed) == "number" and speed > 0, "Speed must be a positive number.")
			self.Speed = speed
		end
		if loop ~= nil then
			self.Loop = loop
		end
	
		self.Time = 0
		self:_apply(0)
		self:_fireEvents(-1, 0)
	
		if Animation.Duration <= 0 then
			self._completed:Fire()
			return self
		end
	
		self:_connect()
		return self
	end
	
	function Animation:Pause()
		if self._connection then
			self._connection:Disconnect()
			self._connection = nil
			self.IsPlaying = false
			self.IsPaused = true
		end
	end
	
	function Animation:Resume()
		if self.IsPaused and not self._connection then
			self:_connect()
		end
	end
	
	function Animation:Seek(seconds, fireEvents)
		local previous = self.Time
		self.Time = math.clamp(seconds, 0, Animation.Duration)
		self:_apply(self.Time)
		if fireEvents and self.Time > previous then
			self:_fireEvents(previous, self.Time)
		end
	end
	
	function Animation:Stop()
		if self._connection then
			self._connection:Disconnect()
			self._connection = nil
		end
		self.IsPlaying = false
		self.IsPaused = false
	end
	
	function Animation:Reset()
		self:Stop()
		self.Time = 0
		self:_apply(0)
	end
	
	function Animation:Destroy()
		self:Stop()
		self._completed:Destroy()
		self._looped:Destroy()
		self._eventFired:Destroy()
		for _, event in pairs(self._named) do
			event:Destroy()
		end
		table.clear(self._named)
	end
	
	return Animation
	]===]
	
	local function buildAnimationData(animName)
		local target = State.target
		return {
			version = DATA_VERSION,
			name = animName,
			targetName = target and target.Name or nil,
			targetClass = target and target.ClassName or nil,
			loop = State.loop,
			duration = getDuration(),
			keyframes = encodeKeyframes(State.keyframes),
		}
	end
	
	local function serializeParams(params)
		local keys = {}
		for key in pairs(params) do
			table.insert(keys, key)
		end
		table.sort(keys)
	
		local parts = {}
		for _, key in ipairs(keys) do
			local literal = serializeValue(params[key])
			if literal then
				table.insert(parts, string.format("[%q] = %s", key, literal))
			end
		end
	
		return "{ " .. table.concat(parts, ", ") .. " }"
	end
	
	local function buildModuleSource(animName)
		if not State.target or #State.keyframes == 0 then
			return nil
		end
	
		local tracks = {}
	
		for _, property in ipairs(PROPERTY_CATALOG) do
			local keys = {}
			local hasZeroKey = false
	
			for _, keyframe in ipairs(State.keyframes) do
				local value = keyframe.Properties[property]
				if value ~= nil then
					if math.abs(keyframe.Time) < 0.001 then
						hasZeroKey = true
					end
					local serialized = serializeValue(value)
					if serialized then
						table.insert(
							keys,
							string.format(
								"\t\t{ Time = %s, Value = %s, Style = Enum.EasingStyle.%s, Direction = Enum.EasingDirection.%s },",
								num(keyframe.Time),
								serialized,
								keyframe.Style.Name,
								keyframe.Direction.Name
							)
						)
					end
				end
			end
	
			if not hasZeroKey and baseline[property] ~= nil and #keys > 0 then
				local serialized = serializeValue(baseline[property])
				if serialized then
					table.insert(
						keys,
						1,
						string.format(
							"\t\t{ Time = 0, Value = %s, Style = Enum.EasingStyle.%s, Direction = Enum.EasingDirection.%s },",
							serialized,
							DEFAULT_STYLE.Name,
							DEFAULT_DIRECTION.Name
						)
					)
				end
			end
	
			if #keys > 0 then
				table.insert(tracks, "\t" .. property .. " = {\n" .. table.concat(keys, "\n") .. "\n\t},")
			end
		end
	
		local events = {}
		for _, keyframe in ipairs(State.keyframes) do
			for _, event in ipairs(keyframe.Events) do
				if event.Enabled ~= false then
					table.insert(
						events,
						string.format(
							"\t{ Time = %s, Name = %q, Params = %s },",
							num(keyframe.Time),
							event.Name,
							serializeParams(event.Params)
						)
					)
				end
			end
		end
	
		local id = ensureId(State.target)
		local replacements = {
			ANIMNAME = string.format("%q", animName),
			ID = string.format("%q", id),
			TARGETNAME = string.format("%q", State.target.Name),
			DURATION = num(getDuration()),
			LOOP = tostring(State.loop),
			TRACKS = table.concat(tracks, "\n"),
			EVENTS = table.concat(events, "\n"),
		}
	
		local source = MODULE_TEMPLATE:gsub("{{(%w+)}}", function(key)
			return replacements[key]
		end)
	
		return source
	end
	
	local Library = {}
	
	local function getLibraryFolder(make)

	R.Animation = Animation
	R.buildAnimationData = buildAnimationData
	R.buildModuleSource = buildModuleSource
	R.Library = Library
	R.getLibraryFolder = getLibraryFolder

end
