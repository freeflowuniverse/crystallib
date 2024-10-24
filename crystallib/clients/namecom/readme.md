# namecom


## implementation

see https://www.name.com/api-docs/dns#ListRecords

then exporter for https://www.luadns.com/



To get started

```vlang


import freeflowuniverse.crystallib.clients. namecom

mut client:= namecom.get()!

client...




```

## example heroscript

```hero
!!namecom.configure
    secret: '...'
    host: 'localhost'
    port: 8888
```


