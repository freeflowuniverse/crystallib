module builder

// is e.g. an ubuntu packagedapp, it needs to be packaged by the package maintainers !
pub struct Package {
	name        string
	description string
	version     string
	aliases     []PackageAlias
}

// if there is an exception of how package needs to be installed (alias)
// e.g. on ubuntu something is called myapp but on alpine its my_app
pub struct PackageAlias {
	name         string
	platformtype PlatformType
	version      string
}

// get the right name depending the platform type
pub fn (mut package Package) name_get(platformtype PlatformType) string {
	for alias in package.aliases {
		if alias.platformtype == platformtype {
			return alias.name
		}
	}
	return package.name
}

// get the right name depending the platform type
pub fn (mut package Package) version_get(platformtype PlatformType) string {
	for alias in package.aliases {
		if alias.platformtype == platformtype {
			if alias.version != '' {
				return alias.version
			}
		}
	}
	return package.version
}

// life cycle management things to code
// is like install or prepare to start with a task
pub fn (mut package Package) prepare(wish Wish) {
}

// not relevant
pub fn (mut package Package) start(wish Wish) ? {
}

// check if it was done ok
pub fn (mut package Package) check(wish Wish) bool {
	return true
}

// check if we are in right state if not lets try to recover
pub fn (mut package Package) recover(wish Wish) ? {
	if !package.check(wish) {
		package.delete(wish) or { panic(err) }
		package.prepare(wish)
		// package.start()
	}
}

// return relevant info of the package
pub fn (mut package Package) info(wish Wish) ? {
}

// not relevant for packages
pub fn (mut package Package) halt(wish Wish) ? {
}

// remove from the system
pub fn (mut package Package) delete(wish Wish) ? {
}
