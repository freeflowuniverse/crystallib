


## the lifecycle of a markdown doc in this parser

- parse (as done by parse_doc()) and create doc with only the following elements
  - Action
  - Codeblock
  - Comment
  - Header
  - Html
  - Paragraph
  - Table
- then the process function will be called on each of the found elements
  - this process function can find children elements which can be
    - Action  -> will parse the action and empty .content
    - Codeblock -> can create Actions as children other text founds stays as content
    - Comment, Header, Html not much too do
    - Paragraph is the big one, will use char parser
      - see below makes children as specified there
      - these children are just used to be able to detect relevant items in the Paragraph for e.g. html or pug output
- now each element has been processed the .processed has been set
- now the doctree or another processor can find the elements he is interested in e.g. actions, links, ...
    - if needed the doctree will set .content so that the markdown() will give another outcome
  

## The Doctree with do the following process

- process includes first
- process definitions


## The Elements

- Action
  - cannot have children
  - once action processed the .content has been set
- Codeblock
  - children: actions
  - content is the text which are not actions
  - markdown() -> gets the actions reformatted + other text after (.content)
- Comment
  - cannot have children
  - markdown() -> returns the original
- Header
  - cannot have children
  - markdown() -> returns the original
- Html
  - cannot have children
  - markdown() -> returns the original
- Paragraph
  - has children which were parsed with the char parser
  - children
    - Comment
    - Def
    - Link
    - List / ListItem
    - Table
  - markdown() -> returns the original (reformat based on children)
