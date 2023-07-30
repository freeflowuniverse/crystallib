module osal

import log

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

pub enum CPUType {
	unknown
	intel
	arm
	intel32
	arm32
}

pub fn platform() PlatformType {
	// TODO: cache in redis
	if cmd_exists('sw_vers') {
		return PlatformType.osx
	} else if cmd_exists('apt-get') {
		return PlatformType.ubuntu
	} else if cmd_exists('apk') {
		return PlatformType.alpine
	}
	panic('platform not supported, only support osx, ubuntu and alpine.')
	return PlatformType.unknown
}

pub fn cputype() CPUType {
	mut logger := log.Logger(&log.Log{
		level: .info
	})
	mut cputype := exec(cmd: 'uname -m', retry: 0) or {
		logger.error('Failed to execute uname to get the cputype: ${err}')
		return CPUType.unknown
	}
	cputype = cputype.to_lower().trim_space()
	if cputype == 'x86_64' {
		return CPUType.intel
	} else if cputype == 'arm64' {
		return CPUType.arm
	}
	logger.warn('Unknown cputype ${cputype}')
	return CPUType.unknown
}
