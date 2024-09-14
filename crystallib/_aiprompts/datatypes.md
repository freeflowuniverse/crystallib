module datatypes

# datatypes

This module provides implementations of less frequently used, but still common data types.

V's `builtin` module is imported implicitly, and has implementations for arrays, maps and strings. These are good for many applications, but there are a plethora of other useful data structures/containers, like linked lists, priority queues, trees, etc, that allow for algorithms with different time complexities, which may be more suitable for your specific application.

It is implemented using generics, that you have to specialise for the type of your actual elements. For example:
```v
import datatypes

mut stack := datatypes.Stack[int]{}
stack.push(1)
println(stack)
```

## Currently Implemented Datatypes:

- [x] Linked list
- [x] Doubly linked list
- [x] Stack (LIFO)
- [x] Queue (FIFO)
- [x] Min heap (priority queue)
- [x] Set
- [x] Quadtree
- [x] Bloom filter
- [ ] ...


fn new_bloom_filter[T](hash_func fn (T) u32, table_size int, num_functions int) !&BloomFilter[T]
    new_bloom_filter creates a new bloom_filter. `table_size` should be greater than 0, and `num_functions` should be 1~16.
fn new_bloom_filter_fast[T](hash_func fn (T) u32) &BloomFilter[T]
    new_bloom_filter_fast creates a new bloom_filter. `table_size` is 16384, and `num_functions` is 4.
fn new_ringbuffer[T](s int) RingBuffer[T]
    new_ringbuffer creates an empty ring buffer of size `s`.
fn (mut bst BSTree[T]) insert(value T) bool
    insert give the possibility to insert an element in the BST.
fn (bst &BSTree[T]) contains(value T) bool
    contains checks if an element with a given `value` is inside the BST.
fn (mut bst BSTree[T]) remove(value T) bool
    remove removes an element with `value` from the BST.
fn (bst &BSTree[T]) is_empty() bool
    is_empty checks if the BST is empty
fn (bst &BSTree[T]) in_order_traversal() []T
    in_order_traversal traverses the BST in order, and returns the result as an array.
fn (bst &BSTree[T]) post_order_traversal() []T
    post_order_traversal traverses the BST in post order, and returns the result in an array.
fn (bst &BSTree[T]) pre_order_traversal() []T
    pre_order_traversal traverses the BST in pre order, and returns the result as an array.
fn (bst &BSTree[T]) to_left(value T) !T
    to_left returns the value of the node to the left of the node with `value` specified if it exists, otherwise the a false value is returned.
    
    An example of usage can be the following one
    ```v
     left_value, exist := bst.to_left(10)
    ```
fn (bst &BSTree[T]) to_right(value T) !T
    to_right return the value of the element to the right of the node with `value` specified, if exist otherwise, the boolean value is false An example of usage can be the following one
    
    ```v
     left_value, exist := bst.to_right(10)
    ```
fn (bst &BSTree[T]) max() !T
    max return the max element inside the BST. Time complexity O(N) if the BST is not balanced
fn (bst &BSTree[T]) min() !T
    min return the minimum element in the BST. Time complexity O(N) if the BST is not balanced.
fn (mut b BloomFilter[T]) add(element T)
    adds the element to bloom filter.
fn (b &BloomFilter[T]) exists(element T) bool
    checks the element is exists.
fn (l &BloomFilter[T]) @union(r &BloomFilter[T]) !&BloomFilter[T]
    @union returns the union of the two bloom filters.
fn (l &BloomFilter[T]) intersection(r &BloomFilter[T]) !&BloomFilter[T]
    intersection returns the intersection of bloom filters.
fn (list DoublyLinkedList[T]) is_empty() bool
    is_empty checks if the linked list is empty
fn (list DoublyLinkedList[T]) len() int
    len returns the length of the linked list
fn (list DoublyLinkedList[T]) first() !T
    first returns the first element of the linked list
fn (list DoublyLinkedList[T]) last() !T
    last returns the last element of the linked list
