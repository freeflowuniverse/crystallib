
# Crystallib  / Hero

## Install Hero

hero is our "hero" tool to execute heroscript, deal with git, ...

hero will be installed in

- /usr/local/bin for linux
- ~/hero/bin for osx

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/install_hero.sh > /tmp/hero_install.sh
bash /tmp/hero_install.sh
#to debug
bash -x /tmp/hero_install.sh
#to use hero make sure you restart your shell or you do (if osx)
source ~/.zprofile 
#check how to use, can also do on each of the subcommands
hero -help
```

## Get started with crystallib

the following script will install vlang and crystallib

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh
bash /tmp/install.sh

#with hero (will compile hero as well)
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/build_hero.sh > /tmp/build_hero.sh
bash /tmp/build_hero.sh
```

requirements

- ssh key loaded for access to github


## Example how to install remotely

There are some nice helper scripts which show you how to work remotely

- see [scripts/remote_hero_debug.vsh](scripts/remote_hero_debug.vsh)
- see [scripts/remote_install_v_hero.vsh](scripts/remote_install_v_hero.vsh)
- see [scripts/remote_update_compile_hero.vsh](scripts/remote_update_compile_hero.vsh)

```bash
export SERVER=65.21.132.119
#next till do the install, you need v & crystal installed locally
#this works on empty machine
~/code/github/freeflowuniverse/crystallib/scripts/remote_hero_debug.vsh

```


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

The v documentation is on [https://freeflowuniverse.github.io/crystallib](https://freeflowuniverse.github.io/crystallib)

> todo: there is some content underneath manual, but we are in process to use hero to generate mdbook. Stay tuned.


## generating docs

```bash
#cd in this directory
cd ~/code/github/freeflowuniverse/crystallib
bash doc.sh
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
