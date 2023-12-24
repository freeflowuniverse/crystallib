## sourcetree

```v
import freeflowuniverse.crystallib.osal.sourcetree

//will look for git in location if not found will give error
sourcetree.open(path:"/tmp/something")!

```

- if path not specified will chose current path