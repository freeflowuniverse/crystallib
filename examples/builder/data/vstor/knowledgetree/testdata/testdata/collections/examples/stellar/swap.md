# Swap tokens example

Swap tokens from one asset type to the other (XLM to TFT for example)

## Prerequisites

- Stellar accounts with some XLM and TFT (if you wish to swap TFT to XLM)

## run the example

- `-s`: stellar secret of your stellar account
- `-n`: network (testnet/public, default=public)
- `-o`: the asset to swap (default is xlm)
- `-d`: the destination asset (tft for example)
- `-a`: amount of tokens to swap (can be with decimals: "0.1")

```sh
v -cg run swap.v -s stellar_secret -o xlm -d tft -m amount
```