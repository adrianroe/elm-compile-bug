I think the below is a minimal repro of a compiler bug in Elm.  It is a (tiny!) reduction from what started life as code to describe directed asyclic graphs in Json, decode them in Elm and then render them to the screen.

The code parses some very simple, albeit recursive, Json.

Following the pattern in https://github.com/elm-lang/elm-compiler/blob/0.18.0/hints/bad-recursion.md it was straightforward to come up with a single file example that took recursive Json and map it to approriately non-recursive Elm types.

In it's very simplest form, the bug still occurs if you have types as below:

```elm
type alias Node =
    { name : String
    , nodes : Nodes
    }


type Nodes
    = Nodes (List Node)
```

The Json parser is similarly simple (here using Json.Decode.Pipeline - the bug also happens with Json.Decode on its own):

```elm
nodesDecoder : Decoder Nodes
nodesDecoder =
    Json.Decode.map Nodes (list (lazy (\_ -> decodeNode)))


decodeNode : Decoder Node
decodeNode =
    decode Node
        |> required "name" string
        |> required "nodes" nodesDecoder
```
Parsing:

```elm
{
  "name": "The node",
  "nodes": []
}

with this code, as expected gives:

```elm
Ok { name = "The node", nodes = Nodes [] }
```

The "real" code is much more complex, with all sorts of information within a node and nodes containing not only other nodes, but also edges that referenced multiple nodes.  If all the code was in a single file then everything works perfectly :)

However, given the complexity and the large number of types involved, I split the actual code into two files - one for the types and another of the parser.

When you split the above code into NodeJson and NodeTypes (to save any copy and paste, you can get it here https://github.com/adrianroe/elm-compile-bug) things get much more brittle.

The code as in git repo also works.  Run elm-reactor and double click on Main.elm and you've get the expected output.  However, if you change the order of definition of the decoders in NodeJson to be the other way round as below:

Doing so with the code as below (identical, with the functions in the reverse order):

```elm
decodeNode : Decoder Node
decodeNode =
    decode Node
        |> required "name" string
        |> required "nodes" nodesDecoder


nodesDecoder : Decoder Nodes
nodesDecoder =
    Json.Decode.map Nodes (list (lazy (\_ -> decodeNode)))
```

...compiles just fine, but you get:
```
Main.elm:4467 Uncaught TypeError: Cannot read property 'tag' of undefined
```
The line of code is in runHelp (it's the switch line that fails).
```
function runHelp(decoder, value)
{
	switch (decoder.tag)
	{
		case 'bool':
			return (typeof value === 'boolean')
				? ok(value)
				: badPrimitive('a Bool', value);
...
```

If I merge the Json decoder and the Types into a sinlge file then I can't make it go wrong- regardless of the order of functions etc.

I hope this helps - it's certainly the minimal repro I could reduce my code to.

Thanks to all involved for Elm and it's awesomeness.  It has made this back-end developer's lifevastly better!