fn (mut list DoublyLinkedList[T]) push_back(item T)
    push_back adds an element to the end of the linked list
fn (mut list DoublyLinkedList[T]) push_front(item T)
    push_front adds an element to the beginning of the linked list
fn (mut list DoublyLinkedList[T]) push_many(elements []T, direction Direction)
    push_many adds array of elements to the beginning of the linked list
fn (mut list DoublyLinkedList[T]) pop_back() !T
    pop_back removes the last element of the linked list
fn (mut list DoublyLinkedList[T]) pop_front() !T
    pop_front removes the last element of the linked list
fn (mut list DoublyLinkedList[T]) insert(idx int, item T) !
    insert adds an element to the linked list at the given index
fn (list &DoublyLinkedList[T]) index(item T) !int
    index searches the linked list for item and returns the forward index or none if not found.
fn (mut list DoublyLinkedList[T]) delete(idx int)
    delete removes index idx from the linked list and is safe to call for any idx.
fn (list DoublyLinkedList[T]) str() string
    str returns a string representation of the linked list
fn (list DoublyLinkedList[T]) array() []T
    array returns a array representation of the linked list
fn (mut list DoublyLinkedList[T]) next() ?T
    next implements the iter interface to use DoublyLinkedList with V's `for x in list {` loop syntax.
fn (mut list DoublyLinkedList[T]) iterator() DoublyListIter[T]
    iterator returns a new iterator instance for the `list`.
fn (mut list DoublyLinkedList[T]) back_iterator() DoublyListIterBack[T]
    back_iterator returns a new backwards iterator instance for the `list`.
fn (mut iter DoublyListIterBack[T]) next() ?T
    next returns *the previous* element of the list, or `none` when the start of the list is reached. It is called by V's `for x in iter{` on each iteration.
fn (mut iter DoublyListIter[T]) next() ?T
    next returns *the next* element of the list, or `none` when the end of the list is reached. It is called by V's `for x in iter{` on each iteration.
fn (list LinkedList[T]) is_empty() bool
    is_empty checks if the linked list is empty
fn (list LinkedList[T]) len() int
    len returns the length of the linked list
fn (list LinkedList[T]) first() !T
    first returns the first element of the linked list
fn (list LinkedList[T]) last() !T
    last returns the last element of the linked list
fn (list LinkedList[T]) index(idx int) !T
    index returns the element at the given index of the linked list
fn (mut list LinkedList[T]) push(item T)
    push adds an element to the end of the linked list
fn (mut list LinkedList[T]) push_many(elements []T)
    push adds an array of elements to the end of the linked list
fn (mut list LinkedList[T]) pop() !T
    pop removes the last element of the linked list
fn (mut list LinkedList[T]) shift() !T
    shift removes the first element of the linked list
fn (mut list LinkedList[T]) insert(idx int, item T) !
    insert adds an element to the linked list at the given index
fn (mut list LinkedList[T]) prepend(item T)
    prepend adds an element to the beginning of the linked list (equivalent to insert(0, item))
fn (list LinkedList[T]) str() string
    str returns a string representation of the linked list
fn (list LinkedList[T]) array() []T
    array returns a array representation of the linked list
fn (mut list LinkedList[T]) next() ?T
    next implements the iteration interface to use LinkedList with V's `for` loop syntax.
fn (mut list LinkedList[T]) iterator() ListIter[T]
    iterator returns a new iterator instance for the `list`.
fn (mut iter ListIter[T]) next() ?T
    next returns the next element of the list, or `none` when the end of the list is reached. It is called by V's `for x in iter{` on each iteration.
fn (mut heap MinHeap[T]) insert(item T)
    insert adds an element to the heap.
fn (mut heap MinHeap[T]) insert_many(elements []T)
    insert array of elements to the heap.
fn (mut heap MinHeap[T]) pop() !T
    pop removes the top-most element from the heap.
