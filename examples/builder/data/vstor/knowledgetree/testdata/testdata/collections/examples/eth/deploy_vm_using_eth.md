# Deploying a VM with Ethereum

This example allows you to deploy a VM on our grid using Ethereum. The example will swap ethereum tokens to TFT tokens on ethereum. After that it will use a bridge to get the tokens on stellar. Once they are on stellar it will use a bridge to get them on tfchain. Once there is balance on tfchain it will be able to deploy a VM with ipv6 and your ssh key so that you can login into it with ssh. 

## Prerequisites

To run this example you will need:

- Ethereum account with some balance
- Stellar account with a TFT Trustline
- Tfchain account
- ssh key

## Tool

- `--eth-secret`: the secret of your ethereum account
- `--stellar-secret`: the secret of your stellar account (the account should have a trustline)
- `--stellar-network`: the network on stellar (either public or testnet), should be matching the network of your ethereum account
- `--tfchain-mnemonic`: the mnemonic of your account on tfchain
- `--tfchain-network`: the tfchain network (either main or dev), should be matching the stellar network
- `--ssh-key`: the ssh key you will be using to login into your vm later

```sh
v -cg deploy_vm_with_eth.v --eth-secret "your eth secret" --stellar-secret "your stellar secret" --stellar-network "testnet" --tfchain-mnemonic "your mnemonic" --tfchain-network "dev" --ssh-key "ssh-ed25519 ..."
```
