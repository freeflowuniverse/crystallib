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
