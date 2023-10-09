module markdowndocs

import freeflowuniverse.crystallib.data.params { Param, Params }

fn test_action_no_action_name_should_fail() {
	mut docs := new(
		content: '
!!
'
	) or {
		assert '${err}' == 'cannot parse macro, need to be at least cmd, now ""'
		return
	}
	assert false, 'parsing should fail, it did not'
}

fn test_action_empty_params() {
	mut docs := new(
		content: '
!!farmerbot.powermanager.poweroff
'
	)!

	assert docs.items.len == 1
	assert docs.items[0] is Action
	action := docs.items[0] as Action
	assert action.name == 'farmerbot.powermanager.poweroff'
	assert action.params == Params{
		params: []
		args: []
	}
}

fn test_action_some_params_multiline() {
	mut docs := new(
		content: '
!!farmerbot.nodemanager.define
	id:15
	twinid:20
	has_public_ip:yes
	has_public_config:1
'
	)!

	assert docs.items.len == 1
	assert docs.items[0] is Action
	action := docs.items[0] as Action
	assert action.name == 'farmerbot.nodemanager.define'
	assert action.params == Params{
		params: [Param{
			key: 'id'
			value: '15'
		}, Param{
			key: 'twinid'
			value: '20'
		}, Param{
			key: 'has_public_ip'
			value: 'yes'
		}, Param{
			key: 'has_public_config'
			value: '1'
		}]
		args: []
	}
}

fn test_action_some_params_inline() {
	mut docs := new(
		content: '
!!farmerbot.nodemanager.define id:15 twinid:20 has_public_ip:yes has_public_config:1
'
	)!

	assert docs.items.len == 1
	assert docs.items[0] is Action
	action := docs.items[0] as Action
	assert action.name == 'farmerbot.nodemanager.define'
	assert action.params == Params{
		params: [Param{
			key: 'id'
			value: '15'
		}, Param{
			key: 'twinid'
			value: '20'
		}, Param{
			key: 'has_public_ip'
			value: 'yes'
		}, Param{
			key: 'has_public_config'
			value: '1'
		}]
		args: []
	}
}

fn test_action_some_params_some_arguments_multi_line() {
	mut docs := new(
		content: '
!!farmerbot.nodemanager.define
	id:15
	has_public_config
	has_public_ip:yes
	is_dedicated
'
	)!

	assert docs.items.len == 1
	assert docs.items[0] is Action
	action := docs.items[0] as Action
	assert action.name == 'farmerbot.nodemanager.define'
	assert action.params == Params{
		params: [Param{
			key: 'id'
			value: '15'
		}, Param{
			key: 'has_public_ip'
			value: 'yes'
		}]
		args: ['has_public_config', 'is_dedicated']
	}
}

fn test_action_some_params_some_arguments_single_line() {
	mut docs := new(
		content: '
!!farmerbot.nodemanager.define id:15 has_public_config has_public_ip:yes is_dedicated
'
	)!

	assert docs.items.len == 1
	assert docs.items[0] is Action
	action := docs.items[0] as Action
	assert action.name == 'farmerbot.nodemanager.define'
	assert action.params == Params{
		params: [Param{
			key: 'id'
			value: '15'
		}, Param{
			key: 'has_public_ip'
			value: 'yes'
		}]
		args: ['has_public_config', 'is_dedicated']
	}
}
