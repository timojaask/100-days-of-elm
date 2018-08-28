## Day 17

Quick review of day 16:

Was writing a 3D engine, until I stumbled upon a [library](https://github.com/kfish/quaternion) that I needed that wasn't compatible with Elm 0.19, so I tried to upgrade it myself, but was not able to run the tests to verify that the upgrade works. Posted an [issue](https://github.com/kfish/quaternion/issues/2) on the github page of the library.

Then I started scanning through the [official Elm guide](https://guide.elm-lang.org) and try to spot what's new since 0.19, and update the code samples that I wrote during the previous days. So far I updated [buttons](./user-input/buttons.elm) and [text input](./user-input/text-input.elm) examples.

---

Next up, [forms](./user-input/forms.elm). First change `Html.beginnerProgram` to `Browser.sandbox`.

Another thing changed in the example is the author factored out the `input` element into a convenience function. This is probably because they also added the default value attribute, resulting in a too large of a line.

Next, I used the [elm/regex](https://package.elm-lang.org/packages/elm/regex/latest/) package to do some of the exercises, and it has changed significantly in the last release. Now creating a Regex from string returns a `Maybe Regex`, so to make the same code work, we need to check for maybes. Also, the Regex docs say that it would be better to use something like [elm/parser](https://package.elm-lang.org/packages/elm/parser/latest) instead of Regex. I quickly read its readme, looks interesting and a bit alient at the same time. Perhaps I could dedicate one day on learning it. For not I'll just attempt fixing the Regex.

And finally, the Html [style attribute](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#style) has changed. Style doesn't take a list of tuples anymore. Now it just takes two strings, one is the attribute name, and another is the attribute value. So if you want to pass miltiple style attributes, you have to write multiple `style`s. I must say it does result in a cheaner code this way.

Before:
```
div
  [ style
    [ ( "color", color )
    , ( "display", display )
    ]
  ]
  [ text message ]
```
After:
```
div
  [ style "color" color
  , style "display" display
  ]
  [ text message ]
```

---

Next up [random example](./effects/random.elm). Here we're replacing `Html.program` with the new `Browser.element`.

The `init` has changed from:
```
init : ( Model, Cmd Msg )
```
to:
```
init : () -> (Model, Cmd Msg)
```
Apparently, the function format is useful when taking flags from JavaScript. In this case, we are declaring that we're not looking for any flags, hence, no function parameters.

I also had to replace a few instances of `Basics.toString` with `String.fromInt`.

---

Next up, [time](./user-input/time.elm). First change `Html.program` to `Browser.element`, and change `init` to function.

This updated chapter goes more in depth about time. There are three important concepts here:
- "Human time" -- is the time we use in our daily live, which is dependent on our location, time of year, etc. It's the "16:40", which doesn't actually tell us the exact time, because we don't know which time zone it is, or if it's DST time or not. We would not want to use this as our time source in our applications. Only for displaying time in the user interface, but never in logic.
- "POSIX time" -- is the seconds since epoch. It's the same no matter where in the world you are and what time of year it is. This time we use as our application logic, and I guess never display to users.
- "Time zones" -- a database of data that we can use to convert POSIX time to Human time. It's pretty complicated, and it's not just `UTC-7` or `UTC+3`. There are DST changes, and also it changes a bunch of times when countries deside to change their time zones, etc.

To show Human time, we must know POSIX time and a Time zone. 

The model in the guide example has changed completely. It used to contain just `Time`, now, it contains:
```
type alias Model =
  { zone : Time.Zone
  , time : Time.Posix
  }
```
So we're gonna update our model and the init function accordingly.

In the `init` function, also the initial command has been changed from `Cmd.none` to `Task.perform AdjustTimeZone Time.here` What this does is performs the `Time.here` task and returns the response with a `AdjustTimeZone` message to our `update` function. The `Time.here` task produces a `Zone` based on current UTC offset. It gives things such as `Etc/GMT+0` or `Etc/GMT-6`, however, due to limitations of JavaScript time API, it cannot give time zones such as `America/New_York`, so it will not work if you keep the application open as DST changes or use it on historical data.

Since `AdjustTimeZone` message is mentioned, we need to actually add it to our `Msg` type, and then handle it anywhere, where we switch over `Msg`.

In `subscriptions` `Time.every` used to take `Time.second` as a parameter. Now it takes a `Float` representing milliseconds, which is perhaps a bit clearer.

When actually displaying time, the conversion of time values is now happening like this:
```
hour = String.fromInt (Time.toHour model.zone model.time)
minute = String.fromInt (Time.toMinute model.zone model.time)
second = String.fromInt (Time.toSecond model.zone model.time)
```

So we will use this instead of the old functions.

Finally, replacing all the `Basics.toString` with `String.fromFloat` and `String.fromInt`.

---

Next up [http.elm](./effects/http.elm). First change `Html.program` to `Browser.element`, and change `init` to function.

Interestingly, the new example decided to combine `NewGif (Ok newUrl)` and `NewGif (Err err)` cases, and have it split at the next level, like this:
```
NewGif result ->
  case result of
    Ok newUrl ->
      ( { model | url = newUrl }
      , Cmd.none
      )

    Err _ ->
      ( model
      , Cmd.none
      )
```

I guess I like this new approach, because it groups the logic nicely.

It also introduces a way to compose URLs programmatically (instead of coding by hand):
```
Url.Builder.crossOrigin "https://api.giphy.com" ["v1","gifs","random"]
  [ Url.Builder.string "api_key" "dc6zaTOxFJmzC"
  , Url.Builder.string "tag" topic
  ]
```

This seems like a better way than doing it by hand. Especially since `Url.Builder.string` is automatically escaping characters, which saves some work.

The new version of book decodes a nested JSON field by nesting the `field` function:
```
Decode.field "data" (Decode.field "image_url" Decode.string)
```
Where as previously it would use `at` function:
```
Decode.at ["data", "image_url"] Decode.string
```

I don't know which way is better. The `at` function is more concise, perhaps.

---

Next, I wanted to see if I can style the `body` element using the new `Browser.document` package. TLDR -- no, you can't. The longer answer is: all you get in addition to the `Browser.element` package is the ability to set the title of the page, and the fact that you are not writing directly into the `body` tag. But you can't change attributes of the `body` tag.

There is (was?) a way of setting `body` style when using `elm-css`: https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/Css-Foreign#body but unfortunately `elm-css` is not yet officially compatible with Elm 0.19.