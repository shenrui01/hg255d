--[[
LuCI - Lua Configuration Interface - Aria2 support

Script by animefans_xj @ nowvideo.dlinkddns.com (af_xj@yahoo.com.cn)

Licensed under the Apache License, Version 2.0 (the "license");
you may not use this file except in compliance with the License.
you may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.aria2",package.seeall)

function index()
	require("luci.i18n")
	luci.i18n.loadc("aria2")
	if not nixio.fs.access("/etc/config/aria2") then
		return
	end
	
	local page = entry({"admin","services","aria2"},cbi("aria2"),_("Aria2 Downloader"))
	page.i18n="aria2"
	page.dependent=true
end
