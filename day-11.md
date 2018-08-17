## Day 11

Quick review of day 10:

Yesterday I wrote [some code](./errors-tasks/task.elm) that uses tasks. Used tasks to chain `Time.now` and `Http.post`.

Also practiced a little bit how endcoding and decoding JSON objects works. Will go deeper into JSON today.

---

Next chapter: [JSON](https://guide.elm-lang.org/interop/json.html)

Decoding simple values works like so:
```
> import Json.Decode exposing (..)

> decodeString int "42"
Ok 42 : Result String Int

> decodeString int "true"
Err "Expecting an Int but instead got: true" : Result String Int
```

To decode lists, we can use the `list` function that would return a list decoder of a given value:
```
list : Decoder a -> Decoder (List a)
```

For exmple:

```
> int
<decoder> : Decoder Int

> list int
<decoder> : Decoder (List Int)

> decodeString (list int) "[1, 2, 3]"
Ok [1,2,3] : Result String (List Int)

> decodeString (list string) """["hi", "yo"]"""
Ok ["hi", "yo"] : Result String (List String)

> decodeString (list (list int)) "[ [0], [1,2,3], [4,5] ]"
Ok [[0],[1,2,3],[4,5]] : Result String (List (List Int))
```

For decoding object you can use `field` function:
```
> field "x" int
<decoder> : Decoder Int

> decodeString (field "x" int) """{ "x": 3, "y": 4 }"""
> Ok 3 : Result String Int
```

In the example above, we're telling field that we want to decode a field named "x" and that it should use and integer decoder for that.

To decode multiple fields, or an entire multi-field object, we can use `map2`, `map3`, `map4`, etc:

```
> type alias Point = { x : Int, y : Int }

> Point
<function> : Int -> Int -> Point

> pointDecoder = map2 Point (field "x" int) (field "y" int)
<decoder> : Decoder Point

> decodeString pointDecoder """{ "x": 3, "y": 4 }"""
Ok { x = 3, y = 4 } : Result String Point
```

And finally, there's a helper library that can be used for decoding complex JSON, called [elm-decode-pipeline](http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/latest):
```
import Json.Decode exposing (Decoder, int)
import Json.Decode.Pipeline exposing (decode, required)

type alias Point = { x : Int, y : Int }

pointDecoder : Decoder Point
pointDecoder =
  decode Point
    |> required "x" int
    |> required "y" int
```

---

Quickly read through [JavaScript Interop chapter](https://guide.elm-lang.org/interop/javascript.html), but decided not to go too deep into it yet, as the main purpose of this 100-day project is to learn as much Elm as possible. Will likely need to use JS at some point though, so I'll return to the chapter then.

---

Moving on to Scaling The Elm Architecture chapters, starting with [Labeled Checkboxes example](https://guide.elm-lang.org/reuse/checkboxes.html). See the code at [checkboxes.elm](./scaling/checkboxes.elm).

So the checkbox example just shows how to break the `view` function into smaller pieces. Nothing new here really. Moving on to [Radio Buttons example](https://guide.elm-lang.org/reuse/radio_buttons.html). See the code at [radiobuttons.elm](./scaling/radiobuttons.elm).

Ok, so there isn't anything new in the radiobuttons example either. Just more factoring out code into functions. The writer suggest some rules of thumb on when to factor code out and when not. Such as "if it's just one radio button, don't factor out!". He's not wrong. "It's always easy to refactor Elm code later." -- that's nice to hear. Probably true.

---

Next chapter is going to be about modules, and that will come handy in large programs (e.g. real world). Will learn about that tomorrow.