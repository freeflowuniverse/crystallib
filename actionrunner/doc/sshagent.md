# sshagent

## sshagent.stop

- unload the sshagent and make sure there are no keys loaded

## sshagent.key.load

- will remember the key
- params
    - name = name to use to remember if more than 1 key (optional)
    - sshkey or key = the string representation of ssh public key
    - reset (bool, optional): if used will make sure only this sshkey is loaded in the agent
