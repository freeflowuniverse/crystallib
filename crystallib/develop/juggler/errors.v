module juggler

import veb

pub struct JugglerError {}

fn invalid_event(data string) string {
	return('The event data received is invalid. Received: ${data}')
}

pub fn (mut ctx Context) error(err JugglerError) veb.Result {
	return ctx.text('no dag found for repo')
}