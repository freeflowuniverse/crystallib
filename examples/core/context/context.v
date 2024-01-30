module main
import freeflowuniverse.crystallib.core.play


fn foo()!{

	// !!core.snippet name:codeargs pull:true reset:false

	text := "
		!!core.context_set name:'mybooks' cid:'000' interactive:false coderoot:'~/hero/code'

		!!core.coderoot_set coderoot:'~/hero/code'

		//sets the params in current session
		!!core.params_session_set
			param1:'111'
			param2:'222'

		!!core.params_context_set
			param1:'111'
			param2:'222'


		"

	mut session := play.session_new(script3: text)!
	println("######### PLAYBOOK")
	println(session.plbook)
	println("######### CONTEXT")
	println(session.context)
	println("######### SESSION")
	println(*session)

}


fn main() {
	foo() or { panic(err) }
}
