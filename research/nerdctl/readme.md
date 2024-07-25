# nerdctl

is a nice tool to manage containers, following scripts show how to use, needs to be ported to crystal

## to login over ssh

```bash
sshpass -p 'admin' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 7022 root@127.0.0.1 -A
```

the 7 of 7022 is the nr as used for the container creation

## to use ssh connection in visual studio code do

use command for ssh connection and use following string

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 7022 root@127.0.0.1 -A
````