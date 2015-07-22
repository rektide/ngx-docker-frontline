-- broad configuration state
lua_shared_dict ndf_config

-- base records, all other dicts are views into these canonical records.
lua_shared_dict ndf_containers 48m -- dict from id to the full json on that id.
lua_shared_dict ndf_containerHosts 8m -- dict from container id to hostname.

-- dicts for finding containers to service a request.
lua_shared_dict ndf_labels 8m -- dict from label 'key=value' to comma separated list of containers matching that.

-- dicts with decoded information needed to reverse-proxy.
lua_shared_dict ndf_hostport 8m -- dict from container id to the hostport being exposed.


-- config --
ngx.shared.ndf_config.set("configTick", 1) -- synchronization mechanism for detecting config changes
ngx.shared.ndf_config.set("targetPort", 80) -- port to expect to talk to
ngx.shared.ndf_config.set("storeUnmatchedPort", false) -- disregard containers with no target port
ngx.shared.ndf_config.set("storeJson", true) -- docker-frontline expects to materialize out any container info it's going to need, but by default will retain the full records anyways.
