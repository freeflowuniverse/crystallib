
# Crystallib

Is an opinionated library as used by threefold mainly to automate cloud environments, its still very much work in progress and we welcome any contribution.

Please check also our [cookbook](https://github.com/freeflowuniverse/crystallib/tree/development/cookbook) which might give some ideas how to use it.

## Get started with hero

```bash
curl -sL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer_hero.sh | bash
```

## Get started with crystallib

the following script will install vlang and crystallib (report bugs please)

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh
bash /tmp/install.sh
```

optional requirements

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

## Install Hero

hero is our "hero" tool to execute heroscript, deal with git, ...

hero will be installed in

- /usr/local/bin for linux
- ~/hero/bin for osx

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer_hero.sh > /tmp/hero_install.sh
bash /tmp/hero_install.sh
#to debug
bash -x /tmp/hero_install.sh
#maybe you want to copy to your system bin dir
cp ~/hero/bin/hero /usr/local/bin
#to use hero make sure you restart your shell or you do (if osx)
source ~/.zprofile 
#check how to use, can also do on each of the subcommands
hero -help
```

requirements

- ssh key loaded for access to github

## generating docs yourself

```bash
#cd in this directory
cd ~/code/github/freeflowuniverse/crystallib
bash doc.sh
```
