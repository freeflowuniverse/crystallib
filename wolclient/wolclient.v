module wolclient

import os

pub const default_command_name = "wakeonlan"

pub fn wakeonlan(mac_address string, ip string, port int) {
	mut cmd_name := $env("WOL_COMMAND")
	if cmd_name == "" {
		cmd_name = default_command_name
	}
	println("command ${cmd_name}")
	mut cmd := [ cmd_name ]

	if ip != "" {
		cmd << "-i"
		cmd << ip
	}
	if port != -1 {
		cmd << "-p"
		cmd << "${port}"
	}
	cmd << mac_address

	result := os.execute(cmd.join(" "))
}