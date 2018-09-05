## Day 25

Quick review of day 24:

TODO

--- 

Today I wanted to start with modelling a [Pomodoro timer](https://en.wikipedia.org/wiki/Pomodoro_Technique) in Elm. According to the principles, you cannot pause the pomodoro, so unlike some pomodoro timers, this app will not have an ability to pause and resume the timer. However, you should be able to stop the current timer and start over. Any interrupted pomodoro is not counted towards the total number of pomodoros completed.

I decided that the UI should have the following things:
- Current break or work time passed in mm:ss.
- Ability to interrupt the current pomodoro, resetting the timer, staying in work mode.
- Ability to interrupt the current break, resetting the timer to work mode.
- Number of pomodoros completed in this session.
- Work time would be set to 25 minutes, but consider it to be flexible in future.
- Break time would be set to 5 minutes, but consider it to be flexible in future.

At first I came up with the following Model: 

```
type alias Seconds = Int

type State
  = Stopped
  | Work Posix
  | Break Posix

type alias Settings =
  { workDuration : Seconds
  , breakDuration : Seconds
  }

type alias Model =
  { state : State
  , pomodorosCompleted : Int
  , settings : Settings
  }
```

Then I started looking at possible values the `Model` can have:

```
- Stopped, 0, { 360, 60 }
- Work 15:32, 10, { 560, 1000 }
- Break 10:30, 90, { 0, 50 }
- Break 10:30, -90, { -10, -50 } -- this is invalid
```

And noticed that the duration can be invalid. Now this is a very simple application, and worrying about that might be a bit of an overkill, but I wanted to practice data types, so I decided I could try to make a data type for duration that woud not allow invalid values.

The valid range for a timer is basically from 1 (minute) to infinite. So we cannot represent it with a union type, because we can't write infinite number of constructors for it. `Int` includes also zero and negative numbers, which are not appropriate for a number of minutes to count down from. So we have to do some custom module, that would use `Int` internally, but expose functions that would limit the values to an allowed range.

Now the question is, if user tries to initialize the duration with an invalid value, what should we return? I see a few options:

```
1. Return a default value (ex. 1 minute), return type being `Duration`.
2. Return a `Nothing`, return type being `Maybe Duration`.
3. Return an `Err` or similar, return type being `Result` or similar.
```

Let's see what each of this options mean:

```
1. (+) Easy to handle in UI logic, because there are no cases to switch over
   (-) Confusing for user, because the value they enter is suddenly chagned to something else
   (+) Most simple to implement
2. (-) Need to handle `Nothing` in UI logic
   (+) The UI can inform the user of their value being invalid
   (-) The UI cannot tell the user why the value is invalid
3. (-) Need to handle `Err` in the UI logic
   (+) The UI can inform the user of their value being invalid
   (+) The UI can show the user the reason for the error
   (-) Most complex to implement
```

So we have options from very simple to more complex, each offering their pros and cons. Considering the kind of data that we're working with -- number of minutes to work/rest, I'd say we don't need error messages to tell the user why "-1" minutes of work is not valid, so I would discard option 3 as it is unnecessarily complex in this case. I would also say that the users might not be too shocked that their invalid value is automatically changed to a valid one without being told that they in fact entered an invalid number -- at least in this particular use case. So this would rule out option 2. In conclusion, I'm going to go with option 1. I also decided to call this type a `NonNegativeInteger`, which seems to be the most precise definition for this number set according to [Wikipedia article on natural numbers](https://en.wikipedia.org/wiki/Natural_number)

We also need to represent number of pomodoros completed, which can be anything from zero and up. I decided to call this type a `PositiveInteger`, again, based on the [same Wikipedia article as before](https://en.wikipedia.org/wiki/Natural_number).

Here are the implementations:

```
module NonNegativeInteger exposing (NonNegativeInteger, fromInt, toInt)

type NonNegativeInteger
  = NonNegativeInteger Int

fromInt : Int -> NonNegativeInteger
fromInt int =
  if int < 0 then
    NonNegativeInteger 0
  else
    NonNegativeInteger int

toInt : NonNegativeInteger -> Int
toInt (NonNegativeInteger int) =
  int
```

```
module PositiveInteger exposing (PositiveInteger, fromInt, toInt)

type PositiveInteger
  = PositiveInteger Int

fromInt : Int -> PositiveInteger
fromInt int =
  if int < 1 then
    PositiveInteger 1
  else
    PositiveInteger int

toInt : PositiveInteger -> Int
toInt (PositiveInteger int) =
  int
```

So then we can use them in our model:

```
type State
  = Stopped
  | Work Posix
  | Break Posix

type alias Settings =
  { workDurationSeconds : PositiveInteger
  , breakDurationSeconds : PositiveInteger
  }

type alias Model =
  { state : State
  , pomodorosCompleted : NonNegativeInteger
  , settings : Settings
  }
```

Note that I decided not to do a `Seconds` type alias anymore, because I guess seconds can also be zero or negative, for example in case of time offsets. So defining `Seconds` as a `PositiveInteger` would be wrong. Because of this, I decided to change the name of work and break durations to include `Seconds` postfilx to communicate the type of duration.

Now I think I want to build in some constraints on how this model should be updated. So I'm going to break the Pomodoro functionality into its own module. Currently that's the whole model, however, when we build the rest of the application UI, it might the model might gain some other non-pomodoro related fields.

```
type alias Model = PomodoroTimer
```

```
type State
  = Stopped
  | Work Posix
  | Break Posix

type alias Settings =
  { workDurationSeconds : PositiveInteger
  , breakDurationSeconds : PositiveInteger
  }

type PomodoroTimer
    = PomodoroTimer
        { state : State
        , pomodorosCompleted : NonNegativeInteger
        , settings : Settings
        }
```

Now we can add some helper functions to work with the timer:

```
mapSettings : (Settings -> Settings) -> PomodoroTimer -> PomodoroTimer
mapSettings fn (PomodoroTimer pomodoroTimer) =
    PomodoroTimer { pomodoroTimer | settings = fn pomodoroTimer.settings }


startWork : Posix -> PomodoroTimer -> PomodoroTimer
startWork timeNow (PomodoroTimer pomodoroTimer) =
    PomodoroTimer { pomodoroTimer | state = Work timeNow }


startBreak : Posix -> PomodoroTimer -> PomodoroTimer
startBreak timeNow (PomodoroTimer pomodoroTimer) =
    PomodoroTimer { pomodoroTimer | state = Break timeNow }


stop : PomodoroTimer -> PomodoroTimer
stop (PomodoroTimer pomodoroTimer) =
    PomodoroTimer { pomodoroTimer | state = Stopped }
```

And finally we need to be able to update the timer by giving it new POSIX time stamp:

```
update : Posix -> PomodoroTimer -> PomodoroTimer
update timeNow (PomodoroTimer pomodoroTimer) =
    case pomodoroTimer.state of
        Stopped ->
            PomodoroTimer pomodoroTimer

        Work timeStarted ->
            let
                secondsPassed =
                    posixToMillis timeNow - posixToMillis timeStarted
            in
            if secondsPassed >= PositiveInteger.toInt pomodoroTimer.settings.workDurationSeconds then
                let
                    (PomodoroTimer stoppedPomodoroTimer) =
                        stop (PomodoroTimer pomodoroTimer)
                in
                PomodoroTimer { stoppedPomodoroTimer | pomodorosCompleted = NonNegativeInteger.inc pomodoroTimer.pomodorosCompleted }

            else
                PomodoroTimer pomodoroTimer

        Break timeStarted ->
            let
                secondsPassed =
                    posixToMillis timeNow - posixToMillis timeStarted
            in
            if secondsPassed >= PositiveInteger.toInt pomodoroTimer.settings.breakDurationSeconds then
                stop (PomodoroTimer pomodoroTimer)

            else
                PomodoroTimer pomodoroTimer
```

This is the only place where we update `pomodorosCompleted`, and check if the time is up. But how does our caller know when to show an alert to user that work or break has ended? We could do some logic that would check a change of state *and* make sure that it wasn't due to user stopping it, but that's too complicated and error-prone. Perhaps we should return an extra argument from the `update` function:

```
type PomodoroEvent
    = None
    | WorkEnded
    | BreakEnded

update : Posix -> PomodoroTimer -> { timer : PomodoroTimer, event : PomodoroEvent }
update timeNow (PomodoroTimer pomodoroTimer) =
    case pomodoroTimer.state of
        Stopped ->
            { timer = PomodoroTimer pomodoroTimer, event = None }

        Work timeStarted ->
            let
                secondsPassed =
                    (posixToMillis timeNow - posixToMillis timeStarted) // 1000
            in
            if secondsPassed >= PositiveInteger.toInt pomodoroTimer.workDurationSeconds then
                let
                    (PomodoroTimer stoppedPomodoroTimer) =
                        stop (PomodoroTimer pomodoroTimer)
                in
                { timer = PomodoroTimer { stoppedPomodoroTimer | pomodorosCompleted = NonNegativeInteger.inc pomodoroTimer.pomodorosCompleted }
                , event = WorkEnded
                }

            else
                { timer = PomodoroTimer pomodoroTimer, event = None }

        Break timeStarted ->
            let
                secondsPassed =
                    (posixToMillis timeNow - posixToMillis timeStarted) // 1000
            in
            if secondsPassed >= PositiveInteger.toInt pomodoroTimer.breakDurationSeconds then
                { timer = stop (PomodoroTimer pomodoroTimer), event = BreakEnded }

            else
                { timer = PomodoroTimer pomodoroTimer, event = None }
```

But how can our UI access the state of the timer without knowing its internal implementation? Let's writing some getters:

```
settings : PomodoroTimer -> Settings
settings (PomodoroTimer pomodoroTimer) =
    pomodoroTimer.settings


pomodorosCompleted : PomodoroTimer -> Int
pomodorosCompleted (PomodoroTimer pomodoroTimer) =
    NonNegativeInteger.toInt pomodoroTimer.pomodorosCompleted


state : PomodoroTimer -> State
state (PomodoroTimer pomodoroTimer) =
    pomodoroTimer.state
```

As I thought more about this stucture, I decided to flatten the model a bit, getting rid of the `Settings` type alias:

```
type PomodoroTimer
    = PomodoroTimer
        { state : State
        , pomodorosCompleted : NonNegativeInteger
        , workDurationSeconds : PositiveInteger
        , breakDurationSeconds : PositiveInteger
        }
```

Now in order to work on settings, the following functions are provided:

```
workDurationSeconds : PomodoroTimer -> Int
workDurationSeconds (PomodoroTimer pomodoroTimer) =
    PositiveInteger.toInt pomodoroTimer.workDurationSeconds


breakDurationSeconds : PomodoroTimer -> Int
breakDurationSeconds (PomodoroTimer pomodoroTimer) =
    PositiveInteger.toInt pomodoroTimer.breakDurationSeconds


mapWorkDurationSeconds : (Int -> Int) -> PomodoroTimer -> PomodoroTimer
mapWorkDurationSeconds fn (PomodoroTimer pomodoroTimer) =
    PomodoroTimer
        { pomodoroTimer
            | workDurationSeconds = PositiveInteger.fromInt (fn (PositiveInteger.toInt pomodoroTimer.workDurationSeconds))
        }


mapBreakDurationSeconds : (Int -> Int) -> PomodoroTimer -> PomodoroTimer
mapBreakDurationSeconds fn (PomodoroTimer pomodoroTimer) =
    PomodoroTimer
        { pomodoroTimer
            | breakDurationSeconds = PositiveInteger.fromInt (fn (PositiveInteger.toInt pomodoroTimer.breakDurationSeconds))
        }
```

A helper function to see how much time is left to work / break:

```
timeLeftSeconds : PomodoroTimer -> Posix -> Int
timeLeftSeconds (PomodoroTimer pomodoroTimer) timeNow =
    case pomodoroTimer.state of
        Stopped ->
            0

        Work timeStarted ->
            PositiveInteger.toInt pomodoroTimer.workDurationSeconds - (posixToMillis timeNow - posixToMillis timeStarted) // 1000

        Break timeStarted ->
            PositiveInteger.toInt pomodoroTimer.breakDurationSeconds - (posixToMillis timeNow - posixToMillis timeStarted) // 1000
```

Finally, to initialize the timer I wrote the following function:

```
init : Int -> Int -> PomodoroTimer
init newWorkDurationSeconds newBreakDurationSeconds =
    PomodoroTimer
        { state = Stopped
        , pomodorosCompleted = NonNegativeInteger.fromInt 0
        , workDurationSeconds = PositiveInteger.fromInt newWorkDurationSeconds
        , breakDurationSeconds = PositiveInteger.fromInt newBreakDurationSeconds
        }
```

That should be it for the PomodoroTimer module. And I think that should conclude my exploration for this data structure. I wrote a crude UI that tests that this actually works in real life. A few small things had to be changed, but they can all be found in the source code under `src/data-structures/Pomodoro`.