# Project Management

How to deal with milestones, stories, tasks

```js
!project.define
	id:'***'
    name:''
	title:'myproject'
	description: '...'
    deadline:''//in ourtime format
    state:'' //new,active,blocked,done,verified

!team.define
	id:'***'
    name:''
	title:'support team in india'
	description: '...'
    members: '' //id's users who are part of team

!story.define
	id:'***'
    name:'' //optional
    project:'' //id or name of project (can define part of title, will also match)
	title:'color_ui'
	description: '...'
    priority:'' //normal,urgent,low
    deadline: //can be defined as +10d as well, get replaced to date when first run
    effort_remaining:''  //in hours
    percent_done:'10%' //or 5 without %
    owner:'' //list of users (name or id based), comma separated
    assignment:'' //list of users (name or id based) or teams, comma separated
    state:'' //new,active,blocked,done,verified
    epics:'' //one or more epics this story links too
    costcenter:'' //one or more costcenters

!task.define
	id:'***'
    story:'' //id or name of story (can define part of title, will also match)
	title:'mytask'
	description: '...'
    priority:'' //normal,urgent,low
    assignment:'' //list of users (name or id based) or teams, comma separated
    deadline: //can be defined as +10d as well
    effort_remaining:''  //in hours
    percent_done:'10%' //or 5 without %
    state:'' //new,active,blocked,done,verified
    costcenter:'' //one or more costcenters

!requirement.define
	id:'***'
    story:'' //id of story (can define part of title, will also match)
	title:'mytask'
	description: '...'
    assignment:'' //list of users (name or id based) or teams, comma separated
    priority:'' //normal,urgent,low
    state:'' //unknown,metonce,metmulti : multi means we have checked multiple times and we're ok

!issue.define
	id:'***'
	title:'server X is down'
    type:'' //event,bug,question,remark,task
	description: '...'
    priority:'' //normal,urgent,low
    deadline: //can be defined as +10d as well
    assignment:'' //list of users (name or id based) or teams, comma separated
    effort_remaining:''  //in hours
    percent_done:'10%' //or 5 without %
    state:'' //new,active,blocked,done,verified
    costcenter:'' //one or more costcenters

!track.define //track effort done on issue, story, requirement or task (can be multiple at once)
    issue: //one or more issues
    story: //one or more stories
    requirement: //one or more requirements
    task: //one or more tasks
    time: //default in minutes, an also do e.g. 1h
    description: '' //what was done

!costcenter.define
	id:'***'
    name:'' //optional
	title:''
    description: '' //describe what cost center is about

```

## priority management

are high level constructs which allow organizations to discuss their priorities

```js
!epic.define
	id:'***'
	name:'grid in production' 
	description: '...'
    deadline:''//in ourtime format

!condition.define //necessary condition
	id:'***'
	title:'mytask'
	description: '...'
    assignment:'' //list of users (name or id based) or teams, comma separated, need to verify condition
    priority:'' //normal,urgent,low
    state:'' //unknown,metonce,metmulti : multi means we have checked multiple times and we're ok


```


!!include model_defaults