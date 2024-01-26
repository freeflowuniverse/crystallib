module dagu

import os
import freeflowuniverse.crystallib.core.texttools

@[noinit]
struct DAGU {
	dags []DAG
}

pub fn new(config Config) DAGU {
	config_yaml := $tmpl('./templates/config.yaml')
	os.write_file('~/.dagu/config.yaml', config_yaml)
	return DAGU{}
}

pub fn (mut d DAGU) new_dag(dag DAG) DAG {
	dag_yaml := $tmpl('./templates/dag.yaml')
	os.write_file('~/.dagu/dags/${texttools.namefix(dag.name)}.yaml', config_yaml)
	return DAGU{}
}
