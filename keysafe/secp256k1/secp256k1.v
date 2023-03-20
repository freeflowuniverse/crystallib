module secp256k1

#include "@VMODROOT/secp256k1mod.h"

#flag @VMODROOT/secp256k1mod.o
#flag -lsecp256k1

struct Secp256k1_t {
	kntxt &C.secp256k1_context
}

fn C.secp256k1_new() &Secp256k1_t

pub fn init() string {
	a := C.secp256k1_new()
	return 'LOL'
}

fn test() {
	println('Hello World')
}