fn (heap MinHeap[T]) peek() !T
    peek gets the top-most element from the heap without removing it.
fn (heap MinHeap[T]) len() int
    len returns the number of elements in the heap.
fn (queue Queue[T]) is_empty() bool
    is_empty checks if the queue is empty
fn (queue Queue[T]) len() int
    len returns the length of the queue
fn (queue Queue[T]) peek() !T
    peek returns the head of the queue (first element added)
fn (queue Queue[T]) last() !T
    last returns the tail of the queue (last element added)
fn (queue Queue[T]) index(idx int) !T
    index returns the element at the given index of the queue
fn (mut queue Queue[T]) push(item T)
    push adds an element to the tail of the queue
fn (mut queue Queue[T]) pop() !T
    pop removes the element at the head of the queue and returns it
fn (queue Queue[T]) str() string
    str returns a string representation of the queue
fn (queue Queue[T]) array() []T
    array returns a array representation of the queue
fn (mut rb RingBuffer[T]) push(element T) !
    push adds an element to the ring buffer.
fn (mut rb RingBuffer[T]) pop() !T
    pop returns the oldest element in the buffer.
fn (mut rb RingBuffer[T]) push_many(elements []T) !
    push_many pushes an array to the buffer.
fn (mut rb RingBuffer[T]) pop_many(n u64) ![]T
    pop_many returns `n` elements of the buffer starting with the oldest one.
fn (rb RingBuffer[T]) is_empty() bool
    is_empty returns `true` if the ring buffer is empty, `false` otherwise.
fn (rb RingBuffer[T]) is_full() bool
    is_full returns `true` if the ring buffer is full, `false` otherwise.
fn (rb RingBuffer[T]) capacity() int
    capacity returns the capacity of the ring buffer.
fn (mut rb RingBuffer[T]) clear()
    clear empties the ring buffer and all pushed elements.
fn (rb RingBuffer[T]) occupied() int
    occupied returns the occupied capacity of the buffer.
fn (rb RingBuffer[T]) remaining() int
    remaining returns the remaining capacity of the buffer.
fn (set Set[T]) exists(element T) bool
    checks the element is exists.
fn (mut set Set[T]) add(element T)
    adds the element to set, if it is not present already.
fn (mut set Set[T]) remove(element T)
    removes the element from set.
fn (set Set[T]) pick() !T
    pick returns an arbitrary element of set, if set is not empty.
fn (mut set Set[T]) rest() ![]T
    rest returns the set consisting of all elements except for the arbitrary element.
fn (mut set Set[T]) pop() !T
    pop returns an arbitrary element and deleting it from set.
fn (mut set Set[T]) clear()
    delete all elements of set.
fn (l Set[T]) == (r Set[T]) bool
    == checks whether the two given sets are equal (i.e. contain all and only the same elements).
fn (set Set[T]) is_empty() bool
    is_empty checks whether the set is empty or not.
fn (set Set[T]) size() int
    size returns the number of elements in the set.
fn (set Set[T]) copy() Set[T]
    copy returns a copy of all the elements in the set.
fn (mut set Set[T]) add_all(elements []T)
    add_all adds the whole `elements` array to the set
fn (l Set[T]) @union(r Set[T]) Set[T]
    @union returns the union of the two sets.
fn (l Set[T]) intersection(r Set[T]) Set[T]
    intersection returns the intersection of sets.
fn (l Set[T]) - (r Set[T]) Set[T]
    - returns the difference of sets.
fn (l Set[T]) subset(r Set[T]) bool
    subset returns true if the set `r` is a subset of the set `l`.
fn (stack Stack[T]) is_empty() bool
    is_empty checks if the stack is empty
fn (stack Stack[T]) len() int
    len returns the length of the stack
fn (stack Stack[T]) peek() !T
    peek returns the top of the stack
fn (mut stack Stack[T]) push(item T)
    push adds an element to the top of the stack
fn (mut stack Stack[T]) pop() !T
    pop removes the element at the top of the stack and returns it
