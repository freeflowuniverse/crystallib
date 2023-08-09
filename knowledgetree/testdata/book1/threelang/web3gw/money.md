# Money

Is an inter-chain centralized actor that can do all money related actions on supported chains (`tfchain`, `stellar`, `etherum`, `bitcoin`, ...).

## Actions

### Send tokens

Sending the same type of token from one account to another account on the same chain or on another chain via the bridge.

- action name: `!!web3gw.money.send`
- parameters:
  - `channel`: `[required]` the chain where the transaction will be done. (`tfchain`, `stellar`, `ethereum`, `bitcoin`, ...)
  - `channel_to`: `[optional]` the destination chain to send the `TFT` to. (`stellar`, `ethereum`, `tfchain`, ...)
  - `to`: `[required]` the destination address or twin_id if destination chain is `tfchain`
  - `amount`: `[required]` the amount to send

- examples:
  - Send tft on tfchain from the loaded account

        ```
        !!web3gw.money.send
            channel:tfchain
            to:28
            amount:100
        ```
  - Send tft from the loaded stellar account to tfchian twin

        ```
        !!web3gw.money.send
            channel:stellar
            channel_to:tfchain
            to:28
            amount:100
        ```

### Swap tokens

Swapping is converting tokens from one type to another on the same chain.

- action name: `!!web3gw.money.swap`
- parameters:
  - `from`: `[required]` the token you want to swap from.
  - `to`: `[required]` the token you want to swap to.
  - `amount`: `[required]` the amount to swap.

- examples:
  - Swap `tft` to `eth` on ethereum chain

        ```
        !!web3gw.money.swap
            from:eth
            to:tft
            amount:100
        ```

### Get balance

Get the balance of the loaded client on a chain.

- action name: `!!web3gw.money.balance`
- parameters:
  - `channel`: `[required]` the chain where you want to check the balance. (`tfchain`, `stellar`, `ethereum`, `bitcoin`, ...)
  - `currency`: `[required]` the currency to get balance for (`tft`, `btc`, `eth`, `xlm`, ...).
- examples:

    ```
    !!web3gw.money.balance
        channel:tfchain
        currency:tft
    ```

    ```
    !!web3gw.money.balance
        channel:ethereum
        currency:tft
    ```
