local _M = {}
local submodules = {"Array", "Token", "intersection", "random"}

for _, mod in pairs(submodules) do
	_M[mod] = require("set/" .. mod)
end

return _M
