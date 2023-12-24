module analytics

pub struct Analyzer {
pub mut:
	backend DBBackend
}

@[params]
pub struct AnalyzerConfig {
	backend ?DBBackend
}

pub fn new(config AnalyzerConfig) !Analyzer {
	mut bend := config.backend or { DBBackend{} }
	return Analyzer{
		backend: bend
	}
}
