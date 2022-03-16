module core

#flag -lcrpgp
#include "crpgp.h"

// KeyParams
[params]
pub struct KeyParams {
  name      string [required]
  email     string [required]
  key_type   CipherSuite
  length    u32
  comment   string

}

pub fn (self KeyParams) id() string {
  comment := if self.comment != "" {
    "($self.comment) "
  } else { "" }
  return "$self.name $comment<$self.email>"
}

pub enum CipherSuite {
  cv25519 // ed_dsa primary, ecdh sub
  rsa     // rsa primary (rsa and bitsize can be parameterized)
}

// id string, masterkey_keytype C.KeyType, subkey_keytype C.KeyType
pub fn generate_key(k KeyParams) ?SignedSecretKey {
  mut primarykey_type := C.KeyType{}
  mut subkey_type := C.KeyType{}
  match k.key_type {
    .cv25519 {
      primarykey_type = C.KeyType{KeyType_Tag.ed_dsa, 0}
      subkey_type = C.KeyType{KeyType_Tag.ecdh, 0}
    }
    .rsa {
      primarykey_type = C.KeyType{KeyType_Tag.rsa, k.length}
      subkey_type = C.KeyType{KeyType_Tag.rsa, k.length}
    }
  }

  builder := new_secret_key_param_builder()?
  builder.primary_key_id(k.id())?
  builder.key_type(primarykey_type)?
  subkey_builder := new_subkey_params_builder()
  subkey_builder.key_type(subkey_type)?
  subkey := subkey_builder.build()?
  builder.subkey(subkey)?
  params := builder.build()?
  sk := params.generate_and_free()?
  ssk := sk.sign()?
  return ssk
}