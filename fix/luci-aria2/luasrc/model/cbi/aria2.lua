--[[
LuCI - Lua Configuration Interface - aria2 support

Script by animefans_xj @ nowvideo.dlinkddns.com (af_xj@yahoo.com.cn)
Based on luci-app-transmission and luci-app-upnp

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")

local running=(luci.sys.call("pidof aria2c > /dev/null") == 0)
local button=""
if running then
	button="&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\" " .. translate("Open Web Interface") .. " \" onclick=\"window.open('http://'+window.location.host+'/aria2')\"/>"
end

m=Map("aria2",translate("Aria2 Downloader"),translate("Use this page, you can download files from HTTP FTP and BitTorrent via Aria2.") .. button)

s=m:section(TypedSection,"aria2",translate("Global"))
s.addremove=false
s.anonymous=true
enable=s:option(Flag,"enabled",translate("Enabled"))
enable.rmempty=false
function enable.cfgvalue(self,section)
	return luci.sys.init.enabled("aria2") and self.enabled or self.disabled
end
function enable.write(self,section,value)
	if value == "1" then
		luci.sys.call("/etc/init.d/aria2 enable >/dev/null")
		luci.sys.call("/etc/init.d/aria2 start >/dev/null")
	else
		luci.sys.call("/etc/init.d/aria2 stop >/dev/null")
		luci.sys.call("/etc/init.d/aria2 disable >/dev/null")
	end
end
user=s:option(ListValue,"user",translate("Run daemon as user"))
local list_user
for _, list_user in luci.util.vspairs(luci.util.split(luci.sys.exec("cat /etc/passwd | cut -f 1 -d :"))) do
	user:value(list_user)
end

location=m:section(TypedSection,"aria2",translate("Location"))
location.addremove=false
location.anonymous=true
config_dir=location:option(Value,"config_dir",translate("Config Directory"))
config_dir.placeholder="/mnt/sda1/.Programs/aria2"
download_dir=location:option(Value,"download_dir",translate("Download Directory"))
download_dir.placeholder="/mnt/sda1/Downloads"

task=m:section(TypedSection,"aria2",translate("Task"))
task.addremove=false
task.anonymous=true
restore_task=task:option(Flag,"restore_task",translate("Restore unfinished task when boot"))
restore_task.rmempty=false
--[[ queue_size : aria2 param : -j ]]--
queue_size=task:option(Value,"queue_size",translate("Download queue size"))
queue_size:value("1","1")
queue_size:value("2","2")
queue_size:value("3","3")
queue_size:value("4","4")
queue_size:value("5","5")
queue_size.rmempty=true
queue_size.placeholder="2"
queue_size.datatype="range(1,20)"
--[[ split : aria2 param : -s ]]--
split=task:option(Value,"split",translate("Blocks of per task"))
split:value("1","1")
split:value("2","2")
split:value("3","3")
split:value("4","4")
split:value("5","5")
split:value("6","6")
split:value("7","7")
split:value("8","8")
split:value("9","9")
split.rmempty=true
split.placeholder="5"
split.datatype="range(1,20)"
--[[ thread : aria2 param : -x ]]--
thread=task:option(ListValue,"thread",translate("Download threads of per server"))
thread:value("1","1")
thread:value("2","2")
thread:value("3","3")
thread:value("4","4")
thread:value("5","5")
thread:value("6","6")
thread:value("7","7")
thread:value("8","8")
thread:value("9","9")
thread:value("10","10")

network=m:section(TypedSection,"aria2",translate("Network"))
network.addremove=false
network.anonymous=true
disable_ipv6=network:option(Flag,"disable_ipv6",translate("Disable IPv6"))
disable_ipv6.rmempty=false
enable_lpd=network:option(Flag,"enable_lpd",translate("Enable Local Peer Discovery"))
enable_lpd.rmempty=false
enable_dht=network:option(Flag,"enable_dht",translate("Enable DHT Network"))
enable_dht.rmempty=false
listen_port=network:option(Value,"listen_port",translate("Port for BitTorrent"))
listen_port.placeholder="6882"
listen_port.datatype="range(1,65535)"
download_speed=network:option(Value,"download_speed",translate("Download speed limit"),translate("In KB/S, 0 means unlimit"))
download_speed.placeholder="0"
download_speed.datatype="range(0,100000)"
upload_speed=network:option(Value,"upload_speed",translate("Upload speed limit"),translate("In KB/S, 0 means unlimit"))
upload_speed.placeholder="0"
upload_speed.datatype="range(0,100000)"

rpc=m:section(TypedSection,"aria2",translate("Remote Control"))
rpc.addremove=false
rpc.anonymous=true
rpc_auth=rpc:option(Flag,"rpc_auth",translate("Use RPC Auth"))
rpc_auth.rmempty=false
rpc_user=rpc:option(Value,"rpc_user",translate("User name"))
rpc_user.placeholder="admin"
rpc_user:depends("rpc_auth",1)
rpc_password=rpc:option(Value,"rpc_password",translate("Password"))
rpc_password.placeholder="admin"
rpc_password:depends("rpc_auth",1)

advanced=m:section(TypedSection,"aria2",translate("Advanced"))
advanced.addremove=false
advanced.anonymous=true
extra_cmd=advanced:option(Flag,"extra_cmd",translate("add extra commands"))
extra_cmd.rmempty=false
cmd_line=advanced:option(Value,"cmd_line",translate("Command-Lines"),translate("To check all commands availabled, visit:") .. "&nbsp;<a onclick=\"window.open('http://'+window.location.host+'/aria2/help.htm')\" style=\"cursor:pointer\"><font color='blue'><i><u>http://aria2.sourceforge.net/manual/en/html/index.html</u></i></font></a>")
cmd_line:depends("extra_cmd",1)

return m
