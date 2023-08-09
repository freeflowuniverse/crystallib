# v Ethereum client

## Create and load a client

Needs an [RPC websocket client to a web3proxy server](../vclients.md#rpc-websocket-client) which is assumed to be present in a variable `rpc_client`.

The `url` parameter needs the url to an Ethereum full node and the `secret` parameter a private key in hex format of the Ethereum account the client needs to use.

```v
eth_url := 'ws://185.69.167.224:8546'
secret := '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'

mut eth_client := eth.new(mut rpc_client)
eth_client.load(url: eth_url, secret: secret)!
```

## Convert TFT on Ethereum to TFT on Stellar

The Ethereum  clients provides an easy way to convert [TFT on Ethereum](https://github.com/threefoldfoundation/tft/tree/main/ethereum) to  [TFT on Stellar](https://github.com/threefoldfoundation/tft-stellar) using the Stellar-Ethereum bridge.

The `amount` parameter is a string in decimal format of the number of TFT's to convert. Keep in mind that a conversion fee of 1 TFT will be deducted so make sure the amount is larger than that.

The destination parameter is the Stellar account that will receive the TFT's.

The following snippet will send 49.12 TFT (50.12 - 1 conversion fee) to GBN4RY5FDSY5MJJKD3G4QYXLQ73H6MXYPUXT4YMV3JXWA2HCXAJTFOZ2.

```v
amount := '50.12'
destination := 'GBN4RY5FDSY5MJJKD3G4QYXLQ73H6MXYPUXT4YMV3JXWA2HCXAJTFOZ2'

eth_client.bridge_to_stellar(destination: destination, amount: amount)!
```

## Convert TFT on Stellar to TFT on Ethereum

The conversion from TFT on Stellar to TFT on Ethereum  is part of the [Stellar client](../stellar/stellar.md#convert-tft-on-stellar-to-tft-on-ethereum).

## Swaps

The web3gw proxy allows buying TFT with and selling TFT for Eth via [uniswap](https://uniswap.org).

### Eth to TFT

Before you actually swap Eth to TFT you may want to know how much TFT you will get.

The ethereum client allows to get a quote for a swap.

```v
eth_to_swap :='0.01'
tftToReceive := eth_client.quote_eth_for_tft(eth_to_swap)!
```

Execute the swap.

```v
eth_to_swap :='0.01'
tx := eth_client.swap_eth_for_tft(eth_to_swap)!
```

### TFT to Eth

Before you actually swap TFT to Eth you may want to know how much Eth you will get.

The ethereum client allows to get a quote for a swap.

```v
tft_to_swap := '2000'
eth_to_receive := eth_client.quote_tft_for_eth(tft_to_swap)!
```

The uniswap contract can not simply take TFT out of your account to perform the swap.

TFT is an ERC-20 token and this provides the ability to approve another account or contract to take a certain amount of TFT from your balance. Every time this other account spends an amount of TFT from your account, this is substracted from the approved amount.

At least the amount of TFT for this swap needs to be approved before the swap can be performed.

```v
t := eth_client.approve_eth_tft_spending(tft_to_swap)!
```

You can approve a much bigger amount to avoid an approval transaction for every swap, saving gas.

To check how much TFT is still allowed to be swapped, use the `get_eth_tft_allowance` function.

```v
approved_amount := eth_client.get_eth_tft_allowance()!
```

Execute the swap.

```v
tx := eth_client.swap_tft_for_eth(tft_to_swap)!
```
