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
	if labels and #labels != 0 then
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
				if #matches == 0 then
					return nil, "nothing at intersection "
				end
			else
				-- no entry for this label, throw base xception
				return nil, "label not fond"
			end
		end
	else
		-- signal that no matching is required
		return nil
	end
	return matches
end

-- pick one entry and lookup contact details
function pickRandom(matches, err)
	if err then
		return nil, err
	elseif matches then
		-- Pick a random element from the set of hosts
		return Set.random(matches)
	else
		-- all hosts are candidates
		local n = ngx.shared.ndf_config.get("all_size")
		n = math.random(n)
		return ngx.shared.ndf_all.get(n)
	end
end

function resolveId(id)
	return ngx.shared.ndf_hostport.get(id), ngx.shared.ndf_containerHosts.get(id)
end

return {
	labels=labels,
	matcher=matcher,
	pickRandom=pickRandom,
	resolveId=resolveId
}
