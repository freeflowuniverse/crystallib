# holochain


in the vm we have

- codeserver
- ssh
- mycelium
- hero calls back home: 

## todo

```bash
export TFGRID_MNEMONIC="jelly fork  ..."
```

## principle

- tfrobot will deploy 10 VM
- each vm will start sshserver and a call backhome
- call back home is message over mycelium to the originator
    - download/install hero as part of the init or hero in flist
    - 'hero callhome $comma_separate_ipv6_list_mycelium'
    - the hero call home will keep on trying untill it got confirmation that it was received (for 24 h) 
    - in other words sends alive message to the TFRobot node who deployed the VM
    - TFRobot node runs vscript to do deploy, this vscript in loop keeps on showing progress of deploy as well as polling over mycelium if the alive message arrived
- have pre-installed https://github.com/coder/code-server
- 
## requirements

- tfrobot
- installed mycelium
  

## ideas for later

- integrate with https://dagu.readthedocs.io/en/latest/web_interface.html