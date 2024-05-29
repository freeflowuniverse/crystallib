module utils

import time
import freeflowuniverse.crystallib.ui.console

pub enum ContainerStatus {
	up
	down
	restarting
	paused
	dead
	created
}

pub struct ContainerVolume {
	src  string
	dest string
}

// convert strings as used by format from docker to MB in int
pub fn parse_size_mb(size_ string) !int {
	mut size := size_.to_lower()
	if size.contains('(') {
		size = size.split('(')[0].trim(' ')
	}
	mut s := 0
	if size.ends_with('gb') {
		s = size.replace('gb', '').int() * 1024
	} else if size.ends_with('mb') {
		s = size.replace('mb', '').int()
	} else if size.ends_with('kb') {
		s = int(size.replace('kb', '').f64() / 1000)
	} else if size.ends_with('b') {
		s = int(size.replace('b', '').f64() / 1000000)
	} else {
		panic("@TODO for other sizes, '${size}'")
	}
	return s
}

pub fn parse_digest(s string) !string {
	mut s2 := s
	if s.starts_with('sha256:') {
		s2 = s2[7..]
	}
	return s2
}

pub fn parse_time(s string) !time.Time {
	mut s2 := s
	s3 := s2.split('+')[0].trim(' ')
	return time.parse_iso8601(s3)
}

pub fn parse_ports(s string) ![]string {
	s3 := s.split(',').map(clear_str)
	return s3
}

pub fn parse_labels(s string) !map[string]string {
	mut res := map[string]string{}
	if s.trim_space().len > 0 {
		// console.print_debug(s)
		// panic("todo")
		// TODO: need to do
	}
	return res
}

pub fn parse_networks(s string) ![]string {
	mut res := []string{}
	if s.trim_space().len > 0 {
		// console.print_debug(s)
		// panic("todo networks")
		// TODO: need to do
	}
	return res
}

pub fn parse_mounts(s string) ![]ContainerVolume {
	mut res := []ContainerVolume{}
	// TODO: need to do
	if s.trim_space().len > 0 {
		// console.print_debug(s)
		// panic("todo mounts")
		// TODO: need to do
	}
	return res
}

pub fn parse_container_state(state string) !ContainerStatus {
	if state.contains('Dead:true') || state.contains('dead') {
		return ContainerStatus.dead
	}
	if state.contains('Paused:true') || state.contains('paused') {
		return ContainerStatus.paused
	}
	if state.contains('Restarting:true') || state.contains('restarting') {
		return ContainerStatus.restarting
	}
	if state.contains('Running:true') || state.contains('running') {
		return ContainerStatus.up
	}
	if state.contains('Status:created') || state.contains('created') {
		return ContainerStatus.created
	}
	if state.contains('exited') {
		return ContainerStatus.down
	}
	if state.contains('stopped') {
		return ContainerStatus.down
	}
	return error('Could not find podman container status: ${state}')
}

pub fn clear_str(s string) string {
	return s.trim(' \n\t')
}

pub fn contains_ssh_port(forwarded_ports []string) bool {
	for port in forwarded_ports {
		splitted := port.split(':')
		if splitted.last() == '22' || splitted.last() == '22/tcp' {
			return true
		}
	}
	return false
}
