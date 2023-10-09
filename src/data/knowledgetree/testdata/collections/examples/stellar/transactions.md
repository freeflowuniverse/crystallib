# Transactions example

Get the last transactions of an account

## Prerequisites

- Stellar account

## run the transactions example

- `-s`: stellar secret of your account
- `-l`: limit the amount of transactions to return, default is 10
- `-n`: network (testnet/public, default=public)

```sh
v -cg run transactions.v -s stellar_secret -n testnet
```