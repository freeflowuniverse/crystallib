module actionparser
import texttools

pub struct ActionsParser {
pub mut:
	actions []Action
}

pub struct Action {
pub:
	name string
pub mut:
	params texttools.Params
}

// get the param as string, if it does not exist will throw error
pub fn (mut action Action) param_get(name_ string) ?string {
	return action.params.get(name_)
}
