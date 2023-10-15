# Account examples

## Create account
Allows you to create an account on tfchain. The generated mnemonic will be printed out on command line, make sure to save it!

- `-n`: tfchain network

```sh
v -cg run create_account.v -n mainnet
```

## Balance of Tfchain account
Prints out the balance for your account on tfchain given the mnemonic and the network.

- `-m`: tfchain mnemonic
- `-n`: tfchain network

```sh
v -cg run balance.v -m mnemonic -n mainnet
```

## Account information

Shows information related to your account on tfchain (address, balance, twinid, etc.).

- `-m`: tfchain mnemonic
- `-n`: tfchain network

```sh
v -cg run account_info.v -m mnemonic -n mainnet
```

## Tranfer 

Transfer tft from your account to another
- `-m`: tfchain mnemonic
- `-n`: tfchain network
- `-a`: amount to transfer
- `-d`: destination (SS58 address)

```sh
v -cg run transfer.v -m mnemonic -n mainnet -a 5000 -d SS58_address
```