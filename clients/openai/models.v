module openai

import json

pub struct Model {
pub mut:
	id string
	created int
	object string
	owned_by string
	root string
	parent string
	permission []ModelPermission
}

pub struct ModelPermission {
pub mut:
	id string
	created int
	object string
	allow_create_engine bool
	allow_sampling bool
	allow_logprobs bool
	allow_search_indices bool
	allow_view bool
	allow_fine_tuning bool
	organization string
	is_blocking bool	
}

pub struct Models {
pub mut:
	data []Model
}

pub fn (mut f OpenAIFactory) list_models() !Models {
	r := f.connection.get(prefix: 'models')!
	return json.decode(Models, r)!
}

pub fn (mut f OpenAIFactory) get_model(model string) !Model {
	r := f.connection.get(prefix: 'models/' + model)!
	return json.decode(Model, r)!
}
