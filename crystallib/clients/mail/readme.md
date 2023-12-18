# mail client

## use hero to configure

```markdown

hero configure mail

## Configure Mail Client
========================

name for mail client (default is 'default')':
smtp login: ttt@incubaid.com
mail_from e.g. myname@domain.com: ttt@incubaid.com
smtp addr e.g. smtp-relay.brevo.com: smtp-relay.brevo.com
smtp passwd: ....
smtp port (default 587):
ssl, means encrypted (y/n) : y

```

## configure

the mail configuration is stored on the filesystem for further use, can be configured as follows

```v
import freeflowuniverse.crystallib.clients.mail

mail.configure(name:'default',
            mail_from:'something@something'
        	smtp_addr:'smtp-relay.brevo.com'
        	smtp_login:'something@something'
        	smpt_port:587
        	smtp_passwd:'ssss')!
```

## configure through 3script

```v
import freeflowuniverse.crystallib.clients.mail

script3:='
!!mailclient.define name:'default'
	mail_from:'something@something'
	smtp_addr:'smtp-relay.brevo.com'
	smtp_login:'something@something'
	smpt_port:587
	smtp_passwd:'ssss'
'


mail.configure(script3:script3)!


//can also be done through get directly
mut cl:=mail.get(reset:true,name:'default',script3:script3)

```


## send mail

```v
import freeflowuniverse.crystallib.clients.mail

mut cl:=mail.get()! //will default get mail client with name 'default'

cl.send(subject:'this is a test',to:'kds@something.com,kds2@else.com',content:'
    this is my email content
    
    ')

```

## brevo remark

- use ssl
- use port: 465