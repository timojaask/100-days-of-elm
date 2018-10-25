## Day 46

Quick review of day 45:

Deciding on the source of truth is essentially making an agreement (with yourself or a team) where a particular piece of information lives.

Make sure the information comes from one source only. If you have caching layers, make sure the priority of the layers -- which one should be right in case of conflict? When should the cache be updated?

The more restricted cache invalidation is the better -- only one way to set it from only one source.

Try to ensure that impossible data states are impossible to make, by creating data types and abstractions that restrict the usage.

-----------------------------------------------------

Given we have:

```
import Json.Decode exposing (Decoder, field, string, int, bool)

type alias Instructor =
    { name : String
    , courses : Int
    , active : Bool
    }
-- Creates a constructor:
-- <function> : String -> Int -> Bool -> Instructor


-- Json.Decode.field : String -> Decoder a -> Decoder a
```

Decoding three fields from JSON using `map3`:

```
-- Json.Decode.map3 :
--  (a -> b -> c -> val)
--  -> Decoder a
--  -> Decoder b
--  -> Decoder c
--  -> Decoder val

Decode.map3 Instructor
    (field "name" string)
    (field "courses" int)
    (field "active" bool)

-- Returns type `Decoder Instructor` 
```

Decoding three fields from JSON using pipeline types:

```
import Json.Decode.Pipeline exposing (required)

-- Decode.succeed : a -> Decoder a
-- required : String -> Decoder a -> Decoder (a -> b) -> Decoder b

Decode.succeed Instructor
    |> required "name" string
    |> required "courses" int
    |> required "active" bool
```

The obvious advantage of using `Decode.succeed` this way is that we can use N number of fields. So how does this even work?

Let's look at some types:

```
> Instructor
<function> : String -> Int -> Bool -> Instructor

> Decode.succeed
<function> : a -> Decoder a

Decode.succeed Instructor
-- returns: Decoder (String -> Int -> Bool -> Instructor)
```

So does that last decoder even does? Basically all it does is it's going to completely disregard any JSON and will simply always return that function. No matter what string we pass into that decoder, it will ignore it, and give you this function.

And then what? Then we give this weird decoder as a last argument of `require`

```
Decode.succeed Instructor
-- returns: Decoder (String -> Int -> Bool -> Instructor)

> required
<function> : String -> Decoder a -> Decoder (a -> b) -> Decoder b

Decode.succeed Instructor
    |> required "name" string
```

This is the same as saying

```
required "name" string (Decode.succeed Instructor)
```

What requried does, is takes the "name" from JSON, uses `string` decoder to decode it, and if that works, calls the last parameter with the result, so essentially applying the first argument of our Instructor. What we get back is the function that returns `Instructor`, but with the first argument already applied:

```
Decode.succeed Instructor
    |> required "name" string
-- returns: Decoder (Int -> Bool -> Instructor)
```

Now we proceed with adding another `required` this time for `Int`, and once we get an `Int` result, will apply it as the first parameter of a function we just got:

```
Decode.succeed Instructor
-- returns: Decoder (String -> Int -> Bool -> Instructor)

    |> required "name" string
-- returns: Decoder (Int -> Bool -> Instructor)

    |> required "courses" int
-- returns: Decoder (Bool -> Instructor)
```

And this is the same as saying:

```
required "courses" int ( required "name" string ( Decode.succeed Instructor ) )
```

And of course, finally we do:
```
Decode.succeed Instructor
-- returns: Decoder (String -> Int -> Bool -> Instructor)

    |> required "name" string
-- returns: Decoder (Int -> Bool -> Instructor)

    |> required "courses" int
-- returns: Decoder (Bool -> Instructor)

    |> required "active" bool
-- returns: Decoder Instructor
```

So in the end we get `Decoder Instructor`, which we can use to decode JSON strings into `Instructor` records!

As you may notice, the decoder doesn't really care if what you pass it is a constructor function or not. All it cares is that it's a function that takes some arguments, and then you're using `required` to partially apply arguments to that function one at a time.

So it does not have to be a constructor. It can be any regular function that takes some arguments (which will come via decoding) and returns some value -- whatever it may be! You can even use an anonymous function and write the whole logic right there! It just happens to be handy that we can use a constructor right there.

If we wanted to, we could write something (stupid) like:

```
createInstructor : String -> Int -> Bool -> Instructor
createInstructor name courses active =
    Instructor name courses active

Decode.succeed createInstructor
    |> required "name" string
    |> required "courses" int
    |> required "active" bool
```

Yay, so we're using a regular function and partially applying its arguments from `required`. And then that function does whatever (in this case it's producing an `Instructor` record, but it can be anything)

We can do even something weird like:

```
isActiveAndBusyInstructor : String -> Int -> Bool -> Instructor
isActiveAndBusyInstructor name courses active =
    if (active == True) then
        if (courses > 10) then
            True
        else
            False
    else
        False

Decode.succeed isActiveAndBusyInstructor
    |> required "name" string
    |> required "courses" int
    |> required "active" bool
```

This will give us a `Decoder Bool`. Actually, that `name` argument was unused, so we should omit it. Anyway, this is just to get the idea.

