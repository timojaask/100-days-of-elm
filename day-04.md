## Day 4

Quick review of day 3:

There wasn't much new in day 3 in terms of language, but a few things wouldn't hurt to revise.

One of them is the fact that messages can have parameters passed with them and handled in the `update` function, like so:

```
type Msg
  = MessageWithoutParam
  | MessageWithStringParam String
update : Msg -> Model -> Model
update msg model =
  case msg of
    MessageWithoutParam ->
      { model | someField = not model.someField }
    MessageWithStringParam strParam
      { model | someOtherField = strParam }
```

This is used for example when passing a message from a text input field, where we want to know what is the value of the input text, like so:

```
input [ type_ "text", placeholder "Name", onInput Name ] []
```

Another thing learned is that you can add your own functions that return Html and call them inside the `view` function:

```
view : Model -> Html Msg
view model =
  div []
    [ text "Hello, World!"
    , myCustomComponent model.name
    ]

myCustomComponent : String -> Html msg
myCustomComponent name =
  text ("Hello, " ++ name ++ "!")
```

You can also define some local variables in using `let ... in`. I haven't really learned about this yet, but it looks like this defined a scoped variable:

```
someFunction : Model -> Html msg
someFunction model =
  let
    (color, message) =
      if model.someBoolState then
        ("black", "Hello")
      else
        ("red", "Goodbye")
  in
    div [ style [("color", color)]] [ text message ]
```

Changing fields within a record is done using this sort of syntax:

```
newRecord = { oldRecord | field1 = "Hello", field2 = "World" }
```

---

Next up: Effects!

This is the good stuff. Here's an ascii diagram of how our applications were working till now:

```
 +----> update >-----+
 |                   |
Msg                Html
 ^                   |
 |                   v
 =====================
 ==== ELM RUNTIME ====
```

As you might be able to see from this, the Elm runtime is doing all the work. Our application is just transofming data, nothing else. We just write pure functions that take in some data and return some data. They are easy to test and deterministic. We are avoiding dealing with any side effects ourselves (such as listening to user input or writing to DOM), Elm runtime does the dirty job for us.

So how do we deal with other side effects, such as doing network requests or subsribing to some other data emitters? This is where Commands and Subscriptions come into play. Actually, they are simple data messages just like the messages we already used. And again, our app just transforms the data, and Elm runtime does the dirty job of actually executing the side effects. The new diagram would look somethong like this:

```
 +----> update >-----+---+---+
 |                   |   |   |
Msg                Html Sub Cmd
 ^                   |   |   |
 |                   v   v   v
 =============================
 ======== ELM RUNTIME ========
```

The way it works is your `update` function gets a message (e.g. user clicked a button), then you'd return a command that would ask Elm runtime to do a network request. Once request is completed and some data is received, it would be passed into your app with a new Msg, which you'd handle in your `update` function as usual. To send a request before any message is received you can use a new `init` function, which is called on start.

New signature for the `update` function:
```
update : Msg -> Model -> (Model, Cmd Msg)
```
This can be read as: Update takes a message and a model, and returns a tuple containing a new model, and a command that produces a message. The command could be something like "FetchUserProfile", and the produced message could be "UserProfileResponse". I totally just made this up, but we'll see if this is correct in the following examples.

---

First expample from the book is the random number generator. Some new things that I need to write about here, in order to process what's going on.

First of all, now we aren't creating a `Html.beginnerProgram` anymore. This time it looks like this:

```
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
```

Question: where are `beginnerProgram` and `program` defined? This is where the docs can be (at the time of writing) found: `http://elm-lang.org/docs` -> Click on "HTML" -> Click on "Html" -> you should now be on `http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html`. Here if you scroll down to "Programs" section, you can find signatures for `beginnerProgram`, `program`, and `programWithFlags`. Flags seems to be some kind of JavaScript interop enabling thing. Will probably learn about it later.

Back to the code -- we have to define `subscriptions`,  which the tutorial doesn't talk about. Here's what worked for me:

```
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
```

Basically not subscribing to anything in this app.

Then we also need to define an `init` function, where you can define the initial state for your model and send a command. In this case, we don't send any:

```
init : (Model, Cmd Msg)
init =
  (Model 0, Cmd.none)
```

However, we could send a dice rolling command. Let's get back to this later.

The `update` function is where all the interesting stuff happens. It how has a different signature:
```
update : Msg -> Model -> (Model, Cmd Msg)
```
So we'll be returning a tuple containing both model and a command object. Let's see that in practice:
```
update msg model =
  case msg of
    Roll ->
      (model, Random.generate NewFace (Random.int 1 6))

    NewFace newFace ->
      (Model newFace, Cmd.none)
```
So we have two messages that we're handling in `update`:
- `Roll` -- this is when user clicks a button, and we want to roll a dice. So we're going to ask Elm runtime to run a random generator for us.

The syntax for the `Random.generate` command is interesting, so better take a look at the docs: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Random
In the Random doc page, scroll down to "Generate Values" section. This is where you can find the `generate` function.

The first argument should be a function. Now I'm still struggling with this syntax a little bit. It apparently wants a function that takes any value and returns a message. Spoiler: This should be the `NewFace` message. I'm just gonna roll with it for now.

