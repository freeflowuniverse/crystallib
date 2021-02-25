module myconfig

pub struct NodejsConfig {
pub mut:
	version NodejsVersion
	path    string
}

struct NodejsVersion {
pub mut:
	name string
	cat  NodejsVersionEnum
}

pub enum NodejsVersionEnum {
	lts
	latest
}

fn (mut cfg ConfigRoot) init() {
	mut version := ''
	if cfg.nodejs.path == '' {
		if cfg.nodejs.version.cat == NodejsVersionEnum.lts {
			version = 'v15.8.0'
		} else {
			version = 'v14.15.4'
		}
		cfg.nodejs.path = '$cfg.paths.base/versions/node/$version'
		cfg.nodejs.version.name = version
	}
}
