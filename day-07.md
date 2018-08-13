## Day 7

Quick review of day 6:

There wasn't really anything new learned yesterday (what?! :O) Yep. Played arond with clock SVG and then copied over the websocket example, which is just a repetition of previous learned concepts (commands and subscriptions).

Let's move right ahead into ✨ [Types!](https://guide.elm-lang.org/types/) ✨

---

New thing that came up in the [types chapter](https://guide.elm-lang.org/types/) is ananymous function syntax:
```
> \n -> n * 2
<function> : Float -> Float
```

One could use it for example in map:
```
> List.map (\n -> n * 2) [1, 2, 3]
[2,4,6] : List number
```

You can also save the result of defining an anonymous function:
```
> double = \n -> n * 2
<function> : number -> number

> double 4
8 : number
```

In fact, this is how all the functions are created in Elm. The function syntax we learned earlier:
```
> square n = n * n
<function> : number -> number
```
is just a syntax sugar for:
```
> square = \n -> n * n
<function> : number -> number
```

How about multiple arguments?
```
> multiply = \x -> (\y -> x * y)
<function> : number -> number -> number

> multiply 2 4
8 : number
```
This is where you start noticing how partial application fits in all of this:
```
> multiplyByTwo = multiply 2
<function> : number -> number

> multiplyByTwo 4
8 : number
```

What this means is that all functions in Elm are curried.

There was also a mention of forward function application operator `|>`. I'm gonna expand on that a bit here. Forward function application seems to be like `pipe` in Ramda, if you're familiar with that. Backward function application is like `compose` in Ramda. Some examples from the [docs](http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#<|):
```
-- backward function application
leftAligned (monospace (fromString "code"))
-- is same as
leftAligned <| monospace <| fromString "code"

-- forward function application
scale 2 (move (10,10) (filled blue (ngon 5 30)))
-- is same as
ngon 5 30
  |> filled blue
  |> move (10,10)
  |> scale 2
```

Neat!

[Type aliases](https://guide.elm-lang.org/types/type_aliases.html) can be used to replace type definition with a shorter name. For example, instead of writing:
```
hasBio : { name : String, bio : String, pic : String } -> Bool
hasBio user =
  String.length user.bio > 0
```
you can write:
```
type alias User =
  { name : String
  , bio : String
  , pic : String
  }

hasBio : User -> Bool
hasBio user =
  String.length user.bio > 0
```

If the type alias is for a record, like in the example above, then you also automaticlly get a constructor that you might find handy:
```
User "Bob" "Was born in Rotterdam" "bob-selfie.jpg"
```

---

### Union types

This is something a bit more exiting than type aliases. What are union types? A few examples:

They can be something that looks similar to enums in some other languages:
```
type Visibility = All | Active | Completed

\visibility -> tasks -> 
  case visibility of
    All ->
      tasks
    Active ->
      List.filter (\task -> not task.complete) tasks
    Completed ->
      List.filter (\taks -> task.complete) tasks
```

However, they can also add values to each type:

```
> type User = Anonymous | Named String

> Anonymous
Anonymous : User

> Named "Bob"
Named "Bob" : User
```

Or a great widget dashboard example, where we have three types of widgets, so how do we represent them:

```
-- LogsInfo, TimeInfo, ScatterInfo are three different types of records, each with their own kind of data.
type Widget = Logs LogsInfo | TimePlot TimeInfo | ScatterPlot ScatterInfo
-- Now we can represent all of them as Widget, so you can have a function that knows how to draw them:
view : Widget -> Html msg
view widget =
  case widget of
    Logs info ->
      viewLogs info

    TimePlot info ->
      viewTime info

    ScatterPlot info ->
      viewScatter info
```

Union types can be recursive too, so if you wanted to build a Linked list (which you don't need to, but for the sake of example):
```
> type List a = Empty | Node a (List a)

> Node 1.618 (Node 6.283 Empty)
Node 1.618 (Node 6.283 Empty) : List Float
```

Or a binary tree:
```
> type Tree a = Empty | Node a (Tree a) (Tree a)

> Node "hi" Empty Empty
Node "hi" Empty Empty : Tree String
```

Tomorrow we'll learn about `Maybe`, `Result`, and `Task`. Super exciting!