if not plugin then
	return
end

local R = { plugin = plugin }
local Modules = script:WaitForChild("Modules")

require(Modules.Foundation)(R)
require(Modules.Operations)(R)
require(Modules.UIBase)(R)
require(Modules.Windows)(R)
require(Modules.InputToolbar)(R)