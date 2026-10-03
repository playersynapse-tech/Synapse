return function(R)
	local plugin = R.plugin
	local VERSION = R.VERSION
	local Selection = R.Selection
	local RunService = R.RunService
	local LOCK_ATTRIBUTE = R.LOCK_ATTRIBUTE
	local DEFAULT_CONFIG = R.DEFAULT_CONFIG
	local config = R.config
	local saveConfig = R.saveConfig
	local refreshers = R.refreshers
	local createdThisAction = R.createdThisAction
	local ACTIONS = R.ACTIONS
	local inspectSelection = R.inspectSelection
	local executeHistoryAction = R.executeHistoryAction
	local say = R.say
	local logMessage = R.logMessage
	local setStatus = R.setStatus
	local setBusy = R.setBusy
	local isBusy = R.isBusy
	local refreshInfo = R.refreshInfo
	local confirm = R.confirm
	local cancelPendingConfirm = R.cancelPendingConfirm
	local actionButtons = R.actionButtons
	local lockButton = R.lockButton
	local unlockButton = R.unlockButton
	local resetButton = R.resetButton
	local clearLogButton = R.clearLogButton
	local logEntries = R.logEntries
	local openButton = R.openButton
	local widget = R.widget
	local connect = R.connect
	local animateClick = R.animateClick
	local infoScale = R.infoScale
	local connections = R.connections
	local root = R.root
	local applyTheme = R.applyTheme

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
		table.insert(lines, "Undo this action with the Studio Undo command.")
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

		table.clear(createdThisAction)
		local lines: { string } = {}
		local ok, err, canRollback = executeHistoryAction(action.history, function()
			action.run(ctx, lines)
		end)
		table.clear(createdThisAction)

		if ok then
			for _, line in ipairs(lines) do
				logMessage("ok", line)
			end
			setStatus("ok", action.title .. ": done. (Undo is available in Studio.)")
		elseif canRollback then
			say("error", action.title .. " failed and was rolled back: " .. tostring(err))
		else
			say("error", action.title .. " failed (could not auto-rollback; use Studio Undo): " .. tostring(err))
		end
	end

	local function guarded(callback: (...any) -> (), ...: any)
		if isBusy() then
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
			local message = ("%s %d object(s)?\n\n%s\n\nUndo with the Studio Undo command."):format(verb, #items, table.concat(names, "\n"))
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
				table.clear(config)
				for key, value in pairs(DEFAULT_CONFIG) do
					config[key] = value
				end
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
		if not widget.Enabled then
			cancelPendingConfirm()
		end
	end)

	connect(Selection.SelectionChanged, function()
		animateClick(infoScale)
		refreshInfo()
	end)

	connect(settings().Studio.ThemeChanged, applyTheme)

	connect(plugin.Unloading, function()
		cancelPendingConfirm()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		table.clear(connections)
		root:Destroy()
	end)

	applyTheme()
	say("info", ("Synapse Tool Configurator v%s ready."):format(VERSION))
	R.buildMessage = buildMessage
	R.runActionInner = runActionInner
	R.guarded = guarded
	R.runLockInner = runLockInner
end

