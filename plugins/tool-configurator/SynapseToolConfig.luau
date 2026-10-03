local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local VERSION = "2.0.0"
local LOG_PREFIX = "[Synapse Tool Configurator] "

local LOCK_ATTRIBUTE = "SynapseLocked"
local CONFIGURED_ATTRIBUTE = "SynapseConfigured"
local BACKUP_ATTRIBUTE = "SynapseBackup"
local BACKUP_TIME_ATTRIBUTE = "SynapseBackupTime"
local BACKUP_FOLDER_NAME = "_SynapseBackups"
local MAX_BACKUPS = 5
local MAX_LOG_ENTRIES = 100
local SETTINGS_KEY = "SynapseToolConfig_v2"

local BRAND = {
	Name = "Synapse",
	Logo = "rbxassetid://136078562940326",
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
local ACCENT = BRAND.Accent
local SUCCESS = BRAND.Success
local DANGER = BRAND.Danger
local WHITE = BRAND.Text

local DEFAULT_CONFIG = {
	confirmActions = true,
	requireSingleSelection = true,
	backupBeforeConvert = false,
	tagConfigured = true,
	unanchorParts = true,
	verboseLog = false,
	fullSetupJoint = "Motor6D",
	maxParts = 500,
	gripPX = 0,
	gripPY = -1,
	gripPZ = 0,
	gripRX = 0,
	gripRY = 90,
	gripRZ = 0,
}

local CONFIG_RANGES = {
	maxParts = { 10, 5000 },
	gripPX = { -50, 50 },
	gripPY = { -50, 50 },
	gripPZ = { -50, 50 },
	gripRX = { -360, 360 },
	gripRY = { -360, 360 },
	gripRZ = { -360, 360 },
}

local JOINT_TYPES = { "Motor6D", "WeldConstraint" }

local config = table.clone(DEFAULT_CONFIG)

local function sanitizeValue(key: string, value: any): any
	local default = DEFAULT_CONFIG[key]
	if type(value) ~= type(default) then
		return default
	end
	if type(value) == "number" then
		if value ~= value or value == math.huge or value == -math.huge then
			return default
		end
		local range = CONFIG_RANGES[key]
		if range then
			value = math.clamp(value, range[1], range[2])
		end
		if key == "maxParts" then
			value = math.floor(value)
		end
	elseif key == "fullSetupJoint" and not table.find(JOINT_TYPES, value) then
		return default
	end
	return value
end

local function saveConfig()
	pcall(function()
		plugin:SetSetting(SETTINGS_KEY, config)
	end)
end

local function loadConfig()
	local ok, saved = pcall(function()
		return plugin:GetSetting(SETTINGS_KEY)
	end)
	if ok and type(saved) == "table" then
		for key in pairs(DEFAULT_CONFIG) do
			if saved[key] ~= nil then
				config[key] = sanitizeValue(key, saved[key])
			end
		end
	end
end

loadConfig()

local THEME = {
	bg = BRAND.Background,
	card = BRAND.Surface,
	text = BRAND.Text,
	sub = BRAND.TextMuted,
	border = BRAND.Border,
	button = BRAND.SurfaceAlt,
	buttonText = BRAND.Text,
	input = BRAND.Surface,
	warn = BRAND.Warning,
	err = BRAND.Danger,
}

local function themeColor(key: string): Color3
	return THEME[key] or BRAND.Text
end

local themeBindings = {}
local refreshers: { () -> () } = {}

local function bindTheme(inst: Instance, prop: string, key: string)
	table.insert(themeBindings, { inst = inst, prop = prop, key = key });
	(inst :: any)[prop] = themeColor(key)
end

local function levelColor(level: string): Color3
	if level == "ok" then
		return SUCCESS
	elseif level == "warn" then
		return themeColor("warn")
	elseif level == "error" then
		return themeColor("err")
	end
	return themeColor("sub")
end

local function newReport()
	return { errors = {}, warnings = {}, notes = {} }
end

local function addError(report, message: string)
	table.insert(report.errors, message)
end

local function addWarning(report, message: string)
	table.insert(report.warnings, message)
end

local function addNote(report, message: string)
	table.insert(report.notes, message)
end

local createdThisAction: { [Instance]: boolean } = {}

local function track<T>(inst: T & Instance): T & Instance
	createdThisAction[inst] = true
	return inst
end

local function safeDestroy(inst: Instance): boolean
	if createdThisAction[inst] or inst:GetAttribute(BACKUP_ATTRIBUTE) == true then
		inst:Destroy()
		return true
	end
	warn(LOG_PREFIX .. "Refused to destroy '" .. inst:GetFullName() .. "' (not created by this plugin).")
	return false
end

local function isLocked(inst: Instance): boolean
	local current: Instance? = inst
	while current and current ~= game do
		if current:GetAttribute(LOCK_ATTRIBUTE) == true then
			return true
		end
		current = current.Parent
	end
	return false
end

local SUPPORTED_CLASSES = { "Model", "Folder", "Tool", "BasePart" }

local function checkTarget(target: Instance, report)
	if target == game or target.Parent == game then
		addError(report, "Services (Workspace, Lighting, ...) cannot be modified by this plugin.")
		return
	end
	if target:IsA("Terrain") or target:IsA("Camera") or target:IsA("SpawnLocation") then
		addError(report, target.ClassName .. " is protected and cannot be used.")
		return
	end

	local supported = false
	for _, class in ipairs(SUPPORTED_CLASSES) do
		if target:IsA(class) then
			supported = true
			break
		end
	end
	if not supported then
		addError(report, target.ClassName .. " is not supported. Use a Model, Folder, Part or Tool.")
		return
	end

	if isLocked(target) then
		addError(report, "Protected: this object (or an ancestor) has the '" .. LOCK_ATTRIBUTE .. "' attribute. Unlock it first.")
		return
	end

	if not target:IsA("Tool") and target:FindFirstAncestorOfClass("Tool") then
		addError(report, "This object is inside a Tool. Select the Tool itself.")
	end
end

local function scanTarget(target: Instance)
	local scan = {
		parts = {} :: { BasePart },
		namedHandles = {} :: { BasePart },
		anchored = 0,
		humanoids = 0,
		nestedTools = 0,
		protectedInside = 0,
		packageLinks = 0,
	}

	local function visit(inst: Instance)
		if inst:IsA("BasePart") then
			table.insert(scan.parts, inst)
			if inst.Anchored then
				scan.anchored += 1
			end
			if inst.Name == "Handle" then
				table.insert(scan.namedHandles, inst)
			end
		elseif inst:IsA("Humanoid") then
			scan.humanoids += 1
		elseif inst:IsA("Tool") and inst ~= target then
			scan.nestedTools += 1
		elseif inst.ClassName == "PackageLink" then
			scan.packageLinks += 1
		end
		if inst ~= target and inst:GetAttribute(LOCK_ATTRIBUTE) == true then
			scan.protectedInside += 1
		end
	end

	visit(target)
	for _, descendant in ipairs(target:GetDescendants()) do
		visit(descendant)
	end
	return scan
end

local function chooseHandle(target: Instance, scan): (BasePart?, string?)
	if target:IsA("Tool") then
		local direct = target:FindFirstChild("Handle")
		if direct and direct:IsA("BasePart") then
			return direct, "existing Handle"
		end
	end

	local named = scan.namedHandles[1]
	if named then
		return named, "part named Handle"
	end
	if target:IsA("BasePart") then
		return target, "selected part"
	end
	if target:IsA("Model") and target.PrimaryPart then
		return target.PrimaryPart, "PrimaryPart"
	end

	local best: BasePart? = nil
	for _, part in ipairs(scan.parts) do
		if not best or part.Size.Magnitude > best.Size.Magnitude then
			best = part
		end
	end
	return best, "largest part"
end

local function cframeClose(a: CFrame, b: CFrame): boolean
	local ca = { a:GetComponents() }
	local cb = { b:GetComponents() }
	for i = 1, #ca do
		if math.abs(ca[i] - cb[i]) > 1e-4 then
			return false
		end
	end
	return true
end

local function buildGrip(): CFrame
	return CFrame.new(config.gripPX, config.gripPY, config.gripPZ)
		* CFrame.Angles(math.rad(config.gripRX), math.rad(config.gripRY), math.rad(config.gripRZ))
end

local function computeUnjoined(root: Instance, handle: BasePart, parts: { BasePart }): { BasePart }
	local adjacency: { [BasePart]: { BasePart } } = {}

	local function link(a: any, b: any)
		if typeof(a) == "Instance" and typeof(b) == "Instance" and a:IsA("BasePart") and b:IsA("BasePart") then
			adjacency[a] = adjacency[a] or {}
			adjacency[b] = adjacency[b] or {}
			table.insert(adjacency[a], b)
			table.insert(adjacency[b], a)
		end
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			if descendant.Enabled then
				link(descendant.Part0, descendant.Part1)
			end
		end
	end

	local reached: { [BasePart]: boolean } = {}
	local function flood(start: BasePart)
		local queue = { start }
		reached[start] = true
		local index = 1
		while queue[index] do
			local current = queue[index]
			index += 1
			for _, nextPart in ipairs(adjacency[current] or {}) do
				if not reached[nextPart] then
					reached[nextPart] = true
					table.insert(queue, nextPart)
				end
			end
		end
	end

	flood(handle)
	local unjoined = {}
	for _, part in ipairs(parts) do
		if not reached[part] then
			table.insert(unjoined, part)
			flood(part)
		end
	end
	return unjoined
end

local function requireReadyTool(ctx, report): boolean
	if not ctx.isTool then
		addError(report, "Select a Tool first (or run Convert To Tool).")
		return false
	end
	local handle = ctx.target:FindFirstChild("Handle")
	if not (handle and handle:IsA("BasePart")) then
		addError(report, "The Tool has no 'Handle' part directly under it. Run Convert To Tool to repair it.")
		return false
	end
	ctx.handle = handle
	return true
end

local function checkConvert(ctx, report)
	local target, handle = ctx.target, ctx.handle
	if not handle then
		addError(report, "No part found to use as Handle.")
		return
	end

	local isTool = ctx.isTool
	local renames = handle.Name ~= "Handle"
	local moves
	if isTool then
		moves = handle.Parent ~= target
	else
		moves = handle ~= target
	end

	if isTool then
		local existing = target:FindFirstChild("Handle")
		if existing and existing ~= handle then
			addError(report, "The Tool already has a different child named 'Handle'. Rename it first.")
			return
		end
	elseif target ~= handle and target.Name == "Handle" then
		addError(report, "The selected object is named 'Handle' but is not the Handle part. Rename it first.")
		return
	end

	if not isTool then
		addNote(report, ("Create a Tool named '%s' in the same location"):format(target.Name))
		if config.backupBeforeConvert then
			addNote(report, "Clone the original into ServerStorage." .. BACKUP_FOLDER_NAME .. " first")
		end
	end
	if renames then
		addNote(report, ("Rename '%s' to 'Handle'"):format(handle.Name))
	end
	if moves then
		addNote(report, "Move the Handle to the Tool root (Roblox requires it there)")
		if handle.Parent and handle.Parent:IsA("Model") and handle.Parent.PrimaryPart == handle then
			addWarning(report, "The Handle is its Model's PrimaryPart; that Model will lose its PrimaryPart.")
		end
	end

	if ctx.handleSource == "largest part" then
		addWarning(report, ("No Handle found: using the largest part ('%s'). Check it is the right one."):format(handle.Name))
	elseif ctx.handleSource == "PrimaryPart" then
		addWarning(report, ("No Handle found: using the PrimaryPart ('%s')."):format(handle.Name))
	end
	if #ctx.scan.namedHandles > 1 then
		addWarning(report, ("%d parts are named 'Handle'. The first one found is used."):format(#ctx.scan.namedHandles))
	end

	if config.unanchorParts and ctx.scan.anchored > 0 then
		addNote(report, ("Unanchor %d part(s)"):format(ctx.scan.anchored))
		ctx.work.unanchor = true
	end
	if not isTool or renames or moves then
		ctx.work.convert = true
	end
end

local function checkJoints(ctx, report, kind: string)
	local unjoined = computeUnjoined(ctx.target, ctx.handle, ctx.scan.parts)
	ctx.unjoined = unjoined
	if #unjoined > 0 then
		addNote(report, ("Create %d %s (parts not yet connected to the Handle)"):format(#unjoined, kind))
		ctx.work.joints = true
	else
		addNote(report, "All parts are already connected to the Handle (no joints needed)")
	end

	if ctx.scan.anchored > 0 then
		if config.unanchorParts then
			if not ctx.work.unanchor then
				addNote(report, ("Unanchor %d part(s)"):format(ctx.scan.anchored))
				ctx.work.unanchor = true
			end
		else
			addWarning(report, ("%d part(s) are anchored and will not follow the Handle."):format(ctx.scan.anchored))
		end
	end
end

local function checkAttachment(ctx, report)
	local existing = ctx.handle and ctx.handle:FindFirstChild("RightGripAttachment")
	if existing and not existing:IsA("Attachment") then
		addError(report, "'RightGripAttachment' exists but is not an Attachment. It will not be overwritten.")
	elseif existing then
		addNote(report, "RightGripAttachment already exists (kept)")
	else
		addNote(report, "Create RightGripAttachment in the Handle")
		ctx.work.attachment = true
	end
end

local function checkGrip(ctx, report)
	local newGrip = buildGrip()
	if ctx.isTool then
		local current = ctx.target.Grip
		if cframeClose(current, newGrip) then
			addNote(report, "Grip already matches the configured value")
			return
		end
		if not cframeClose(current, CFrame.new()) then
			addWarning(report, "The Tool already has a custom Grip. It will be overwritten.")
		end
	end
	addNote(report, ("Set Grip to pos (%s, %s, %s), rot (%s, %s, %s)"):format(
		tostring(config.gripPX), tostring(config.gripPY), tostring(config.gripPZ),
		tostring(config.gripRX), tostring(config.gripRY), tostring(config.gripRZ)
		))
	ctx.work.grip = true
end

local function makeBackup(target: Instance, lines: { string })
	local folder = ServerStorage:FindFirstChild(BACKUP_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = BACKUP_FOLDER_NAME
		folder:SetAttribute(BACKUP_ATTRIBUTE, true)
		track(folder)
		folder.Parent = ServerStorage
	end

	local ok, clone = pcall(function()
		return target:Clone()
	end)
	if not ok or not clone then
		error("Backup failed (object is not archivable). Conversion cancelled.")
	end

	clone.Name = ("%s_backup_%s"):format(target.Name, os.date("%H%M%S"))
	clone:SetAttribute(BACKUP_ATTRIBUTE, true)
	clone:SetAttribute(BACKUP_TIME_ATTRIBUTE, os.time())
	track(clone)
	clone.Parent = folder
	table.insert(lines, "Backup saved: ServerStorage." .. BACKUP_FOLDER_NAME .. "." .. clone.Name)

	local backups = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:GetAttribute(BACKUP_ATTRIBUTE) == true and child ~= clone then
			table.insert(backups, child)
		end
	end
	table.sort(backups, function(a, b)
		return (a:GetAttribute(BACKUP_TIME_ATTRIBUTE) or 0) < (b:GetAttribute(BACKUP_TIME_ATTRIBUTE) or 0)
	end)
	while #backups >= MAX_BACKUPS do
		safeDestroy(table.remove(backups, 1))
	end
end

local function stepUnanchor(parts: { BasePart }, lines: { string })
	local count = 0
	for _, part in ipairs(parts) do
		if part.Anchored then
			part.Anchored = false
			count += 1
		end
	end
	if count > 0 then
		table.insert(lines, ("Unanchored %d part(s)"):format(count))
	end
end

local function stepConvert(ctx, lines: { string }): Tool
	local target, handle = ctx.target, ctx.handle
	local tool: Tool

	if ctx.isTool then
		tool = target
	else
		if config.backupBeforeConvert then
			makeBackup(target, lines)
		end
		tool = Instance.new("Tool")
		track(tool)
		tool.Name = target.Name
		tool.RequiresHandle = true
		tool.Parent = target.Parent
		target.Parent = tool
		table.insert(lines, ("Created Tool '%s'"):format(tool.Name))
	end

	if handle.Name ~= "Handle" then
		table.insert(lines, ("Renamed '%s' to 'Handle'"):format(handle.Name))
		handle.Name = "Handle"
	end
	if handle.Parent ~= tool then
		handle.Parent = tool
		table.insert(lines, "Moved Handle to the Tool root")
	end

	if config.unanchorParts then
		stepUnanchor(ctx.scan.parts, lines)
	end

	Selection:Set({ tool })
	return tool
end

local function stepJoints(root: Instance, handle: BasePart, parts: { BasePart }, kind: string, lines: { string })
	local unjoined = computeUnjoined(root, handle, parts)
	local suffix = kind == "Motor6D" and "_Motor" or "_Weld"
	local created = 0

	for _, part in ipairs(unjoined) do
		local base = part.Name .. suffix
		local name = base
		local counter = 1
		while handle:FindFirstChild(name) do
			counter += 1
			name = base .. counter
		end

		local joint: any
		if kind == "Motor6D" then
			joint = Instance.new("Motor6D")
			joint.Part0 = handle
			joint.Part1 = part
			joint.C0 = handle.CFrame:ToObjectSpace(part.CFrame)
		else
			joint = Instance.new("WeldConstraint")
			joint.Part0 = handle
			joint.Part1 = part
		end
		joint.Name = name
		track(joint)
		joint.Parent = handle
		created += 1
	end

	table.insert(lines, ("Created %d %s"):format(created, kind))
end

local function stepAttachment(handle: BasePart, lines: { string })
	local existing = handle:FindFirstChild("RightGripAttachment")
	if existing then
		if not existing:IsA("Attachment") then
			error("'RightGripAttachment' exists but is not an Attachment.")
		end
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "RightGripAttachment"
	attachment.Visible = true
	track(attachment)
	attachment.Parent = handle
	table.insert(lines, "Created RightGripAttachment")
end

local function stepGrip(tool: Tool, lines: { string })
	local previous = tool.Grip
	tool.Grip = buildGrip()
	table.insert(lines, "Grip applied (previous: " .. tostring(previous) .. ")")
end

local ACTIONS = {}

ACTIONS.convert = {
	title = "Convert To Tool",
	desc = "Wrap the selection in a Tool and fix its Handle",
	history = "Convert Tool",
	check = function(ctx, report)
		checkConvert(ctx, report)
	end,
	run = function(ctx, lines)
		stepConvert(ctx, lines)
	end,
}

local function makeJointAction(title: string, desc: string, history: string, kind: string)
	return {
		title = title,
		desc = desc,
		history = history,
		check = function(ctx, report)
			if not requireReadyTool(ctx, report) then
				return
			end
			checkJoints(ctx, report, kind)
		end,
		run = function(ctx, lines)
			if config.unanchorParts then
				stepUnanchor(ctx.scan.parts, lines)
			end
			stepJoints(ctx.target, ctx.handle, ctx.scan.parts, kind, lines)
		end,
	}
end

ACTIONS.motor = makeJointAction("Create Motor6D", "Joint every loose part to the Handle", "Motor6D Setup", "Motor6D")
ACTIONS.weld = makeJointAction("Create WeldConstraint", "Weld every loose part to the Handle", "Weld Setup", "WeldConstraint")

ACTIONS.attachment = {
	title = "Create Grip Attachment",
	desc = "Add RightGripAttachment to the Handle",
	history = "Create Grip Attachment",
	check = function(ctx, report)
		if not requireReadyTool(ctx, report) then
			return
		end
		checkAttachment(ctx, report)
	end,
	run = function(ctx, lines)
		stepAttachment(ctx.handle, lines)
	end,
}

ACTIONS.grip = {
	title = "Apply Default Grip",
	desc = "Set Tool.Grip from your Config values",
	history = "Apply Default Grip",
	check = function(ctx, report)
		if not requireReadyTool(ctx, report) then
			return
		end
		checkGrip(ctx, report)
	end,
	run = function(ctx, lines)
		stepGrip(ctx.target, lines)
	end,
}

ACTIONS.full = {
	title = "FULL TOOL SETUP",
	desc = "Convert + joints + grip attachment + grip",
	history = "Full Tool Setup",
	check = function(ctx, report)
		checkConvert(ctx, report)
		if #report.errors > 0 then
			return
		end
		checkJoints(ctx, report, config.fullSetupJoint)
		checkAttachment(ctx, report)
		if #report.errors > 0 then
			return
		end
		checkGrip(ctx, report)
		local tag = ctx.target:GetAttribute(CONFIGURED_ATTRIBUTE)
		if ctx.isTool and tag then
			addWarning(report, "This Tool was already configured (v" .. tostring(tag) .. ").")
		end
	end,
	run = function(ctx, lines)
		local tool = stepConvert(ctx, lines)
		local handle = tool:FindFirstChild("Handle")
		if not (handle and handle:IsA("BasePart")) then
			error("Handle missing after conversion.")
		end
		stepJoints(tool, handle, ctx.scan.parts, config.fullSetupJoint, lines)
		stepAttachment(handle, lines)
		stepGrip(tool, lines)
		if config.tagConfigured then
			tool:SetAttribute(CONFIGURED_ATTRIBUTE, VERSION)
		end
	end,
}

local function inspectSelection(action)
	local report = newReport()

	if not RunService:IsEdit() then
		addError(report, "Actions are only available in Edit mode (not while the game is running).")
		return nil, report
	end

	local selection = Selection:Get()
	if #selection == 0 then
		addError(report, "Nothing selected. Select a Model, Part or Tool in the Explorer.")
		return nil, report
	end
	if #selection > 1 then
		if config.requireSingleSelection then
			addError(report, ("%d objects selected. Select exactly one (or disable this check in Config)."):format(#selection))
			return nil, report
		else
			addWarning(report, ("%d objects selected. Only the first one is used."):format(#selection))
		end
	end

	local target = selection[1]
	checkTarget(target, report)
	if #report.errors > 0 then
		return nil, report
	end

	local scan = scanTarget(target)
	if #scan.parts == 0 then
		addError(report, "No BaseParts found inside the selection.")
	end
	if #scan.parts > config.maxParts then
		addError(report, ("%d parts exceeds the safety limit (%d). Raise 'Max parts' in Config if intended."):format(#scan.parts, config.maxParts))
	end
	if scan.humanoids > 0 then
		addError(report, "Contains a Humanoid (character/NPC). Refusing to turn it into a Tool.")
	end
	if scan.protectedInside > 0 then
		addError(report, ("%d object(s) inside are protected with '%s'."):format(scan.protectedInside, LOCK_ATTRIBUTE))
	end
	if #report.errors > 0 then
		return nil, report
	end

	if scan.nestedTools > 0 then
		addWarning(report, ("Contains %d nested Tool(s)."):format(scan.nestedTools))
	end
	if scan.packageLinks > 0 then
		addWarning(report, "Part of a Package. Edits may be reverted when the package updates.")
	end

	local ctx = {
		target = target,
		isTool = target:IsA("Tool"),
		scan = scan,
		work = {},
	}
	ctx.handle, ctx.handleSource = chooseHandle(target, scan)

	action.check(ctx, report)
	if #report.errors > 0 then
		return nil, report
	end
	return ctx, report
end

local function executeHistoryAction(actionName: string, callback: () -> ()): (boolean, any, boolean)
	local supported, recording = pcall(function()
		return ChangeHistoryService:TryBeginRecording(actionName)
	end)

	if supported then
		if not recording then
			return false, "Another undo recording is in progress. Try again in a moment.", true
		end
		local ok, err = pcall(callback)
		ChangeHistoryService:FinishRecording(
			recording,
			ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel
		)
		return ok, err, true
	end

	pcall(function()
		ChangeHistoryService:SetWaypoint("Before " .. actionName)
	end)
	local ok, err = pcall(callback)
	pcall(function()
		ChangeHistoryService:SetWaypoint(actionName)
	end)
	return ok, err, false
end

local toolbar = plugin:CreateToolbar("Synapse Tools")
local openButton = toolbar:CreateButton("SynapseToolConfig", "Open Tool Configurator", BRAND.Logo, "Tool Config")
pcall(function()
	openButton.ClickableWhenViewportHidden = true
end)

local widget = plugin:CreateDockWidgetPluginGui(
	"SynapseToolConfigurator",
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 420, 580, 340, 440)
)
widget.Title = "Synapse Tool Configurator"
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local tweenFast = DesignSystem.Motion.Fast
local tweenBounce = DesignSystem.Motion.Release

local function new(className: string, props: { [string]: any }?, parent: Instance?): any
	local inst = Instance.new(className)
	if props then
		for key, value in pairs(props) do
			(inst :: any)[key] = value
		end
	end
	inst.Parent = parent
	return inst
end

local function addCorner(inst: Instance, radius: number)
	return applyCorner(inst, radius)
end

local function addStroke(inst: Instance, key: string)
	local stroke = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, inst)
	bindTheme(stroke, "Color", key)
	return stroke
end

local function label(parent: Instance, text: string, size: number, colorKey: string, props: { [string]: any }?): TextLabel
	local l = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextSize = size,
		Font = BRAND.FontMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
	bindTheme(l, "TextColor3", colorKey)
	if props then
		for key, value in pairs(props) do
			(l :: any)[key] = value
		end
	end
	return l
end

local function animateClick(uiScale: UIScale)
	local down = TweenService:Create(uiScale, tweenFast, { Scale = 0.96 })
	local up = TweenService:Create(uiScale, tweenBounce, { Scale = 1 })
	down.Completed:Once(function()
		up:Play()
	end)
	down:Play()
end

local function attachHover(button: GuiButton, uiScale: UIScale)
	button.MouseEnter:Connect(function()
		TweenService:Create(uiScale, DesignSystem.Motion.Fast, { Scale = 1.02 }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(uiScale, DesignSystem.Motion.Fast, { Scale = 1 }):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(uiScale, DesignSystem.Motion.Press, { Scale = 0.97 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(uiScale, DesignSystem.Motion.Release, { Scale = 1 }):Play()
	end)
end

local root = new("Frame", { Name = "Root", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, widget)
bindTheme(root, "BackgroundColor3", "bg")

local header = new("Frame", { Size = UDim2.new(1, 0, 0, DesignSystem.Size.Header), BorderSizePixel = 0 }, root)
styleHeader(header)
local logo = new("ImageLabel", {
	Position = UDim2.fromOffset(10, 8),
	Size = UDim2.fromOffset(28, 28),
	BackgroundTransparency = 1,
	Image = BRAND.Logo,
}, header)
label(header, "Synapse Tool Configurator", 16, "text", {
	Position = UDim2.fromOffset(DesignSystem.Size.Header, 0),
	Size = UDim2.new(1, -120, 1, 0),
	Font = BRAND.FontBold,
})
label(header, "v" .. VERSION, 12, "sub", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 0),
	Size = UDim2.fromOffset(60, DesignSystem.Size.Header),
	TextXAlignment = Enum.TextXAlignment.Right,
})

local tabBar = new("Frame", { Position = UDim2.fromOffset(0, DesignSystem.Size.Header), Size = UDim2.new(1, 0, 0, DesignSystem.Size.Tab), BorderSizePixel = 0 }, root)
styleHeader(tabBar)

local pages = new("Frame", {
	Position = UDim2.fromOffset(0, 76),
	Size = UDim2.new(1, 0, 1, -(DesignSystem.Size.Header + DesignSystem.Size.Tab + DesignSystem.Size.Status)),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
}, root)

local statusBar = new("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1, 0, 0, DesignSystem.Size.Status),
	BorderSizePixel = 0,
}, root)
styleStatus(statusBar)
local statusLabel = label(statusBar, "Ready.", 12, "sub", {
	Position = UDim2.fromOffset(12, 0),
	Size = UDim2.new(1, -24, 1, 0),
	TextTruncate = Enum.TextTruncate.AtEnd,
})
local statusLevel = "info"

local function createPage(): ScrollingFrame
	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
	}, pages)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 16),
	}, page)
	return page
end

local toolsPage = createPage()
local configPage = createPage()
local logPage = createPage()

local tabButtons: { [string]: TextButton } = {}
local tabPages = { Tools = toolsPage, Config = configPage, Log = logPage }
local tabOrder = { "Tools", "Config", "Log" }
local currentTab = "Tools"

local function refreshTabs()
	for name, button in pairs(tabButtons) do
		local active = name == currentTab
		button.TextColor3 = active and themeColor("text") or themeColor("sub")
		button.Underline.Visible = active
		tabPages[name].Visible = active
	end
end

for index, name in ipairs(tabOrder) do
	local button = new("TextButton", {
		Name = name,
		Text = name,
		TextSize = 13,
		Font = BRAND.FontSemibold,
		BackgroundTransparency = 1,
		Size = UDim2.new(1 / #tabOrder, 0, 1, 0),
		Position = UDim2.new((index - 1) / #tabOrder, 0, 0, 0),
	}, tabBar)
	new("Frame", {
		Name = "Underline",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0.1, 1),
		Size = UDim2.new(0.8, 0, 0, 2),
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
	}, button)
	button.MouseButton1Click:Connect(function()
		currentTab = name
		refreshTabs()
	end)
	tabButtons[name] = button
end
table.insert(refreshers, refreshTabs)

local function addSection(parent: Instance, order: number, text: string)
	label(parent, string.upper(text), 11, "sub", {
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 18),
		Font = BRAND.FontBold,
	})
end

local function createCard(parent: Instance, order: number, height: number): Frame
	local card = new("Frame", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, height), BorderSizePixel = 0 }, parent)
	bindTheme(card, "BackgroundColor3", "card")
	addCorner(card, 8)
	addStroke(card, "border")
	return card
end

local function createSmallButton(parent: Instance, text: string, props: { [string]: any }?): TextButton
	local button = new("TextButton", {
		Text = text,
		TextSize = 13,
		Font = BRAND.FontSemibold,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, parent)
	bindTheme(button, "BackgroundColor3", "button")
	bindTheme(button, "TextColor3", "buttonText")
	addCorner(button, 6)
	addStroke(button, "border")
	if props then
		for key, value in pairs(props) do
			button[key] = value
		end
	end
	attachHover(button, new("UIScale", nil, button))
	return button
end

local function addToggle(parent: Instance, order: number, title: string, desc: string, key: string)
	local row = createCard(parent, order, 58)
	label(row, title, 13, "text", {
		Position = UDim2.fromOffset(12, 7),
		Size = UDim2.new(1, -72, 0, 17),
		Font = BRAND.FontSemibold,
	})
	label(row, desc, 11, "sub", {
		Position = UDim2.fromOffset(12, 25),
		Size = UDim2.new(1, -72, 0, 28),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(38, 20),
		BorderSizePixel = 0,
	}, row)
	addCorner(track, 10)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
	}, track)
	addCorner(knob, 8)
	local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "" }, row)

	local function refresh(animate: boolean)
		local on = config[key]
		track.BackgroundColor3 = on and ACCENT or themeColor("border")
		local position = on and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		if animate then
			TweenService:Create(knob, tweenFast, { Position = position }):Play()
		else
			knob.Position = position
		end
	end

	hit.MouseButton1Click:Connect(function()
		config[key] = not config[key]
		saveConfig()
		refresh(true)
	end)
	table.insert(refreshers, function()
		refresh(false)
	end)
	refresh(false)
end

local function formatNumber(value: number): string
	return tostring(math.round(value * 100) / 100)
end

local function addNumberGroup(parent: Instance, order: number, title: string, desc: string, keys: { string }, hints: { string })
	local row = createCard(parent, order, 58)
	local boxWidth, gap = 46, 4
	local total = #keys * boxWidth + (#keys - 1) * gap

	label(row, title, 13, "text", {
		Position = UDim2.fromOffset(12, 7),
		Size = UDim2.new(1, -(total + 30), 0, 17),
		Font = BRAND.FontSemibold,
	})
	label(row, desc, 11, "sub", {
		Position = UDim2.fromOffset(12, 25),
		Size = UDim2.new(1, -(total + 30), 0, 28),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	for index, key in ipairs(keys) do
		local box = new("TextBox", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12 - (#keys - index) * (boxWidth + gap), 0.5, 0),
			Size = UDim2.fromOffset(boxWidth, 26),
			PlaceholderText = hints[index],
			ClearTextOnFocus = false,
			TextSize = 12,
			Font = BRAND.FontMedium,
			BorderSizePixel = 0,
			Text = formatNumber(config[key]),
		}, row)
		bindTheme(box, "BackgroundColor3", "input")
		bindTheme(box, "TextColor3", "text")
		addCorner(box, 5)
		addStroke(box, "border")

		box.FocusLost:Connect(function()
			local number = tonumber(box.Text)
			if number then
				config[key] = sanitizeValue(key, number)
				saveConfig()
			end
			box.Text = formatNumber(config[key])
		end)
		table.insert(refreshers, function()
			box.Text = formatNumber(config[key])
		end)
	end
end

local function addCycle(parent: Instance, order: number, title: string, desc: string, key: string, options: { string })
	local row = createCard(parent, order, 58)
	label(row, title, 13, "text", {
		Position = UDim2.fromOffset(12, 7),
		Size = UDim2.new(1, -150, 0, 17),
		Font = BRAND.FontSemibold,
	})
	label(row, desc, 11, "sub", {
		Position = UDim2.fromOffset(12, 25),
		Size = UDim2.new(1, -150, 0, 28),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	local button = createSmallButton(row, config[key], {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(120, 28),
	})
	button.MouseButton1Click:Connect(function()
		local index = table.find(options, config[key]) or 0
		config[key] = options[(index % #options) + 1]
		saveConfig()
		button.Text = config[key]
	end)
	table.insert(refreshers, function()
		button.Text = config[key]
	end)
end

local infoCard = createCard(toolsPage, 1, 70)
local infoScale = new("UIScale", nil, infoCard)
local dot = new("Frame", { Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(10, 10), BorderSizePixel = 0 }, infoCard)
addCorner(dot, 5)
local selName = label(infoCard, "Selected: None", 14, "text", {
	Position = UDim2.fromOffset(32, 8),
	Size = UDim2.new(1, -44, 0, 20),
	Font = BRAND.FontBold,
	TextTruncate = Enum.TextTruncate.AtEnd,
})
local selDetail = label(infoCard, "", 12, "sub", {
	Position = UDim2.fromOffset(14, 32),
	Size = UDim2.new(1, -28, 0, 32),
	TextWrapped = true,
	TextYAlignment = Enum.TextYAlignment.Top,
})

addSection(toolsPage, 2, "Actions")

local actionButtons: { [string]: TextButton } = {}
local allButtons: { GuiButton } = {}

local function createActionButton(order: number, key: string, accent: boolean?)
	local action = ACTIONS[key]
	local button = new("TextButton", {
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 54),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, toolsPage)
	if accent then
		button.BackgroundColor3 = ACCENT
	else
		bindTheme(button, "BackgroundColor3", "button")
	end
	addCorner(button, 8)
	if accent then
		new("UIStroke", { Color = Color3.fromRGB(60, 160, 255), Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, button)
	else
		addStroke(button, "border")
	end

	local titleLabel = label(button, action.title, 14, accent and "text" or "buttonText", {
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -28, 0, 18),
		Font = BRAND.FontBold,
	})
	local descLabel = label(button, action.desc, 11, accent and "text" or "sub", {
		Position = UDim2.fromOffset(14, 29),
		Size = UDim2.new(1, -28, 0, 16),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	if accent then

		for i = #themeBindings, 1, -1 do
			local b = themeBindings[i]
			if b.inst == titleLabel or b.inst == descLabel then
				table.remove(themeBindings, i)
			end
		end
		titleLabel.TextColor3 = WHITE
		descLabel.TextColor3 = Color3.fromRGB(220, 235, 255)
	end

	attachHover(button, new("UIScale", nil, button))
	actionButtons[key] = button
	table.insert(allButtons, button)
	return button
end

createActionButton(3, "convert")
createActionButton(4, "motor")
createActionButton(5, "weld")
createActionButton(6, "attachment")
createActionButton(7, "grip")
createActionButton(8, "full", true)

addSection(toolsPage, 9, "Protection")

local lockRow = new("Frame", { LayoutOrder = 10, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1 }, toolsPage)
local lockButton = createSmallButton(lockRow, "Lock Selected", { Size = UDim2.new(0.5, -4, 1, 0) })
local unlockButton = createSmallButton(lockRow, "Unlock Selected", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0),
	Size = UDim2.new(0.5, -4, 1, 0),
})
table.insert(allButtons, lockButton)
table.insert(allButtons, unlockButton)

label(toolsPage, "Nothing is ever deleted. Every action is one undo (Ctrl+Z). Locked objects get the '" .. LOCK_ATTRIBUTE .. "' attribute and are ignored by all actions.", 11, "sub", {
	LayoutOrder = 11,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	TextWrapped = true,
	TextYAlignment = Enum.TextYAlignment.Top,
})

addSection(configPage, 1, "Safety")
addToggle(configPage, 2, "Confirm every action", "Ask before running. Warnings always ask.", "confirmActions")
addToggle(configPage, 3, "Require single selection", "Refuse when several objects are selected.", "requireSingleSelection")
addToggle(configPage, 4, "Backup before convert", "Clone the original into ServerStorage (keeps last " .. MAX_BACKUPS .. ").", "backupBeforeConvert")
addToggle(configPage, 5, "Tag configured tools", "Set the '" .. CONFIGURED_ATTRIBUTE .. "' attribute after Full Setup.", "tagConfigured")
addNumberGroup(configPage, 6, "Max parts", "Refuse objects with more parts than this.", { "maxParts" }, { "500" })

addSection(configPage, 7, "Behavior")
addToggle(configPage, 8, "Unanchor parts", "Anchored parts do not follow the hand.", "unanchorParts")
addCycle(configPage, 9, "Full Setup joint", "Joint type used by FULL TOOL SETUP.", "fullSetupJoint", JOINT_TYPES)
addToggle(configPage, 10, "Verbose log", "Also log what each action will do.", "verboseLog")

addSection(configPage, 11, "Default grip")
addNumberGroup(configPage, 12, "Position", "Grip offset (studs): X, Y, Z.", { "gripPX", "gripPY", "gripPZ" }, { "X", "Y", "Z" })
addNumberGroup(configPage, 13, "Rotation", "Grip rotation (degrees): X, Y, Z.", { "gripRX", "gripRY", "gripRZ" }, { "X", "Y", "Z" })

addSection(configPage, 14, "Maintenance")
local resetButton = createSmallButton(configPage, "Reset settings to defaults", {
	LayoutOrder = 15,
	Size = UDim2.new(1, 0, 0, 36),
})
table.insert(allButtons, resetButton)

local clearLogButton = createSmallButton(logPage, "Clear log", { LayoutOrder = -100000, Size = UDim2.new(1, 0, 0, 30) })
local logEntries: { { label: TextLabel, level: string } } = {}
local logCounter = 0

local overlay = new("TextButton", {
	Name = "Overlay",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	Active = true,
	Visible = false,
	ZIndex = 10,
}, root)

local dialog = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, -32, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BorderSizePixel = 0,
	ZIndex = 11,
}, overlay)
bindTheme(dialog, "BackgroundColor3", "bg")
addCorner(dialog, 10)
addStroke(dialog, "border")
new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, dialog)
new("UIPadding", {
	PaddingTop = UDim.new(0, 14),
	PaddingBottom = UDim.new(0, 14),
	PaddingLeft = UDim.new(0, 14),
	PaddingRight = UDim.new(0, 14),
}, dialog)

local dialogTitle = label(dialog, "", 15, "text", {
	LayoutOrder = 1,
	Size = UDim2.new(1, 0, 0, 20),
	Font = BRAND.FontBold,
	ZIndex = 12,
})
local dialogMessage = label(dialog, "", 12, "sub", {
	LayoutOrder = 2,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	TextWrapped = true,
	TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 12,
})
local dialogButtons = new("Frame", { LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ZIndex = 12 }, dialog)
local cancelButton = createSmallButton(dialogButtons, "Cancel", { Size = UDim2.new(0.5, -4, 1, 0), ZIndex = 12 })
local confirmButton = createSmallButton(dialogButtons, "Run", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0),
	Size = UDim2.new(0.5, -4, 1, 0),
	ZIndex = 12,
})
confirmButton.TextColor3 = WHITE

local busy = false
local pendingConfirm: BindableEvent? = nil
local connections: { RBXScriptConnection } = {}

local function connect(signal: RBXScriptSignal, callback: (...any) -> ()): RBXScriptConnection
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end

local function setStatus(level: string, text: string)
	statusLevel = level
	statusLabel.Text = text
	statusLabel.TextColor3 = levelColor(level)
end

local function logMessage(level: string, text: string)
	logCounter += 1
	local prefixes = { ok = "OK", warn = "WARN", error = "ERROR", info = "INFO" }
	local entryLabel = new("TextLabel", {
		LayoutOrder = -logCounter,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = ("[%s] %s  %s"):format(os.date("%H:%M:%S"), prefixes[level] or "INFO", text),
		TextSize = 12,
		Font = Enum.Font.Code,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = levelColor(level),
	}, logPage)
	table.insert(logEntries, { label = entryLabel, level = level })
	while #logEntries > MAX_LOG_ENTRIES do
		table.remove(logEntries, 1).label:Destroy()
	end
end

local function say(level: string, text: string)
	logMessage(level, text)
	setStatus(level, text)
end

local function setBusy(value: boolean)
	busy = value
	for _, button in ipairs(allButtons) do
		button.Active = not value
		button.BackgroundTransparency = value and 0.5 or 0
	end
end

local function refreshInfo()
	local selection = Selection:Get()
	if #selection == 0 then
		selName.Text = "Selected: None"
		selDetail.Text = "Select a Model, Part or Tool in the Explorer."
		dot.BackgroundColor3 = themeColor("sub")
		return
	end

	local target = selection[1]
	local extra = #selection > 1 and (" (+%d more)"):format(#selection - 1) or ""
	selName.Text = "Selected: " .. target.Name .. extra

	local report = newReport()
	checkTarget(target, report)
	if #report.errors > 0 then
		selDetail.Text = report.errors[1]
		dot.BackgroundColor3 = themeColor("err")
	elseif #selection > 1 and config.requireSingleSelection then
		selDetail.Text = "Select exactly one object (see Config)."
		dot.BackgroundColor3 = themeColor("warn")
	else
		local state = target:IsA("Tool") and "Tool - ready to configure." or "Not a Tool yet - use Convert To Tool."
		selDetail.Text = target.ClassName .. ". " .. state
		dot.BackgroundColor3 = SUCCESS
	end
end

local function applyTheme()
	for _, binding in ipairs(themeBindings) do
		pcall(function()
			binding.inst[binding.prop] = themeColor(binding.key)
		end)
	end
	statusLabel.TextColor3 = levelColor(statusLevel)
	for _, entry in ipairs(logEntries) do
		entry.label.TextColor3 = levelColor(entry.level)
	end
	for _, refresh in ipairs(refreshers) do
		refresh()
	end
	refreshInfo()
end

local function confirm(title: string, message: string, confirmText: string, danger: boolean): boolean
	if pendingConfirm then
		return false
	end

	local event = Instance.new("BindableEvent")
	pendingConfirm = event
	dialogTitle.Text = title
	dialogMessage.Text = message
	confirmButton.Text = confirmText
	confirmButton.BackgroundColor3 = danger and DANGER or ACCENT
	overlay.Visible = true

	local result = event.Event:Wait()

	overlay.Visible = false
	pendingConfirm = nil
	event:Destroy()
	return result == true
end

confirmButton.MouseButton1Click:Connect(function()
	if pendingConfirm then
		pendingConfirm:Fire(true)
	end
end)
cancelButton.MouseButton1Click:Connect(function()
	if pendingConfirm then
		pendingConfirm:Fire(false)
	end
end)

local function buildMessage(ctx, report): string
	local lines = { ("Target: %s (%s)"):format(ctx.target.Name, ctx.target.ClassName) }
	if #report.notes > 0 then
		table.insert(lines, "")
		table.insert(lines, "This will:")
		for _, note in ipairs(report.notes) do
			table.insert(lines, "  - " .. note)
		end
	end
	if #report.warnings > 0 then
		table.insert(lines, "")
		table.insert(lines, "Warnings:")
		for _, warning in ipairs(report.warnings) do
			table.insert(lines, "  ! " .. warning)
		end
	end
	if #lines > 16 then
		local extra = #lines - 15
		lines = { table.unpack(lines, 1, 15) }
		table.insert(lines, ("  ...and %d more line(s)"):format(extra))
	end
	table.insert(lines, "")
	table.insert(lines, "You can undo this with Ctrl+Z.")
	return table.concat(lines, "\n")
end

local function runActionInner(key: string)
	local action = ACTIONS[key]
	local ctx, report = inspectSelection(action)

	if not ctx then
		for _, message in ipairs(report.errors) do
			say("error", action.title .. ": " .. message)
		end
		return
	end

	if config.verboseLog then
		for _, note in ipairs(report.notes) do
			logMessage("info", action.title .. ": " .. note)
		end
	end
	for _, warning in ipairs(report.warnings) do
		logMessage("warn", action.title .. ": " .. warning)
	end

	if next(ctx.work) == nil then
		say("info", action.title .. ": nothing to do, already set up.")
		return
	end

	if config.confirmActions or #report.warnings > 0 then
		local accepted = confirm(action.title, buildMessage(ctx, report), "Run", #report.warnings > 0)
		if not accepted then
			say("info", action.title .. ": cancelled.")
			return
		end

		local current = Selection:Get()[1]
		if current ~= ctx.target or not ctx.target.Parent then
			say("error", action.title .. ": selection changed while confirming. Aborted, nothing was modified.")
			return
		end
	end

	createdThisAction = {}
	local lines: { string } = {}
	local ok, err, canRollback = executeHistoryAction(action.history, function()
		action.run(ctx, lines)
	end)
	createdThisAction = {}

	if ok then
		for _, line in ipairs(lines) do
			logMessage("ok", line)
		end
		setStatus("ok", action.title .. ": done. (Ctrl+Z to undo)")
	elseif canRollback then
		say("error", action.title .. " failed and was rolled back: " .. tostring(err))
	else
		say("error", action.title .. " failed (could not auto-rollback, use Ctrl+Z): " .. tostring(err))
	end
end

local function guarded(callback: (...any) -> (), ...: any)
	if busy then
		return
	end
	setBusy(true)
	local ok, err = pcall(callback, ...)
	setBusy(false)
	if not ok then
		say("error", "Unexpected error: " .. tostring(err))
	end
	refreshInfo()
end

for key, button in pairs(actionButtons) do
	button.MouseButton1Click:Connect(function()
		guarded(runActionInner, key)
	end)
end

local function runLockInner(lock: boolean)
	if not RunService:IsEdit() then
		say("error", "Only available in Edit mode.")
		return
	end

	local items = {}
	for _, inst in ipairs(Selection:Get()) do
		local blocked = inst == game or inst.Parent == game or inst:IsA("Terrain") or inst:IsA("Camera")
		if not blocked and (lock and inst:GetAttribute(LOCK_ATTRIBUTE) ~= true or (not lock and inst:GetAttribute(LOCK_ATTRIBUTE) == true)) then
			table.insert(items, inst)
		end
	end

	if #items == 0 then
		say("info", lock and "Nothing to lock (nothing selected, already locked, or protected service)." or "No selected object has the lock attribute.")
		return
	end

	if not lock or config.confirmActions then
		local names = {}
		for index, inst in ipairs(items) do
			if index > 8 then
				table.insert(names, ("  ...and %d more"):format(#items - 8))
				break
			end
			table.insert(names, "  - " .. inst.Name)
		end
		local verb = lock and "Lock" or "Unlock"
		local message = ("%s %d object(s)?\n\n%s\n\nUndo with Ctrl+Z."):format(verb, #items, table.concat(names, "\n"))
		if not confirm(verb .. " Selected", message, verb, not lock) then
			say("info", verb .. ": cancelled.")
			return
		end
	end

	local ok, err, canRollback = executeHistoryAction(lock and "Lock Objects" or "Unlock Objects", function()
		for _, inst in ipairs(items) do
			inst:SetAttribute(LOCK_ATTRIBUTE, lock and true or nil)
		end
	end)

	if ok then
		say("ok", ("%s %d object(s)."):format(lock and "Locked" or "Unlocked", #items))
	else
		say("error", (lock and "Lock" or "Unlock") .. " failed" .. (canRollback and " and was rolled back" or "") .. ": " .. tostring(err))
	end
end

lockButton.MouseButton1Click:Connect(function()
	guarded(runLockInner, true)
end)
unlockButton.MouseButton1Click:Connect(function()
	guarded(runLockInner, false)
end)

resetButton.MouseButton1Click:Connect(function()
	guarded(function()
		if confirm("Reset settings", "Restore ALL settings to their defaults?\n\nYour game is not affected.", "Reset", true) then
			config = table.clone(DEFAULT_CONFIG)
			saveConfig()
			for _, refresh in ipairs(refreshers) do
				refresh()
			end
			say("ok", "Settings restored to defaults.")
		end
	end)
end)

clearLogButton.MouseButton1Click:Connect(function()
	for _, entry in ipairs(logEntries) do
		entry.label:Destroy()
	end
	table.clear(logEntries)
end)

openButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

connect(widget:GetPropertyChangedSignal("Enabled"), function()
	openButton:SetActive(widget.Enabled)
	if not widget.Enabled and pendingConfirm then
		pendingConfirm:Fire(false)
	end
end)

connect(Selection.SelectionChanged, function()
	animateClick(infoScale)
	refreshInfo()
end)

connect(settings().Studio.ThemeChanged, applyTheme)

connect(plugin.Unloading, function()
	if pendingConfirm then
		pendingConfirm:Fire(false)
	end
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
	root:Destroy()
end)

applyTheme()
say("info", ("Synapse Tool Configurator v%s ready."):format(VERSION))
