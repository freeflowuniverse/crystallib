# Action files

heroscript is normally put in a markdown file.

### Example 

the following statements are for DAL actions.

```js

!user.define
	id: '1ge'  
	name: fatayera 
	firstname: 'Adnan'
	lastname: 'Fatayerji'
	description: 'Head of Business Development'

!contact:define
    user:'1ge'
	email: 'adnan@threefold.io,fatayera@threefold.io'

!circle.define
    id:'***'
	name:tftech_coordination


!circle_role.define
    id:'***' //means will be filled in automatically
    name:'vpsales'      
	circle:'tftech' //can be id of circle or name
	role:'stakeholder' 
	description:''
	

!comment.define id:'1ge' 
	comment:
		this is a comment
		can be multiline
    author:'despiegk' //is optional


```
