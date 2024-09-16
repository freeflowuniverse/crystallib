# mailclient



To get started

```vlang

import freeflowuniverse.crystallib.clients. mailclient

mut client:= mailclient.get()!

client.send(subject:'this is a test',to:'kds@something.com,kds2@else.com',body:'
    this is my email content
    ')!

```

## example heroscript

```hero
!!mailclient.configure
    secret: '...'
    host: 'localhost'
    port: 8888
```

## use of env variables

if you have a secrets file you could import as

```bash
//e.g.  source ~/code/git.ourworld.tf/despiegk/hero_secrets/mysecrets.sh
```

following env variables are supported

- MAIL_FROM=
- MAIL_PASSWORD=
- MAIL_PORT=465
- MAIL_SERVER=smtp-relay.brevo.com
- MAIL_USERNAME=kristof@incubaid.com

these variables will only be set at configure time


## brevo remark

- use ssl
- use port: 465