module crpgp

// Things that are hard to convert from the c header file automatically
pub enum KeyType_Tag {
  rsa
  ecdh
  ed_dsa
}

struct C.KeyType {
	tag KeyType_Tag
	rsa u32
}