module publishconfig

const lts_ver = 'v14.17.0'
const latest_ver = 'v16.1.0'

pub struct NodejsConfig {
pub mut:
	version string
	path    string
}

fn (mut cfg ConfigRoot) init_nodejs() {
	mut version := ''
	if cfg.nodejs.path == '' {
		if cfg.nodejs.version == "lts" {
			version = lts_ver
		} else {
			version = latest_ver
		}
		cfg.nodejs.path = '$cfg.publish.paths.base/versions/node/$version'
		cfg.nodejs.version = version
	}
}
