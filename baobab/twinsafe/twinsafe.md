# twinsafe

a personal safe data stor to keep info about the 3bot ecosystem

This is a datastor in sqlite which holds your private key info and the pub key info from other twins.

context

- all 3bots can reach each other using mbus
- mbus communicates over local redis or ipv4/ipv6 reachable network
- we need to know the relation between the ipv4/6/redis and the twin id
- in our local datastor we can remember name, description, ...
- we use sqlite to remember all the info
- the personal datastor also remembers our private key(s)
- we use algo/secp256k1/secp256k1.v for signing & verification
- encryption is done using symmetric encryption (see )

## remarks

There are 2 objects, mytwin is the info I need for myself, so I can sign info and I have my private key available, othertwin only has info how I can get to another twin and communicate with it.



>> TODO: create some tests