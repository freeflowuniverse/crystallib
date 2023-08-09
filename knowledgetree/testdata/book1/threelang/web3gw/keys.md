# Keys

An actor that loads all the needed clients to interact with the supported chains (`tfchain`, `stellar`, `etherum`, `bitcoin`, ...).

## Actions

- action name: `!!web3gw.keys.define`
- parameters:

    TFChain client configuration:
  - `mnemonic`: required, mnemonic to load the tfchain client with
  - `network`: default to `dev`, tfchain network to connect to

    Bitcoin client configuration:
  - `bitcoin_host`
  - `bitcoin_user`
  - `bitcoin_pass`

    Ethereum client configuration:
  - `ethereum_url`
  - `ethereum_secret`

    Stellar client configuration:
  - `steller_network`: default to `public`, stellar network to connect to
  - `steller_secret`

- examples:
    Load handler that holds tfchain, stellar clients:

    ```md
    !!web3gw.keys.define
        tfc_mnemonic:'candy maple cake sugar pudding cream honey rich smooth crumble sweet treat'
        tfc_network:dev
        str_network:public
        str_secret:'SAKRB7EE6H23EF733WFU76RPIYOPEWVOMBBUXDQYQ3OF4NF6ZY6B6VLW'
