return function(R)
	local Selection = R.Selection
	local TweenService = R.TweenService
	local VERSION = R.VERSION
	local LOCK_ATTRIBUTE = R.LOCK_ATTRIBUTE
	local CONFIGURED_ATTRIBUTE = R.CONFIGURED_ATTRIBUTE
	local MAX_BACKUPS = R.MAX_BACKUPS
	local MAX_LOG_ENTRIES = R.MAX_LOG_ENTRIES
	local BRAND = R.BRAND
	local DesignSystem = R.DesignSystem
	local styleHeader = R.styleHeader
	local ACCENT = R.ACCENT
	local SUCCESS = R.SUCCESS
	local DANGER = R.DANGER
	local WHITE = R.WHITE
	local DEFAULT_CONFIG = R.DEFAULT_CONFIG
	local JOINT_TYPES = R.JOINT_TYPES
	local config = R.config
	local sanitizeValue = R.sanitizeValue
	local saveConfig = R.saveConfig
	local themeColor = R.themeColor
	local themeBindings = R.themeBindings
	local refreshers = R.refreshers
	local bindTheme = R.bindTheme
	local levelColor = R.levelColor
	local newReport = R.newReport
	local checkTarget = R.checkTarget
	local ACTIONS = R.ACTIONS
	local tweenFast = R.tweenFast
	local new = R.new
	local addCorner = R.addCorner
	local addStroke = R.addStroke
	local label = R.label
	local attachHover = R.attachHover
	local root = R.root
	local tabBar = R.tabBar
	local pages = R.pages
	local statusLabel = R.statusLabel
	local statusLevel = R.statusLevel

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
		addCorner(card, DesignSystem.Radius.Medium)
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
			new("UIStroke", { Color = BRAND.Accent, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, button)
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
			descLabel.TextColor3 = themeColor("text")
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

	label(toolsPage, "Nothing is ever deleted. Every action can be undone in Studio. Locked objects get the '" .. LOCK_ATTRIBUTE .. "' attribute and are ignored by all actions.", 11, "sub", {
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
			local removed = table.remove(logEntries, 1)
			if removed then
				removed.label:Destroy()
			end
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

	local function cancelPendingConfirm()
		if pendingConfirm then
			pendingConfirm:Fire(false)
		end
	end

	local function isBusy()
		return busy
	end

	R.toolsPage = toolsPage
	R.configPage = configPage
	R.logPage = logPage
	R.tabButtons = tabButtons
	R.tabPages = tabPages
	R.currentTab = currentTab
	R.actionButtons = actionButtons
	R.allButtons = allButtons
	R.infoScale = infoScale
	R.lockButton = lockButton
	R.unlockButton = unlockButton
	R.resetButton = resetButton
	R.clearLogButton = clearLogButton
	R.logEntries = logEntries
	R.connections = connections
	R.setStatus = setStatus
	R.logMessage = logMessage
	R.say = say
	R.setBusy = setBusy
	R.isBusy = isBusy
	R.refreshInfo = refreshInfo
	R.applyTheme = applyTheme
	R.confirm = confirm
	R.connect = connect
	R.cancelPendingConfirm = cancelPendingConfirm
end

