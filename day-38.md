## Day 38

Yesterday I did Elm architecture in Swift, just for fun, but today I'm gonna get back to the real Elm.

I started by watching Robert Feldman's Frontend Masters course on Elm, version 2. One interesting bit that came out of that is that Msg can indeed be anything really. So far I've been always using union types to describe messages. For example:

```
type Msg
    = Increment
    | Decrement

button [ onClick Increment ] [ text "Increment" ]
```

Which is very convenient and is the standard way to do things in Elm. But the fun part is that it doesn't need to be a union type. It can be a record:

```
type alias Msg =
    { action : String
    , type : String
    }

button [ onClick (Msg "ButtonClicked" "Increment")] []
```

Not saying that this should be used, but it's interesting to realize that it's not set in stone that it has to be a union type.

Another "fun" fact is what's called "parametrized types". A `List` is a parametrized type, because in order to use a `List`, you have to provide a parameter telling what is the type of the items that this list is going to hold, for example, a list of strings `List String`, or a list of integers `List Int`.

Another parametrized type is `Html` -- the stuff that the `view` function returns. The parameter for `Html` type says what is the type of messages that this code is going to produce. This is then going to be the same type that the `update` function recives as the first parameter. So if we define our view as `view : Model -> Html String`, then we must define our update as `update : String -> Model -> Model`. Commonly the messages we pass are a union type, which is by convention named `Msg`. This means that our view function would return `Html` with a messages of type `Msg`, and our update must take first parameter of type `Msg`.

Another fun fact is that functions in Elm can only ever take one argument. If you have a function that needs more arguments to complete its task, then you use multiple functions under the hood -- applying first parameter you get a function that takes the next parameter, and applying the next parameter gives you a function that returns the final result -- as an example. So for example `update : Msg -> Model -> Model`, is a function that takes one parameter `Msg` and returns a function that takes a `Model` and returns a `Model`.

---

Improved the Border Quizz game a bit. Created a stylesheet for it, which lives in `index.css`. It's included in the `index.html` file, which also starts the app, which is in `main.js`. The `main.js` is compiled by running:

```
elm make src/Main.elm --output main.js
```

