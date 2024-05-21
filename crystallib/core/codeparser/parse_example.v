module codeparser
// import freeflowuniverse.crystallib.core.codemodel {Example}
// import freeflowuniverse.crystallib.rpc.openrpc {ExamplePairing}

// pub fn parse_example_pairing(text_ string) !ExamplePairing {
// 	if !text_.contains('Example:') { return error('no example found fitting format') }
// 	mut text := text_.all_after('Example:').trim_space()
	
// 	mut pairing := ExamplePairing{}

// 	if text.contains('assert') {
// 		pairing.name = if text.all_before('assert').trim_space() != '' {
// 			text.all_before('assert').trim_space()
// 		} else {text.all_after('assert').all_before('(').trim_space()}
// 		value := text.all_after('==').all_before('//').trim_space()
// 		pairing.result = parse_example()
// 		description := text.all_after('//').trim_space()
// 	}

// 	return pairing
// }

// pub fn parse_examples(text string) []openrpc.Example {

// }

// pub fn parse_example(text string) openrpc.Example {
// 	return Example{

// 	}
// }