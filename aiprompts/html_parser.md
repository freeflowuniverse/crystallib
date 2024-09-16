module net.html

net/html is an **HTML Parser** written in pure V.

## Usage

```v
import net.html

fn main() {
    doc := html.parse('<html><body><h1 class="title">Hello world!</h1></body></html>')
    tag := doc.get_tags(name: 'h1')[0] // <h1>Hello world!</h1>
    println(tag.name) // h1
    println(tag.content) // Hello world!
    println(tag.attributes) // {'class':'title'}
    println(tag.str()) // <h1 class="title">Hello world!</h1>
}
```

More examples found on [`parser_test.v`](parser_test.v) and [`html_test.v`](html_test.v)

fn parse(text string) DocumentObjectModel
    parse parses and returns the DOM from the given text.
    
    Note: this function converts tags to lowercase. E.g. <MyTag>content</MyTag> is parsed as <mytag>content</mytag>.
fn parse_file(filename string) DocumentObjectModel
    parse_file parses and returns the DOM from the contents of a file.
    
    Note: this function converts tags to lowercase. E.g. <MyTag>content</MyTag> is parsed as <mytag>content</mytag>.
enum CloseTagType {
	in_name
	new_tag
}
struct DocumentObjectModel {
mut:
	root           &Tag = unsafe { nil }
	constructed    bool
	btree          BTree
	all_tags       []&Tag
	all_attributes map[string][]&Tag
	close_tags     map[string]bool // add a counter to see count how many times is closed and parse correctly
	attributes     map[string][]string
	tag_attributes map[string][][]&Tag
	tag_type       map[string][]&Tag
	debug_file     os.File
}
    The W3C Document Object Model (DOM) is a platform and language-neutral interface that allows programs and scripts to dynamically access and update the content, structure, and style of a document.
    
    https://www.w3.org/TR/WD-DOM/introduction.html
fn (dom DocumentObjectModel) get_root() &Tag
    get_root returns the root of the document.
fn (dom DocumentObjectModel) get_tag(name string) []&Tag
    get_tag retrieves all tags in the document that have the given tag name.
fn (dom DocumentObjectModel) get_tags(options GetTagsOptions) []&Tag
    get_tags returns all tags stored in the document.
fn (dom DocumentObjectModel) get_tags_by_class_name(names ...string) []&Tag
    get_tags_by_class_name retrieves all tags recursively in the document root that have the given class name(s).
fn (dom DocumentObjectModel) get_tag_by_attribute(name string) []&Tag
    get_tag_by_attribute retrieves all tags in the document that have the given attribute name.
fn (dom DocumentObjectModel) get_tags_by_attribute(name string) []&Tag
    get_tags_by_attribute retrieves all tags in the document that have the given attribute name.
fn (mut dom DocumentObjectModel) get_tags_by_attribute_value(name string, value string) []&Tag
    get_tags_by_attribute_value retrieves all tags in the document that have the given attribute name and value.
fn (mut dom DocumentObjectModel) get_tag_by_attribute_value(name string, value string) []&Tag
    get_tag_by_attribute_value retrieves all tags in the document that have the given attribute name and value.
struct GetTagsOptions {
pub:
	name string
}
struct Parser {
mut:
	dom                DocumentObjectModel
	lexical_attributes LexicalAttributes = LexicalAttributes{
		current_tag: &Tag{}
	}
	filename    string = 'direct-parse'
	initialized bool
	tags        []&Tag
	debug_file  os.File
}
    Parser is responsible for reading the HTML strings and converting them into a `DocumentObjectModel`.
fn (mut parser Parser) add_code_tag(name string)
    This function is used to add a tag for the parser ignore it's content. For example, if you have an html or XML with a custom tag, like `<script>`, using this function, like `add_code_tag('script')` will make all `script` tags content be jumped, so you still have its content, but will not confuse the parser with it's `>` or `<`.
fn (mut parser Parser) split_parse(data string)
    split_parse parses the HTML fragment
fn (mut parser Parser) parse_html(data string)
    parse_html parses the given HTML string
fn (mut parser Parser) finalize()
    finalize finishes the parsing stage .
fn (mut parser Parser) get_dom() DocumentObjectModel
    get_dom returns the parser's current DOM representation.
struct Tag {
pub mut:
	name               string
	content            string
	children           []&Tag
	attributes         map[string]string // attributes will be like map[name]value
	last_attribute     string
	class_set          datatypes.Set[string]
	parent             &Tag = unsafe { nil }
	position_in_parent int
	closed             bool
	close_type         CloseTagType = .in_name
}
    Tag holds the information of an HTML tag.
fn (tag Tag) text() string
    text returns the text contents of the tag.
fn (tag &Tag) str() string
fn (tag &Tag) get_tag(name string) ?&Tag
    get_tag retrieves the first found child tag in the tag that has the given tag name.
fn (tag &Tag) get_tags(name string) []&Tag
    get_tags retrieves all child tags recursively in the tag that have the given tag name.
fn (tag &Tag) get_tag_by_attribute(name string) ?&Tag
    get_tag_by_attribute retrieves the first found child tag in the tag that has the given attribute name.
fn (tag &Tag) get_tags_by_attribute(name string) []&Tag
    get_tags_by_attribute retrieves all child tags recursively in the tag that have the given attribute name.
fn (tag &Tag) get_tag_by_attribute_value(name string, value string) ?&Tag
    get_tag_by_attribute_value retrieves the first found child tag in the tag that has the given attribute name and value.
fn (tag &Tag) get_tags_by_attribute_value(name string, value string) []&Tag
    get_tags_by_attribute_value retrieves all child tags recursively in the tag that have the given attribute name and value.
fn (tag &Tag) get_tag_by_class_name(names ...string) ?&Tag
    get_tag_by_class_name retrieves the first found child tag in the tag that has the given class name(s).
fn (tag &Tag) get_tags_by_class_name(names ...string) []&Tag
    get_tags_by_class_name retrieves all child tags recursively in the tag that have the given class name(s).
