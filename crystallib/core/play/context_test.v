module play

import os

fn test_one() {
	text := "
	!!core.context_set name:'mybooks' cid:'000' interactive:false fsdb_encrypted:true coderoot:'~/hero/code'

	!!core.coderoot_set '~/hero/code'

	!!core.snippet codeargs pull:true reset:false

	//sets the params in current session
	!!core.params_session_set
		param1:'111'
		param2:'222'

	!!core.params_context_set
		param1:'111'
		param2:'222'


	"

	mut session := session_new(script3: "")!
	println(session)
	if true {
		panic('sdsds')
	}
}
