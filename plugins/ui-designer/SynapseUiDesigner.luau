if not plugin then
	return
end

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
	A.rebuildTimeline()
	scroll.CanvasPosition = Vector2.new(0, 0)
end

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
	local folder = ReplicatedStorage:FindFirstChild(LIBRARY_FOLDER)
	if not folder and make then
		folder = Instance.new("Folder")
		folder.Name = LIBRARY_FOLDER
		folder.Parent = ReplicatedStorage
	end
	return folder
end

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
			setMessage(importMessage, "Exported to the box. Click it, press Ctrl+A and Ctrl+C to copy.", "ok")
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

do
	local windowFocused = false
	pluginGui.WindowFocused:Connect(function()
		windowFocused = true
	end)
	pluginGui.WindowFocusReleased:Connect(function()
		windowFocused = false
	end)

	local function jumpKey(direction)
		local best = nil
		for _, keyframe in ipairs(State.keyframes) do
			if direction > 0 then
				if keyframe.Time > State.time + 0.0005 then
					best = keyframe
					break
				end
			elseif keyframe.Time < State.time - 0.0005 then
				best = keyframe
			end
		end
		if best then
			stopPlayback()
			State.selected = best
			State.selectedEvent = nil
			A.setTime(best.Time)
			A.refreshInspector()
			A.rebuildTimeline()
		end
	end

	UserInputService.InputBegan:Connect(function(input)
		if not windowFocused or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if UserInputService:GetFocusedTextBox() then
			return
		end

		local key = input.KeyCode
		local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightMeta)

		if key == Enum.KeyCode.Escape then
			A.closeMenu()
			A.toggleHelp(false)
		elseif key == Enum.KeyCode.F then
			A.toggleEffects()
		end

		if not State.target then
			return
		end

		if ctrl then
			if key == Enum.KeyCode.Z then
				if shiftDown() then
					A.redo()
				else
					A.undo()
				end
			elseif key == Enum.KeyCode.Y then
				A.redo()
			elseif key == Enum.KeyCode.C then
				A.copyKeyframe()
			elseif key == Enum.KeyCode.X then
				A.cutKeyframe()
			elseif key == Enum.KeyCode.V then
				A.pasteKeyframe(State.time)
			elseif key == Enum.KeyCode.D then
				A.duplicateKeyframe()
			end
			return
		end

		if key == Enum.KeyCode.Space then
			A.togglePlay()
		elseif key == Enum.KeyCode.K then
			A.recordKeyframe()
		elseif key == Enum.KeyCode.E then
			A.addEventAt(State.time)
		elseif key == Enum.KeyCode.L then
			State.loop = not State.loop
			A.updateToggleButtons()
			A.scheduleSave()
		elseif key == Enum.KeyCode.Home then
			A.goToStart()
		elseif key == Enum.KeyCode.End then
			A.goToEnd()
		elseif key == Enum.KeyCode.Delete or key == Enum.KeyCode.Backspace then
			A.deleteKeyframe()
		elseif key == Enum.KeyCode.Left or key == Enum.KeyCode.Right then
			local direction = key == Enum.KeyCode.Right and 1 or -1
			if shiftDown() then
				jumpKey(direction)
			else
				stopPlayback()
				local step = State.snap > 0 and State.snap or 0.05
				A.setTime(math.max(0, roundTo(State.time + step * direction, 4)))
			end
		end
	end)
end

buildSaveWindow()
buildImportWindow()
local objectsGui = buildObjectsWindow()
local effectsGui = buildEffectsWindow()

do
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
		return button
	end

	addToolbarButton("SynapseUiDesigner", "Open UI Designer", LOGO_IMAGE, "UI Designer", pluginGui)
	addToolbarButton("SynapseUiDesignerObjects", "Open UI Designer Objects", LOGO_IMAGE, "UI Objects", objectsGui)
	addToolbarButton("SynapseUiDesignerEffects", "Open the Effects panel", EFFECTS_ICON, "Effects", effectsGui)
end

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
