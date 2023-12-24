# zdb Example

The zdb example exposes the following functionality:

- deploying a zdb instance with custom specs.
- reading a zdb instance from the grid.
- deleting a zdb instance from the grid.

## CLI Arguments

The [zdb cli](../../../../examples/tfgrid/zdb.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: identifier for the instance, must be unique
- node_id: node id to deploy on, if 0, a random eligible node will be selected. defaults to `0`.
- password: zdb password
- public: true to make zdb public
- size: size in GB of the zdb
- mode: mode of the zdb. must be one of `user`, or `seq`. defaults to `user`
  
```sh
    v run zdb.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name myzdb --node_id 5 --password mypass123 --size 10
```

### Get Operation Arguments

- name: name of the zdb instance

```sh
    v run zdb.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name myzdb
```

### Delete Operation Arguments

- name: name of the zdb instance

```sh
    v run zdb.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name myzdb
```
