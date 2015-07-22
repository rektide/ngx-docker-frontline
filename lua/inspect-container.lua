local cjson = require "resty.libcjson"

-- extract request --
-- read ContainerHost info
local headers = ngx.request.get_headers()
local containerHost = headers.ContainerHost

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
local foundPort = false

-- store hostport. json entry looks like: { "22/tcp": [{ "HostPort": "11022" }] }
for port,binding in pairs(container.HostConfig.PortBindings) do
	local i = string.find(port, "/")
	if string.sub(port, i) === "/tcp" then
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
for label,val in pairs(container.Config.Labels) do
	local key = label .. "=" .. val
	local current = ngx.shared.labels[key]
	current = current == nil ? current .. "," .. id : id
	ngx.shared.labels.set(key, current)
end


-- store containerHosts and maybe containers --
local id = container.Id
ngx.shared.ndf_containers.set(id, container)
if ngx.shared.ndf_config.get("storeJson") then
	ngx.shared.ndf_containerHosts.set(id, containerHost)
end
