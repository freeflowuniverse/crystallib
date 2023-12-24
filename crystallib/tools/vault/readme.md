# Vault


Methods to keep history of folders, can be used as a backup solution.

the result will be .vault folders in each directory which have the history of files as well as version nr's

```
./.vault
./.vault/newfile1.1
./.vault/meta
./markdownparser
./newfile1
./test_parent
./test_parent/.test_ignore
./test_parent/.vault
./test_parent/.vault/readme.1.md
./test_parent/.vault/meta
./test_parent/readme.md
```

a metadata file looks like

```bash
a73f7818de83bcc1dc4fe89190b2d3054bd37c10bb1ed055693292f2da50cba3|1662454965|1|newfile1
b7129644df8d551f6b3f2905e5b44795087f4da77a62b1ad663f5b107ca9dac2|1662454965|1|readme.md
cc1dc4fe89190b2d3c4fe89190b2d3054bd37c10bb1ed055693290b2d3054bd3|1662454980|2|newfile1
```

the nr's will go up if new version, newfile got 2 versions here



## restore

> not implemented yet