
we are building a decentralized DNS system

- the DNS system is stored in a filedb, which is a directory with subdirs where directory structure + file name, defines the key
- we store pubkeys (32 bytes) and names (like dns names)- 
- the public key gets mapped to a unique id per filedb dir
- each person can register 1 or more names (max 12 characters, min 3)
- these names are unique per repo and linked to the id of the public key
- a name can be owned by min 1, max 5 public keys (names can be co-owned) = means max 4 bytes x 5 to identify which users own a name
- we represent database for public keys and names as directory structures
- database for public keys
    - each pubkey as remembered in the file database in the repo on $repodir/keys gets a unique incremental key = int
    - we have max 256 dirs and 256 files, where the name is first byte expressed as hex
    - e.g. hex(999999) = 'f423f', this results in $repodir/keys/f4/23.txt
    - in each txt file we \n separate the entries (each line is pubkey\n)
    - 999999 -> f4/23 then f (remainder) gets converted back to int and this is the element in the list in 23.txt (the Xe line)
    - this means max nr of dirs:65536, max nr of elements in file = 152 items, line separated
    - this means it goes fast to process one txt file to retrieve relation between id and pubkey
    - this db allows gast retrieval of pubkey based on int (unique per file db dir)
    -  the order of the lines is never changed, new data always added so we keep unique id (int)
- database for names
  - names are ascii only with ofcourse '.' as separator
  - names are 2 levels  e.g. kristof.belgium
  - we hash the name md5, take first 2 chars as identifier for directory, the next 2 chars as text file with the names
  - e.g. /data/repo1/names/aa/bb.txt  (aa would be first 2 chars of md5, bb next 2 chars of md5)
  - names are in that bb.txt file (example), they are added as they come in
  - the linenr is the unique id in that file, which means each name has unique id as follows
    - aabb1 (position 1) would result to: aabb -> int + 1, e.g. position 999 would be hex2int(aabb)+999
    - this would be the unique int
  - per line we store the following: $name(lowercase, ascii):f423f,a4233:signature
    - this means 2 pub keys linked to the name
    - the link is done by an id (as described above, which can then be mapped back to pubkey)
    - the signature is secp256k1 signature which can be verified by everyone who reads this file, only 1 of users need to sign
      - the signature is on name+the id's of who owns the name (so we verify ownership)
  - the order of the lines is never changed, new data always added so we keep unique id (int)

now create the following python functions and implement above

```python
#register pubkey in the pubkey db, return the int
def key_register(pubkey) -> int

class NamePreparation:
  name str
  pubkeys []int #position of each pubkey in the pubkey db
  signature []u8 #bytestr of the secp256k1 signature

  #sign name + int's (always concatenated in same way) with given privkey
  #the result is stored in signature on class
  def sign(privkey):
    #need to check that priv key given is part of the pubkeys

  #return str representation which is $name:f423f,a4233,...:$signature
  def str() -> str:
      ...

#name will be lowercased, trimmed space
#max 1 dot in name (2 levels in DNS, top and 1 down)
#signature is secp256k and will be verified in this function against all given pubkeys
#the first pubkey need to have signed the name + 
#returns the inique id of the name in this filedb repo
def name_register(name:str,pubkeys:[]str,privkey:...) -> int:
  #will use NamePreparation functionality
  #str() will give the right str which is added as newline to the right file in the filedb

#find the name, NotFound exception when name not found, 
#if verify on then will check the signature vs the first pubkey of the list
def name_get(id:int,verify:bool=True) -> str:

def key_get(id:int) -> PubKey:



```

