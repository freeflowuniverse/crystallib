# rights

- admin or coordinators have all rights by default
- stakeholders, member have view rights for all
- contributor,followor have view rights for stories,tasks,milestones,issues, ...
- public: is non registered user, if a circle is public a additional set of rights will be added specific for public users.

When a circle is established a rights.md file is created if it doesn't exist yet, this has all the default rights inside.


```js
//the following allows some teams and user rabbit to call wal actions starting with machine, can also do all on member root object, might be dangerous but is example
//no rights on sal's
!right.define id:'***' 
    range_allow:'
    !!!machine.*
    !member.* 
    '
    teams:'ateam,anotherteam'
    users:'rabbit'
    roles:'stakeholder,member'

```

```js
//rabbit becomes an absolute super hero
//access to all wal, dal and sal
!right.define id:'***' 
    range_allow:'
    !!!*
    !!*
    !*
    '
    range:'rabbit'
```

can also write as

```js
//rabbit becomes an absolute super hero
//access to all wal, dal and sal
//but for whatever weird reason cannot do anything with model for members.
!right.define id:'***' users:'rabbit'
    range_allow:'!!!*,!!*,!*'
    range_deny:'!member.*'
```

## default rights

> TODO: need to define the default rights

The default is deny all.

```js
!right.define id:'***' roles:'stakeholders,members'
    range_allow:'!*.define'

!right.define id:'***' roles:'contributors,followers'
    range_allow:'
            !task.define,!task.get,!task.list
            !issue.define,!issue.get,!issue.list
            !
            '


```

## public rights

Added when circle is public


```js
//TODO: 


```