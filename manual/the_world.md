
# the world

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

