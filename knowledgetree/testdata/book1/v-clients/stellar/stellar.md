# v Stellar client

Any of the calls mentioned below need a [RPC websocket client to a web3proxy server](../vclients.md#rpc-websocket-client) which is assumed to be present in a variable `rpc_client`.

```v
mut stellar_client := stellar.new(mut rpc_client)
```

## Create a stellar account

You can create a stellar account using the `create_account` method. It takes one argument: the network to create the account on. During the execution of that method the generated key is loaded thus allowing you to call other methodes right after this method without having to load the key first.

```v
seed := stellar_client.create_account("public")
```

## Load a client

If you already possess a stellar account you can just load the key by calling the `load` method. This requires the `secret` of your stellar account and optionally the network to connect to (the default network is public).

```v
secret := 'SB1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGH'

mut stellar_client := stellar.new(mut rpc_client)
stellar_client.load(secret: secret, network: 'public')!
```

## Get TFT balance

The `balance` function gets the TFT balance of an account. If the passed account is an empty string, the balance of the loaded stellar account is returned.

```v
balance := stellar_client.balance('')!
```

## Get data related to an account

The `account_data` function gets the data related to an account. If the passed account is an empty string, the data related to the loaded stellar account is returned.

```v
account_data := stellar_client.account_data('')!
```

## Transfer TFT from one account to the other on stellar

Calling `transfer` allows you to transfer tft on stellar from one account to the other.

```v
amount := '1651.12'
destination := 'GBN4RY5FDSY5MJJKD3G4QYXLQ73H6MXYPUXT4YMV3JXWA2HCXAJTFOZ2'
stellar_client.transfer(destination: destination, amount: amount)!
```

## Swap tokens from one asset to the other

If you wish to swap some tokens into another asset, for example from XLM (lumen) to TFT you can do so by calling the `swap` method.

```v
amount := '500.0'
destination := 'GBN4RY5FDSY5MJJKD3G4QYXLQ73H6MXYPUXT4YMV3JXWA2HCXAJTFOZ2'
stellar_client.swap(amount: amount, source_asset: "xlm", destination_asset: "tft")!
```

## Transactions

Transactions of an account can be returned with the method `transactions`. Here are the arguments it takes:

- `account`: filter the transactions on the account with the address from this argument, leave empty for your account
- `limit`: limit the amount of transactions to gather with this argument, this is 10 by default
- `include_failed`: include the failed arguments
- `cursor`: list the last transactions starting from this cursor, leave empty to start from the top
- `ascending`: if true it will list the transactions in ascending order, default is false

```v
amount := '500.0'
myaccount := stellar_client.address()!
transactions := stellar_client.transactions(account:myaccount, limit:20)!
```

## Convert TFT on Stellar to TFT on Ethereum

The stellar client provides an easy way to convert [TFT on Stellar](https://github.com/threefoldfoundation/tft-stellar) to [TFT on Ethereum](https://github.com/threefoldfoundation/tft/tree/main/ethereum) using the Stellar-Ethereum bridge.

The `amount` parameter is a string in decimal format of the number of TFT's to convert. Keep in mind that a conversion fee of 2000 TFT will be deducted so make sure the amount is larger than that.

The destination parameter is the Ethereum account that will receive the TFT's.

The following snippet will send 1000.50 TFT (3000.50 - 2000 conversion fee) to 0x65e491D7b985f77e60c85105834A0332fF3002CE.

```v
amount := '3000.50'
destination := '0x65e491D7b985f77e60c85105834A0332fF3002CE'
stellar_client.bridge_to_eth(amount: amount, destination: destination)!
```

The conversion from TFT on Ethereum to TFT on Stellar is part of the [Ethereum client](../ethereum/ethereum.md#convert-tft-on-ethereum-to-tft-on-stellar).

## Convert TFT on Stellar to TFT on Tfchain

The Stellar-Tfchain bridge allows you to convert your TFTs on stellar to TFTs on Tfchain. Calling the method `bridge_to_tfchain` will initiate that process. It requires the amount and the twin id of the recipient on Tfchain.

Note that the `bridge_to_tfchain` will return once that the transaction has been executed on Stellar. This does not mean that the amount transferred will be on the Tfchain account right away. The bridge has to recognize the transaction and create a similar transaction on Tfchain. It is therefore encouraged to execute the `await_transaction_on_tfchain_bridge` method (from [Tfchain client](../tfchain)) right after the `bridge_to_tfchain` method. This function returns once it recognizes the transaction with the hash return by `bridge_to_tfchain`. The example demonstrates the process.

```v
amount := '3000.50'
hash := stellar_client.bridge_to_tfchain(amount: amount, twin_id: 53)!

tfchain_client.await_transaction_on_tfchain_bridge(hash)!
```
