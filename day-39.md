## Day 39

Quick review of day 38:

Yesterday I continued watching Frontend Masters Elm workshop v2, and noted a few interesting bits:
- Where we usually use `Msg` it can really be any type, it can be `String` or a record or anything.
- The message type in `update` must be the same as what's returned in `view`.
- `view` returns a parametrized `Html` type. Parametrized means that `Html` can't be declared just like that on its own, it takes a parameter. In this case, the parameter defines the type of message that the `Html` can produce, which in case of `view` must be the same as what `update` receives. `List` is another parametrized type -- it must have a type of item as a parameter.
- Parametrized type can take generic type as a parameter, such as `List a` -- meaning that the list can be of any type. Or `Html a` (convention: `Html msg`) -- meaning that `Html` will have whatever message type.
- Functions in Elm can only ever take one argument. If you want to emulate multiple arguments, the function must return another function that takes the second argument. 

I also added an external CSS style sheet to the Border Quiz game, and removed the inline styles. This is a typical way of managing styles in Elm. Another common way would be to use something like `elm-css`, which I should probably try out later. I also added `index.html` which runs the Elm code and includes the style. The Elm code is compiled to JavaScript with `elm make src/Main.elm --output main.js`.

---

Today I continue watching the Elm workshop from Frontend Masters.

One interesting bit is a code smell. When you have two function arguments of the same type one after another, it's very easy to accidentally mix them up and the compiler won't tell us:

```
viewTag -> String -> String -> Html Msg
viewTag selectedTag tag =
```

This is a problem because we can break out app without knowing it. There are couple of solutions, both of which turn the two parameters into one record. One is by just taking the record and then using its properties in code:

```
viewTag -> { selectedTag : String, tag : String } -> Html Msg
viewTag config =
    -- USE: ... config.tag ... config.selectedTag
```

And another one is using destructuring assignment:

```
viewTag -> { selectedTag : String, tag : String } -> Html Msg
viewTag { selectedTag, tag } =
```

The latter probably is neater in this particular use case.

One thing to note is if we do this, we sacrifice partial application. We can no longer partially apply a record.

---

The different items in custom types (in other languages also known as "sum types", "union types", "ADTs" -- "algebraic data types") are actually called "variants". So the `Tab` custom type has three variants:

```
type Tab =
    YourFeed | GlobalFeed | TagFeed
```

You can also say that `Tab` can only have one of the three possible values. Like `Int` can have values `1`, `2`, `3`, etc, `Tab` can have values `YourFeed`, `GlobalFeed`, `TagFeed`. The difference here of course is that `Tab` can only have one of the three values, but `Int` can have nearly infinite number of values (or whatever we can fit in 64 bits).

Where `type alias` is giving a name to an existing type, `type` really creates a new type that did not exist before.

```
yours : Tab
yours =
    YourFeed
```

Above we're saying that `yours` has a value of `YourFeed` and its type is `Tab`.

Comparing this to `enum`s in many languages, where there would be some number value behind the enum variants, in Elm these are not backed by any primitive type, these are actual new kind of values defined. So you can't cast from `0` to `YourFeed` or anything like that.

Note that in the previous editions of Elm (< 0.19) custom types used to be called "union types".

---

This is an important key to understanding custom types with parameters. For example:

```
type Tab
    = YourFeed
    | GlobalFeed
    | TagFeed String
```

Here:

- `YourFeed` is a value of type `Tab`
- `GlobalFeed` is a value of type `Tab`
- `TagFeed` is a **function** that takes a `String` and returns a value of type `Tab`!

You can see that in Elm REPL:

```
> YourFeed
YourFeed : Tab

> GlobalFeed
GlobalFeed : Tab

> TagFeed
<function> : String -> Tab
```

This really helps clearing the confusion that you might have with the parametrized custom type variants. They are not values, they are functions that return the required value.

So when we do `TagFeed "hello"`, we are calling the `TagFeed` function, and it returns a value of type `Tag`, which we an then use somewhere.

For example, if our `Msg` is nested:

```
type RunningMsg
    = Pause
    | Resume

type Msg
    = Reset
    | RunningMsg RunningMsg
```

Our `update` expects message of type `Msg`, and so our `view` must return `Html Msg`. What if we need to send `Pause` message? Well, we can get the right type of message by calling `RunningMsg` function with `Pause` argument, and it will return a value of type `Msg`, just what we need to return.

There might be a slight confusion here, because we have a type named `RunningMsg`, and we have a function that is named `RunningMsg`. This is fine with Elm compiler, because it will know from the context which one you're using. You can see this by typing the variants in Elm REPL:

```
> RunningMsg
<function> : RunningMsg -> Msg

> Pause
Pause : RunningMsg
```

Typing `RunningMsg` will return a function that takes a value of `RunningMsg` type as a parameter, and returns a value of type `Msg`.

---

The use of custom types with `update` seems very elegant and compiler ensured. This makes me think of how Redux does the same thing with string values and reducers, which kinda makes it look like a pig with lipstick on. Sure it makes JavaScript a bit saner, but it's still pretty ugly underneath.

---

### Type variables

What is the return type of `List.head`? Since it can be applied to any type of lists, it's what you'd often call a generic function. In this case it's defiend as:

```
List.head : List elem -> Maybe elem
List.head list =
    ...
```

Here, `elem` is a type variable. You can name it just like any other variable, with a lowercase letter. It can be `a`, `b`, `val`, `element`, `lol`, etc, but what it means is that it's some type -- any type.