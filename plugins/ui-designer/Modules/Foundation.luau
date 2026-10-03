return function(R)
	local plugin = R.plugin
	local Selection = game:GetService("Selection")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local HttpService = game:GetService("HttpService")
	local ChangeHistoryService = game:GetService("ChangeHistoryService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local StarterGui = game:GetService("StarterGui")
	
	local ATTRIBUTE_NAME = "SynapseUiData"
	local ID_ATTRIBUTE = "SynapseUiId"
	local LEGACY_DATA_ATTRIBUTE = "UIAnimatorPro_Data"
	local LEGACY_ID_ATTRIBUTE = "UIAnimatorPro_Id"
	local LIBRARY_FOLDER = "UIAnimations"
	local LIBRARY_ATTRIBUTE = "SynapseUiAnimation"
	local LIBRARY_DATA_ATTRIBUTE = "SynapseUiAnimationData"
	local SETTINGS_KEY = "SynapseUiDesignerSettings_v4"
	local DATA_VERSION = 3
	local MAX_IMPORT_KEYFRAMES = 1000
	local MAX_IMPORT_EVENTS = 1000
	local MAX_ANIMATION_TIME = 3600
	local MAX_EVENT_PARAMS = 24
	local LOGO_IMAGE = "rbxassetid://136078562940326"
	local BRAND = {
		Name = "Synapse",
		Logo = LOGO_IMAGE,
		Accent = Color3.fromRGB(0, 122, 255),
		Success = Color3.fromRGB(76, 175, 80),
		Warning = Color3.fromRGB(246, 136, 0),
		Danger = Color3.fromRGB(214, 90, 60),
		Background = Color3.fromRGB(46, 46, 46),
		Surface = Color3.fromRGB(37, 37, 37),
		SurfaceAlt = Color3.fromRGB(60, 60, 60),
		Text = Color3.fromRGB(229, 229, 229),
		TextMuted = Color3.fromRGB(170, 170, 170),
		Border = Color3.fromRGB(34, 34, 34),
		Radius = 8,
		Font = Enum.Font.Gotham,
		FontMedium = Enum.Font.GothamMedium,
		FontSemibold = Enum.Font.GothamSemibold,
		FontBold = Enum.Font.GothamBold,
	}
	
	local DesignSystem = {
		Spacing = { XS = 4, SM = 8, MD = 12, LG = 16, XL = 24 },
		Size = { Header = 48, Toolbar = 36, Tab = 34, Button = 32, Input = 32, Status = 28 },
		Radius = { Small = 6, Medium = 8, Large = 10, Pill = 999 },
		Motion = {
			Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			Normal = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			Press = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			Release = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		},
		Color = {
			Background = BRAND.Background,
			Surface = BRAND.Surface,
			SurfaceAlt = BRAND.SurfaceAlt,
			Border = BRAND.Border,
			Accent = BRAND.Accent,
			Text = BRAND.Text,
			TextMuted = BRAND.TextMuted,
			Success = BRAND.Success,
			Warning = BRAND.Warning,
			Danger = BRAND.Danger,
		},
		Font = {
			Regular = BRAND.Font,
			Medium = BRAND.FontMedium,
			Semibold = BRAND.FontSemibold,
			Bold = BRAND.FontBold,
		},
	}
	
	local function applyCorner(instance: Instance, radius: number)
		local corner = instance:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius)
		corner.Parent = instance
		return corner
	end
	
	local function applyBorder(instance: Instance, color: Color3?, transparency: number?)
		local stroke = instance:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = color or DesignSystem.Color.Border
		stroke.Transparency = transparency or 0
		stroke.Parent = instance
		return stroke
	end
	
	local function styleSurface(instance: GuiObject, radius: number?)
		instance.BorderSizePixel = 0
		instance.BackgroundColor3 = DesignSystem.Color.Surface
		applyCorner(instance, radius or DesignSystem.Radius.Medium)
		applyBorder(instance)
		return instance
	end
	
	local function styleButton(instance: GuiButton, accent: boolean?)
		instance.AutoButtonColor = false
		instance.BorderSizePixel = 0
		instance.BackgroundColor3 = accent and DesignSystem.Color.Accent or DesignSystem.Color.SurfaceAlt
		instance.TextColor3 = DesignSystem.Color.Text
		instance.Font = DesignSystem.Font.Semibold
		instance.TextSize = 13
		applyCorner(instance, DesignSystem.Radius.Small)
		applyBorder(instance, accent and DesignSystem.Color.Accent or DesignSystem.Color.Border)
		local scale = instance:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = instance
		instance.MouseEnter:Connect(function()
			TweenService:Create(scale, DesignSystem.Motion.Fast, { Scale = 1.02 }):Play()
		end)
		instance.MouseLeave:Connect(function()
			TweenService:Create(scale, DesignSystem.Motion.Fast, { Scale = 1 }):Play()
		end)
		instance.MouseButton1Down:Connect(function()
			TweenService:Create(scale, DesignSystem.Motion.Press, { Scale = 0.97 }):Play()
		end)
		instance.MouseButton1Up:Connect(function()
			TweenService:Create(scale, DesignSystem.Motion.Release, { Scale = 1 }):Play()
		end)
		return instance
	end
	
	local function styleInput(instance: TextBox)
		instance.BorderSizePixel = 0
		instance.BackgroundColor3 = DesignSystem.Color.Background
		instance.TextColor3 = DesignSystem.Color.Text
		instance.PlaceholderColor3 = DesignSystem.Color.TextMuted
		instance.Font = DesignSystem.Font.Regular
		instance.TextSize = 13
		instance.ClearTextOnFocus = false
		applyCorner(instance, DesignSystem.Radius.Small)
		applyBorder(instance)
		return instance
	end
	
	local function styleTab(instance: GuiButton, active: boolean)
		instance.AutoButtonColor = false
		instance.BackgroundTransparency = 0
		instance.BackgroundColor3 = active and DesignSystem.Color.SurfaceAlt or DesignSystem.Color.Surface
		instance.TextColor3 = active and DesignSystem.Color.Text or DesignSystem.Color.TextMuted
		instance.Font = DesignSystem.Font.Semibold
		instance.TextSize = 13
		applyCorner(instance, DesignSystem.Radius.Small)
		applyBorder(instance, active and DesignSystem.Color.Accent or DesignSystem.Color.Border)
		return instance
	end
	
	local function styleHeader(instance: GuiObject)
		instance.BorderSizePixel = 0
		instance.BackgroundColor3 = DesignSystem.Color.Surface
		return instance
	end
	
	local function styleStatus(instance: GuiObject)
		instance.BorderSizePixel = 0
		instance.BackgroundColor3 = DesignSystem.Color.Surface
		return instance
	end
	
	local EFFECTS_ICON = BRAND.Logo
	local LEFT_PAD = 24
	local RULER_H = 24
	local KEY_LANE_Y = 54
	local EVENT_LANE_Y = 106
	local LANES_H = 136
	local SIDE_W = 300
	local SNAP_STEPS = { 0, 0.01, 0.05, 0.1, 0.25 }
	local MIN_ZOOM, MAX_ZOOM = 20, 1200
	local SPEEDS = { 0.25, 0.5, 1, 2, 4 }
	local DEFAULT_STYLE = Enum.EasingStyle.Quad
	local DEFAULT_DIRECTION = Enum.EasingDirection.Out
	local UNDO_LIMIT = 60
	local MAX_NAME_LENGTH = 48
	local PREFIX = "[Synapse UI Designer] "
	
	local PROPERTY_CATALOG = {
		"Position",
		"Size",
		"Rotation",
		"AnchorPoint",
		"BackgroundTransparency",
		"BackgroundColor3",
		"ImageTransparency",
		"ImageColor3",
		"Text",
		"TextTransparency",
		"TextColor3",
		"TextStrokeTransparency",
		"TextStrokeColor3",
		"TextSize",
		"MaxVisibleGraphemes",
		"BorderColor3",
		"BorderSizePixel",
		"GroupTransparency",
	}
	
	local INTEGER_PROPS = {
		TextSize = true,
		MaxVisibleGraphemes = true,
		BorderSizePixel = true,
	}
	
	local STYLES = Enum.EasingStyle:GetEnumItems()
	local DIRECTIONS = Enum.EasingDirection:GetEnumItems()
	
	local C = {
		bg = BRAND.Background,
		bar = BRAND.Surface,
		lane = BRAND.Border,
		laneKeys = BRAND.Surface,
		laneEvents = Color3.fromRGB(44, 44, 48),
		row = BRAND.SurfaceAlt,
		text = BRAND.Text,
		textDim = BRAND.TextMuted,
		blue = BRAND.Accent,
		red = BRAND.Danger,
		green = BRAND.Success,
		orange = BRAND.Warning,
		purple = BRAND.Accent,
		teal = BRAND.Accent,
		event = BRAND.Accent,
		danger = BRAND.Danger,
		gray = Color3.fromRGB(95, 95, 95),
		key = BRAND.Accent,
		keySel = BRAND.Warning,
		playhead = BRAND.Danger,
		selected = Color3.fromRGB(60, 80, 110),
	}
	
	local State = {
		target = nil,
		keyframes = {},
		selected = nil,
		selectedEvent = nil,
		time = 0,
		playing = false,
		loop = false,
		autoKey = true,
		speed = 1,
		pxPerSec = 200,
		snap = 0.05,
		follow = true,
		logEvents = true,
		showProps = true,
		clipboard = nil,
		eventClipboard = nil,
		undo = {},
		redo = {},
		enabledProps = {
			Position = true,
			Size = true,
			Rotation = true,
			BackgroundTransparency = true,
		},
		fx = { place = "playhead", autoPreview = true, eventMarker = false, recent = {} },
	}
	
	local baseline = {}
	local applied = {}
	local applyingProperties = 0
	local propertyConnections = {}
	local ancestryConnection = nil
	local playConnection = nil
	local drag = nil
	
	local A = {}
	A.linkListeners = {}
	
	do
		local ok, saved = pcall(function()
			return plugin:GetSetting(SETTINGS_KEY)
		end)
		if ok and type(saved) == "table" then
			if type(saved.autoKey) == "boolean" then
				State.autoKey = saved.autoKey
			end
			if type(saved.logEvents) == "boolean" then
				State.logEvents = saved.logEvents
			end
			if type(saved.follow) == "boolean" then
				State.follow = saved.follow
			end
			if type(saved.snap) == "number" and table.find(SNAP_STEPS, saved.snap) then
				State.snap = saved.snap
			end
			if type(saved.speed) == "number" and table.find(SPEEDS, saved.speed) then
				State.speed = saved.speed
			end
			if type(saved.pxPerSec) == "number" then
				State.pxPerSec = math.clamp(saved.pxPerSec, MIN_ZOOM, MAX_ZOOM)
			end
			if saved.place == "playhead" or saved.place == "start" or saved.place == "end" then
				State.fx.place = saved.place
			end
			if type(saved.autoPreview) == "boolean" then
				State.fx.autoPreview = saved.autoPreview
			end
			if type(saved.eventMarker) == "boolean" then
				State.fx.eventMarker = saved.eventMarker
			end
			if type(saved.recent) == "table" then
				for _, id in ipairs(saved.recent) do
					if type(id) == "string" and #State.fx.recent < 8 then
						table.insert(State.fx.recent, id)
					end
				end
			end
		end
	end
	
	function A.saveSettings()
		pcall(function()
			plugin:SetSetting(SETTINGS_KEY, {
				autoKey = State.autoKey,
				logEvents = State.logEvents,
				follow = State.follow,
				snap = State.snap,
				speed = State.speed,
				pxPerSec = State.pxPerSec,
				place = State.fx.place,
				autoPreview = State.fx.autoPreview,
				eventMarker = State.fx.eventMarker,
				recent = State.fx.recent,
			})
		end)
	end
	
	local function create(className, properties, parent)
		local object = Instance.new(className)
		for property, value in pairs(properties or {}) do
			object[property] = value
		end
		if parent then
			object.Parent = parent
		end
		return object
	end
	
	local function corner(parent, radius)
		return applyCorner(parent, radius or DesignSystem.Radius.Small)
	end
	
	local function padding(parent, l, r, t, b)
		return create("UIPadding", {
			PaddingLeft = UDim.new(0, l or 0),
			PaddingRight = UDim.new(0, r or l or 0),
			PaddingTop = UDim.new(0, t or 0),
			PaddingBottom = UDim.new(0, b or t or 0),
		}, parent)
	end
	
	local function orderer()
		local n = 0
		return function()
			n += 1
			return n
		end
	end
	
	local propertyCache = {}
	local function hasProperty(instance, name)
		local className = instance.ClassName
		local classCache = propertyCache[className]
		if not classCache then
			classCache = {}
			propertyCache[className] = classCache
		end
		local known = classCache[name]
		if known == nil then
			local ok, value = pcall(function()
				return instance[name]
			end)
			known = ok and typeof(value) ~= "Instance"
			classCache[name] = known
		end
		return known
	end
	
	local function cycleNumber(list, current)
		for index, value in ipairs(list) do
			if value == current then
				return list[index % #list + 1]
			end
		end
		return list[1]
	end
	
	local function roundTo(value, places)
		local m = 10 ^ places
		return math.round(value * m) / m
	end
	
	local function isFiniteNumber(value)
		return type(value) == "number" and value == value and math.abs(value) ~= math.huge
	end
	
	local function isFiniteValue(value)
		local kind = typeof(value)
		if kind == "number" then
			return isFiniteNumber(value)
		elseif kind == "UDim2" then
			return isFiniteNumber(value.X.Scale)
				and isFiniteNumber(value.X.Offset)
				and isFiniteNumber(value.Y.Scale)
				and isFiniteNumber(value.Y.Offset)
		elseif kind == "Vector2" then
			return isFiniteNumber(value.X) and isFiniteNumber(value.Y)
		elseif kind == "Color3" then
			return isFiniteNumber(value.R) and isFiniteNumber(value.G) and isFiniteNumber(value.B)
		end
		return true
	end
	
	local function num(value)
		return string.format("%.6g", value)
	end
	
	local function fmtTime(time)
		if roundTo(time, 2) == roundTo(time, 3) then
			return string.format("%.2fs", time)
		end
		return string.format("%.3fs", time)
	end
	
	local function trim(text)
		local result = text:gsub("^%s+", "")
		result = result:gsub("%s+$", "")
		return result
	end
	
	local function serializeValue(value)
		local kind = typeof(value)
		if kind == "number" then
			return num(value)
		elseif kind == "boolean" then
			return tostring(value)
		elseif kind == "UDim2" then
			return string.format(
				"UDim2.new(%s, %d, %s, %d)",
				num(value.X.Scale),
				math.round(value.X.Offset),
				num(value.Y.Scale),
				math.round(value.Y.Offset)
			)
		elseif kind == "Vector2" then
			return string.format("Vector2.new(%s, %s)", num(value.X), num(value.Y))
		elseif kind == "Color3" then
			return string.format("Color3.new(%s, %s, %s)", num(value.R), num(value.G), num(value.B))
		elseif kind == "string" then
			return string.format("%q", value)
		end
		return nil
	end
	
	local function encodeValue(value)
		local kind = typeof(value)
		if kind == "number" then
			return { t = "n", d = value }
		elseif kind == "boolean" then
			return { t = "b", d = value }
		elseif kind == "UDim2" then
			return { t = "u", d = { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset } }
		elseif kind == "Vector2" then
			return { t = "v", d = { value.X, value.Y } }
		elseif kind == "Color3" then
			return { t = "c", d = { value.R, value.G, value.B } }
		elseif kind == "string" then
			return { t = "s", d = value }
		end
		return nil
	end
	
	local function decodeValue(item)
		local t, d = item.t, item.d
		if t == "n" then
			return d
		elseif t == "b" then
			return d == true
		elseif t == "u" then
			return UDim2.new(d[1], d[2], d[3], d[4])
		elseif t == "v" then
			return Vector2.new(d[1], d[2])
		elseif t == "c" then
			return Color3.new(d[1], d[2], d[3])
		elseif t == "s" then
			return d
		end
		return nil
	end
	
	local function formatValue(value)
		local kind = typeof(value)
		if kind == "number" then
			return num(value)
		elseif kind == "UDim2" then
			return string.format(
				"%s, %s, %s, %s",
				num(value.X.Scale),
				num(value.X.Offset),
				num(value.Y.Scale),
				num(value.Y.Offset)
			)
		elseif kind == "Vector2" then
			return string.format("%s, %s", num(value.X), num(value.Y))
		elseif kind == "Color3" then
			return "#" .. value:ToHex():upper()
		elseif kind == "string" then
			return value
		end
		return tostring(value)
	end
	
	local function extractNumbers(text)
		local numbers = {}
		for token in text:gmatch("[%-]?%d*%.?%d+") do
			local n = tonumber(token)
			if n then
				table.insert(numbers, n)
			end
		end
		return numbers
	end
	
	local function parseValue(text, sample)
		if typeof(sample) == "string" then
			return text
		end
	
		text = trim(text)
		local kind = typeof(sample)
	
		if kind == "number" then
			return tonumber(text)
		elseif kind == "UDim2" then
			local n = extractNumbers(text)
			if #n == 4 then
				return UDim2.new(n[1], n[2], n[3], n[4])
			elseif #n == 2 then
				return UDim2.fromOffset(n[1], n[2])
			end
		elseif kind == "Vector2" then
			local n = extractNumbers(text)
			if #n == 2 then
				return Vector2.new(n[1], n[2])
			end
		elseif kind == "Color3" then
			local hex = text:match("^#?(%x%x%x%x%x%x)$")
			if hex then
				return Color3.fromHex(hex)
			end
			local n = extractNumbers(text)
			if #n == 3 then
				if text:find("%.") and n[1] <= 1 and n[2] <= 1 and n[3] <= 1 then
					return Color3.new(n[1], n[2], n[3])
				end
				return Color3.fromRGB(
					math.clamp(n[1], 0, 255),
					math.clamp(n[2], 0, 255),
					math.clamp(n[3], 0, 255)
				)
			end
		end
	
		return nil
	end
	
	local function lerpValue(a, b, alpha)
		local kind = typeof(a)
		if kind == "number" then
			return a + (b - a) * alpha
		elseif kind == "UDim2" or kind == "Vector2" or kind == "Color3" then
			return a:Lerp(b, alpha)
		end
		return alpha < 1 and a or b
	end
	
	local function sanitizeEventName(name)
		if type(name) ~= "string" then
			return nil
		end
		name = trim((name:gsub("%c", " ")))
		name = name:sub(1, MAX_NAME_LENGTH)
		if name == "" then
			return nil
		end
		return name
	end
	
	local function splitTopLevel(text, separator)
		local parts, buffer = {}, {}
		local inQuote, escaped = false, false
	
		for index = 1, #text do
			local char = text:sub(index, index)
			if escaped then
				escaped = false
				table.insert(buffer, char)
			elseif char == "\\" and inQuote then
				escaped = true
				table.insert(buffer, char)
			elseif char == '"' then
				inQuote = not inQuote
				table.insert(buffer, char)
			elseif char == separator and not inQuote then
				table.insert(parts, table.concat(buffer))
				buffer = {}
			else
				table.insert(buffer, char)
			end
		end
	
		table.insert(parts, table.concat(buffer))
		return parts, inQuote
	end
	
	local function parseScalar(raw)
		raw = trim(raw)
	
		if #raw >= 2 and raw:sub(1, 1) == '"' and raw:sub(-1) == '"' then
			return (raw:sub(2, -2):gsub("\\(.)", "%1"))
		end
	
		local lower = raw:lower()
		if lower == "true" then
			return true
		elseif lower == "false" then
			return false
		end
	
		local number = tonumber(raw)
		if number and number == number and math.abs(number) ~= math.huge then
			return number
		end
	
		return raw
	end
	
	local function parseParams(text)
		text = trim(text or "")
		local params = {}
		if text == "" then
			return params
		end
	
		local parts, unclosed = splitTopLevel(text, ",")
		if unclosed then
			return nil, "Unclosed quote in the parameters."
		end
	
		local count = 0
		for _, part in ipairs(parts) do
			part = trim(part)
			if part ~= "" then
				local key, value = part:match("^([%a_][%w_]*)%s*=%s*(.*)$")
				if not key then
					return nil, 'Use name=value (example: damage=10, sound="hit", crit=true).'
				end
				if value == "" then
					return nil, 'Parameter "' .. key .. '" has no value.'
				end
				count += 1
				if count > MAX_EVENT_PARAMS then
					return nil, "Too many parameters (maximum 24)."
				end
				params[key] = parseScalar(value)
			end
		end
	
		return params
	end
	
	local EV = {}
	
	EV.TYPES = { "string", "number", "boolean", "Vector2", "Color3" }
	EV.LABELS = { string = "Text", number = "Number", boolean = "Bool", Vector2 = "Vec2", Color3 = "Color" }
	
	EV.PRESETS = {
		{ name = "PlaySound", params = { sound = "rbxassetid://0", volume = 1, pitch = 1 } },
		{ name = "Damage", params = { amount = 10, crit = false } },
		{ name = "CameraShake", params = { intensity = 0.5, duration = 0.3 } },
		{ name = "SpawnEffect", params = { effect = "Sparkle", count = 10 } },
		{ name = "SetState", params = { state = "Open" } },
		{ name = "Tint", params = { color = Color3.fromRGB(255, 80, 80), duration = 0.2 } },
		{ name = "Callback", params = {} },
	}
	
	function EV.typeOf(value)
		local kind = typeof(value)
		if kind == "string" or kind == "number" or kind == "boolean" or kind == "Vector2" or kind == "Color3" then
			return kind
		end
		return "string"
	end
	
	function EV.default(kind)
		if kind == "number" then
			return 0
		elseif kind == "boolean" then
			return false
		elseif kind == "Vector2" then
			return Vector2.new(0, 0)
		elseif kind == "Color3" then
			return Color3.new(1, 1, 1)
		end
		return ""
	end
	
	function EV.toText(value)
		local kind = typeof(value)
		if kind == "string" then
			return value
		elseif kind == "number" then
			return num(value)
		elseif kind == "boolean" then
			return tostring(value)
		elseif kind == "Vector2" then
			return string.format("%s, %s", num(value.X), num(value.Y))
		elseif kind == "Color3" then
			return "#" .. value:ToHex():upper()
		end
		return tostring(value)
	end
	
	function EV.fromText(text, kind)
		if kind == "string" then
			return text
		elseif kind == "number" then
			local n = tonumber(trim(text))
			if n and isFiniteNumber(n) then
				return n
			end
			return nil
		elseif kind == "boolean" then
			local lower = trim(text):lower()
			if lower == "true" or lower == "1" or lower == "yes" then
				return true
			elseif lower == "false" or lower == "0" or lower == "no" then
				return false
			end
			return nil
		elseif kind == "Vector2" then
			return parseValue(text, Vector2.new())
		elseif kind == "Color3" then
			return parseValue(text, Color3.new())
		end
		return nil
	end
	
	function EV.convert(value, kind)
		local parsed = EV.fromText(EV.toText(value), kind)
		if parsed == nil then
			return EV.default(kind)
		end
		return parsed
	end
	
	function EV.display(value)
		if type(value) == "string" then
			local escaped = value:gsub("\\", "\\\\")
			escaped = escaped:gsub('"', '\\"')
			return '"' .. escaped .. '"'
		elseif typeof(value) == "Vector2" then
			return "Vector2(" .. EV.toText(value) .. ")"
		end
		return EV.toText(value)
	end
	
	function EV.sortedKeys(params)
		local keys = {}
		for key in pairs(params) do
			table.insert(keys, key)
		end
		table.sort(keys)
		return keys
	end
	
	function EV.nextKey(params, base)
		if params[base] == nil then
			return base
		end
		local index = 2
		while params[base .. index] ~= nil do
			index += 1
		end
		return base .. index
	end
	
	function EV.new(name, params, enabled)
		return {
			Name = sanitizeEventName(name) or "Event",
			Params = params and table.clone(params) or {},
			Enabled = enabled ~= false,
		}
	end
	
	local function formatParams(params)
		local parts = {}
		for _, key in ipairs(EV.sortedKeys(params)) do
			table.insert(parts, key .. "=" .. EV.display(params[key]))
		end
		return table.concat(parts, ", ")
	end
	
	local function cloneEvents(events)
		local copy = {}
		for _, event in ipairs(events or {}) do
			table.insert(copy, { Name = event.Name, Params = table.clone(event.Params), Enabled = event.Enabled ~= false })
		end
		return copy
	end
	
	local function makeKeyframe(time, properties, style, direction, events)
		return {
			Time = time,
			Style = style or DEFAULT_STYLE,
			Direction = direction or DEFAULT_DIRECTION,
			Properties = properties or {},
			Events = events or {},
		}
	end
	
	local function sortKeyframes()
		table.sort(State.keyframes, function(a, b)
			return a.Time < b.Time
		end)
	end
	
	local function getDuration()
		local count = #State.keyframes
		return count > 0 and State.keyframes[count].Time or 0
	end
	
	local function keyframeAt(time)
		for _, keyframe in ipairs(State.keyframes) do
			if math.abs(keyframe.Time - time) < 0.001 then
				return keyframe
			end
		end
		return nil
	end
	
	local function countEvents()
		local total = 0
		for _, keyframe in ipairs(State.keyframes) do
			total += #keyframe.Events
		end
		return total
	end
	
	local function snapTime(time)
		if State.snap <= 0 then
			return math.max(0, roundTo(time, 3))
		end
		return math.max(0, roundTo(math.round(time / State.snap) * State.snap, 4))
	end
	
	local function evaluateProperty(property, time)
		local previous, nextKey
		for _, keyframe in ipairs(State.keyframes) do
			if keyframe.Properties[property] ~= nil then
				if keyframe.Time <= time then
					previous = keyframe
				else
					nextKey = keyframe
					break
				end
			end
		end
	
		if not previous and not nextKey then
			return baseline[property]
		end
		if not previous then
			local initial = baseline[property]
			return initial ~= nil and initial or nextKey.Properties[property]
		end
		if not nextKey then
			return previous.Properties[property]
		end
	
		local span = nextKey.Time - previous.Time
		local alpha = span > 0 and (time - previous.Time) / span or 1
		alpha = math.clamp(alpha, 0, 1)
		alpha = TweenService:GetValue(alpha, previous.Style, previous.Direction)
	
		return lerpValue(previous.Properties[property], nextKey.Properties[property], alpha)
	end
	
	local function applyAt(time)
		local target = State.target
		if not target or not target.Parent then
			return
		end
	
		local keyed = {}
		for _, keyframe in ipairs(State.keyframes) do
			for property in pairs(keyframe.Properties) do
				keyed[property] = true
			end
		end
	
		applyingProperties += 1
		for _, property in ipairs(PROPERTY_CATALOG) do
			local value
			if keyed[property] then
				value = evaluateProperty(property, time)
			elseif applied[property] ~= nil and baseline[property] ~= nil and applied[property] ~= baseline[property] then
				value = baseline[property]
			end
	
			if value ~= nil then
				if INTEGER_PROPS[property] and type(value) == "number" then
					value = math.round(value)
				end
				pcall(function()
					target[property] = value
					applied[property] = target[property]
				end)
			end
		end
		applyingProperties -= 1
	end
	
	local function snapshotBaseline()
		table.clear(baseline)
		local target = State.target
		if not target then
			return
		end
		for _, property in ipairs(PROPERTY_CATALOG) do
			if hasProperty(target, property) then
				baseline[property] = target[property]
			end
		end
	end
	
	local function restoreBaseline()
		local target = State.target
		if not target or not target.Parent then
			return
		end
		applyingProperties += 1
		for property, value in pairs(baseline) do
			applied[property] = value
			pcall(function()
				target[property] = value
			end)
		end
		applyingProperties -= 1
	end
	
	local function encodeKeyframes(keyframes)
		local list = {}
		for _, keyframe in ipairs(keyframes) do
			local props = {}
			for name, value in pairs(keyframe.Properties) do
				local encoded = encodeValue(value)
				if encoded then
					props[name] = encoded
				end
			end
	
			local events = {}
			for _, event in ipairs(keyframe.Events or {}) do
				local params = {}
				for key, value in pairs(event.Params) do
					local encoded = encodeValue(value)
					if encoded then
						params[key] = encoded
					end
				end
				local entryEvent = { name = event.Name, params = params }
				if event.Enabled == false then
					entryEvent.enabled = false
				end
				table.insert(events, entryEvent)
			end
	
			local entry = {
				time = keyframe.Time,
				style = keyframe.Style.Name,
				direction = keyframe.Direction.Name,
				props = props,
			}
			if #events > 0 then
				entry.events = events
			end
			table.insert(list, entry)
		end
		return list
	end
	
	local function decodeKeyframes(list)
		local keyframes = {}
		for _, item in ipairs(list) do
			if type(item) == "table" then
				local properties = {}
				for name, encoded in pairs(item.props or {}) do
					if type(encoded) == "table" then
						local ok, value = pcall(decodeValue, encoded)
						if ok and value ~= nil then
							properties[name] = value
						end
					end
				end
	
				local events = {}
				local rawEvents = type(item.events) == "table" and item.events or {}
				for _, rawEvent in ipairs(rawEvents) do
					if type(rawEvent) == "table" then
						local name = sanitizeEventName(rawEvent.name)
						if name then
							local params = {}
							local rawParams = type(rawEvent.params) == "table" and rawEvent.params or {}
							for key, encoded in pairs(rawParams) do
								if type(key) == "string" and type(encoded) == "table" then
									local ok, value = pcall(decodeValue, encoded)
									if ok and value ~= nil then
										params[key] = value
									end
								end
							end
							table.insert(events, { Name = name, Params = params, Enabled = rawEvent.enabled ~= false })
						end
					end
				end
	
				local styleOk, style = pcall(function()
					return Enum.EasingStyle[item.style]
				end)
				local dirOk, direction = pcall(function()
					return Enum.EasingDirection[item.direction]
				end)
	
				table.insert(
					keyframes,
					makeKeyframe(
						math.max(tonumber(item.time) or 0, 0),
						properties,
						styleOk and style or DEFAULT_STYLE,
						dirOk and direction or DEFAULT_DIRECTION,
						events
					)
				)
			end
		end
	
		table.sort(keyframes, function(a, b)
			return a.Time < b.Time
		end)
		return keyframes
	end
	
	local function saveToTarget()
		local target = State.target
		if not target or not target.Parent then
			return
		end
	
		if #State.keyframes == 0 then
			pcall(function()
				target:SetAttribute(ATTRIBUTE_NAME, nil)
			end)
			return
		end
	
		local data = {
			version = DATA_VERSION,
			loop = State.loop,
			keyframes = encodeKeyframes(State.keyframes),
		}
	
		pcall(function()
			target:SetAttribute(ATTRIBUTE_NAME, HttpService:JSONEncode(data))
		end)
	end
	
	local saveToken = 0
	function A.scheduleSave()
		saveToken += 1
		local token = saveToken
		local target = State.target
		task.delay(0.4, function()
			if token == saveToken and State.target == target then
				saveToTarget()
			end
		end)
	end
	
	local function loadFromTarget()
		State.keyframes = {}
		State.selected = nil
		State.selectedEvent = nil
	
		local target = State.target
		if not target then
			return
		end
	
		local raw = target:GetAttribute(ATTRIBUTE_NAME)
		if raw == nil then
			local legacy = target:GetAttribute(LEGACY_DATA_ATTRIBUTE)
			if legacy ~= nil then
				raw = legacy
				pcall(function()
					target:SetAttribute(ATTRIBUTE_NAME, legacy)
					target:SetAttribute(LEGACY_DATA_ATTRIBUTE, nil)
				end)
			end
		end
		if type(raw) ~= "string" then
			return
		end
	
		local ok, data = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not ok or type(data) ~= "table" or type(data.keyframes) ~= "table" then
			return
		end
		if #data.keyframes == 0 or #data.keyframes > MAX_IMPORT_KEYFRAMES then
			return
		end
	
		local previousTime = -1
		local eventCount = 0
		for _, item in ipairs(data.keyframes) do
			local time = type(item) == "table" and tonumber(item.time)
			if
				type(item) ~= "table"
				or not isFiniteNumber(time)
				or time < 0
				or time > MAX_ANIMATION_TIME
				or time <= previousTime
			then
				return
			end
			previousTime = time
			if item.events ~= nil and type(item.events) ~= "table" then
				return
			end
			eventCount += #(item.events or {})
			if eventCount > MAX_IMPORT_EVENTS then
				return
			end
		end
	
		if type(data.loop) == "boolean" then
			State.loop = data.loop
		end
	
		State.keyframes = decodeKeyframes(data.keyframes)
		State.selected = State.keyframes[1]
	end
	
	local lastUndoKey, lastUndoAt = nil, 0
	
	local function snapshotState()
		return {
			keys = encodeKeyframes(State.keyframes),
			selected = State.selected and table.find(State.keyframes, State.selected) or nil,
			selectedEvent = State.selectedEvent,
			time = State.time,
			loop = State.loop,
			enabledProps = table.clone(State.enabledProps),
		}
	end
	
	local function pushUndo(coalesceKey)
		if not State.target then
			return
		end
	
		local now = os.clock()
		if coalesceKey and coalesceKey == lastUndoKey and now - lastUndoAt < 1 then
			lastUndoAt = now
			return
		end
		lastUndoKey, lastUndoAt = coalesceKey, now
	
		table.insert(State.undo, snapshotState())
		if #State.undo > UNDO_LIMIT then
			table.remove(State.undo, 1)
		end
		table.clear(State.redo)
		A.updateHistoryButtons()
	end
	
	local pluginGui = plugin:CreateDockWidgetPluginGui(
		"SynapseUiDesigner",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Bottom, true, false, 1000, 300, 560, 220)
	)
	pluginGui.Title = "Synapse UI Designer"
	pluginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local mainBg = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = C.bg,
		BorderSizePixel = 0,
	}, pluginGui)
	
	local topBar = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = C.bar,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 3,
	}, mainBg)
	
	padding(topBar, 8, 8, 0, 0)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, topBar)
	
	local body = create("Frame", {
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1, 0, 1, -40),
		BackgroundTransparency = 1,
	}, mainBg)
	
	local leftColumn = create("Frame", {
		Size = UDim2.new(1, -SIDE_W, 1, 0),
		BackgroundTransparency = 1,
	}, body)
	
	local scroll = create("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 6),
		Size = UDim2.new(1, -16, 1, -34),
		BackgroundColor3 = C.lane,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 8,
		ClipsDescendants = true,
	}, leftColumn)
	
	local statusLabel = create("TextLabel", {
		Position = UDim2.new(0, 8, 1, -24),
		Size = UDim2.new(0.58, -8, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = C.textDim,
		Font = BRAND.Font,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, leftColumn)
	
	local hintLabel = create("TextLabel", {
		Position = UDim2.new(0.58, 0, 1, -24),
		Size = UDim2.new(0.42, -8, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = C.textDim,
		Font = BRAND.Font,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, leftColumn)
	
	local hintToken = 0
	local function setHint(text, color, duration)
		hintToken += 1
		local token = hintToken
		hintLabel.Text = text or ""
		hintLabel.TextColor3 = color or C.textDim
		if duration then
			task.delay(duration, function()
				if hintToken == token then
					hintLabel.Text = ""
				end
			end)
		end
	end
	
	local function notify(text, kind)
		local color = C.textDim
		if kind == "error" then
			color = Color3.fromRGB(255, 120, 130)
			warn(PREFIX .. text)
		elseif kind == "ok" then
			color = C.green
		elseif kind == "event" then
			color = C.event
		end
		setHint(text, color, 4)
	end
	
	local function tip(object, text)
		object.MouseEnter:Connect(function()
			setHint(text)
		end)
		object.MouseLeave:Connect(function()
			if hintLabel.Text == text then
				setHint("")
			end
		end)
	end
	
	local topOrder = orderer()
	local Btn = {}
	
	local function topButton(key, text, color, width, tooltip)
		local button = create("TextButton", {
			Size = UDim2.fromOffset(width, 28),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			Font = BRAND.FontBold,
			TextSize = 13,
			AutoButtonColor = true,
			LayoutOrder = topOrder(),
		}, topBar)
		corner(button, 5)
		if tooltip then
			tip(button, tooltip)
		end
		Btn[key] = button
		return button
	end
	
	local function topSeparator()
		create("Frame", {
			Size = UDim2.fromOffset(1, 22),
			BackgroundColor3 = C.gray,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			LayoutOrder = topOrder(),
		}, topBar)
	end
	
	create("ImageLabel", {
		Name = "Logo",
		Size = UDim2.fromOffset(32, 32),
		BackgroundTransparency = 1,
		Image = LOGO_IMAGE,
		ScaleType = Enum.ScaleType.Fit,
		LayoutOrder = topOrder(),
	}, topBar)
	
	topButton("link", "Link UI", C.blue, 84, "Link the object selected in the Explorer")
	topButton("key", "+ Keyframe", C.red, 96, "Add or update a keyframe at the playhead (K)")
	topButton("event", "+ Event", C.event, 80, "Add an event at the playhead time (E)")
	
	do
		local holder = create("Frame", {
			Size = UDim2.fromOffset(98, 28),
			BackgroundColor3 = C.purple,
			BorderSizePixel = 0,
			LayoutOrder = topOrder(),
		}, topBar)
		corner(holder, 5)
		create("ImageLabel", {
			Position = UDim2.fromOffset(7, 6),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Image = EFFECTS_ICON,
			ScaleType = Enum.ScaleType.Fit,
		}, holder)
		local button = create("TextButton", {
			Position = UDim2.fromOffset(24, 0),
			Size = UDim2.new(1, -24, 1, 0),
			BackgroundTransparency = 1,
			Text = "Effects",
			TextColor3 = Color3.new(1, 1, 1),
			Font = BRAND.FontBold,
			TextSize = 13,
		}, holder)
		tip(button, "Open the Effects panel: ready-made animations (F)")
		Btn.effects = button
	end
	
	topSeparator()
	topButton("home", "Home", C.gray, 56, "Go to the start (Home)")
	topButton("play", "Play", C.green, 70, "Play / pause (Space)")
	topButton("loop", "Loop: off", C.gray, 80, "Toggle looping (L)")
	topButton("auto", "Auto-key: on", C.orange, 100, "Record property edits automatically")
	topButton("speed", "Speed: 1x", C.gray, 78, "Cycle the preview speed")
	topButton("snap", "Snap: 0.05s", C.gray, 96, "Cycle time snapping")
	topSeparator()
	topButton("zoomOut", "Zoom -", C.gray, 60, "Zoom out")
	topButton("zoomIn", "Zoom +", C.gray, 60, "Zoom in")
	topButton("fit", "Fit", C.gray, 44, "Fit the whole animation in view")
	topSeparator()
	topButton("undo", "Undo", C.gray, 56, "Undo the last timeline edit (Ctrl+Z)")
	topButton("redo", "Redo", C.gray, 56, "Redo the last undone edit (Ctrl+Y)")
	topSeparator()
	topButton("save", "Save", C.purple, 64, "Save the animation as a ModuleScript")
	topButton("import", "Import", C.blue, 72, "Import a saved animation or JSON")
	topButton("clear", "Clear", C.gray, 64, "Remove every keyframe (can be undone)")
	topSeparator()
	topButton("log", "Log: on", C.gray, 70, "Print animation events to the Output while previewing")
	topButton("help", "?", C.gray, 30, "Mouse controls and keyboard shortcuts")
	
	local side = create("ScrollingFrame", {
		Position = UDim2.new(1, -SIDE_W, 0, 0),
		Size = UDim2.new(0, SIDE_W, 1, 0),
		BackgroundColor3 = C.bar,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 6,
	}, body)
	
	padding(side, 8, 8, 6, 6)
	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, side)
	
	local sideOrder = orderer()
	

	R.Selection = Selection
	R.UserInputService = UserInputService
	R.TweenService = TweenService
	R.RunService = RunService
	R.HttpService = HttpService
	R.ChangeHistoryService = ChangeHistoryService
	R.ReplicatedStorage = ReplicatedStorage
	R.StarterGui = StarterGui
	R.ATTRIBUTE_NAME = ATTRIBUTE_NAME
	R.ID_ATTRIBUTE = ID_ATTRIBUTE
	R.LEGACY_ID_ATTRIBUTE = LEGACY_ID_ATTRIBUTE
	R.LIBRARY_FOLDER = LIBRARY_FOLDER
	R.LIBRARY_ATTRIBUTE = LIBRARY_ATTRIBUTE
	R.LIBRARY_DATA_ATTRIBUTE = LIBRARY_DATA_ATTRIBUTE
	R.DATA_VERSION = DATA_VERSION
	R.MAX_IMPORT_KEYFRAMES = MAX_IMPORT_KEYFRAMES
	R.MAX_IMPORT_EVENTS = MAX_IMPORT_EVENTS
	R.MAX_ANIMATION_TIME = MAX_ANIMATION_TIME
	R.MAX_EVENT_PARAMS = MAX_EVENT_PARAMS
	R.LOGO_IMAGE = LOGO_IMAGE
	R.BRAND = BRAND
	R.styleButton = styleButton
	R.EFFECTS_ICON = EFFECTS_ICON
	R.LEFT_PAD = LEFT_PAD
	R.RULER_H = RULER_H
	R.KEY_LANE_Y = KEY_LANE_Y
	R.EVENT_LANE_Y = EVENT_LANE_Y
	R.LANES_H = LANES_H
	R.SNAP_STEPS = SNAP_STEPS
	R.MIN_ZOOM = MIN_ZOOM
	R.SPEEDS = SPEEDS
	R.DEFAULT_STYLE = DEFAULT_STYLE
	R.DEFAULT_DIRECTION = DEFAULT_DIRECTION
	R.PREFIX = PREFIX
	R.PROPERTY_CATALOG = PROPERTY_CATALOG
	R.INTEGER_PROPS = INTEGER_PROPS
	R.STYLES = STYLES
	R.DIRECTIONS = DIRECTIONS
	R.C = C
	R.State = State
	R.baseline = baseline
	R.applied = applied
	R.applyingProperties = applyingProperties
	R.propertyConnections = propertyConnections
	R.ancestryConnection = ancestryConnection
	R.playConnection = playConnection
	R.drag = drag
	R.A = A
	R.create = create
	R.corner = corner
	R.padding = padding
	R.orderer = orderer
	R.hasProperty = hasProperty
	R.cycleNumber = cycleNumber
	R.roundTo = roundTo
	R.isFiniteNumber = isFiniteNumber
	R.isFiniteValue = isFiniteValue
	R.num = num
	R.fmtTime = fmtTime
	R.trim = trim
	R.serializeValue = serializeValue
	R.decodeValue = decodeValue
	R.formatValue = formatValue
	R.parseValue = parseValue
	R.sanitizeEventName = sanitizeEventName
	R.parseParams = parseParams
	R.EV = EV
	R.formatParams = formatParams
	R.cloneEvents = cloneEvents
	R.makeKeyframe = makeKeyframe
	R.sortKeyframes = sortKeyframes
	R.getDuration = getDuration
	R.keyframeAt = keyframeAt
	R.countEvents = countEvents
	R.snapTime = snapTime
	R.evaluateProperty = evaluateProperty
	R.applyAt = applyAt
	R.snapshotBaseline = snapshotBaseline
	R.restoreBaseline = restoreBaseline
	R.encodeKeyframes = encodeKeyframes
	R.decodeKeyframes = decodeKeyframes
	R.saveToTarget = saveToTarget
	R.loadFromTarget = loadFromTarget
	R.lastUndoKey = lastUndoKey
	R.snapshotState = snapshotState
	R.pushUndo = pushUndo
	R.pluginGui = pluginGui
	R.mainBg = mainBg
	R.scroll = scroll
	R.statusLabel = statusLabel
	R.setHint = setHint
	R.notify = notify
	R.tip = tip
	R.Btn = Btn
	R.side = side
	R.sideOrder = sideOrder

end
