module docker

import time

// convert strings as used by format from docker to MB in int
fn parse_size_mb(size_ string) ?int {
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
		panic("@TODO for other sizes, '$size'")
	}
	return s
}

fn parse_digest(s string) ?string {
	mut s2 := s
	if s.starts_with('sha256:') {
		s2 = s2[7..]
	}
	return s2
}

fn parse_time(s string) ?time.Time {
	mut s2 := s
	s3 := s2.split('+')[0].trim(' ')
	return time.parse(s3)
}

fn parse_ports(s string) ?[]string {
	s3 := s.split(',').map(clear_str)
	return s3
}

fn parse_labels(s string) ?map[string]string {
	mut res := map[string]string{}
	// TODO: need to do
	return res
}

fn parse_networks(s string) ?[]string {
	mut res := []string{}
	// TODO: need to do
	return res
}

fn parse_mounts(s string) ?[]DockerContainerVolume {
	mut res := []DockerContainerVolume{}
	// TODO: need to do
	println(s)
	if s.len > 0 {
		panic('sd3')
	}
	return res
}

fn parse_container_state(state string) ?DockerContainerStatus {
	if state.contains('Dead:true') || state.contains('dead') {
		return DockerContainerStatus.dead
	}
	if state.contains('Paused:true') || state.contains('paused') {
		return DockerContainerStatus.paused
	}
	if state.contains('Restarting:true') || state.contains('restarting') {
		return DockerContainerStatus.restarting
	}
	if state.contains('Running:true') || state.contains('running') {
		return DockerContainerStatus.up
	}
	if state.contains('Status:created') || state.contains('created') {
		return DockerContainerStatus.created
	}
	if state.contains('exited') {
		return DockerContainerStatus.down
	}
	return error('Could not find docker status: $state')
}

fn clear_str(s string) string {
	return s.trim(' \n\t')
}

fn contains_ssh_port(forwarded_ports []string) bool {
	for port in forwarded_ports {
		splitted := port.split(':')
		if splitted[1] == '22' || splitted[1] == '22/tcp' {
			return true
		}
	}
	return false
}
