module config

const lts_ver = '14.17.5'

const latest_ver = '16.8.0'

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
		if cfg.nodejs.version == NodejsCat.latest {
			version = config.latest_ver
		} else {
			version = config.lts_ver
		}
		cfg.nodejs.path = '$cfg.publish.paths.base/versions/node/v$version'
		cfg.nodejs.versionnr = version
	}
	// println(cfg.nodejs)
}
