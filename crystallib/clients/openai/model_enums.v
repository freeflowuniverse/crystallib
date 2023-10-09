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
	whisper_1
}

fn modelname_str(e ModelType) string {
	if e == .gpt_4 {
		return 'gpt-4'
	}
	if e == .gpt_3_5_turbo {
		return 'gpt-3.5-turbo'
	}
	return match e {
		.gpt_4 {
			'gpt-4'
		}
		.gpt_3_5_turbo {
			'gpt-3.5-turbo'
		}
		.gpt_4_0613 {
			'gpt-4-0613'
		}
		.gpt_4_32k {
			'gpt-4-32k'
		}
		.gpt_4_32k_0613 {
			'gpt-4-32k-0613'
		}
		.gpt_3_5_turbo_0613 {
			'gpt-3.5-turbo-0613'
		}
		.gpt_3_5_turbo_16k {
			'gpt-3.5-turbo-16k'
		}
		.gpt_3_5_turbo_16k_0613 {
			'gpt-3.5-turbo-16k-0613'
		}
		.whisper_1 {
			'whisper-1'
		}
	}
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
