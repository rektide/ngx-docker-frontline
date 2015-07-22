function SetIntersection(destructive, ...)
	local result = nil
	for _, set in ipairs(args) do
		if not set then
			-- skip empty entries entirely
		elseif not result then
			-- first entry, copy in
			result = destructive ? set : {}
			if not destructive then
				for key, _ in pairs(set) do
					result[key] = key
				end
			end
		else 
			-- check each existing against new set
			for key, val in pairs(result) do
				if not set[key] then
					result[key] = nil
				else
					result[key] = val
				end
			end
			-- if empty, abort
			if #result = 0 then
				return nil
			end
		end
	end
	return result
end

return SetIntersection
