
# sid = Smart ID

- format:
  - smart id, is 3 to 6 letters, 0...z
- the rid,cid and id are all smart id's
- sid's are unique per circle
- sid's are remembered in redis, so we know for sure that they are unique
- sid's can be converted to int very easily

## gid = Global ID

Identifies an object in unique way on global level, normally not needed in 3script, because 3script most often executes in context of a circle

- gid = rid.cid.oid
  - rid = region id (regional internet on which circle is defined)
  - cid = circle id
  - id = object id
- each of above id's are smart id's


The following are valid representations

- '$rid.$cid.$id'
- '$cid.$id' if rid is known
- '$id' if rid and cid are known

## automatically fill in 

```golang
!circle_role.define
  id:'***' //means will be filled in automatically, unique per circle
  name:'vpsales'      
	circle:'tftech' //can be id of circle or name
	role:'stakeholder' 
```

## code

```golang
pub struct SmartId {
pub mut:
	rid 		     string //regional internet id
	cid          string //link to circle
	id          string //content id
}
```

## sid's can address the world

- each object can be addressed by means of 3 smart id's
    - $smartid_region (e.g. regional internet)
    - $smartid_circle
    - $smartid_object
- object is any of the object types e.g. issue, story, ...
- each object is identified as 
    - $smartid_region.$smartid_circle.$smartid_object
    - $smartid_circle.$smartid_object (will enherit the id from the region we are operating on)
    - $smartid_object  (will enherit region and circle from the circle we are operating on)
- smart id is
    - 2 to 6 times [a...z|0...9]
    - size to nr of objects
        - 2 -> 26+10^2 = 1,296
        - 3 -> 26+10^3 = 46,656
        - 4 -> 26+10^4 = 1,679,616
        - 5 -> 26+10^5 = 60,466,176
        - 6 -> 26+10^6 = 2,176,782,336
- a circle can be owned by 1 person or by a group (e.g. company, or administrators for e.g. blockchain DB)
- e.g. 1a.e5q.9h would result to globally unique identifier 1a would be the region, e5q the circle, 9h is id of the obj in my circle

