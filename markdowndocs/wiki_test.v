module markdowndocs


fn test_wiki_headers_paragraphs() {
	content := 
'
# TMUX

tmux library provides functions for managing local / remote tmux sessions

## Getting started

To initialize tmux on a local or [remote node](mysite:page.md), simply build the [node](defs:node.md), install tmux, and run start

- test1
- test 2
	- yes
	- no

### something else

'
	mut docs := new(content:content)!

	assert docs.items.len == 5
	assert docs.items[0] is Header
	assert docs.items[1] is Paragraph
	paragraph1 := docs.items[1] as Paragraph
	assert paragraph1.items.len == 1
	assert paragraph1.items[0] is Text
	assert docs.items[2] is Header
	assert docs.items[3] is Paragraph
	paragraph2 := docs.items[3] as Paragraph
	assert paragraph2.items.len == 5
	assert paragraph2.items[0] is Text
	assert paragraph2.items[1] is Link
	assert paragraph2.items[2] is Text
	assert paragraph2.items[3] is Link
	assert paragraph2.items[4] is Text
	assert docs.items[4] is Header
	assert content.trim_space() == docs.wiki().trim_space()
}

fn test_wiki_code() {
	content := 
'
# This is some code

```v
for x in list {
	println(x)
}
```

# This is an action in a piece of code

```
!!farmerbot.nodemanager.define
	id:15
	twinid:20
	has_public_ip:yes
	has_public_config:1
```
'
	mut docs := new(content:content)!

	assert docs.items.len == 4
	assert docs.items[0] is Header
	assert docs.items[1] is CodeBlock
	codeblock1 := docs.items[1] as CodeBlock
	assert codeblock1.category == "v"
	assert docs.items[2] is Header
	assert docs.items[3] is CodeBlock
	codeblock2 := docs.items[3] as CodeBlock
	assert content.trim_space() == docs.wiki().trim_space()
}


fn test_wiki_links() {
	content := 
'
# this is a test

- [this is link](something.md)
- ![this is link2](something.jpg)

## ts

![this is link2](something.jpg)
'
	mut docs := new(content: content)!

	assert docs.items.len == 4
	assert docs.items[0] is Header
	assert docs.items[1] is Paragraph
	paragraph1 := docs.items[1] as Paragraph
	assert paragraph1.items.len == 4
	assert paragraph1.items[0] is Text
	assert paragraph1.items[1] is Link
	assert paragraph1.items[2] is Text
	assert paragraph1.items[3] is Link
	assert docs.items[2] is Header
	assert docs.items[3] is Paragraph
	paragraph2 := docs.items[3] as Paragraph
	assert paragraph2.items.len == 1
	assert paragraph2.items[0] is Link
	assert content.trim_space() == docs.wiki().trim_space()
}

fn test_wiki_header_too_long() {
	content := 
'
##### Is ok

###### Should not be ok
'
	mut docs := new(content: content)!
	
	expected_wiki := 
'
##### Is ok
'
	assert expected_wiki.trim_space() == docs.wiki().trim_space()
}

fn test_wiki_all_together() {
	content := 
'
# Farmerbot

Welcome to the farmerbot. The farmerbot is a service that a farmer can run allowing him to automatically manage the nodes of his farm.

The key feature of the farmerbot is powermanagement. The farmerbot will automatically shutdown nodes from its farm whenever possible and bring them back on when they are needed using Wake-on-Lan (WOL). It will try to maximize downtime as much as possible by recommending which nodes to use, this is one of the requests that the farmerbot can handle (asking for a node to deploy on).

The behavior of the farmerbot is customizable through markup definition files. You can find an example [here](example_data/nodes.md).

## Under the hood

The farmerbot has been implemented using the actor model principles. It contains two actors that are able to execute jobs (actions that need to be executed by a specific actor).

The first actor is the nodemanager which is in charge of executing jobs related to nodes (e.g. finding a suitable node). The second actor is the powermanager which allows us to power on and off nodes in the farm.

Actors can schedule the execution of jobs for other actors which might or might not be running on the same system. For example, the nodemanager might schedule the execution of a job to power on a node (which is meant for the powermanager). The repository [baobab](https://github.com/freeflowuniverse/baobab) contains the logic for scheduling jobs.

Jobs don\'t have to originate from the system running the farmerbot. It may as well be scheduled from another system (with another twin id). The job to find a suitable node for example will come from the TSClient (which is located on another system). These jobs will be send from the TSClient to the farmerbot via [RMB](https://github.com/threefoldtech/rmb-rs).

## Configuration

As mentioned before the farmerbot can be configured through markup definition files. This section will guide you through the possibilities.

### Nodes

The farmerbot requires you to setup the nodes that the farmerbot should handle.
Required attributes:
- id
- twinid

Optional attributes:
- cpuoverprovision => a value between 1 and 4 defining how much the cpu can be overprovisioned (2 means double the amount of cpus)
- public_config => true or false telling the farmerbot whether or not the node has a public config
- dedicated => true or false telling the farmerbot whether or not the node is dedicated (only allow renting the full node)
- certified => true or false telling the farmerbot whether or not the node is certified

Example:

```
!!farmerbot.nodemanager.define
	id:20
	twinid:105
	public_config:true
	dedicated:1
	certified:yes
	cpuoverprovision:1
```
'
	mut docs := new(content:content)!

	assert content.trim_space() == docs.wiki().trim_space()
}