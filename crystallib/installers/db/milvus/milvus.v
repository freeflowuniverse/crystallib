module milvus

import freeflowuniverse.crystallib.installers.docker
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.conversiontools.tmux
import freeflowuniverse.crystallib.ui.console

pub struct Milvus {
pub mut:
	path string
}

pub fn (m Milvus) start() ! {
	if !osal.done_exists('milvus_started') {
		osal.execute_silent('mkdir -p ${m.path}')!
		docker.install()!
		osal.execute_silent('wget https://github.com/milvus-io/milvus/releases/download/v2.3.3/milvus-standalone-docker-compose.yml -O ${m.path}/docker-compose.yml')!
		mut t := tmux.new(
			sessionid: 'milvus'
		)!
		c := '
		cd ${m.path}
		docker-compose up	
		echo "DOCKER COMPOSE ENDED, EXIT TO BASH"
		/bin/bash 
		'
		mut w := t.window_new(name: 'milvus', cmd: c)!
		w.output_wait('Milvus Proxy successfully initialized and ready to serv', 120)!
		osal.done_set('milvus_started', 'OK')!
	}
}

pub fn (m Milvus) stop() ! {
	if osal.done_exists('milvus_started') {
		console.print_debug('stopping milvus')
		mut t := tmux.new(sessionid: 'milvus')!
		t.window_delete(name: 'milvus')!
		osal.done_delete('milvus_started')!
	}
}
