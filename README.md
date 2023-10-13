

## Get started with crystallib

the following script will install vlang and crystallib

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/v_install.sh > /tmp/install.sh
bash /tmp/install.sh
```

requirements

- ssh key loaded for access to github

### alternative with manual git checkout & v install

requirements

- v installed
- ssh key loaded for access to github

```bash
mkdir -p ~/code/github/freeflowuniverse
cd ~/code/github/freeflowuniverse
git clone git@github.com:freeflowuniverse/crystallib.git
cd crystallib
# checkout a branch with most recent changes
# git checkout development 
bash install.sh

```

## manual

> todo: there is some content underneath manual, but we are in process to use hero to generate mdbook. Stay tuned.


## generating docs

```bash
#cd in this directory
cd ~/code/github/freeflowuniverse/crystallib
bash doc.sh
```


## Install Hero

hero is our "hero" tool to execute 3script, deal with git, ...

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/hero_install.sh > /tmp/hero_install.sh
bash /tmp/hero_install.sh
```

requirements

- ssh key loaded for access to github

#### to compile

```bash
bash ~/code/github/freeflowuniverse/crystallib/cli/hero/compile.sh
```

## test your code before checking in

```bash
cd ~/code/github/freeflowuniverse/crystallib
bash test.sh
```

- use `v test crystallib/core/pathlib` to run tests of one module
