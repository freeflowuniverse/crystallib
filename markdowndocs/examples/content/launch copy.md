# this is a test

Its our attempt to use markdown to execute a certain state.

It allows us to specify parser which need to be done, only !! at start of line is executed.

```yaml
yes = 1
```

"""yaml
yes = 2
"""

comments allowed, the next thing is not useful but good for testing, it specifies name argument on git.ensure, its the same anyhow

!!action.define name:download_git
!!git.ensure url:'https://github.com/threefoldfoundation/info_foundation' autocommit:'mychanges' update:true
!!git.ensure url:https://github.com/threefoldfoundation/legal autocommit:'mychanges' update:true  
  name:legal

> can be multiline

!!git.ensure url:https://github.com/threefoldfoundation/info_gridmanual 
    autocommit:'mychanges'
    update:true

<!-- comments should not stop -->

!!publisher.server.params port:8082

!!action.define name:server_start depends:download_git,get_content

!!publisher.server.start

!!action.run name:server_start

can be in code block or without, it does not matter

## git

<!-- Means a git command, 

### git ensure

makes sure a git repo is on system. -->


## action does not have to be in code block

!!action.define2 name:get_content

> if we don't specify source of content, then its the document itself

!!markdown.section.get1 start:'### git ensure' name:testcontent.blue

> we now remove the first line which matched, the last line is never included, but now we forced to include it + 1 extra line

!!markdown.section.get2 start:'### git ensure' end:'# end of' name:testcontent.red trim_end:+3 trim_start:+1

> fetch a full document, there will be no start/stop

!!markdown.section.get3 name:testcontent.pink gitrepo:info_foundation 
    file:'communication.md'

### end of block

This should be in the found block.

### we can even do task management with it


!!taskcontext name:myproject1

!!task id:a1 
  name:'need to do something 1'
  description:
    ## markdown works in it
  
    description can be multiline
    lets see what happens
  
    - a
    - something else
  
    ### subtitle
  
    ```python
    #even code block in the other block, crazy parsing for sure
    def test():
      print("test")
    ```
  priority:10


//lets now create another task which depends on the previous one

!!task id:a1 name:'something else' assign:'kristof(50%),jan' effort:1d 
    depends:a1  

!!dao.deposit currency:usdc amount:10
!!dao.withdraw currency:usdc amount:10

!!dao.pool.deposit currency:usdc amount:10
!!dao.pool.withdraw currency:usdc amount:10

!!dao.pool.buy  currency:tft amount:100

!!dao.wallets.info currency:usdc 
!!dao.wallets.info 

!!dao.exchange.buy currency:tft amount:100 price_max_usd:0.05 deadline:10h

