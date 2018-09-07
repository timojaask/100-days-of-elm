## Day 27

Quick review of day 26:

Yesterday I started modelling a "Border Quiz" -- a game where a player must name all the bordering countries of a given country.

I was going though different options for representing the source material for the game -- essentially a list of countries, with information such as: which continents they belong to, what are the possible accepted names and spellings for this country, who are the neighbors.

Eventually the data structure was shaped by the fact that a country can belong to multiple continents, it might have multiple accepted names, and multiple neighbors.

Then I have ported a full list of countries from an old JavaScript version of the game that I wrote years ago, to Elm.

---

What data structures do I need for this game? Let's think from the highest level. 

Does this game need loading? With the current setup, I don't think so. So we can skip loading phase.

Does this game need to show a menu before starting a game? Probably not now. We can jump straight into a game. I think a menu would options to start another game could be visible at all times.

Does this game need to save previous progress though? That could actually be a very useful feature, because one game can last a while. That means we need to fetch a saved game data from some external resource. So we do need loading, at least eventually. I think the game should try to load previously unfinished game, and if none found, start a new game.

Based on this, the top-level model could look like this:

```
type Model
    = Loading
    | Loaded AppState
```

What does the app state need? Here's the "UI" of the game again:

```
-------------------------

Neighbours of Germany:
[ input text: answer ]
( 2 / 9 ) France, Belgium
Overall progress: 0 / 48

[ button: Restart ]
[ input combo: areas ]

-------------------------
```

```
- List of countries to be played
- Current country being played
- List of countries already played

- List of neighbors to be guessed
- List of neighbors already guessed

- List of country sets to select from
```

I think that should cover it for now, at least regarding the game logic data structure. We might still need to keep that UI related state, but let's not get into that yet.

I have realized that list of "continents" is not the best way to represent the sets of countries to be played. Because, one of the options should be "All", and that's not a continent, so naming the list "continents" would be already wrong. And who knows, maybe I'll want to break some large continent down to smaller parts to make the game easier. So it shall be named "country set".

---

Let's work on representing a list of countries to be played / playing / already played. One way to represent is to have one list and then have a pointer to the current country ID:

```
currentCountryId : Int
countries : List Country
```

But this way we can easily create an invalid state, where the `currentCountryId` is set to some ID that doesn't exist in the `countries` list. It seems a better idea to represent it as three items:

```
type alias Quiz =
    { playedCountries : List Country
    , currentCountry : Country
    , nextCountries : List Country
    , neighborsGuessed : List Int
    , neighborsLeft : List Int
    }

initQuiz : Country -> List Country -> Quiz
initQuiz firstCountry nextCountries =
    Quiz [] firstCountry nextCountries [] firstCountry.neighbors
```

This way, when we initialize the data, we must provide at least current country, there's no way to make this thing empty.

Now there's still a way to make this state making no sense: if the country has no neighbors. If it has no neighbors, then we can't play it! Not sure how to fix it right now.

---

So I've worked mostly on the UI of the game, as that's where most of the work lies. You can see the [source code](./src/data-structures/BorderQuiz/Main.elm) for implementation. The basic gameplay is functional, but the restart functionality hasn't yet been implemented, and I haven't actually tried to "win" the game.

Will be back tomorrow with do finish implementation and clean up.