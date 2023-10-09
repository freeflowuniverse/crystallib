
## select the domain/book/actor

```yaml
!!select_domain protocol_me
!!select_book aaa
!!select_actor people
```

## sid = Smart ID

A smart id consists out of `rid.bid.cid`.  A Smart if is a unique id to represent a piece of information on global level.

The following are valid representations

- '$rid.$bid.$cid'
- '$bid.$cid' if rid is known
- '$cid' if bid and rid are known

```golang
pub struct SmartId {
pub mut:
	rid 		 string //regional internet id
	bid          string //link back to the id of the book, so we can find the book back
	cid          string //content id
}
```


