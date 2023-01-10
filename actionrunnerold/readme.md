# action runner

is the top level class which executes on all actions over the multiple known modules.

## Example

to run the example,

run `v -cg run runner.v run_git.md` in /example

the filesystem will be created in the example directory, and the actions for the runner will be parsed from run_git.md

## ActionJob

Represents the job for running an action.

### Action Job State

An actionjob can have one of the following states:

- init
- tostart
- recurring
- scheduled
- active
- done
- error

Except for recurring jobs, a job's statefile can only exist in one of these folders, and thus is moved between them in the filesystem.

### Action Job Events

An actionjob event is something the triggers a change in an actionjob's state.

An actionjob can emit one of the following events:

- schedule: moves state from tostart/recurring to scheduled
- running: moves state from scheduled to active
- ok: moves state from active to done
- error: moves state from active to error
- restart: moves state from active to tostart

### State Folder (FS Database)

The state folder is used like a database to save the jobs' state.
The state is only saved subsequent to an event, as that is the only time state changes.
