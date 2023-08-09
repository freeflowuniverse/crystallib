# Account Transactions Action

> Return a limited amount of transactions bound to a specific account

- action name: !!stellar.account.transactions
- parameters:
  - account [optional]
    - filter the transactions on the account with the address from this argument, leave empty for your account
  - limit [optional]
    - limit the amount of transactions to gather with this argument, this is 10 by default
  - include_failed [optional]
    - include the failed arguments
  - cursor [optional]
    - list the last transactions starting from this cursor, leave empty to start from the top
  - ascending [optional]
    - order the transactions in ascending order

## Example

```md
    !!stellar.account.transactions
```
