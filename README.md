# set of libraries

- [PLANNING HERE](https://circles.threefold.me/project/despiegk-product_publisher/issues)

As used for Threefold and ...

## to install

```bash
sh install.sh
```

## to develop

- go to ~/.vmodules/ checkout this repo under despiegk/crystallib
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