The second argument wants a `Random.Generator` of any type (that's the ` a` part). We want to generate an integer, so you can scroll up in the Random docs to the "Primitive Generators" section and find the `int` generator. It is a function, which returns a `Generator` of type `Int`, so that's what we want. Calling this function requires two parameters: minInt and maxInt, so in case of a dice, we'd want to call it like so: `Random.int 1 6`, which should produce an integer generator that generates nunbers from 1 to 6, inclusive.

So that was a long breakdown of one line of code! Are we done yet? Nope! We've just asked Elm runtime to generate a random integer for us. But how to we get the result? If you remeber, we passed it the `NewFace` message. This is the "callback" that we're gonna use. So when the number is generated, Elm runtime will send us the `NewFace` messages with the result as a parameter. Here's this part again for your convenience:
```
    NewFace newFace ->
      (Model newFace, Cmd.none)
```
So we can go ahead and update the model with the new dieFace number. Could have also done it by updating a field, like: `{ model | dieFace = newFace }`, but since it's the only field in the record, might as well create the whole record from scratch -- less typing. Then we also pass `Cmd.none`, because we don't need the Elm runtime to do anything else at this point.

And we're done! Let's proceed with some exercises.

---

### Exercise 1

> Instead of showing a number, show the die face as an image.

So I need to dig up some dice images (or draw). In this sort of situations my go-to website is www.flaticon.com. Surely enough, founds some nice looking die faces.
Next, we need to figure out how to display an image. Let's try the docs:
```
img : List (Attribute msg) -> List (Html msg) -> Html msg
Represents an image.
```
That was extremely helpful, but I'm just going to place these images into a `img` subfolder relative to the elm source code and see what happens -- `img [ src "./img/dice-1.png" ] []` -- and viola! It works.

Then I'm going to need to generate an image based on `model.dieFace`. Let's be fancy and make a function for that. Something like this:

```
dieFaceImage : Int -> Html msg
dieFaceImage dieFace =
  img [ src ("./img/dice-" ++ (toString dieFace) ++ ".png") ] []
```

then call that instead of `img` in the `view` function:
```
view model =
  div []
    [ dieFaceImage model.dieFace
    , button [ onClick Roll ] [ text "Roll" ]
    ]
```
And what do you know, it works! Roll the pretty visual dice!

By the way, let's be fair and credit the author of the awesome dice images. As per Flaticon guidelines, the attribution shall be as follows:

```
attribution : Html msg
attribution =
  span []
    [ text "Icon made by "
    , a [ href "https://smashicons.com/" ] [ text "Smashicons" ]
    , text " from "
    , a [ href "https://www.flaticon.com"] [ text "www.flaticon.com" ]
  ]
```

### Exercise 2

> Add a second die and have them both roll at the same time.

So we'd need to generate two individual random numbers. On the first try I used the same generator as before, but called it twice, like so:

```
type Msg
  = Roll
  | FirstDie Int
  | SecondDie Int
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model, Random.generate FirstDie (Random.int 1 6))

    FirstDie newFace ->
      ({ model | dieFace1 = newFace }, Random.generate SecondDie (Random.int 1 6))

    SecondDie newFace ->
      ({ model | dieFace2 = newFace }, Cmd.none)
```

But this is pretty clunky and requires two trips to Elm runtime and back. Not cool. Let's see what Random docs has to offer. Sure enough, they have a `pair` generator, which proces a pair of random generators. How handy. The signature is like this:
```
pair : Generator a -> Generator b -> Generator (a, b)
```
Armed with that knowledge, we can rewrite our `update` to do only one call:
```
type Msg
  = Roll
  | NewFace (Int, Int)
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model
      , Random.generate NewFace
        ( Random.pair (Random.int 1 6) (Random.int 1 6) )
      )

    NewFace (newFace1, newFace2) ->
      (Model newFace1 newFace2, Cmd.none)
```

And it works!

### Exercise 3

> Instead of showing an image of a die face, use the elm-lang/svg library to draw it yourself.

Now we need to dig into the svg library docs. Oh boy.

So I started with a completely boneheaded approach, by making a separate SVG generating function for each face:

```
dieFaceProps : List (Attribute msg)
dieFaceProps = [ width "100", height "100", viewBox "0 0 100 100" ]
dieFaceRect : Html.Html msg
dieFaceRect = rect [ fill "green", x "0", y "0", width "100", height "100" ] []
dieFaceCircle : Int -> Int -> Html.Html msg
dieFaceCircle x y = circle [ fill "white", cx (toString x), cy (toString y), r "10" ] []

dieFace1 : Html.Html msg
dieFace1 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 50 50
    ]

...

dieFace6 : Html.Html msg
dieFace6 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 20 20
    , dieFaceCircle 20 50
    , dieFaceCircle 20 80
    , dieFaceCircle 80 80
    , dieFaceCircle 80 50
    , dieFaceCircle 80 20
    ]
```

Not pretty. I'll come back tomorrow to fix this. Maybe a better way would be to have a list of circle configurations, and then just one SVG generating function that would take a face number, and use the list to see what circle configuration to do.