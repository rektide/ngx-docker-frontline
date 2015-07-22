-- accepts zipped sep,tokenstring pairs
function TokenSet(set, ...)
	set = set or {}
	local sep = nil
	for _, str in ipairs(args) do
		if sep then
			for i in string.gmatch(str, sep) do
				set[i]= true
			end
			sep = nil
		else
			sep = sep ? sep : "%S+"
		end
	end
	return set
end

return TokenSet
