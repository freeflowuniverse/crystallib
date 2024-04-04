module testmodule

pub fn testfunction0(param string) string {
	return param
}

pub struct Config {
	name   string
	number int
}

pub fn testfunction1(config Config) []string {
	return []string{len: config.number, init: config.name}
}
