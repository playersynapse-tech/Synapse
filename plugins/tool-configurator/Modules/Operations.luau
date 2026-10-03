return function(R)
	local ChangeHistoryService = R.ChangeHistoryService
	local Selection = R.Selection
	local RunService = R.RunService
	local ServerStorage = R.ServerStorage
	local VERSION = R.VERSION
	local LOG_PREFIX = R.LOG_PREFIX
	local LOCK_ATTRIBUTE = R.LOCK_ATTRIBUTE
	local CONFIGURED_ATTRIBUTE = R.CONFIGURED_ATTRIBUTE
	local BACKUP_ATTRIBUTE = R.BACKUP_ATTRIBUTE
	local BACKUP_TIME_ATTRIBUTE = R.BACKUP_TIME_ATTRIBUTE
	local BACKUP_FOLDER_NAME = R.BACKUP_FOLDER_NAME
	local MAX_BACKUPS = R.MAX_BACKUPS
	local config = R.config
	local DEFAULT_CONFIG = R.DEFAULT_CONFIG
	local CONFIG_RANGES = R.CONFIG_RANGES
	local JOINT_TYPES = R.JOINT_TYPES
	local ACCENT = R.ACCENT
	local SUCCESS = R.SUCCESS
	local DANGER = R.DANGER
	local WHITE = R.WHITE
	local themeColor = R.themeColor

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

	R.levelColor = levelColor
	R.newReport = newReport
	R.addError = addError
	R.addWarning = addWarning
	R.addNote = addNote
	R.createdThisAction = createdThisAction
	R.track = track
	R.safeDestroy = safeDestroy
	R.isLocked = isLocked
	R.checkTarget = checkTarget
	R.scanTarget = scanTarget
	R.chooseHandle = chooseHandle
	R.buildGrip = buildGrip
	R.computeUnjoined = computeUnjoined
	R.requireReadyTool = requireReadyTool
	R.checkConvert = checkConvert
	R.checkJoints = checkJoints
	R.checkAttachment = checkAttachment
	R.checkGrip = checkGrip
	R.makeBackup = makeBackup
	R.stepUnanchor = stepUnanchor
	R.stepConvert = stepConvert
	R.stepJoints = stepJoints
	R.stepAttachment = stepAttachment
	R.stepGrip = stepGrip
	R.ACTIONS = ACTIONS
	R.inspectSelection = inspectSelection
	R.executeHistoryAction = executeHistoryAction
end

