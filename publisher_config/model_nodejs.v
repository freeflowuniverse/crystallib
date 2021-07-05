module publishconfig

const LTS_VER := 'v14.17.0'
const LATEST_VER := 'v16.1.0'

pub struct NodejsConfig {
pub mut:
	version string
	path    string
}

fn (mut cfg ConfigRoot) init_nodejs() {
	mut version := ''
	if cfg.nodejs.path == '' {
		if cfg.nodejs.version == "lts" {
			version = LTS_VER
		} else {
			version = LATEST_VER
		}
		cfg.nodejs.path = '$cfg.publish.paths.base/versions/node/$version'
		cfg.nodejs.version = version
	}
}
