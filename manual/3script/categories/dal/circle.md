
# Users & Contacts

```js
!circle.define id:'***' name:acircle 
	description: ''
    alias:'' //list of possible aliases
    tags:

!member.define id:'***' circle:'acircle' user:'rabbit'
    role:'coordinator' //coordinator,admin,stakeholder,member,contributor,follower




!circle_right.define id:'***' circle:'acircle' 
    acl:'
    !member.* despiegk //means despiegk can do all actions on member
    !member.* auser
    '

```

!!include model_defaults