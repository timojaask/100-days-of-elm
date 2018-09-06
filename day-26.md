## Day 26

Quick review of day 25:

Yesterday I got cold, and felt too lazy to do a review of day 24. So I'll start by going back to [day-25.md](./day-25.md) and do it now.

Okay, with that out of the way, let's review day 25:

Yesterday I put the Tic-Tac-Toe game aside and decided to make a pomodoro timer. It was more straight forward and enjoyable to model than the game. The rules for the timer were quite simple and it was not too difficult to model them, however, I still ended up with a lot of code!

I learned how I can restrict integers to a certain range, so that it would be impossible to have an invalid value. There are a few options to handle invalid entries:

A. Just clamp the value to the allowed range.

B. Retrun a `Maybe`, and if the value is invalid, return `Nothing`.

C. Return a `Result` or similar, with messages explaining failure reason.

Each of these options has its own advantages and disadvantages, and should be considered for each application separately. For keeping the number of pomodoros completed I decided to go with A. However, for settings I went with A at first, but now I think that when I actually implement it, I'd probably go for B or C.

One Elm feature that I used appropriately here is hiding type constructor. So the PomodoroTimer is a union type with only one constructor, which is not being exported. This way, the users of the API are not able to write or read the contents of data. This way, we can create helper functions that would provide a restricted way to access the data hidden inside of this data structure, which helps us in setting rules. The idea is making impossible states impossible.

At some point I tried to answer a question -- how do I send a message from a sub module? As it turns out, it was a bad idea. What I needed to do is to let the caller know that something has happened -- for example, if the user calls the `update` function, it returns an updated `PomodoroTimer`. But what if during this update the time has ended and we need to tell the caller that the work is up? I thought it would be handy to send `WorkEnded` message, which would be handled by the update function, but it's a pretty bad idea, because with more of these things we can run in race conditions, because messages are not real time. So what I ended up doing is to return a record which contain the new `PomodoroTimer` and an "event" type, which can be either `None`, `WorkEnded`, or `BreakEnded`. Then the caller would handle these inside of their `update` function as soon as they update the timer.

One interesting problem I faced is splitting the `type Msg` into multiple pieces. So I did this:

```
type Msg
    = LoadedMsg LoadedMsg
    | Tick Posix

type LoadedMsg
    = StartWork
    | StartBreak
    | Stop
```

This is not great, but it was better than before, where all messages were in one place. Basically, I had to handle all messages, even if the app was not yet loaded, but it didn't make sense to handle `StartWork`, `StartBreak`, or `Stop`, when the UI is not even there to trigger any of these messages. So grouping them under `LoadedMsg` allowed me to only handle `LoadedMsg` and if the app is not loaded at the time, just ignore it. If the app is loaded at the time, then handle the three cases of `LoadedMsg`.

Then I didn't know how do I pass the nested messages to `onClick` function in HTML. I saw Richard Feldman using something like `LoadedMsg << StartWork`, but that didn't work for me. Then once I took a look at `Msg` and realized that it's just a regular union type, and can be initilized like any other regular union type, I figured out that I should be able to do it by just using `LoadedMsg StartWork`, and indeed that worked. Still don't know what did Richard do in that talk.

---

Today I'm going to make a "Border Quiz" game, where a player has to name all bordering countries of a given country. For example if a given country is "Finland", the player has to type it's neighbours: "Russia", "Sweden", "Norway".

Countries without any *land borders* will not be included in the quiz. that's pretty much most of Oceania and Caribbean island nations.

I made this came once back in the day in JavaScript, because I thought this was one of the best ways to really memorize the political geography of the world.

The game has a very simple UI:

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

1. Shows current country
2. Allows to enter one country at a time (pressing Enter in between)
3. Lists number of countries answered correctly, and how many are total
4. Shows overall game progress
5. Has a restart game button
6. Allows selecting different world regions to focus on: All, Asia, Africa, (Oceania ??), Europe, the Americas

Also, entering incorrect answer and pressing enter should either show an error text or simply do nothing.
Pressing enter on correct answer clears the input text box and updates the list of countries answered correctly.

### The data structure

One question I need to answer is how to represent the connection between neighboring countries.

1. A list of tuples or records, each having the country name, and a list of neighboring country names, such as:

```
[ ( "Finland", [ "Russia", "Sweden", "Norway" ] )
, ( "Sweden", [ "Norway", "Finland" ] )
, ( "Norway", [ "Sweden", "Finland", "Russia" ])
, ( "Denmark", [ "Germany ] )
, ...
]
```

2. A list of tuples or records, each having an id, country name, and a list of neighboring country ids, such as:

```
[ ( 1, "Finland", [ 10, 2, 3 ] )
, ( 2, "Sweden", [ 3, 1 ] )
, ( 3, "Norway", [ 2, 1, 10 ] )
, ( 4, "Denmark", [ 7 ] )
, ...
]
```

The number 1 is easier to work with, number 2 will probably make the final code size smaller. A thid option would be to store it as number 2, and then during loading convert it to number 1 format in memory.

Now that I think about it, I will probably want to use a record to represent each item, at least in memory:

```
type alias Country =
    { name : String
    , continents : List String
    , neighbors : List String
    }

type alias Continent =
    String
```

I'll think about optimization later. I'll start with full representation of these data structures at first. Then see how large is the bundle after compiling. Then try to optimize it.

So with this the structure would be:

```
continents : List Continent
continents =
    [ "Africa"
    , "Asia"
    , "Europe"
    , "North America"
    , "South America"
    ]
```

Ok, so there are obviously more continents than this, and "Americas" is arguably two continents, but for the purpose of this game, we really are not interested in Antarctica, Australia, and I'm leaving off Oceania, because of the lack of land borders and the lack of clear definition of "neighbouring" countries over there.

There are a few more tricky questions, such as, is Russia in Asia or Europe? Of course the answer is "both", but how do we represent it here? Or Turkey, Georgia, Armenia, Azerbaijan, Egypt, etc? There are a bunch of countries that belong to two different continents. One thing is for sure -- we are not dealing with precise science here.

One solution could be to allow to list multiple continents for each country. This would be pretty correct representation.

Another issue is that one country may be different accepted English names and spellings. So if the answer is "United States of America", so we require the user to type it exactly? Or do we allow "USA", or "United States"? Is it "East Timor" or "Timor-Leste", or even "Democratic Republic of Timor-Leste"? I think it would be a better idea to allow different *common* variations of country names. So now we end up with a bunch of lists:

```
type alias Country =
    { names : List String
    , continents : List String
    , neighbors : List String
    }
```

Now there's a new issue with this -- it's now difficult to refer to a country by a String name, because there are multiple names. We *could* just use one of the name variations, and then search the `names` list to match, but maybe I'll just use IDs.

So `Country` now becomes:

```
type alias Country =
    { id : Int
    , names : List String
    , continents : List Int
    , neighbors : List Int
    }
```

While we're at it, let's refer to continents using IDs as well, for consistency:

```
type alias Continent =
    { id : Int
    , name : String
    }
```

So now the data looks like this:

```
countries : List Country
countries =
    [ Country 0 [ "Afghanistan" ] [ 0 ] [ 31, 70, 112, 142, 148, 155 ]
    , Country 1 [ "Albania" ] [ 4 ] [ 92, 101, 60, 80 ]
    , Country 2 [ "Algeria" ] [ 1 ] [ 88, 95, 96, 102, 108, 146, 159 ]
    , Country 3 [ "Andorra" ] [ 4 ] [ 53, 134 ]
    , ...
```

Alright, I spent most of today's time building this structure and actually porting the list from JS to Elm.