## Day 35

Quick review of day 34:

Yesterday I was just trying to figure out how to get rid of some Maybes. Then I decided that it's a waste of time, and instead of trying to hide them, I should try to deal with them better.

---

I was tryint to figure out how to make it impossible to have a message in update that should not be there on a given application state. Like, we can't have `AnswerInputFormSubmitted` message in `update`, when our application state is `LoadingError`. But then I thought that, of course, this is not guaranteed. There can be a race condition, where an error occurred, but before it was processed by `update`, user clicked submitted the form, so now, first the error will be processed and state changed to `LoadingError`, then the `AnswerInputFormSubmitted` will arrive to `update`, when our state is already at error. This proves that we indeed can have conflicting message and state.

So I wanted to see how do other people deal with this mess. I checked how this is done in Robert Feldman's [elm-spa-example](https://github.com/rtfeldman/elm-spa-example/blob/master/src/Main.elm), and it's quite interesting. First of all, he's not tryign to fight the fact that we can have messages that don't belong to a certain context. So what he does instead, is handle messages and state in the same `case .. of`:

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ... MANY CASES IN BETWEEN ...

        ( GotSettingsMsg subMsg, Settings settings ) ->
            Settings.update subMsg settings
                |> updateWith Settings GotSettingsMsg model

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )
```

This looks pretty handy! I could adopt the same way, so I don't have have to bother with having two or more cases.

The problem I have with this is that the compiler will not warn me if I miss a case, because we're handling *the rest* of the cases with `( _, _ )`, which essentially means "I don't care what else is there, just ignore it". So if I add a new state, and forgot to handle it here, it will be just silently ignored.

But then again, we don't really have any good options here. Since we can't do anything about the possibility of having wrong message in the wrong state, we must handle them all. But as the number of different states and messages grow withing the application, it will eventually become impossible to explicitely handle all the impossible messages. So a tradeoff here is to just ignore the rest, like in the example above, making our code simpler, but allowing the possibility to forget to include a case.

So I tried to implement this, and it works well for some of my cases, and doesn't work so well for some other. For example, handling restart now requires two cases, even thought they are absolutely identical:

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of

        ...

        ( Restart, Playing playingModel ) ->
            ( initWithCountrySet (SelectedItemList.selectedItem playingModel.countrySets) playingModel.countrySets, Cmd.none )

        ( Restart, Finished playingModel ) ->
            ( initWithCountrySet (SelectedItemList.selectedItem playingModel.countrySets) playingModel.countrySets, Cmd.none )

        ...
```

If there's a way to combine these two into one -- that would be great. But I don't know how.

Unfortunately that's all the time I have for today. Continue tomorrow.

