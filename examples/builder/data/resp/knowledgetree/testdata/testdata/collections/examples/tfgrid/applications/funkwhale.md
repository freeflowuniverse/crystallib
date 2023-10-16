# Funkwhale Example

The funkwhale example exposes the following functionality:

- deploying a funkwhale instance with custom specs.
- reading a funkwhale instance from the grid.
- deleting a funkwhale instance from the grid.

## CLI Arguments

The [funkwhale cli](../../../../examples/tfgrid/funkwhale.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: identifier for the instance, must be unique
- farm_id: farm id to deploy on, if 0, a random eligible node on a random farm will be selected. defaults to `0`.
- capacity: capacity of the funkwhale instance. must be one of `small`, `medium`, `large`, or `extra-large`. defaults to `medium`.
- ssh: public SSH key to access the Funkwhale machine. should be in `~/.ssh/id_rsa.pub` on linux systems.
- admin_email: admin email to access admin dashboard
- admin_username: admin username to access admin dashboard
- admin_password: admin password to access admin dashboard
- public_ipv6: add public ipv6 to the instance. defaults to `false`
  
```sh
    v run funkwhale.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name myfunkwhale --capacity small --ssh "YOUR PUBLIC SSH KEY" --admin_email e@email.com --admin_username user1 --admin_password pass1
```

### Get Operation Arguments

- name: name of the funkwhale instance

```sh
    v run funkwhale.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name myfunkwhale
```

### Delete Operation Arguments

- name: name of the funkwhale instance

```sh
    v run funkwhale.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name myfunkwhale
```
