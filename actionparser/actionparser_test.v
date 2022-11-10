module actionparser

fn test_read() {
	res := parse('actionparser/launch.md') or { panic('cannot parse,$err') }

	res2 := ParseResult{
		actions: [
			ParseAction{
				name: 'action.define'
				params: [
					ParseParam{
						name: 'name'
						value: 'download_git'
					},
				]
			},
			ParseAction{
				name: 'git.ensure'
				params: [
					ParseParam{
						name: 'url'
						value: 'https://github.com/threefoldfoundation/info_foundation'
					},
					ParseParam{
						name: 'autocommit'
						value: 'mychanges'
					},
					ParseParam{
						name: 'update'
						value: 'true'
					},
				]
			},
			ParseAction{
				name: 'git.ensure'
				params: [
					ParseParam{
						name: 'url'
						value: 'https://github.com/threefoldfoundation/legal'
					},
					ParseParam{
						name: 'autocommit'
						value: 'mychanges'
					},
					ParseParam{
						name: 'update'
						value: 'true'
					},
					ParseParam{
						name: 'name'
						value: 'legal'
					},
				]
			},
			ParseAction{
				name: 'git.ensure'
				params: [
					ParseParam{
						name: 'url'
						value: 'https://github.com/threefoldfoundation/info_gridmanual'
					},
					ParseParam{
						name: 'autocommit'
						value: 'mychanges'
					},
					ParseParam{
						name: 'update'
						value: 'true'
					},
				]
			},
			ParseAction{
				name: 'publisher.server.params'
				params: [
					ParseParam{
						name: 'port'
						value: '8082'
					},
				]
			},
			ParseAction{
				name: 'action.define'
				params: [
					ParseParam{
						name: 'name'
						value: 'server_start'
					},
					ParseParam{
						name: 'depends'
						value: 'download_git,get_content'
					},
				]
			},
			ParseAction{
				name: 'publisher.server.start'
				params: []
			},
			ParseAction{
				name: 'action.run'
				params: [
					ParseParam{
						name: 'name'
						value: 'server_start'
					},
				]
			},
			ParseAction{
				name: 'action.define'
				params: [
					ParseParam{
						name: 'name'
						value: 'get_content'
					},
				]
			},
			ParseAction{
				name: 'markdown.section.get'
				params: [
					ParseParam{
						name: 'start'
						value: '### git ensure'
					},
					ParseParam{
						name: 'name'
						value: 'testcontent.blue'
					},
				]
			},
			ParseAction{
				name: 'markdown.section.get'
				params: [
					ParseParam{
						name: 'start'
						value: '### git ensure'
					},
					ParseParam{
						name: 'end'
						value: '# end of'
					},
					ParseParam{
						name: 'name'
						value: 'testcontent.red'
					},
					ParseParam{
						name: 'trim_end'
						value: '+3'
					},
					ParseParam{
						name: 'trim_start'
						value: '+1'
					},
				]
			},
			ParseAction{
				name: 'markdown.section.get'
				params: [
					ParseParam{
						name: 'name'
						value: 'testcontent.pink'
					},
					ParseParam{
						name: 'gitrepo'
						value: 'info_foundation'
					},
					ParseParam{
						name: 'file'
						value: 'communication.md'
					},
				]
			},
			ParseAction{
				name: 'taskcontext'
				params: [
					ParseParam{
						name: 'name'
						value: 'myproject1'
					},
				]
			},
			ParseAction{
				name: 'task'
				params: [
					ParseParam{
						name: 'id'
						value: 'a1'
					},
					ParseParam{
						name: 'name'
						value: 'need to do something 1'
					},
					ParseParam{
						name: 'description'
						value: '## markdown works in it

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
priority:10'
					},
				]
			},
			ParseAction{
				name: 'task'
				params: [
					ParseParam{
						name: 'id'
						value: 'a1'
					},
					ParseParam{
						name: 'name'
						value: 'something else'
					},
					ParseParam{
						name: 'assign'
						value: 'kristof(50%),jan'
					},
					ParseParam{
						name: 'effort'
						value: '1d'
					},
					ParseParam{
						name: 'depends'
						value: 'a1'
					},
				]
			},
			ParseAction{
				name: 'task'
				params: [
					ParseParam{
						name: 'id'
						value: 'b3'
					},
					ParseParam{
						name: 'name'
						value: 'do1'
					},
				]
			},
			ParseAction{
				name: 'task'
				params: [
					ParseParam{
						name: 'id'
						value: 'b4'
					},
					ParseParam{
						name: 'name'
						value: 'do1'
					},
				]
			},
		]
	}

	assert res == res2

	// panic('sss')
}
