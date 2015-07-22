local cjson = require "resty.libcjson"

-- extract request --
-- read ContainerHost info
local headers = ngx.request.get_headers()
local containerHost = headers["Frontline-ContainerHost"]

if hostname == nil then
	ngx.log(ngx.ERR, "InspectContainer had no ContainerHost header")
	return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

-- read container json data
local container = cjson.new().decode(ngx.var.request_body)
if container == cjson.null or container == nil then
	ngx.log(ngx.ERR, "InspectContainer lacked a valid JSON body.")
	return ngx.exit(ngx.HTTP_BAD_REQUEST)
end


-- materialize views/transform request --
local id = container.Id
local foundPort = false
local existed = ngx.shared.containerHosts.get(id)

-- store hostport. json entry looks like: { "22/tcp": [{ "HostPort": "11022" }] }
for port,binding in pairs(container.HostConfig.PortBindings) do
	local i = string.find(port, "/")
	if string.sub(port, i) == "/tcp" then
		port = tonumber(string.sub(port, 0, i - 1)) -- finalize port
		if ngx.shared.ndf_config.get("targetPort") == port then -- check port
			binding = tonumber(binding[0].HostPort)
			ngx.shared.ndf_hostport.set(id, binding) -- store match
			foundPort = true
		end
	end
end

if !foundPort and !ngx.shared.ndf_config.get("storeUnmatchedPort") then
	return ngx.exit(200)
end

-- store labels
function insureId(str)
	if not str then
		return id
	elseif not string:find(str, id)	then
		return str .. " " .. id
	end
end
for label,val in pairs(container.Config.Labels) do
	-- pure labels without values
	if val != false and val != 0 and val != "" then
		local current = insureId(ngx.shared.labels[label])
		if current then
			ngx.shared.labels.set(label, current)
		end
	end

	-- key:value label
	local full = label .. "=" .. val
	local currentFull = insureId(ngx.shared.labels[full])
	if currentFull then
		ngx.shared.labels.set(full, current)
	end
end


-- store containerHosts and maybe containers --
ngx.shared.ndf_containerHosts.set(id, containerHost)
if ngx.shared.ndf_config.get("storeJson") then
	ngx.shared.ndf_containers.set(id, container)
end
