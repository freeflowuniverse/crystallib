# crystal binary encoder protocol

Made for performance and smallest possible binary size

Its a very simple implementation, it just follows the order of the object and concatenate binary representations of the original information. This should lead in very fast serialization and smallest possible binary format

downsides

- if mistakes are made in encoding, data will be lost, its very minimal


example

```go

import encoder

mut e := encoder.new()
a := AStruct{
    items: ['a', 'b']
    nr: 10
    privkey: []u8{len: 5, init: u8(0xf8)}
}
e.add_list_string(a.items)
e.add_int(a.nr)
_, privkey := ed25519.generate_key()!
e.add_bytes(privkey)

println(e.data)
mut d := encoder.decoder_new(e.data)
mut aa := AStruct{}
aa.items = d.get_list_string()
aa.nr = d.get_int()
aa.privkey = d.get_bytes()

assert a == aa
```