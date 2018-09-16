## Day 36

Quick review of day 35:

Yesterday I realized that I can't try to escape maybes forever. We just have to learn to live with some of them.

Then I wanted to see how other people deal with complex `update` functions, because when the number of messages grows and the number of app states grows, you have inevitably some complexity there. One example was Robert Feldman's [elm-spa-example](https://github.com/rtfeldman/elm-spa-example/blob/master/src/Main.elm), where he decided to put both message and model in the same case expression: `case ( msg, model ) of`. Then he'd handle all the valid cases, and ignore the rest with `( _, _ ) -> ...`.

Then I tried to implement this approach in my application and it worked for some cases, didn't work so well for another. Particularly the restart case was nasty, because it's identical for both `Playing` and `Finished` state, but has to be handled twice.

---

Today I'll continue figuring out how can I improve my Elm code.

Now I'm thinking that perhaps it is fine that Restart is handled separately for Playing and Finished. Right now the two states are the same, but who knows maybe in future they'll be different and then I have to split them anyway.

I've been reading some other people's code and I noticed the same modular approach used in their apps as the `elm-spa-example`. The approach is to have the model and messages split by SPA page, like in [this example](https://github.com/rundis/albums/blob/master/frontend/src/Main.elm).

---

After modifying the `update` function to use `case ( msg, model ) of`, and some other small adjustments, the code actually looks pretty good. I feel like the only a bit hairy part of code left are the `updateWithAnswer` and `updateWithCorrectAnswer` functions.

Let's try to intoduce the list shuffling. The `shuffle` function returns a Random.Generator. I could write something like this:

```
filterAndShuffle : Int -> NonEmptyList Country -> Maybe (Random.Generator (List Country))
filterAndShuffle setId countryList =
    let
        maybeFilteredList =
            NonEmptyList.filter
                (\country ->
                    List.any (\id -> id == setId) country.continents
                )
                countryList
    in
    case maybeFilteredList of
        Nothing ->
            Nothing

        Just filteredList ->
            Just (shuffle (NonEmptyList.toList filteredList))
```

Now I need to introduce a `Loading` state to this application. This is going to be the state right after init, or right after user pressed reset, and we send a task with the generator to Elm runtime. Then, once the task is done and we get a shuffled list back, we can proceed to initializing our game state and either failing, or moving to Playing state.

Will get back to this tomorrow.