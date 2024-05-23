# BIP39 (mnemonic)

This is a pure v-lang implementation of BIP39.

**WARNING:** seed generation is not supported yet, only mnemonic to entropy and vice-versa is supported.

# Wordlists

Only `English` is supported right now and is embeded on compile time.
Wordlist comes from official `bitcoin/bip-0039/english.txt`.

# Mnemonic

The module needs to be instanciated with:

```
m := mnemonic.new()!
```

Possible error are wordlist parsing issue.

# Get entropy from mnemonic

```
words := "winter hire open opinion frown turtle this bulb mouse spell endorse thumb regret useless expand nerve improve impulse"
entropy := m.to_entropy(words)
```

# Get mnemonic from entropy

```
entropy := m.generate_entropy(224)! // or your own entropy buffer
words := m.to_mnemonic(entropy)!
```

# Tests

In order to validate implementation, tests vector from python-mnemonicvectors.json is included.

This is implemented via `mnemonic_test.v`
