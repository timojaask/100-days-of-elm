## Day 6

Quick review of day 5:

`Http.send` is used in Elm to send HTTP requests. It takes two parameters, the result message (for handling in `update`, looking like `FetchedCatGifs (Result Http.Error String)`) and an `Http.Request`. As with other commands, Elm does the actualy work, our application just sends this command and then handles the response, either success or error.

You can make various custom requests (see the [Http package docs](http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http)), but the one used yesterday is `Http.get`. Takes a URL, and a [`Json.Decode.Decoder`](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode). Decoder is used to parse the response data, in case the response is successful.

Besides the decoder, the result is handled in the `update` function:
```
    NewGif (Ok newUrl) ->
      ({ model | gifUrl = newUrl }, Cmd.none)

    NewGif (Err err) ->
      ({ model | errorMessage = errorToString err }, Cmd.none)
```
The error can be any of the following:
```
type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus (Response String)
    | BadPayload String (Response String)
```

Also learned an interesting thing about the usage of HTML select and option tags. They don't have any kind of "onChange" handler in Elm. Instead you can use `onInput`.

Subscriptions were introduced by subscribing to timer tick even. Subscribing and unsubscribing is very easy:
```
subscriptions : Model -> Sub Msg
subscriptions model =
  if model.isRunning then
    Time.every Time.second Tick
  else
    Sub.none
```
In this case `Tick` is the message that the `update` function is going to receive every second.

Also learned about `Date`, which you can use to parse `Time` (getting date and time components).

---

### Exercise 2 (continued)

Here's what needs to be done again:
> Make the clock look nicer. Add an hour and minute hand. Etc.

The code is at: [time.elm](./effects/time.elm).

Let's get hours and minutes figured out before moving on to visual stuff.

Let's have functions to get time components: `hour`, `minute`, and `second`.

Then make a function to get hand direction. Made three functions: `secondHandCoord`, `minuteHandCoord`, and `hourHandCoord` to get the end coordinate of each hand.

For Sunday's sake I made a version of something that resembles a [Swiss railway clock](https://en.wikipedia.org/wiki/Swiss_railway_clock). See [time.elm](./effects/time.elm). Could make it look 100% like the original, but maybe there's no time for that right now.

---

Moving on to web sockets. [web-sockets.elm](./effects/web-sockets.elm)

So the git book has an error: the websocket URL is supposed to start with `wss`, not `ws` as it is in the book. The full source code example is correct, however.

There is nothing really new in this chapter in terms of language features. We're just using a different library now. Still sending commands to Elm runtime and subscribing to messages.