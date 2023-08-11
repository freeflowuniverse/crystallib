# Peertube Example

The peertube example exposes the following functionality:

- deploying a peertube instance with custom specs.
- reading a peertube instance from the grid.
- deleting a peertube instance from the grid.

## CLI Arguments

The [peertube cli](../../../../examples/tfgrid/peertube.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: identifier for the instance, must be unique
- farm_id: farm id to deploy on, if 0, a random eligible node on a random farm will be selected. defaults to `0`.
- capacity: capacity of the peertube instance. must be one of `small`, `medium`, `large`, or `extra-large`. defaults to `medium`.
- ssh: public SSH key to access the Peertube machine. should be in `~/.ssh/id_rsa.pub` on linux systems.
- admin_email: admin email
- db_username: db username
- db_password: db password
  
```sh
    v run peertube.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name mypeertube --capacity small --ssh "YOUR PUBLIC SSH KEY"
```

### Get Operation Arguments

- name: name of the peertube instance

```sh
    v run peertube.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name mypeertube
```

### Delete Operation Arguments

- name: name of the peertube instance

```sh
    v run peertube.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name mypeertube
```
