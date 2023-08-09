# Create Account Action

> Creates an account on the provided network and returns the seed. Consecutive calls will be using the newly created account.

- action name: !!stellar.account.create
- parameters:
  - network [optional]
    - network to create the account on. defaults to `testnet`

## Example

```md
    !!stellar.account.create
```
