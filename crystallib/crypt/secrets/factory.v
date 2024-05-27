module secrets
import freeflowuniverse.crystallib.ui.console

pub struct SecretBox {
pub mut:
	secret string
	items  map[string]string
}

@[params]
pub struct SecretBoxArgs {
pub mut:
	// reset       bool
	// interactive bool = true
	secret string @[required]
}

pub fn get(args SecretBoxArgs) !SecretBox {
	// if args.reset {
	// 	reset()!
	// }
	// if args.secret.len == 0 {
	// 	mut myui := ui.new()!
	// 	console.clear()
	// 	secret_ := myui.ask_question(question: 'Please enter your hero secret string (box)')!
	// 	secret = md5.hexhash(secret_)
	// 	r.set(key, secret)!
	// }
	return SecretBox{
		secret: args.secret
	}
}
