module daguserver

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.dagu
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller
import freeflowuniverse.crystallib.core.texttools

pub fn (mut self DaguServer[Config]) dag_path(name string) string {
	return '${os.home_dir()}/dags/${texttools.name_fix(name)}.yaml'
}

// register a new dag
pub fn (mut self DaguServer[Config]) new(dag dagu.DAG) ! {
	dag_yaml := $tmpl('./templates/dag.yaml')
	dag_file := self.dag_path(dag.name)
	os.write_file(dag_file, dag_yaml)!
}

// pub fn (mut self DaguServer[Config]) url() string {
// 	return '${dagu_s.host}:${dagu_s.port}/api/v1'
// }

// Dry-runs specified DAG, what are the options? QUESTION:
pub fn (mut self DaguServer[Config]) dryrun(name string, options string) !string {
	panic('implement')
	dag_file := self.dag_path(name)
	result := os.execute_opt('dagu dry  ${dag_file} ')!
	return result.output
}

// Restart the DAG
pub fn (mut self DaguServer[Config]) restart(name string) !string {
	dag_file := self.dag_path(name)
	result := os.execute_opt('dagu restart ${dag_file}')!
	return result.output
}

// Retry the DAG execution
pub fn (mut self DaguServer[Config]) retry(request_id string, name string) !string {
	dag_file := self.dag_path(name)
	result := os.execute_opt('dag retry --req ${request_id} ${dag_file}')!
	return result.output
}

pub fn (mut self DaguServer[Config]) start(name string) !string {
	dag_file := self.dag_path(name)
	console.print_debug('dag start  ${dag_file}')
	result := os.execute_opt('dagu start  ${dag_file} ')!
	return result.output
}

pub fn (mut self DaguServer[Config]) server() ! {
	mut cfg := self.config()!
	println('debugzoniko ${cfg}')
	daguinstaller.start(
		homedir: cfg.homedir
		configpath: cfg.configpath
		username: cfg.username
		password: cfg.password
		secret: cfg.secret
		port: cfg.port
	)!
}

// Display current status of the DAG
pub fn (mut self DaguServer[Config]) status(name string) !string {
	dag_file := self.dag_path(name)
	result := os.execute_opt('dagu status ${dag_file}')!
	// TODO: is this a good result, shouldn't this be an enum?
	return result.output
}

// Stop the running DAG
pub fn (mut self DaguServer[Config]) stop() ! {
	daguinstaller.stop()!
}

// // Stop the running DAG
// pub fn (mut self DaguServer[Config]) dag_stop(name string) !string {
// 	dag_file := self.dag_path(name)
// 	result := os.execute_opt('dagu stop ${dag_file}')!
// 	return result.output
// }

// pub fn (mut self DaguServer[Config]) delete(name string) ! {
// 	self.dag_stop(name)!
// 	dag_file := self.dag_path(name)
// 	os.rm(dag_file)!
// }
