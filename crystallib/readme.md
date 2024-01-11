
# Crystallib

Is an opinionated library as used by threefold mainly to automate cloud environments, its still very much work in progress and we welcome any contribution.

## Get started with crystallib

the following script will install vlang and crystallib

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

## generating docs yourself

```bash
#cd in this directory
cd ~/code/github/freeflowuniverse/crystallib
bash doc.sh
```
