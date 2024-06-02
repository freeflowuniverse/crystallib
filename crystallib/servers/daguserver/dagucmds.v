module daguserver

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.dagu

pub fn (mut self DaguServer[T]) dag_path(name string) string {
	return '${homedir}/dags/${texttools.name_fix(name)}.yaml'
}

// register a new dat
pub fn (self DaguServer[T]) new(dag dagu.Dag) ! {
	dag_yaml := $tmpl('./templates/dag.yaml')
	dag_file := self.dag_path(name)
	os.write_file(dag_file, dag_yaml)!
}

// Dry-runs specified DAG, what are the options? QUESTION:
pub fn (self DaguServer[T]) dryrun(name string, options string) !string {
	panic('implement')
	dag_file := self.dag_path(name)
	result := os.execute_opt('dagu dry  ${dag_file} ${flags}')!
	return result.output
}

// Restart the DAG
pub fn (self DaguServer[T]) restart(name string) !string {
	dag_file := self.dag_path(name)
	result := os.execute_opt('dagu restart ${dag_file}')!
	return result.output
}

// Retry the DAG execution
pub fn (self DaguServer[T]) retry(request_id string, name string) !string {
	dag_file := self.dag_path(name)
	result := os.execute_opt('dag retry --req ${request_id} ${dag_file}')!
	return result.output
}

pub fn (self DaguServer[T]) start(name string) !string {
	dag_file := self.dag_path(name)
	console.print_debug('dag start  ${dag_file}')
	result := os.execute_opt('dagu start  ${dag_file} ')!
	return result.output
}

// Display current status of the DAG
pub fn (self DaguServer[T]) status(name string) !string {
	dag_file := self.dag_path(name)
	result := os.execute_opt('dagu status ${dag_file}')!
	// TODO: is this a good result, shouldn't this be an enum?
	return result.output
}

// Stop the running DAG
pub fn (self DaguServer[T]) dag_stop(name string) !string {
	dag_file := self.dag_path(name)
	result := os.execute_opt('dagu stop ${dag_file}')!
	return result.output
}

pub fn (self DaguServer[T]) delete(name string) ! {
	self.dag_stop(name)!
	dag_file := self.dag_path(name)
	os.rm(dag_file)!
}
