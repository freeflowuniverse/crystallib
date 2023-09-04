


## to develop

requirements

- v installed
- ssh key loaded for access to github

```bash
mkdir -p ~/code/github/freeflowuniverse
cd ~/code/github/freeflowuniverse
git clone git@github.com:freeflowuniverse/crystallib.git
cd crystallib
# checkout current branch with most recent changes
git checkout development_kristof 
bash install.sh

```

## test your code before checking in

```bash
cd ~/code/github/freeflowuniverse/crystallib
bash test.sh
```

- use `v test vredis2/` to run tests of one module

## generating docs

```bash
#cd in this directory
cd ~/code/github/freeflowuniverse/crystallib
bash doc.sh
```

## to install

> don't use to develop

```bash
v install https://github.com/freeflowuniverse/crystallib
```
