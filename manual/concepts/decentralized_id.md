
we are building a decentralized DNS system

- the DNS system is stored in a git based repo
- each repo can max host the names for 10 million people
- each person has a public key of 32 bytes
- the public key gets mapped to a unique id per repository per public key (just u32 = 4 bytes)
- each person can register 1 or more names (max 12 characters, min 3)
- these names are unique per repo and linked to the id of the public key
- a name can be owned by min 1, max 5 public keys (names can be co-owned) = means max 4 bytes x 5 to identify which users own a name
- we represent database for public keys and names as directory structures
- the database is done as follows
    - the first byte represented in hex identies a dir in $repodir/names/$firstbyte e.g. /data/repo1/names/aa/ 
    - in each directory we can have max 
    - the first 2 bytes which is 4x256 combinations result in a directory structure of 2 levels deep with max 256 files in each
    - e.g. [aa,0a,c4,... other 28 bytes] results in directory for names
      - each part is 1 hex representation for a byte
      - $repodir/names/aa/0a/3b/c4  the last c4 is a text file which has all the names + signatures + owners for that level
      - the the c4 file is \n separated (lines) 
      - each line has following: $rest_of_hex_representation_28bytes:aa,bb,cc,dd:$signature\n
      - the aa,bb,cc,dd are in this case 4 u32 representing the public keys of the users who own this name 
      - the signature is secp256k1 signature which can be verified by everyone who reads this file, only 1 of users need to sign
      - the signature is on name+the id's of who owns the name (so we verify ownership)
    - this means we can get max: 256*256*256*256 files (3 directory levels + 256 files per dir) = 

- 1 pub key mycelium = 32 bytes
- we store 
- 1 repo has 1 extension e.g. .mynames
- each 
- max 10 million subnames of 1 extension
