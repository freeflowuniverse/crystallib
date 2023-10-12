module publisher

import freeflowuniverse.crystallib.baobab.actions as actionslib { ActionsArgs }
import freeflowuniverse.crystallib.data.params as paramslib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdowndocs
import freeflowuniverse.crystallib.data.knowledgetree

__global (
	actor_factory map[string]&PublisherActor
)

[noinit]
struct PublisherActor {
mut:
	knowledgetree shared knowledgetree.Tree
	books         shared map[string]&knowledgetree.MDBook
}

// PlayConfig. If actions are provided runs actions. Otherwise loads and runs actions in path.
pub struct Play {
	ActionsArgs
	actions []actionslib.Action
}

pub fn play(params Play) ! {
	actions := if params.actions.len > 0 {
		ap := actionslib.Actions{
			actions: params.actions
		}
		ap.filtersort(actor: 'knowledgetree')!
	} else {
		ap := actionslib.new(params.ActionsArgs)!
		ap.filtersort(actor: 'knowledgetree')!
	}

	for action in actions {
		if action.circle !in actor_factory {
			actor_factory[action.circle] = &PublisherActor{
				knowledgetree: knowledgetree.new()!
			}
		}
		actor_factory[action.circle].act(action)!
	}
}

// act handles incoming action and matches to corresponding method
pub fn (mut actor PublisherActor) act(action actionslib.Action) ! {
	match action.name {
		'collections_scan' {
			actor.collections_scan(action)!
		}
		'book_generate' {
			actor.book_generate(action)!
		}
		'book_open' {
			actor.book_open(action)!
		}
		else {
			return error('action name ${action.name} not supported')
		}
	}
}

// collections_scan scans a path for collections and adds the collections to actor's knowledgetree
fn (mut actor PublisherActor) collections_scan(action actionslib.Action) ! {
	git_url := action.params.get('git_url')!
	git_root := action.params.get('git_root')!
	lock actor.knowledgetree {
		actor.knowledgetree.scan(
			git_url: git_url
			git_root: git_root
			heal: true
		)!
	}
}

// book_generate generates an mdbook using the actor's knowledgetree and provided params
fn (mut actor PublisherActor) book_generate(action actionslib.Action) ! {
	mut tree := knowledgetree.Tree{}
	rlock actor.knowledgetree {
		tree = actor.knowledgetree
	}
	lock actor.books {
		name := action.params.get('name')!
		if name in actor.books {
			return error('Book with name ${name} exists')
		}
		actor.books[name] = knowledgetree.book_generate(
			name: action.params.get('name')!
			tree: tree
			path: action.params.get_default('path', '')!
			git_url: action.params.get_default('git_url', '')!
			git_reset: action.params.get_default_false('git_reset')
			git_root: action.params.get_default('git_root', '')!
			git_pull: action.params.get_default_false('git_pull')
			dest: action.params.get_default('dest', '')!
			dest_md: action.params.get_default('dest_md', '')!
		)!
	}
}

// book_open opens the book with the provided name
fn (actor PublisherActor) book_open(action actionslib.Action) ! {
	rlock actor.books {
		name := action.params.get('name')!
		if name !in actor.books {
			return error('Book ${name} not found :(')
		}
		actor.books[name].read()!
	}
}
