module caddy

pub fn plugin_is_installed(plugin_ string) !bool {
	plugin := plugin_.trim_space()
	result := osal.exec(cmd: 'caddy list-modules --packages')!

	mut lines := result.output.split('\n')

	mut standardard_packages := []string{}
	mut nonstandardard_packages := []string{}

	mut standard := true
	for mut line in lines {
		line = line.trim_space()
		if line == '' {
			continue
		}
		if line.starts_with('Standard modules') {
			standard = false
			continue
		}
		package := line.all_after(' ')
		if standard {
			standardard_packages << package
		} else {
			nonstandardard_packages << package
		}
	}

	return plugin in standardard_packages || plugin in nonstandardard_packages
}
