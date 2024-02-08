module dagu

import os
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib

@[noinit]
struct DAGU {
	home string // home directory for dagu
mut:
	dags []DAG
}

pub fn new(config_ ?Config) !DAGU {
	if config := config_ {
		config_yaml := $tmpl('./templates/config.yaml')
		os.write_file('${os.home_dir()}/.dagu/config.yaml', config_yaml)!
	}
	dags_dir := '${os.home_dir()}/.dagu/dags'
	if !os.exists(dags_dir) {
		os.mkdir(dags_dir)!
	}
	return DAGU{
		home: '${os.home_dir()}/.dagu/'
	}
}

pub fn (mut d DAGU) basic_auth(username string, password string) ! {
	mut admin_file := pathlib.get_file(path: '${d.home}/admin.yaml', create: true)!
	admin_file.write($tmpl('./templates/admin.yaml'))!
}

pub fn (mut d DAGU) new_dag(dag DAG) DAG {
	d.dags << DAG{
		...dag
		path: '${os.home_dir()}/.dagu/dags/${texttools.name_fix(dag.name)}.yaml'
	}
	return dag
}

pub fn (d DAGU) start(dag_name string, options StartOptions) !string {
	filtered := d.dags.filter(it.name == dag_name)
	if filtered.len == 0 {
		return error('DAG ${dag_name} not found.')
	}
	dag := filtered[0]
	dag.write()!
	return start(dag.path, options)!
}

pub fn (d DAGU) scheduler(dag_name string) !string {
	filtered := d.dags.filter(it.name == dag_name)
	if filtered.len == 0 {
		return error('DAG ${dag_name} not found.')
	}
	dag := filtered[0]
	dag.write()!
	return scheduler(dags: dag.path)!
}

pub fn (mut d DAGU) delete(dag_name string) ! {
	index := d.dags.map(it.name).index(dag_name)
	if index == d.dags.len {
		return error('DAG ${dag_name} not found.')
	}
	d.dags[index].delete()!
	d.dags.delete(index)
}

pub fn (dag DAG) write() ! {
	dag_yaml := $tmpl('./templates/dag.yaml')
	os.write_file(dag.path, dag_yaml)!
}

pub fn (dag DAG) delete() ! {
	os.rm(dag.path)!
}
