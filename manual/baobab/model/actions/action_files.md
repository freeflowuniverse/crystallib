# Action files

Actions should be added in a markdown file by the user. Below you can find an example of such file. The baobab package contains the necessary logic to parse these files and return the actions.

```js
//select the book, can come from context as has been set before
//now every person added will be added in this book
!!select_domain protocol_me
!!select_book aaa
!!select_actor people

//delete everything as found in current book
!!people.person_delete cid:1g

!!people.person_define
	//is optional will be filled in automatically, but maybe we want to update
	cid: '1g' 
	//name as selected in this group, can be used to find someone back
	name: fatayera 
	firstname: 'Adnan'
	lastname: 'Fatayerji'
	description: 'Head of Business Development'
	email: 'adnan@threefold.io,fatayera@threefold.io'

!!people.circle_link
	//can define as cid or as name
	circle:tftech         
	role:'stakeholder'
	description:''
	//is the name as given to the link
	name:'vpsales'        

!!people.circle_comment cid:'1g' 
	comment:
		this is a comment
		can be multiline 

!!people.digital_payment_add
	person:fatayera
	name: 'TF Wallet'
	blockchain: 'stellar'
	account: ''
	description: 'TF Wallet for TFT' 
	preferred: false
	time_slot: 5:21AM
	total_size: 50GB
```
