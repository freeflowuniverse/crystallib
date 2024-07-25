# nerdctl

is a nice tool to manage containers, following scripts show how to use, needs to be ported to crystal

> the scripts and examples only for for OSX right now

## lima

to install see install.sh

```bash
limactl list
#check how many cpu's if not enough change ~/Users/despiegk1~/.lima/default/lima.yaml
#change cpu's to nr of cores you have

#to go in vm which is running the containers
limactl shell default

```

## to login over ssh

```bash
#5 is for posgresql
ssh -p 5022 root@127.0.0.1 -A 
#7 is for crystal
ssh -p 7022 root@127.0.0.1 -A 
```



if ssh-auth not done

```bash
sshpass -p 'admin' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 7022 root@127.0.0.1 -A
```


## to use ssh connection in visual studio code do

use command for ssh connection and use following string

```bash
ssh -p 7022 root@127.0.0.1 -A
```

## to log output of postgresql

```bash
#over ssh get the main log, useful for debugging of e.g. psql scripts
ssh -p 5022 root@127.0.0.1 -A  'tail /var/log/postgresql/postgresql-16-main.log  -f'
```

## to get v-analyzer

```bash
v -e "$(curl -fsSL https://raw.githubusercontent.com/vlang/v-analyzer/main/install.vsh)"
```