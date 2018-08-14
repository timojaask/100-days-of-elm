## Day 8

Quick review of day 7:

Full function syntax:
```
> multiply = \x -> (\y -> x * y)
<function> : number -> number -> number
> multiply 4 5
20 : number

> doubleListItems = List.map (\n -> n * 2)
<function> : List number -> List number
> doubleListItems [1, 2, 3]
[2,4,6] : List number
```

All functions in Elm are curried.

Let's look at forward and backward function application.
Starting with backward, which is done using `compose` in Ramda:
```
leftAligned (monospace (fromString "code"))
```
Can be written as:
```
leftAligned <| monospace <| fromString "code"
```
And forward, which is done using `pipe` in ramda:
```
scale 2 (move (10, 10) (filled blue (ngon 5 30)))
```
Can be written as:
```
ngon 5 30
  |> filled blue
  |> move (10, 10)
  |> scale 2
```

Use type aliases to conveniently name any type in Elm. For example:
```
type alias Dollars = Float
type alias User =
  { name: String
  , bio : String
  , pic : String
  }
```
In case of records, type alias also implicitely creates a constructor.

Union types are very powerful in Elm. You can create union types with or without arguments. You can use them to work on weird data structures.

For example, if you need a data structure to represent an active website user, who can be either anonymous or one that has a name. In Javascript you could have a user object, where name could be undefined if it's anonymous. However, this is error prone, as you have to make sure you don't accidentally display "undefined" in the user interface instead of the name. The language doesn't help you in preventing mistakes like that.

In Elm, you can't have undefined. User record either has a name or it's not a User record. So how do you represent both cases in one type? That's where union types come handy:

```
type User = Anonymous | Named String

displayUserName : User -> Html Msg
displayUserName user =
  case user of
    Anonymous ->
      text "Anonymous"
    Named name ->
      text name
```

Elm forces you to handle the anonymous case.

Union types can also be recursive, as in a linked list example:
```
> type List a = Empty | Node a (List a)

> Node 1.618 (Node 6.283 Empty)
Node 1.618 (Node 6.283 Empty) : List Float
```

---

Before getting into Error Handling and Tasks, let's do some union type related exercises. There are a few found in the [binary tree example](http://elm-lang.org/examples/binary-tree)

One interesting thing I noticed when reading the binary tree example is the `foldl` function. It's like reduce in many languages or libraries. There's also `foldr` which does the same, but iterates the list in a reverse order.

### Exercise 1

> Sum all of the elements of a tree.
> sum : Tree number -> number

Very straight forward, similar to already defined functions:

```
sum : Tree number -> number
sum tree =
  case tree of
    Empty -> 0
    Node n left right ->
      n + (sum left) + (sum right)
```

### Exercise 2

> Flatten a tree into a list.
> flatten : Tree a -> List a

Same as before, simple recursive concatenation of node values:

```
flatten : Tree a -> List a
flatten tree =
  case tree of
    Empty -> []
    Node v left right ->
      [v] ++ (flatten left) ++ (flatten right)
```

### Exercise 3

> Check to see if an element is in a given tree.
> isElement : a -> Tree a -> Bool

Again, same as previous examples.

```
isElement x tree =
  case tree of
    Empty -> False
    Node v left right ->
      if x == v then True
      else (isElement x left) || (isElement x right)
```

### Exercise 4

> Write a general fold function that acts on trees. The fold function does not need to guarantee a particular order of traversal.
> fold : (a -> b -> b) -> b -> Tree a -> b

One way is to reuse the existing functionality:

```
fold : (a -> b -> b) -> b -> Tree a -> b
fold func acc tree = List.foldl func acc (flatten tree)
```

But if we wanted to do it the more difficult way (faster?), then perhaps:
```
fold : (a -> b -> b) -> b -> Tree a -> b
fold func acc tree =
  case tree of
    Empty -> acc
    Node v left right ->
      (func v (fold func (fold func acc right) left))
```

### Exercise 5

> Use "fold" to do exercises 1-3 in one line each. The best readable versions I have come up have the following length in characters including spaces and function name:
>  sum: 16
>  flatten: 21
>  isElement: 46
> See if you can match or beat me! Don't forget about currying and partial application!

Not sure what constutues "readable" in this case. I think the `sum` and `fold` below are readable for a trained eye, but `isElement` is pretty funky. Would not ship it maybe.
```
sum : Tree number -> number
sum=fold (+) 0

flatten : Tree a -> List a
flatten=fold (::) []

isElement : a -> Tree a -> Bool
isElement v=fold (\a -> ((||) (a == v))) False
```

### Exercise 6

> Can "fold" be used to implement "map" or "depth"?

Damn, that's tough. "depth" seems too fat fetched. I don't think we can know where in the tree each value comes from, so I'd say that's impossible. I also don't see how can we preserve the tree structure in "map".

### Exercise 7

> Try experimenting with different ways to traverse a tree: pre-order, in-order, post-order, depth-first, etc. More info at: http://en.wikipedia.org/wiki/Tree_traversal

Let's use `flatten` as an example.

#### Pre-order (NLR)

-- Got interrupted. Continue tomorrow.