module actionsexecutor

import freeflowuniverse.crystallib.data.actionparser { ActionsArgs }
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.doctree

__global (
	actor_factory map[string]&PublisherActor
)

[noinit]
struct PublisherActor {
mut:
	doctree shared doctree.Tree
	books   shared map[string]&doctree.MDBook
}

// PlayConfig. If actions are provided runs actions. Otherwise loads and runs actions in path.
pub struct Play {
	ActionsArgs
	actions []actionparser.Action
}

pub fn play(params Play) ! {
	actions := if params.actions.len > 0 {
		ap := actionparser.Actions{
			actions: params.actions
		}
		ap.filtersort(actor: 'doctree')!
	} else {
		ap := actionparser.new(params.ActionsArgs)!
		ap.filtersort(actor: 'doctree')!
	}

	for action in actions {
		if action.circle !in actor_factory {
			actor_factory[action.circle] = &PublisherActor{
				doctree: doctree.new()!
			}
		}
		actor_factory[action.circle].act(action)!
	}
}

// act handles incoming action and matches to corresponding method
pub fn (mut actor PublisherActor) act(action actionparser.Action) ! {
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

// collections_scan scans a path for collections and adds the collections to actor's doctree
fn (mut actor PublisherActor) collections_scan(action actionparser.Action) ! {
	git_url := action.params.get('git_url')!
	git_root := action.params.get('git_root')!
	lock actor.doctree {
		actor.doctree.scan(
			git_url: git_url
			git_root: git_root
			heal: true
		)!
	}
}

// book_generate generates an mdbook using the actor's doctree and provided params
fn (mut actor PublisherActor) book_generate(action actionparser.Action) ! {
	mut tree := doctree.Tree{}
	rlock actor.doctree {
		tree = actor.doctree
	}
	lock actor.books {
		name := action.params.get('name')!
		if name in actor.books {
			return error('Book with name ${name} exists')
		}
		actor.books[name] = doctree.book_generate(
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
fn (actor PublisherActor) book_open(action actionparser.Action) ! {
	rlock actor.books {
		name := action.params.get('name')!
		if name !in actor.books {
			return error('Book ${name} not found :(')
		}
		actor.books[name].read()!
	}
}
