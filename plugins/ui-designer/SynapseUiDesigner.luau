if not plugin then
	return
end

local R = {
	plugin = plugin,
}

local Modules = script:WaitForChild("Modules")

require(Modules.Foundation)(R)
require(Modules.UIBase)(R)
require(Modules.InspectorEvents)(R)
require(Modules.Editor)(R)
require(Modules.Timeline)(R)
require(Modules.Animation)(R)
require(Modules.Library)(R)
require(Modules.Windows)(R)
require(Modules.ObjectsEffects)(R)
require(Modules.InputToolbar)(R)
