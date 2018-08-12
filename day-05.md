## Day 5

Quick review of day 4:

It was exciting! Yesterday we started looking at how effects are handled by Elm runtime (to be continued today). Let's go through new things one at a time:

- There are three types of programs you can make: `beginnerProgram`, `program`, and `programWithFlags`. They are described in the [Html docs](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html) From here on out, I'm assuming that `program` is used.
- use an initializer function to provide the initial model and command.
- `update` now returns a tuple, which contains a new model and a command for the Elm runtime to process.
- Learned to use [random generators](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Random).
- Learn to add local [images](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html#img) and (SVG)[http://package.elm-lang.org/packages/elm-lang/svg/latest]

---

Today I want to start by improving yesterday's example 3 solution. The original solution to draw SVG dice faces was to have a function for each of the 6 faces, but I'd like to write a more compact code. Let's see.

... half an hour later -- So I got a bit carried away with SVG painting and more or less replicated the PNG icons by manually styling the SVG components. Waste of time? Probably. Fun? Definitely!

It would be nice to split the code into multiple files at this point, but perhaps another time. See the code in [random.elm](./effects/random.elm)

---

Exercise 4 uses animation and tasks which should be covered later in the tutorial, so I'll leave it for later. For now, let's move onto HTTP!

---

See the HTTP example implementation in [http.elm](./effects/http.elm). What's new and exciting here?

`Http.send` command generator. Generates a command that tells Elm runtime to send an HTTP request. Takes two parameters: the handler function (in this case `NewGif (Result Http.Error String)`) and an `Http.Request`. Sending this command to Elm runtime will make it send the request, and when a response is received, be it error or success, it will be handled in your `update` function under `NewGif` case. For more, see the [Http package docs](http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http).

Defining a request object is pretty simple. For GET request use `Http.get` and pass a URL (String) and a result decoder (`Json.Decode.Decoder`). The decoder will take a succesful result and parse it the way you want. For example, to get a value from down a path of some JSON response, you can: `Json.Decode.at ["path", "to", "value"] Json.Decode.string` -- so two arguments: path to the value, and a decoder to use, in this case we just parse a string, so `Json.Decode.string` decoder is used. See more in [Json.Decode package docs](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode)

It's also good to look at how Http response is handled. The message in this example is like this: `NewGif (Result Http.Error String)`. We can receive either a success response, or an error response. We can handle this in two separate case statements:
```
    NewGif (Ok newUrl) ->
      ({ model | gifUrl = newUrl }, Cmd.none)

    NewGif (Err _) ->
      (model, Cmd.none)
```
Even though not used in this example, it's interesting to see what does the error contain:
```
type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus (Response String)
    | BadPayload String (Response String)
```

With this newly aquired Ajax knowledge we can now write some real badass Web 2.0 apps! Delightful!

Let's continue with some exercises.

---

### Exercise 1

> Show a message explaining why the image didn't change when you get an Http.Error.

We'll need a message string in the model to be displayed -- `errorMessage : String`. Then we need to convert the `Http.Error` to a string that we can display:
```
errorToString : Http.Error -> String
errorToString err =
  case err of
    Http.BadUrl str ->
      "Bad URL"
    Http.Timeout ->
      "Timeout"
    Http.NetworkError ->
      "Network error"
    Http.BadStatus response ->
      "Bad status: " ++ (toString response.status.code) ++ ": " ++ response.status.message
    Http.BadPayload errStr response ->
      "BadPayload. Reason: " ++ errStr
```
Let's put all of that to action inside of our `update` case:
```
    NewGif (Err err) ->
      ({ model | errorMessage = errorToString err }, Cmd.none)
```

### Exercise 2

> Allow the user to modify the topic with a text field.

Let's just replace the heading text with an input that would send a `SetTopic` message `onInput`. Then we handle `SetTopic` in `update` but settin the topic accordingly:
```
    SetTopic newTopic ->
      ({ model | topic = newTopic }, Cmd.none)
```

### Exercise 3

> Allow the user to modify the topic with a drop down menu.

Define available topics:
```
topics : List String
topics = [ "cats", "dogs", "cars" ]
```

Create select and option elements:
```
topicDropdown : Model -> Html Msg
topicDropdown model =
  select [ onInput SetTopic ]
    (List.map optionElement topics)

optionElement : String -> Html Msg
optionElement name =
  option [ value name ] [ text name ]
```

Note that select doesn't have its own `onChange` event. However, `onInput` works just as well for it, so we'll go with that.

By default, the first option is selected, which in this case is "cats". We need to make sure we initialize our model with the same value. Here it's just hard coded, but if we wanted to be precise, we could use `defaultTopic = Maybe.withDefault "cats" (List.head topics)` when initializing our model.

---

Moving on to subscriptions (the "Time" chapter in The Elm Architecture guide).

Here we learn how to subscribe to time ticks. Very straight forward:
```
type Msg = Tick Time
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      (newTime, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every second Tick
```

This means we're gonna get `Tick` message every second, with a current time passed in as a parameter.

Then there's some funky geometry math stuff going on. Let's dig deeper. For this we will be consulting the [Basics package docs](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Basics). We have `cos` and `sin` functions. Pretty self explanatory, nothing to it. And then there's `turns`. What? Let's look at the code:
```
angle = turns (Time.inMinutes model)
```

Let's break this down:
```
turns : Float -> Float
Convert turns to standard Elm angles (radians). One turn is equal to 360°.
```
Still doesn't explain what "turns" is.
```
Time.inMinutes : Time -> Float
```
So we are converting minutes to radians? How does that work? I can't quite get it. Perhaps there's some time-trigonometry-magic I don't understand. It seems to me that this example code is producing incorrect results.

---

### Exercise 1

> Add a button to pause the clock, turning the Time subscription off.

Added the button that sends `ToggleIsRunning` on click, which is handled by toggling `isRunning` value in the model. Then in `subscriptions` use that as a conditional to turn the subscription and and off:
```
subscriptions model =
  if model.isRunning then
    Time.every Time.second Tick
  else
    Sub.none
```

### Exercise 2

> Make the clock look nicer. Add an hour and minute hand. Etc.

So I think the example seconds hand is actually shown at incorrect angle. I decided to rewrite this a bit using `Date`:

```
second : Time -> Int
second time =
  Date.second (Date.fromTime time)

secondsHandEndCoords : Int -> Int -> Int -> Time -> (Float, Float)
secondsHandEndCoords cx cy r time =
  let
    offset = secondsHandOffset time
  in
    ( toFloat cx + Tuple.first offset * toFloat r
    , toFloat cy + Tuple.second offset * toFloat r
    )

secondsHandOffset : Time -> (Float, Float)
secondsHandOffset time =
  let
    secondsDegrees = 360 / 60 * (toFloat (second time))
    secondsRadians = secondsDegrees * 3.14159265359 / 180
    secondsXOffset = sin(secondsRadians)
    secondsYOffset = cos(secondsRadians) * -1
  in
    (secondsXOffset, secondsYOffset)
```

To be continued tomorrow.
