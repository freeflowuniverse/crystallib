# RMB

Reliable Message Bus

Can talk to ZOS'es, ...

## requirements

We need client to rmb-rs

compile rmb-rs (see below)

```bash
rmb-peer --mnemonics "$(cat mnemonic.txt)" --relay wss://relay.dev.grid.tf:443 --substrate wss://tfchain.dev.grid.tf:443

#OR:

export TFCHAINSECRET='something here'

rmb-peer --mnemonics "$TFCHAINSECRET" --relay wss://relay.dev.grid.tf:443 --substrate wss://tfchain.dev.grid.tf:443

```

### for developers

more info see https://github.com/threefoldtech/rmb-rs
the message format of RMB itself https://github.com/threefoldtech/rmb-rs/blob/main/proto/types.proto


> TODO: implement each endpoint on the zerohub here at client

> TODO: the original code comes from code/github/threefoldtech/farmerbot/farmerbot/system/zos.v 


