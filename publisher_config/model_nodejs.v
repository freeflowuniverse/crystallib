module publisher_config

const lts_ver = 'v14.17.0'

const latest_ver = 'v16.7.0'

pub struct NodejsConfigFS {
pub mut:
	version string
	nvm     bool
}

pub struct NodejsConfig {
pub mut:
	version   NodejsCat
	versionnr string
	path      string
	nvm       bool
}

pub enum NodejsCat {
	lts
	latest
}

fn (mut cfg ConfigRoot) init_nodejs() {
	mut version := ''
	if cfg.nodejs.path == '' {
		if cfg.nodejs.version == NodejsCat.lts {
			version = publisher_config.lts_ver
		} else {
			version = publisher_config.latest_ver
		}
		cfg.nodejs.path = '$cfg.publish.paths.base/versions/node/$version'
		cfg.nodejs.versionnr = version
	}
}
