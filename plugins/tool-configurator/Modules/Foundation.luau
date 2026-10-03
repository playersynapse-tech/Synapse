return function(R)
	local plugin = R.plugin
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
		bg = DesignSystem.Color.Background,
		card = DesignSystem.Color.Surface,
		text = DesignSystem.Color.Text,
		sub = DesignSystem.Color.TextMuted,
		border = DesignSystem.Color.Border,
		button = DesignSystem.Color.SurfaceAlt,
		buttonText = DesignSystem.Color.Text,
		input = DesignSystem.Color.Surface,
		warn = DesignSystem.Color.Warning,
		err = DesignSystem.Color.Danger,
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

	R.ChangeHistoryService = ChangeHistoryService
	R.Selection = Selection
	R.TweenService = TweenService
	R.RunService = RunService
	R.ServerStorage = ServerStorage
	R.VERSION = VERSION
	R.LOG_PREFIX = LOG_PREFIX
	R.LOCK_ATTRIBUTE = LOCK_ATTRIBUTE
	R.CONFIGURED_ATTRIBUTE = CONFIGURED_ATTRIBUTE
	R.BACKUP_ATTRIBUTE = BACKUP_ATTRIBUTE
	R.BACKUP_TIME_ATTRIBUTE = BACKUP_TIME_ATTRIBUTE
	R.BACKUP_FOLDER_NAME = BACKUP_FOLDER_NAME
	R.MAX_BACKUPS = MAX_BACKUPS
	R.MAX_LOG_ENTRIES = MAX_LOG_ENTRIES
	R.SETTINGS_KEY = SETTINGS_KEY
	R.BRAND = BRAND
	R.DesignSystem = DesignSystem
	R.applyCorner = applyCorner
	R.applyBorder = applyBorder
	R.styleSurface = styleSurface
	R.styleButton = styleButton
	R.styleInput = styleInput
	R.styleTab = styleTab
	R.styleHeader = styleHeader
	R.styleStatus = styleStatus
	R.ACCENT = ACCENT
	R.SUCCESS = SUCCESS
	R.DANGER = DANGER
	R.WHITE = WHITE
	R.DEFAULT_CONFIG = DEFAULT_CONFIG
	R.CONFIG_RANGES = CONFIG_RANGES
	R.JOINT_TYPES = JOINT_TYPES
	R.config = config
	R.sanitizeValue = sanitizeValue
	R.saveConfig = saveConfig
	R.loadConfig = loadConfig
	R.THEME = THEME
	R.themeColor = themeColor
	R.themeBindings = themeBindings
	R.refreshers = refreshers
	R.bindTheme = bindTheme
end

