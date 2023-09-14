module openai

import os
import freeflowuniverse.crystallib.httpconnection

pub struct OpenAIFactory {
mut:
	connection &httpconnection.HTTPConnection
}

[params]
pub struct OpenAIFactoryArgs {
pub:
	openaikey string
}

pub fn new(args OpenAIFactoryArgs) !OpenAIFactory {
	mut conn := httpconnection.new(
		name: 'openai'
		url: 'https://api.openai.com/v1/'
	)!
	mut oif := OpenAIFactory{
		connection: conn
	}
	env := os.environ()
	mut key := args.openaikey
	if 'OPENAI_API_KEY' in env {
		// compensate for internet not being there
		key = env['OPENAI_API_KEY']
	}
	oif.connection.default_header.add(.authorization, 'Bearer ${key}')
	// req.add_custom_header('x-disable-pagination', 'True') !

	return oif
}
