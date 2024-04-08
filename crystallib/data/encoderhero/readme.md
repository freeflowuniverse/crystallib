# hero Encoder

> encoder hero is based on json2 from https://github.com/vlang/v/blob/master/vlib/x/json2/README.md

## Usage

#### encode[T]

```v
#!/usr/bin/env -S v -w -cg -enable-globals run

import freeflowuniverse.crystallib.data.encoderhero
import time

struct Person {
mut:
	name     string
	age      ?int = 20
	birthday time.Time
	deathday ?time.Time
}

mut person := Person{
    name: 'Bob'
    birthday: time.now()
}
person_json := encoderhero.encode[Person](person)

```

#### decode[T]

```v
import freeflowuniverse.crystallib.data.encoderhero
import time

struct Person {
mut:
	name     string
	age      ?int = 20
	birthday time.Time
	deathday ?time.Time
}

data := '

'

person := encoderhero.decode[Person](data)!
/*
struct Person {
    mut:
        name "Bob"
        age  20
        birthday "2022-03-11 13:54:25"
    }
*/

```


#### raw decode

```v
import x.json2
import net.http

fn main() {
	resp := http.get('https://reqres.in/api/products/1')!

	// This returns an Any type
	raw_product := json2.raw_decode(resp.body)!
}
```


## License

for all original code as used from Alexander:

// Copyright (c) 2019-2024 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.