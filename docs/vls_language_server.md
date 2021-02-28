# V language server configuration

there is a first language server working. 


## get newest version of vls 

you will have to get newest version and build manually


```bash
v -prod cmd/vls
```

after building make sure you link to e.g /usr/local/bin/vls

the commit which worked for me was ```6a00aa1ce7363036810338b9ff9bef8670ac688a```

vls is a moving target for sure

## then download vsstudio extension

- prebuild: https://github.com/vlang/vscode-vlang/releases
- see https://github.com/vlang/vscode-vlang

download the .vsix and install in your visual studio code.
Make sure you have disabled the old extension !



