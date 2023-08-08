module osal

fn test_env_get_default() ! {
	key := 'keythatshouldnotexist'
	def_value := 'defaultvalue'

	env_unset(key)

	env_get(key) or {
		assert env_get_default(key, def_value) == def_value
		return
	}
	return error('The environment value ${key} should have been unset, it was not!')
}

fn test_env_set_env_get_env_unset() ! {
	key := 'myenvironmentvariable'
	value := 'somevalue'

	env_set(key: key, value: value)

	assert env_get(key)! == value

	env_unset(key)

	env_get(key) or { return }
	return error('The environment variable ${key} should have been unset, it was not!')
}

fn test_env_unset_all_and_set_all_and_get_all() {
	mut env := map[string]string{}
	env['Dummy'] = 'dummy'

	env_unset_all()

	assert env_get_all() == map[string]string{}

	env_set_all(env: env)

	assert env_get_all() == env
}
