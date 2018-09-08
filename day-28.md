## Day 28

Quick review of day 27:

Yesterday I implemented some of the the basic functionality of "Border Quiz" game. You can now actually play it using all countries. This time I implemented the whole app in one file. There weren't any major issues or questions.

--- 

Today I will continue improving the app structure, clean up some code and implement the area selection functionality and reset.

I think I'll get rid of the "LoadingCountries" state, because I'm not loading them from anywhere now, and I don't know if I will in future, so away it goes!

```
type Model
    = LoadingError String
    | Playing PlayingModel
```

There's still the error case, because loading can fail, theoretically, if the source data is empty.

I don't like particularly one piece of code that I wrote:

```
initQuiz : List Country -> Maybe Quiz
initQuiz countriesList =
    let
        result =
            ( List.head countriesList, List.tail countriesList )
    in
    case result of
        ( Nothing, _ ) ->
            Nothing

        ( _, Nothing ) ->
            Nothing

        ( Just first, Just rest ) ->
            Just (Quiz [] first rest [] first.neighbors)
```

I simply want to split the list into first element and the rest, but I have to write this big thing. I was thinking if there's a better way. I found that instead of `List.tail` I could use `List.drop`. This way the code becomes significantly simpler:

```
initQuiz : List Country -> Maybe Quiz
initQuiz countriesList =
    case List.head countriesList of
        Nothing ->
            Nothing

        Just first ->
            Just (Quiz [] first (List.drop 1 countriesList) [] first.neighbors)
```

While looking at the [`List` API](https://package.elm-lang.org/packages/elm/core/latest/List), I found an interesting note below `isEmpty`, `head`, and `tail` functions:

> **Note**: It is usually preferable to use a `case` to deconstruct a `List` because it gives you `(x :: xs)` and you can work with both subparts.

Unfortunately it didn't come with any examples, so I googled and found the following:

```
listDescription : List String -> String
listDescription list =
 case list of
    [] -> "Nothing here !"
    [_] -> "This list has one element"
    [a,b] -> "Wow we have 2 elements: " ++ a ++ " and " ++ b
    a::b::_ -> "A huge list !, The first 2 are: " ++ a ++ " and " ++ b
```

So we can `case` over a `List`. In `initQuiz` I could use such construct, probably like so:

```
initQuiz : List Country -> Maybe Quiz
initQuiz countriesList =
    case countriesList of
        [] ->
            Nothing

        first :: rest ->
            Just (Quiz [] first rest [] first.neighbors)
```

This does indeed look a bit cleaner, so I'll use it. There was another case of `head` and `tail`, so I cleaned it up in the same fashion.

I also reduced some code a bit by moving maybes like this:

```
    let
        maybeQuiz =
            initQuiz countries
    in
    case maybeQuiz of
```

straight into the `case ... of` like this:

```
    case initQuiz countries of
```

I think this is an improvement. There wes at least one more case like this.

I also split the huge `update` function to smaller logical pieces, which made the code more readable, I believe.

Then, I wanted to tackle the ungly looking `countryIdsToNames` function:

```
countryIdsToNames : List Int -> String
countryIdsToNames idList =
    List.foldl
        (\id ->
            \acc ->
                acc
                    ++ (if String.isEmpty acc then
                            ""

                        else
                            ", "
                       )
                    ++ countryFirstNameById id
        )
        ""
        idList
```

Not pretty. Good thing about this implementation is that we iterate over the list of IDs only once. However, if we're willing to forego some performance for the sake of readability, we could use one of the following options:

Using the `>>` function composition:

```
countryIdsToNames : List Int -> String
countryIdsToNames =
    List.map countryFirstNameById
        >> List.intersperse ", "
        >> String.concat
```

Using the `<<` function composition:

```
countryIdsToNames : List Int -> String
countryIdsToNames =
    String.concat
        << List.intersperse ", "
        << List.map countryFirstNameById
```

Using the `|>` pipe operator:

```
countryIdsToNames : List Int -> String
countryIdsToNames idList =
    idList
        |> List.map countryFirstNameById
        |> List.intersperse ", "
        |> String.concat
```


Using the `<|` pipe operator:

```
countryIdsToNames : List Int -> String
countryIdsToNames idList =
    String.concat <| List.intersperse ", " <| List.map countryFirstNameById idList
```

Now the downside of all of these is that we iterate of the list three times. Even worse, `concat` iterates over a longer list, because of items added in between each existing item. However, that shouldn't be any problem in our use case, where the lists are maximum 10 items long, I believe. I personally like the `>>` function composition version, so I'll stick with that.

By the way, this probably marks one of the first time I'm deliberately creating a point-free style function!