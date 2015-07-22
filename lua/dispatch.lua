local Set = require("set")
local Cookie = require("resty.cookie")

-- find labels being asked for
function labels()
	local cookie = Cookie:new()
	local headers = ngx.request.get_headers()
	local labels = Set.Token(nil,
		nil, headers["Frontline-Label"],
		",", cookie:get("Frontline-Label"))
end

-- from a list of labels, find all matching container ids
function matcher(labels, matches)
	if labels and #labels then
		-- find servers satisfying all labels
		for label, _ in pairs(labels) do
			-- lookup all containers for label
			local containers = ngx.shared.ndf_labels.get(label)
			if containers then
				-- todo, memoize against config store version
				containers = Set.Token(containers)
				-- run intersection against existing matches
				-- (works in first pass because nil sets are skipped)
				matches = Set.intersection(true, matches, containers)
			else
				return
			end
		end
	else
		-- all servers
		-- matches = ngx.shared.ndf_all
	end
	return matches
end

return {
	labels=labels,
	matcher=matcher
}
