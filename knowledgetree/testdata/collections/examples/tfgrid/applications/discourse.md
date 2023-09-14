# Discourse Example

The discourse example exposes the following functionality:

- deploying a discourse instance with custom specs.
- reading a discourse instance from the grid.
- deleting a discourse instance from the grid.

## CLI Arguments

The [discourse cli](../../../../examples/tfgrid/discourse.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: Name of the discourse instance
- farm_id: Farm ID to deploy the instance on. If 0, a random eligible node on a random farm will be selected. defaults to `0`.
- capacity: Capacity of the discourse instance. must be one of `small`, `medium`, `large`, or `extra-large`. defaults to `medium`.
- disk: Size in GB of disk to be mounted. defaults to `0`
- ssh: public SSH key to access the Presearch machine. should be in `~/.ssh/id_rsa.pub` on linux systems.
- dev_email: Developer email
- smtp_address: SMTP server domain address.
- smtp_username: SMTP username
- smtp_password: SMTP password
- smtp_enable_tls: True to enable TLS for SMTP. defaults to `false`
- smtp_port: SMTP server port, defaults to `587`
- public_ipv6: Add public ipv6 to the instance. defaults to `false`
  
```sh
    v run discourse.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name mydiscourse --capacity large --ssh "YOUR PUBLIC SSH KEY"
```

### Get Operation Arguments

- name: name of the discourse instance

```sh
    v run discourse.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name mydiscourse
```

### Delete Operation Arguments

- name: name of the discourse instance

```sh
    v run discourse.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name mydiscourse
```
