# Swap examples

## Prerequisites

- Ethereum account with at least 0.01 ETH

## Swap Eth to Ethereum TFT

- `-s`: ethereum secret
- `-m`: the amount of Eth to swap for TFT (can be with decimals: "0.1")
- `-e`: ethereum node url

```sh
v -cg run swap_eth_for_tft.v -m "0.00001" -s ethereum_s -e https://goerli.infura.io/v3/your_infura_key
```

You will get prompted if you are satisfied with the transaction. If you are, type `y` and hit enter. Otherwise, type `n` and hit enter.

## Swap Ethereum TFT to Eth

- `-s`: ethereum secret
- `-m`: amount of tft in string format (can be with decimals: "0.1")
- `-e`: ethereum node url

```sh
v -cg run swap_tft_for_eth.v -s secret -d destination_stellar_addrr -m "100.50" -e https://goerli.infura.io/v3/your_infura_key
```

You will get prompted if you are satisfied with the transaction. If you are, type `y` and hit enter. Otherwise, type `n` and hit enter.
