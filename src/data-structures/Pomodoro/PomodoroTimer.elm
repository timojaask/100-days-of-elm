module PomodoroTimer exposing
    ( PomodoroEvent(..)
    , PomodoroTimer
    , State(..)
    , breakDurationSeconds
    , init
    , mapBreakDurationSeconds
    , mapWorkDurationSeconds
    , pomodorosCompleted
    , startBreak
    , startWork
    , state
    , stop
    , timeLeftSeconds
    , update
    , workDurationSeconds
    )

import Debug
import NonNegativeInteger exposing (NonNegativeInteger)
import PositiveInteger exposing (PositiveInteger)
import Time exposing (Posix, posixToMillis)


type State
    = Stopped
    | Work Posix
    | Break Posix


type PomodoroTimer
    = PomodoroTimer
        { state : State
        , pomodorosCompleted : NonNegativeInteger
        , workDurationSeconds : PositiveInteger
        , breakDurationSeconds : PositiveInteger
        }


type PomodoroEvent
    = None
    | WorkEnded
    | BreakEnded


init : Int -> Int -> PomodoroTimer
init newWorkDurationSeconds newBreakDurationSeconds =
    PomodoroTimer
        { state = Stopped
        , pomodorosCompleted = NonNegativeInteger.fromInt 0
        , workDurationSeconds = PositiveInteger.fromInt newWorkDurationSeconds
        , breakDurationSeconds = PositiveInteger.fromInt newBreakDurationSeconds
        }


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


pomodorosCompleted : PomodoroTimer -> Int
pomodorosCompleted (PomodoroTimer pomodoroTimer) =
    NonNegativeInteger.toInt pomodoroTimer.pomodorosCompleted


state : PomodoroTimer -> State
state (PomodoroTimer pomodoroTimer) =
    pomodoroTimer.state


startWork : Posix -> PomodoroTimer -> PomodoroTimer
startWork timeNow (PomodoroTimer pomodoroTimer) =
    PomodoroTimer { pomodoroTimer | state = Work timeNow }


startBreak : Posix -> PomodoroTimer -> PomodoroTimer
startBreak timeNow (PomodoroTimer pomodoroTimer) =
    PomodoroTimer { pomodoroTimer | state = Break timeNow }


stop : PomodoroTimer -> PomodoroTimer
stop (PomodoroTimer pomodoroTimer) =
    PomodoroTimer { pomodoroTimer | state = Stopped }


timeLeftSeconds : PomodoroTimer -> Posix -> Int
timeLeftSeconds (PomodoroTimer pomodoroTimer) timeNow =
    case pomodoroTimer.state of
        Stopped ->
            0

        Work timeStarted ->
            PositiveInteger.toInt pomodoroTimer.workDurationSeconds - (posixToMillis timeNow - posixToMillis timeStarted) // 1000

        Break timeStarted ->
            PositiveInteger.toInt pomodoroTimer.breakDurationSeconds - (posixToMillis timeNow - posixToMillis timeStarted) // 1000


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
