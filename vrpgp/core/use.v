module core

#flag -lcrpgp
#include "crpgp.h"
// id string, masterkey_keytype C.KeyType, subkey_keytype C.KeyType
pub fn generate_key() ?SignedSecretKey {
	builder := new_secret_key_param_builder()?
	builder.primary_key_id("sameh <sameh@gmail.com>")?
	builder.key_type(C.KeyType{KeyType_Tag.ed_dsa, 0})?
	subkey_builder := new_subkey_params_builder()
	subkey_builder.key_type(C.KeyType{KeyType_Tag.ecdh, 0})?
	subkey := subkey_builder.build()?
	builder.subkey(subkey)?
	params := builder.build()?
	sk := params.generate_and_free()?
	ssk := sk.sign()?
	return ssk
}