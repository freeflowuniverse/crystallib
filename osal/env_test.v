module osal

fn test_env_get_default() ! {
	mut o := new()!

	key := 'keythatshouldnotexist'
	def_value := 'defaultvalue'

	o.env_unset(key)

	o.env_get(key) or {
		assert o.env_get_default(key, def_value) == def_value
		return
	}
	return error('The environment value ${key} should have been unset, it was not!')
}

fn test_env_set_env_get_env_unset() ! {
	mut o := new()!

	key := 'myenvironmentvariable'
	value := 'somevalue'

	o.env_set(key: key, value: value)

	assert o.env_get(key)! == value

	o.env_unset(key)

	o.env_get(key) or { return }
	return error('The environment variable ${key} should have been unset, it was not!')
}

fn test_env_unset_all_and_set_all_and_get_all() {
	mut o := new()!
	mut env := map[string]string{}
	env['Dummy'] = 'dummy'

	o.env_unset_all()

	assert o.env_get_all() == map[string]string{}

	o.env_set_all(env: env)

	assert o.env_get_all() == env
}
