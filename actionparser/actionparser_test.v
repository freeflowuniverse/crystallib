module actionparser

fn test_read() {

    actions.init()

	res := actions.add('actionparser/launch.md') or { panic('cannot parse,$err') }

	res2 := Actions{
    actions: [Action{
        name: 'action.define'
        params: [Param{
            name: 'name'
            value: 'download_git'
        }]
    }, Action{
        name: 'git.ensure'
        params: [Param{
            name: 'url'
            value: 'https://github.com/threefoldfoundation/info_foundation'
        }, Param{
            name: 'autocommit'
            value: 'mychanges'
        }, Param{
            name: 'update'
            value: 'true'
        }]
    }, Action{
        name: 'git.ensure'
        params: [Param{
            name: 'url'
            value: 'https://github.com/threefoldfoundation/legal'
        }, Param{
            name: 'autocommit'
            value: 'mychanges'
        }, Param{
            name: 'update'
            value: 'true'
        }, Param{
            name: 'name'
            value: 'legal'
        }]
    }, Action{
        name: 'git.ensure'
        params: [Param{
            name: 'url'
            value: 'https://github.com/threefoldfoundation/info_gridmanual'
        }, Param{
            name: 'autocommit'
            value: 'mychanges'
        }, Param{
            name: 'update'
            value: 'true'
        }]
    }, Action{
        name: 'publisher.server.params'
        params: [Param{
            name: 'port'
            value: '8082'
        }]
    }, Action{
        name: 'action.define'
        params: [Param{
            name: 'name'
            value: 'server_start'
        }, Param{
            name: 'depends'
            value: 'download_git,get_content'
        }]
    }, Action{
        name: 'publisher.server.start'
        params: []
    }, Action{
        name: 'action.run'
        params: [Param{
            name: 'name'
            value: 'server_start'
        }]
    }, Action{
        name: 'action.define'
        params: [Param{
            name: 'name'
            value: 'get_content'
        }]
    }, Action{
        name: 'markdown.section.get'
        params: [Param{
            name: 'start'
            value: '### git ensure'
        }, Param{
            name: 'name'
            value: 'testcontent.blue'
        }]
    }, Action{
        name: 'markdown.section.get'
        params: [Param{
            name: 'start'
            value: '### git ensure'
        }, Param{
            name: 'end'
            value: '# end of'
        }, Param{
            name: 'name'
            value: 'testcontent.red'
        }, Param{
            name: 'trim_end'
            value: '+3'
        }, Param{
            name: 'trim_start'
            value: '+1'
        }]
    }, Action{
        name: 'markdown.section.get'
        params: [Param{
            name: 'name'
            value: 'testcontent.pink'
        }, Param{
            name: 'gitrepo'
            value: 'info_foundation'
        }, Param{
            name: 'file'
            value: 'communication.md'
        }]
    }, Action{
        name: 'taskcontext'
        params: [Param{
            name: 'name'
            value: 'myproject1'
        }]
    }, Action{
        name: 'task'
        params: [Param{
            name: 'id'
            value: 'a1'
        }, Param{
            name: 'name'
            value: 'need to do something 1'
        }, Param{
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
        }]
    }, Action{
        name: 'task'
        params: [Param{
            name: 'id'
            value: 'a1'
        }, Param{
            name: 'name'
            value: 'something else'
        }, Param{
            name: 'assign'
            value: 'kristof(50%),jan'
        }, Param{
            name: 'effort'
            value: '1d'
        }, Param{
            name: 'depends'
            value: 'a1'
        }]
    }, Action{
        name: 'task'
        params: [Param{
            name: 'id'
            value: 'b3'
        }, Param{
            name: 'name'
            value: 'do1'
        }]
    }, Action{
        name: 'task'
        params: [Param{
            name: 'id'
            value: 'b4'
        }, Param{
            name: 'name'
            value: 'do1'
        }]
    }]
	}

	assert res == res2

	// panic('sss')
}
