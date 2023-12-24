module play

import freeflowuniverse.crystallib.data.paramsparser
import os

fn test_one() {
	text := "
	!!core.context_set name:'mybooks' cid:'000' interactive:false fsdb_encrypted:true coderoot:'~/hero/code'

	//sets the params in current session
	!!core.params_session_set
		param1:'111'
		param2:'222'

	!!core.params_context_set
		param1:'1111'
		param2:'2222'


	"

	mut session := session_new(script3: text)!
	println(*session)
	println(session.context)

	println(session.params)
	assert session.params == paramsparser.Params{
		params: [paramsparser.Param{
			key: 'param1'
			value: '111'
			comment: ''
		}, paramsparser.Param{
			key: 'param2'
			value: '222'
			comment: ''
		}]
		args: []
		comments: []
	}
}