fn (stack Stack[T]) str() string
    str returns a string representation of the stack
fn (stack Stack[T]) array() []T
    array returns a array representation of the stack
enum Direction {
	front
	back
}
struct AABB {
pub mut:
	x      f64
	y      f64
	width  f64
	height f64
}
struct BSTree[T] {
mut:
	root &BSTreeNode[T] = unsafe { 0 }
}
    Pure Binary Seach Tree implementation
    
    Pure V implementation of the Binary Search Tree Time complexity of main operation O(log N) Space complexity O(N)
struct DoublyLinkedList[T] {
mut:
	head &DoublyListNode[T] = unsafe { 0 }
	tail &DoublyListNode[T] = unsafe { 0 }
	// Internal iter pointer for allowing safe modification
	// of the list while iterating. TODO: use an option
	// instead of a pointer to determine it is initialized.
	iter &DoublyListIter[T] = unsafe { 0 }
	len  int
}
    DoublyLinkedList[T] represents a generic doubly linked list of elements, each of type T.
struct DoublyListIter[T] {
mut:
	node &DoublyListNode[T] = unsafe { 0 }
}
    DoublyListIter[T] is an iterator for DoublyLinkedList. It starts from *the start* and moves forwards to *the end* of the list. It can be used with V's `for x in iter {` construct. One list can have multiple independent iterators, pointing to different positions/places in the list. A DoublyListIter iterator instance always traverses the list from *start to finish*.
struct DoublyListIterBack[T] {
mut:
	node &DoublyListNode[T] = unsafe { 0 }
}
    DoublyListIterBack[T] is an iterator for DoublyLinkedList. It starts from *the end* and moves backwards to *the start* of the list. It can be used with V's `for x in iter {` construct. One list can have multiple independent iterators, pointing to different positions/places in the list. A DoublyListIterBack iterator instance always traverses the list from *finish to start*.
struct LinkedList[T] {
mut:
	head &ListNode[T] = unsafe { 0 }
	len  int
	// Internal iter pointer for allowing safe modification
	// of the list while iterating. TODO: use an option
	// instead of a pointer to determine if it is initialized.
	iter &ListIter[T] = unsafe { 0 }
}
struct ListIter[T] {
mut:
	node &ListNode[T] = unsafe { 0 }
}
    ListIter[T] is an iterator for LinkedList. It can be used with V's `for x in iter {` construct. One list can have multiple independent iterators, pointing to different positions/places in the list. An iterator instance always traverses the list from start to finish.
struct ListNode[T] {
mut:
	data T
	next &ListNode[T] = unsafe { 0 }
}
struct MinHeap[T] {
mut:
	data []T
}
    MinHeap is a binary minimum heap data structure.
struct Quadtree {
pub mut:
	perimeter AABB
	capacity  int
	depth     int
	level     int
	particles []AABB
	nodes     []Quadtree
}
fn (mut q Quadtree) create(x f64, y f64, width f64, height f64, capacity int, depth int, level int) Quadtree
    create returns a new configurable root node for the tree.
fn (mut q Quadtree) insert(p AABB)
    insert recursively adds a particle in the correct index of the tree.
fn (mut q Quadtree) retrieve(p AABB) []AABB
    retrieve recursively checks if a particle is in a specific index of the tree.
fn (mut q Quadtree) clear()
    clear flushes out nodes and particles from the tree.
fn (q Quadtree) get_nodes() []Quadtree
    get_nodes recursively returns the subdivisions the tree has.
struct Queue[T] {
mut:
	elements LinkedList[T]
}
struct RingBuffer[T] {
mut:
	reader  int // index of the tail where data is going to be read
	writer  int // index of the head where data is going to be written
	content []T
}
    RingBuffer represents a ring buffer also known as a circular buffer.
struct Set[T] {
mut:
	elements map[T]u8
}
struct Stack[T] {
mut:
	elements []T
}
