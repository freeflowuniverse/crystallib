module osal


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

pub fn (mut o Osal) platform() PlatformType {
	if o.cmd_exists('sw_vers') {
		return PlatformType.osx
	} else if o.cmd_exists('apt-get') {
		return PlatformType.ubuntu
	} else if o.cmd_exists('apk') {
		return PlatformType.alpine
	} 

	return PlatformType.unknown
}

pub fn (mut o Osal) cputype() CPUType {
	mut cputype := o.exec(cmd: 'uname -m', retry_max: 0) or {
		o.logger.error("Failed to execute uname to get the cputype: ${err}")
		return CPUType.unknown
	}
	cputype = cputype.to_lower().trim_space()
	if cputype == 'x86_64' {
		return CPUType.intel
	} else if cputype == 'arm64' {
		return CPUType.arm
	}

	o.logger.warn("Unknown cputype ${cputype}")
	return CPUType.unknown
}
