-- set helper from Programming in Lua
function ListSet (set, ...)
	set = set or {}
	for _, list in ipairs(arg) do
		for _, val in ipairs(list) do
			set[val] = true
		end
	end
	return set
end

return ListSet
