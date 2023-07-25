module osal

// TODO:
/*
fn platform() !PlatformType {
	// use redis to cache,
	println(' - platform load')
	mut cputype := exec_silent('uname -m')!
	cputype = cputype.to_lower().trim_space()
	if cputype == 'x86_64' {
		cputype = CPUType.intel
	} else if cputype == 'arm64' {
		cputype = CPUType.arm
	} else {
		return error("did not find cpu type, implement more types e.g. 32 bit. found: '${cputype}'")
	}

	if cmd_exists('sw_vers') {
		platform = PlatformType.osx
	} else if cmd_exists('apt-get') {
		platform = PlatformType.ubuntu
		package_refresh() or {}
	} else if cmd_exists('apk') {
		platform = PlatformType.alpine
	} else {
		panic('only ubuntu, alpine and osx supported for now')
	}
	return platform
}

fn platform_load() ! {
	// TODO: should rewrite this with one bash script, which gets the required info & returns e.g. env, platform, ... is much faster
	println(' - platform load')
	mut cputype := exec_silent('uname -m')!
	cputype = cputype.to_lower().trim_space()
	if cputype == 'x86_64' {
		cputype = CPUType.intel
	} else if cputype == 'arm64' {
		cputype = CPUType.arm
	} else {
		return error("did not find cpu type, implement more types e.g. 32 bit. found: '${cputype}'")
	}

	if platform == PlatformType.unknown {
		if cmd_exists('sw_vers') {
			platform = PlatformType.osx
		} else if cmd_exists('apt-get') {
			platform = PlatformType.ubuntu
			package_refresh() or {}
		} else if cmd_exists('apk') {
			platform = PlatformType.alpine
		} else {
			panic('only ubuntu, alpine and osx supported for now')
		}
	}
}
*/
