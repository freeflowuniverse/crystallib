module osal

const (
	redis_key_platform = 'osal.platform'
	redis_key_cputype  = 'osal.cputype'
)

// Returns the enum value that matches the provided string for PlatformType
pub fn platform_enum_from_string(platform string) PlatformType {
	return match platform.to_lower() {
		'osx' { .osx }
		'ubuntu' { .ubuntu }
		'alpine' { .alpine }
		else { .unknown }
	}
}

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

// Returns the enum value that matches the provided string for CPUType
pub fn cputype_enum_from_string(cpytype string) CPUType {
	return match cpytype.to_lower() {
		'intel' { .intel }
		'arm' { .arm }
		'intel32' { .intel32 }
		'arm32' { .arm32 }
		else { .unknown }
	}
}

pub enum CPUType {
	unknown
	intel
	arm
	intel32
	arm32
}

// Returns the platform of the system and caches it into redis, will return one of osx, ubuntu, alpine or unknown
pub fn platform() PlatformType {
	mut logger := get_logger()
	mut platform_ := PlatformType.unknown
	print("platform")
	mut redis := get_redis()
	print("redis exists")
	cached := redis.exists(osal.redis_key_platform) or { false }
	println("+++")
	if cached {
		platform_from_redis := redis.get(osal.redis_key_platform) or {
			logger.error('Failed to get value from redis key ${osal.redis_key_platform}')
			'unknown'
		}
		platform_ = platform_enum_from_string(platform_from_redis)
		if platform_ != PlatformType.unknown {
			return platform_
		}
	}
	if cmd_exists('sw_vers') {
		platform_ = PlatformType.osx
	} else if cmd_exists('apt-get') {
		platform_ = PlatformType.ubuntu
	} else if cmd_exists('apk') {
		platform_ = PlatformType.alpine
	} else {
		logger.error('Unknown platform')
	}
	if platform_ != PlatformType.unknown {
		redis.set(osal.redis_key_platform, platform_.str()) or {
			logger.error('Failed to cache platform in redis')
		}
	}
	return platform_
}

// Returns the cpu type of the system and caches it in redis, will return one of unknown, intel, arm, intel32 or arm32
pub fn cputype() CPUType {
	mut logger := get_logger()
	mut cputype_ := CPUType.unknown
	mut redis := get_redis()
	cached := redis.exists(osal.redis_key_cputype) or { false }
	if cached {
		cputype_from_redis := redis.get(osal.redis_key_cputype) or {
			logger.error('Failed to get value from redis key ${osal.redis_key_cputype}')
			'unknown'
		}
		cputype_ = cputype_enum_from_string(cputype_from_redis)
		if cputype_ != CPUType.unknown {
			return cputype_
		}
	}
	sys_info := execute_stdout('uname -m') or {
		logger.error('Failed to execute uname to get the cputype: ${err}')
		return CPUType.unknown
	}
	cputype_ = match sys_info.to_lower().trim_space() {
		'x86_64' {
			CPUType.intel
		}
		'arm64' {
			CPUType.arm
		}
		// TODO 32 bit ones!
		else {
			logger.error('Unknown cpu type ${sys_info}')
			CPUType.unknown
		}
	}

	if cputype_ != CPUType.unknown {
		redis.set(osal.redis_key_cputype, cputype_.str()) or {
			logger.error('Failed to cache cputype in redis')
		}
	}
	return cputype_
}

pub fn is_osx() bool {
	return platform() == .osx
}
