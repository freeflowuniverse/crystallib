module actionsparser

import os

const text='
//select the book, can come from context as has been set before
//now every person added will be added in this book
!!actor.select aaa.people

//delete everything as found in current book
!!person_delete cid:1g

!!person_define
  //is optional will be filled in automatically, but maybe we want to update
  cid: '1gt' 
  //name as selected in this group, can be used to find someone back
  name: fatayera
	firstname: 'Adnan'
	lastname: 'Fatayerji'
	description: 'Head of Business Development'
  email: 'adnan@threefold.io,fatayera@threefold.io'

!!circle_link
//can define as cid or as name, name needs to be in same book
  person: '1gt'
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

!!circle_comment cid:'1g' 
    comment:
      another comment

!!digital_payment_add 
  person:fatayera
	name: 'TF Wallet'
	blockchain: 'stellar'
	account: ''
	description: 'TF Wallet for TFT' 
	preferred: false

!!actor.select bbb.people

!!person_define
  cid: 'eg'
  name: despiegk

!!book.select bbb
'

fn test_filter() {
	actions := new(
		text: text
		filter: ['circle_delete', 'person_delete', 'circle_define', 'person_define', 'circle_link',
			'circle_comment', 'digital_payment_add']
		actor: 'people'
		book: 'aaa'
	)!	

}

