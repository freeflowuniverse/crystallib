module nodejs

import os
import despiegk.crystallib.builder
import despiegk.crystallib.process
import despiegk.crystallib.publisher_config

// return string which represents init for npm
pub fn init_string(cfg &publisher_config.ConfigRoot) string {
	return ''
}

pub fn install(cfg &publisher_config.ConfigRoot) ? {
	mut script := ''

	base := cfg.publish.paths.base
	nodejspath := cfg.nodejs.path

	mut node := builder.node_get({}) or {
		println(' ** ERROR: cannot load node. Error was:\n$err')
		exit(1)
	}
	node.platform_prepare() ?

	if !os.exists('$base/nvm.sh') {
		script = "
		set -e
		rm -f $base/nvm.sh
		curl -s -o '$base/nvm.sh' https://raw.githubusercontent.com/nvm-sh/nvm/master/nvm.sh
		"
		process.execute_silent(script) or {
			println('cannot download nvm script.\n$err')
			exit(1)
		}
	}

	if !os.exists('$nodejspath/bin/node') {
		println(' - will install nodejs (can take quite a while)')
		
		lts := cfg.nodejs.version.replace('v', '')

		if cfg.nodejs.version.cat == publisher_config.NodejsVersionEnum.lts {
			script = '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			nvm install $lts
			npm install --global @gridsome/cli
			'
		} else {
			script = '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			nvm install node
			npm install --global @gridsome/cli
			'
		}
		process.execute_silent(script) or {
			println('cannot install nodejs.\n$err')
			exit(1)
		}
	}

	println(' - nodejs installed')
}
