
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
