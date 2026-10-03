return function(R)
	local plugin = R.plugin
	local BRAND = R.BRAND
	local DesignSystem = R.DesignSystem
	local TweenService = R.TweenService
	local VERSION = R.VERSION
	local applyCorner = R.applyCorner
	local bindTheme = R.bindTheme
	local styleHeader = R.styleHeader
	local styleStatus = R.styleStatus

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

	R.toolbar = toolbar
	R.openButton = openButton
	R.widget = widget
	R.tweenFast = tweenFast
	R.tweenBounce = tweenBounce
	R.new = new
	R.addCorner = addCorner
	R.addStroke = addStroke
	R.label = label
	R.animateClick = animateClick
	R.attachHover = attachHover
	R.root = root
	R.header = header
	R.logo = logo
	R.tabBar = tabBar
	R.pages = pages
	R.statusBar = statusBar
	R.statusLabel = statusLabel
	R.statusLevel = statusLevel
end

