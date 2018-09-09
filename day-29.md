## Day 29

Quick review of day 28:

Yesterday I simplified the top-level model a lot, because I was prematurely over-engineering it.

Then I was wondering how can I make List splitting easier. I needed to get a head and a tail of a list, but since both `List.head` and `List.tail` functions return `Maybe`, I wrote a pretty ugly looking code handling three cases. On my first improvement try, insted of `List.tail` I used `List.drop 1`, which doens't return a `Maybe`, so my number of cases dropped to just two. Then I learned that I can use `case ... of` directly on a list, and split it that way. So in the end I was farily happy with my last version:

```
initQuiz : List Country -> Maybe Quiz
initQuiz countriesList =
    case countriesList of
        [] ->
            Nothing
        
        first :: rest ->
            Just (Quiz [] first rest [] first.neighbors)
```

I also cleaned up code which was using `let` expressions a perhaps unnecessarily. So I went from doing:

```
    let
        maybeQuiz =
            initQuiz countries
    in
    case maybeQuiz of
```

to:

```
    case initQuiz countries of
```

Then I learned about function composition and piping in Elm. I had a nested function like this:

```
countryIdsToNames : List Int -> String
countryIdsToNames = countryIds
    String.concat (List.intersperse ", " (List.map countryFirstNameById countryIds))
```

There are a couple of ways to improve the style of this code. We can use function composition operators `<<` or `>>`. This is the equivalent of `compose` and `pipe` in Ramda, if you're familiar with that. This allows you to write point-free style functions. Here's an example:

```
countryIdsToNames : List Int -> String
countryIdsToNames =
    List.map countryFirstNameById
        >> List.intersperse ", "
        >> String.concat
```

Another way is to use Elm's forward `|>` and backward `<|` pipe operators. As far as I understand, these do not allow you to write point-free style and are the preferred way in the Elm community (based on exactly one person's opinion!) Anyway, they work sort of like function composition, but you have to pass the value:

```
countryIdsToNames : List Int -> String
countryIdsToNames idList =
    idList
        |> List.map countryFirstNameById
        |> List.intersperse ", "
        |> String.concat
```

I asked on Elm Slack channel which way is preferred, and someone responded that using Elm's pipe operators is more common in Elm, because reasons (more readable was mentioned). I guess there's a place for both, and each case has to be judged separately.

I also refactored a bunch of code, breaking down the big and scary `update` function.

---

Today I'm going to continue going through the code I wrote and see what I can improve.

So I did some small clean-up, nothing fancy. Now I want to make the "Restart" button work. Doing that was pretty simple. Just add a new `Msg` called `Restart`. Add `onClick Restart` to the restart button in the UI. Handle the message in `update` by initializing a new model of the game.

Next, I want to make the continent dropdown box work. I renamed `continents` list to `countrySets`, removed "Antarctica" and added "All". First, I added a function that would filter a list of coutries given a `CountrySet`: 

```
countriesBySet : List Country -> CountrySet -> List Country
countriesBySet allCountries countrySet =
    if countrySet.id == allCountriesSetId then
        allCountries

    else
        List.filter
            (\country ->
                List.any
                    (\continentId -> continentId == countrySet.id)
                    country.continents
            )
            allCountries


allCountriesSetId =
    999


countrySets : List CountrySet
countrySets =
    [ CountrySet allCountriesSetId "All"
    , CountrySet 0 "Asia"
    , CountrySet 1 "Africa"
    , CountrySet 3 "Oceania"
    , CountrySet 4 "Europe"
    , CountrySet 5 "North America"
    , CountrySet 6 "South America"
    ]
```

Then I had to add a handler for when the value of the select tag changes. This is unfortunately incampatible with Internet Explorer, but it's the sanest way to go:

```
select [ onInput SetSelectedCountrySet ]
            viewCountrySetOptions
```

In the `update` function, I'd handle `SetSelectedCountrySet` by just saving the value into the model for later use.

Then, when user clicks on the Restart button, in the `update` I'd restart the game by passing it a filtered country list, instead of just all countries:

```
Restart ->
    initGameWithCountries (countriesBySetName countries playingModel.selectedSetName)
```

The game is almost complete. I think there's one more thing left -- show something when the game is over. I'll just add another piece to the `Model` type:

```
type Model
    = LoadingError String
    | Playing PlayingModel
    | Finished PlayingModel
```

Now I had to do some funny tricks inside the `update` function, like this:

```
update : Msg -> Model -> Model
update msg model =
    let
        maybePlayingModel =
            case model of
                LoadingError _ ->
                    Nothing

                Playing playingModel ->
                    Just playingModel

                Finished playingModel ->
                    Just playingModel
    in
    case maybePlayingModel of
        Nothing ->
            model

        Just playingModel ->
            case msg of

            ...
```

But that seems ok so far. Then I had to change the return value of some `update` functions to include a `gameOver` parameter. It became a bit uglier, but still works. And finally, the `view` is handling the `Finished` case, so it shows a "You won!" message in the end of the game.

However, there's a bug, where if I win the game, then restart, it will show an error message.

Will have to deal with that tomorrow.