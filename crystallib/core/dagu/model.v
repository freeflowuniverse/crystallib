module dagu

pub struct Root {
pub mut:
	steps []Step
}

pub struct Step {
pub mut:
	name     string
	executor Executor
	command  string
	output   string
	depends  []string
}

pub struct ExecutorConfig {
pub mut:
	timeout int
	headers map[string]string
	silent  bool
	body    string
}

pub struct Executor {
pub mut:
	type_  string
	config ExecutorConfig
}
