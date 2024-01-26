module dagu

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
	config_yaml := $tmpl('./templates/config.yaml')
	os.write_file('~/.dagu/config.yaml', config_yaml)
	return DAGU{}
}

pub fn 