## Day 2

Quick review of Day 1:
Functions:

```
-- addOne : number -> number
addOne x = x + 1

addOne 3

-- multiply : number -> number -> number
multiply a b = a * b
```

Conditionals:

```
-- oldEnough : number -> Bool
oldEnough age = if age >= 18 then True else False
```

Lists and strings:

```
numbers = [3, 2, 1]
List.map addOne numbers
List.sort numbers
String.length "hello"
```

Records:

```
city = { name = "Helsinki", country = "Finland" }
city.name
.country city

sayHello { name } = "Hello, " ++ name ++ "!"
sayHello city
sayHello { name = "Bob", age = 35 }

anotherCity = { city | name = "Turku" }
yetAnotherCity = { city | name = "New York", country = "US" }
```

Start reading The Elm Architecture: https://guide.elm-lang.org/architecture/

### The Elm Architecture

The three main parts of every Elm program:
- Model: The state of the application
- Update: A way to update the state
- View: A way to view the state

A skeleton for a typical Elm app can be made like so:

```
import Html exposing (..)

-- MODEL
type alias Model = { ... }


-- UPDATE
type Msg = Reset | ...

update : Msg -> Model -> Model
update msg model =
  case msg of
    Reset -> ...
    ...

-- VIEW
view : Model -> Html Msg
view model =
  ...
```

One way to begin writing an Elm app is to try to make a model. First example of this is in [buttons.elm](./user-input/buttons.elm). Since it's a increment/decrement counter, the model is most likely going to need an integer. In this case, it's the simplest kind of model:

```
type alias Model = Int
```

Then we'd need to update the model somehow. Since the counter needs to be incremented and decremented, these are the two actions, or messages as they say in Elm, that we need:

```
type Msg = Increment | Decrement
```

Each time a message is passed it's going to be handled by an `update` function, which takes the message and the model as parameters and returns a (new) model:

```
update msg model =
  case msg of
    Increment ->
      model + 1
    Decrement ->
      model - 1
```

And finally, all of this needs to be rendered for users to see and interact with. This is where `view` function comes in, which takes Model as a parameter and returns HTML that can produce messages, which will be handled by the `update` function. HTML are creating using Elm functions of the same name, which take a list of attributes as a first parameter and a list of child elements as a second parameter, like so:

```
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (toString model) ]
    , button [ onClick Increment ] [ text "+" ]
    ]
```

For example, we want to render a button, with "-" title and an onClick attribute that triggers `Decrement` message, we just call a `button` function with a list of attributes and child elements, in this case: `button [ onClick Decrement ] [ text "-" ]`.

----

On another note, this just in:
```
Error: The description in elm-package.json is not valid.

Error in $: Problem with the "repository" field.

Package names must start with a letter.
```

So it seems I can't use "100-days-of-elm" as a name, because it cannot start with a number. Bloody hell? Renamed the "summary" and "repository" values, because they don't matter anyway, unless I want to publish a package, which I don't. After this, I got some other errors, which went away after some fiddling around. No idea why, but it works finally. Great, we can now move on with our lives.

---

This concludes the day two. I was hoping to get done a little bit more, but errors happened, life goes on. Coming back tomorrow!