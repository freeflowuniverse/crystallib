## ssh agent

```v
import freeflowuniverse.crystallib.osal.sshagent

mut agent := sshagent.new()!

privkey:='
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACDXf9Z/2AH8/8a1ppagCplQdhWyQ8wZAieUw3nNcxsDiQAAAIhb3ybRW98m
0QAAAAtzc2gtZWQyNTUxOQAAACDXf9Z/2AH8/8a1ppagCplQdhWyQ8wZAieUw3nNcxsDiQ
AAAEC+fcDBPqdJHlJOQJ2zXhU2FztKAIl3TmWkaGCPnyts49d/1n/YAfz/xrWmlqAKmVB2
FbJDzBkCJ5TDec1zGwOJAAAABWJvb2tz
-----END OPENSSH PRIVATE KEY-----
'

mut sshkey:=agent.add("mykey:,privkey)!


sshkey.forget()!

```

### hero

there is also a hero command

```js
//will add the key and load (at this stage no support for passphrases)
!!sshagent.key_add name:'myname'
    privkey:'
        -----BEGIN OPENSSH PRIVATE KEY-----
        b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
        QyNTUxOQAAACDXf9Z/2AH8/8a1ppagCplQdhWyQ8wZAieUw3nNcxsDiQAAAIhb3ybRW98m
        0QAAAAtzc2gtZWQysdsdsddsdsdsdsdsdsd8/8a1ppagCplQdhWyQ8wZAieUw3nNcxsDiQ
        AAAEC+fcDBPqdJHlJOQJ2zXhU2FztKAIl3TmWkaGCPnyts49d/1n/YAfz/xrWmlqAKmVB2
        FbJDzBkCJ5TDec1zGwOJAAAABWJvb2tz
        -----END OPENSSH PRIVATE KEY-----
        '

```

