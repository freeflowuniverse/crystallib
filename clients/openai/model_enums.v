module openai

pub enum ModelType {
	gpt_3_5_turbo
	gpt_4
	gpt_4_0613
	gpt_4_32k
	gpt_4_32k_0613
	gpt_3_5_turbo_0613
	gpt_3_5_turbo_16k
	gpt_3_5_turbo_16k_0613
}

fn modelname_str(e ModelType) string {
	if e == .gpt_4 {
		return 'gpt-4'
	}
	if e == .gpt_3_5_turbo {
		return 'gpt-3.5-turbo'
	}

	// TODO: https://platform.openai.com/docs/models/how-we-use-your-data implement remaining
	panic('could not find right type')
}

pub enum RoleType {
	system
	user
	assistant
	function
}

fn roletype_str(x RoleType) string {
	return match x {
		.system {
			'system'
		}
		.user {
			'user'
		}
		.assistant {
			'assistant'
		}
		.function {
			'function'
		}
	}
}
