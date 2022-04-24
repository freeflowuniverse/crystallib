
## to install

```bash
v install https://github.com/freeflowuniverse/crystallib
```

## to develop

- do ```v install https://github.com/freeflowuniverse/crystallib```
- edit the code there
- use `v run test.v` to run some ad hoc tests
- use `v test vredis2/` to run tests of one module

## generating docs

```bash
#cd in this directory
## with also private methods
v doc -all -m . -o /tmp/crystallib -f html -readme
## public methods only

rm -rf /tmp/crystallib && v doc -m . -o /tmp/crystallib -f html -readme
open /tmp/crystallib/_docs/builder.html
```

## examples see

- ```github/freeflowuniverse/crystaltools/examples```


