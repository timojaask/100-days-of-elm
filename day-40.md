## Day 40

Quick review of day 39:

Yesterday I continued watching Elm workshop from Frontend Masters.

Interesting bits:

- Code smell when you have two function arguments of the same type one after another: `viewTag -> String -> String -> Html Msg`. It's easy to mix them up without compiler knowing. Alternative is to use a record holding both, but then you miss out on partial application. Tradeoffs.
- What used to be called "union types" in Elm < v0.19, is now called "custom types".
- When creating custom types, you actually create a whole new type and define what kind of values can it have. Where `String` can have an unlimited number of different values, your custom types can be as limited as you want, which is great and compiler enforced.
- The defined values in custom types are called "variants".
- The variant that takes parameters is actually a function, which returns a value of the custom type -- this is important to repeat -- it's not a value, it's a function that returns a value. This distinction makes things clear.
- A custom type as a parameter of another custom type might seem confusing, but in reality it's the same thing -- `type Msg = Rest | RunningMsg RunningMsg` -- here the first `RunningMsg` is a function `<function> : RunningMsg -> Msg`. It takes a parameter of type `RunningMsg`, which should be defined somewhere in the code too. Even though two different things have the same name, the Elm compiler is okay with that.
- Type variables allow us to define "generic" types, such as `List item` or `Html msg` -- notice that the type variable always starts with a lowercase letter, while concrete types always start with a capital letter. Variable type means you can use any type in place of it.

---

Today I'm continuing watching the workshop.

### Decoding JSON

Say we expect a JSON:

```
{
    "user_id": 27,
    "first_name": "Al",
    "last_name": "Kai"
}
```

And we want to parse it into an Elm record:

```
type alias User =
    { id : Int
    , firstName : String
    , lastName : String
    }
```

We could do it like this:

```
-- assuming imports from Json.Decode, including Decoder, required, int, and string
user : Decoder User
user =
    Json.Decode.succeed User
        |> required "user_id" int
        |> required "first_name" string
        |> required "last_name" string
```

What's happening here?

- `Json.Decode.succeed` is a function taking a function as an argument, in this case the function is `User` constructor, which in turn takes three arguments.
- The previous is being passed to `required` function, as a last argument. `required` parses JSON for `"user_id"` integer and gives it as the first parameter to `User`.
- The previous is being passed to the next `required`, which in turn parses `"first_name"` and passes it as a second parameter to `User`.
- The previous is again being passed to the last `required`, which in turn parses `"last_name"` and passes the resutl as the last parameter to `User`.
- This happens as long as each parsing is successful. Else, we bail.

Good thing to notice here is that for each `required` field we pass in a `Decoder`, such as `int`, `string`, or any of our custom decoders, such as the one we just created named `user`. This is great, because you can decode nested object structures, such as:

```
machine : Decoder Machine
machine =
    Json.Decode.succeed Machine
        |> required "name" string
        |> required "user" user
```

Or:

```
users : Decoder (List User)
users =
    list user
```

In the latter example `list` is a function that takes a decoder as an argument, in this case the `user` decoder which knows how to decode a `User` record from JSON, and returns a decoder that can decode a list of users.

What about `null` values in JSON or missing fields? If you want to make these options possible without generating an error, then you can use `(nullable string)` decoder for `null` values, which returns a `Maybe String`, or `optional`, which checks for existance of field, and if doesn't exists uses the default value. You can also combine the two having an optional nullable decoder:

```
user : Decoder User
user =
    Json.Decode.succeed User
        |> required "user_id" int
        |> required "name" (nullable string)
        |> optional "email" string "me@foo.com"
        |> optional "phone" (nullable string) Nothing -- check this syntax, I'm not sure right now
```

### Destructuring tuples and records

In tuples the only way to distinguish items is order (first, second, third). So when destructuring, we only care that the order is correct:

```
let
    (name, x, y) = ("bob", 5, 10)
in
("The name is " ++ name ++ ", and the coordinates are: " ++ (String.fromInt x) ++ ", " ++ (String.fromInt y))
```

So above, we're just giving names to first, second, and third item of a tuple. Can also do:

```
let
    someTuple = ("bob", 5, 10)
    (name, x, y) = someTuple
in
("The name is " ++ name ++ ", and the coordinates are: " ++ (String.fromInt x) ++ ", " ++ (String.fromInt y))
```

In records, the order of fields does not matter, so we cannot access them by order. Instead we access them by name. For example:

```
let
    { y, name, x } = { name = "bob", x = 5, y = 10 }
in
("The name is " ++ name ++ ", and the coordinates are: " ++ (String.fromInt x) ++ ", " ++ (String.fromInt y))
```

---

### Sending HTTP requests

Just a quick example of sending a POST request:

```
type Msg
    = BlaBlaBla
    | CompletedRegister (Result Http.Error Viewer)
    | BlahBlahBlah

update msg model =
    case msg of
        SubmittedForm ->
            let
                requestBody : Http.Body
                requestBody =
                    encodeJsonBody model.form

                responseDecoder : Decoder Viewer
                responseDecoder =
                    Decode.field "user" Viewer.decoder

                request : Http.Request Viewer
                request =
                    Http.post "/api/users" requestBody responseDecoder

                cmd : Cmd Msg
                cmd =
                    Http.send CompletedRegister request
            in
            ( model, cmd )
```

Or we could use a pipe operator:

```
                cmd : Cmd Msg
                cmd =
                    Http.post "/api/users" requestBody responseDecoder
                        |> Http.send CompletedRegister
```

