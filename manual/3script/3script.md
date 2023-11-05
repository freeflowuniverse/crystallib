# 3script

Our core language of how we act within baobab.

Each action/macro starts with !, !!,!!!  or !!!!

!!include dal

!!include sal

### wal = world abstraction layer

- !!! : world dsl action = WAL
  - $domain.$topicname.$actionname
      - domain means vendor domain, the people maintaining the relevant code
      - topicname to be further defined, what it means
  - the actorname and actionname can be anything, but always compliant with our namefix transformer (unify a name)
  - domain is optional, if not mentioned then is core.  which is our default

### macros

- !!!! : macro's
  - format: $domain.$macroname
  - there are html and wiki macro's
  - they produce wiki or html
  - if wiki once parsing 3script it will replace the macro with the wiki output, this happens recursive
  - if html, only relevant for when creating html pages
  - domain is optional, if not mentioned then is core.  which is our default

## more info

> see [dsl](dsl.md) to understand which DSL's we have.


when executing 3script the following order will always be maintained

-  DAL
-  WAL
-  SAL
-  MACROS

## specials

### definitions

- {$defname} or {$collectionname:defname} will get transformed to a link to the page which has defined the concept of definition

### circle selection

- !!tree.circle_select id:... name:...
- will make sure that all following actions (dal, sal, wal) are executed in that specified circle