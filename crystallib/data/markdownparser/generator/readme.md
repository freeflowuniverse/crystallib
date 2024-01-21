
to make sure all types are generated do

```bash
vrun ~/code/github/freeflowuniverse/crystallib/crystallib/data/markdownparser/generator/generator.v
```

make sure you adjust the types you want in generator.v see

```golang
fn get_generator_names() []ElementCat {
	mut elementsobj:=[]ElementCat{}
	
	//HERE ADD YOUR DIFFERENT ELEMENTS
	elementsobj<<new(name:"html",classname:"HTML")
	elementsobj<<new(name:"none")
	elementsobj<<new(name:"paragraph")
	elementsobj<<new(name:"text")
	elementsobj<<new(name:"action")

	return elementsobj
}
```

add your elements object to that file